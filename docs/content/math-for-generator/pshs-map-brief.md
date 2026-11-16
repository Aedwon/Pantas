# Brief: map the official PSHS-NCE math sample items to existing lessons

Read-only. Repository: current directory, branch content/math-for-generator-r1.

Read `docs/content/math-for-generator/pshs-nce-source.md` and `pshs-nce-reviewer-transcript.md` (items 1 to 20 of the 2024 reviewer) plus the two 2015 items named at the end of the source file (smallest difference of two numbers made from given digits; time-zone difference).

For each of the 22 items:
1. Solve it yourself and confirm the official key. Note any disagreement.
2. Search the ACTIVE lessons under content/lessons/mathematics (skip any file whose front matter has `status: retired`). Find the lesson or lessons that teach the method a Grade 6 student needs to solve it. Read the relevant section, do not judge from titles.
3. Verdict: `covered` (a lesson teaches the method with a worked example a Grade 6 student could follow), `partial` (the topic is there but the method or level is missing, or it is taught only at a level far above Grade 6), or `missing`.

Write one JSON line per item to `docs/content/math-for-generator/pshs-map.jsonl` as you finish each item (append; do not wait for the end):
{"item": "2024-1", "type": "<short>", "keyAgrees": true, "lessons": ["<lesson id>"], "verdict": "covered|partial|missing", "why": "<one sentence>"}

Then, as your final message, a short markdown summary: counts per verdict, and the missing and partial methods grouped into the fewest sensible new lessons (title, methods, which items), noting where an existing lesson could carry it instead.
