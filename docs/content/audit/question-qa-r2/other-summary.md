# Question QA r2: Language, Reasoning, Reading Comprehension, General Information

## Scope and source identity

- Assignment: question QA round r2, approved 1 October 2026.
- Worktree: /Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2-other.
- Branch: content/question-qa-r2-other.
- Policy revision read on resumption: cf2d123e38319b2d35751f122bcc4766f3026c8b. AGENTS.md, WORKFLOW.md, and SUBAGENTS.md were fetched from origin/main and read in full.
- Baseline content: 1f79d880 on web/roadmap-engine-r1.
- Resumption head: e389469f78d50b78712ad6b78b035c989c683d24, matching the remote at startup.
- Completed content and ledger revision before this summary: 5027a0ab83923b65835826dd9dc9786d3cde6224.
- Resumption began with a clean worktree and 46 complete ledgers. Those lessons were skipped under the assignment's resume rule. Their NEEDS AEDWON explanations, notes, and formatting were inspected. The remaining 15 lessons were completed and committed.
- Only the four assigned question directories, their matching audit directories, and this summary changed. Application code, tools, tests, lessons, seeds, CSE vocabulary placeholders, and other branches were not changed.
- Commits remain local. This implementor did not push or merge.

## Completion totals

All 61 lessons have complete per-question ledgers. Each has exactly 20 imported active questions. No lesson is below the target and no question is figure-pending at the final source revision.

| Subject | Lessons | Existing audited | New | Final questions | Active |
|---|---:|---:|---:|---:|---:|
| general-information | 12 | 152 | 88 | 240 | 240 |
| language-proficiency | 19 | 319 | 61 | 380 | 380 |
| reading-comprehension | 13 | 160 | 100 | 260 | 260 |
| reasoning | 17 | 244 | 96 | 340 | 340 |
| Total | 61 | 875 | 345 | 1220 | 1220 |

All 875 baseline question IDs and their original approval fields were preserved. New questions use unused IDs and approved: false. Meta routing and exam lists match the baseline.

10 ledger rows record SOLVED-FIXED. Difficulty labels for existing questions in the resumed lessons were preserved; new batches ramp from easy toward exam level.

| Status | Count |
|---|---:|
| CORRECTED | 722 |
| NEW | 345 |
| NEEDS AEDWON | 43 |
| VERIFIED | 110 |

Severity describes the original finding, before correction. A HIGH finding can be a wrong explanation, an ambiguous item, a wrong fact, or a key problem. It does not necessarily mean a corrected answer key.

| Severity | Count |
|---|---:|
| MEDIUM | 464 |
| HIGH | 211 |
| LOW | 94 |
| NONE | 451 |

43 items remain NEEDS AEDWON. 11 of these carry HIGH findings. Their original stems, choices, and keys remain under the assignment's preservation rule. These are unresolved lesson-fit or content decisions, not silently repaired or approved questions.

## Verification evidence

The full-bank importer was run after each completed lesson and after relevant follow-up changes. Exit 0 was required before the next lesson. No validation failure in another group's subject required an exception.

Final checks use the actual importer output in memory rather than an assumed source count:

```text
dart run tools/import_questions/import_questions.dart --root content/questions > /dev/null
exit: 0
lessons=61 questions=1220 active=1220 preserved=875 new=345 fixed_keys=10 under20=0 errors=0
scope_files=123 out_of_scope=0
ledger_schema=OK
identical_items=0
check_no_ai_attribution: OK
```

The scoped mechanical check covers source and imported wrong-choice notes, absence of notes on correct choices, one marked key, string choice values, prohibited shuffled-choice text, student-directed "You picked" notes, bare fractions, em dashes, ledger/question identity, baseline IDs, approval preservation, unchanged routing, and imported active counts. Passage lengths and 4-to-8 question sets were checked separately. Full-question fingerprints compare stem, choices, figureSpec, and passage reference; none are identical.

The raw answer-length scan is a separate limitation below. It is not included in the errors=0 structural count. A marked key is not an independent proof that the answer is correct; authors performed the semantic audit, and the count is mechanical evidence.

## Gaps, pending decisions, and work not verified

- General Information has no blueprint. The lead's ruling was followed: use the lessons, style guide, and existing single_choice vocabulary. No blueprint was authored.
- The Reasoning blueprint does not cover every clerical filing archetype. Existing vocabulary and the lesson rules were used. Untaught conventions remain NEEDS AEDWON.
- The figure ruling permits supported figureSpec questions and overrides the older figure-pending blueprint. Existing completed figure lessons were resumed from their ledgers. The unsupported rounded-base self-righting question remains a protected NEEDS AEDWON item.
- The command-line importer on this branch calls questionToDoc directly. It does not invoke the passage-file validation path, and it does not reject a missing wrong-choice note. Its success alone therefore does not prove either rule. This run checked passage constraints and source/imported notes separately. Importer enforcement belongs to the lead's separate tooling assignment.
- The terminal relay runners were queried and all three reported offline. This dispatched assignment used the authorized local shell execution path.
- No new policy contradiction or dependency stop condition prevented completion. Known lesson gaps were preserved under the explicit task rulings rather than treated as authorization to alter lessons.
- No Question Studio approval, autonomous visual review, app/emulator/device checks, Flutter suite, app analysis, protected-package rebuilding or signing, publishing, or integration was performed. Existing approved values were kept and new items remain unapproved. These content-only checks do not claim release readiness.
- The independent authored-content review was waived by the accepted 1 October audit record. No additional reviewer was dispatched.
- Repository-wide status and integration records outside the assigned paths remain the orchestrator's responsibility. This summary records implementor completion only.

## Raw answer-length candidates retained under the resume rule

The correct text is longer in raw source than every distractor in 32 non-protected questions from the previously completed lessons. The instruction requires skipping their complete ledgers. They were not reopened. Source lengths include LaTeX, so this is not a verified rendered-length finding. These IDs need a later authorized check if the lead wants that limitation resolved:

- q-grammar-and-structure-parallelism-0001
- q-grammar-and-structure-parts-of-speech-0004
- q-grammar-and-structure-parts-of-speech-0008
- q-grammar-and-structure-parts-of-speech-0011
- q-grammar-and-structure-parts-of-speech-0013
- q-grammar-and-structure-parts-of-speech-0018
- q-grammar-and-structure-parts-of-speech-0019
- q-grammar-and-structure-phrases-and-clauses-0001
- q-grammar-and-structure-phrases-and-clauses-0011
- q-grammar-and-structure-pronoun-antecedent-agreement-0002
- q-grammar-and-structure-pronoun-antecedent-agreement-0003
- q-grammar-and-structure-pronoun-antecedent-agreement-0004
- q-grammar-and-structure-pronoun-antecedent-agreement-0007
- q-grammar-and-structure-sentence-structure-0004
- q-grammar-and-structure-sentence-structure-0008
- q-grammar-and-structure-sentence-structure-0012
- q-grammar-and-structure-tenses-and-voice-0005
- q-grammar-and-structure-tenses-and-voice-0009
- q-grammar-and-structure-tenses-and-voice-0016
- q-grammar-and-structure-tenses-and-voice-0017
- q-language-application-sentence-completion-0008
- q-language-application-sentence-completion-0012
- q-language-application-sentence-completion-0013
- q-language-application-sentence-completion-0015
- rc-cs-nsd-0003
- q-mechanical-technical-reasoning-gear-rotations-0014
- q-mechanical-technical-reasoning-springs-and-weights-0011
- q-mechanical-technical-reasoning-structural-stability-0009
- q-spatial-abstract-reasoning-figure-grouping-0002
- q-spatial-abstract-reasoning-figure-grouping-0015
- q-spatial-abstract-reasoning-figure-series-0005
- q-spatial-abstract-reasoning-figure-series-0017

