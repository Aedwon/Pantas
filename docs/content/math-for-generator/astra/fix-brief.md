# Fix brief: CET math audit findings

Read `docs/content/math-for-generator/astra/rulings.md` and every file in `docs/content/math-for-generator/astra/results/` that has findings. Apply the ruling to each finding, in the lesson file the finding names. Change only what the ruling says. Keep the lesson voice (plain English a Grade 5 student can follow, short sentences, `\dfrac`, no em dashes, American spelling). Do not touch any other file.

Write `docs/content/math-for-generator/astra/fixes.jsonl`, one line per finding, appended as you go: {"family": "<result file id>", "file": "<lesson path>", "quote": "<first 40 characters of the finding quote>", "action": "<what you changed, one sentence>"}.

Then run `python3 tools/audit/run_all.py` and report any line naming a file you changed, other than illustration-inventory messages. Final message: the count of findings fixed and any you could not fix, with the reason.
