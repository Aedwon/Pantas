# Question QA round r2: combined acceptance summary

Date: 3 October 2026. Branch: `content/question-qa-r2`.

## Outcome and scope

The approved audit, expansion, mechanical verification, integration, and importer-note enforcement are complete on the working branch. All 158 source lessons have at least 20 imported active questions. There are 3,163 active questions, including 799 added questions. All 2,364 pre-QA question IDs remain in their original files. The ledgers record 19 corrected answer keys.

The three CSE vocabulary placeholder lessons are outside this audit. The production export separately retains two historical CSE placeholder questions without lesson links; its total is 3,165 questions. This report counts the 158 audited YAML lessons only.

The content authors reported their semantic audits and complete per-question ledgers. As Aedwon directed, the orchestrator performed mechanical checks and did not independently review their authored content. The importer and test changes received an independent code review by the orchestrator, who did not author them.

134 questions remain `NEEDS AEDWON`, including 19 HIGH findings retained under the preservation rule. Those questions remain active; their stems, choices, and keys were preserved while explanations, notes, and formatting were reshaped. This is completion of the authorized audit, not release acceptance or resolution of those decisions.

## Source identity

- Audit baseline: `1f79d880264e9c80c7507c95a365126d251c3837`.
- Verified feature commit: `533f06e43fabe587b58dfa93a497fda2fcedaab7`.
- Final policy read: `7c53c0a37326868c05ea0eb02667df4b43a8a282` on main; policy files are independent of the code branch.
- Controlling plan: `docs/superpowers/plans/2026-10-02-question-qa-r2-orchestrator.md` on main.
- Approvals, exact user comments, lead rulings, checkpoints, and final branch SHA: `docs/superpowers/decisions/2026-10-01-question-explanations-log.md` on main.
- This report adds documentation only after the verified feature commit. The report-inclusive working-branch SHA is recorded in the main decision log.

| Group | Accepted source commit | Lessons | Existing audited | Added | Active | Fixed keys | Pending items |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| math | `0e9cca17558aa48720cd4aebf04930adf8a946b1` | 46 | 712 | 208 | 920 | 1 | 58 |
| science | `1e40ca47e3b8251ed0c97cb01b01634021dd0012` | 51 | 777 | 246 | 1023 | 8 | 33 |
| other | `25b4e45f09c79948768cb14407a3abffb73c8a9c` | 61 | 875 | 345 | 1220 | 10 | 43 |

All three summaries are committed and all three source commits are merged with `--no-ff`. Their remote SHAs were verified before integration. No merge conflict occurred. Branches and worktrees were preserved.

## Counts

| Status | Count |
| --- | ---: |
| CORRECTED | 1702 |
| NEEDS AEDWON | 134 |
| NEW | 799 |
| VERIFIED | 528 |

| Original finding severity | Count |
| --- | ---: |
| HIGH | 436 |
| LOW | 223 |
| MEDIUM | 1196 |
| NONE | 1308 |

HIGH is the severity found before correction, not a count of remaining wrong keys. The 436 original HIGH findings are listed below; their 19 pending HIGH items are identified separately. The 19 recorded key fixes are a different measure.

## Mechanical gates and final verification

Commands ran on the exact verified feature source with clean tracked status. Tests that spawn Dart ran serially, with no overlapping test process.

```text
dart run tools/import_questions/import_questions.dart --root content/questions > /dev/null
exit: 0
lessons=158 questions=3163 active=3163 preserved=2364 fixed_keys=19 under20=0 errors=0

flutter test --no-pub --concurrency=1 --reporter expanded
06:26 +3409: All tests passed!
exit: 0

flutter analyze --no-pub
1 issue found: explicitly accepted bookmarks_sheet.dart:238:21 onReorder deprecation info
exit: 1, accepted exact exception; no errors or warnings

dart format --output=none --set-exit-if-changed lib test
Formatted 1277 files (0 changed)
exit: 0

dart run tool/check_layering.dart
check_layering: OK
exit: 0

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
exit: 0

git diff --check
exit: 0
```

The script inspected every YAML source file and the actual importer output. It checked active counts, nonempty wrong-choice notes in source and emitted choices, unique IDs, per-file baseline ID preservation, unchanged lesson and exam routing, complete matching ledger rows, no bare fraction commands, no U+2014, and no prohibited choice text (All of the above, None of the above, Both A and B). There are no under-20 exceptions.

Mechanical checker SHA-256: `52f49991169d459a54d6aa1b6d1a8b23311546fe2a6f0cff7f12a517c604a810`. The command used the worktree package configuration and an NDJSON capture of the actual importer output. The current mechanical result is reproduced in the counts and per-lesson table here; detailed execution logs remain in the Mac QA log directory.

The new guard rejects missing, null, empty, and whitespace-only wrong-choice notes with a FormatException naming the question and one-based choice number. Correct choices need no note. Non-string rejection, figure activation, conversion, and note propagation remain unchanged. Four loaded regression tests failed before the guard and passed afterward. All 41 focused tests passed, including the shipping parser and temporary database round trip.

## Verification-input recovery and test adaptations

The combined worktree lacked ignored generated code, localizations, and seed inputs. Existing generation commands recreated ignored code/localizations from unchanged source. The already-authenticated frozen engineering package was copied byte-for-byte as verification input, not rebuilt or signed. Flutter 3.44.6 and Dart 3.12.2 were used. The package inputs are still the prior bank and are not the QA release package.

| Unchanged verification input | SHA-256 |
| --- | --- |
| `content.db` | `0ef89a64f2d2f63854b3d22048a7d992d5c04fb03df4fec2e7f4e898e6d083dc` |
| `content.manifest.json` | `51bc0a766558879e540475ab972f03df7e3077241bab8f688c1b50ece5874f23` |
| `content.manifest.sig` | `e0853df259529031344f14d5a5fe6628e1b92c367a96c584894058fe13199f31` |

The first full-suite run had 3,396 passing tests and two failures because the live export counts changed and an E02 migration test regenerated its historical specimen from the live QA bank. Both files passed unchanged on the pre-QA baseline. The lead recorded a bounded test-only revision before editing.

The live export test now pins measured counts while retaining ordering, mapping, database, and passage checks. The historical test loads the immutable compressed pre-QA export, verifies both input hashes, and reconstructs the unchanged approved E02 database digest. The production migration allowlist and all existing migration/user-data preservation assertions were retained. This adds no Git-history or network dependency to the tests and does not duplicate a generated production database.

- Static historical fixture: `test/fixtures/content/e02_export.json.gz`.
- Compressed bytes: 1,065,219.
- Compressed SHA-256: `74d952691046485458c06b82313984e551b2a57e5a5f7b02f93c5023dfabfc78`.
- Decoded export SHA-256: `51349cfe24049a282b8dc053c3a01df65d5636e7808b055d3008cead2504ff67`.
- Preserved approved E02 DB SHA-256: `eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45`.

The corrected full suite passed 3,409 tests. No production library or tracked seed source changed. Runtime changes are limited to the approved importer guard; other changes are the scoped tests, immutable test input, question YAML, ledgers, and summaries.

## Lessons under 20

None. Every audited lesson has 20 to 22 emitted active questions. No figure-pending question is counted.

## Answer keys recorded as fixed

- `q-arithmetic-number-sense-properties-of-real-numbers-0015`: Wrong key: the y coefficients sum to 9-2+5=12, not 14. Correct choice and mistaken distractor derivations fixed.
- `rc-cs-ic-0013`: Original conclusion exceeded the evidence: stable turnover did not establish satisfaction or lower departures.
- `q-clerical-ability-alphabetic-filing-rules-0001`: The answer changed the recorded surname Dela Cruz to Delacruz; restored its spelling and stated the rule.
- `q-clerical-ability-alphabetic-filing-rules-0004`: The answer respelled De la Rosa as Delarosa and presented the convention as universal.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0013`: Original asserted three movable pulleys always yield advantage eight without rope routing.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0015`: Original wrongly claimed equal-advantage ideal machines require different travel and showed mismatched arms.
- `q-spatial-abstract-reasoning-figure-matrices-0004`: Key said black for a blank in the white middle column; solved from the actual grid and fixed.
- `q-spatial-abstract-reasoning-mental-rotation-3d-visualization-0011`: Key incorrectly named the topmost column square; the second-from-top center is opposite the bottommost square.
- `q-spatial-abstract-reasoning-paper-folding-and-cutting-0001`: Key gave two openings despite the stem explicitly limiting the cut to one layer; fixed to one.
- `q-verbal-logic-assumptions-and-conclusions-0001`: Achievable completion is not necessary for a conditional policy to be true; corrected the key using the lesson's stated distinction.
- `q-verbal-logic-assumptions-and-conclusions-0008`: The old answer merely repeated the causal claim as an assumption. Replaced the asserted percentage with a causal-inference argument and a necessary unstated link.
- `q-biology-botany-0012`: Marked answer and explanation overgeneralized negative root phototropism.
- `q-biology-cellular-metabolism-0012`: Original key and explanation treated the pathways as exact mirror-image reactions.
- `q-biology-taxonomy-and-classification-0004`: Original key called leo the whole species name while another choice correctly named the binomial.
- `q-chemistry-acids-bases-ph-0013`: Original marked choice falsely claimed every neutralization produces salt and water.
- `q-chemistry-mole-concept-0006`: Original marked answer falsely prohibited valid combined dimensional-analysis conversions.
- `q-chemistry-quantum-numbers-electron-configuration-0002`: Original key gave six for a single p orbital; repaired through explicit orbital/subshell comparison.
- `q-chemistry-quantum-numbers-electron-configuration-0003`: Original key gave ten for one d orbital; new framing distinguishes orbital count from electron capacity.
- `q-earth-science-astronomy-layers-of-the-earth-0002`: Original key used 70 km as typical continental thickness instead of about 35 km.

## Pending HIGH decisions

