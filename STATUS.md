# CSE rewrite status

Plan: `docs/superpowers/plans/pwa-launch/E4-E7-cse-content-rewrite.md` on main (approved October
25, balanced). Base: `content/question-qa-r2` at 765c5dc0.

## P0 preparation

| Task | State | Evidence |
|---|---|---|
| P0.1 brief builder | done | d978d5a9; 78 briefs + `new-lessons.md`; 11 tests pass |
| P0.2 mechanical fixer | done, applied | bd03b0b1; 62 tests pass; 15 dash and 52 number fixes in 22 lessons, idempotent; 36 items left for writers (`needs-review`); 27 traps without a one-line warning and 43 table rows left for writers |
| P0.3 question typing check | done | d978d5a9; 24 tests pass; 8 real problems in `science/physics/light-and-optics.yaml` (not CSE) |
| P0.4 prompt page and relay hand-in | phase 1 done (rewrite, read) | `tools/content_rewrite/relay/`; 118 tests pass; 28 rewrite batches planned; GitHub check passes (736d8b47); read form rule text synced to checklist 14a218d8; tools live on this branch, not the audit branch |
| P0.5 terms check | done | main `docs/superpowers/decisions/2026-10-25-cse-rewrite-p0-notes.md` |
| P0.6 new lessons and splits | applied, not committed | Plans in `docs/content/rewrite/plans/`. Oct 25 decisions applied: 5 splits (Bill of Rights x4, environment x4 plus laws, duties x2, tenses x2), 8 new part lessons plus 4 new lessons as stubs (12 files each for lesson and questions), 41 questions moved with ids unchanged (3,215 ids before and after), 12 `outline.json` entries, `split-map.json` (99 rows) applied by the brief builder (86 briefs; row totals unchanged), 18 builder tests pass. New files hold teaching only where it was moved; the rest is `<!-- REWRITE -->`. Each new file is short of 20 questions. Open: first-part titles kept (question C), tenses Filipino part inherits all 9 exam tags (question F) |
| P0.7 illustration worklist | done | 7 markers in the corpus, 3 in CSE lessons; README count stale |
| P0.8 SVG in the app | waiting | style D approved Oct 25 (`docs/content/rewrite/figure-style/`); app code waits for engineering coordination |
| P0.9 source ledger | done | `docs/content/audit/cse-rewrite-ledger.md` (header only) |

Notes: B08 brief rows on lines the fixer changed may already be fixed; the writer checks the
line and the reader confirms. Two stray chat citation markers removed from the visual media
lesson (bd03b0b1).

## October 25: splits applied (fdcbdba3)

12 lessons added: 8 split parts and 4 new stubs; 41 questions moved with ids unchanged (3,215 ids
before and after); importer exit 0. The push check on fdcbdba3 failed as expected: the length
guard (written to catch a truncated chat rewrite) flagged the two lessons that shrank by design
(bill of rights, duties and prohibited acts). Later pushes compare with the split versions. The
`REWRITE` placeholder comments raise the AI-TELL sweep count by 1 per lesson until rewritten.
New question shortfall to 20: 14 lessons, about 240 questions in all.
