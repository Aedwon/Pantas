# ACET requirements and format profile

Status: Research complete, awaiting source check and rebuild. Level 1 only. Not accepted.

Policy retrieved from current main `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`; lead verified live main and confirmed policy unchanged from dispatch. Audit branch: `docs/content-coverage-audit-r1`, observed HEAD `6b43affb58188f36d0cecc14eaf9c2ce25a3a0f4`. Project date and actual access date: October 4, 2026; tool clock: `2026-10-04 12:27:57 UTC`.

## 1. Sources

1. **Ateneo College Entrance Test information and FAQ.** URL: https://www.ateneo.edu/college/admissions/acet. Publisher: Ateneo de Manila University, Office of Admission and Aid. Accessed October 4, 2026. Confidence: official publisher, content inaccessible. Outcome: web and live HTTP returned 403; a link-following attempt returned a JavaScript bot-check page without exam content. Not evidence of any particular subtest or format rule.
2. **Choose your route: Take the ACET.** URL: https://www.ateneo.edu/college/admissions/apply/TakeACET. Publisher: Ateneo de Manila University. Accessed October 4, 2026. Confidence: official publisher, content inaccessible. Outcome: web and live HTTP returned 403. The alternative guessed `/apply/acet` route also returned 403 and supplied no evidence.
3. **College Admissions Calendar.** URL: https://www.ateneo.edu/college/admissions/calendar. Publisher: Ateneo de Manila University. Accessed October 4, 2026. Confidence: official publisher, content inaccessible. Outcome: web returned 403. No current-cycle dates verified from this page.
4. **Ateneo College Admissions, EDUSUITE portal.** URL: https://ateneo.admissions.ph/. Publisher: Ateneo College Admissions through Edusuite. Accessed October 4, 2026. Confidence: official publisher, body content unverified. Outcome: web open returned zero text; live HTTP returned 200 with an application shell and no announcement text. Search indexing reports SY 2027-2028 and September 2026 dates, but those snippets are leads, not verified body evidence.
5. **Apply to Ateneo.** URL: https://apply.ateneo.edu/. Publisher: Ateneo de Manila University. Accessed October 4, 2026. Confidence: official publisher, content inaccessible. Outcome: web and live HTTP returned 403. No admission-cycle or scope claim relies on this inaccessible page.
6. **ACET: The Ateneo College Entrance Test.** URL: https://www.schoolfinderph.com/blog/acet-guide. Publisher: SchoolFinderPH Team. Displayed publication date: August 12, 2026. Accessed October 4, 2026. Confidence: weak. Outcome: web open succeeded, 168 lines. Relevant sections: What Is on the ACET; scoring; SY 2027-2028 cycle; Sources; FAQ. It links organizer pages, but its editorial reliability is unestablished and the source wording could not be checked. Its preparation advice confuses the application essay's limit with the exam essay. Do not upgrade its claimed organizer quotations to official evidence.
7. **ACET 2027 Reviewer, Exam Dates & Format.** URL: https://supertutor.ph/resources/exams/acet/. Publisher: Super Tutor. Displayed fact-check date: September 24, 2026. Accessed October 4, 2026. Confidence: weak, commercial unofficial reviewer. Outcome: web open succeeded, 172 lines. Relevant sections: exam format; glance; FAQ. Current-cycle, paper delivery, and scoring claims remain reviewer claims. Its duration entry conflicts with source 6.
8. **Ateneo College Entrance Exam (ACET) Application.** URL: https://www.upcatreview.com/ateneo-college-entrance-exam-acet-application/. Publisher: Review Masters. Publication date not displayed; body describes the September 2019 exam and January 2020 decisions. Accessed October 4, 2026. Confidence: weak, unofficial reviewer and historical. Outcome: web open succeeded, 153 lines. Coverage names Mathematics, English, and General Intelligence. This older grouping does not establish current subtests.
9. **7 Important FAQs Aspiring Ateneo Students Have About the ACET.** URL: https://www.candymag.com/lifestyle/ateneo-college-entrance-exam-faqs-a1804-20230615. Publisher: Candy/Summit Media, Marit Samson. Search-indexed date: June 15, 2023. Accessed October 4, 2026. Confidence: inaccessible, not accepted as strong secondary evidence. Outcome: web and live HTTP returned 403. Search snippets are not used as body evidence.
10. **K to 12 Mathematics Curriculum Guide, Grades 1-10.** URL: https://www.deped.gov.ph/wp-content/uploads/2019/01/Math-CG_with-tagged-math-equipment.pdf. Publisher: DepEd. Document date: August 2016. Accessed October 4, 2026. Confidence: official curriculum, tier 2, not ACET coverage. Outcome: web initially returned 403; live HTTP with `Mozilla/5.0` returned 200, 3,188,806 bytes, valid PDF, 257 pages. Extracted relevant elementary and Grades 7-10 sections in memory. Locators: percentage pp. 191-192; number sense pp. 206-209; algebra pp. 210-213, 219-223, 231-241, 246-250; geometry pp. 214-216, 224-228, 242-246, 250-251; statistics/probability pp. 216-218, 229-230, 251-253.
11. **K to 12 English Curriculum Guide, Grades 1-10.** URL: https://www.deped.gov.ph/wp-content/uploads/2019/01/English-CG.pdf. Publisher: DepEd. Document date: May 2016. Accessed October 4, 2026. Confidence: official curriculum, tier 2, not ACET coverage. Outcome: live HTTP with `Mozilla/5.0` returned 200, 4,806,754 bytes, valid PDF, 247 pages; one later retrieval timed out, another succeeded. Extracted framework and Grades 7-10 relevant competencies. Locators: analogies pp. 163-164; agreement p. 174; voice p. 175; context clues/parallelism pp. 176-177; modals pp. 184-185; bias pp. 186,192; conditionals pp. 205-207; Grade 10 pronouns/persuasive writing p. 223. These curriculum domains do not confirm separate ACET subtests.
12. **K to 12 Science Curriculum Guide, Grades 3-10.** URL: https://www.deped.gov.ph/wp-content/uploads/2019/01/Science-CG_with-tagged-sci-equipment_revised.pdf. Publisher: DepEd. Document date: August 2016. Accessed October 4, 2026. Confidence: official curriculum, tier 2, not ACET coverage. Outcome: web opened a 203-page PDF with extracted text. Relevant locators: framework pp. 2-4; Grades 7-10 standards pp. 7-8; spiraling concepts pp. 10 onward. Science exposure does not establish a Science subtest or General Knowledge science scope.
13. **Strengthened SHS Program.** URL: https://www.deped.gov.ph/strengthened-shs-program/. Publisher: DepEd. Page publication date not displayed. Accessed October 4, 2026. Confidence: official curriculum-program information. Outcome: web open failed, but live HTTP with `Mozilla/5.0` returned 200, 664,562 bytes; extracted current core/elective listings and issuance titles. The accessible page lists Grade 11 pilot implementation in SY 2025-2026 and Grade 12 pilot implementation in SY 2026-2027. Search-indexed FAQ text was not present in the live body and is not treated as verified.
14. **Strengthened SHS General Mathematics, Grade 11.** URL: https://www.deped.gov.ph/wp-content/uploads/GENERAL-MATHEMATICS-1.pdf. Publisher: DepEd, with CHED panel inputs. Document publication date not displayed. Accessed October 4, 2026. Confidence: official curriculum, tier 2. Outcome: followed source 13's semestral core-guide link; HTTP 200, 379,273 bytes, valid eight-page PDF, extracted in memory. Relevant locators: Q1 finance/sequences pp. 2-3; Q2 measurement/functions/data pp. 4-5; Q3 trigonometry/distributions pp. 5-6; Q4 finance/statistics/logic pp. 7-8. Preparation support only for the relevant strengthened-SHS cohort, not every ACET taker.
15. **Strengthened SHS Effective Communication, Grade 11.** URL: https://www.deped.gov.ph/wp-content/uploads/Effective-Communication-1.pdf. Publisher: DepEd. Publication date not displayed. Accessed October 4, 2026. Confidence: official curriculum, tier 2. Outcome: followed source 13's core-guide link; HTTP 200, 355,092 bytes, valid nine-page PDF, extracted relevant sections in memory. Locators: personal communication p. 3; social/cultural reading and arguments p. 5; academic reading, vocabulary, and data interpretation pp. 6-7; professional communication pp. 8-9. Strengthened-SHS cohort support only.
16. **Strengthened SHS General Science, Grade 11.** URL: https://www.deped.gov.ph/wp-content/uploads/GENERAL-SCIENCE-1.pdf. Publisher: DepEd, with CHED panel inputs. Publication date not displayed. Accessed October 4, 2026. Confidence: official curriculum, tier 2. Outcome: followed source 13's core-guide link; HTTP 200, 365,109 bytes, valid eight-page PDF, extracted in memory. Locators: physics PDF pp. 2-3, chemistry pp. 4-5, biology pp. 6-7, Earth/space pp. 7-8. Conditional background preparation, not evidence of ACET Science inclusion.
17. **Strengthened SHS implementation memoranda, access limitation.** URLs: https://www.deped.gov.ph/wp-content/uploads/DM-12-s.-2026_Full-Implementation-of-the-Strengthened-Senior-High-School-Curriculum-in-School-Year-2026-2027.pdf and https://www.deped.gov.ph/wp-content/uploads/DM_s2026_036r-UPDATED_Pilot-Implementation-of-the-SSHS-Curriculum-for-Grade-12-in-SY-26-27pdf.pdf. Publisher: DepEd. Accessed October 4, 2026. Confidence: official publisher, body unverified. Outcome: live HTTP returned 200 with valid PDFs, two and 76 pages respectively; extracted first pages were empty scanned images. No memorandum-body claim relies on these unread pages.
18. **K to 12 SHS Core General Mathematics Curriculum Guide, official competency record.** URL: https://lrmds.deped.gov.ph/detail/14511. Publisher: DepEd Learning Resource Management and Development System. Portal publication date: September 25, 2018. Accessed October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web/live HTTP opened the record with full listed competencies and Grade 11 designation; underlying PDF not retrieved. The guessed 2019 `/SHS-Core_General-Math-CG.pdf` route returned 404 and is not evidence.
19. **K to 12 SHS Core Reading and Writing Skills Curriculum Guide, official competency record.** URL: https://lrmds.deped.gov.ph/detail/14520. Publisher: DepEd LRMDS. Portal publication date: September 25, 2018. Accessed October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web/live HTTP opened the Grade 11/12 record with reading, writing, claims, and textual-evidence competencies. Underlying PDF not retrieved; the guessed 2019 route returned 404. Grade 11/12 labeling does not establish completion before a September test.
20. **K to 12 SHS Core Statistics and Probability Curriculum Guide, official competency record.** URL: https://lrmds.deped.gov.ph/detail/14521. Publisher: DepEd LRMDS. Portal publication date: September 25, 2018. Accessed October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web/live HTTP opened the Grade 11/12 record with distributions, inference, and regression competencies. Underlying PDF not retrieved; the guessed 2019 route returned 404. Scheduling/completion before the exam is unknown.
21. **Ateneo Entrance Test (ACET) Reviewer.** URL: https://pinoyreviewer.com/review/acet. Publisher: Pinoy Reviewer. Publication date not displayed. Accessed October 4, 2026. Confidence: weak, unofficial reviewer. Outcome: web opened the category page. Categories describe grammar/vocabulary/reading, algebra/geometry/trigonometry/problem solving, patterns/sequences/spatial reasoning, and critical reading/inference. These are the site's review categories, not organizer-confirmed subtests. Its bank counts and quiz timings are not ACET counts or timings.
22. **K to 12 SHS Core Earth and Life Science Curriculum Guide, official competency record.** URL: https://lrmds.deped.gov.ph/detail/14509. Publisher: DepEd LRMDS. Portal publication date: September 25, 2018. Accessed October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web opened full listed competencies; underlying PDF not retrieved. Core designation and Grade 11/12 labeling do not prove common prior completion or exam inclusion.
23. **K to 12 SHS Core Physical Science Curriculum Guide, official competency record.** URL: https://lrmds.deped.gov.ph/detail/14519. Publisher: DepEd LRMDS. Portal publication date: September 25, 2018. Accessed October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web opened full listed competencies; underlying PDF not retrieved. Track substitution and exam-date completion need separate verification.
24. **DepEd Memorandum 003, s. 2026, SSHS pilot monitoring and evaluation, Section III (Scope).** URL: https://www.deped.gov.ph/wp-content/uploads/DM_s2026_003r.pdf. Publisher: DepEd. Document year: 2026; exact issue date not verified from the scanned cover. Accessed October 4, 2026. Confidence: official curriculum-policy evidence. Outcome: web returned 403; live HTTP with `Mozilla/5.0` returned 200, 15,390,305 bytes, valid 14-page PDF. Cover extraction empty; PDF p. 4 contains readable text for Section III. It explicitly separates the Grade 11 SY 2025-2026 pilot cohort continuing to Grade 12 in SY 2026-2027 from non-pilot Grade 12 learners who retain the existing SHS curriculum. This provides actual body evidence for cohort distinction.

