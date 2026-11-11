import type {Firestore} from 'firebase-admin/firestore';
import {HttpsError} from 'firebase-functions/v2/https';
import {inCustomCorpus, isCustomExamId} from './_customTrack.js';

export type QuestionRef = {id: string; setId: string; topicId: string; lessonId: string | null; passageId: string | null};
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
    let set: {meta?: {topic?: string; subtopic?: string; exams?: string[]}; questions?: {id: string; passage?: unknown; isActive?: boolean; figure?: unknown; figureSpec?: unknown}[]};
    try {
      set = JSON.parse(String(doc.get('payload')));
    } catch {
      continue; // A malformed document must not break every roadmap and mock for the exam.
    }
    const topic = set.meta?.topic;
    if (typeof topic !== 'string' || !set.meta?.exams?.includes(slug)) continue;
    topicSlugs.add(topic);
    for (const question of set.questions ?? []) {
      if (question.isActive === false || question.figure != null && String(question.figure).trim() !== '' && question.figureSpec == null) continue;
      questions.push({id: question.id, setId: doc.id, topicId: topicIdFor(examId, topic),
        lessonId: typeof set.meta.subtopic === 'string' ? `lesson-${topic}-${set.meta.subtopic}` : null,
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
export const clearExamContentCache = (): void => { cache.clear(); gapCache = undefined; corpusCache = undefined; };

export type StudyContent = {
  revision: string;
  subjects: {id: string; name: string; ordering: number}[];
  topics: {id: string; name: string; subjectId: string; ordering: number}[];
  lessons: {id: string; topicId: string; title: string; ordering: number; prerequisites: {lesson: string; strength: 'required' | 'helpful'}[]}[];
  questions: {id: string; setId: string; topicId: string; lessonId: string | null; passageId: string | null}[];
};
type CatalogReference = string | {_ref: string};
type CatalogSubject = {_id: string; name: string; ordering?: number; exam?: CatalogReference};
type CatalogTopic = {_id: string; name: string; subject: CatalogReference; ordering?: number};
type CatalogLesson = {id: string; topic: CatalogReference; title: string; ordering?: number; prerequisites?: {lesson: string; strength: 'required' | 'helpful'}[]};
type CatalogSet = {id: string; topic: CatalogReference; lesson?: CatalogReference | null; exams: string[];
  questions: {id: string; passage?: CatalogReference | null; isActive?: boolean}[]};
type CatalogDocument = {subjects?: CatalogSubject[]; topics?: CatalogTopic[]; lessons?: CatalogLesson[];
  sets?: CatalogSet[]; parts?: string[]; catalogs?: string[]};
/**
 * Missing, unreadable or inconsistent authored catalog data is a content problem the student can
 * retry after, never a crash: it carries a typed `unavailable` code instead of a raw parse error.
 */
const contentUnavailable = (message: string) => new HttpsError('unavailable', message);

/** Resolves authored relationships from the current C7 catalog. Shared historical
 * UPCAT-named ids remain identities, never an inferred exam/subject assignment. A custom exam id
 * gets the union of every catalog the index lists (see `loadStudy`). */
export async function loadStudyContent(db: Firestore, examId: string,
  tx?: FirebaseFirestore.Transaction): Promise<StudyContent> {
  return scopeStudy(await loadStudy(db, examId, isCustomExamId(examId), tx));
}

/** The listing rule, then only the subjects a kept topic belongs to. */
function scopeStudy(raw: StudyContent): StudyContent {
  const content = scopeLessonContent(raw);
  const keptSubjects = new Set(content.topics.map(t => t.subjectId));
  return {...content, subjects: content.subjects.filter(s => keptSubjects.has(s.id))};
}

/** Compatibility exclusions need every authored lesson relationship. */
export async function loadStudyContentLinks(db: Firestore, examId: string):
  Promise<Pick<StudyContent, 'lessons' | 'questions'>> {
  const {lessons, questions} = await loadStudy(db, examId, isCustomExamId(examId));
  return {lessons, questions};
}

/**
 * Simplicity note: there is no corpus-level content document. The union is read from the catalogs
 * `index.catalogs` lists, nine documents today. If that list grows past about 20, build one corpus
 * document in `catalogItems` and read it here instead.
 */
async function loadStudy(db: Firestore, examId: string, custom: boolean,
  tx?: FirebaseFirestore.Transaction): Promise<StudyContent> {
  const versions: string[] = [], fetching = new Map<string, Promise<CatalogDocument | null>>();
  // One fetch per document, even when two callers ask at once, so it counts once in the revision.
  const fetchOnce = (id: string): Promise<CatalogDocument | null> => {
    if (!fetching.has(id)) fetching.set(id, (async () => {
      if (!id || id.includes('/')) throw contentUnavailable('Invalid catalog identity.');
      const ref = db.doc('content/catalog/items/' + id), doc = await (tx ? tx.get(ref) : ref.get());
      if (!doc.exists) return null;
      let raw: unknown;
      try { raw = JSON.parse(String(doc.get('payload'))); }
      catch { throw contentUnavailable('The exam content catalog could not be read.'); }
      if (!raw || typeof raw !== 'object' || Array.isArray(raw)) throw contentUnavailable('Invalid exam catalog.');
      versions.push(id + ':' + String(doc.get('version')));
      return raw as CatalogDocument;
    })());
    return fetching.get(id)!;
  };
  const read = async (id: string, required = true): Promise<CatalogDocument | null> => {
    const value = await fetchOnce(id);
    if (!value && required) throw contentUnavailable('The exam content catalog is not available.');
    return value;
  };
  const withParts = async (id: string): Promise<CatalogDocument[]> => {
    const root = (await read(id))!;
    return [root, ...await Promise.all((root.parts ?? []).map(async part => (await read(part))!))];
  };
  let selected: CatalogDocument[], index: CatalogDocument | null;
  if (custom) {
    // The index is required and names the catalogs: a missing one is unavailable, never a partial corpus.
    index = await read('index');
    const catalogs = index?.catalogs;
    if (!Array.isArray(catalogs) || catalogs.length === 0 || !catalogs.every(id => typeof id === 'string')) {
      throw contentUnavailable('The exam content catalog is not available.');
    }
    selected = (await Promise.all(catalogs.map(withParts))).flat();
  } else {
    selected = await withParts(examId);
    index = await read('index', false);
  }
  const refId = (value: CatalogReference | undefined | null): string =>
    typeof value === 'string' ? value : value?._ref ?? '';
  // A set tagged for several exams sits in each exam's catalog, so the union keeps one copy per set id.
  // Real uploads write identical copies, so copies that differ mean this read met an upload: retry, never mix.
  const offered = selected.flatMap(d => d.sets ?? []);
  const seen = new Map<string, string>();
  const unique = custom ? offered.filter(s => {
    const copy = JSON.stringify([refId(s.topic), s.lesson == null ? null : refId(s.lesson), s.questions]);
    const first = seen.get(s.id);
    if (first === undefined) { seen.set(s.id, copy); return true; }
    if (first !== copy) throw contentUnavailable('Question-set copies differ.');
    return false;
  }) : offered;
  const sets = unique.filter(s => {
    if (!Array.isArray(s.exams)) throw contentUnavailable('Question-set exam membership is not available.');
    return custom ? inCustomCorpus(s) : s.exams.includes(examId);
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
    for(const doc of docs)for(const lesson of doc.lessons ?? [])if(requestedTopics.has(refId(lesson.topic)))allLessons.set(lesson.id,lesson);
  };
  collect(selected);
  // Load owning catalogs before validating authored lesson relationships.
  const owners = new Set([...requestedTopics].map(id => {
    const topic = allTopics.get(id);
    return topic ? refId(allSubjects.get(refId(topic.subject))?.exam) : '';
  }).filter(id => id && id !== examId));
  for (const owner of owners) collect(await withParts(owner));
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
  const lessons=[...allLessons.values()].map(l=>({id:l.id,topicId:refId(l.topic),title:l.title,ordering:l.ordering??0,prerequisites:l.prerequisites??[]})).sort((a,b)=>a.ordering-b.ordering||a.id.localeCompare(b.id));
  const questions=sets.flatMap(s=>s.questions.filter(q=>q.isActive!==false).map(q=>({id:q.id,setId:s.id,topicId:refId(s.topic),
    lessonId:s.lesson==null?null:refId(s.lesson),passageId:q.passage==null?null:refId(q.passage)})));
  if(new Set(questions.map(q=>q.id)).size!==questions.length)throw contentUnavailable('Duplicate authored question identities.');
  return {revision:versions.sort().join('|') + ':exam-lessons-v2',subjects,topics,lessons,questions};
}

/** One listing and planning rule: an active exam question must link to the lesson. */
export function scopeLessonContent<T extends {
  topics: {id: string}[];
  lessons: {id: string; topicId: string}[];
  questions: {topicId: string; lessonId: string | null}[];
}>(content: T, excludedTopics: string[] = [], excludedLessons: string[] = []): T {
  const questions = content.questions.filter(q => !excludedTopics.includes(q.topicId) &&
    (q.lessonId === null || !excludedLessons.includes(q.lessonId)));
  const linked = new Map<string, Set<string>>();
  for (const q of questions) {
    if (q.lessonId === null) continue;
    if (!linked.has(q.topicId)) linked.set(q.topicId, new Set());
    linked.get(q.topicId)!.add(q.lessonId);
  }
  const lessons = content.lessons.filter(l => !excludedTopics.includes(l.topicId) &&
    !excludedLessons.includes(l.id) && linked.get(l.topicId)?.has(l.id));
  const topics = new Set(lessons.map(l => l.topicId));
  const lessonTopics = new Set(content.lessons.map(l => l.topicId));
  for (const q of questions) {
    if (!lessonTopics.has(q.topicId)) topics.add(q.topicId);
  }
  return {...content, lessons, topics: content.topics.filter(t => topics.has(t.id)),
    questions};
}

let corpusCache: {at: number; value: StudyContent} | undefined;
/**
 * The custom-exam corpus for readers that are not transactional. Kept five minutes, like `loadExamContent`.
 * `fresh` skips the kept copy and reads again, then keeps what it read.
 */
export async function loadCorpusCached(db: Firestore, now: number, {fresh = false}: {fresh?: boolean} = {}): Promise<StudyContent> {
  if (!fresh && corpusCache && now >= corpusCache.at && now - corpusCache.at < TTL_MS) return corpusCache.value;
  const value = scopeStudy(await loadStudy(db, 'corpus', true));
  corpusCache = {at: now, value};
  return value;
}

/** What a student's excluded topics and lessons leave: the questions and lessons they can still be given. */
export function applyScope(content: StudyContent, excludedTopicIds: Iterable<string> = [],
  excludedLessonIds: Iterable<string> = []): StudyContent {
  const excluded = new Set(excludedTopicIds), excludedLessons = new Set(excludedLessonIds);
  const includedTopics = new Set(content.topics.filter(t => !excluded.has(t.id)).map(t => t.id));
  return {...content, topics: content.topics.filter(t => includedTopics.has(t.id)),
    lessons: content.lessons.filter(l => includedTopics.has(l.topicId) && !excludedLessons.has(l.id)),
    questions: content.questions.filter(q => includedTopics.has(q.topicId) && (q.lessonId === null || !excludedLessons.has(q.lessonId)))};
}

let gapCache: {at: number; value: Record<string, string>} | undefined;
/** Gap tags stay server-only. One document, cached for five minutes like exam content. */
export async function loadGapTags(db: Firestore, now: number): Promise<Record<string, string>> {
  if (gapCache && now >= gapCache.at && now - gapCache.at < TTL_MS) return gapCache.value;
  const doc = await db.doc('content/gaps/items/tags').get();
  const value: Record<string, string> = {};
  if (doc.exists) {
    let raw: unknown;
    try { raw = JSON.parse(String(doc.get('payload'))); }
    catch { throw contentUnavailable('The prerequisite content could not be read.'); }
    if (!raw || typeof raw !== 'object' || Array.isArray(raw)) throw contentUnavailable('Invalid prerequisite content.');
    for (const choices of Object.values(raw)) {
      if (!choices || typeof choices !== 'object' || Array.isArray(choices)) throw contentUnavailable('Invalid prerequisite content.');
      for (const [choice, lesson] of Object.entries(choices)) {
        if (typeof lesson !== 'string') throw contentUnavailable('Invalid prerequisite content.');
        value[choice] = lesson;
      }
    }
  }
  gapCache = {at: now, value};
  return value;
}
