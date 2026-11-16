# Writer brief: new PSHS-NCE math lesson

You write one new math lesson for Pantas, a Philippine exam review app. The student is about 11 to 12 years old and is preparing for the Philippine Science High School National Competitive Examination (PSHS-NCE). Write in the repository, at the exact path given. Write nothing else.

Read first, in full:
- `docs/content/lesson-style-guide.md` and `docs/content/lesson-authoring-runbook.md` (structure, sections, voice: plain English a Grade 5 student can understand).
- `docs/content/rewrite/cet/writer-rules.md` (rules the last writing run followed; the CET-specific parts do not apply).
- `docs/content/math-for-generator/pshs-nce-source.md` and the items named in your task, in `pshs-nce-reviewer-transcript.md` and `pshs-map.jsonl`.
- The example lesson named in your task, for the front matter and section format.
- AGENTS.md, "Voice" and "Maths in content": `\dfrac`, never `\frac` except inside another fraction; math between single dollars; no em dashes; American spelling.

Rules for this lesson:
- Teach every method listed in your task, each with at least one fully worked example a Grade 6 student can follow step by step. Build examples like the official items, with new numbers and new situations. Never copy an official item.
- About the exam, you may say only that the official PSHS sample has items like this. Do not say what the exam covers, how many items it has, or what is "always" or "often" on it.
- Every number is from the problem or from arithmetic you show. Every general statement ("always", "never", "every", "only") must be true at its boundary values; state the condition when there is one.
- No worked step or figure marker may show an answer before the solution does.
- Figures: if one is needed, add an ILLUSTRATION marker in the format the style guide uses. Do not draw anything.
- Length: as long as the methods need, about 1,200 to 2,000 words.

When done, run `python3 tools/audit/run_all.py` and report only the lines that name your file. Fix structure errors it names in your file, except illustration-inventory messages ("unexpected illustration marker", "expected N code FIGURE markers"), which are expected for a new lesson.

Final message: the path, the word count, and one line per method naming the example that teaches it.
