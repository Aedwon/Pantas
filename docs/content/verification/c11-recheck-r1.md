# C11 CSE content re-check (CSE release lead r11, Nov 28, 2026)

Manager brief, Aedwon's words: "ok but be careful not to end up in an endless audit loop lest we waste too much
usage" and "please only fix those things absolutely necessary. we don't need to cover everything, pareto principle."

## Re-check

One Sonnet worker, read only, sorted the Minor and Unsure findings of the Nov 24 Codex b audit (9 CSE adjudication
files) plus question 0040 against the live root dbc5e7244. Sort file (private, holds audit text):
`~/Documents/Projects/Pantas-private/audits/2026-11-24-codex-b/c11-sort.md`.

- GONE 50, MUST FIX 1, SKIP 35 (2 close calls).
- Six Math lesson findings were marked GONE because their lesson files are retired; the lead read the findings: each
  is an edge case (zero terms in a sequence, negative starting values, separate shaded pieces, logically related
  conditional parts) that no CSE question turns on, so they would be SKIP either way. The same-direction speed rule is
  already fixed in the live motion lessons.

## MUST FIX: q-verbal-logic-assumptions-and-conclusions-0040

The key "A rejected sample was listed as accepted." dropped the claim's "at intake" and "in the final log" limits, so it
could hold while the claim stayed true. New key: "A sample rejected at intake was listed as accepted in the final
log." (shorter than choices B and the explanation's own claim; not the longest choice). The explanation now names both
limits. Other choices and rationales unchanged.

Independent read (one Sonnet reviewer, blind solve from the stem and choices before reading the file): answer C, the
keyed choice; no other choice defensible as the precise negation (A swaps the groups, B overstates with "every", D is a
missing entry); explanation correct and plain; rationales name real mistakes; key 66 characters, not the longest; no
em dash. Verdict: AGREE. No second round.

Validator (`import_questions --root content/questions/reasoning`): exit 0.

## Also in this upload

`imaginary-unit-and-powers.md`: the two lines that joined equations with `\qquad` now put one equation per display line,
so screen readers no longer read "qquad" (manager, Nov 28; no read needed).
