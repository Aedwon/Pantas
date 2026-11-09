/** The exam id a question set's `meta.exams` tag stands for: tag `cse-pro` is exam `exam_cse_pro`. */
export const examIdOfTag = (tag: string): string => `exam_${tag.replaceAll('-', '_')}`;

/**
 * Whether the account's Pro reaches a question set: any one of the set's exam tags is covered. The single rule
 * for Pro question content, shared by content delivery and session diagnosis notes. A set with no usable
 * tags is never covered.
 */
export function setCoveredByTags(exams: unknown, coversExam: (examId: string) => boolean): boolean {
  return Array.isArray(exams) && exams.some(tag => typeof tag === 'string' && coversExam(examIdOfTag(tag)));
}
