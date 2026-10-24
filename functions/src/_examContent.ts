import type {Firestore} from 'firebase-admin/firestore';
import {HttpsError} from 'firebase-functions/v2/https';

export type QuestionRef = {id: string; setId: string; topicId: string; passageId: string | null};
export type LessonRef = {id: string; topicId: string; ordering: number};
export type ExamContent = {
  topics: {id: string; name: string}[];
  questions: QuestionRef[];
  lessons: LessonRef[];
};

const TTL_MS = 5 * 60_000;
const cache = new Map<string, {at: number; value: ExamContent}>();

/** `exam_dost_sei` is `dost-sei` in a question set's `meta.exams`. */
export const examSlug = (examId: string): string => examId.replace(/^exam_/, '').replace(/_/g, '-');

/** The topic id the app's seed and the mock blueprints use: `topic_<exam>_<topic>`. */
export const topicIdFor = (examId: string, topic: string): string =>
  `topic_${examId.replace(/^exam_/, '')}_${topic.replace(/-/g, '_')}`;

const titleCase = (slug: string): string => slug.split('-').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');

/**
 * Reads the exam's questions and lessons from the server-only content collections. The result is
 * kept in this instance's memory for a few minutes, because a roadmap recompute or a mock start
 * would otherwise read the whole bank each time.
 */
export async function loadExamContent(db: Firestore, examId: string, now: number): Promise<ExamContent> {
  const hit = cache.get(examId);
  if (hit && now - hit.at < TTL_MS && now >= hit.at) return hit.value;
  const slug = examSlug(examId);
  const questions: QuestionRef[] = [];
  const topicSlugs = new Set<string>();
  for (const doc of (await db.collection('content/questions/items').get()).docs) {
    let set: {meta?: {topic?: string; exams?: string[]}; questions?: {id: string; passage?: unknown}[]};
    try {
      set = JSON.parse(String(doc.get('payload')));
    } catch {
      continue; // A malformed document must not break every roadmap and mock for the exam.
    }
    const topic = set.meta?.topic;
    if (typeof topic !== 'string' || !set.meta?.exams?.includes(slug)) continue;
    topicSlugs.add(topic);
    for (const question of set.questions ?? []) {
      questions.push({id: question.id, setId: doc.id, topicId: topicIdFor(examId, topic),
        passageId: typeof question.passage === 'string' ? question.passage : null});
    }
  }
  const lessons: LessonRef[] = [];
  const lessonDocs = (await db.collection('content/lessons/items').select('topic').get()).docs
    .map(doc => ({id: doc.id, topic: String(doc.get('topic') ?? '').replace(/^topic-/, '')}))
    .filter(lesson => topicSlugs.has(lesson.topic))
    .sort((a, b) => (a.id < b.id ? -1 : 1));
  const counts = new Map<string, number>();
  for (const lesson of lessonDocs) {
    const ordering = counts.get(lesson.topic) ?? 0;
    counts.set(lesson.topic, ordering + 1);
    lessons.push({id: lesson.id, topicId: topicIdFor(examId, lesson.topic), ordering});
  }
  const value: ExamContent = {
    topics: [...topicSlugs].sort().map(topic => ({id: topicIdFor(examId, topic), name: titleCase(topic)})),
    questions, lessons,
  };
  cache.set(examId, {at: now, value});
  return value;
}

/** For tests: content changes between cases. */
export const clearExamContentCache = (): void => cache.clear();

export type StudyContent = {
  revision: string;
  subjects: {id: string; name: string; ordering: number}[];
  topics: {id: string; name: string; subjectId: string; ordering: number}[];
  lessons: {id: string; topicId: string; title: string; ordering: number}[];
  questions: {id: string; setId: string; topicId: string; lessonId: string | null; passageId: string | null}[];
};
type CatalogReference = string | {_ref: string};
type CatalogSubject = {_id: string; name: string; ordering?: number; exam?: CatalogReference};
type CatalogTopic = {_id: string; name: string; subject: CatalogReference; ordering?: number};
type CatalogLesson = {id: string; topic: CatalogReference; title: string; ordering?: number};
type CatalogSet = {id: string; topic: CatalogReference; lesson?: CatalogReference | null; exams: string[];
  questions: {id: string; passage?: CatalogReference | null}[]};
type CatalogDocument = {subjects?: CatalogSubject[]; topics?: CatalogTopic[]; lessons?: CatalogLesson[];
  sets?: CatalogSet[]; parts?: string[]; catalogs?: string[]};
/**
 * Missing, unreadable or inconsistent authored catalog data is a content problem the student can
 * retry after, never a crash: it carries a typed `unavailable` code instead of a raw parse error.
 */
const contentUnavailable = (message: string) => new HttpsError('unavailable', message);

/** Resolves authored relationships from the current C7 catalog. Shared historical
 * UPCAT-named ids remain identities, never an inferred exam/subject assignment. */
