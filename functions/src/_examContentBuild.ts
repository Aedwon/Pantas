import {HttpsError} from 'firebase-functions/v2/https';

// Pure exam-content builder, shared by the server's loader (`_examContent.ts`) and the content upload
// (`contentUpload.ts`). It imports nothing that starts a Firebase app, so the upload tool can load it.

export type QuestionRef = {id: string; setId: string; topicId: string; lessonId: string | null; passageId: string | null};
export type LessonRef = {id: string; topicId: string; ordering: number};
export type ExamContent = {
  retiredReplacements?: Record<string,string[]>;
  topics: {id: string; name: string}[];
  questions: QuestionRef[];
  lessons: LessonRef[];
};

const contentUnavailable = (message: string): HttpsError => new HttpsError('unavailable', message);

export type AliasLesson = {id: string; status?: string; replacedBy?: string[]};
export function lessonResolver(lessons: AliasLesson[]): (id: string | null, explicit?: boolean) => string | null {
  const byId = new Map(lessons.map(l => [l.id, l]));
  const visiting = new Set<string>(), visited = new Set<string>();
  const visit = (id: string): void => {
    if (visiting.has(id)) throw contentUnavailable(`replacedBy cycle at ${id}`);
    if (visited.has(id)) return;
    const lesson = byId.get(id);
    if (!lesson) throw contentUnavailable(`unknown lesson ${id}`);
    if (lesson.status === 'retired' && !lesson.replacedBy?.length) throw contentUnavailable(`empty replacedBy at ${id}`);
    visiting.add(id);
    for (const next of lesson.replacedBy ?? []) visit(next);
    visiting.delete(id);
    visited.add(id);
  };
  for (const lesson of lessons) visit(lesson.id);
  return (id, explicit = false) => {
    if (id === null) return null;
    if (!byId.has(id)) {
      if (explicit) throw contentUnavailable(`unknown lesson ${id}`);
      return id; // Preserve legacy derived links for catalogs with no matching lesson.
    }
    while (byId.get(id)?.status === 'retired') id = byId.get(id)!.replacedBy![0];
    return id;
  };
}

/** `exam_dost_sei` is `dost-sei` in a question set's `meta.exams`. */
export const examSlug = (examId: string): string => examId.replace(/^exam_/, '').replace(/_/g, '-');

/** The topic id the app's seed and the mock blueprints use: `topic_<exam>_<topic>`. */
export const topicIdFor = (examId: string, topic: string): string =>
  `topic_${examId.replace(/^exam_/, '')}_${topic.replace(/-/g, '_')}`;

export const titleCase = (slug: string): string => slug.split('-').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');

/** A lesson document's fields the builder reads (`content/lessons/items`). */
export type BankLesson = {id: string; topic?: unknown; status?: unknown; replacedBy?: unknown; ordering?: unknown; isActive?: unknown};
/** A question-set document's id and JSON payload (`content/questions/items`). */
export type BankSet = {id: string; payload: unknown};

/**
 * Turns the stored lessons and question sets into one exam's content. The whole-bank scan and the
 * upload's exam summaries both call this, so the two cannot drift. Inputs are in document id order,
 * as Firestore returns them.
 */
export function buildExamContent(examId: string, bankLessons: BankLesson[], bankSets: BankSet[]): ExamContent {
  const slug = examSlug(examId);
  const lessonDocs = bankLessons.map(doc => ({
    id: doc.id, topic: String(doc.topic ?? '').replace(/^topic-/, ''),
    status: doc.status as string | undefined, replacedBy: doc.replacedBy as string[] | undefined,
    ordering: Number(doc.ordering ?? 0), isActive: doc.isActive as boolean | undefined,
  }));
  const resolveLesson = lessonResolver(lessonDocs);
  const questions: QuestionRef[] = [];
  const topicSlugs = new Set<string>();
  for (const doc of bankSets) {
    let set: {meta?: {topic?: string; subtopic?: string; exams?: string[]}; questions?: {id: string; lesson?: string; passage?: unknown; isActive?: boolean; figure?: unknown; figureSpec?: unknown}[]};
    try {
      set = JSON.parse(String(doc.payload));
    } catch {
      continue; // A malformed document must not break every roadmap and mock for the exam.
    }
    const topic = set.meta?.topic;
    if (typeof topic !== 'string' || !set.meta?.exams?.includes(slug)) continue;
    topicSlugs.add(topic);
    for (const question of set.questions ?? []) {
      if (question.isActive === false || question.figure != null && String(question.figure).trim() !== '' && question.figureSpec == null) continue;
      questions.push({id: question.id, setId: doc.id, topicId: topicIdFor(examId, topic),
        lessonId: resolveLesson(question.lesson ?? (typeof set.meta.subtopic === 'string' ? `lesson-${topic}-${set.meta.subtopic}` : null), question.lesson != null),
        passageId: typeof question.passage === 'string' ? question.passage : null});
    }
  }
  const lessons: LessonRef[] = lessonDocs
    .filter(l => topicSlugs.has(l.topic) && (l.status ?? 'active') === 'active' && l.isActive !== false)
    .sort((a, b) => a.ordering - b.ordering || a.id.localeCompare(b.id))
    .map(l => ({id: l.id, topicId: topicIdFor(examId, l.topic), ordering: l.ordering}));
  return {
    topics: [...topicSlugs].sort().map(topic => ({id: topicIdFor(examId, topic), name: titleCase(topic)})),
    questions, lessons,
    ...(lessonDocs.some(l=>l.status==='retired')?{retiredReplacements: Object.fromEntries(lessonDocs.filter(l=>l.status==='retired').map(l=>[l.id,l.replacedBy??[]]))}:{}),
  };
}

/**
 * Raise whenever `buildExamContent` can return something different for the same documents: summaries
 * written by an older builder are then ignored until the next full upload.
 */
export const BUILDER_VERSION = 'exam-content-v1';
/** Exam summaries and the bank marker, written by the content upload (`contentUpload.ts`). */
export const SUMMARY_COLLECTION = 'content/summaries/items';
export const BANK_MARKER_ID = '_bank';
export const summaryPartId = (examId: string, part: number): string => `${examId}~${part}`;