- `q-code-of-conduct-ra-6713-penalties-and-enforcement-0011`: Lesson does not teach CSC procedure; stem attributes rule to Section 11 instead of Section 12.
- `q-code-of-conduct-ra-6713-statements-of-assets-and-divestment-0013`: Lesson does not teach university-specific routing; blanket wording overlooks category/location distinctions.
- `q-philippine-constitution-accountability-and-impeachment-0010`: Lesson lists but does not define grounds; betrayal of public trust can also fit the unqualified stem.
- `q-philippine-constitution-accountability-and-impeachment-0011`: Lesson does not define treason; betrayal of public trust can also fit the unqualified stem.
- `q-geometry-triangles-0015`: The lesson does not teach area scaling; the old 9.6 note also claimed an inverted ratio produces it, which is false. Stem, choices and key retained.
- `rc-cs-mi-0012`: Retrieving the purpose of dike openings is a detail question. Original source made unverified claims about a real project; relabeled as a fictional account.
- `rc-cs-mi-0013`: Inferring scientific methods from site selection is an inference question. Original source made unverified claims about a real project; relabeled as a fictional account.
- `rc-cs-mi-0014`: Retrieving two outcomes is a detail question. Original source made unverified claims about a real project; relabeled as a fictional account.
- `q-clerical-ability-alphabetic-filing-rules-0003`: Business stop-word treatment is not taught; key depends on an unnamed convention and is not universal. Stem, choices and key retained.
- `q-clerical-ability-alphabetic-filing-rules-0009`: Abbreviation expansion is not taught; the key depends on an unnamed system and is not universal. Stem, choices and key retained.
- `q-clerical-ability-alphabetic-filing-rules-0011`: Government-agency jurisdiction ordering is not taught; the key depends on an unnamed convention. Stem, choices and key retained.
- `q-mechanical-technical-reasoning-structural-stability-0011`: Curved-base self-righting is absent from the lesson; the always claim and long key are retained for a ruling. No supported renderer draws this rounded base.
- `q-biology-characteristics-of-life-0013`: Lesson does not teach this distinction; preserved keyed choice incorrectly requires two parents and remains longest. Explanation now qualifies self-fertilization; false sexual-bacterial claim removed from notes.
- `q-earth-science-astronomy-fossils-and-geologic-time-0002`: Lesson does not teach fossil preservation by rock-formation conditions. Stem/choices/key preserved; original explanation wrongly excluded every metamorphosed fossil.
- `q-earth-science-astronomy-fossils-and-geologic-time-0021`: Lesson lacks early-fish/Paleozoic teaching; isotope clock unspecified and not necessarily layer-deposition age. Stem/choices/key and longest cue preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0018`: Hardness/streak absent from lesson; equal nominal reference hardness makes scratch bounds inconsistent; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0002`: History is untaught; 1927 expanding-universe work is conflated with 1931 primeval-atom proposal; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0007`: History is untaught; retained key conflates 1927 expansion work with later Big Bang origin proposal; overlaps 0002.
- `q-earth-science-astronomy-plate-tectonics-0003`: Named/date history untaught; 1959 date is unsupported by checked USGS chronology (model 1960, publication 1962); stem, choices, key preserved.

## Every NEEDS AEDWON item

- `q-code-of-conduct-ra-6713-penalties-and-enforcement-0011` [HIGH]: Lesson does not teach CSC procedure; stem attributes rule to Section 11 instead of Section 12.
- `q-code-of-conduct-ra-6713-penalties-and-enforcement-0013` [LOW]: Lesson names Section 8 penalties but does not teach the section-to-SALN mapping.
- `q-code-of-conduct-ra-6713-penalties-and-enforcement-0014` [LOW]: Lesson names Section 9 penalties but does not teach the section-to-divestment mapping.
- `q-code-of-conduct-ra-6713-statements-of-assets-and-divestment-0013` [HIGH]: Lesson does not teach university-specific routing; blanket wording overlooks category/location distinctions.
- `q-environment-management-environmental-concepts-0007` [LOW]: Lesson teaches the framework but does not name its national council.
- `q-peace-and-human-rights-humanitarian-law-and-human-rights-law-0006` [LOW]: Lesson describes armed-conflict scope but does not teach this alternate name.
- `q-philippine-constitution-accountability-and-impeachment-0010` [HIGH]: Lesson lists but does not define grounds; betrayal of public trust can also fit the unqualified stem.
- `q-philippine-constitution-accountability-and-impeachment-0011` [HIGH]: Lesson does not define treason; betrayal of public trust can also fit the unqualified stem.
- `q-philippine-constitution-accountability-and-impeachment-0015` [LOW]: Lesson names the ground but does not teach its intentional-breach definition.
- `q-philippine-constitution-bill-of-rights-0006` [LOW]: Lesson names suspension limits but does not explain the writ's purpose.
- `q-philippine-constitution-bill-of-rights-0008` [MEDIUM]: Lesson names the protection but does not teach its legal conditions; original stem is overbroad.
- `q-philippine-constitution-bill-of-rights-0009` [LOW]: Lesson names but does not define ex post facto laws.
- `q-philippine-constitution-bill-of-rights-0010` [LOW]: Lesson names but does not define bills of attainder.
- `q-philippine-constitution-bill-of-rights-0012` [LOW]: Lesson teaches the safeguards but not the Miranda label.
- `q-philippine-constitution-bill-of-rights-0014` [LOW]: Lesson states search protection but does not teach warrant-issuance conditions.
- `q-philippine-constitution-the-civil-service-commission-0011` [LOW]: Lesson omits the initial transitional appointment durations.
- `q-philippine-constitution-the-civil-service-commission-0012` [LOW]: This lesson does not teach impeachment; it belongs in accountability material.
- `q-grammar-and-structure-phrases-and-clauses-0009` [MEDIUM]: Tests comma placement, which this lesson does not teach explicitly. Stem, choices and key retained; notes reshaped.
- `q-grammar-and-structure-phrases-and-clauses-0010` [MEDIUM]: Tests comma placement, which this lesson does not teach explicitly. Stem, choices and key retained; notes reshaped.
- `q-grammar-and-structure-phrases-and-clauses-0013` [MEDIUM]: Tests comma placement, which this lesson does not teach explicitly. Stem, choices and key retained; notes reshaped.
- `q-grammar-and-structure-redundancy-and-double-negatives-0005` [MEDIUM]: Requires an acronym expansion that the lesson does not teach. Stem, choices and key retained; notes reshaped.
- `q-grammar-and-structure-redundancy-and-double-negatives-0007` [MEDIUM]: Requires an acronym expansion that the lesson does not teach. Stem, choices and key retained; notes reshaped.
- `q-grammar-and-structure-redundancy-and-double-negatives-0009` [MEDIUM]: Requires an acronym expansion that the lesson does not teach. Stem, choices and key retained; notes reshaped.
- `q-grammar-and-structure-redundancy-and-double-negatives-0015` [MEDIUM]: Requires an acronym expansion that the lesson does not teach. Stem, choices and key retained; notes reshaped.
- `q-grammar-and-structure-subject-verb-agreement-0018` [MEDIUM]: Tests Filipino focus and marker roles that the lesson names but explicitly leaves to other Filipino grammar topics. Stem, choices and key retained; explanation and notes reshaped.
- `q-grammar-and-structure-subject-verb-agreement-0019` [MEDIUM]: Tests Filipino focus and marker roles that the lesson names but explicitly leaves to other Filipino grammar topics. Stem, choices and key retained; explanation and notes reshaped.
- `q-grammar-and-structure-tenses-and-voice-0011` [MEDIUM]: Tests a specific Filipino object-focus construction that the lesson does not teach. Stem, choices and key retained; explanation and notes reshaped.
- `q-language-application-error-identification-0014` [MEDIUM]: Requires the unreal-past conditional pattern, which the lesson does not teach. Stem, choices and key retained; explanation and notes reshaped.
- `q-vocabulary-root-words-prefixes-suffixes-0016` [MEDIUM]: Tests a consonant/vowel placement rule not explicitly taught by the lesson. Stem, choices and key retained; explanation and notes reshaped.
- `q-algebra-sets-and-set-notation-0004` [MEDIUM]: The lesson does not teach the empty set or its universal subset property.
- `q-algebra-sets-and-set-notation-0008` [MEDIUM]: The lesson does not teach counting subsets or the rule 2^n.
- `q-algebra-sets-and-set-notation-0013` [MEDIUM]: The lesson does not teach set-builder notation or relative-complement notation.
- `q-algebra-sets-and-set-notation-0014` [MEDIUM]: The lesson does not teach De Morgan’s identities.
- `q-algebra-types-of-functions-0015` [MEDIUM]: The lesson does not teach perpendicular slopes; stem, choices and key retained.
- `q-arithmetic-number-sense-business-math-0002` [MEDIUM]: The lesson does not teach the distance-based fare rule or rounding partial kilometers.
- `q-arithmetic-number-sense-business-math-0005` [MEDIUM]: The lesson does not teach commissions on net profit.
- `q-arithmetic-number-sense-business-math-0006` [MEDIUM]: The lesson does not teach profit margin on selling price.
- `q-arithmetic-number-sense-business-math-0007` [MEDIUM]: The lesson does not teach the distance-based fare rule.
- `q-arithmetic-number-sense-business-math-0012` [MEDIUM]: The lesson does not teach tiered commissions; the old note for 8700 had an incorrect derivation.
- `q-arithmetic-number-sense-business-math-0013` [MEDIUM]: The lesson does not teach conversion between margin and markup.
- `q-arithmetic-number-sense-business-math-0014` [MEDIUM]: The lesson does not teach fare-revenue accounting.
- `q-arithmetic-number-sense-business-math-0015` [MEDIUM]: The lesson does not teach payment allocation to interest before principal.
- `q-arithmetic-number-sense-fractions-decimals-percentages-0004` [MEDIUM]: The lesson does not teach repeating-decimal conversion; stem, choices and key retained.
- `q-arithmetic-number-sense-fractions-decimals-percentages-0010` [MEDIUM]: The lesson does not teach simple interest; two notes had incorrect numerical derivations, now corrected.
- `q-arithmetic-number-sense-prime-factorization-gcf-lcm-0013` [MEDIUM]: The lesson does not teach counting divisors with exponent choices; stem, choices and key retained.
- `q-arithmetic-number-sense-properties-of-real-numbers-0012` [MEDIUM]: The lesson does not teach closure or the standard number sets; stem, choices and key retained. Correct choice remains longest under the preservation rule.
- `q-arithmetic-number-sense-ratio-and-proportion-0007` [MEDIUM]: The lesson does not teach area or squared map scales; stem, choices and key retained.
- `q-arithmetic-number-sense-ratio-and-proportion-0012` [MEDIUM]: The lesson does not teach the distance-speed-time formula; stem, choices and key retained. The old 32 note lacked a specific calculation, now identified as a forty-minute hour.
- `q-geometry-basic-geometric-concepts-0011` [MEDIUM]: The lesson does not define perpendicular rays; stem, choices and key retained.
- `q-geometry-basic-geometric-concepts-0014` [MEDIUM]: The lesson does not teach the 360-degree sum around a point; stem, choices and key retained.
- `q-geometry-circles-0008` [MEDIUM]: The lesson does not teach cyclic-quadrilateral opposite angles; stem, choices and key retained.
- `q-geometry-circles-0009` [MEDIUM]: The lesson does not teach the interior intersecting-chord angle theorem; stem, choices and key retained.
- `q-geometry-circles-0010` [MEDIUM]: The lesson does not teach the exterior secant-angle theorem; stem, choices and key retained.
- `q-geometry-circles-0011` [MEDIUM]: The lesson does not teach perpendicular-from-center chord bisection; stem, choices and key retained.
- `q-geometry-circles-0012` [MEDIUM]: The lesson does not teach the tangent-secant power theorem; stem, choices and key retained.
- `q-geometry-circles-0013` [MEDIUM]: The lesson does not teach the area of an inscribed square; stem, choices and key retained.
- `q-geometry-circles-0015` [MEDIUM]: The lesson does not teach equal tangent triangles and the thirty-degree right-triangle rule; stem, choices and key retained.
- `q-geometry-coordinate-geometry-0008` [MEDIUM]: The lesson does not teach triangle area from coordinates; stem, choices and key retained.
- `q-geometry-coordinate-geometry-0012` [MEDIUM]: The lesson does not teach parallelogram area from coordinates; stem, choices and key retained.
- `q-geometry-coordinate-geometry-0013` [MEDIUM]: The lesson does not teach circle equations and completing squares; stem, choices and key retained.
- `q-geometry-coordinate-geometry-0014` [MEDIUM]: The lesson does not teach solving simultaneous line equations; stem, choices and key retained.
- `q-geometry-coordinate-geometry-0015` [MEDIUM]: The lesson does not teach the point-to-line distance formula; stem, choices and key retained.
- `q-geometry-logic-and-reasoning-0012` [MEDIUM]: The lesson does not teach diagonal properties of parallelograms, rectangles, and rhombi; stem, choices and key retained. Correct choice remains longest under the preservation rule.
- `q-geometry-logic-and-reasoning-0013` [MEDIUM]: The lesson does not teach the formal negation of a conditional; stem, choices and key retained.
- `q-geometry-measurement-0011` [MEDIUM]: The lesson gives cone volume and slant height but not cone surface area; stem, choices and key retained.
- `q-geometry-quadrilaterals-and-polygons-0007` [MEDIUM]: The lesson does not teach the trapezoid midsegment-length rule; stem, choices and key retained.
- `q-geometry-quadrilaterals-and-polygons-0008` [MEDIUM]: The lesson does not teach the Pythagorean theorem needed for perimeter from rhombus diagonals; stem, choices and key retained.
- `q-geometry-quadrilaterals-and-polygons-0011` [MEDIUM]: The lesson does not teach counting polygon diagonals; stem, choices and key retained.
- `q-geometry-quadrilaterals-and-polygons-0013` [MEDIUM]: The lesson does not teach square area from its diagonal; stem, choices and key retained.
- `q-geometry-triangles-0013` [MEDIUM]: The lesson does not teach the right-triangle altitude proportion; stem, choices and key retained.
- `q-geometry-triangles-0015` [HIGH]: The lesson does not teach area scaling; the old 9.6 note also claimed an inverted ratio produces it, which is false. Stem, choices and key retained.
- `q-precalculus-basic-calculus-conic-sections-0004` [MEDIUM]: The lesson does not teach focal-locus definitions; the stem also lacks an absolute-difference condition. Stem, choices and key retained.
- `q-precalculus-basic-calculus-conic-sections-0014` [MEDIUM]: The lesson does not teach the parabola focus parameter; stem, choices and key retained.
- `q-statistics-and-probability-basic-probability-0014` [MEDIUM]: The lesson does not teach reverse conditioning with Bayes rule; stem, choices and key retained.
- `q-statistics-and-probability-combinatorics-0006` [MEDIUM]: Repeated-letter arrangements are not taught in the lesson; stem, choices and key retained.
- `q-statistics-and-probability-combinatorics-0007` [MEDIUM]: Circular arrangements are not taught in the lesson; stem, choices and key retained.
- `q-statistics-and-probability-combinatorics-0011` [MEDIUM]: Block arrangements are not taught in the lesson; stem, choices and key retained.
- `q-statistics-and-probability-combinatorics-0013` [MEDIUM]: Circular block arrangements are not taught in the lesson; stem, choices and key retained.
- `q-statistics-and-probability-combinatorics-0015` [MEDIUM]: Excluded-adjacency block counting are not taught in the lesson; stem, choices and key retained.
- `q-statistics-and-probability-data-analysis-graphs-0012` [MEDIUM]: Weighted or grouped-data means are not taught in this graph lesson; stem, choices and key retained. Replaced vague guess or rounding notes with explicit row-copying and premature-rounding mistakes.
- `q-statistics-and-probability-data-analysis-graphs-0013` [MEDIUM]: Weighted or grouped-data means are not taught in this graph lesson; stem, choices and key retained. Replaced vague guess or rounding notes with explicit row-copying and premature-rounding mistakes.
- `q-statistics-and-probability-measures-of-central-tendency-0015` [MEDIUM]: The lesson does not teach the usual mean-median-mode ordering in a skewed distribution; that ordering is not universal. Stem, choices and key retained.
- `q-statistics-and-probability-measures-of-variability-0015` [MEDIUM]: The lesson gives the sample denominator but does not teach unbiased estimation or Bessel correction; stem, choices and key retained.
- `q-trigonometry-inverse-trigonometric-functions-0014` [MEDIUM]: The lesson does not teach secant; stem, choices and key retained.
- `q-trigonometry-inverse-trigonometric-functions-0016` [MEDIUM]: The lesson does not teach cotangent; stem, choices and key retained. Correct choice remains longest under the preservation rule.
- `q-trigonometry-solving-right-triangles-0011` [MEDIUM]: The lesson does not teach cotangent. The intended level-ground and ground-level observations are also unstated. Stem, choices and key retained. Correct choice remains longest under the preservation rule.
- `q-trigonometry-solving-right-triangles-0016` [MEDIUM]: The lesson does not teach cotangent. The intended level-ground and ground-level observations are also unstated. Stem, choices and key retained. Correct choice remains longest under the preservation rule.
- `rc-cs-mi-0002` [MEDIUM]: Direct retrieval of a percentage is not the main-idea skill; allocation also combines beds and compost.
- `rc-cs-mi-0003` [MEDIUM]: Inferring a leader's general preference is outside the main-idea skill.
- `rc-cs-mi-0004` [MEDIUM]: Retrieving the youth petition motive is a detail question.
- `rc-cs-mi-0007` [MEDIUM]: Retrieving a ledger's function is a detail question.
- `rc-cs-mi-0008` [MEDIUM]: Explaining customer motives is an inference question.
- `rc-cs-mi-0009` [MEDIUM]: Retrieving a credit rule is a detail question.
- `rc-cs-mi-0012` [HIGH]: Retrieving the purpose of dike openings is a detail question. Original source made unverified claims about a real project; relabeled as a fictional account.
- `rc-cs-mi-0013` [HIGH]: Inferring scientific methods from site selection is an inference question. Original source made unverified claims about a real project; relabeled as a fictional account.
- `rc-cs-mi-0014` [HIGH]: Retrieving two outcomes is a detail question. Original source made unverified claims about a real project; relabeled as a fictional account.
- `q-clerical-ability-alphabetic-filing-rules-0003` [HIGH]: Business stop-word treatment is not taught; key depends on an unnamed convention and is not universal. Stem, choices and key retained.
- `q-clerical-ability-alphabetic-filing-rules-0009` [HIGH]: Abbreviation expansion is not taught; the key depends on an unnamed system and is not universal. Stem, choices and key retained.
- `q-clerical-ability-alphabetic-filing-rules-0011` [HIGH]: Government-agency jurisdiction ordering is not taught; the key depends on an unnamed convention. Stem, choices and key retained.
- `q-clerical-ability-numeric-and-chronological-filing-0009` [MEDIUM]: Terminal-digit filing is explicitly outside the lesson's taught methods. Stem, choices and key retained; explanation and notes reshaped.
- `q-mechanical-technical-reasoning-structural-stability-0011` [HIGH]: Curved-base self-righting is absent from the lesson; the always claim and long key are retained for a ruling. No supported renderer draws this rounded base.
- `q-biology-characteristics-of-life-0013` [HIGH]: Lesson does not teach this distinction; preserved keyed choice incorrectly requires two parents and remains longest. Explanation now qualifies self-fertilization; false sexual-bacterial claim removed from notes.
- `q-biology-genetics-and-heredity-0008` [MEDIUM]: Lesson does not teach the RNA base alphabet or T/U distinction. Stem, choices, and key preserved; explanation and notes now follow the required shape.
- `q-biology-genetics-and-heredity-0013` [MEDIUM]: Lesson does not teach the RNA base alphabet or T/U distinction. Stem, choices, and key preserved; explanation and notes now follow the required shape.
- `q-biology-human-anatomy-physiology-0008` [MEDIUM]: Lesson names urea but does not teach its protein-breakdown origin. Stem, choices, and key preserved; explanation and notes corrected.
- `q-biology-human-anatomy-physiology-0015` [MEDIUM]: Lesson names heart chambers but does not teach receiving versus pumping roles. Stem, choices, and key preserved; explanation and notes reshaped.
- `q-earth-science-astronomy-earths-motions-0012` [MEDIUM]: Lesson does not name Polaris. Stem, choices, key, and longest-answer cue preserved; explanation/notes corrected. Source: https://science.nasa.gov/solar-system/what-is-the-north-star-and-how-do-you-find-it/
- `q-earth-science-astronomy-fossils-and-geologic-time-0002` [HIGH]: Lesson does not teach fossil preservation by rock-formation conditions. Stem/choices/key preserved; original explanation wrongly excluded every metamorphosed fossil.
- `q-earth-science-astronomy-fossils-and-geologic-time-0003` [MEDIUM]: Lesson title names stratigraphy but the teaching text does not define the discipline; stem/choices/key preserved, including weak Paleontology dating label.
- `q-earth-science-astronomy-fossils-and-geologic-time-0014` [MEDIUM]: Lesson does not teach the complete eon-era-period-epoch hierarchy; stem/choices/key preserved.
- `q-earth-science-astronomy-fossils-and-geologic-time-0016` [MEDIUM]: Lesson does not teach Paleozoic first-fish, land-plant, or reptile history; stem/choices/key and length cue preserved.
- `q-earth-science-astronomy-fossils-and-geologic-time-0018` [MEDIUM]: Lesson does not teach the human-evolution/current-era part of this item; stem/choices/key preserved.
- `q-earth-science-astronomy-fossils-and-geologic-time-0021` [HIGH]: Lesson lacks early-fish/Paleozoic teaching; isotope clock unspecified and not necessarily layer-deposition age. Stem/choices/key and longest cue preserved.
- `q-earth-science-astronomy-heavenly-bodies-0015` [MEDIUM]: Halley's period is accurate per NASA but absent from the lesson; stem, choices, key preserved.
- `q-earth-science-astronomy-layers-of-the-earth-0006` [MEDIUM]: Magnetic field generation is not taught; stem, choices, key preserved; overlaps item 0014.
- `q-earth-science-astronomy-layers-of-the-earth-0014` [MEDIUM]: Global field generation absent from lesson; stem, choices, key preserved; duplicate of 0006 and longest-answer cue retained.
- `q-earth-science-astronomy-minerals-and-rocks-0003` [MEDIUM]: Mohs scale is not taught; stem, choices, key preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0004` [MEDIUM]: Scratch hardness tests are not taught; stem, choices, key preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0005` [MEDIUM]: Streak is not taught; stem, choices, key preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0006` [MEDIUM]: Pyrite/streak tests are not taught; stem, choices, key preserved, including longest-answer cue.
- `q-earth-science-astronomy-minerals-and-rocks-0007` [MEDIUM]: Luster is not taught; stem, choices, key preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0008` [MEDIUM]: Cleavage/fracture are not taught; stem, choices, key preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0018` [HIGH]: Hardness/streak absent from lesson; equal nominal reference hardness makes scratch bounds inconsistent; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0002` [HIGH]: History is untaught; 1927 expanding-universe work is conflated with 1931 primeval-atom proposal; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0003` [MEDIUM]: Named historical discovery is untaught; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0007` [HIGH]: History is untaught; retained key conflates 1927 expansion work with later Big Bang origin proposal; overlaps 0002.
- `q-earth-science-astronomy-plate-tectonics-0003` [HIGH]: Named/date history untaught; 1959 date is unsupported by checked USGS chronology (model 1960, publication 1962); stem, choices, key preserved.
- `q-earth-science-astronomy-plate-tectonics-0012` [MEDIUM]: Arrival order appears in lesson figure, but solid/liquid transmission is untaught; stem, choices, key preserved.
- `q-earth-science-astronomy-plate-tectonics-0013` [MEDIUM]: Solid/liquid transmission is untaught; stem, choices, key preserved.
- `q-earth-science-astronomy-plate-tectonics-0014` [MEDIUM]: Wave-transmission properties untaught; stem, choices, key preserved; overlap with 0012/0013 and answer-length cue retained.
- `q-earth-science-astronomy-plate-tectonics-0017` [MEDIUM]: Hotspot volcanism is untaught; stem, choices, key preserved, including longest-answer cue.
- `q-earth-science-astronomy-plate-tectonics-0018` [MEDIUM]: Density contrast as a subduction cause is untaught; stem, choices, key preserved, including answer-length cue.
- `q-earth-science-astronomy-plate-tectonics-0019` [MEDIUM]: Core-state seismology is untaught; stem, choices, key preserved; duplicates layer lesson and retains answer-length cue.
- `q-earth-science-astronomy-plate-tectonics-0020` [MEDIUM]: Hotspots and collision landforms are not fully taught; stem, choices, key preserved, including answer-length cue.

## Every original HIGH finding

These rows record what the authors found before correction. Status shows whether the item was corrected or protected for a decision.

- `q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0002` [CORRECTED]: Explanation wrongly cited Section 5(b); corrected to 5(c).
- `q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0003` [CORRECTED]: Explanation wrongly cited Section 5(c); corrected to 5(b).
- `q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0005` [CORRECTED]: Original answer omitted the essential no-favor condition.
- `q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0007` [CORRECTED]: Explanation wrongly cited Section 7(c); corrected to 7(b)(3).
- `q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0013` [CORRECTED]: Explanation wrongly cited Section 7(d); corrected to 7(c).
- `q-code-of-conduct-ra-6713-penalties-and-enforcement-0008` [CORRECTED]: Original wording omitted proof in a proper administrative proceeding.
- `q-code-of-conduct-ra-6713-penalties-and-enforcement-0011` [NEEDS AEDWON]: Lesson does not teach CSC procedure; stem attributes rule to Section 11 instead of Section 12.
- `q-code-of-conduct-ra-6713-penalties-and-enforcement-0015` [CORRECTED]: Original stem implied all Section 11 violations carry imprisonment; offense now specified.
- `q-code-of-conduct-ra-6713-statements-of-assets-and-divestment-0008` [CORRECTED]: Original stem omitted the ongoing-investigation exception to destruction.
- `q-code-of-conduct-ra-6713-statements-of-assets-and-divestment-0011` [CORRECTED]: Original non-executive wording could include regional or judicial officials with other repositories.
- `q-code-of-conduct-ra-6713-statements-of-assets-and-divestment-0013` [NEEDS AEDWON]: Lesson does not teach university-specific routing; blanket wording overlooks category/location distinctions.
- `q-philippine-constitution-accountability-and-impeachment-0010` [NEEDS AEDWON]: Lesson lists but does not define grounds; betrayal of public trust can also fit the unqualified stem.
- `q-philippine-constitution-accountability-and-impeachment-0011` [NEEDS AEDWON]: Lesson does not define treason; betrayal of public trust can also fit the unqualified stem.
- `q-philippine-constitution-bill-of-rights-0005` [CORRECTED]: Original stem broadly implied any state alteration of contractual rights is prohibited.
- `q-grammar-and-structure-pronoun-antecedent-agreement-0001` [CORRECTED]: More than one pronoun was defensible without a stated pronoun or collective-reference convention.
- `q-grammar-and-structure-pronoun-antecedent-agreement-0005` [CORRECTED]: More than one pronoun was defensible without a stated pronoun or collective-reference convention.
- `q-grammar-and-structure-pronoun-antecedent-agreement-0006` [CORRECTED]: More than one pronoun was defensible without a stated pronoun or collective-reference convention.
- `q-grammar-and-structure-punctuation-and-capitalization-0002` [CORRECTED]: Unstated style or collective-reference convention made another answer defensible.
- `q-grammar-and-structure-punctuation-and-capitalization-0004` [CORRECTED]: Unstated style or collective-reference convention made another answer defensible.
- `q-grammar-and-structure-punctuation-and-capitalization-0017` [CORRECTED]: Unstated style or collective-reference convention made another answer defensible.
- `q-grammar-and-structure-subject-verb-agreement-0001` [CORRECTED]: Past "barked" was also grammatical because every morning did not specify present time.
- `q-grammar-and-structure-tenses-and-voice-0005` [CORRECTED]: Key treated a possible simple-past form or a tense shift as wrong without a sufficient stated timeline or form requirement.
- `q-grammar-and-structure-tenses-and-voice-0012` [CORRECTED]: Key treated a possible simple-past form or a tense shift as wrong without a sufficient stated timeline or form requirement.
- `q-language-application-error-identification-0008` [CORRECTED]: The unspecified formal convention treated a grammatical simple-past sequence as requiring correction.
- `q-language-application-paragraph-organization-0005` [CORRECTED]: Unattributed scientific study and specific results; also more than one plausible placement of methods and findings.
- `q-language-application-paragraph-organization-0008` [CORRECTED]: Another offered order was defensible; the key relied on an unstated preferred opening or chronology.
- `q-language-application-paragraph-organization-0010` [CORRECTED]: Another offered order was defensible; the key relied on an unstated preferred opening or chronology.
- `q-language-application-paragraph-organization-0011` [CORRECTED]: Failure conditions could defensibly open before the general topic; added a backward reference. Context checked against https://www.energy.gov/sites/default/files/2024-05/EED_2827_FIG_SafetyStrategy%20240505v2.pdf
- `q-language-application-paragraph-organization-0012` [CORRECTED]: Another offered order was defensible; the key relied on an unstated preferred opening or chronology.
- `q-language-application-paragraph-organization-0013` [CORRECTED]: Resource introduction could precede the heat-transfer explanation in another offered order. Strengthened reference; verified source scope: https://www.eia.gov/energyexplained/geothermal/index.php
- `q-language-application-paragraph-organization-0014` [CORRECTED]: Another offered order was defensible; the key relied on an unstated preferred opening or chronology.
- `q-language-application-paragraph-organization-0015` [CORRECTED]: Another offered order was defensible; the key relied on an unstated preferred opening or chronology.
- `q-language-application-sentence-completion-0006` [CORRECTED]: Several offered pairs could fit clear but mutually conflicting statements.
- `q-vocabulary-idioms-and-figures-of-speech-0005` [CORRECTED]: Broad classification also allowed a hyperbolic reading; narrowed the stem to the direct comparison.
- `q-vocabulary-idioms-and-figures-of-speech-0009` [CORRECTED]: Broad wording also allowed hyperbole; narrowed the target to the contradictory word pair.
- `q-vocabulary-spelling-rules-0010` [CORRECTED]: The old mispsell note falsely claimed an added consonant; it actually transposes s and p.
- `q-algebra-algebraic-expressions-0007` [CORRECTED]: Both displayed lines were wrong; the stem did not ask for the first error.
- `q-algebra-algebraic-expressions-0012` [CORRECTED]: Both displayed results were wrong; the stem did not specify the first error.
- `q-algebra-quadratic-equations-0008` [CORRECTED]: Complex includes real numbers; the complex-root choice could also describe the repeated real roots.
- `q-algebra-systems-of-equations-0006` [CORRECTED]: Two supposedly wrong ordered pairs also solved the system; now asks for the number of solutions.
- `q-algebra-systems-of-equations-0010` [CORRECTED]: Best method was subjective and graphing was defensible; now tests a substitution step.
- `q-arithmetic-number-sense-prime-factorization-gcf-lcm-0014` [CORRECTED]: Without requiring the maximum package count, one package and one trip were valid; added the missing grouping condition.
- `q-arithmetic-number-sense-prime-factorization-gcf-lcm-0015` [CORRECTED]: Fare collection per round and counting the endpoint were unstated; defined completed-round earnings to remove alternate readings.
- `q-arithmetic-number-sense-properties-of-real-numbers-0015` [CORRECTED]: Wrong key: the y coefficients sum to 9-2+5=12, not 14. Correct choice and mistaken distractor derivations fixed.
- `q-arithmetic-number-sense-sequences-and-series-0006` [CORRECTED]: The sequence type was unstated; arithmetic was required for the marked answer.
- `q-arithmetic-number-sense-sequences-and-series-0009` [CORRECTED]: The mean type was unstated; specified arithmetic means to exclude geometric means.
- `q-geometry-basic-geometric-concepts-0012` [VERIFIED]: Explanation falsely said using three times the complement gives thirty degrees; it gives forty-five. Removed the wrong-choice discussion.
- `q-geometry-logic-and-reasoning-0005` [CORRECTED]: A distractor was a true contrapositive of a premise and therefore also followed logically; replaced it with a nonvalid partial negation.
- `q-geometry-parallel-perpendicular-lines-0009` [CORRECTED]: Endpoint labels did not determine whether the angles were alternate or same-side interior; stated the intended alternate pair.
- `q-geometry-parallel-perpendicular-lines-0012` [CORRECTED]: The inclination direction was ambiguous, allowing different crossing angles; specified that both transversals rise left to right.
- `q-geometry-quadrilaterals-and-polygons-0006` [VERIFIED]: The old note falsely said a pentagon has interior angles larger than 144 degrees; a regular pentagon has 108-degree angles.
- `q-geometry-triangles-0001` [CORRECTED]: The old note claimed subtracting 120 from 90 gives positive 30; replaced the choice and note.
- `q-geometry-triangles-0015` [NEEDS AEDWON]: The lesson does not teach area scaling; the old 9.6 note also claimed an inverted ratio produces it, which is false. Stem, choices and key retained.
- `q-precalculus-basic-calculus-conic-sections-0002` [CORRECTED]: A circle is a special ellipse; requested the most specific type to avoid two defensible classifications.
- `q-statistics-and-probability-basic-probability-0008` [CORRECTED]: Removed an unsupported claim that Baguio weather records establish the probability.
- `q-statistics-and-probability-measures-of-variability-0006` [CORRECTED]: Replaced positive root with nonnegative root because zero SD is possible.
- `q-trigonometry-solving-right-triangles-0002` [CORRECTED]: The 125-degree note claimed supplementary subtraction, but 180-35 is 145; corrected the distractor.
- `rc-cs-ap-0006` [VERIFIED]: Source placed Mount Apo at Ormoc Bay; corrected to the coast. Mount Apo is in Mindanao (https://davaodelsur.gov.ph/tourism/mt-apo/).
- `rc-cs-ap-0007` [VERIFIED]: Source placed Mount Apo at Ormoc Bay; corrected to the coast. Mount Apo is in Mindanao (https://davaodelsur.gov.ph/tourism/mt-apo/).
- `rc-cs-ap-0008` [CORRECTED]: Source placed Mount Apo at Ormoc Bay; corrected to the coast. Mount Apo is in Mindanao (https://davaodelsur.gov.ph/tourism/mt-apo/).
- `rc-cs-ap-0009` [VERIFIED]: Source placed Mount Apo at Ormoc Bay; corrected to the coast. Mount Apo is in Mindanao (https://davaodelsur.gov.ph/tourism/mt-apo/).
- `rc-cs-ap-0010` [VERIFIED]: Source placed Mount Apo at Ormoc Bay; corrected to the coast. Mount Apo is in Mindanao (https://davaodelsur.gov.ph/tourism/mt-apo/).
- `rc-cs-ap-0011` [CORRECTED]: Question named a nonexistent passage; original source included an unsupported safety threshold.
- `rc-cs-ap-0012` [CORRECTED]: Question named a nonexistent passage; original source included an unsupported safety threshold.
- `rc-cs-ap-0013` [CORRECTED]: Question named a nonexistent passage; original source included an unsupported safety threshold.
- `rc-cs-ap-0014` [CORRECTED]: Question named a nonexistent passage; original source included an unsupported safety threshold.
- `rc-cs-ap-0015` [CORRECTED]: Question named a nonexistent passage; original source included an unsupported safety threshold.
- `rc-cs-ct-0006` [CORRECTED]: Unsupported exact cooling and cortisol claims removed; retained the park argument (https://www.epa.gov/heatislands/using-trees-and-vegetation-reduce-heat-islands).
- `rc-cs-ct-0007` [CORRECTED]: Unsupported exact cooling and cortisol claims removed; retained the park argument (https://www.epa.gov/heatislands/using-trees-and-vegetation-reduce-heat-islands).
- `rc-cs-ct-0008` [CORRECTED]: Unsupported exact cooling and cortisol claims removed; retained the park argument (https://www.epa.gov/heatislands/using-trees-and-vegetation-reduce-heat-islands).
- `rc-cs-ct-0009` [CORRECTED]: Unsupported exact cooling and cortisol claims removed; retained the park argument (https://www.epa.gov/heatislands/using-trees-and-vegetation-reduce-heat-islands).
- `rc-cs-ct-0010` [CORRECTED]: Unsupported exact cooling and cortisol claims removed; retained the park argument (https://www.epa.gov/heatislands/using-trees-and-vegetation-reduce-heat-islands).
- `rc-cs-cc-0006` [CORRECTED]: Original source omitted spinning and made an unsupported two-day dye-failure claim; revised process (https://www.nature.com/articles/24290).
- `rc-cs-cc-0007` [CORRECTED]: Original source omitted spinning and made an unsupported two-day dye-failure claim; revised process (https://www.nature.com/articles/24290).
- `rc-cs-cc-0008` [CORRECTED]: Original source omitted spinning and made an unsupported two-day dye-failure claim; revised process (https://www.nature.com/articles/24290).
- `rc-cs-cc-0009` [CORRECTED]: Original source omitted spinning and made an unsupported two-day dye-failure claim; revised process (https://www.nature.com/articles/24290).
- `rc-cs-cc-0010` [CORRECTED]: Original source omitted spinning and made an unsupported two-day dye-failure claim; revised process (https://www.nature.com/articles/24290).
- `rc-cs-fo-0001` [CORRECTED]: Unsupported real municipal figures relabeled as fictional scenario records; removed wrong-choice discussion.
- `rc-cs-fo-0002` [CORRECTED]: Unsupported real municipal figures relabeled as fictional scenario records; removed wrong-choice discussion.
- `rc-cs-fo-0003` [CORRECTED]: Unsupported real municipal figures relabeled as fictional scenario records; removed wrong-choice discussion.
- `rc-cs-fo-0004` [CORRECTED]: Unsupported real municipal figures relabeled as fictional scenario records; removed wrong-choice discussion.
- `rc-cs-fo-0005` [CORRECTED]: Unsupported real municipal figures relabeled as fictional scenario records; removed wrong-choice discussion.
- `rc-cs-fo-0006` [CORRECTED]: Unsupported real-world figures relabeled as fictional scenario records; corrected power-versus-energy error (https://www.eia.gov/energyexplained/electricity/measuring-electricity.php).
- `rc-cs-fo-0007` [CORRECTED]: Unsupported real-world figures relabeled as fictional scenario records; corrected power-versus-energy error (https://www.eia.gov/energyexplained/electricity/measuring-electricity.php).
- `rc-cs-fo-0008` [CORRECTED]: Unsupported real-world figures relabeled as fictional scenario records; corrected power-versus-energy error (https://www.eia.gov/energyexplained/electricity/measuring-electricity.php).
- `rc-cs-fo-0009` [CORRECTED]: Unsupported real-world figures relabeled as fictional scenario records; corrected power-versus-energy error (https://www.eia.gov/energyexplained/electricity/measuring-electricity.php).
- `rc-cs-fo-0010` [CORRECTED]: Unsupported real-world figures relabeled as fictional scenario records; corrected power-versus-energy error (https://www.eia.gov/energyexplained/electricity/measuring-electricity.php).
- `rc-cs-ic-0006` [CORRECTED]: Original conclusion exceeded the evidence: rice remains did not prove local farming.
- `rc-cs-ic-0007` [CORRECTED]: Original conclusion exceeded the evidence: tokens did not establish primary trade transactions.
- `rc-cs-ic-0008` [CORRECTED]: Original conclusion exceeded the evidence: post holes did not establish permanent homes.
- `rc-cs-ic-0010` [CORRECTED]: Original conclusion exceeded the evidence: artifacts did not prove a settled trade network.
- `rc-cs-ic-0011` [CORRECTED]: Original conclusion exceeded the evidence: combined reforms did not prove a primary cause of erratic driving.
- `rc-cs-ic-0013` [CORRECTED]: Original conclusion exceeded the evidence: stable turnover did not establish satisfaction or lower departures.
- `rc-cs-ic-0015` [CORRECTED]: Original conclusion exceeded the evidence: combined observations did not prove causal effects or retention gains.
- `rc-cs-mi-0011` [CORRECTED]: Weak choices replaced or explanation reshaped to keep the central point clear. Original source made unverified claims about a real project; relabeled as a fictional account.
- `rc-cs-mi-0012` [NEEDS AEDWON]: Retrieving the purpose of dike openings is a detail question. Original source made unverified claims about a real project; relabeled as a fictional account.
- `rc-cs-mi-0013` [NEEDS AEDWON]: Inferring scientific methods from site selection is an inference question. Original source made unverified claims about a real project; relabeled as a fictional account.
- `rc-cs-mi-0014` [NEEDS AEDWON]: Retrieving two outcomes is a detail question. Original source made unverified claims about a real project; relabeled as a fictional account.
- `rc-cs-mi-0015` [CORRECTED]: Weak choices replaced or explanation reshaped to keep the central point clear. Original source made unverified claims about a real project; relabeled as a fictional account.
- `rc-cs-nsd-0001` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0002` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0003` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0004` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0005` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0006` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0007` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0008` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0009` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0010` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0011` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0012` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0013` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0014` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-nsd-0015` [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- `rc-cs-se-0001` [CORRECTED]: Original source had conflicting outage durations and unstated immediate ordering; clarified fictional timeline.
- `rc-cs-se-0002` [CORRECTED]: Original source had conflicting outage durations and unstated immediate ordering; clarified fictional timeline.
- `rc-cs-se-0003` [CORRECTED]: Original source had conflicting outage durations and unstated immediate ordering; clarified fictional timeline.
- `rc-cs-se-0004` [CORRECTED]: Original source had conflicting outage durations and unstated immediate ordering; clarified fictional timeline.
- `rc-cs-se-0005` [CORRECTED]: Original source had conflicting outage durations and unstated immediate ordering; clarified fictional timeline.
- `rc-cs-se-0006` [CORRECTED]: Original key inferred an actual refuge move from an instruction alone; added explicit arrival timing and removed unsupported immediacy.
- `rc-cs-se-0007` [CORRECTED]: Original key inferred an actual refuge move from an instruction alone; added explicit arrival timing and removed unsupported immediacy.
- `rc-cs-se-0008` [CORRECTED]: Original key inferred an actual refuge move from an instruction alone; added explicit arrival timing and removed unsupported immediacy.
- `rc-cs-se-0009` [CORRECTED]: Original key inferred an actual refuge move from an instruction alone; added explicit arrival timing and removed unsupported immediacy.
- `rc-cs-se-0010` [CORRECTED]: Original key inferred an actual refuge move from an instruction alone; added explicit arrival timing and removed unsupported immediacy.
- `rc-tt-eea-0001` [CORRECTED]: Original report contained unsupported real-project claims and was below the passage minimum.
- `rc-tt-eea-0002` [CORRECTED]: Original report contained unsupported real-project claims and was below the passage minimum.
- `rc-tt-eea-0003` [CORRECTED]: Original report contained unsupported real-project claims and was below the passage minimum.
- `rc-tt-eea-0004` [CORRECTED]: Original report contained unsupported real-project claims and was below the passage minimum.
- `rc-tt-eea-0005` [CORRECTED]: Original report contained unsupported real-project claims and was below the passage minimum.
- `rc-tt-eea-0006` [CORRECTED]: Institutional editorial authorship was unstated; genre rules were overgeneralized.
- `rc-tt-eea-0007` [CORRECTED]: Institutional editorial authorship was unstated; genre rules were overgeneralized.
- `rc-tt-eea-0008` [CORRECTED]: Institutional editorial authorship was unstated; genre rules were overgeneralized.
- `rc-tt-eea-0009` [CORRECTED]: Institutional editorial authorship was unstated; genre rules were overgeneralized.
- `rc-tt-eea-0010` [CORRECTED]: Institutional editorial authorship was unstated; genre rules were overgeneralized.
- `rc-tt-po-0004` [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- `rc-tt-po-0006` [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- `rc-tt-po-0007` [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- `rc-tt-po-0011` [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- `rc-tt-po-0013` [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- `rc-tt-po-0015` [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- `rc-tt-vm-0001` [CORRECTED]: Unverified public-health percentages presented as measured rates; converted to an explicitly illustrative arithmetic example.
- `rc-tt-vm-0005` [CORRECTED]: Unsupported official health-agency endorsement/contact implied by original example; changed to a classroom health-desk label.
- `q-clerical-ability-alphabetic-filing-rules-0001` [CORRECTED]: The answer changed the recorded surname Dela Cruz to Delacruz; restored its spelling and stated the rule.
- `q-clerical-ability-alphabetic-filing-rules-0003` [NEEDS AEDWON]: Business stop-word treatment is not taught; key depends on an unnamed convention and is not universal. Stem, choices and key retained.
- `q-clerical-ability-alphabetic-filing-rules-0004` [CORRECTED]: The answer respelled De la Rosa as Delarosa and presented the convention as universal.
- `q-clerical-ability-alphabetic-filing-rules-0005` [CORRECTED]: Claimed city is the universal tie-breaker; supplied a city-next rule so the key is defensible.
- `q-clerical-ability-alphabetic-filing-rules-0009` [NEEDS AEDWON]: Abbreviation expansion is not taught; the key depends on an unnamed system and is not universal. Stem, choices and key retained.
- `q-clerical-ability-alphabetic-filing-rules-0011` [NEEDS AEDWON]: Government-agency jurisdiction ordering is not taught; the key depends on an unnamed convention. Stem, choices and key retained.
- `q-logical-verbal-reasoning-syllogisms-and-deductive-logic-0016` [CORRECTED]: The old note said premise order determines validity; reordering the same premises does not change entailment. Removed a solution-length choice and corrected the note.
- `q-logical-verbal-reasoning-truth-tables-propositional-logic-0012` [CORRECTED]: Original note claimed regrouping changed the value even though both groupings were true under its inputs; changed inputs to expose the grouping difference.
- `q-logical-verbal-reasoning-word-analogies-0008` [CORRECTED]: Warm was defensible under an increasing-temperature relation; specified intensity of each named quality.
- `q-logical-verbal-reasoning-word-analogies-0012` [CORRECTED]: Original unfinished book-to-blank analogy did not supply a coherent completion and its explanation confused preserving with reversing direction.
- `q-logical-verbal-reasoning-word-analogies-0013` [CORRECTED]: Waltz can be a type of music as well as a dance; fixed the intended sense so only one choice fits.
- `q-logical-verbal-reasoning-word-analogies-0015` [CORRECTED]: Cow, branch was also correct; its old note admitted the key merely expected leaf. Replaced it with an inverted whole relation. The source lesson has the same ambiguous example.
- `q-logical-verbal-reasoning-word-analogies-0016` [CORRECTED]: Rooster was defensible for a male chick; key/lock and ignition/engine also used imprecise actions. Replaced the double analogy with specific relations.
- `q-mechanical-technical-reasoning-fluid-pressure-0002` [CORRECTED]: Explanation falsely said open connected vessels always have equal levels; specified the required liquid and surface-pressure conditions.
- `q-mechanical-technical-reasoning-fluid-pressure-0004` [CORRECTED]: Missing figure and self-contained conditions; faster-always-means-lower-pressure was overbroad.
- `q-mechanical-technical-reasoning-fluid-pressure-0008` [CORRECTED]: Missing figure and conditions; slower-flow-always-means-higher-pressure was overbroad.
- `q-mechanical-technical-reasoning-fluid-pressure-0010` [CORRECTED]: Squeezing a nozzle does not by itself hold flow rate fixed; replaced that unsupported guarantee with a defined continuity calculation.
- `q-mechanical-technical-reasoning-fluid-pressure-0011` [CORRECTED]: Repeated a pressure comparison and overstated faster-always-lower; changed to the kinetic-energy term.
- `q-mechanical-technical-reasoning-fluid-pressure-0012` [CORRECTED]: Stem described round, triangular, irregular, and unequal-height vessels that this renderer does not draw; replaced with an equilibrium change supported by the figure.
- `q-mechanical-technical-reasoning-fluid-pressure-0013` [CORRECTED]: Pressure conclusion lacked the same-height ideal-flow assumptions and answer contained a long solution.
- `q-mechanical-technical-reasoning-fluid-pressure-0014` [CORRECTED]: Original combined settled reservoirs with active connecting flow, without a driving condition or drawable combined figure; replaced with a single supported Bernoulli conservation item.
- `q-mechanical-technical-reasoning-gear-rotations-0007` [CORRECTED]: Figure was pending despite an existing supported spoke layout; activated it and removed a stop-motion throwaway.
- `q-mechanical-technical-reasoning-gear-rotations-0008` [CORRECTED]: Repeated 0001's endpoint answer and claimed all meshes always reverse; changed to a report-consistency check for explicit external meshes.
- `q-mechanical-technical-reasoning-gear-rotations-0009` [CORRECTED]: Original claimed direction depends only on meshing parity for every gear geometry; specified external gears and separated the effects of tooth count and connection.
- `q-mechanical-technical-reasoning-gear-rotations-0011` [CORRECTED]: Figure was pending and the original prediction lacked a displayed center direction; supplied the supported layout and made the comparison definite.
- `q-mechanical-technical-reasoning-gear-rotations-0015` [CORRECTED]: Unequal-size spoke diagram was pending; the spoke painter ignores teeth sizing. Reframed as a supported unequal-size row and removed the solution-length answer.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0001` [CORRECTED]: Mass was labeled as force, and ideal assumptions were missing.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0002` [CORRECTED]: Mass-force units were wrong; added supporting-segment and ideal conditions.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0003` [CORRECTED]: Original assumed two movable pulleys guarantee advantage four and used mass as force.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0004` [CORRECTED]: Replaced kg-force ambiguity with newtons and perpendicular static conditions.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0005` [CORRECTED]: Repeated forward balance calculation; added torque comparison and fixed force units.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0006` [CORRECTED]: Removed dependence on a previous shuffled question and corrected force units.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0007` [CORRECTED]: Repeated earlier comparison and referred to another question; replaced with minimum-arm design.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0008` [CORRECTED]: Original made an overbroad claim about all movable pulleys and used kg as force.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0009` [CORRECTED]: Replaced yes/no throwaways with exact distance slips and fixed mass-force wording.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0011` [CORRECTED]: Changed mass-force units and stated weightless perpendicular balance conditions.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0012` [CORRECTED]: Corrected force units and specified balance assumptions.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0013` [CORRECTED]: Original asserted three movable pulleys always yield advantage eight without rope routing.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0014` [CORRECTED]: Original combined machinery that its single-lever figure could not represent; replaced with static work.
- `q-mechanical-technical-reasoning-pulleys-and-levers-0015` [CORRECTED]: Original wrongly claimed equal-advantage ideal machines require different travel and showed mismatched arms.
- `q-mechanical-technical-reasoning-springs-and-weights-0008` [CORRECTED]: Original falsely called fixed linear increments invalid; rounding was the actual error.
- `q-mechanical-technical-reasoning-structural-stability-0003` [CORRECTED]: Original centered-line choice also satisfied the correct condition; removed overlapping answers.
- `q-mechanical-technical-reasoning-structural-stability-0006` [CORRECTED]: Original explanation applied a static gravity-line rule to an accelerating truck.
- `q-mechanical-technical-reasoning-structural-stability-0011` [NEEDS AEDWON]: Curved-base self-righting is absent from the lesson; the always claim and long key are retained for a ruling. No supported renderer draws this rounded base.
- `q-mechanical-technical-reasoning-structural-stability-0012` [CORRECTED]: Original used wheelbase for track width and a static explanation for dynamic rollover.
- `q-mechanical-technical-reasoning-structural-stability-0014` [CORRECTED]: Original treated a tilted box as retaining a three-meter contact region and misidentified its pivot boundary.
- `q-spatial-abstract-reasoning-figure-grouping-0002` [CORRECTED]: Several original choices were defensible under different rules; specified reflection symmetry.
- `q-spatial-abstract-reasoning-figure-grouping-0003` [CORRECTED]: Boolean through value was unsupported; off-center lines still intersect and do not make the claimed three regions.
- `q-spatial-abstract-reasoning-figure-grouping-0005` [CORRECTED]: Original allowed alternative side-count and equality rules; made the boundary criterion explicit.
- `q-spatial-abstract-reasoning-figure-grouping-0007` [CORRECTED]: Missing star and scalene figure could not be drawn; used supported marked-square symmetry.
- `q-spatial-abstract-reasoning-figure-grouping-0008` [CORRECTED]: Stem called a triangle a quadrilateral and claimed sizes absent from the figure.
- `q-spatial-abstract-reasoning-figure-grouping-0009` [CORRECTED]: Missing figure and unsupported star outline replaced with drawn internal line grouping.
- `q-spatial-abstract-reasoning-figure-grouping-0010` [CORRECTED]: Stem called the drawn rhombus a kite; replaced verbose yes/no claims with testable grouping rules.
- `q-spatial-abstract-reasoning-figure-grouping-0011` [CORRECTED]: Missing shading figure activated with existing figure-series fill fields.
- `q-spatial-abstract-reasoning-figure-grouping-0012` [CORRECTED]: Original stem described five figures and three-region cuts but its four drawn shapes had different regions.
- `q-spatial-abstract-reasoning-figure-grouping-0013` [CORRECTED]: Original referred to an absent fifth kite; changed to even-side grouping.
- `q-spatial-abstract-reasoning-figure-grouping-0014` [CORRECTED]: Missing edge-dot figure activated using supported visible arrow fields.
- `q-spatial-abstract-reasoning-figure-matrices-0001` [CORRECTED]: Original rotation was absent from the figure and unmarked square rotations made three choices visually equivalent.
- `q-spatial-abstract-reasoning-figure-matrices-0004` [CORRECTED]: Key said black for a blank in the white middle column; solved from the actual grid and fixed.
- `q-spatial-abstract-reasoning-figure-matrices-0005` [CORRECTED]: Original grid omitted union, had the wrong outlines, and radial segments could not form the claimed full X.
- `q-spatial-abstract-reasoning-figure-matrices-0006` [CORRECTED]: Renderer draws fill from the bottom; original two identical lower fills could not show complementary halves.
- `q-spatial-abstract-reasoning-figure-matrices-0007` [CORRECTED]: Original claimed a right-side dot but the supported field drew a top-right corner dot.
- `q-spatial-abstract-reasoning-figure-matrices-0009` [CORRECTED]: Original duplicated union question while its figure showed an unrelated diagonal; changed to feature overlap.
- `q-spatial-abstract-reasoning-figure-matrices-0010` [CORRECTED]: Original confused adding a line with rotating the shape; changed to a marked reflection across different outlines.
- `q-spatial-abstract-reasoning-figure-matrices-0013` [CORRECTED]: The original stem and key called a line-angle field a shape rotation; distinguished the drawn feature.
- `q-spatial-abstract-reasoning-figure-matrices-0014` [CORRECTED]: Original claimed absent fill and union fields; black fill would also hide black rays.
- `q-spatial-abstract-reasoning-figure-series-0004` [CORRECTED]: Undefined extra-large state was unsupported; made the three-size cycle explicit in the figure.
- `q-spatial-abstract-reasoning-figure-series-0008` [CORRECTED]: Undefined extra-small continuation replaced with a shown reversing size cycle.
- `q-spatial-abstract-reasoning-figure-series-0009` [CORRECTED]: Original repeated 0004 and required an undefined size; replaced with independent dot and size tracks.
- `q-spatial-abstract-reasoning-figure-series-0011` [CORRECTED]: Original circle fill fields described height fractions as area percentages and supplied an unshown cycle; used square fills and displayed repetition.
- `q-spatial-abstract-reasoning-figure-series-0012` [CORRECTED]: Triangle dot route was described in the wrong rotation direction; replaced repeated corner motion with outline cycling.
- `q-spatial-abstract-reasoning-figure-series-0013` [CORRECTED]: Original stem claimed absent rotation fields and undefined extra-large size; rebuilt with supported independent tracks.
- `q-spatial-abstract-reasoning-mental-rotation-3d-visualization-0002` [CORRECTED]: Drawing was a valid net although the stem and key described an invalid one.
- `q-spatial-abstract-reasoning-mental-rotation-3d-visualization-0006` [CORRECTED]: Unqualified claim of circular shadows from any light direction was false for tilted screens or point sources.
- `q-spatial-abstract-reasoning-mental-rotation-3d-visualization-0011` [CORRECTED]: Key incorrectly named the topmost column square; the second-from-top center is opposite the bottommost square.
- `q-spatial-abstract-reasoning-mental-rotation-3d-visualization-0014` [CORRECTED]: Extra square was drawn diagonally beside the center instead of at the right arm end; explanation gave an unsafe folding rule.
- `q-spatial-abstract-reasoning-paper-folding-and-cutting-0001` [CORRECTED]: Key gave two openings despite the stem explicitly limiting the cut to one layer; fixed to one.
- `q-spatial-abstract-reasoning-paper-folding-and-cutting-0005` [CORRECTED]: The renderer edge cut is inset and the original claim of one notch per outer edge was false.
- `q-spatial-abstract-reasoning-paper-folding-and-cutting-0006` [CORRECTED]: Original specified a diamond that the actual triangular cut does not justify; used connectedness without an invented outline.
- `q-spatial-abstract-reasoning-paper-folding-and-cutting-0007` [CORRECTED]: Original asserted an unconditional eight-hole rule and lacked a diagram.
- `q-spatial-abstract-reasoning-paper-folding-and-cutting-0009` [CORRECTED]: Removed the false implication that perpendicular reflections never commute; asked about physically reversing the fold sequence.
- `q-spatial-abstract-reasoning-paper-folding-and-cutting-0010` [CORRECTED]: Original four-fold stem contradicted the three-fold renderer; replaced with a supported crease-joining case.
- `q-spatial-abstract-reasoning-paper-folding-and-cutting-0012` [CORRECTED]: Original stem placed the cut at the outer corner while its corner field drew it near the fold intersection.
- `q-spatial-abstract-reasoning-paper-folding-and-cutting-0013` [CORRECTED]: Original compared two packets with only one depicted and asserted hole counts without crease conditions.
- `q-spatial-abstract-reasoning-paper-folding-and-cutting-0014` [CORRECTED]: Stem required an unsupported diagonal fold and triangular cut absent from the diagram.
- `q-verbal-logic-assumptions-and-conclusions-0001` [CORRECTED]: Achievable completion is not necessary for a conditional policy to be true; corrected the key using the lesson's stated distinction.
- `q-verbal-logic-assumptions-and-conclusions-0006` [CORRECTED]: Presence alone did not prove compliance with a permission rule; added the missing compliance premise.
- `q-verbal-logic-assumptions-and-conclusions-0008` [CORRECTED]: The old answer merely repeated the causal claim as an assumption. Replaced the asserted percentage with a causal-inference argument and a necessary unstated link.
- `q-verbal-logic-assumptions-and-conclusions-0011` [CORRECTED]: A permission rule alone did not establish that an actual approval was authorized; made compliance explicit and removed unrelated cost/location guesses.
- `q-verbal-logic-assumptions-and-conclusions-0012` [CORRECTED]: The old asserted bill decrease did not require replacement of grid consumption; other mechanisms such as export credits were possible. Specified the replacement argument.
- `q-biology-botany-0002` [VERIFIED]: Explanation incorrectly described all xylem cells as dead.
- `q-biology-botany-0003` [VERIFIED]: Explanation incorrectly treated all xylem cells as dead and discussed a wrong choice.
- `q-biology-botany-0006` [CORRECTED]: Explanation said all xylem cells were dead; other choices were implausible.
- `q-biology-botany-0010` [VERIFIED]: Wrong-choice note incorrectly said roots show negative gravitropism.
- `q-biology-botany-0011` [CORRECTED]: Original stem described both negative phototropism and positive gravitropism; explanation overgeneralized root light responses.
- `q-biology-botany-0012` [CORRECTED]: Marked answer and explanation overgeneralized negative root phototropism.
- `q-biology-cell-biology-0001` [CORRECTED]: Explanation falsely said mitochondria do not hold DNA.
- `q-biology-cell-biology-0008` [CORRECTED]: Original stem and explanation wrongly called walls, chloroplasts, and vacuoles plant-only across all life.
- `q-biology-cell-biology-0009` [CORRECTED]: Explanation incorrectly described the structures as unique to plants across all organisms.
- `q-biology-cell-biology-0016` [CORRECTED]: Explanation said all active transport directly needs ATP; stem left passive permeability unstated.
- `q-biology-cellular-metabolism-0007` [CORRECTED]: Original stem wrongly attributed all oxygen animals breathe to plants, excluding algae and cyanobacteria.
- `q-biology-cellular-metabolism-0008` [CORRECTED]: Original correct choice could read as saying animal cells also perform photosynthesis.
- `q-biology-cellular-metabolism-0010` [CORRECTED]: Explanation incorrectly said mitochondria occur in nearly all cells and restricted chloroplasts to plant-type cells.
- `q-biology-cellular-metabolism-0012` [CORRECTED]: Original key and explanation treated the pathways as exact mirror-image reactions.
- `q-biology-cellular-reproduction-0002` [CORRECTED]: Original broad sperm-production stem could include mitosis; explanation restricted all meiosis to gamete production.
- `q-biology-cellular-reproduction-0003` [CORRECTED]: Original explanation claimed meiosis always produces four daughter cells, ignoring unequal oogenesis.
- `q-biology-cellular-reproduction-0009` [CORRECTED]: Original question and explanation treated mitosis as identical to division into daughter cells.
- `q-biology-cellular-reproduction-0012` [CORRECTED]: Original stem confused an abbreviated description with proof of missing biological stages.
- `q-biology-characteristics-of-life-0001` [CORRECTED]: Original made-of wording also allowed molecules as a defensible answer.
- `q-biology-characteristics-of-life-0007` [CORRECTED]: Original note falsely said viruses lack membranes; many viruses have envelopes.
- `q-biology-characteristics-of-life-0012` [CORRECTED]: Original gravity distractor implied gravity cannot be a biological stimulus; plant gravitropism shows otherwise.
- `q-biology-characteristics-of-life-0013` [NEEDS AEDWON]: Lesson does not teach this distinction; preserved keyed choice incorrectly requires two parents and remains longest. Explanation now qualifies self-fertilization; false sexual-bacterial claim removed from notes.
- `q-biology-characteristics-of-life-0014` [CORRECTED]: Original item treated every property as mandatory in each individual and assigned evolution to one organism.
- `q-biology-ecology-0008` [CORRECTED]: Wrong note falsely said 1 kilocalorie came from three 10% steps; item repeated the same forward calculation.
- `q-biology-ecology-0011` [CORRECTED]: Explanation incorrectly called nitrate a direct product of fixation; distractors were unrelated.
- `q-biology-ecology-0012` [CORRECTED]: Correct choice and explanation incorrectly called nitrate a direct fixation product.
- `q-biology-ecology-0018` [CORRECTED]: Original stem and explanation overstated a four-or-five-level limit not taught as a fixed rule.
- `q-biology-evolution-0001` [CORRECTED]: Original stem and explanation incorrectly dated the first proposal of natural selection to 1859.
- `q-biology-evolution-0003` [CORRECTED]: Original imposed a nonrequired causal order and falsely said inheritance follows selection.
- `q-biology-evolution-0006` [CORRECTED]: Original explanation made isolated populations inevitably form separate species through selection alone.
- `q-biology-evolution-0007` [CORRECTED]: Original explanation reduced finch diversification to an absolute one-island geographic-speciation story.
- `q-biology-evolution-0008` [CORRECTED]: Original had implausible distractors and claimed selection never changes an individual’s traits during life.
- `q-biology-evolution-0011` [CORRECTED]: Original treated resistance as necessarily predating exposure without evidence; item duplicated pesticide scenario.
- `q-biology-evolution-0012` [CORRECTED]: Original explanation treated selection as the sole mechanism leading to speciation.
- `q-biology-evolution-0014` [CORRECTED]: Original explanation made speciation a guaranteed result of geographic isolation.
- `q-biology-genetics-and-heredity-0010` [CORRECTED]: Original stem lacked model assumptions and explanation falsely ruled out all dominant inheritance.
- `q-biology-genetics-and-heredity-0014` [CORRECTED]: Original duplicate pedigree item falsely said unaffected parents cannot have a child with a dominant condition.
- `q-biology-human-anatomy-physiology-0004` [CORRECTED]: Original note wrongly said all skeletal muscle requires conscious signaling.
- `q-biology-human-anatomy-physiology-0009` [CORRECTED]: Original denied specificity in innate defenses and used implausible no-response distractor.
- `q-biology-human-anatomy-physiology-0014` [CORRECTED]: Original claimed only adaptive immunity builds memory without qualifying antigen-specific clonal memory.
- `q-biology-taxonomy-and-classification-0003` [CORRECTED]: Original presented Protista as a settled modern kingdom and used rank-name filler.
- `q-biology-taxonomy-and-classification-0004` [CORRECTED]: Original key called leo the whole species name while another choice correctly named the binomial.
- `q-biology-taxonomy-and-classification-0005` [CORRECTED]: Original falsely credited Linnaeus with simply creating all of binomial nomenclature.
- `q-biology-taxonomy-and-classification-0006` [CORRECTED]: Original claimed a scientific name always refers to exactly the same species without revision.
- `q-biology-taxonomy-and-classification-0008` [CORRECTED]: Original called the specific epithet alone the species name and used British spelling in notes.
- `q-biology-taxonomy-and-classification-0009` [CORRECTED]: Original explanation claimed every domain contains several kingdoms and treated Protista as settled.
- `q-biology-taxonomy-and-classification-0011` [CORRECTED]: Original falsely said the whole species name is lowercase.
- `q-biology-taxonomy-and-classification-0013` [CORRECTED]: Original treated count of shared ranks as an exact measure of relatedness.
- `q-chemistry-acids-bases-ph-0001` [CORRECTED]: Original applied the pH-7 divider without a temperature condition.
- `q-chemistry-acids-bases-ph-0002` [CORRECTED]: Original claimed pH 7 is always neutral without stating temperature.
- `q-chemistry-acids-bases-ph-0003` [CORRECTED]: Original applied the pH-7 divider without a temperature condition.
- `q-chemistry-acids-bases-ph-0011` [CORRECTED]: Original repeated the pH-ratio scenario and oversimplified acidity to concentration alone.
- `q-chemistry-acids-bases-ph-0013` [CORRECTED]: Original marked choice falsely claimed every neutralization produces salt and water.
- `q-chemistry-acids-bases-ph-0014` [CORRECTED]: Original explanation treated salt formation as ions combining; choices used safety and no-ion filler.
- `q-chemistry-atomic-structure-0008` [CORRECTED]: Original isotope distractor falsely implied changing proton count creates isotopes; item duplicated electron-change classification.
- `q-chemistry-basic-organic-chemistry-0007` [CORRECTED]: Original described saturation as maximum hydrogen filling, excluding saturated cycloalkanes.
- `q-chemistry-basic-organic-chemistry-0008` [CORRECTED]: Original OH-only wording could include other hydroxyl-containing classes, including carboxylic acids.
- `q-chemistry-basic-organic-chemistry-0010` [CORRECTED]: Original keyed wording treated functional groups as the only determinant of chemical behavior.
- `q-chemistry-basic-organic-chemistry-0011` [CORRECTED]: Original saturation definition wrongly required every possible position to hold hydrogen.
- `q-chemistry-basic-organic-chemistry-0013` [CORRECTED]: Original stated longest-chain selection as a universal IUPAC rule without limiting it to simple alkanes.
- `q-chemistry-basic-organic-chemistry-0014` [CORRECTED]: Original repeated longest-chain framing and claimed all IUPAC naming always starts with the longest chain.
- `q-chemistry-chemical-bonding-0001` [CORRECTED]: Original explanation treated every metal/nonmetal pair as necessarily ionic.
- `q-chemistry-chemical-bonding-0002` [CORRECTED]: Original explanation treated nonmetal/nonmetal bonding as a definition rather than a shortcut.
- `q-chemistry-chemical-bonding-0003` [CORRECTED]: Original note falsely required a metal and nonmetal for every ionic compound.
- `q-chemistry-chemical-bonding-0004` [CORRECTED]: Original used conflicting rigid cutoffs and excluded defensible weak polarity at the 0.4 boundary.
- `q-chemistry-chemical-bonding-0005` [CORRECTED]: Original claimed a large electronegativity difference always produces complete transfer.
- `q-chemistry-chemical-bonding-0012` [CORRECTED]: Original duplicated metal/nonmetal classification and falsely said it always gives ionic bonding.
- `q-chemistry-chemical-bonding-0014` [CORRECTED]: Original explanation treated octet completion as the main general cause and omitted lower-energy conditions.
- `q-chemistry-chemical-nomenclature-0001` [CORRECTED]: Potassium(I) bromide was an unnecessary but defensible Stock-style distractor.
- `q-chemistry-chemical-nomenclature-0006` [CORRECTED]: Nitrogen(V) oxide was a defensible alternate Stock name.
- `q-chemistry-chemical-nomenclature-0012` [CORRECTED]: Original falsely treated -ite as universally one oxygen fewer with unchanged charge.
- `q-chemistry-chemical-nomenclature-0013` [CORRECTED]: Original claimed every compound of two nonmetals always uses Greek prefixes.
- `q-chemistry-chemical-reactions-0002` [VERIFIED]: Original note falsely restricted all combustion to hydrocarbons yielding CO2 and water.
- `q-chemistry-chemical-reactions-0012` [CORRECTED]: Original explanation treated any symbolic compound swap as a real double replacement.
- `q-chemistry-gas-laws-0007` [CORRECTED]: Original described 0 K as literally no thermal energy and used 273 as exact.
- `q-chemistry-gas-laws-0008` [CORRECTED]: Original omitted fixed temperature and amount, so the result was not guaranteed.
- `q-chemistry-gas-laws-0009` [CORRECTED]: Original rejected using the ideal gas law at both states, a valid method.
- `q-chemistry-history-of-the-atom-0003` [CORRECTED]: Original nucleus-plus-orbits description also fit Bohr.
- `q-chemistry-history-of-the-atom-0004` [CORRECTED]: Original quantized-level description also fit modern quantum mechanics.
- `q-chemistry-history-of-the-atom-0005` [CORRECTED]: Original attributed the entire modern probability model to one researcher.
- `q-chemistry-history-of-the-atom-0007` [CORRECTED]: Original explanation required literal collision and used weak distractors.
- `q-chemistry-history-of-the-atom-0008` [CORRECTED]: Original note incorrectly dated the plum pudding model to 1897; correct answer was longest.
- `q-chemistry-history-of-the-atom-0010` [CORRECTED]: Original credited the modern quantum model to Schrödinger alone.
- `q-chemistry-history-of-the-atom-0011` [CORRECTED]: Original used an absolute all-particles prediction and a false charge-independence note.
- `q-chemistry-history-of-the-atom-0012` [CORRECTED]: Original generalized Bohr’s spectral success to all atoms.
- `q-chemistry-matter-0001` [VERIFIED]: Original element definition omitted the ordinary-chemical-reaction limit.
- `q-chemistry-matter-0003` [VERIFIED]: Original note claimed mixtures have no chemical bonds, an overgeneralization.
- `q-chemistry-matter-0007` [CORRECTED]: Original called the CO2 gas misty; visible dry-ice mist is condensed water droplets.
- `q-chemistry-matter-0009` [CORRECTED]: Original claimed becoming less ordered always requires absorbing energy.
- `q-chemistry-matter-0010` [CORRECTED]: Original claimed becoming more ordered always releases energy.
- `q-chemistry-matter-0013` [CORRECTED]: Original note assigned all rust the formula Fe2O3; rust composition is more complex.
- `q-chemistry-mixtures-and-separation-0001` [CORRECTED]: No visible coffee grounds did not establish molecular homogeneity; coffee can contain colloids.
- `q-chemistry-mixtures-and-separation-0007` [CORRECTED]: Original explanation wrongly said one component evaporates first alone and promised both pure liquids.
- `q-chemistry-mixtures-and-separation-0010` [CORRECTED]: Original last distractor was a defensible restatement of why ordinary filtration fails.
- `q-chemistry-mixtures-and-separation-0012` [CORRECTED]: Original falsely treated distillation as components boiling away one after another.
- `q-chemistry-mixtures-and-separation-0013` [CORRECTED]: Original claimed farther travel proves weaker paper attraction alone.
- `q-chemistry-mixtures-and-separation-0015` [CORRECTED]: Original promised safe drinking water despite unspecified dissolved contaminants and rejected a feasible reversed sequence.
- `q-chemistry-mole-concept-0005` [CORRECTED]: Original last note claimed 45 times NA produced 8.1e24; the arithmetic was wrong.
- `q-chemistry-mole-concept-0006` [CORRECTED]: Original marked answer falsely prohibited valid combined dimensional-analysis conversions.
- `q-chemistry-mole-concept-0008` [CORRECTED]: Original asserted exact numerical transfer and conflated tabulated atomic mass with a single atom.
- `q-chemistry-mole-concept-0009` [CORRECTED]: Original called 6.022e23 the full value and asserted an unsupported exam-wide rounding rule.
- `q-chemistry-mole-concept-0012` [CORRECTED]: Original repeated grams-to-entities and gave an incorrect number for molar mass times NA.
- `q-chemistry-mole-concept-0013` [CORRECTED]: Original 84 g/mol note gave arithmetic unrelated to that answer; g/mol terminology corrected.
- `q-chemistry-nuclear-chemistry-0005` [CORRECTED]: Original unspecified beta could mean beta-minus or beta-plus; mass number is exactly unchanged.
- `q-chemistry-nuclear-chemistry-0006` [VERIFIED]: Original note implied fission fragments must be roughly equal; the definition does not require that.
- `q-chemistry-nuclear-chemistry-0007` [CORRECTED]: Original described two solar hydrogen nuclei directly forming helium and claimed unqualified greater fusion energy.
- `q-chemistry-nuclear-chemistry-0011` [CORRECTED]: Original stated thick lead or concrete blocks gamma rays completely.
- `q-chemistry-nuclear-chemistry-0014` [CORRECTED]: Original compared fusion and fission energy without specifying per event or per fuel mass.
- `q-chemistry-periodic-table-0004` [CORRECTED]: Original applied same-valence-count rule to all groups without transition-metal or helium qualifications.
- `q-chemistry-periodic-table-0010` [CORRECTED]: Original bundled electron affinity into an upper-right rule and claimed radius varies continuously.
- `q-chemistry-periodic-table-0011` [CORRECTED]: Original treated electron affinity as the same sign-free, exception-free trend.
- `q-chemistry-periodic-table-0012` [CORRECTED]: Original implied no diagonal comparison can be straightforward even when both trends agree.
- `q-chemistry-periodic-table-0014` [CORRECTED]: Original higher-affinity claim omitted sign convention and ignored major exceptions.
- `q-chemistry-quantum-numbers-electron-configuration-0001` [VERIFIED]: Original explanation falsely called s the smallest orbital capacity; all individual orbitals hold at most two.
- `q-chemistry-quantum-numbers-electron-configuration-0002` [CORRECTED]: Original key gave six for a single p orbital; repaired through explicit orbital/subshell comparison.
- `q-chemistry-quantum-numbers-electron-configuration-0003` [CORRECTED]: Original key gave ten for one d orbital; new framing distinguishes orbital count from electron capacity.
- `q-chemistry-quantum-numbers-electron-configuration-0006` [CORRECTED]: Original implied 4s is always below 3d without occupancy or atom context.
- `q-chemistry-quantum-numbers-electron-configuration-0007` [CORRECTED]: Original described a p orbital as holding six and confused orbital and subshell capacities.
- `q-chemistry-solutions-0005` [CORRECTED]: Original generalized one observation to most solids and confused dissolution rate with capacity.
- `q-chemistry-solutions-0014` [CORRECTED]: Original fixed only solvent mass and did not establish unchanged solute amount.
- `q-chemistry-stoichiometry-0006` [CORRECTED]: Original explanation implied an apparent yield above 100% necessarily rejects a reported result.
- `q-chemistry-thermodynamics-and-kinetics-0005` [CORRECTED]: Original notes treated increased concentration as always increasing rate and excluded zero-order behavior.
- `q-chemistry-thermodynamics-and-kinetics-0007` [CORRECTED]: Original duplicated catalyst speed and falsely claimed catalysts never change final product amounts in any context.
- `q-chemistry-thermodynamics-and-kinetics-0010` [CORRECTED]: Original asserted only speed can ever change and every final product amount is universally fixed.
- `q-chemistry-thermodynamics-and-kinetics-0012` [CORRECTED]: Original reduced thermodynamics to heat exchange and used a longest answer.
- `q-chemistry-thermodynamics-and-kinetics-0013` [CORRECTED]: Original Paper never releases energy unless on fire distractor was defensible in context; correct answer was longest.
- `q-chemistry-thermodynamics-and-kinetics-0014` [CORRECTED]: Original duplicated catalyst speed and claimed no catalyst can ever affect product quantity outside a defined equilibrium.
- `q-earth-science-astronomy-earths-motions-0002` [CORRECTED]: Original note incorrectly measured the 23.5-degree tilt from the orbital plane rather than its perpendicular.
- `q-earth-science-astronomy-earths-motions-0004` [CORRECTED]: Original did not specify tilt reference and falsely claimed zero tilt eliminates every possible seasonal variation.
- `q-earth-science-astronomy-earths-motions-0009` [CORRECTED]: Original wrongly aligned Philippine March-May hot season with Australian winter; longest choice shortened. Source: https://www.pagasa.dost.gov.ph/information/climate-philippines
- `q-earth-science-astronomy-earths-motions-0011` [CORRECTED]: Original called every solar day exactly 24 hours; this is the mean, not every apparent solar day.
- `q-earth-science-astronomy-earths-motions-0013` [CORRECTED]: Original stated every-four-years leap days without the Gregorian century exceptions.
- `q-earth-science-astronomy-earths-motions-0014` [CORRECTED]: Original duplicated the opposite-hemisphere example and assigned Philippine local weather solely to tilt.
- `q-earth-science-astronomy-earths-subsystems-0002` [CORRECTED]: Original treated water-vapor classification as universally exclusive and called cloud droplets water vapor.
- `q-earth-science-astronomy-earths-subsystems-0007` [CORRECTED]: Original rejected a defensible separate cryosphere convention and used a nonexistent-ice distractor.
- `q-earth-science-astronomy-eclipses-and-moon-phases-0013` [CORRECTED]: Original partly-covered description also allowed annular central viewing, not solely penumbra; context now excludes that ambiguity.
- `q-earth-science-astronomy-fossils-and-geologic-time-0002` [NEEDS AEDWON]: Lesson does not teach fossil preservation by rock-formation conditions. Stem/choices/key preserved; original explanation wrongly excluded every metamorphosed fossil.
- `q-earth-science-astronomy-fossils-and-geologic-time-0006` [CORRECTED]: Original assumed every fossil equals its containing layer’s age and incorrectly assigned mammal appearance mainly to Cenozoic.
- `q-earth-science-astronomy-fossils-and-geologic-time-0007` [CORRECTED]: Original falsely claimed radiometric dating is the only possible numerical-dating method.
- `q-earth-science-astronomy-fossils-and-geologic-time-0009` [CORRECTED]: Original assumed every daughter is immediately stable and every isotope result is automatically the actual rock age.
- `q-earth-science-astronomy-fossils-and-geologic-time-0010` [CORRECTED]: Original incorrectly defined half-life as decay directly into a stable form.
- `q-earth-science-astronomy-fossils-and-geologic-time-0013` [CORRECTED]: Original said real finite samples can never reach zero; explanation now states only the ideal halving result.
- `q-earth-science-astronomy-fossils-and-geologic-time-0019` [CORRECTED]: Original falsely treated all dinosaurs as extinct and used a dinosaur-never-existed distractor.
- `q-earth-science-astronomy-fossils-and-geologic-time-0020` [CORRECTED]: Original falsely said only small shrew-like mammals existed in Mesozoic; reworking and non-avian scope clarified.
- `q-earth-science-astronomy-fossils-and-geologic-time-0021` [NEEDS AEDWON]: Lesson lacks early-fish/Paleozoic teaching; isotope clock unspecified and not necessarily layer-deposition age. Stem/choices/key and longest cue preserved.
- `q-earth-science-astronomy-heavenly-bodies-0007` [CORRECTED]: Original unqualified tail claim ignored ion/dust differences and orbital effects.
- `q-earth-science-astronomy-heavenly-bodies-0008` [CORRECTED]: Unqualified tail claim and contradictory motion distractor corrected.
- `q-earth-science-astronomy-heavenly-bodies-0009` [CORRECTED]: Original falsely ruled out tails on every asteroid; duplicate replaced.
- `q-earth-science-astronomy-layers-of-the-earth-0002` [CORRECTED]: Original key used 70 km as typical continental thickness instead of about 35 km.
- `q-earth-science-astronomy-layers-of-the-earth-0003` [CORRECTED]: Original gave 70 km as typical continental thickness and 5 km for oceanic crust; weak distractors replaced.
- `q-earth-science-astronomy-layers-of-the-earth-0015` [CORRECTED]: Original explanation wrongly treated 70 km as typical continental thickness.
- `q-earth-science-astronomy-minerals-and-rocks-0017` [CORRECTED]: Original incorrectly turned granite-derived sediment into limestone and marble.
- `q-earth-science-astronomy-minerals-and-rocks-0018` [NEEDS AEDWON]: Hardness/streak absent from lesson; equal nominal reference hardness makes scratch bounds inconsistent; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0001` [CORRECTED]: Original explanation falsely pictured all space as one tiny spatial point.
- `q-earth-science-astronomy-origin-of-the-universe-0002` [NEEDS AEDWON]: History is untaught; 1927 expanding-universe work is conflated with 1931 primeval-atom proposal; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0004` [CORRECTED]: Original claimed observations prove a single point in pre-existing space.
- `q-earth-science-astronomy-origin-of-the-universe-0007` [NEEDS AEDWON]: History is untaught; retained key conflates 1927 expansion work with later Big Bang origin proposal; overlaps 0002.
- `q-earth-science-astronomy-plate-tectonics-0003` [NEEDS AEDWON]: Named/date history untaught; 1959 date is unsupported by checked USGS chronology (model 1960, publication 1962); stem, choices, key preserved.
- `q-earth-science-astronomy-plate-tectonics-0005` [CORRECTED]: Original claimed one 1959 discovery supplied the entire force and acceptance mechanism.
- `q-earth-science-astronomy-plate-tectonics-0016` [VERIFIED]: Original explanation falsely described wholesale melting of the subducting plate.
- `q-earth-science-astronomy-weather-and-climate-0015` [CORRECTED]: Original treated frequent typhoons as defining Habagat and implied rigid dates.
- `q-earth-science-astronomy-weather-and-climate-0016` [CORRECTED]: Original wrongly presented Amihan as generally dry without the eastern rainfall distinction.
- `q-earth-science-astronomy-weather-and-climate-0017` [CORRECTED]: Original used typhoon conditions as a monsoon definition; duplicate identification replaced.
- `q-earth-science-astronomy-weather-and-climate-0018` [CORRECTED]: Original reinforced universally dry Amihan; now tests regional rainfall.
- `q-earth-science-astronomy-weather-and-climate-0020` [CORRECTED]: Original key incorrectly described greenhouse action as trapping incoming solar heat.
- `q-earth-science-astronomy-weather-and-climate-0022` [CORRECTED]: Original assigned a typhoon to a monsoon; replaced with year-round cyclone interpretation.
- `q-physics-dynamics-0011` [CORRECTED]: Original stated N=mg without requiring zero vertical acceleration; duplicate normal-force item replaced.
- `q-physics-electricity-and-magnetism-0011` [CORRECTED]: Original conditional equal-resistance choice was also defensible; now specifies unequal resistors.
- `q-physics-electricity-and-magnetism-0014` [CORRECTED]: Original viewing instruction contradicted upward current viewed from above; clarified perspective.
- `q-physics-fluid-mechanics-0006` [CORRECTED]: Original presented lower pressure at higher speed as universal and called it an inverse relation.
- `q-physics-fluid-mechanics-0007` [CORRECTED]: Original notes claimed curvature forces faster airflow; replaced with measured pressure difference.
- `q-physics-fluid-mechanics-0008` [CORRECTED]: Original explanation said no object property affects buoyancy; displaced volume does depend on immersion.
- `q-physics-fluid-mechanics-0010` [CORRECTED]: Original unqualified Bernoulli claim ignored height, pumps, and flow assumptions.
- `q-physics-gravity-and-keplers-laws-0004` [CORRECTED]: Original explanation excluded circles even though they are a special case of ellipses.
- `q-physics-gravity-and-keplers-laws-0006` [CORRECTED]: Original used undefined average distance instead of semimajor axis.
- `q-physics-gravity-and-keplers-laws-0008` [CORRECTED]: Original used ambiguous three times longer and undefined distance for different unspecified central masses.
- `q-physics-gravity-and-keplers-laws-0011` [CORRECTED]: Original applied variable speed to all ellipses without the circular special case.
- `q-physics-kinematics-0005` [CORRECTED]: Original wrong-choice note named arithmetic that did not produce its stated value; corrected choice or note.
- `q-physics-kinematics-0007` [CORRECTED]: Original wrong-choice note named arithmetic that did not produce its stated value; corrected choice or note.
- `q-physics-kinematics-0012` [CORRECTED]: Original wrong-choice note named arithmetic that did not produce its stated value; corrected choice or note.
- `q-physics-light-and-optics-0004` [CORRECTED]: Original lens rule omitted refractive index relative to surroundings; now specifies ordinary glass in air.
- `q-physics-light-and-optics-0006` [CORRECTED]: Original lens rule omitted refractive index relative to surroundings; now specifies ordinary glass in air.
- `q-physics-light-and-optics-0012` [CORRECTED]: Original lens rule omitted refractive index relative to surroundings; now specifies ordinary glass in air.
- `q-physics-momentum-and-impulse-0002` [CORRECTED]: Original note claimed 5 times 0.2 produces 2; corrected to 1.
- `q-physics-momentum-and-impulse-0003` [CORRECTED]: Original note claimed division by stationary mass produces 1; replaced with mass-unweighted average.
- `q-physics-momentum-and-impulse-0006` [CORRECTED]: Original used a closed-system claim without requiring negligible external impulse.
- `q-physics-momentum-and-impulse-0008` [CORRECTED]: Original presented J=Ft without qualifying constant or average force.
- `q-physics-momentum-and-impulse-0010` [CORRECTED]: Original vector-momentum comparison lacked directions; now asks for magnitudes.
- `q-physics-momentum-and-impulse-0013` [CORRECTED]: Original unsigned sum gives 4.4, not the listed 2.2; corrected distractor.
- `q-physics-scalars-and-vectors-0001` [CORRECTED]: Original classified the quantity by presence or absence of a direction word; now names path length or displacement.
- `q-physics-scalars-and-vectors-0002` [CORRECTED]: Original classified the quantity by presence or absence of a direction word; now names path length or displacement.
- `q-physics-thermodynamics-0007` [CORRECTED]: Original gave a broad entropy limit without the pure, perfect-crystal condition.
- `q-physics-thermodynamics-0012` [CORRECTED]: Original compared heating rates without controlling mass and heat input.
- `q-physics-thermodynamics-0015` [CORRECTED]: Original omitted equal masses and initial temperatures, so the hotter sample was not determined.
- `q-physics-two-dimensional-motion-0002` [CORRECTED]: Original 0.882 note incorrectly named missing time square; replaced repeated setup with a two-step height problem.
- `q-physics-two-dimensional-motion-0013` [CORRECTED]: Original nonzero horizontal claim did not explicitly exclude a vertical launch; now states a nonzero horizontal component.
- `q-physics-units-and-measurements-0007` [CORRECTED]: Original note claimed 90 times 3.6 gives 32.4; corrected the computed distractor.
- `q-physics-units-and-measurements-0011` [CORRECTED]: Original wrongly claimed kilometers divided by seconds is inherently meaningless; now corrects mislabeled output.
- `q-physics-waves-and-sound-0007` [CORRECTED]: Mechanical wave was also a defensible choice and the explanation described light as moving medium particles.
- `q-physics-waves-and-sound-0008` [CORRECTED]: Standing-wave option could also describe a longitudinal disturbance; now asks only orientation.
- `q-physics-waves-and-sound-0012` [CORRECTED]: Original generalized air’s longitudinal sound to all media; solids can support transverse modes.
- `q-physics-work-energy-power-0004` [CORRECTED]: Original notes named arithmetic that did not produce 19.6 or 3.13; corrected distractors.
- `q-physics-work-energy-power-0011` [CORRECTED]: Kinetic energy determines speed, not velocity direction; changed requested quantity and incorrect arithmetic note.
- `q-physics-work-energy-power-0014` [CORRECTED]: Original assumed zero potential energy at the bottom without specifying that reference.