## 2. Subtests and languages

The current-cycle official list remains unknown because sources 1-5 supplied no readable body evidence. The following working list is supported only by accessible weak sources, not confirmed requirements. Sources 6-7 report Mathematics, English, General Knowledge, Abstract Reasoning, and an essay. Source 8 uses the historical grouping Mathematics, English, and General Intelligence. These names must not be silently treated as equivalent current subtests. [1-8; unknown for current official scope, weak for reported names]

- Mathematics: reported area; test language unknown. [6-8; weak]
- English: reported area; English by source label, but a verified item-language allocation is unknown. [6-8; weak]
- General Knowledge: reported area; test language unknown. [6-7; weak]
- Abstract Reasoning: reported area; verbal versus nonverbal instructions and language unknown. [6-7; weak]
- Essay: reported written component assessing writing and reasoning; exam essay language unknown. The application essay is a different requirement. [6-7; weak]
- Separate Reading Comprehension, Verbal Analogy, Logical Reasoning, Numerical Ability, or General Intelligence boundaries: current official status unknown. [1-2,8; unknown]
- Filipino: sources 6-7 report no separate Filipino section, but organizer wording is inaccessible. No confirmed exclusion is made. [1-2,6-7; weak report, official status unknown]

## 3. Required topics and skills

### Interpretation and cohort boundary

