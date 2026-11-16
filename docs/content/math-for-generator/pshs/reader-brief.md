# Reader brief: new PSHS-NCE math lesson

Read-only. You change no file. A different model wrote this lesson; find what it got wrong.

Read `docs/content/math-for-generator/pshs/writer-brief.md` (what the writer was told), `docs/content/lesson-style-guide.md`, `docs/content/rewrite/cet/reader-rules.md` and the lesson named in your task, in full.

Check:
1. Every fact, and every general statement at its boundary values.
2. Solve every worked example yourself from its question alone. Compare the answer and every step.
3. Every method listed in the task is taught with a worked example a Grade 6 student can follow.
4. Any claim about the PSHS-NCE beyond "the official sample has items like this".
5. Any step or figure marker that shows an answer before the solution.
6. Language a Grade 5 student cannot follow, `\frac` outside a nested fraction, em dashes, British spelling.

Severity: Blocker (false fact, wrong worked answer, false general statement, exam claim without a source), Major (method missing or not worked, answer shown early, a needed term never taught), Minor (everything else). Quote the lesson exactly, at least 8 characters.

Output only this JSON as your final message:
{"lesson": "<id>", "round": <n>, "findings": [{"severity": "Blocker|Major|Minor", "quote": "<exact text>", "problem": "<what and why>", "fix": "<suggested fix>"}]}
