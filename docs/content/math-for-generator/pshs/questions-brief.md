# Question brief: new PSHS-NCE math lesson

Write exactly 20 questions for the lesson named in your task, at the question file path given. Write nothing else.

Read first: `docs/content/question-style-guide.md`, `docs/content/question-authoring-runbook.md`, SUBAGENTS.md Part 4 "Content rules that no validator enforces" (from `git show origin/main:SUBAGENTS.md`), the lesson in full, and an existing file for format, `content/questions/mathematics/arithmetic-number-sense/divisibility-rules.yaml`.

- meta: subject mathematics, the lesson's topic, subtopic = the lesson's file name, `exams: [pshs-nce]`.
- Ids `q-<topic>-<subtopic>-0001` to `-0020`. Each question has `lesson: <lesson id>` and `keyPoint: <n>` matching the lesson's keyPoints if it has them.
- Five choices per question, as in the official PSHS sample (A to E).
- Spread the questions over every method the lesson teaches. Difficulty ramps from easy to the level of the official sample items named in the task. Do not copy an official item.
- Every wrong choice is a real mistake, with its own rationale: the mistake, why it looks right, one check. The explanation (Grade 5 English) says only why the right answer is right, with the worked solution.
- Never make the correct answer the longest choice. Do not set `approved:`. LaTeX in single quotes or block scalars. No em dashes. American spelling. `\dfrac`.
- A question that needs a figure: add `figure: <slug>` and describe it; do not draw.

Then run, and fix until it passes:
`dart run tools/import_questions/import_questions.dart --root <the file's directory> >/dev/null 2>&1; echo "exit: $?"`

Final message: the path, the count, and the validator exit code you read.