No detailed topic is confirmed as a current ACET requirement. Tier 2 establishes curriculum content, not organizer scope. The working subtest grouping below comes from weak sources and remains provisional. [1-2,6-8,21; unknown for official scope, weak for grouping]

The Grades 1-10 guides provide mainstream K to 12 background. They do not prove every applicant, including international, transfer, or older applicants, studied the same curriculum. Old SHS records label subjects core but sometimes Grade 11/12; that does not establish completion by the exam date. DepEd separates the strengthened-SHS pilot cohort continuing to Grade 12 in SY 2026-2027 from non-pilot Grade 12 learners retaining the existing curriculum. Neither old nor strengthened SHS preparation is asserted universal. [10-16,18-20,24 Section III; official curriculum, exam relevance inferred]

#### Mathematics

**Confirmed**

- Current detailed Mathematics coverage and required depth: unknown. [1-2; unknown]

**Supported, curriculum**

- Number sense: operate on integers and rational numbers; convert fractions and decimals; order real numbers and use absolute value. [10, pp. 206-209; official curriculum, ACET relevance inferred]
- Percent applications: calculate percent, rate, or base and solve percentage problems. [10, pp. 191-192; official curriculum, ACET relevance inferred]
- Proportion problems: apply direct, inverse, and partitive proportion to distance, rate, and time. [10, p. 191; official curriculum, ACET relevance inferred]
- Sets: identify subsets and cardinality; apply union, intersection, difference, and Venn diagrams to problems. [10, p. 206; official curriculum, ACET relevance inferred]
- Polynomial/rational algebra: factor polynomials and simplify rational expressions; solve associated problems. [10, pp. 219-220; official curriculum, ACET relevance inferred]
- Linear equations/functions: model and solve problems with equations, inequalities, functions, and systems in two variables. [10, pp. 219-223; official curriculum, ACET relevance inferred]
- Quadratic algebra: solve equations through roots, factoring, completing the square, or the quadratic formula; connect roots and coefficients. [10, pp. 231-233; official curriculum, ACET relevance inferred]
- Variation/radicals: model direct, inverse, joint, or combined variation; convert rational exponents and radicals; solve radical problems. [10, pp. 237-241; official curriculum, ACET relevance inferred]
- Sequences/polynomials: identify patterns; distinguish arithmetic/geometric sequences; solve sequence problems; divide polynomials and use the Rational Root Theorem. [10, pp. 246-250; official curriculum, ACET relevance inferred]
- Trigonometry: use right-triangle ratios, laws of sines/cosines, and oblique triangles in problems. [10, pp. 245-246; official curriculum, ACET relevance inferred]
- Triangle geometry: apply congruence postulates, similarity/proportionality, and the Pythagorean theorem. [10, pp. 228-229,242-244; official curriculum, ACET relevance inferred]
- Quadrilaterals/circles: identify parallelograms; relate chords, arcs, and central/inscribed angles; solve circle problems. [10, pp. 241-242,250-251; official curriculum, ACET relevance inferred]
- Coordinate geometry: derive and apply the distance formula to geometric relationships. [10, p. 251; official curriculum, ACET relevance inferred]
- Solid measurement: calculate volumes and solve solid-volume problems. [10, pp. 200-201; official curriculum, ACET relevance inferred]
- Descriptive statistics: interpret tables/graphs; calculate mean, median, mode, variability, and positional measures. [10, pp. 216-218,252-253; official curriculum, ACET relevance inferred]
- Counting/probability: distinguish permutations/combinations and solve related probability problems. [10, pp. 251-252; official curriculum, ACET relevance inferred]
- Functions, conditional old-SHS preparation: evaluate and combine functions; model rational, inverse, exponential, and logarithmic functions; analyze domain/range, graphs, intercepts, and asymptotes. [18, Competencies; official core curriculum, cohort/completion and ACET relevance unconfirmed]
- Business mathematics, conditional old-SHS preparation: compare simple/compound interest; evaluate annuities; distinguish stocks/bonds and business/consumer loans. [18, Competencies; official core curriculum, cohort/completion and ACET relevance unconfirmed]
- Statistical inference, conditional old-SHS preparation: use probability/normal distributions, sampling, confidence intervals, tests, and correlation/regression. [20, Competencies; official core curriculum, completion before the exam and ACET relevance unconfirmed]
- Strengthened-SHS preparation: solve wages, percentage, sequence/series, conversion, area/volume, function-modeling, and trigonometry problems; interpret distributions and relationships. [14, PDF pp. 2-8; official core curriculum, applicable cohort/completion and ACET relevance unconfirmed]

