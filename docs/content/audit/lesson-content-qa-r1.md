# Lesson Content QA R1

**Status:** In progress  
**Base SHA:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**QA branch:** `web/content-qa-lessons-r1`  
**Corpus:** `content/lessons/**.md`  
**Access date for web sources in this pass:** 2026-08-25

This ledger records the independent source-referenced QA pass requested for the complete student-facing lesson corpus. It is not an illustration review and does not authorize question-bank, application-code, Sanity, or illustration changes.

## Method

Each lesson receives an explicit status for factual verification, wording/tone, pedagogy, sourcing, whether an edit was made, and unresolved concerns. Material corrections are documented separately with durable source information. `VERIFIED` means the lesson's factual content and worked examples were checked during this pass; it does not mean the source is reproduced in the lesson itself.

Disposition values used below: `VERIFIED`, `CORRECTED`, `CLARIFIED`, `NEEDS PRODUCT DECISION`, `SOURCE INSUFFICIENT`.

## Source bibliography used so far

| Code | Organization | Source/document | Publication/revision | URL | What it establishes |
|---|---|---|---|---|---|
| PH-RA6713 | Lawphil / Republic of the Philippines | Republic Act No. 6713, Code of Conduct and Ethical Standards for Public Officials and Employees | Approved 1989-02-20 | https://lawphil.net/statutes/repacts/ra1989/ra_6713_1989.html | Sections 4, 5, 7, 8, 9, and 11: conduct, public-request duties, prohibited acts, SALN rules, divestment, penalties. |
| PH-CONST | Lawphil / Republic of the Philippines | 1987 Philippine Constitution | 1987 | https://lawphil.net/consti/cons1987.html | Article structure, Bill of Rights, Constitutional Commissions, accountability/impeachment, CHR constitutional basis. |
| PH-CSC-2026 | Civil Service Commission | Examination Announcement No. 03, s. 2026 — 09 August 2026 CSE-PPT | Published 2026-04-20 | https://csc.gov.ph/examination-advisories/examination-announcement-no-03-s-2026-conduct-of-career-service-examination-pen-and-paper-test-cse-ppt-for-professional-and-subprofessional-levels-09-august-2026 | Current public CSE-PPT announcement and official scope framing; supports broad coverage only, not invented lesson-level frequency claims. |
| ICRC-IHL | International Committee of the Red Cross | International Humanitarian Law: A Comprehensive Introduction | 2019 edition | https://library.icrc.org/library/docs/DOC/icrc-4231-002-2019.pdf | IHL applies in armed conflict and binds all parties; human-rights law remains applicable and primarily binds states. |
| OX-PREALG-LCM | OpenStax | Prealgebra 2e, 2.5 Prime Factorization and the Least Common Multiple | 2e | https://openstax.org/books/prealgebra-2e/pages/2-5-prime-factorization-and-the-least-common-multiple | Prime factorization, GCF/LCM methods and prime-power reasoning. |
| OX-CA-COMPLEX | OpenStax | College Algebra 2e, 2.4 Complex Numbers | 2e | https://openstax.org/books/college-algebra-2e/pages/2-4-complex-numbers | Standard form `a+bi`; `a` is real part and `b` is imaginary part; complex arithmetic. |
| OX-CA-LOG | OpenStax | College Algebra 2e, exponential/logarithmic functions and equations | 2e | https://openstax.org/books/college-algebra-2e/pages/6-introduction-to-exponential-and-logarithmic-functions | Logarithm base and argument restrictions and exponent/logarithm relationships. |
| OX-CA-RATIONAL | OpenStax | Algebra and Trigonometry, 5.6 Rational Functions | Edition page | https://openstax.org/books/algebra-and-trigonometry/pages/5-6-rational-functions | Rational functions, domain restrictions, asymptotic behavior. |
| OX-LINES | OpenStax | Precalculus 2e, 2.2 Graphs of Linear Functions | 2e | https://openstax.org/books/precalculus-2e/pages/2-2-graphs-of-linear-functions | Parallel/perpendicular slope rules, including vertical/horizontal exception. |
| OX-GEOM | OpenStax | Contemporary Mathematics, Ch. 10 geometry chapters | Edition page | https://openstax.org/books/contemporary-mathematics/pages/10-key-concepts | Standard Euclidean angle, line, polygon, perimeter, area, and quadrilateral facts. |

## Substantive correction ledger

### General Information

