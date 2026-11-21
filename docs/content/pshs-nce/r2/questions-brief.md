# Question brief: PSHS-NCE-only questions for existing lesson parts

You write one new question file for Pantas, a Philippine exam review app. The student is a Grade 6 applicant (about 11 to 12 years old) preparing for the Philippine Science High School National Competitive Examination (PSHS-NCE). Write only the file named in your task. Change no other file.

Read first, in full: `docs/content/question-style-guide.md`; SUBAGENTS.md Part 4 "Content rules that no validator enforces" (`git show origin/main:SUBAGENTS.md`); every part named in your task; the existing question file(s) whose questions point at those parts (`grep -rl "lesson: <part id>" content/questions`), for format only; the official items named in your task in `docs/content/pshs-nce/reviewer-transcript.md`, for level and style only.

Rules:
- `meta`: subject, topic and subtopic from the file path (subtopic = the file name without `.yaml`), `exams: [pshs-nce]` only.
- Ids `q-<topic>-<subtopic>-0001` upward, unique. Each question has `lesson: <part id>` and `keyPoint: <n>` matching a key point in that part's front matter.
- Write exactly the count given for each part. Every key point of the part gets at least one question. Spread the rest over the part's key points.
- Test only what the part teaches. Level: a strong Grade 6 applicant, like the official sample items named; realistic PSHS-NCE wording. Never copy or lightly reword an official item. Never use the disputed keys II-16 or III-18 as fact.
- Five choices (A to E as the official sample shows). Exactly one correct. Every wrong choice is a real mistake with its own `rationale`: the mistake, why it looks right, one check. The `explanation` (Grade 5 English) says only why the right answer is right, with steps when solving is involved.
- The correct answer is never the longest choice; check each question. No grammar or wording clue. No "All of the above" or letter references. Quote choices that are bare numbers, booleans, or contain ": ".
- Figures: use only figure kinds and fields the app draws (`lib/core/ui/figures/`), as the existing files for these parts do. If a question would need a figure that cannot be drawn, write a different question. Never describe a figure in words as a substitute. Passages follow the existing file format for that part.
- Never claim anything about the PSHS-NCE beyond "the official sample has items like this". Do not set `approved:`. No em dashes. American spelling. `\dfrac`, single-dollar math; single quotes or block scalars for anything with a backslash.

Then run and fix until it passes:
`dart run tools/import_questions/import_questions.dart --root <the file's directory> >/dev/null 2>&1; echo "exit: $?"`

Final message: the path, the count per part, and the validator exit code you read.

Quantitative items (ids like `2024-1`) are in `docs/content/math-for-generator/pshs-nce-reviewer-transcript.md`, with what the source does and does not state in `docs/content/math-for-generator/pshs-nce-source.md`. Item 2024-11's key is unverified: do not use it. Every number in a math question comes from arithmetic you can show; check each key by solving it twice.