**Supported, weak**

- Algebra: prepare to manipulate expressions and solve mathematical problems; exact exam operations unknown. [21, Mathematics category; weak]
- Geometry: prepare to apply geometric relationships; actual tested figures/theorems unknown. [21, Mathematics category; weak]
- Trigonometry: prepare basic trigonometric problem solving; exact identity or function depth unknown. [21, Mathematics category; weak]

**Unknown**

- Current inclusion and depth of individual arithmetic, geometry, statistics, finance, or trigonometric topics remain unknown. Calculus, conics, and other specialized STEM material are not established common preparation or exam requirements. No absence claim is made. [1-2,10,14,18,20-21; unknown]

#### English, including provisional reading/verbal skills

**Confirmed**

- Current English topic list, passage types, and item boundaries: unknown. [1-2; unknown]

**Supported, curriculum**

- Grammar: apply subject-verb agreement, active/passive voice, parallel structures, cohesive devices, modals, conditionals, and reflexive/intensive pronouns. [11, pp. 174-177,184-185,205-207,223; official curriculum, ACET relevance inferred]
- Vocabulary/verbal relationships: infer unfamiliar meanings through context; identify word relationships and complete analogies. [11, pp. 163-164,176-177; official curriculum, ACET relevance inferred]
- Critical reading: identify author bias and use textual aids to understand a text; distinguish formal/informal word definitions. [11, pp. 186,192,223; official curriculum, ACET relevance inferred]
- Text organization, conditional old-SHS preparation: distinguish narration, description, definition, classification, comparison, cause/effect, problem/solution, and persuasion. [19, Competencies; official core curriculum, exam-date completion and ACET relevance unconfirmed]
- Claims/evidence, conditional old-SHS preparation: identify explicit/implicit claims; assess assertions and counterclaims against textual evidence. [19, Competencies; official core curriculum, exam-date completion and ACET relevance unconfirmed]
- Strengthened-SHS preparation: identify main points, implied meanings, assumptions, and bias; use vocabulary strategies and interpret charts/tables in academic texts. [15, pp. 3,5-7; official core curriculum, applicable cohort/completion and ACET relevance unconfirmed]

