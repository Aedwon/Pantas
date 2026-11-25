# CSE content fixes, release lead r6 (velocity E-160, continues E-145)

Written Nov 25 by the CSE release lead r6 (integrator). Policy: main 173fd0909.
His words: Nov 25, about 7:10 AM Manila: "let's prioritize release with current content first". About 7:45 AM: "let's keep on working then on the ongoing processes then."
In one sentence: ship the correctness fixes to the CSE content that prod already serves, as fixes under the standing ship-it.

Not in scope: the lesson walk-through rewrite (parked at its spec), new content, any UI.

## Sources

- A: Codex b audits, `~/Documents/Projects/Pantas-private/audits/2026-11-24-codex-b/adj-*.md` (CSE files), read against main.
- B: re-check of every CONFIRMED Blocker and Major from A against the content tree prod serves, `Pantas-private/audits/2026-11-24-prod-recheck/recheck.md` (56 findings: 8 Blocker and 13 Major still apply, 35 fixed in prod, 0 not found). Finding numbers below are B's.
- C: lead overrides for findings 30, 31, 34, 49 in `Pantas-private/audits/2026-11-24-prod-recheck/fix-prompt.md` (r2 lead).
- Fix run: Codex Sol, commit 013989708 on `content/cse-key-fixes-r1` (from d97de9415, the prod content root), report `/tmp/pantas-cse-checks.zOWu4H/fix-report.md` (copied to the private folder by r6).

## The list (19 items; B finding number, severity in prod, item)

Questions (10, each needs a re-solve, the content gate and a ledger approval):
1. B2, Blocker: `q-arithmetic-number-sense-prime-factorization-gcf-lcm-0011` (packages must use every item for the keyed answer to hold).
2. B9, Blocker: `q-algebra-word-problems-0004` (10% sugar by mass vs volume).
3. B28, Major: `q-grammar-and-structure-parallelism-0010` (choice D note).
4. B30, Blocker: `q-grammar-and-structure-pronoun-antecedent-agreement-0007` ("her" also valid; override C).
5. B31, Blocker: `q-grammar-and-structure-punctuation-and-capitalization-0014` (two readings; override C).
6. B35, Blocker: `q-language-application-error-identification-0017` (keyed sentence changes meaning).
7. B39, Major: `q-vocabulary-context-clues-0020` (keyed "recovery" does not fit the context).
8. B40, Major: `q-vocabulary-root-words-prefixes-suffixes-0017` ("co-" vs "col-" in collaborate).
9. B41, Blocker: `q-vocabulary-spelling-rules-0017` ("seise" is a valid legal spelling).
10. B43, Major: `q-vocabulary-spelling-rules-0014` (note says "managing" keeps the e).

Mock blueprint (1):
11. B34, Major: `content/mock/cse-pro.yaml`, 155 scored and 15 unscored becomes 150 and 20 (CSC Examination Advisory No. 19, s. 2026); Numerical Ability 45 to 40.

Lessons (8 findings, 10 files):
12. B44, Major: SALN repositories vs where the declarant files (two SALN office lessons).
13. B45, Major: SALN inspection needs a lawful request under the repository's rules.
14. B46, Major: SALN copy release timing and Ombudsman custody (public access, filing dates).
15. B48, Major: parallelism lessons present matching word forms as required.
16. B49, Blocker: joined antecedents example ("Liza and Carlo ... (her / their) project"; override C).
17. B53, Blocker: its / it's example has a second valid choice ("their").
18. B55, Major: projections lesson asks about a report's wording, not the forecast.
19. B56, Major: event order example leaves the delay's timing open.

Already shipped: B15 and B16 (pulley figure painters, app code) in PR #117, prod Nov 24 19:48 UTC.

## Not in this pass (for the manager)

- Source A's CSE Minor (about 68) and Unsure (about 14) findings: never re-checked against the prod tree. A second pass would re-check them first, then fix.
- CET findings (`CET-TRIAGE.md`): CET is not a CSE gate.
- Pulley (1,1) figure branch, questions 0002, 0009, 0013, 0018: app drawing code, UI lane.

## Steps and checks

1. Lead review of the 20-file diff against B and C.
2. Independent re-solve of all 10 questions and a fact check of the lesson edits (a Sonnet worker, not the author's vendor; law facts cited to the primary text).
3. Content gate and approval ledger: each of the 10 questions approved through `tool/content/approve.dart` with evidence; gate exit 0.
4. Export with main's tools; validator 0; lesson checks.
5. Rule 7 count before each hosted run; staging plan, upload, re-plan; prod plan, backup of changed documents, upload, re-plan 0 differences; launch log entry with rollback.