| Lesson | Original claim / issue | Corrected interpretation | Source(s) | Disposition |
|---|---|---|---|---|
| `general-information/code-of-conduct-ra-6713/duties-and-prohibited-acts.md` | The lesson treated the annual 45-working-day performance report as a duty of all officers, described a 15-day acknowledgement requirement, and described a limit on initials/signatures more broadly than the statute. | RA 6713 §5(a) requires a response containing action taken within 15 working days; §5(b)'s annual report applies to heads/responsible officers; §5(c) says official papers should have, as far as practicable, no more than three signatories; public documents are available at reasonable working hours. | PH-RA6713 §§5(a)-(e) | CORRECTED |
| `general-information/code-of-conduct-ra-6713/penalties-and-enforcement.md` | The up-to-₱25,000 amount was presented as a generic penalty for misuse of filed statements. | §11(d) allows the official/employee concerned to bring an action against a person who obtains/uses a report for a prohibited §8(D) purpose; the court may assess up to ₱25,000 in that specific action. | PH-RA6713 §11 | CORRECTED |
| `general-information/code-of-conduct-ra-6713/statements-of-assets-and-divestment.md` | SALN inspection was described as beginning only after 10 working days, filing offices were overgeneralized, and divestment timing was not stated with the statute's exact trigger. | Statements are available for inspection at reasonable hours; copying/reproduction becomes available after 10 working days. Filing offices follow §8(A), and §9 sets the 30/60-day resignation/divestment rules from assumption when conflict exists. | PH-RA6713 §§8-9 | CORRECTED |
| `general-information/environment-management/environmental-concepts.md` | The ECC description implied that issuance certifies general project compliance rather than documenting compliance with the Philippine EIS system and applicable conditions. | Clarified ECC as the EIS-system decision document/clearance and kept the lesson at an introductory operational level. | Philippine EIS framework under PD 1586; DENR/EMB materials were consulted in the web review | CLARIFIED |
| `general-information/environment-management/the-environmental-laws.md` | Several statutes were framed as items specifically “examined” instead of examples within the CSC's broader published Environment Management and Protection area. | Kept the statutes as useful Philippine environmental-law preparation but removed unsupported claims that CSC publishes those exact statutes as guaranteed item content. | PH-CSC-2026 plus the cited statutes | CLARIFIED |
| `general-information/peace-and-human-rights/humanitarian-law-and-human-rights-law.md` | The HRL/IHL distinction was stated too categorically in places. | IHL applies in armed conflict and binds all parties; international human-rights law remains applicable, though treaty derogation/jurisdiction rules make the relationship more nuanced than “only one body of law applies.” | ICRC-IHL | CORRECTED |
| `general-information/philippine-constitution/bill-of-rights.md` | The lesson grouped §§12-22 simply as “rights of the accused,” although several provisions are broader protections and some apply outside a criminal-trial posture. | Reframed §§12-22 as criminal-process and related protections without implying every section applies only to an accused person. | PH-CONST Art. III | CLARIFIED |
| `general-information/philippine-constitution/the-articles-in-outline.md` | The lesson made an unsupported claim that memorizing the article map is a “fundamental requirement” of Civil Service examinations. | Retained the article map as useful preparation while avoiding a claim about confidential or unreleased test-item design. | PH-CONST; PH-CSC-2026 | CLARIFIED |

### Mathematics — Arithmetic and Number Sense