**Supported, weak**

- Grammar/vocabulary: identify correct usage and word meaning; tested rule list unknown. [21, Language Proficiency category; weak]
- Reading: analyze texts, make inferences, and read critically. Separate Reading Comprehension subtest status remains unknown. [21, Reading Comprehension category; weak]
- Verbal ability: work with language relationships; current analogy item format unknown. [21, Language Proficiency category; weak]

**Unknown**

- Reading section boundaries, passage length, literary/informational mix, item vocabulary level, analogy format, and current item-language allocation are unknown. Curriculum exposure does not establish an oral/listening ACET component. [1-2,11,19,21; unknown]

#### General Knowledge / historical General Intelligence

**Confirmed**

- Current meaning, scope, and relation between these labels: unknown. [1-2; unknown]

**Supported, curriculum**

- Scientific inquiry background: interpret evidence and distinguish variables when reasoning about an investigation. This is a general preparation skill, not established General Knowledge science scope. [12, pp. 2-4,7; official curriculum, ACET relevance unconfirmed]
- Science background: explain relationships among living systems, matter, motion/energy, and Earth/space phenomena. No Science subtest inclusion follows. [12, pp. 7-8; official curriculum, ACET relevance unconfirmed]
- Conditional old-SHS science background: relate cellular energy and ecological processes, geological hazards, chemical structure/reactions, and physical models to evidence. Grade 11/12 completion and track-specific alternatives remain unverified. [22-23, Competencies; official curriculum, common completion and ACET relevance unconfirmed]
- Conditional strengthened-SHS science background: interpret everyday physics, household chemistry, interacting biological systems, climate effects, and Philippine Earth/space context. [16, PDF pp. 2-8; official core curriculum, applicable cohort/completion and ACET relevance unconfirmed]