export async function loadStudyContent(db: Firestore, examId: string,
  tx?: FirebaseFirestore.Transaction): Promise<StudyContent> {
  const versions: string[] = [], loaded = new Map<string, CatalogDocument>();
  const read = async (id: string, required = true): Promise<CatalogDocument | null> => {
    if (loaded.has(id)) return loaded.get(id)!;
    if (!id || id.includes('/')) throw contentUnavailable('Invalid catalog identity.');
    const ref = db.doc('content/catalog/items/' + id), doc = await (tx ? tx.get(ref) : ref.get());
    if (!doc.exists) {
      if (required) throw contentUnavailable('The exam content catalog is not available.');
      return null;
    }
    let raw: unknown;
    try { raw = JSON.parse(String(doc.get('payload'))); }
    catch { throw contentUnavailable('The exam content catalog could not be read.'); }
    if (!raw || typeof raw !== 'object' || Array.isArray(raw)) throw contentUnavailable('Invalid exam catalog.');
    const value = raw as CatalogDocument;
    loaded.set(id, value); versions.push(id + ':' + String(doc.get('version')));
    return value;
  };
  const withParts = async (id: string): Promise<CatalogDocument[]> => {
    const root = (await read(id))!;
    return [root, ...await Promise.all((root.parts ?? []).map(async part => (await read(part))!))];
  };
  const selected = await withParts(examId), index = await read('index', false);
  const refId = (value: CatalogReference | undefined | null): string =>
    typeof value === 'string' ? value : value?._ref ?? '';
  const sets = selected.flatMap(d => d.sets ?? []).filter(s => {
    if (!Array.isArray(s.exams)) throw contentUnavailable('Question-set exam membership is not available.');
    return s.exams.includes(examId);
  });
  const requestedTopics = new Set(sets.map(s => refId(s.topic)));
  const requestedLessons = new Set(sets.flatMap(s => s.lesson == null ? [] : [refId(s.lesson)]));
  const allSubjects = new Map<string, CatalogSubject>(), allTopics = new Map<string, CatalogTopic>();
  for (const doc of [...(index ? [index] : []), ...selected]) {
    for (const subject of doc.subjects ?? []) allSubjects.set(subject._id,subject);
    for (const topic of doc.topics ?? []) allTopics.set(topic._id,topic);
  }
  const allLessons = new Map<string,CatalogLesson>();
  const collect = (docs: CatalogDocument[]) => {
    for(const doc of docs)for(const lesson of doc.lessons ?? [])if(requestedLessons.has(lesson.id))allLessons.set(lesson.id,lesson);
  };
  collect(selected);
  for(const id of index?.catalogs ?? []) {
    if ([...requestedLessons].every(id=>allLessons.has(id))) break;
    if(id!==examId)collect(await withParts(id));
  }
  for (const id of requestedTopics) {
    const topic=allTopics.get(id);
    if(!topic || !allSubjects.has(refId(topic.subject))) throw contentUnavailable('An authored topic relationship is not available.');
  }
  for (const id of requestedLessons) {
    const lesson=allLessons.get(id);
    if(!lesson || !requestedTopics.has(refId(lesson.topic))) throw contentUnavailable('An authored lesson relationship is not available.');
  }
  for(const set of sets) if(set.lesson!=null && refId(allLessons.get(refId(set.lesson))?.topic)!==refId(set.topic)) {
    throw contentUnavailable('The lesson and question-set topics differ.');
  }
  const subjectIds=new Set([...requestedTopics].map(id=>refId(allTopics.get(id)!.subject)));
  const subjects=[...subjectIds].map(id=>allSubjects.get(id)!).map(s=>({id:s._id,name:s.name,ordering:s.ordering??0}))
    .sort((a,b)=>a.ordering-b.ordering || a.id.localeCompare(b.id));
  const subjectOrder=new Map(subjects.map((s,i)=>[s.id,i]));
  const topics=[...requestedTopics].map(id=>allTopics.get(id)!).map(t=>({id:t._id,name:t.name,subjectId:refId(t.subject),ordering:t.ordering??0}))
    .sort((a,b)=>(subjectOrder.get(a.subjectId)!-subjectOrder.get(b.subjectId)!)||a.ordering-b.ordering||a.id.localeCompare(b.id));
  const lessons=[...allLessons.values()].map(l=>({id:l.id,topicId:refId(l.topic),title:l.title,ordering:l.ordering??0}));
  const questions=sets.flatMap(s=>s.questions.map(q=>({id:q.id,setId:s.id,topicId:refId(s.topic),
    lessonId:s.lesson==null?null:refId(s.lesson),passageId:q.passage==null?null:refId(q.passage)})));
  if(new Set(questions.map(q=>q.id)).size!==questions.length)throw contentUnavailable('Duplicate authored question identities.');
  return {revision:versions.sort().join('|'),subjects,topics,lessons,questions};
}
