# Reader brief: seven new PSHS-NCE-only lesson parts (D21)

Read-only. You change no file. A different model wrote these parts; find what it got wrong. Read `docs/content/pshs-nce/r2/d21/writer-brief.md` (what the writer was told), `docs/content/lesson-style-guide.md`, `docs/content/rewrite/cet/reader-rules.md`, then each part listed in `docs/content/pshs-nce/r2/d21/parts.txt`, in full.

Check: every fact and every general statement at its boundary values; solve every worked example yourself and compare each step; every key point taught with a worked example a Grade 6 student can follow; any claim about the PSHS-NCE beyond "the official sample has items like this"; any use of the disputed II-16 key; any step or marker that shows an answer early; language a Grade 5 student cannot follow; `\frac` outside a nested fraction; em dashes; British spelling; any edit to an existing file (`git status`).

Severity: Blocker (false fact, wrong worked answer, false general statement, exam claim, existing file changed), Major (key point not taught or not worked, answer shown early, a needed term never taught), Minor (the rest). Quote exactly, at least 8 characters.

Output only this JSON as your final message:
{"round": <n>, "findings": [{"lesson": "<id>", "severity": "Blocker|Major|Minor", "quote": "<exact text>", "problem": "<what and why>", "fix": "<suggested fix>"}]}
