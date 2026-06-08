export function validateQuestion(q) {
  const errors = [];
  if (!q.stem || !q.stem.trim()) errors.push('stem is empty');
  if (!q.explanation || !q.explanation.trim()) errors.push('explanation is empty');
  const choices = Array.isArray(q.choices) ? q.choices : [];
  if (choices.length < 2) errors.push('needs at least 2 choices');
  if (choices.some((c) => !c.text || !c.text.trim())) errors.push('a choice has empty text');
  const correct = choices.filter((c) => c.correct === true).length;
  if (correct !== 1) errors.push(`exactly one correct answer required (found ${correct})`);
  return errors;
}

const norm = (s) => (s || '').toLowerCase().replace(/\s+/g, ' ').replace(/\s*\?\s*/g, '?').trim();

export function findDuplicateStems(questions) {
  const pairs = [];
  for (let i = 0; i < questions.length; i++) {
    for (let j = i + 1; j < questions.length; j++) {
      if (norm(questions[i].stem) === norm(questions[j].stem)) {
        pairs.push([questions[i].id, questions[j].id]);
      }
    }
  }
  return pairs;
}
