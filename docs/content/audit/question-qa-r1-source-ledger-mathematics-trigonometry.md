# Question QA R1 source ledger — Mathematics / Trigonometry

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Reviewed:** 25 August 2026

This ledger records substantive corrections from the Trigonometry question pass. All 112 original authored items across seven banks were independently recomputed or re-derived and compared with their matching repository lessons. The findings are deterministic trigonometry, geometry, algebra, and repository-schema issues, so no external factual source was required.

## Major corrected questions

| Question | Finding | Disposition |
|---|---|---|
| `q-trigonometry-basic-trigonometric-ratios-0005` | A distractor, `12/20`, was mathematically identical to the keyed `3/5`, leaving two correct choices. | Replaced it with the distinct reciprocal error `20/12`; key remains `3/5`. |
| `q-trigonometry-unit-circle-0011` | The 45-degree distractor used `(sin 45°, cos 45°)`. Because sine and cosine are equal at 45 degrees, the displayed ordered pair was numerically identical to the correct unit-circle point. | Replaced it with a 30-degree coordinate-order distractor where the reversal changes the actual ordered pair. |
| `q-trigonometry-unit-circle-0014` | Both the keyed 300-degree statement and the 200-degree statement gave correct reference angles. | Replaced the second statement with an incorrect Quadrant III calculation; one answer is now uniquely true. |
| `q-trigonometry-laws-of-sines-and-cosines-0007` | Original SSA givens produced `sin B > 1`, so no triangle satisfied the stated data. | Replaced the side lengths with a valid SSA setup and recomputed `sin B = 15 sin 50° / 20`. |
| `q-trigonometry-laws-of-sines-and-cosines-0008` | A sign-error distractor did not match the arithmetic described by its rationale. | Repaired the distractor to `2√19`, the value produced when `cos 120°` is incorrectly treated as `+1/2`. |
| `q-trigonometry-laws-of-sines-and-cosines-0011` | The explanation contained an accidental drafting artifact saying the author would simply accept the supplied answer. | Removed the artifact and fully recomputed the Law of Cosines result; `cos C = -11/80` is correct. |
| `q-trigonometry-laws-of-sines-and-cosines-0012` | The first two choices were algebraically identical correct forms of the same Law-of-Cosines result. | Replaced the duplicate with a sine-for-cosine distractor. |
| `q-trigonometry-solving-right-triangles-0011` | The plane-motion wording did not explicitly establish that the second horizontal distance should be subtracted from the first. | Clarified that the plane moves horizontally toward the observer; the existing difference expression is then justified. |
| `q-trigonometry-solving-right-triangles-0013` | The keyed answer claimed the hillside data conflicted with the geometry, while its own explanation correctly said the slope/horizontal separation was missing. | Changed the key to the statement that hill slope or equivalent horizontal/vertical data are required. |
| `q-trigonometry-solving-right-triangles-0016` | The keyed height formula had the cotangent difference reversed, producing a negative value for a positive height. | Corrected the formula to `200 / (cot 20° - cot 35°)` and re-derived it from the two observation equations. |
| `q-trigonometry-trigonometric-identities-0001` | The explanation incorrectly called `1/tan θ` cosecant. | Corrected it to cotangent. |
| `q-trigonometry-trigonometric-identities-0010` | A distractor rationale said `sec² θ` and `tan² θ` can be equal when `tan θ = 0`. | Corrected the rationale: `sec² θ = tan² θ + 1`, so they are never equal where defined. |
| `q-trigonometry-trigonometric-identities-0013` | Explanation claimed `tan² θ + cot² θ > 2`. Equality is possible when `|tan θ| = 1`. | Corrected the bound to `>= 2` with its equality condition. |

## Repository-contract and wording corrections

The repository question style guide permits only `easy`, `medium`, `hard`, and `exam` as authored difficulty values. Twelve Trigonometry items used the unsupported value `medium-hard`; all twelve were normalized to `hard` while preserving the intended easy-to-hard ordering.

A repeated generation artifact also produced stems such as `angle A = 30 degrees in degrees` or asked for dimensionless sine/tangent ratios `in degrees`. These were removed throughout the affected Laws of Sines/Cosines, Solving Right Triangles, and Basic Trigonometric Ratios items. These are recorded as low-severity per-item corrections in the status ledgers.

## Lesson conformity

All seven matching lessons teach the concepts required by their active questions:

1. **Angles and Radian Measure:** degree/radian conversion, coterminal angles, quadrants, and `s = rθ` in radians.
2. **Basic Trigonometric Ratios:** SOH-CAH-TOA, reciprocal ratios, special triangles, and complementary-angle relationships.
3. **Inverse Trigonometric Functions:** input domains, principal ranges, and triangle-based compositions.
4. **Unit Circle:** exact standard-angle values, reference angles, quadrant signs, and `(cos θ, sin θ)` coordinate order.
5. **Laws of Sines and Cosines:** matched side-angle pairs, SAS/SSS Law of Cosines, and the SSA ambiguous/impossible case.
6. **Solving Right Triangles:** angles of elevation/depression and one- and two-observation-point tangent models.
7. **Trigonometric Identities:** reciprocal, quotient, and Pythagorean identities with sign/domain awareness.

No lesson-source conflict or material lesson coverage gap was found in this topic.

## Visual classification

No active question requires an external figure to determine a unique answer. Triangle and unit-circle diagrams would be beneficial for many geometry-heavy items, but every stem supplies enough numerical and relational information to solve the item textually.
