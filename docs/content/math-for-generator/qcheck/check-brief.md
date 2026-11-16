# Check brief: CET math question check fixes

Read-only. Read `docs/content/math-for-generator/qcheck/rulings.md`, every result file in `docs/content/math-for-generator/qcheck/results/`, `docs/content/math-for-generator/qcheck/fixes.jsonl`, and the diff of the fixes: `git show ac795a3c0 -- content/lessons/mathematics content/questions/mathematics/algebra content/questions/mathematics/geometry/coordinate-geometry.yaml, ignoring the files counting-and-digit-patterns, practical-measurement and clock-time-and-time-differences`.

For each of the 32 findings (one was rejected by ruling 1; confirm only that nothing changed for it): is the error gone, and did the fix follow the ruling? Then read each changed lesson in full around the change: did any fix add a new false statement, a wrong step, a wrong part pointer, an answer shown before its solution, or language a Grade 5 student cannot follow?

Output only JSON as your final message:
{"checked": <n>, "failed": [{"file": "<path>", "finding": "<first 40 characters of the quote>", "problem": "<what is still wrong>"}], "newIssues": [{"file": "<path>", "severity": "Blocker|Major", "quote": "<exact text>", "problem": "<what>"}]}