## Retained raw answer-length candidates

61 candidates remain recorded: 22 Mathematics and 39 in the other group. Of these, 15 are protected pending items and 46 are in previously completed ledgers skipped under the resumption rule. Raw source length includes LaTeX and is not rendered width. These were not reopened or visually checked; no visual acceptance is claimed. The three subject summaries explain the preservation and resumption limits.

### Mathematics (22)

- `q-arithmetic-number-sense-properties-of-real-numbers-0012`
- `q-geometry-logic-and-reasoning-0012`
- `q-precalculus-basic-calculus-conic-sections-0004`
- `q-statistics-and-probability-measures-of-central-tendency-0015`
- `q-statistics-and-probability-measures-of-variability-0015`
- `q-trigonometry-inverse-trigonometric-functions-0016`
- `q-trigonometry-solving-right-triangles-0011`
- `q-trigonometry-solving-right-triangles-0016`
- `q-geometry-triangles-0009`
- `q-precalculus-basic-calculus-basic-derivatives-0006`
- `q-precalculus-basic-calculus-basic-derivatives-0009`
- `q-precalculus-basic-calculus-basic-integrals-0010`
- `q-precalculus-basic-calculus-conic-sections-0015`
- `q-precalculus-basic-calculus-conic-sections-0018`
- `q-statistics-and-probability-basic-probability-0007`
- `q-statistics-and-probability-combinatorics-0005`
- `q-statistics-and-probability-combinatorics-0014`
- `q-statistics-and-probability-measures-of-central-tendency-0018`
- `q-statistics-and-probability-measures-of-central-tendency-0019`
- `q-trigonometry-angles-and-radian-measure-0015`
- `q-trigonometry-basic-trigonometric-ratios-0008`
- `q-trigonometry-basic-trigonometric-ratios-0009`

