# CET bite-sized split: independent re-solve evidence

Date: November 19, 2026. Lead: CET finish lead. Plan: `docs/superpowers/plans/2026-11-19-cet-bite-sized-finish.md` on main.

Every question below sits in a CET topic that was split into parts (plus the PSHS-NCE and CET Algebra questions that share those topics). Each was solved blind by a separate Codex GPT 6.2 Sol run, which saw only the stem, the choices and the passage, never the key. The run's answer and confidence were compared with the key by `tools/content_rewrite/question_check/merge_solves.py`: every compared question matched with no low-confidence answer (2,570 solved, 0 mismatches). Questions whose text equals the earlier CSE blind-solve commit were skipped by the tool and rely on that earlier solve.

The new pool-gap questions were written by GPT 6.2 Sol and solved by a separate run in the same pass. Their authors did not solve them.

The Algebra word-problems file changed only in its exam tags (ustet removed); it stays covered by its earlier Algebra solve (`docs/content/verification/algebra.md`) and by ruling R2.

Not yet done: the independent sample audit by a separate Sol run, listed in the plan. Approval here means a key matched a blind solve, not that an audit passed.

| Topic | Questions approved |
|---|---|
| mathematics/algebra | 173 |
| mathematics/arithmetic-number-sense | 41 |
| mathematics/geometry | 208 |
| mathematics/precalculus-basic-calculus | 84 |
| mathematics/statistics-and-probability | 114 |
| mathematics/trigonometry | 174 |
| reading-comprehension/text-types | 61 |
| reasoning/mechanical-technical-reasoning | 118 |
| reasoning/spatial-abstract-reasoning | 27 |
| science/biology | 300 |
| science/chemistry | 434 |
| science/earth-science-astronomy | 291 |
| science/physics | 408 |
| Total | 2433 |

## Audit fixes (November 20, 2026)

After the independent Sol audit, fixes changed 76 questions. All 1,097 questions in the fixed files were solved blind again by a separate GPT 6.2 Sol run (1,097 matches, 0 mismatches, 0 low confidence). The 76 changed questions are re-approved on that solve.