| Lesson | Original claim / issue | Corrected interpretation | Source(s) | Disposition |
|---|---|---|---|---|
| `mathematics/arithmetic-number-sense/business-math.md` | Rule of 72 was presented under simple interest. At 8% simple interest the lesson's 9-year doubling estimate is false. | Rule of 72 is only an approximation for compound/exponential growth. Simple-interest doubling follows `2P=P(1+rt)`, so `t=1/r` (12.5 years at 8%). Compound-interest notation was also clarified for multiple compounding periods. | Standard interest formulas; cross-checked against OpenStax algebra/finance treatment | CORRECTED |
| `mathematics/arithmetic-number-sense/divisibility-rules.md` | “Zero is divisible by every number” lacked the required nonzero-divisor restriction; some splitting language implied a rule more general than justified. | `0` is divisible by every **nonzero** integer. Composite divisibility decomposition is stated only where the selected conditions together characterize divisibility. | Elementary number theory; OX-PREALG-LCM for factor reasoning | CORRECTED |
| `mathematics/arithmetic-number-sense/fractions-decimals-percentages.md` | Fraction/decimal/percent descriptions and conversion shortcuts were phrased as universal without noting repeating decimals/rounding. | Clarified exact versus approximate common conversions and kept percentage identities mathematically exact. | Standard arithmetic definitions | CLARIFIED |
| `mathematics/arithmetic-number-sense/order-of-operations.md` | “Plus and minus are walls” could imply arbitrary regrouping across subtraction; wording around unary negatives risked overgeneralization. | Kept PEMDAS/GEMDAS hierarchy while preserving left-to-right evaluation and the distinction between `-3^2` and `(-3)^2`. | Standard arithmetic convention | CLARIFIED |
| `mathematics/arithmetic-number-sense/prime-factorization-gcf-lcm.md` | The “continuous division” description said multiplying divisors and the final row always yields the LCM for multiple numbers; this can overcount. The remainder example asked for the smallest positive integer, for which `3` itself was smaller than `123`. | LCM uses the highest required prime powers. The remainder example now excludes the trivial value by requiring a number greater than the divisors before adding the common remainder to an LCM. | OX-PREALG-LCM | CORRECTED |
| `mathematics/arithmetic-number-sense/properties-of-real-numbers.md` | Multiplicative inverse rule lacked `a != 0`; subtraction/division wording was too absolute. | Reciprocal/inverse statements now carry the nonzero restriction and distinguish binary subtraction/division from equivalent addition/multiplication forms. | Standard field properties | CORRECTED |
| `mathematics/arithmetic-number-sense/ratio-and-proportion.md` | “Direct means divide; inverse means multiply” was presented as the definition, and examples assumed constant-rate conditions without stating them. | Direct proportion means a constant ratio (`y=kx`); inverse proportion means a constant product (`xy=k`) under the stated model. | Standard algebra treatment of proportional relationships | CORRECTED |
| `mathematics/arithmetic-number-sense/real-imaginary-numbers.md` | In `a+bi`, the lesson called `bi` the imaginary part; it also presented one convention for natural numbers as universal. | The imaginary part is the real coefficient `b`; conventions differ on whether `0` is included in the natural numbers, so the lesson states its convention instead of calling alternatives wrong by definition. | OX-CA-COMPLEX | CORRECTED |
| `mathematics/arithmetic-number-sense/sequences-and-series.md` | Infinite-geometric convergence was described informally as terms “shrinking,” and a divergent series was said to have a sum that is “infinite.” | A finite infinite-geometric sum exists exactly when `|r|<1`; otherwise the series diverges. Formula prerequisites were moved into the taught concept. | OpenStax College Algebra sequence/series treatment | CORRECTED |

### Mathematics — Algebra

| Lesson | Original claim / issue | Corrected interpretation | Source(s) | Disposition |
|---|---|---|---|---|
| `mathematics/algebra/exponents-and-logarithms.md` | Log rules omitted domain/base restrictions and implied cancellation identities without stating them. | For real logarithms, base `a>0`, `a!=1`, and arguments must be positive; inverse identities are used on their valid domains. | OX-CA-LOG | CORRECTED |
| `mathematics/algebra/functions-and-relations.md` | “Most of the time” domain restrictions were reduced to denominator-zero and even-root cases; inverse construction was described without the one-to-one requirement. | Domain also depends on logarithms, compositions, and other operations; a function must be one-to-one on the stated domain to have an inverse **function**. | OpenStax College Algebra functions/inverses treatment | CORRECTED |
| `mathematics/algebra/linear-equations-inequalities.md` | Slope shortcuts were stated without `B != 0` and vertical-line handling. | `m=-A/B` applies when `B!=0`; vertical lines have undefined slope. | OX-LINES | CORRECTED |
| `mathematics/algebra/polynomials.md` | “Synthetic division only works with a simple group like x-1” was imprecise and degree/domain language needed qualification. | Standard synthetic division in this lesson is for linear divisors of the form `x-c`; polynomial exponents are nonnegative integers. | Standard algebra treatment | CLARIFIED |
| `mathematics/algebra/quadratic-equations.md` | Completing-square instructions silently assumed a monic quadratic; discriminant `<0` was described as giving “two imaginary answers”; sign-of-roots shortcut ignored the leading coefficient and non-real cases. | Divide by `a` before the standard completing-square step when needed; negative discriminant gives two non-real complex-conjugate roots; product/sign reasoning uses `c/a` and only supports real-root sign conclusions when the roots are real. | OpenStax College Algebra quadratic-equation treatment | CORRECTED |
| `mathematics/algebra/radicals-and-rationalization.md` | Real-radical simplification and rationalization omitted variable/domain restrictions; an infinite-radical shortcut was stated as universal. | Added the conditions under which square-root product/simplification rules hold and removed overbroad shortcut language. | Standard real-radical algebra | CORRECTED |
| `mathematics/algebra/sets-and-set-notation.md` | `Total = A + B - overlap` was labeled as a universal total formula. | The formula gives `|A ∪ B|`; a universal population may also contain a “neither” region. | Standard inclusion-exclusion | CORRECTED |
| `mathematics/algebra/types-of-functions.md` | Rational functions were described as any fraction with `x` in the denominator, and asymptotes as lines a curve never touches. | A rational function is a quotient of polynomials with nonzero denominator; an asymptote describes limiting behavior and a graph can cross some asymptotes (for example, horizontal or oblique asymptotes). | OX-CA-RATIONAL | CORRECTED |