### Other subjects (39)

- `q-grammar-and-structure-parallelism-0001`
- `q-grammar-and-structure-parts-of-speech-0004`
- `q-grammar-and-structure-parts-of-speech-0008`
- `q-grammar-and-structure-parts-of-speech-0011`
- `q-grammar-and-structure-parts-of-speech-0013`
- `q-grammar-and-structure-parts-of-speech-0018`
- `q-grammar-and-structure-parts-of-speech-0019`
- `q-grammar-and-structure-phrases-and-clauses-0001`
- `q-grammar-and-structure-phrases-and-clauses-0011`
- `q-grammar-and-structure-pronoun-antecedent-agreement-0002`
- `q-grammar-and-structure-pronoun-antecedent-agreement-0003`
- `q-grammar-and-structure-pronoun-antecedent-agreement-0004`
- `q-grammar-and-structure-pronoun-antecedent-agreement-0007`
- `q-grammar-and-structure-sentence-structure-0004`
- `q-grammar-and-structure-sentence-structure-0008`
- `q-grammar-and-structure-sentence-structure-0012`
- `q-grammar-and-structure-tenses-and-voice-0005`
- `q-grammar-and-structure-tenses-and-voice-0009`
- `q-grammar-and-structure-tenses-and-voice-0016`
- `q-grammar-and-structure-tenses-and-voice-0017`
- `q-language-application-sentence-completion-0008`
- `q-language-application-sentence-completion-0012`
- `q-language-application-sentence-completion-0013`
- `q-language-application-sentence-completion-0015`
- `rc-cs-nsd-0003`
- `q-mechanical-technical-reasoning-gear-rotations-0014`
- `q-mechanical-technical-reasoning-springs-and-weights-0011`
- `q-mechanical-technical-reasoning-structural-stability-0009`
- `q-spatial-abstract-reasoning-figure-grouping-0002`
- `q-spatial-abstract-reasoning-figure-grouping-0015`
- `q-spatial-abstract-reasoning-figure-series-0005`
- `q-spatial-abstract-reasoning-figure-series-0017`
- `q-environment-management-environmental-concepts-0007`
- `q-grammar-and-structure-phrases-and-clauses-0009`
- `q-grammar-and-structure-phrases-and-clauses-0010`
- `q-grammar-and-structure-phrases-and-clauses-0013`
- `q-grammar-and-structure-subject-verb-agreement-0018`
- `q-vocabulary-root-words-prefixes-suffixes-0016`
- `q-mechanical-technical-reasoning-structural-stability-0011`

