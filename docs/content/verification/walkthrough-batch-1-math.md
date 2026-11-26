# Batch 1 Verification Record: Mathematics CSE Walk-Through Rewrite

- Date: November 26, 2026
- Branch: `content/lesson-walkthrough-cse-r1` (base `content/cse-key-fixes-r1` `a7cc22b6b`)
- Policy commit read: `origin/main` `6e142ce08` (rule 4 rulings at `a32e4b5ee`)
- Spec: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Pick 1a: 900 pre-tap words; Pick 2A: Show answer)
- Scope: All 54 original CSE Mathematics lessons (55 active lessons after splitting `signed-integers-and-substitution` into `signed-integer-operations` and `substituting-negative-numbers`, retiring `signed-integers-and-substitution`).

## Independent Lesson Recomputation

Every worked number, `:::check`, `:::pair`, `:::try`, example step, and `**Check:**` line across all 55 active Mathematics lessons was recomputed from scratch by independent verifiers that did not author the lessons:
- Chunks 1 and 2 (22 lessons): 144/144 Python recomputation checks passed; 0 Blockers, 0 Majors, 10 Minors (all 10 fixed and re-verified).
- Chunks 3, 4, 5 and 3 Math samples (33 lessons): 271/271 Python recomputation checks passed; 0 Blockers, 5 Majors, 23 real Minors (all fixed and re-verified with 0 findings on the 6 amended math files).
- Checkpoint audit round 1 fixes (14 lessons, 4 Q17 rationales on `0022`/`0023`/`0024`/`0027`, and 2 reverse-direction trap-evidence entries): all 28 round 1 findings + 1 extra systemic trap-evidence finding addressed.
- Checkpoint audit round 2 caught 3 remaining items (`0023` `$-10$` rationale printed `$12 - (-9) - 13 = -10$` as an equality instead of rewriting to `$12 - 9 - 13 = -10$`; `work-rate-problems.md` Examples #1 and #2 omitted the same-rate-alone-and-together assumption in their stems; `infinite-geometric-series.md` omitted the `$a_1 \neq 0$` precondition in its convergence checklist item and placed the `$a_1 = 0$` case under the nonzero lead-in). Round 3 fixed all 3 items, re-approved `0023` via `tool/content/approve.dart`, and passed independent re-verification.
- Trap pairs: 157 inline `:::pair` blocks across 55 lessons, backed by 166 verbatim non-correct quiz choices in `content/walkthrough-trap-evidence.json` (direction-matched to question rationales).

## Moved Questions (Pure `lesson:`/`keyPoint:` Remap, Text Unchanged)

Retagged from retired `lesson-arithmetic-number-sense-signed-integers-and-substitution` with zero edits to stem, choices, rationales, or explanations; re-approved via `tool/content/approve.dart --moved`:
- `q-arithmetic-number-sense-order-of-operations-0003` -> `lesson-arithmetic-number-sense-substituting-negative-numbers` (`keyPoint: 2`)
- `q-arithmetic-number-sense-order-of-operations-0008` -> `lesson-arithmetic-number-sense-substituting-negative-numbers` (`keyPoint: 3`)
- `q-arithmetic-number-sense-order-of-operations-0013` -> `lesson-arithmetic-number-sense-substituting-negative-numbers` (`keyPoint: 3`)
- `q-arithmetic-number-sense-order-of-operations-0021` -> `lesson-arithmetic-number-sense-signed-integer-operations` (`keyPoint: 3`)

## New Pool-Gap Questions (Independent Blind Solve, Keys Hidden)

Authored to meet the per-exam `lesson-pool` requirement (`quizSize = 5`, all 3 key points covered) for the two split parts of `signed-integers-and-substitution`. Independently blind-solved from shuffled stems and choices (keys, explanations, and rationales hidden) by a separate verifier; all 6 agreed with the YAML key and had unambiguous stems and no second defensible answer. Round 2 strengthened 4 distractor rationales (`0022` `$-33$`, `0023` `$-10$`, `0024` `$(-2)(3)(-4) \div 6$`, `0027` `$1$`) with exact arithmetic slips and visual cues without altering stems, choices, keys, or explanations, and Round 3 fixed `0023`'s `$12 - (-9) - 13$` rewrite equality; all affected items were re-verified and re-approved via `tool/content/approve.dart`:

| Question ID | Target Lesson | Key Point | Blind Solve | YAML Key | Verdict |
|---|---|---|---|---|---|
| `q-arithmetic-number-sense-order-of-operations-0022` | `lesson-arithmetic-number-sense-signed-integer-operations` | 1 | `$-9$` | `$-9$` | AGREE |
| `q-arithmetic-number-sense-order-of-operations-0023` | `lesson-arithmetic-number-sense-signed-integer-operations` | 1 | `$8$` | `$8$` | AGREE |
| `q-arithmetic-number-sense-order-of-operations-0024` | `lesson-arithmetic-number-sense-signed-integer-operations` | 2 | `$(-2)(-3)(-4) \div 6$` | `$(-2)(-3)(-4) \div 6$` | AGREE |
| `q-arithmetic-number-sense-order-of-operations-0025` | `lesson-arithmetic-number-sense-signed-integer-operations` | 3 | `$12$` | `$12$` | AGREE |
| `q-arithmetic-number-sense-order-of-operations-0026` | `lesson-arithmetic-number-sense-substituting-negative-numbers` | 1 | `$9$` | `$9$` | AGREE |
| `q-arithmetic-number-sense-order-of-operations-0027` | `lesson-arithmetic-number-sense-substituting-negative-numbers` | 2 | `$-1$` | `$-1$` | AGREE |