**Supported, weak**

- A General Knowledge component is reported, but the accessible guides do not provide a reliable detailed syllabus. A historical reviewer uses General Intelligence instead. [6-8; weak]

**Unknown**

- Current affairs, Philippine/world history, civics, geography, culture, science facts, numerical ability, and verbal reasoning inclusion are unknown. The label General Knowledge alone cannot establish any of these topics. The label General Intelligence cannot establish the same scope. [1-2,6-8; unknown]

#### Abstract Reasoning / provisional aptitude skills

**Confirmed**

- Current reasoning topic list and item boundaries: unknown. [1-2; unknown]

**Supported, curriculum**

- Pattern reasoning: generate patterns and distinguish arithmetic/geometric sequences. This supports numerical pattern preparation, not a confirmed figural subtest. [10, pp. 246-249; official curriculum, ACET relevance inferred]
- Verbal relationships: identify relationships in analogies; this does not place analogies in Abstract Reasoning. [11, pp. 163-164; official curriculum, subtest placement unknown]
- Formal logic, conditional old-SHS preparation: evaluate propositions, conditional statements, categorical syllogisms, fallacies, and proof/counterexamples. [18, Competencies; official core curriculum, applicable cohort/completion and ACET relevance unconfirmed]
- Formal logic, conditional strengthened-SHS preparation: distinguish simple/compound propositions, logical operations, conditional forms, contradictions, and truth values. [14, p. 8; official core curriculum, applicable cohort/completion and ACET relevance unconfirmed]

