# Re-map brief: PSHS-NCE sample items to current lesson parts

Read-only. You change no file. Your final message is the only output.

On November 17 the 70 official PSHS-NCE sample items (Tests II to IV) were mapped to whole lessons (`docs/content/pshs-nce/map.jsonl`; items in `docs/content/pshs-nce/reviewer-transcript.md`). Since then every lesson was split into short parts ("bite-sized"). Each old lesson file now has `status: retired` and a `replacedBy:` list. The current parts are listed in `docs/content/pshs-nce/remap-parts.tsv`. New PSHS parts also exist in `content/lessons/reasoning/spatial-abstract-reasoning/` (for example `matching-dot-placement.md`, `closed-surfaces-in-solids.md`, `comparing-counts-in-figures.md`); include any part there that teaches an item.

For each of the 70 items:
1. Read the item in the transcript and its map line (type, verdict, why).
2. Open the parts that replaced the lessons its map line names, and any other part that teaches the method. Read their text.
3. List every current part that teaches the method the item needs, most useful first. A part counts only if it teaches the method or fact with a worked example, not a mention.
4. Say whether the old verdict still holds on the parts: covered, partial or missing. Change it only with a reason.

Rules: use part ids exactly as their front matter `_id` gives them. Never list a retired lesson. Do not use the disputed keys II-16 and III-18 as facts.

Output only this JSON as your final message:
{"items": [{"item": "II-1", "parts": ["lesson-..."], "verdict": "covered|partial|missing", "changed": false, "why": "<one sentence>"}]}