Seven additional candidates are protected NEEDS AEDWON items. Their choices were retained because that preservation instruction overrides ordinary rewriting:

- q-environment-management-environmental-concepts-0007
- q-grammar-and-structure-phrases-and-clauses-0009
- q-grammar-and-structure-phrases-and-clauses-0010
- q-grammar-and-structure-phrases-and-clauses-0013
- q-grammar-and-structure-subject-verb-agreement-0018
- q-vocabulary-root-words-prefixes-suffixes-0016
- q-mechanical-technical-reasoning-structural-stability-0011

Repeated instruction-only stems were also found in seven groups, chiefly punctuation, spelling, and visual pattern questions. Their choices or figure specifications differ. No identical full item was found. This mechanical fingerprint check does not replace the authors' review for semantic near-duplicates.

## Every HIGH finding

- q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0002 [CORRECTED]: Explanation wrongly cited Section 5(b); corrected to 5(c).
- q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0003 [CORRECTED]: Explanation wrongly cited Section 5(c); corrected to 5(b).
- q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0005 [CORRECTED]: Original answer omitted the essential no-favor condition.
- q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0007 [CORRECTED]: Explanation wrongly cited Section 7(c); corrected to 7(b)(3).
- q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0013 [CORRECTED]: Explanation wrongly cited Section 7(d); corrected to 7(c).
- q-code-of-conduct-ra-6713-penalties-and-enforcement-0008 [CORRECTED]: Original wording omitted proof in a proper administrative proceeding.
- q-code-of-conduct-ra-6713-penalties-and-enforcement-0011 [NEEDS AEDWON]: Lesson does not teach CSC procedure; stem attributes rule to Section 11 instead of Section 12.
- q-code-of-conduct-ra-6713-penalties-and-enforcement-0015 [CORRECTED]: Original stem implied all Section 11 violations carry imprisonment; offense now specified.
- q-code-of-conduct-ra-6713-statements-of-assets-and-divestment-0008 [CORRECTED]: Original stem omitted the ongoing-investigation exception to destruction.
- q-code-of-conduct-ra-6713-statements-of-assets-and-divestment-0011 [CORRECTED]: Original non-executive wording could include regional or judicial officials with other repositories.
- q-code-of-conduct-ra-6713-statements-of-assets-and-divestment-0013 [NEEDS AEDWON]: Lesson does not teach university-specific routing; blanket wording overlooks category/location distinctions.
- q-philippine-constitution-accountability-and-impeachment-0010 [NEEDS AEDWON]: Lesson lists but does not define grounds; betrayal of public trust can also fit the unqualified stem.
- q-philippine-constitution-accountability-and-impeachment-0011 [NEEDS AEDWON]: Lesson does not define treason; betrayal of public trust can also fit the unqualified stem.
- q-philippine-constitution-bill-of-rights-0005 [CORRECTED]: Original stem broadly implied any state alteration of contractual rights is prohibited.
- q-grammar-and-structure-pronoun-antecedent-agreement-0001 [CORRECTED]: More than one pronoun was defensible without a stated pronoun or collective-reference convention.
- q-grammar-and-structure-pronoun-antecedent-agreement-0005 [CORRECTED]: More than one pronoun was defensible without a stated pronoun or collective-reference convention.
- q-grammar-and-structure-pronoun-antecedent-agreement-0006 [CORRECTED]: More than one pronoun was defensible without a stated pronoun or collective-reference convention.
- q-grammar-and-structure-punctuation-and-capitalization-0002 [CORRECTED]: Unstated style or collective-reference convention made another answer defensible.
- q-grammar-and-structure-punctuation-and-capitalization-0004 [CORRECTED]: Unstated style or collective-reference convention made another answer defensible.
- q-grammar-and-structure-punctuation-and-capitalization-0017 [CORRECTED]: Unstated style or collective-reference convention made another answer defensible.
- q-grammar-and-structure-subject-verb-agreement-0001 [CORRECTED]: Past "barked" was also grammatical because every morning did not specify present time.
- q-grammar-and-structure-tenses-and-voice-0005 [CORRECTED]: Key treated a possible simple-past form or a tense shift as wrong without a sufficient stated timeline or form requirement.
- q-grammar-and-structure-tenses-and-voice-0012 [CORRECTED]: Key treated a possible simple-past form or a tense shift as wrong without a sufficient stated timeline or form requirement.
- q-language-application-error-identification-0008 [CORRECTED]: The unspecified formal convention treated a grammatical simple-past sequence as requiring correction.
- q-language-application-paragraph-organization-0005 [CORRECTED]: Unattributed scientific study and specific results; also more than one plausible placement of methods and findings.
- q-language-application-paragraph-organization-0008 [CORRECTED]: Another offered order was defensible; the key relied on an unstated preferred opening or chronology.
- q-language-application-paragraph-organization-0010 [CORRECTED]: Another offered order was defensible; the key relied on an unstated preferred opening or chronology.
- q-language-application-paragraph-organization-0011 [CORRECTED]: Failure conditions could defensibly open before the general topic; added a backward reference. Context checked against https://www.energy.gov/sites/default/files/2024-05/EED_2827_FIG_SafetyStrategy%20240505v2.pdf
- q-language-application-paragraph-organization-0012 [CORRECTED]: Another offered order was defensible; the key relied on an unstated preferred opening or chronology.
- q-language-application-paragraph-organization-0013 [CORRECTED]: Resource introduction could precede the heat-transfer explanation in another offered order. Strengthened reference; verified source scope: https://www.eia.gov/energyexplained/geothermal/index.php
- q-language-application-paragraph-organization-0014 [CORRECTED]: Another offered order was defensible; the key relied on an unstated preferred opening or chronology.
- q-language-application-paragraph-organization-0015 [CORRECTED]: Another offered order was defensible; the key relied on an unstated preferred opening or chronology.
- q-language-application-sentence-completion-0006 [CORRECTED]: Several offered pairs could fit clear but mutually conflicting statements.
- q-vocabulary-idioms-and-figures-of-speech-0005 [CORRECTED]: Broad classification also allowed a hyperbolic reading; narrowed the stem to the direct comparison.
- q-vocabulary-idioms-and-figures-of-speech-0009 [CORRECTED]: Broad wording also allowed hyperbole; narrowed the target to the contradictory word pair.
- q-vocabulary-spelling-rules-0010 [CORRECTED]: The old mispsell note falsely claimed an added consonant; it actually transposes s and p.
- rc-cs-ap-0006 [VERIFIED]: Source placed Mount Apo at Ormoc Bay; corrected to the coast. Mount Apo is in Mindanao (https://davaodelsur.gov.ph/tourism/mt-apo/).
- rc-cs-ap-0007 [VERIFIED]: Source placed Mount Apo at Ormoc Bay; corrected to the coast. Mount Apo is in Mindanao (https://davaodelsur.gov.ph/tourism/mt-apo/).
- rc-cs-ap-0008 [CORRECTED]: Source placed Mount Apo at Ormoc Bay; corrected to the coast. Mount Apo is in Mindanao (https://davaodelsur.gov.ph/tourism/mt-apo/).
- rc-cs-ap-0009 [VERIFIED]: Source placed Mount Apo at Ormoc Bay; corrected to the coast. Mount Apo is in Mindanao (https://davaodelsur.gov.ph/tourism/mt-apo/).
- rc-cs-ap-0010 [VERIFIED]: Source placed Mount Apo at Ormoc Bay; corrected to the coast. Mount Apo is in Mindanao (https://davaodelsur.gov.ph/tourism/mt-apo/).
- rc-cs-ap-0011 [CORRECTED]: Question named a nonexistent passage; original source included an unsupported safety threshold.
- rc-cs-ap-0012 [CORRECTED]: Question named a nonexistent passage; original source included an unsupported safety threshold.
- rc-cs-ap-0013 [CORRECTED]: Question named a nonexistent passage; original source included an unsupported safety threshold.
- rc-cs-ap-0014 [CORRECTED]: Question named a nonexistent passage; original source included an unsupported safety threshold.
- rc-cs-ap-0015 [CORRECTED]: Question named a nonexistent passage; original source included an unsupported safety threshold.
- rc-cs-ct-0006 [CORRECTED]: Unsupported exact cooling and cortisol claims removed; retained the park argument (https://www.epa.gov/heatislands/using-trees-and-vegetation-reduce-heat-islands).
- rc-cs-ct-0007 [CORRECTED]: Unsupported exact cooling and cortisol claims removed; retained the park argument (https://www.epa.gov/heatislands/using-trees-and-vegetation-reduce-heat-islands).
- rc-cs-ct-0008 [CORRECTED]: Unsupported exact cooling and cortisol claims removed; retained the park argument (https://www.epa.gov/heatislands/using-trees-and-vegetation-reduce-heat-islands).
- rc-cs-ct-0009 [CORRECTED]: Unsupported exact cooling and cortisol claims removed; retained the park argument (https://www.epa.gov/heatislands/using-trees-and-vegetation-reduce-heat-islands).
- rc-cs-ct-0010 [CORRECTED]: Unsupported exact cooling and cortisol claims removed; retained the park argument (https://www.epa.gov/heatislands/using-trees-and-vegetation-reduce-heat-islands).
- rc-cs-cc-0006 [CORRECTED]: Original source omitted spinning and made an unsupported two-day dye-failure claim; revised process (https://www.nature.com/articles/24290).
- rc-cs-cc-0007 [CORRECTED]: Original source omitted spinning and made an unsupported two-day dye-failure claim; revised process (https://www.nature.com/articles/24290).
- rc-cs-cc-0008 [CORRECTED]: Original source omitted spinning and made an unsupported two-day dye-failure claim; revised process (https://www.nature.com/articles/24290).
- rc-cs-cc-0009 [CORRECTED]: Original source omitted spinning and made an unsupported two-day dye-failure claim; revised process (https://www.nature.com/articles/24290).
- rc-cs-cc-0010 [CORRECTED]: Original source omitted spinning and made an unsupported two-day dye-failure claim; revised process (https://www.nature.com/articles/24290).
- rc-cs-fo-0001 [CORRECTED]: Unsupported real municipal figures relabeled as fictional scenario records; removed wrong-choice discussion.
- rc-cs-fo-0002 [CORRECTED]: Unsupported real municipal figures relabeled as fictional scenario records; removed wrong-choice discussion.
- rc-cs-fo-0003 [CORRECTED]: Unsupported real municipal figures relabeled as fictional scenario records; removed wrong-choice discussion.
- rc-cs-fo-0004 [CORRECTED]: Unsupported real municipal figures relabeled as fictional scenario records; removed wrong-choice discussion.
- rc-cs-fo-0005 [CORRECTED]: Unsupported real municipal figures relabeled as fictional scenario records; removed wrong-choice discussion.
- rc-cs-fo-0006 [CORRECTED]: Unsupported real-world figures relabeled as fictional scenario records; corrected power-versus-energy error (https://www.eia.gov/energyexplained/electricity/measuring-electricity.php).
- rc-cs-fo-0007 [CORRECTED]: Unsupported real-world figures relabeled as fictional scenario records; corrected power-versus-energy error (https://www.eia.gov/energyexplained/electricity/measuring-electricity.php).
- rc-cs-fo-0008 [CORRECTED]: Unsupported real-world figures relabeled as fictional scenario records; corrected power-versus-energy error (https://www.eia.gov/energyexplained/electricity/measuring-electricity.php).
- rc-cs-fo-0009 [CORRECTED]: Unsupported real-world figures relabeled as fictional scenario records; corrected power-versus-energy error (https://www.eia.gov/energyexplained/electricity/measuring-electricity.php).
- rc-cs-fo-0010 [CORRECTED]: Unsupported real-world figures relabeled as fictional scenario records; corrected power-versus-energy error (https://www.eia.gov/energyexplained/electricity/measuring-electricity.php).
- rc-cs-ic-0006 [CORRECTED]: Original conclusion exceeded the evidence: rice remains did not prove local farming.
- rc-cs-ic-0007 [CORRECTED]: Original conclusion exceeded the evidence: tokens did not establish primary trade transactions.
- rc-cs-ic-0008 [CORRECTED]: Original conclusion exceeded the evidence: post holes did not establish permanent homes.
- rc-cs-ic-0010 [CORRECTED]: Original conclusion exceeded the evidence: artifacts did not prove a settled trade network.
- rc-cs-ic-0011 [CORRECTED]: Original conclusion exceeded the evidence: combined reforms did not prove a primary cause of erratic driving.
- rc-cs-ic-0013 [CORRECTED]: Original conclusion exceeded the evidence: stable turnover did not establish satisfaction or lower departures.
- rc-cs-ic-0015 [CORRECTED]: Original conclusion exceeded the evidence: combined observations did not prove causal effects or retention gains.
- rc-cs-mi-0011 [CORRECTED]: Weak choices replaced or explanation reshaped to keep the central point clear. Original source made unverified claims about a real project; relabeled as a fictional account.
- rc-cs-mi-0012 [NEEDS AEDWON]: Retrieving the purpose of dike openings is a detail question. Original source made unverified claims about a real project; relabeled as a fictional account.
- rc-cs-mi-0013 [NEEDS AEDWON]: Inferring scientific methods from site selection is an inference question. Original source made unverified claims about a real project; relabeled as a fictional account.
- rc-cs-mi-0014 [NEEDS AEDWON]: Retrieving two outcomes is a detail question. Original source made unverified claims about a real project; relabeled as a fictional account.
- rc-cs-mi-0015 [CORRECTED]: Weak choices replaced or explanation reshaped to keep the central point clear. Original source made unverified claims about a real project; relabeled as a fictional account.
- rc-cs-nsd-0001 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0002 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0003 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0004 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0005 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0006 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0007 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0008 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0009 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0010 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0011 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0012 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0013 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0014 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-nsd-0015 [CORRECTED]: Unsupported real project, festival, or cooperative records replaced with an explicitly fictional account; distractors tied to dates, roles, and quantities.
- rc-cs-se-0001 [CORRECTED]: Original source had conflicting outage durations and unstated immediate ordering; clarified fictional timeline.
- rc-cs-se-0002 [CORRECTED]: Original source had conflicting outage durations and unstated immediate ordering; clarified fictional timeline.
- rc-cs-se-0003 [CORRECTED]: Original source had conflicting outage durations and unstated immediate ordering; clarified fictional timeline.
- rc-cs-se-0004 [CORRECTED]: Original source had conflicting outage durations and unstated immediate ordering; clarified fictional timeline.
- rc-cs-se-0005 [CORRECTED]: Original source had conflicting outage durations and unstated immediate ordering; clarified fictional timeline.
- rc-cs-se-0006 [CORRECTED]: Original key inferred an actual refuge move from an instruction alone; added explicit arrival timing and removed unsupported immediacy.
- rc-cs-se-0007 [CORRECTED]: Original key inferred an actual refuge move from an instruction alone; added explicit arrival timing and removed unsupported immediacy.
- rc-cs-se-0008 [CORRECTED]: Original key inferred an actual refuge move from an instruction alone; added explicit arrival timing and removed unsupported immediacy.
- rc-cs-se-0009 [CORRECTED]: Original key inferred an actual refuge move from an instruction alone; added explicit arrival timing and removed unsupported immediacy.
- rc-cs-se-0010 [CORRECTED]: Original key inferred an actual refuge move from an instruction alone; added explicit arrival timing and removed unsupported immediacy.
- rc-tt-eea-0001 [CORRECTED]: Original report contained unsupported real-project claims and was below the passage minimum.
- rc-tt-eea-0002 [CORRECTED]: Original report contained unsupported real-project claims and was below the passage minimum.
- rc-tt-eea-0003 [CORRECTED]: Original report contained unsupported real-project claims and was below the passage minimum.
- rc-tt-eea-0004 [CORRECTED]: Original report contained unsupported real-project claims and was below the passage minimum.
- rc-tt-eea-0005 [CORRECTED]: Original report contained unsupported real-project claims and was below the passage minimum.
- rc-tt-eea-0006 [CORRECTED]: Institutional editorial authorship was unstated; genre rules were overgeneralized.
- rc-tt-eea-0007 [CORRECTED]: Institutional editorial authorship was unstated; genre rules were overgeneralized.
- rc-tt-eea-0008 [CORRECTED]: Institutional editorial authorship was unstated; genre rules were overgeneralized.
- rc-tt-eea-0009 [CORRECTED]: Institutional editorial authorship was unstated; genre rules were overgeneralized.
- rc-tt-eea-0010 [CORRECTED]: Institutional editorial authorship was unstated; genre rules were overgeneralized.
- rc-tt-po-0004 [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- rc-tt-po-0006 [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- rc-tt-po-0007 [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- rc-tt-po-0011 [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- rc-tt-po-0013 [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- rc-tt-po-0015 [CORRECTED]: Quoted lines or evidence did not occur in the poem, or weak choices overstated the interpretation.
- rc-tt-vm-0001 [CORRECTED]: Unverified public-health percentages presented as measured rates; converted to an explicitly illustrative arithmetic example.
- rc-tt-vm-0005 [CORRECTED]: Unsupported official health-agency endorsement/contact implied by original example; changed to a classroom health-desk label.
- q-clerical-ability-alphabetic-filing-rules-0001 [CORRECTED]: The answer changed the recorded surname Dela Cruz to Delacruz; restored its spelling and stated the rule.
- q-clerical-ability-alphabetic-filing-rules-0003 [NEEDS AEDWON]: Business stop-word treatment is not taught; key depends on an unnamed convention and is not universal. Stem, choices and key retained.
- q-clerical-ability-alphabetic-filing-rules-0004 [CORRECTED]: The answer respelled De la Rosa as Delarosa and presented the convention as universal.
- q-clerical-ability-alphabetic-filing-rules-0005 [CORRECTED]: Claimed city is the universal tie-breaker; supplied a city-next rule so the key is defensible.
- q-clerical-ability-alphabetic-filing-rules-0009 [NEEDS AEDWON]: Abbreviation expansion is not taught; the key depends on an unnamed system and is not universal. Stem, choices and key retained.
- q-clerical-ability-alphabetic-filing-rules-0011 [NEEDS AEDWON]: Government-agency jurisdiction ordering is not taught; the key depends on an unnamed convention. Stem, choices and key retained.
- q-logical-verbal-reasoning-syllogisms-and-deductive-logic-0016 [CORRECTED]: The old note said premise order determines validity; reordering the same premises does not change entailment. Removed a solution-length choice and corrected the note.
- q-logical-verbal-reasoning-truth-tables-propositional-logic-0012 [CORRECTED]: Original note claimed regrouping changed the value even though both groupings were true under its inputs; changed inputs to expose the grouping difference.
- q-logical-verbal-reasoning-word-analogies-0008 [CORRECTED]: Warm was defensible under an increasing-temperature relation; specified intensity of each named quality.
- q-logical-verbal-reasoning-word-analogies-0012 [CORRECTED]: Original unfinished book-to-blank analogy did not supply a coherent completion and its explanation confused preserving with reversing direction.
- q-logical-verbal-reasoning-word-analogies-0013 [CORRECTED]: Waltz can be a type of music as well as a dance; fixed the intended sense so only one choice fits.
- q-logical-verbal-reasoning-word-analogies-0015 [CORRECTED]: Cow, branch was also correct; its old note admitted the key merely expected leaf. Replaced it with an inverted whole relation. The source lesson has the same ambiguous example.
- q-logical-verbal-reasoning-word-analogies-0016 [CORRECTED]: Rooster was defensible for a male chick; key/lock and ignition/engine also used imprecise actions. Replaced the double analogy with specific relations.
- q-mechanical-technical-reasoning-fluid-pressure-0002 [CORRECTED]: Explanation falsely said open connected vessels always have equal levels; specified the required liquid and surface-pressure conditions.
- q-mechanical-technical-reasoning-fluid-pressure-0004 [CORRECTED]: Missing figure and self-contained conditions; faster-always-means-lower-pressure was overbroad.
- q-mechanical-technical-reasoning-fluid-pressure-0008 [CORRECTED]: Missing figure and conditions; slower-flow-always-means-higher-pressure was overbroad.
- q-mechanical-technical-reasoning-fluid-pressure-0010 [CORRECTED]: Squeezing a nozzle does not by itself hold flow rate fixed; replaced that unsupported guarantee with a defined continuity calculation.
- q-mechanical-technical-reasoning-fluid-pressure-0011 [CORRECTED]: Repeated a pressure comparison and overstated faster-always-lower; changed to the kinetic-energy term.
- q-mechanical-technical-reasoning-fluid-pressure-0012 [CORRECTED]: Stem described round, triangular, irregular, and unequal-height vessels that this renderer does not draw; replaced with an equilibrium change supported by the figure.
- q-mechanical-technical-reasoning-fluid-pressure-0013 [CORRECTED]: Pressure conclusion lacked the same-height ideal-flow assumptions and answer contained a long solution.
- q-mechanical-technical-reasoning-fluid-pressure-0014 [CORRECTED]: Original combined settled reservoirs with active connecting flow, without a driving condition or drawable combined figure; replaced with a single supported Bernoulli conservation item.
- q-mechanical-technical-reasoning-gear-rotations-0007 [CORRECTED]: Figure was pending despite an existing supported spoke layout; activated it and removed a stop-motion throwaway.
- q-mechanical-technical-reasoning-gear-rotations-0008 [CORRECTED]: Repeated 0001's endpoint answer and claimed all meshes always reverse; changed to a report-consistency check for explicit external meshes.
- q-mechanical-technical-reasoning-gear-rotations-0009 [CORRECTED]: Original claimed direction depends only on meshing parity for every gear geometry; specified external gears and separated the effects of tooth count and connection.
- q-mechanical-technical-reasoning-gear-rotations-0011 [CORRECTED]: Figure was pending and the original prediction lacked a displayed center direction; supplied the supported layout and made the comparison definite.
- q-mechanical-technical-reasoning-gear-rotations-0015 [CORRECTED]: Unequal-size spoke diagram was pending; the spoke painter ignores teeth sizing. Reframed as a supported unequal-size row and removed the solution-length answer.
- q-mechanical-technical-reasoning-pulleys-and-levers-0001 [CORRECTED]: Mass was labeled as force, and ideal assumptions were missing.
- q-mechanical-technical-reasoning-pulleys-and-levers-0002 [CORRECTED]: Mass-force units were wrong; added supporting-segment and ideal conditions.
- q-mechanical-technical-reasoning-pulleys-and-levers-0003 [CORRECTED]: Original assumed two movable pulleys guarantee advantage four and used mass as force.
- q-mechanical-technical-reasoning-pulleys-and-levers-0004 [CORRECTED]: Replaced kg-force ambiguity with newtons and perpendicular static conditions.
- q-mechanical-technical-reasoning-pulleys-and-levers-0005 [CORRECTED]: Repeated forward balance calculation; added torque comparison and fixed force units.
- q-mechanical-technical-reasoning-pulleys-and-levers-0006 [CORRECTED]: Removed dependence on a previous shuffled question and corrected force units.
- q-mechanical-technical-reasoning-pulleys-and-levers-0007 [CORRECTED]: Repeated earlier comparison and referred to another question; replaced with minimum-arm design.
- q-mechanical-technical-reasoning-pulleys-and-levers-0008 [CORRECTED]: Original made an overbroad claim about all movable pulleys and used kg as force.
- q-mechanical-technical-reasoning-pulleys-and-levers-0009 [CORRECTED]: Replaced yes/no throwaways with exact distance slips and fixed mass-force wording.
- q-mechanical-technical-reasoning-pulleys-and-levers-0011 [CORRECTED]: Changed mass-force units and stated weightless perpendicular balance conditions.
- q-mechanical-technical-reasoning-pulleys-and-levers-0012 [CORRECTED]: Corrected force units and specified balance assumptions.
- q-mechanical-technical-reasoning-pulleys-and-levers-0013 [CORRECTED]: Original asserted three movable pulleys always yield advantage eight without rope routing.
- q-mechanical-technical-reasoning-pulleys-and-levers-0014 [CORRECTED]: Original combined machinery that its single-lever figure could not represent; replaced with static work.
- q-mechanical-technical-reasoning-pulleys-and-levers-0015 [CORRECTED]: Original wrongly claimed equal-advantage ideal machines require different travel and showed mismatched arms.
- q-mechanical-technical-reasoning-springs-and-weights-0008 [CORRECTED]: Original falsely called fixed linear increments invalid; rounding was the actual error.
- q-mechanical-technical-reasoning-structural-stability-0003 [CORRECTED]: Original centered-line choice also satisfied the correct condition; removed overlapping answers.
- q-mechanical-technical-reasoning-structural-stability-0006 [CORRECTED]: Original explanation applied a static gravity-line rule to an accelerating truck.
- q-mechanical-technical-reasoning-structural-stability-0011 [NEEDS AEDWON]: Curved-base self-righting is absent from the lesson; the always claim and long key are retained for a ruling. No supported renderer draws this rounded base.
- q-mechanical-technical-reasoning-structural-stability-0012 [CORRECTED]: Original used wheelbase for track width and a static explanation for dynamic rollover.
- q-mechanical-technical-reasoning-structural-stability-0014 [CORRECTED]: Original treated a tilted box as retaining a three-meter contact region and misidentified its pivot boundary.
- q-spatial-abstract-reasoning-figure-grouping-0002 [CORRECTED]: Several original choices were defensible under different rules; specified reflection symmetry.
- q-spatial-abstract-reasoning-figure-grouping-0003 [CORRECTED]: Boolean through value was unsupported; off-center lines still intersect and do not make the claimed three regions.
- q-spatial-abstract-reasoning-figure-grouping-0005 [CORRECTED]: Original allowed alternative side-count and equality rules; made the boundary criterion explicit.
- q-spatial-abstract-reasoning-figure-grouping-0007 [CORRECTED]: Missing star and scalene figure could not be drawn; used supported marked-square symmetry.
- q-spatial-abstract-reasoning-figure-grouping-0008 [CORRECTED]: Stem called a triangle a quadrilateral and claimed sizes absent from the figure.
- q-spatial-abstract-reasoning-figure-grouping-0009 [CORRECTED]: Missing figure and unsupported star outline replaced with drawn internal line grouping.
- q-spatial-abstract-reasoning-figure-grouping-0010 [CORRECTED]: Stem called the drawn rhombus a kite; replaced verbose yes/no claims with testable grouping rules.
- q-spatial-abstract-reasoning-figure-grouping-0011 [CORRECTED]: Missing shading figure activated with existing figure-series fill fields.
- q-spatial-abstract-reasoning-figure-grouping-0012 [CORRECTED]: Original stem described five figures and three-region cuts but its four drawn shapes had different regions.
- q-spatial-abstract-reasoning-figure-grouping-0013 [CORRECTED]: Original referred to an absent fifth kite; changed to even-side grouping.
- q-spatial-abstract-reasoning-figure-grouping-0014 [CORRECTED]: Missing edge-dot figure activated using supported visible arrow fields.
- q-spatial-abstract-reasoning-figure-matrices-0001 [CORRECTED]: Original rotation was absent from the figure and unmarked square rotations made three choices visually equivalent.
- q-spatial-abstract-reasoning-figure-matrices-0004 [CORRECTED]: Key said black for a blank in the white middle column; solved from the actual grid and fixed.
- q-spatial-abstract-reasoning-figure-matrices-0005 [CORRECTED]: Original grid omitted union, had the wrong outlines, and radial segments could not form the claimed full X.
- q-spatial-abstract-reasoning-figure-matrices-0006 [CORRECTED]: Renderer draws fill from the bottom; original two identical lower fills could not show complementary halves.
- q-spatial-abstract-reasoning-figure-matrices-0007 [CORRECTED]: Original claimed a right-side dot but the supported field drew a top-right corner dot.
- q-spatial-abstract-reasoning-figure-matrices-0009 [CORRECTED]: Original duplicated union question while its figure showed an unrelated diagonal; changed to feature overlap.
- q-spatial-abstract-reasoning-figure-matrices-0010 [CORRECTED]: Original confused adding a line with rotating the shape; changed to a marked reflection across different outlines.
- q-spatial-abstract-reasoning-figure-matrices-0013 [CORRECTED]: The original stem and key called a line-angle field a shape rotation; distinguished the drawn feature.
- q-spatial-abstract-reasoning-figure-matrices-0014 [CORRECTED]: Original claimed absent fill and union fields; black fill would also hide black rays.
- q-spatial-abstract-reasoning-figure-series-0004 [CORRECTED]: Undefined extra-large state was unsupported; made the three-size cycle explicit in the figure.
- q-spatial-abstract-reasoning-figure-series-0008 [CORRECTED]: Undefined extra-small continuation replaced with a shown reversing size cycle.
- q-spatial-abstract-reasoning-figure-series-0009 [CORRECTED]: Original repeated 0004 and required an undefined size; replaced with independent dot and size tracks.
- q-spatial-abstract-reasoning-figure-series-0011 [CORRECTED]: Original circle fill fields described height fractions as area percentages and supplied an unshown cycle; used square fills and displayed repetition.
- q-spatial-abstract-reasoning-figure-series-0012 [CORRECTED]: Triangle dot route was described in the wrong rotation direction; replaced repeated corner motion with outline cycling.
- q-spatial-abstract-reasoning-figure-series-0013 [CORRECTED]: Original stem claimed absent rotation fields and undefined extra-large size; rebuilt with supported independent tracks.
- q-spatial-abstract-reasoning-mental-rotation-3d-visualization-0002 [CORRECTED]: Drawing was a valid net although the stem and key described an invalid one.
- q-spatial-abstract-reasoning-mental-rotation-3d-visualization-0006 [CORRECTED]: Unqualified claim of circular shadows from any light direction was false for tilted screens or point sources.
- q-spatial-abstract-reasoning-mental-rotation-3d-visualization-0011 [CORRECTED]: Key incorrectly named the topmost column square; the second-from-top center is opposite the bottommost square.
- q-spatial-abstract-reasoning-mental-rotation-3d-visualization-0014 [CORRECTED]: Extra square was drawn diagonally beside the center instead of at the right arm end; explanation gave an unsafe folding rule.
- q-spatial-abstract-reasoning-paper-folding-and-cutting-0001 [CORRECTED]: Key gave two openings despite the stem explicitly limiting the cut to one layer; fixed to one.
- q-spatial-abstract-reasoning-paper-folding-and-cutting-0005 [CORRECTED]: The renderer edge cut is inset and the original claim of one notch per outer edge was false.
- q-spatial-abstract-reasoning-paper-folding-and-cutting-0006 [CORRECTED]: Original specified a diamond that the actual triangular cut does not justify; used connectedness without an invented outline.
- q-spatial-abstract-reasoning-paper-folding-and-cutting-0007 [CORRECTED]: Original asserted an unconditional eight-hole rule and lacked a diagram.
- q-spatial-abstract-reasoning-paper-folding-and-cutting-0009 [CORRECTED]: Removed the false implication that perpendicular reflections never commute; asked about physically reversing the fold sequence.
- q-spatial-abstract-reasoning-paper-folding-and-cutting-0010 [CORRECTED]: Original four-fold stem contradicted the three-fold renderer; replaced with a supported crease-joining case.
- q-spatial-abstract-reasoning-paper-folding-and-cutting-0012 [CORRECTED]: Original stem placed the cut at the outer corner while its corner field drew it near the fold intersection.
- q-spatial-abstract-reasoning-paper-folding-and-cutting-0013 [CORRECTED]: Original compared two packets with only one depicted and asserted hole counts without crease conditions.
- q-spatial-abstract-reasoning-paper-folding-and-cutting-0014 [CORRECTED]: Stem required an unsupported diagonal fold and triangular cut absent from the diagram.
- q-verbal-logic-assumptions-and-conclusions-0001 [CORRECTED]: Achievable completion is not necessary for a conditional policy to be true; corrected the key using the lesson's stated distinction.
- q-verbal-logic-assumptions-and-conclusions-0006 [CORRECTED]: Presence alone did not prove compliance with a permission rule; added the missing compliance premise.
- q-verbal-logic-assumptions-and-conclusions-0008 [CORRECTED]: The old answer merely repeated the causal claim as an assumption. Replaced the asserted percentage with a causal-inference argument and a necessary unstated link.
- q-verbal-logic-assumptions-and-conclusions-0011 [CORRECTED]: A permission rule alone did not establish that an actual approval was authorized; made compliance explicit and removed unrelated cost/location guesses.
- q-verbal-logic-assumptions-and-conclusions-0012 [CORRECTED]: The old asserted bill decrease did not require replacement of grid consumption; other mechanisms such as export credits were possible. Specified the replacement argument.

## Every NEEDS AEDWON item

- q-code-of-conduct-ra-6713-penalties-and-enforcement-0011 [HIGH]: Lesson does not teach CSC procedure; stem attributes rule to Section 11 instead of Section 12.
- q-code-of-conduct-ra-6713-penalties-and-enforcement-0013 [LOW]: Lesson names Section 8 penalties but does not teach the section-to-SALN mapping.
- q-code-of-conduct-ra-6713-penalties-and-enforcement-0014 [LOW]: Lesson names Section 9 penalties but does not teach the section-to-divestment mapping.
- q-code-of-conduct-ra-6713-statements-of-assets-and-divestment-0013 [HIGH]: Lesson does not teach university-specific routing; blanket wording overlooks category/location distinctions.
- q-environment-management-environmental-concepts-0007 [LOW]: Lesson teaches the framework but does not name its national council.
- q-peace-and-human-rights-humanitarian-law-and-human-rights-law-0006 [LOW]: Lesson describes armed-conflict scope but does not teach this alternate name.
- q-philippine-constitution-accountability-and-impeachment-0010 [HIGH]: Lesson lists but does not define grounds; betrayal of public trust can also fit the unqualified stem.
- q-philippine-constitution-accountability-and-impeachment-0011 [HIGH]: Lesson does not define treason; betrayal of public trust can also fit the unqualified stem.
- q-philippine-constitution-accountability-and-impeachment-0015 [LOW]: Lesson names the ground but does not teach its intentional-breach definition.
- q-philippine-constitution-bill-of-rights-0006 [LOW]: Lesson names suspension limits but does not explain the writ's purpose.
- q-philippine-constitution-bill-of-rights-0008 [MEDIUM]: Lesson names the protection but does not teach its legal conditions; original stem is overbroad.
- q-philippine-constitution-bill-of-rights-0009 [LOW]: Lesson names but does not define ex post facto laws.
- q-philippine-constitution-bill-of-rights-0010 [LOW]: Lesson names but does not define bills of attainder.
- q-philippine-constitution-bill-of-rights-0012 [LOW]: Lesson teaches the safeguards but not the Miranda label.
- q-philippine-constitution-bill-of-rights-0014 [LOW]: Lesson states search protection but does not teach warrant-issuance conditions.
- q-philippine-constitution-the-civil-service-commission-0011 [LOW]: Lesson omits the initial transitional appointment durations.
- q-philippine-constitution-the-civil-service-commission-0012 [LOW]: This lesson does not teach impeachment; it belongs in accountability material.
- q-grammar-and-structure-phrases-and-clauses-0009 [MEDIUM]: Tests comma placement, which this lesson does not teach explicitly. Stem, choices and key retained; notes reshaped.
- q-grammar-and-structure-phrases-and-clauses-0010 [MEDIUM]: Tests comma placement, which this lesson does not teach explicitly. Stem, choices and key retained; notes reshaped.
- q-grammar-and-structure-phrases-and-clauses-0013 [MEDIUM]: Tests comma placement, which this lesson does not teach explicitly. Stem, choices and key retained; notes reshaped.
- q-grammar-and-structure-redundancy-and-double-negatives-0005 [MEDIUM]: Requires an acronym expansion that the lesson does not teach. Stem, choices and key retained; notes reshaped.
- q-grammar-and-structure-redundancy-and-double-negatives-0007 [MEDIUM]: Requires an acronym expansion that the lesson does not teach. Stem, choices and key retained; notes reshaped.
- q-grammar-and-structure-redundancy-and-double-negatives-0009 [MEDIUM]: Requires an acronym expansion that the lesson does not teach. Stem, choices and key retained; notes reshaped.
- q-grammar-and-structure-redundancy-and-double-negatives-0015 [MEDIUM]: Requires an acronym expansion that the lesson does not teach. Stem, choices and key retained; notes reshaped.
- q-grammar-and-structure-subject-verb-agreement-0018 [MEDIUM]: Tests Filipino focus and marker roles that the lesson names but explicitly leaves to other Filipino grammar topics. Stem, choices and key retained; explanation and notes reshaped.
- q-grammar-and-structure-subject-verb-agreement-0019 [MEDIUM]: Tests Filipino focus and marker roles that the lesson names but explicitly leaves to other Filipino grammar topics. Stem, choices and key retained; explanation and notes reshaped.
- q-grammar-and-structure-tenses-and-voice-0011 [MEDIUM]: Tests a specific Filipino object-focus construction that the lesson does not teach. Stem, choices and key retained; explanation and notes reshaped.
- q-language-application-error-identification-0014 [MEDIUM]: Requires the unreal-past conditional pattern, which the lesson does not teach. Stem, choices and key retained; explanation and notes reshaped.
- q-vocabulary-root-words-prefixes-suffixes-0016 [MEDIUM]: Tests a consonant/vowel placement rule not explicitly taught by the lesson. Stem, choices and key retained; explanation and notes reshaped.
- rc-cs-mi-0002 [MEDIUM]: Direct retrieval of a percentage is not the main-idea skill; allocation also combines beds and compost.
- rc-cs-mi-0003 [MEDIUM]: Inferring a leader's general preference is outside the main-idea skill.
- rc-cs-mi-0004 [MEDIUM]: Retrieving the youth petition motive is a detail question.
- rc-cs-mi-0007 [MEDIUM]: Retrieving a ledger's function is a detail question.
- rc-cs-mi-0008 [MEDIUM]: Explaining customer motives is an inference question.
- rc-cs-mi-0009 [MEDIUM]: Retrieving a credit rule is a detail question.
- rc-cs-mi-0012 [HIGH]: Retrieving the purpose of dike openings is a detail question. Original source made unverified claims about a real project; relabeled as a fictional account.
- rc-cs-mi-0013 [HIGH]: Inferring scientific methods from site selection is an inference question. Original source made unverified claims about a real project; relabeled as a fictional account.
- rc-cs-mi-0014 [HIGH]: Retrieving two outcomes is a detail question. Original source made unverified claims about a real project; relabeled as a fictional account.
- q-clerical-ability-alphabetic-filing-rules-0003 [HIGH]: Business stop-word treatment is not taught; key depends on an unnamed convention and is not universal. Stem, choices and key retained.
- q-clerical-ability-alphabetic-filing-rules-0009 [HIGH]: Abbreviation expansion is not taught; the key depends on an unnamed system and is not universal. Stem, choices and key retained.
- q-clerical-ability-alphabetic-filing-rules-0011 [HIGH]: Government-agency jurisdiction ordering is not taught; the key depends on an unnamed convention. Stem, choices and key retained.
- q-clerical-ability-numeric-and-chronological-filing-0009 [MEDIUM]: Terminal-digit filing is explicitly outside the lesson's taught methods. Stem, choices and key retained; explanation and notes reshaped.
- q-mechanical-technical-reasoning-structural-stability-0011 [HIGH]: Curved-base self-righting is absent from the lesson; the always claim and long key are retained for a ruling. No supported renderer draws this rounded base.

## Final per-lesson counts

| Subject / topic / lesson | Existing | New | Active |
|---|---:|---:|---:|
| general-information/code-of-conduct-ra-6713/duties-and-prohibited-acts | 14 | 6 | 20 |
| general-information/code-of-conduct-ra-6713/norms-of-conduct | 15 | 5 | 20 |
| general-information/code-of-conduct-ra-6713/penalties-and-enforcement | 15 | 5 | 20 |
| general-information/code-of-conduct-ra-6713/statements-of-assets-and-divestment | 15 | 5 | 20 |
| general-information/environment-management/environmental-concepts | 6 | 14 | 20 |
| general-information/environment-management/the-environmental-laws | 12 | 8 | 20 |
| general-information/peace-and-human-rights/human-rights-fundamentals | 8 | 12 | 20 |
| general-information/peace-and-human-rights/humanitarian-law-and-human-rights-law | 7 | 13 | 20 |
| general-information/philippine-constitution/accountability-and-impeachment | 15 | 5 | 20 |
| general-information/philippine-constitution/bill-of-rights | 15 | 5 | 20 |
| general-information/philippine-constitution/the-articles-in-outline | 15 | 5 | 20 |
| general-information/philippine-constitution/the-civil-service-commission | 15 | 5 | 20 |
| language-proficiency/grammar-and-structure/modifiers | 15 | 5 | 20 |
| language-proficiency/grammar-and-structure/parallelism | 15 | 5 | 20 |
| language-proficiency/grammar-and-structure/parts-of-speech | 20 | 0 | 20 |
| language-proficiency/grammar-and-structure/phrases-and-clauses | 15 | 5 | 20 |
| language-proficiency/grammar-and-structure/pronoun-antecedent-agreement | 18 | 2 | 20 |
| language-proficiency/grammar-and-structure/punctuation-and-capitalization | 20 | 0 | 20 |
| language-proficiency/grammar-and-structure/redundancy-and-double-negatives | 15 | 5 | 20 |
| language-proficiency/grammar-and-structure/sentence-structure | 16 | 4 | 20 |
| language-proficiency/grammar-and-structure/subject-verb-agreement | 20 | 0 | 20 |
| language-proficiency/grammar-and-structure/tenses-and-voice | 18 | 2 | 20 |
| language-proficiency/language-application/error-identification | 15 | 5 | 20 |
| language-proficiency/language-application/paragraph-organization | 15 | 5 | 20 |
| language-proficiency/language-application/sentence-completion | 15 | 5 | 20 |
| language-proficiency/vocabulary/confusing-words | 15 | 5 | 20 |
| language-proficiency/vocabulary/context-clues | 15 | 5 | 20 |
| language-proficiency/vocabulary/idioms-and-figures-of-speech | 18 | 2 | 20 |
| language-proficiency/vocabulary/root-words-prefixes-suffixes | 18 | 2 | 20 |
| language-proficiency/vocabulary/spelling-rules | 18 | 2 | 20 |
| language-proficiency/vocabulary/synonyms-and-antonyms | 18 | 2 | 20 |
| reading-comprehension/comprehension-skills/authors-purpose-tone-pov | 15 | 5 | 20 |
| reading-comprehension/comprehension-skills/choosing-a-title | 10 | 10 | 20 |
| reading-comprehension/comprehension-skills/context-clues-in-passages | 10 | 10 | 20 |
| reading-comprehension/comprehension-skills/fact-vs-opinion | 10 | 10 | 20 |
| reading-comprehension/comprehension-skills/inferencing-and-conclusions | 15 | 5 | 20 |
| reading-comprehension/comprehension-skills/main-idea | 15 | 5 | 20 |
| reading-comprehension/comprehension-skills/noting-specific-details | 15 | 5 | 20 |
| reading-comprehension/comprehension-skills/sequencing-of-events | 10 | 10 | 20 |
| reading-comprehension/text-types/essays-editorials-articles | 15 | 5 | 20 |
| reading-comprehension/text-types/poetry | 15 | 5 | 20 |
| reading-comprehension/text-types/short-stories-and-novels | 10 | 10 | 20 |
| reading-comprehension/text-types/speeches | 10 | 10 | 20 |
| reading-comprehension/text-types/visual-media | 10 | 10 | 20 |
| reasoning/clerical-ability/alphabetic-filing-rules | 12 | 8 | 20 |
| reasoning/clerical-ability/numeric-and-chronological-filing | 12 | 8 | 20 |
| reasoning/logical-verbal-reasoning/number-and-letter-sequences | 16 | 4 | 20 |
| reasoning/logical-verbal-reasoning/syllogisms-and-deductive-logic | 16 | 4 | 20 |
| reasoning/logical-verbal-reasoning/truth-tables-propositional-logic | 16 | 4 | 20 |
| reasoning/logical-verbal-reasoning/word-analogies | 16 | 4 | 20 |
| reasoning/mechanical-technical-reasoning/fluid-pressure | 14 | 6 | 20 |
| reasoning/mechanical-technical-reasoning/gear-rotations | 15 | 5 | 20 |
| reasoning/mechanical-technical-reasoning/pulleys-and-levers | 15 | 5 | 20 |
| reasoning/mechanical-technical-reasoning/springs-and-weights | 15 | 5 | 20 |
| reasoning/mechanical-technical-reasoning/structural-stability | 15 | 5 | 20 |
| reasoning/spatial-abstract-reasoning/figure-grouping | 14 | 6 | 20 |
| reasoning/spatial-abstract-reasoning/figure-matrices | 14 | 6 | 20 |
| reasoning/spatial-abstract-reasoning/figure-series | 14 | 6 | 20 |
| reasoning/spatial-abstract-reasoning/mental-rotation-3d-visualization | 14 | 6 | 20 |
| reasoning/spatial-abstract-reasoning/paper-folding-and-cutting | 14 | 6 | 20 |
| reasoning/verbal-logic/assumptions-and-conclusions | 12 | 8 | 20 |

## Sources checked during this resumption

The project lessons govern lesson fit. Primary legal sources were used to verify externally checkable details. Passages added in this run are original examples, not borrowed prose.

- [1987 Constitution](https://lawphil.net/consti/cons1987.html), Articles III, IX, XI, and XIII, and the full article outline.
- [RA 6713](https://lawphil.net/statutes/repacts/ra1989/ra_6713_1989.html), Sections 3 to 12: conduct, duties, gift conditions, disclosure, divestment, penalties, and enforcement.
- [RA 6713 implementing rules](https://ncda.gov.ph/rules-implementing-the-code-of-conduct-and-ethical-standards-for-public-officials-and-employees-republic-act-no-6713/): later-arising conflicts and administrative proceedings.
- [CSC SALN repository guidance](https://www.csc.gov.ph/phocadownload/userupload/irmo/policy%20resolutions/2025/saln/1-D%20Rules%20Annex%20D_Repository%20Agencies.pdf): category-specific distinctions underlying the pending state-university item.
- [RA 9003](https://lawphil.net/statutes/repacts/ra2001/ra_9003_2001.html): source segregation, diversion, and solid-waste management.
- [RA 8749](https://lawphil.net/statutes/repacts/ra1999/ra_8749_1999.html): air control and the qualified toxic-fumes incineration provision.
- [RA 9275](https://lawphil.net/statutes/repacts/ra2004/ra_9275_2004.html): water-quality and discharge framework.
- [RA 9729](https://lawphil.net/statutes/repacts/ra2009/ra_9729_2009.html): climate framework and commission.
- [RA 10121](https://lawphil.net/statutes/repacts/ra2010/ra_10121_2010.html): disaster-management framework and NDRRMC.
- [PD 1586](https://lawphil.net/statutes/presdecs/pd1978/pd_1586_1978.html): EIS System and ECC.
- [RA 9147](https://lawphil.net/statutes/repacts/ra2001/ra_9147_2001.html) and [RA 11038](https://lawphil.net/statutes/repacts/ra2018/ra_11038_2018.html): wildlife and expanded protected-area scope.
- [OHCHR human-rights explanation](https://bangkok.ohchr.org/what-are-human-rights): inherent rights and nondiscrimination.
- [ICRC comparison of humanitarian and human-rights law](https://www.icrc.org/en/document/what-difference-between-ihl-and-human-rights-law): time scope, bound parties, and complementary protection.
- [Supreme Court discussion of culpable constitutional violation](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/1/64003): the definition underlying the preserved out-of-lesson item.
- [Rules of Court, Rule 117](https://lawphil.net/courts/supreme/rc/rc_110-127_2000.html): first-jeopardy conditions underlying the preserved double-jeopardy item.

