# Check brief: CET math audit fixes

Read-only. Read `docs/content/math-for-generator/astra/rulings.md`, every result file with findings in `results/`, `fixes.jsonl`, and the diff of the fixes: `git show 8adb01209 -- content/lessons/mathematics`.

For each of the 32 findings: is the error gone, and did the fix follow the ruling? Then read each changed lesson in full around the change: did any fix add a new false statement, a wrong step, a wrong part pointer, an answer shown before its solution, or language a Grade 5 student cannot follow?

Output only JSON as your final message:
{"checked": <n>, "failed": [{"file": "<path>", "finding": "<first 40 characters of the quote>", "problem": "<what is still wrong>"}], "newIssues": [{"file": "<path>", "severity": "Blocker|Major", "quote": "<exact text>", "problem": "<what>"}]}
