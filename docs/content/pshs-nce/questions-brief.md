# Question brief: new PSHS-NCE abstract reasoning lesson

Write exactly 20 questions for the lesson named in your task, at the question file path given. Write nothing else.

Read first: `docs/content/question-style-guide.md`, `docs/content/question-authoring-runbook.md`, SUBAGENTS.md Part 4 "Content rules that no validator enforces" (from `git show origin/main:SUBAGENTS.md`), the lesson in full, and the existing files in `content/questions/reasoning/spatial-abstract-reasoning/` for format and figure data.

Figures, the hard rule: the app draws only five question figure kinds: `shape-row`, `figure-matrix`, `figure-series`, `paper-fold`, `cube-net`. Read `lib/core/ui/figures/question_figure.dart`, `figure_registry.dart` and the widget for each kind you use, and use only the fields that widget actually draws. Answer choices are text, never figures. A question whose figure cannot be drawn with those kinds and fields is not written; write a question on another method instead. A question may have no figure only if it needs no picture (for example a word relationship between a flat shape and a solid). Never describe a figure only in the stem text as a substitute for a figure.

- meta: subject reasoning, topic spatial-abstract-reasoning, subtopic = the lesson's file name, `exams: [pshs-nce]`.
- Ids `q-spatial-abstract-reasoning-<subtopic>-0001` to `-0020`. Each question has `lesson: <lesson id>` and `keyPoint: <n>` if the lesson has keyPoints.
- Five choices per question, as in the official PSHS sample (A to E).
- Spread the questions over every method the lesson teaches that can be drawn. Difficulty ramps from easy to the level of the official sample items named in the task. Do not copy an official item.
- Every wrong choice is a real mistake, with its own rationale: the mistake, why it looks right, one check. The explanation (Grade 5 English) says only why the right answer is right.
- Never make the correct answer the longest choice. Do not set `approved:`. No em dashes. American spelling.

Then run, and fix until it passes:
`dart run tools/import_questions/import_questions.dart --root <the file's directory> >/dev/null 2>&1; echo "exit: $?"`

Final message: the path, the count, the validator exit code you read, and which methods got no question because their figure cannot be drawn.
