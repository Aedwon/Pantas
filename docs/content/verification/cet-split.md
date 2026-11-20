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

After the independent Sol audit, fixes changed 77 questions. All 1,097 questions in the fixed files were solved blind again by a separate GPT 6.2 Sol run (1,097 matches, 0 mismatches, 0 low confidence). The 77 changed questions are re-approved on that solve.

## Re-check fix (November 20, 2026)

The independent re-check changed one question's wording (q-chemistry-stoichiometry-0004, "molar mass" for a g/mol value). The file was solved blind again by a separate GPT 6.2 Sol run (24 of 24 matched, 0 low confidence). The question is re-approved on that solve.

## ACET verbal logic pool (November 20, 2026)

GPT 6.2 Sol wrote 26 new questions (ids 0029 to 0054 in `reasoning/verbal-logic/assumptions-and-conclusions.yaml`) so the pool reaches 54 for the 45 ACET slots. A separate GPT 6.2 Sol run solved the file blind: 34 of 34 solved questions matched, including all 26 new ones, 0 mismatches, 0 low confidence. The 26 are approved on that solve.

## Normal-curve lesson, pool gaps, mocks (November 20, 2026)

GPT 6.2 Sol wrote 10 questions for the new normal-curve lesson (DCAT only) and 7 gap questions in six older lessons whose pools fell short after the audit fixes. A separate GPT 6.2 Sol run solved the files blind: 10 of 10 for the normal-curve file and 118 of 118 for the five gap files, 0 mismatches, 0 low confidence. The 17 new questions are approved on those solves.

## November 20 CET completeness sweep

A separate solver saw only the shuffled stems, choices, and passages. The question-check pipeline matched all 15 answers. There were zero mismatches and no low-confidence answers. These questions previously passed the gate on the frozen ledger with their YAML approval flag set to false.

- `q-text-types-essays-editorials-articles-0016`: B. The byline identifies Rosa as an individual author, and she argues for a policy change.
- `q-text-types-essays-editorials-articles-0017`: C. The byline and personal-capacity label identify the views as Rosa's.
- `q-text-types-essays-editorials-articles-0018`: D. The blocked view is the reason the writer gives for moving pickup away from the crossing.
- `q-text-types-essays-editorials-articles-0019`: A. She addresses residents' concern and proposes observing a trial before deciding.
- `q-text-types-essays-editorials-articles-0020`: B. Attribution makes Rosa the source of the proposal, and reporting responses covers how others reacted.
- `q-text-types-visual-media-0011`: A. February is at 70 thousand pesos, below only April's 90 thousand.
- `q-text-types-visual-media-0012`: A. The truncated baseline makes the change look large relative to the displayed bar lengths.
- `q-text-types-visual-media-0013`: C. Sales fall from 70 to 60 in March and climb to 90 in April.
- `q-text-types-visual-media-0014`: B. The labeled axis makes changes across the plotted months easier to see.
- `q-text-types-visual-media-0015`: D. The same values appear against two different baselines, changing how large the gap looks.
- `q-text-types-visual-media-0016`: B. Gio needs the timetable after his posting helped start the crowding that hid it.
- `q-text-types-visual-media-0017`: C. The earlier panels show the actions that caused the problem Gio faces in the last panel.
- `q-text-types-visual-media-0018`: C. The larger headline attracts attention that the smaller timetable text is less likely to get.
- `q-text-types-visual-media-0019`: D. Gio makes an exception and others add posters until the timetable is hidden.
- `q-text-types-visual-media-0020`: D. Pointing to the pile shows what happened to the timetable and answers Gio without words.

### PSHS-NCE spatial reasoning pools

A separate solver answered the 12 new questions from shuffled blind packets. All 12 matched at high confidence. Each of the six parts tests key point 1 with two questions. The items use self-contained spatial inference and require no image.

- `q-spatial-abstract-reasoning-dots-on-shape-boundaries-0001`: C. The first center lies inside the triangle. The second center lies on the side.
- `q-spatial-abstract-reasoning-dots-on-shape-boundaries-0002`: B. The 5 cm distance exceeds the inner radius and equals the outer radius.
- `q-spatial-abstract-reasoning-labeling-overlap-regions-0001`: D. The midpoint is 3 cm from each center, which puts it inside each 5 cm radius.
- `q-spatial-abstract-reasoning-labeling-overlap-regions-0002`: A. Position 6 lies within the span of R only, and the height of 1 lies between 0 and 3.
- `q-spatial-abstract-reasoning-labeling-three-shape-regions-0001`: C. The distance of 4 cm is greater than the radius of A and less than the radii of B and C.
- `q-spatial-abstract-reasoning-labeling-three-shape-regions-0002`: C. Position 3 lies within A and B and to the left of C. The height of 2 fits both A and B.
- `q-spatial-abstract-reasoning-matching-dot-placement-0001`: C. The circle center lies inside the circle. The whole circle lies inside the square.
- `q-spatial-abstract-reasoning-matching-dot-placement-0002`: B. Every square side is 5 cm from the center. The circle extends only 4 cm from that center.
- `q-spatial-abstract-reasoning-matching-dots-outside-a-shape-0001`: C. The gap between the outlines lies outside A and inside B.
- `q-spatial-abstract-reasoning-matching-dots-outside-a-shape-0002`: C. The distance must exceed 6 cm and be below 8 cm. The choice 7 cm fits.
- `q-spatial-abstract-reasoning-matching-two-dots-0001`: C. The part of A beyond B fits P. The overlap fits Q. The frame encloses both regions.
- `q-spatial-abstract-reasoning-matching-two-dots-0002`: D. Two crossing circles each have a region outside the other circle, so both placements fit.
