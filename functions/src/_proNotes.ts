/**
 * Puts a Pro account's wrong-choice notes into a question set. `notes` is `{questionId: [note | null per choice]}`,
 * the payload stored in `contentPro/{id}`. Shared by `getContent` and the content gate's packaging
 * (`tools/upload_content`), so both build the Pro copy the same way. Imports nothing.
 */
export function mergeProNotes(
  questions: {id: string; choices?: Record<string, unknown>[]}[],
  notes: Record<string, (string | null)[]>,
): void {
  for (const question of questions) {
    const forQuestion = notes[question.id];
    if (!forQuestion || !question.choices) continue;
    question.choices.forEach((choice, index) => {
      const note = forQuestion[index];
      if (typeof note === 'string') choice.rationale = note;
    });
  }
}