### Mathematics — Geometry

| Lesson | Original claim / issue | Corrected interpretation | Source(s) | Disposition |
|---|---|---|---|---|
| `mathematics/geometry/basic-geometric-concepts.md` | “Through any two points” omitted “distinct”; adjacent/linear-pair definitions were loose; exam-frequency wording was unsupported. | Unique line through two **distinct** points; adjacent angles share a side and have non-overlapping interiors; a linear pair's non-common sides are opposite rays. | OX-GEOM | CORRECTED |
| `mathematics/geometry/coordinate-geometry.md` | Negative-reciprocal/product-`-1` perpendicular-slope rule was presented without the horizontal/vertical exception; `m=-A/B` lacked `B!=0`. | Negative reciprocal/product test applies when both slopes are defined; vertical and horizontal lines are perpendicular, and vertical slopes are undefined. | OX-LINES | CORRECTED |
| `mathematics/geometry/quadrilaterals-and-polygons.md` | “Trapezoid = exactly one pair of parallel sides” was presented as the only convention; polygon/exterior-angle statements omitted their standard simple/convex context. | The lesson now explicitly adopts the exclusive trapezoid convention and notes that inclusive definitions also exist. Interior/exterior formulas are stated in the standard simple/convex setting used by the lesson. | OX-GEOM | CLARIFIED |

## Per-lesson inventory

`Status` below records the current state of the pass, not publication approval.