**Supported, weak**

- Pattern recognition: infer a pattern or logical sequence. [21, Abstract Reasoning category; weak]
- Spatial reasoning: compare spatial relationships; exact tasks such as folding, rotation, or cube nets are not specified. [21, Abstract Reasoning category; weak]

**Unknown**

- Figural series/matrices, rotations/reflections, folding, cube nets, odd-one-out, syllogism placement, and mechanical reasoning inclusion/depth are unknown. Do not convert general spatial preparation into those exact item requirements. [1-2,21; unknown]

#### Essay component

**Confirmed**

- Current exam-essay inclusion, prompt, language, rubric, and required length: unknown. [1-2; unknown]

**Supported, curriculum**

- Argument writing: identify persuasive-text features and compose a persuasive text. [11, p. 223; official curriculum, ACET relevance inferred]
- Conditional old-SHS writing: organize coherent, cohesive text; use appropriate language/mechanics; support assertions and counterclaims with evidence. [19, Competencies; official core curriculum, exam-date completion and ACET relevance unconfirmed]
- Conditional strengthened-SHS writing: compose coherent arguments/narratives for a purpose and audience; write critical reviews and academic texts. [15, pp. 5-7; official core curriculum, applicable cohort/completion and ACET relevance unconfirmed]

**Supported, weak**

- Writing/reasoning: an exam essay assessing these skills is reported. [6-7; weak]

**Unknown**

- Current essay rubric, topic style, length, language, allotted time, and whether the written component is retained each cycle are unknown. The application essay's reported word limit cannot be assigned to the exam essay. [1-2,6-7; unknown]

## 4. Format profile

