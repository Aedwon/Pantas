# Brief: fix R3 Codex read 2 Majors once (E-216, step 7; no further read)

Follow `reasoning-r3-r1-fix-brief.md` in this folder (startup, hard rules, words, checks, report), with these changes:

- Findings: `docs/content/verification/walkthrough-work/codex-reasoning-r3-read2.md` (PASS, 0 Blockers, 20 Majors). Fix
  every Major once. There is no further read, so every value you change must be re-sorted by you and must stay right.
- Most Majors say a Core Concept demo or prose line uses the values or answer of a linked quiz question. Replace those
  demo values with fresh ones of the same kind (new names, codes, numbers or dates) that need the same move, and give the
  demo's new order. Do not change any `:::pair` Wrong line or its cited wrong choice; a pair may keep the quiz's values,
  because its citation needs them. Check the linked questions (`content/questions/reasoning/clerical-ability/`) so no new
  demo value set equals a question's choices.
- A changed demo must still match the text, checklist lines and pair notes that refer to it; update those references.
- The other Majors: split two-move steps; name the deciding digit or place in the Quick Check and try answers
  (`whole-number-and-decimal-filing.md:72` and `:111`); add the first-subcode tie condition to the checklist line at
  `integer-subcode-filing.md:106`.
- Do not touch `content/walkthrough-trap-evidence.json` this time, or any file outside the nine lessons.
