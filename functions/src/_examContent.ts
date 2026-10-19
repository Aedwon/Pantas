import type {Firestore} from 'firebase-admin/firestore';

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
