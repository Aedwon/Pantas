# Brief: map the official PSHS-NCE verbal, science and abstract sample items to existing lessons

Read-only except for the output file. Repository: current directory.

Read `docs/content/pshs-nce/reviewer-transcript.md` (items II-1 to II-30, III-1 to III-20, IV-1 to IV-20).

Search the active lessons under `content/lessons/language-proficiency`, `content/lessons/reading-comprehension`, `content/lessons/reasoning` and `content/lessons/science` (skip any file whose front matter has `status: retired`). For abstract items, read all five lessons in `content/lessons/reasoning/spatial-abstract-reasoning`.

For each item:
1. Find the lesson or lessons that teach the method or knowledge a Grade 6 student needs to answer it. Read the relevant section; do not judge from titles.
2. Verdict: `covered` (a lesson teaches the method or fact with a worked example a Grade 6 student could follow), `partial` (the topic is there but the method, fact or level is missing, or it is taught only far above Grade 6), or `missing`.

Append one JSON line per item to `docs/content/pshs-nce/map.jsonl` as you finish it:
{"item": "III-4", "type": "<short>", "lessons": ["<lesson id>"], "verdict": "covered|partial|missing", "why": "<one sentence naming the lesson section, or what is absent>"}

Final message, also written to `docs/content/pshs-nce/map-summary.md`: counts per verdict per test, then the missing and partial methods grouped into the fewest sensible new lessons (title, methods, items), noting where an existing lesson could carry it with a short added section instead. A science fact recall item that any Grade 6 science lesson on the topic would teach counts against that topic's lesson, not as a new lesson.