| Domain | Lesson | Factual verification | Tone/wording | Pedagogy | Source status | Edited | Unresolved concerns | Status |
|---|---|---|---|---|---|---|---|---|
| General Information | `code-of-conduct-ra-6713/duties-and-prohibited-acts` | checked against RA 6713 | checked | checked | primary statute | yes | none | CORRECTED |
| General Information | `code-of-conduct-ra-6713/norms-of-conduct` | checked against RA 6713 | checked | checked | primary statute | no | none | VERIFIED |
| General Information | `code-of-conduct-ra-6713/penalties-and-enforcement` | checked against RA 6713 | checked | checked | primary statute | yes | none | CORRECTED |
| General Information | `code-of-conduct-ra-6713/statements-of-assets-and-divestment` | checked against RA 6713 | checked | checked | primary statute | yes | none | CORRECTED |
| General Information | `environment-management/environmental-concepts` | checked | checked | checked | Philippine legal/agency sources | yes | none | CLARIFIED |
| General Information | `environment-management/the-environmental-laws` | checked | checked | checked | CSC + Philippine statutes | yes | none | CLARIFIED |
| General Information | `peace-and-human-rights/human-rights-fundamentals` | checked | checked | checked | Constitution + ICRC | no | none | VERIFIED |
| General Information | `peace-and-human-rights/humanitarian-law-and-human-rights-law` | checked | checked | checked | ICRC | yes | none | CORRECTED |
| General Information | `philippine-constitution/accountability-and-impeachment` | checked against Constitution | checked | checked | primary Constitution | no | none | VERIFIED |
| General Information | `philippine-constitution/bill-of-rights` | checked against Constitution | checked | checked | primary Constitution | yes | none | CLARIFIED |
| General Information | `philippine-constitution/the-articles-in-outline` | checked against Constitution | checked | checked | Constitution + CSC | yes | none | CLARIFIED |
| General Information | `philippine-constitution/the-civil-service-commission` | checked against Constitution | checked | checked | primary Constitution | no | none | VERIFIED |
| Mathematics / Arithmetic | `business-math` | examples re-derived | checked | checked | standard/OpenStax references | yes | none | CORRECTED |
| Mathematics / Arithmetic | `divisibility-rules` | examples re-derived | checked | checked | standard number theory | yes | none | CORRECTED |
| Mathematics / Arithmetic | `fractions-decimals-percentages` | examples re-derived | checked | checked | standard arithmetic | yes | none | CLARIFIED |
| Mathematics / Arithmetic | `order-of-operations` | examples re-derived | checked | checked | standard arithmetic convention | yes | none | CLARIFIED |
| Mathematics / Arithmetic | `prime-factorization-gcf-lcm` | examples re-derived | checked | checked | OX-PREALG-LCM | yes | none | CORRECTED |
| Mathematics / Arithmetic | `properties-of-real-numbers` | examples re-derived | checked | checked | standard algebra | yes | none | CORRECTED |
| Mathematics / Arithmetic | `ratio-and-proportion` | examples re-derived | checked | checked | standard algebra | yes | none | CORRECTED |
| Mathematics / Arithmetic | `real-imaginary-numbers` | examples re-derived | checked | checked | OX-CA-COMPLEX | yes | none | CORRECTED |
| Mathematics / Arithmetic | `sequences-and-series` | examples re-derived | checked | checked | standard/OpenStax algebra | yes | none | CORRECTED |
| Mathematics / Algebra | `algebraic-expressions` | examples re-derived | checked | checked | standard algebra | no | none | VERIFIED |
| Mathematics / Algebra | `exponents-and-logarithms` | examples re-derived | checked | checked | OX-CA-LOG | yes | none | CORRECTED |
| Mathematics / Algebra | `functions-and-relations` | examples re-derived | checked | checked | standard/OpenStax functions | yes | none | CORRECTED |
| Mathematics / Algebra | `linear-equations-inequalities` | examples re-derived | checked | checked | OX-LINES | yes | none | CORRECTED |
| Mathematics / Algebra | `polynomials` | examples re-derived | checked | checked | standard algebra | yes | none | CLARIFIED |
| Mathematics / Algebra | `quadratic-equations` | examples re-derived | checked | checked | standard/OpenStax algebra | yes | none | CORRECTED |
| Mathematics / Algebra | `radicals-and-rationalization` | examples re-derived | checked | checked | standard algebra | yes | none | CORRECTED |
| Mathematics / Algebra | `sets-and-set-notation` | examples re-derived | checked | checked | inclusion-exclusion | yes | none | CORRECTED |
| Mathematics / Algebra | `systems-of-equations` | examples re-derived | checked | checked | standard algebra | no | none | VERIFIED |
| Mathematics / Algebra | `types-of-functions` | examples re-derived | checked | checked | OX-CA-RATIONAL | yes | none | CORRECTED |
| Mathematics / Algebra | `word-problems` | all six worked examples re-derived | checked | checked | standard algebra | no | none | VERIFIED |
| Mathematics / Geometry | `basic-geometric-concepts` | checked | checked | checked | OX-GEOM | yes | none | CORRECTED |
| Mathematics / Geometry | `circles` | all examples re-derived | checked | checked | OX-GEOM | no | none | VERIFIED |
| Mathematics / Geometry | `coordinate-geometry` | all examples re-derived | checked | checked | OX-LINES | yes | none | CORRECTED |
| Mathematics / Geometry | `logic-and-reasoning` | truth relations/examples checked | checked | checked | standard propositional logic | no | none | VERIFIED |
| Mathematics / Geometry | `measurement` | all examples re-derived | checked | checked | OX-GEOM | no | wording sweep still pending | VERIFIED |
| Mathematics / Geometry | `parallel-perpendicular-lines` | all examples re-derived | checked | checked | OX-GEOM | no | wording sweep still pending | VERIFIED |
| Mathematics / Geometry | `quadrilaterals-and-polygons` | all examples re-derived | checked | checked | OX-GEOM | yes | none | CLARIFIED |
| Mathematics / Geometry | `triangles` | all examples re-derived | checked | checked | OX-GEOM | no | wording sweep still pending | VERIFIED |

**Audited so far: 40 / 158.**  
**Edited so far: 28.**  
**Verified without content change so far: 12.**

## Remaining domains

The following have not yet received final R1 status and must not be represented as verified until their own source/example pass is complete:

- Mathematics / Trigonometry
- Mathematics / Statistics and Probability
- Mathematics / Precalculus and Basic Calculus
- Mathematics / Data Interpretation
- Science / Earth Science and Astronomy
- Science / Biology
- Science / Chemistry
- Science / Physics
- Language Proficiency
- Reading Comprehension
- Reasoning, including the CSE clerical/verbal additions

## Illustration follow-up log

This QA branch does not alter illustration scope or assets. Existing geometry placeholders were checked only for contradiction with the audited prose. No new geometry illustration scope is authorized here.