## Per-lesson emitted active counts

| Source lesson file | Active questions |
| --- | ---: |
| `content/questions/general-information/code-of-conduct-ra-6713/duties-and-prohibited-acts.yaml` | 20 |
| `content/questions/general-information/code-of-conduct-ra-6713/norms-of-conduct.yaml` | 20 |
| `content/questions/general-information/code-of-conduct-ra-6713/penalties-and-enforcement.yaml` | 20 |
| `content/questions/general-information/code-of-conduct-ra-6713/statements-of-assets-and-divestment.yaml` | 20 |
| `content/questions/general-information/environment-management/environmental-concepts.yaml` | 20 |
| `content/questions/general-information/environment-management/the-environmental-laws.yaml` | 20 |
| `content/questions/general-information/peace-and-human-rights/human-rights-fundamentals.yaml` | 20 |
| `content/questions/general-information/peace-and-human-rights/humanitarian-law-and-human-rights-law.yaml` | 20 |
| `content/questions/general-information/philippine-constitution/accountability-and-impeachment.yaml` | 20 |
| `content/questions/general-information/philippine-constitution/bill-of-rights.yaml` | 20 |
| `content/questions/general-information/philippine-constitution/the-articles-in-outline.yaml` | 20 |
| `content/questions/general-information/philippine-constitution/the-civil-service-commission.yaml` | 20 |
| `content/questions/language-proficiency/grammar-and-structure/modifiers.yaml` | 20 |
| `content/questions/language-proficiency/grammar-and-structure/parallelism.yaml` | 20 |
| `content/questions/language-proficiency/grammar-and-structure/parts-of-speech.yaml` | 20 |
| `content/questions/language-proficiency/grammar-and-structure/phrases-and-clauses.yaml` | 20 |
| `content/questions/language-proficiency/grammar-and-structure/pronoun-antecedent-agreement.yaml` | 20 |
| `content/questions/language-proficiency/grammar-and-structure/punctuation-and-capitalization.yaml` | 20 |
| `content/questions/language-proficiency/grammar-and-structure/redundancy-and-double-negatives.yaml` | 20 |
| `content/questions/language-proficiency/grammar-and-structure/sentence-structure.yaml` | 20 |
| `content/questions/language-proficiency/grammar-and-structure/subject-verb-agreement.yaml` | 20 |
| `content/questions/language-proficiency/grammar-and-structure/tenses-and-voice.yaml` | 20 |
| `content/questions/language-proficiency/language-application/error-identification.yaml` | 20 |
| `content/questions/language-proficiency/language-application/paragraph-organization.yaml` | 20 |
| `content/questions/language-proficiency/language-application/sentence-completion.yaml` | 20 |
| `content/questions/language-proficiency/vocabulary/confusing-words.yaml` | 20 |
| `content/questions/language-proficiency/vocabulary/context-clues.yaml` | 20 |
| `content/questions/language-proficiency/vocabulary/idioms-and-figures-of-speech.yaml` | 20 |
| `content/questions/language-proficiency/vocabulary/root-words-prefixes-suffixes.yaml` | 20 |
| `content/questions/language-proficiency/vocabulary/spelling-rules.yaml` | 20 |
| `content/questions/language-proficiency/vocabulary/synonyms-and-antonyms.yaml` | 20 |
| `content/questions/mathematics/algebra/algebraic-expressions.yaml` | 20 |
| `content/questions/mathematics/algebra/exponents-and-logarithms.yaml` | 20 |
| `content/questions/mathematics/algebra/functions-and-relations.yaml` | 20 |
| `content/questions/mathematics/algebra/linear-equations-inequalities.yaml` | 20 |
| `content/questions/mathematics/algebra/polynomials.yaml` | 20 |
| `content/questions/mathematics/algebra/quadratic-equations.yaml` | 20 |
| `content/questions/mathematics/algebra/radicals-and-rationalization.yaml` | 20 |
| `content/questions/mathematics/algebra/sets-and-set-notation.yaml` | 20 |
| `content/questions/mathematics/algebra/systems-of-equations.yaml` | 20 |
| `content/questions/mathematics/algebra/types-of-functions.yaml` | 20 |
| `content/questions/mathematics/algebra/word-problems.yaml` | 20 |
| `content/questions/mathematics/arithmetic-number-sense/business-math.yaml` | 20 |
| `content/questions/mathematics/arithmetic-number-sense/divisibility-rules.yaml` | 20 |
| `content/questions/mathematics/arithmetic-number-sense/fractions-decimals-percentages.yaml` | 20 |
| `content/questions/mathematics/arithmetic-number-sense/order-of-operations.yaml` | 20 |
| `content/questions/mathematics/arithmetic-number-sense/prime-factorization-gcf-lcm.yaml` | 20 |
| `content/questions/mathematics/arithmetic-number-sense/properties-of-real-numbers.yaml` | 20 |
| `content/questions/mathematics/arithmetic-number-sense/ratio-and-proportion.yaml` | 20 |
| `content/questions/mathematics/arithmetic-number-sense/real-imaginary-numbers.yaml` | 20 |
| `content/questions/mathematics/arithmetic-number-sense/sequences-and-series.yaml` | 20 |
| `content/questions/mathematics/data-interpretation/rates-ratios-and-percentages-in-context.yaml` | 20 |
| `content/questions/mathematics/data-interpretation/tables-and-charts.yaml` | 20 |
| `content/questions/mathematics/geometry/basic-geometric-concepts.yaml` | 20 |
| `content/questions/mathematics/geometry/circles.yaml` | 20 |
| `content/questions/mathematics/geometry/coordinate-geometry.yaml` | 20 |
| `content/questions/mathematics/geometry/logic-and-reasoning.yaml` | 20 |
| `content/questions/mathematics/geometry/measurement.yaml` | 20 |
| `content/questions/mathematics/geometry/parallel-perpendicular-lines.yaml` | 20 |
| `content/questions/mathematics/geometry/quadrilaterals-and-polygons.yaml` | 20 |
| `content/questions/mathematics/geometry/triangles.yaml` | 20 |
| `content/questions/mathematics/precalculus-basic-calculus/basic-derivatives.yaml` | 20 |
| `content/questions/mathematics/precalculus-basic-calculus/basic-integrals.yaml` | 20 |
| `content/questions/mathematics/precalculus-basic-calculus/conic-sections.yaml` | 20 |
| `content/questions/mathematics/precalculus-basic-calculus/limits-and-continuity.yaml` | 20 |
| `content/questions/mathematics/statistics-and-probability/basic-probability.yaml` | 20 |
| `content/questions/mathematics/statistics-and-probability/combinatorics.yaml` | 20 |
| `content/questions/mathematics/statistics-and-probability/data-analysis-graphs.yaml` | 20 |
| `content/questions/mathematics/statistics-and-probability/measures-of-central-tendency.yaml` | 20 |
| `content/questions/mathematics/statistics-and-probability/measures-of-variability.yaml` | 20 |
| `content/questions/mathematics/trigonometry/angles-and-radian-measure.yaml` | 20 |
| `content/questions/mathematics/trigonometry/basic-trigonometric-ratios.yaml` | 20 |
| `content/questions/mathematics/trigonometry/inverse-trigonometric-functions.yaml` | 20 |
| `content/questions/mathematics/trigonometry/laws-of-sines-and-cosines.yaml` | 20 |
| `content/questions/mathematics/trigonometry/solving-right-triangles.yaml` | 20 |
| `content/questions/mathematics/trigonometry/trigonometric-identities.yaml` | 20 |
| `content/questions/mathematics/trigonometry/unit-circle.yaml` | 20 |
| `content/questions/reading-comprehension/comprehension-skills/authors-purpose-tone-pov.yaml` | 20 |
| `content/questions/reading-comprehension/comprehension-skills/choosing-a-title.yaml` | 20 |
| `content/questions/reading-comprehension/comprehension-skills/context-clues-in-passages.yaml` | 20 |
| `content/questions/reading-comprehension/comprehension-skills/fact-vs-opinion.yaml` | 20 |
| `content/questions/reading-comprehension/comprehension-skills/inferencing-and-conclusions.yaml` | 20 |
| `content/questions/reading-comprehension/comprehension-skills/main-idea.yaml` | 20 |
| `content/questions/reading-comprehension/comprehension-skills/noting-specific-details.yaml` | 20 |
| `content/questions/reading-comprehension/comprehension-skills/sequencing-of-events.yaml` | 20 |
| `content/questions/reading-comprehension/text-types/essays-editorials-articles.yaml` | 20 |
| `content/questions/reading-comprehension/text-types/poetry.yaml` | 20 |
| `content/questions/reading-comprehension/text-types/short-stories-and-novels.yaml` | 20 |
| `content/questions/reading-comprehension/text-types/speeches.yaml` | 20 |
| `content/questions/reading-comprehension/text-types/visual-media.yaml` | 20 |
| `content/questions/reasoning/clerical-ability/alphabetic-filing-rules.yaml` | 20 |
| `content/questions/reasoning/clerical-ability/numeric-and-chronological-filing.yaml` | 20 |
| `content/questions/reasoning/logical-verbal-reasoning/number-and-letter-sequences.yaml` | 20 |
| `content/questions/reasoning/logical-verbal-reasoning/syllogisms-and-deductive-logic.yaml` | 20 |
| `content/questions/reasoning/logical-verbal-reasoning/truth-tables-propositional-logic.yaml` | 20 |
| `content/questions/reasoning/logical-verbal-reasoning/word-analogies.yaml` | 20 |
| `content/questions/reasoning/mechanical-technical-reasoning/fluid-pressure.yaml` | 20 |
| `content/questions/reasoning/mechanical-technical-reasoning/gear-rotations.yaml` | 20 |
| `content/questions/reasoning/mechanical-technical-reasoning/pulleys-and-levers.yaml` | 20 |
| `content/questions/reasoning/mechanical-technical-reasoning/springs-and-weights.yaml` | 20 |
| `content/questions/reasoning/mechanical-technical-reasoning/structural-stability.yaml` | 20 |
| `content/questions/reasoning/spatial-abstract-reasoning/figure-grouping.yaml` | 20 |
| `content/questions/reasoning/spatial-abstract-reasoning/figure-matrices.yaml` | 20 |
| `content/questions/reasoning/spatial-abstract-reasoning/figure-series.yaml` | 20 |
| `content/questions/reasoning/spatial-abstract-reasoning/mental-rotation-3d-visualization.yaml` | 20 |
| `content/questions/reasoning/spatial-abstract-reasoning/paper-folding-and-cutting.yaml` | 20 |
| `content/questions/reasoning/verbal-logic/assumptions-and-conclusions.yaml` | 20 |
| `content/questions/science/biology/botany.yaml` | 20 |
| `content/questions/science/biology/cell-biology.yaml` | 20 |
| `content/questions/science/biology/cellular-metabolism.yaml` | 20 |
| `content/questions/science/biology/cellular-reproduction.yaml` | 20 |
| `content/questions/science/biology/characteristics-of-life.yaml` | 20 |
| `content/questions/science/biology/ecology.yaml` | 20 |
| `content/questions/science/biology/evolution.yaml` | 20 |
| `content/questions/science/biology/genetics-and-heredity.yaml` | 20 |
| `content/questions/science/biology/human-anatomy-physiology.yaml` | 20 |
| `content/questions/science/biology/taxonomy-and-classification.yaml` | 20 |
| `content/questions/science/chemistry/acids-bases-ph.yaml` | 20 |
| `content/questions/science/chemistry/atomic-structure.yaml` | 20 |
| `content/questions/science/chemistry/basic-organic-chemistry.yaml` | 20 |
| `content/questions/science/chemistry/chemical-bonding.yaml` | 20 |
| `content/questions/science/chemistry/chemical-nomenclature.yaml` | 20 |
| `content/questions/science/chemistry/chemical-reactions.yaml` | 20 |
| `content/questions/science/chemistry/gas-laws.yaml` | 20 |
| `content/questions/science/chemistry/history-of-the-atom.yaml` | 20 |
| `content/questions/science/chemistry/matter.yaml` | 20 |
| `content/questions/science/chemistry/mixtures-and-separation.yaml` | 20 |
| `content/questions/science/chemistry/mole-concept.yaml` | 20 |
| `content/questions/science/chemistry/nuclear-chemistry.yaml` | 20 |
| `content/questions/science/chemistry/periodic-table.yaml` | 20 |
| `content/questions/science/chemistry/quantum-numbers-electron-configuration.yaml` | 20 |
| `content/questions/science/chemistry/solutions.yaml` | 20 |
| `content/questions/science/chemistry/stoichiometry.yaml` | 20 |
| `content/questions/science/chemistry/thermodynamics-and-kinetics.yaml` | 20 |
| `content/questions/science/earth-science-astronomy/earths-motions.yaml` | 20 |
| `content/questions/science/earth-science-astronomy/earths-subsystems.yaml` | 20 |
| `content/questions/science/earth-science-astronomy/eclipses-and-moon-phases.yaml` | 20 |
| `content/questions/science/earth-science-astronomy/fossils-and-geologic-time.yaml` | 21 |
| `content/questions/science/earth-science-astronomy/heavenly-bodies.yaml` | 20 |
| `content/questions/science/earth-science-astronomy/layers-of-the-earth.yaml` | 20 |
| `content/questions/science/earth-science-astronomy/minerals-and-rocks.yaml` | 20 |
| `content/questions/science/earth-science-astronomy/origin-of-the-universe.yaml` | 20 |
| `content/questions/science/earth-science-astronomy/plate-tectonics.yaml` | 20 |
| `content/questions/science/earth-science-astronomy/water-cycle-oceanography.yaml` | 20 |
| `content/questions/science/earth-science-astronomy/weather-and-climate.yaml` | 22 |
| `content/questions/science/physics/dynamics.yaml` | 20 |
| `content/questions/science/physics/electricity-and-magnetism.yaml` | 20 |
| `content/questions/science/physics/fluid-mechanics.yaml` | 20 |
| `content/questions/science/physics/gravity-and-keplers-laws.yaml` | 20 |
| `content/questions/science/physics/kinematics.yaml` | 20 |
| `content/questions/science/physics/light-and-optics.yaml` | 20 |
| `content/questions/science/physics/momentum-and-impulse.yaml` | 20 |
| `content/questions/science/physics/scalars-and-vectors.yaml` | 20 |
| `content/questions/science/physics/thermodynamics.yaml` | 20 |
| `content/questions/science/physics/two-dimensional-motion.yaml` | 20 |
| `content/questions/science/physics/units-and-measurements.yaml` | 20 |
| `content/questions/science/physics/waves-and-sound.yaml` | 20 |
| `content/questions/science/physics/work-energy-power.yaml` | 20 |

## Next actions requiring Aedwon

- Resolve the pending content decisions and authorize integration of `content/question-qa-r2` into `web/roadmap-engine-r1`. No such merge was performed.
- Rebuild and re-sign the protected package with the signing key. The E09 package hashes will change; phone checks after the UI connection must run against the new package. No QA package was built or signed.
- Complete the on-request list of all wrong-choice notes in the UI round from approved Claude Design screens. The current reveal still shows only the picked choice note after a miss.
- Perform visual/device acceptance, including any desired check of the retained length candidates. No autonomous screenshots or visual review were performed.

The application-code freeze and separate publication approval remain in effect. This working-branch completion does not publish or release the app.