| Entry | Value | Sources | Checked | Confidence |
|---|---|---|---|---|
| Choices per item | unknown; no verified organizer sample | 1-2; unavailable | October 4, 2026 | unknown |
| Item types per subtest | Official current format unknown. Weak guides report multiple choice for Mathematics, English, General Knowledge, Abstract Reasoning, plus essay. | 1-2; 6-7 reported format | October 4, 2026 | weak |
| "None of the above" style | unknown; reviewer bank examples would not establish organizer style | 1-2,21 | October 4, 2026 | unknown |
| "All of the above" style | unknown | 1-2,21 | October 4, 2026 | unknown |
| Negative stems ("NOT", "EXCEPT") | unknown | 1-2,21 | October 4, 2026 | unknown |
| Language per subtest | unknown. Weak guides report no separate Filipino section; that does not establish every item's language or essay language. | 1-2,6-7 | October 4, 2026 | weak |
| Timing that affects item length | unknown sectional timing, passage allowance, and essay time. Weak sources disagree about whether overall duration is published. No number adopted. | 1-2,6-7 | October 4, 2026 | unknown |
| Subtest mix by proportion | unknown; no verified published proportions | 1-2,6-8 | October 4, 2026 | unknown |
| Topic weights | unknown; no verified published weights | 1-2,6-8,21 | October 4, 2026 | unknown |
| Delivery | Official current delivery unknown; paper at testing centers is reported by an unofficial reviewer. | 1-5,7 | October 4, 2026 | weak |
| Scoring and wrong-answer penalty | Official raw-score calculation and penalty unknown. Weak guides report no deduction; one reports percentile-based results. Neither establishes the full score formula. | 1-2,6-7 | October 4, 2026 | weak |

## 5. Version and cycle notes

- **Research target:** current or most recent accessible cycle as of October 4, 2026. The newest accessible weak guide targets SY 2027-2028 and reports September 2026 testing. The official portal's body could not be read. Therefore, SY 2027-2028 is a research lead, not an organizer-verified cycle in this record. [3-7; weak cycle lead, official cycle unknown]
- **Publication date is separate:** the accessible guide displays August 12, 2026; the reviewer displays a September 24, 2026 fact check. Neither date proves the source saw the actual current test or establishes an organizer content revision. [6-7; weak]
- **Historical naming:** the reviewer with 2019 dates describes Mathematics, English, and General Intelligence. Current weak guides use General Knowledge and Abstract Reasoning. Whether this is a real exam change or a difference in grouping is unknown. [6-8; weak, change unknown]
- **Conflicting timing:** one weak guide gives an approximate duration; the reviewer says duration is not published. Neither wins as official evidence. The profile stays unknown. [1-2,6-7; unknown]
- **Curriculum transition:** DepEd's Section III separates the Grade 11 SY 2025-2026 pilot cohort continuing to Grade 12 in SY 2026-2027 from non-pilot Grade 12 learners retaining the existing curriculum. Old and strengthened guides differ in organization. Each applicant's completed preparation remains unknown; a universal SHS topic list is not supported. The separate 2026 implementation PDFs in source 17 remain unread scans. [13-20,24 Section III; official curriculum/policy, applicant completion unknown]
- **No confirmed topic exclusion:** the accessible weak lists omit a standalone Science component and report no Filipino section. That cannot establish that science never appears within another component or that all language allocation is fixed. [1-2,6-8,12,16; unknown exclusion]

## 6. Open questions

- Obtain readable current Office of Admission and Aid coverage/FAQ or an organizer-issued examinee document. Sources 1-5 were inaccessible or shell-only, which blocks official scope confirmation. Do not infer a requirement from the reported quotations.
- Confirm the current admission cycle, exact subtest grouping, item languages, and whether the exam essay remains. The newest cycle lead is supported by weak sources only.
- Confirm detailed topics/depth, choices, stem style, delivery, score formula, penalty, proportions, and weights. Keep unpublished values unknown; no estimate or review-bank timing substitutes for organizer evidence.
- Verify each applicant cohort's pre-exam completion, track-specific substitutions, and any later amendment to source 24's cohort rules. Grade 11/12 labels do not establish that every taker met the topic before September.
- Retrieve the underlying old SHS PDFs where useful. Official portal competencies were read, but underlying files were not obtained; guessed direct routes returned 404.
- Rebuild the requirement list independently from the organizer's top source before accepting any scope statement. Source checking and independent rebuilding remain pending.
- Level 2 overlap, lesson reading, lesson/quiz standards, and content changes were not performed. This file is a research record, not an acceptance or full-coverage claim.
