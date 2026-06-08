# Question generation brief

Generate one YAML file per subtopic at
content/questions/<subject>/<topic>/<subtopic>.yaml following
docs/content/question-style-guide.md and the subject blueprint in
docs/content/question-blueprints/<subject>.md.

Rules:
- Stem: authentic UPCAT/DOST exam wording and difficulty.
- Explanation: simple Grade 4–6 English; say why the answer is right and
  why the main distractor is wrong.
- Cover every archetype in the blueprint × 2–3 variants, ramped easy→exam.
- Exactly one correct choice; 4 choices; plausible mistake-based distractors.
- id: q-<topicSlug>-<subtopicSlug>-NNNN, numbered easy→hard.
- Figure-dependent items: add `figure: <slug>` and list the slug for the
  question-figures worklist.
