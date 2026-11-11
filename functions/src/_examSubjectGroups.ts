import {cseParts} from './generated/cse_parts.js';
import type {StudyContent} from './_examContent.js';

type Content = Pick<StudyContent, 'subjects' | 'topics'>;
type Topic = Content['topics'][number];
type Part = {readonly id: string; readonly name: string; readonly topicNames: readonly string[]};
const partsFor = (examId: string): readonly Part[] =>
  Object.hasOwn(cseParts, examId) ? cseParts[examId as keyof typeof cseParts] : [];

/** Null hides CSE topics outside the exam's parts. Stored ids stay intact. */
export function examSubjectName(examId: string, topic: Topic, subjectName: string): string | null {
  const parts = partsFor(examId);
  return parts.length ? parts.find(p => p.topicNames.includes(topic.name))?.name ?? null : subjectName;
}

export function examSubjectGroups(examId: string, content: Content): {id: string; name: string; topics: Topic[]}[] {
  const parts = partsFor(examId);
  if (!parts.length) return content.subjects.map(s => ({id: s.id, name: s.name,
    topics: content.topics.filter(t => t.subjectId === s.id)}));
  return parts.map(p => ({id: p.id, name: p.name,
    topics: p.topicNames.flatMap(name => content.topics.filter(t => t.name === name))}))
    .filter(group => group.topics.length > 0);
}

export function examPerformanceSubjects(examId: string, content: Content,
  topics: {id: string; correct: number; answered: number}[]) {
  const counts = new Map(topics.map(t => [t.id, t]));
  return examSubjectGroups(examId, content).map(s => {
    const rows = s.topics.flatMap(t => {
      const row = counts.get(t.id);
      return row && row.answered > 0 ? [row] : [];
    });
    return {id: s.id, title: s.name,
      correct: rows.reduce((sum, t) => sum + t.correct, 0),
      answered: rows.reduce((sum, t) => sum + t.answered, 0), topicCount: rows.length};
  }).filter(s => s.answered > 0);
}
