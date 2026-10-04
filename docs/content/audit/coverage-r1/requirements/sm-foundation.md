# SM Foundation college scholarship examination: requirements and format

Status: Research complete, awaiting source check and rebuild. Level 1 only. This report does not claim accepted requirements or complete exam coverage.

Project date and actual access date: October 4, 2026. Tool-clock access window: October 4, 2026, 12:48-13:06 UTC. Policy: current main `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`. Workstream at research start: `docs/content-coverage-audit-r1`, HEAD `6b43affb58188f36d0cecc14eaf9c2ce25a3a0f4`; corpus input remains the approved `765c5dc0fa5586281047bf4f7b30d09ab3707887`. No content was examined or changed.

## 1. Sources

1. **SM College Scholarship program page.** URL: https://www.sm-foundation.org/what_we_do/college-scholarship-program/ . Publisher: SM Foundation. Publication date unspecified; live page names the February 1-28, 2026 application period. Access: October 4, 2026. Confidence: official. Outcome: web reader HTTP 403; non-UI HTTP 200 with `Mozilla/5.0`, 75,778 bytes, HTML body read. Eligibility includes incoming freshmen who are Grade 12 graduates or ALS completers. No academic examination blueprint appears in the retrieved page.
2. **Dear Applicant / online examination instructions.** URL: https://scholarship.sm-foundation.org/DPA/ExamInstruction.pdf . Publisher: SM Foundation scholarship portal. Document explicitly schedules April 26, 2021, not 2026. Access: October 4, 2026. Confidence: official, historical only. Outcome: web reader opened both pages; non-UI HTTP 200, 114,630 bytes, `application/pdf`, two pages independently extracted in memory. Page 1 specifies online proctoring, multiple-choice questions, scratch paper, no calculators, and a 45-minute answering period. It gives no academic subtest list.
3. **1,100 New Scholars Join SM Foundation, Largest College Scholarship Batch in Program History.** URL: https://www.sm-foundation.org/news/1100-new-scholars-join-sm-foundation-largest-college-scholarship-batch-in-program-history/ . Publisher: SM Foundation. Publication: July 3, 2026. Access: October 4, 2026. Confidence: official. Outcome: web reader HTTP 403; non-UI HTTP 200, 61,383 bytes, HTML body read. Establishes the 2026 awarding event; it does not publish examination topics or format.
4. **SM Foundation opens 2025 College Scholarship Application.** URL: https://www.sm-foundation.org/news/sm-foundation-opens-2025-college-scholarship-application/ . Publisher: SM Foundation. Publication: February 1, 2025; explicitly AY 2025-2026. Access: October 4, 2026. Confidence: official, earlier cycle. Outcome: web reader HTTP 403; non-UI HTTP 200, 59,673 bytes, HTML body read. Applications ran February 1 to March 31, 2025; no academic blueprint appears.
5. **SM College Scholarship Program Online Application Process Flow.** URL: https://www.sm-foundation.org/wp-content/uploads/2023/03/SMFoundation-Scholarship-Online-Process-Flow.pdf . Publisher: SM Foundation. Edition/cycle unknown; URL directory is not publication proof. Access: October 4, 2026. Confidence: official, edition/cycle unspecified. Outcome: web reader HTTP 403; non-UI HTTP 200, 1,664,219 bytes, one-page PDF. `pypdf` returned no text. The embedded page image was subsequently decoded, resized for legibility, and visually read through tool output entirely in memory; no file or browser automation was used. It specifies application/evaluation, examination, interview, random home visits, school/course confirmation, orientation, and contract signing. Examination schedule/venue arrive by email; passers and interviews are described as occurring on examination day. These are process claims, not an academic syllabus.

6. **K to 12 Mathematics Curriculum Guide, Grades 1-10, August 2016.** URL: https://www.deped.gov.ph/wp-content/uploads/2019/01/Math-CG_with-tagged-math-equipment.pdf . Publisher: DepEd. Access: October 4, 2026. Confidence: official curriculum, tier 2, not examination scope. Outcome: live non-UI HTTP 200, `application/pdf`, 3,188,806 bytes, 257 pages, relevant pages extracted in memory. Anchors: proportion/percent p. 191; sets and rational numbers pp. 206-207; algebra pp. 219, 231; geometry pp. 242, 246, 251; counting/probability/position measures pp. 251-253.
7. **K to 12 Science Curriculum Guide, Grades 3-10, August 2016.** URL: https://www.deped.gov.ph/wp-content/uploads/2019/01/Science-CG_with-tagged-sci-equipment_revised.pdf . Publisher: DepEd. Access: October 4, 2026. Confidence: official curriculum, tier 2, not examination scope. Outcome: live HTTP 200, `application/pdf`, 3,172,036 bytes, 203 pages, extracted in memory. Grade 7-10 standards pp. 7-8 and selected competencies pp. 166, 171, 181, 190 read.
8. **K to 12 English Curriculum Guide, Grades 1-10, May 2016.** URL: https://www.deped.gov.ph/wp-content/uploads/2019/01/English-CG.pdf . Publisher: DepEd. Access: October 4, 2026. Confidence: official curriculum, tier 2, not examination scope. Outcome: live HTTP 200, `application/pdf`, 4,806,754 bytes, 247 pages, extracted in memory. Anchors: agreement/voice/tenses pp. 174-175; context/parallelism p. 176; evidence/bias p. 186; synonyms/antonyms and punctuation p. 205; pronouns/persuasion p. 223; reading p. 235.
9. **SHS Core General Mathematics, official curriculum competency record.** URL: https://lrmds.deped.gov.ph/detail/14511 . Publisher: DepEd Learning Portal. Portal publication: September 25, 2018; underlying guide edition unknown. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web opened the Grade 11 core record and full competency listing; underlying PDF not retrieved. Functions, business mathematics, and logic are listed.
10. **SHS Core Reading and Writing Skills, official curriculum competency record.** URL: https://lrmds.deped.gov.ph/detail/14520 . Publisher: DepEd Learning Portal. Portal publication: September 25, 2018; underlying edition unknown. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web opened Grade 11/12 core record and full competencies, including organization, textual claims, and evidence; underlying PDF not retrieved.
11. **SHS Core Komunikasyon at Pananaliksik sa Wika at Kulturang Pilipino, official curriculum competency record.** URL: https://lrmds.deped.gov.ph/detail/14513 . Publisher: DepEd Learning Portal. Portal publication: September 25, 2018. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web opened Grade 11 core record and full competencies. This supports Filipino preparation only, not Filipino examination inclusion; underlying PDF not retrieved.
12. **SHS Core Physical Science, official curriculum competency record.** URL: https://lrmds.deped.gov.ph/detail/14519 . Publisher: DepEd Learning Portal. Portal publication: September 25, 2018. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web opened Grade 11/12 core record and full competencies; underlying PDF not retrieved. Common completion, track substitution, and SM examination relevance remain unverified.
13. **DepEd Memorandum 003, s. 2026, SSHS pilot monitoring and evaluation, Section III.** URL: https://www.deped.gov.ph/wp-content/uploads/DM_s2026_003r.pdf . Publisher: DepEd. Publication year: 2026; exact cover date not readable in extraction. Access: October 4, 2026. Confidence: official curriculum policy. Outcome: live HTTP 200, 15,390,305 bytes, 14-page PDF, extracted in memory. PDF p. 4 distinguishes Grade 11 pilot learners in SY 2025-2026 progressing to Grade 12 in SY 2026-2027 from other Grade 12 learners retaining the existing curriculum. A later policy check remains required before future-cohort mapping.
14. **Strengthened SHS General Mathematics, Grade 11.** URL: https://www.deped.gov.ph/wp-content/uploads/GENERAL-MATHEMATICS-1.pdf . Publisher: DepEd. Publication date unspecified. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: live HTTP 200, 379,273 bytes, eight-page PDF, extracted in memory; cover/course description and competency pages read. This is a strengthened-curriculum guide, not a 2026 SM test blueprint.
15. **Strengthened SHS General Science, Grade 11.** URL: https://www.deped.gov.ph/wp-content/uploads/GENERAL-SCIENCE-1.pdf . Publisher: DepEd. Publication date unspecified. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: live HTTP 200, 365,109 bytes, eight-page PDF, extracted in memory. Physics, chemistry, biology, and Earth/space competency pages read.
16. **Strengthened SHS Effective Communication, Grade 11.** URL: https://www.deped.gov.ph/wp-content/uploads/Effective-Communication-1.pdf . Publisher: DepEd. Publication date unspecified. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: initial HTTP retrieval timed out; retry HTTP 200, 355,092 bytes, nine-page PDF, extracted in memory. Cover, bilingual course description, and pp. 3, 5-7 read. English and Filipino are parallel strands, not proof of a bilingual SM exam.

17. **2020 CETs, SM Scholarship Exam subsection.** URL: https://www.studocu.com/ph/document/polytechnic-university-of-the-philippines/bachelor-of-science-in-accountancy/cetstopics-this-is-not-mine-but-this-might-help-you-goodluck/31312019 . Publisher: anonymous original examinee document, uploaded to Studocu; uploader notes it is not their work. Document updated July 11, 2020 and describes the previous year's experience. Access: October 4, 2026. Confidence: weak, historical recollection. Outcome: web opened preview text, including the disclaimer and separately headed SM subsection. It lists Language Proficiency, Numerical Reasoning, and Nonverbal Reasoning, with spatial/abstract components. Adjacent other-exam text is not SM evidence. A duplicate Scribd transcription was also opened but is not independent corroboration.
18. **Tips for the Upcoming SM Scholarship Exam.** URL: https://www.reddit.com/r/studentsph/comments/ujaosn/tips_for_the_upcoming_sm_scholarship_exam/ . Publisher: Reddit user Niro-kun. Original post: May 5, 2022, established by the page's linked post-date archive; lead independently reconfirmed that archive on October5,2026; later comments do not redate the original guidance. Access: October 4, 2026. Confidence: weak, preparation advice rather than a verified SM exam account. Outcome: web opened full post and comments. Author explicitly treats the reported subjects as uncertain and bases advice on a DOST-STE Grade 7 entrance experience. Names Math, English, Science, and Abstract Reasoning; offers arithmetic, grammar, and figural-pattern advice.
19. **Currently Finished the SM Scholarship Entrance Exam 2026.** URL: https://www.reddit.com/r/CollegeAdmissionsPH/comments/1rzdym2/currently_finished_the_sm_scholarship_entrance/ . Publisher: Reddit user eee_eunnie and commenters. Title identifies 2026; exact original date unverified on independent reopening; the title supplies2026 only. Access: October 4, 2026. Confidence: weak, unverified applicant account. Outcome: web opened post/comments. Reports taking an SMFI exam through a browser and camera/microphone concerns. Does not establish official current delivery rules, academic scope, score computation, or a proctoring technical specification.
20. **SHS STEM Specialized Pre-Calculus, official curriculum competency record.** URL: https://lrmds.deped.gov.ph/detail/14427 . Publisher: DepEd Learning Portal. Portal publication: September 21, 2018. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web opened Grade 11 STEM-specialized identity and full competency listing; underlying PDF not retrieved. Conics, induction, advanced trigonometry, and polar coordinates are strand-specific background, not universal SM preparation.
21. **SHS STEM Specialized Biology 1, official curriculum competency record.** URL: https://lrmds.deped.gov.ph/detail/14410 . Publisher: DepEd Learning Portal. Portal publication: September 20, 2018. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web opened Grades 11/12 STEM-specialized identity and full competencies; underlying PDF not retrieved. Detailed cellular energy pathways are strand-specific background, not universal SM preparation.
22. **SHS Core Statistics and Probability, official curriculum competency record.** URL: https://lrmds.deped.gov.ph/detail/14521 . Publisher: DepEd Learning Portal. Portal publication: September 25, 2018. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web opened Grade 11/12 core record and full distribution, sampling, estimation, testing, and regression competencies; underlying PDF not retrieved. Applicant completion and exam inclusion are unconfirmed.
23. **SHS Core Earth and Life Science, official curriculum competency record.** URL: https://lrmds.deped.gov.ph/detail/14509 . Publisher: DepEd Learning Portal. Portal publication: September 25, 2018. Access: October 4, 2026. Confidence: official curriculum, tier 2. Outcome: web opened Grade 11/12 core record and full competencies; underlying PDF not retrieved. Track substitution and completion before testing are unconfirmed.

24. **2025 Social Good Report.** [SM Foundation report](https://www.sm-foundation.org/wp-content/uploads/2026/06/SMFI_SGR-2025-for-web.pdf). Publisher: SM Foundation. Report year2025; hosted inJune2026 directory, which alone is not proof of exact publication day. Accessed October5,2026 independently by reviewer and lead: HTTP200, validPDF, cover identifies2025. Printedp11/PDFp13 describes online examination, virtual interview and overall performance ranking for its reported process. This is official2025 delivery history, not a2026 exam blueprint or numerical score formula. No academic subject subdivisions, styles, weights or proportions appear there.

## 2. Subtests and languages

Current academic subtest names and examination languages: **unknown**. Sources [1, 3] establish the 2026 college scholarship program, while historical instructions [2] establish an examination without naming its academic parts. English instructions do not establish English-only test items. [1-3; official, current scope unknown]

The undated organizer process flow confirms an examination stage followed by interviews, without naming academic parts. It sends the examination schedule/venue by email. Online application does not itself establish online examination delivery. [5; official, cycle unspecified]

| Candidate part | Evidence and language | Current status |
|---|---|---|
| Language Proficiency | Historical examinee report lists synonyms/antonyms, verbal reasoning, sentence completion, and error identification. Examination language unspecified. [17; weak] | 2026 inclusion, grouping, and language unknown |
| Numerical Reasoning / Mathematics | Historical examinee report names Numerical Reasoning and basic arithmetic/algebra. English/Filipino wording unknown. [17; weak] | 2026 inclusion and name unknown |
| Nonverbal Reasoning | Historical examinee report groups Spatial Reasoning and Abstract Reasoning here. Instructions language unknown. [17; weak] | 2026 inclusion and grouping unknown |
| Science | Preparation advice lists Science as a subject; the older report mentions a science-related numerical question rather than a separate Science part. [17-18; weak] | Separate Science subtest unknown |

These candidate parts are leads for a provisional map, not a confirmed 2026 roster. The two weak sources differ in grouping and evidence quality. The official sources neither settle that difference nor exclude omitted subjects. No DOST examination blueprint is imported into this report. [1-5, 17-18; current scope unknown]

## 3. Required topics and skills

**Confirmed academic scope:** unknown. No opened organizer source establishes an academic subtest, detailed topic list, or required depth for the 2026 examination. The historical official instructions establish multiple-choice answering and computation facilities, not a subject syllabus. [1-4; official, academic scope unknown]

**Curriculum applicability:** these are school-preparation candidates, not examination requirements. Grade 7-10 guides describe curriculum exposure; they do not prove instruction received by every applicant. The organizer accepts ALS completers and does not prescribe a single SHS strand. No common SHS topic list for all eligible takers is established. Legacy SHS records and strengthened Grade 11 guides are conditional, cohort-specific background. [1, 6-16; official sources, inference]

### Language preparation candidate, subtest identity unconfirmed

**Confirmed**

- Unknown: current language subtest identity and required skills. [1-4; unknown]

**Supported, curriculum**

- English grammar: apply agreement, clauses, connectors, active/passive voice, reported speech, and verb tenses. [8, pp. 174-175; official curriculum, exam relevance inferred]
- English vocabulary: infer meanings from context and synonym/antonym clues. [8, pp. 176, 205; official curriculum, exam relevance inferred]
- English reading: identify purpose, explicit/implied information, conclusions, evidence, and bias; interpret tables/graphs. [8, pp. 186, 235; official curriculum, exam relevance inferred]
- Legacy SHS reading/writing: distinguish text organization, claims, coherence, and evidence-supported counterclaims. [10, Competencies; official core curriculum, common completion and exam relevance unconfirmed]
- Filipino language background: choose words for context, infer communicative intent, and connect ideas in writing. This does not establish a Filipino examination part. [11, Competencies; official core curriculum, common completion and exam relevance unconfirmed]
- Strengthened SHS communication: identify main points, implied meanings, assumptions, and bias; interpret charts and unfamiliar terms in English/Filipino strands. [16, pp. 2-3, 5-7; official core curriculum, cohort/completion and exam relevance unconfirmed]

**Supported, weak**

- Vocabulary/grammar tasks: choose synonyms/antonyms, complete sentences, and detect errors; verbal reasoning is named without skill detail. [17; weak, historical]
- English grammar review: author recommends basic grammar using another exam experience, not a verified SM item blueprint. [18; weak, advice only]

**Unknown**

- English-only versus bilingual items; passages, literature, listening, essay inclusion, and required text complexity. [1-4; unknown]

### Mathematics preparation candidate, subtest identity unconfirmed

**Confirmed**

- Unknown: current mathematics/numerical subtest identity and required topic depth. [1-4; unknown]

**Supported, curriculum**

- Arithmetic: operate on rational numbers; convert fractions/decimals; solve proportion and percent problems. [6, pp. 191, 206-207; official curriculum, exam relevance inferred]
- Algebra: factor polynomials, simplify rational expressions, and solve linear and quadratic equations/inequalities. [6, pp. 219, 231; official curriculum, exam relevance inferred]
- Geometry: apply parallelogram properties, triangle trigonometry, circle relations, and coordinate distance. [6, pp. 242, 246, 251; official curriculum, exam relevance inferred]
- Counting/data: distinguish permutations/combinations, calculate event probabilities, and interpret positional measures. [6, pp. 251-253; official curriculum, exam relevance inferred]
- Legacy SHS functions/finance: evaluate and model rational, inverse, exponential, and logarithmic functions; solve interest, annuity, and loan problems. [9, Competencies; official core curriculum, common completion and exam relevance unconfirmed]
- Legacy SHS statistics: use probability distributions, sampling, confidence intervals, hypothesis tests, and correlation/regression. [22, Competencies; official core curriculum, common completion and exam relevance unconfirmed]
- Strand-specific mathematics: conics, induction, advanced trigonometry, and polar coordinates belong to STEM Pre-Calculus. They are not established common preparation. [20, Competencies; official specialized curriculum, current exam inclusion unknown]
- Strengthened SHS mathematics: solve finance, sequence, measurement, function, trigonometry, and distribution problems. [14, pp. 2-6; official core curriculum, cohort/completion and exam relevance unconfirmed]

**Supported, weak**

- Arithmetic and basic algebra: historical report names these, including a science-related numerical question. No detailed current topic list follows. [17; weak, historical]
- Review advice: practice operations, common factors/multiples, fractions, ratios, and simple algebra. These are recommendations, not verified SM item observations. [18; weak, advice only]

**Unknown**

- Actual inclusion of advanced algebra, statistics, trigonometry, calculus, finance, and geometry. Curriculum presence does not resolve test inclusion. [1-4, 6, 9, 14; unknown exam scope]

### Reasoning preparation candidate, subtest identity unconfirmed

**Confirmed**

- Unknown: current verbal, numerical, abstract, spatial, or mechanical reasoning parts. [1-4; unknown]

**Supported, curriculum**

- Numerical patterns: generate patterns and recognize sequences. [6, p. 246; official curriculum, exam relevance inferred]
- Legacy SHS logic: determine proposition truth values, conditional forms, syllogism validity, fallacies, and proof/counterexamples. [9, Competencies; official core curriculum, common completion and exam relevance unconfirmed]
- Strengthened SHS logic: distinguish propositions, logical operations, conditionals, tautologies, contradictions, and truth values. [14, p. 8; official core curriculum, cohort/completion and exam relevance unconfirmed]

**Supported, weak**

- Spatial and abstract reasoning: historical report names these without a detailed skill blueprint. [17; weak, historical]
- Figural patterns: preparation advice proposes identifying a next shape/position by following individual moving elements. Advice derives from another exam experience. [18; weak, advice only]

**Unknown**

- Figural/spatial formats, rotations, series rules, analogies, mechanical reasoning, and subtest placement. School logic does not establish an abstract-reasoning blueprint. [1-4, 9, 14; unknown]

### Science preparation candidate, separate subtest unconfirmed

**Confirmed**

- Unknown: separate Science subtest or science content within another part. [1-4; unknown]

**Supported, curriculum**

- Matter: distinguish mixtures/substances and particle models; explain chemical change and reaction conditions. [7, pp. 7-8; official curriculum, exam relevance unconfirmed]
- Life science: explain cells, organ systems, reproduction, inheritance, ecosystems, and adaptation. [7, pp. 7-8, 190; official curriculum, exam relevance unconfirmed]
- Physics: interpret motion graphs; apply force, work, energy, and momentum concepts; compare electromagnetic wavelengths. [7, pp. 7-8, 171, 181; official curriculum, exam relevance unconfirmed]
- Earth/space: explain earthquakes, volcanoes, weather/climate, seasons, and eclipses. [7, pp. 7-8, 166; official curriculum, exam relevance unconfirmed]
- Legacy SHS physical science: explain atomic structure, molecular properties, reactions, motion, gravitation, and waves. [12, Competencies; official core curriculum, common completion and exam relevance unconfirmed]
- Legacy SHS Earth/life science: interpret Earth systems, rocks/resources, geological hazards, cellular energy, reproduction, evolution, and ecology. [23, Competencies; official core curriculum, common completion and exam relevance unconfirmed]
- Strand-specific biology: membrane transport, detailed photosynthesis/respiration pathways, and enzyme processes appear in STEM Biology 1. They are not established common preparation. [21, Competencies; official specialized curriculum, current exam inclusion unknown]
- Strengthened SHS science: apply everyday physics, household chemistry, interacting biological systems, climate effects, and Philippine Earth/space context. [15, pp. 2-8; official core curriculum, cohort/completion and exam relevance unconfirmed]

**Supported, weak**

- A historical numerical section may contain a science-related calculation. This does not establish a standalone Science subtest. [17; weak, historical]
- The 2022 advice names broad Science review and suggests cell division as a possible complex topic, without verifying actual SM inclusion. [18; weak, advice only]

**Unknown**

- Whether Science forms a separate current part; detailed scientific reasoning, calculation depth, and strand-specific advanced topics. [1-4; unknown]

## 4. Format profile

This is a current-cycle profile with historical evidence displayed explicitly. Historical evidence does not fill a current unknown. No proportion or topic weight is calculated from a reviewer or historical count. [1-5, 17-19; current format largely unknown]

| Entry | Value | Sources | Checked | Confidence |
|---|---|---|---|---|
| Choices per item | Current and historical option counts unknown; official instructions name multiple choice without a count. | [2, p. 1] | October 4, 2026 | unknown |
| Item types per subtest | Current types/parts unknown. Historical 2021 instructions specify multiple choice overall. Historical recollection names vocabulary, sentence completion, error identification, numerical, spatial, and abstract tasks. | [2, p. 1; 17] | October 4, 2026 | unknown |
| "None of the above" style | unknown | No usable example in [1-5, 17-19] | October 4, 2026 | unknown |
| "All of the above" style | unknown | No usable example in [1-5, 17-19] | October 4, 2026 | unknown |
| Negative stems ("NOT", "EXCEPT") | unknown | No usable example in [1-5, 17-19] | October 4, 2026 | unknown |
| Language per subtest | unknown; English organizer instructions do not establish item language. | [2; 17-18] | October 4, 2026 | unknown |
| Timing that affects item length | Current unknown. Historical 2021 PDF specifies 77 questions in 45 minutes; it does not give separate section limits or item lengths. Do not derive a current per-item target. | [2, p. 1] | October 4, 2026 | unknown |
| Subtest mix by proportion | unknown; no accepted published/verified current proportions | [1-5; 17 is unverified historical recollection] | October 4, 2026 | unknown |
| Topic weights | unknown; no accepted published/verified current weights | [1-5, 17-18] | October 4, 2026 | unknown |
| Delivery | Current official mode unknown. Official2025 SocialGoodReport describes online examination and virtual interviews; historical2021 instructions specify proctored online testing. A 2026 applicant account reports browser access; generic process flow mentions emailed venue. It does not specify paper versus computer. | [24, printedp11/PDFp13; 2,p1; 5; weak19] | October 5, 2026 | unknown |
| Scoring and wrong-answer penalty | unknown: score formula, cutoff, normalization, section combination, blank treatment, and wrong-answer penalty are not established. Passing an exam is a selection stage, not a scoring rule. | [2, p. 1; 5] | October 4, 2026 | unknown |

Additional historical constraint: the 2021 instructions permit scratch paper and prohibit calculators, notes, textbooks, and outside help. The 2026 rules remain unknown. Do not transfer another organizer's calculator or scoring policy. [2, p. 1; official, historical only]

## 5. Version and cycle notes

The latest directly opened organizer cycle is the 2026 application round, followed by a July 3, 2026 awarding event. The live program page does not explicitly attach an academic-year label to the entire round. Do not present a future 2027 application or examination as verified. [1, 3; official]

The 2025 page explicitly names AY 2025-2026. Its February 1 to March 31 application period differs from the live 2026 page's February 1-28 period. This establishes an application-calendar change, not a changed academic blueprint. [1, 4; official]

DepEd Section III places strengthened-SHS pilot Grade 11 learners in SY 2025-2026 and their Grade 12 continuation in SY 2026-2027. Applying their Grade 11 guides to all 2026 scholarship applicants is unsupported, especially with ALS eligibility. Future cycles require renewed organizer and curriculum checks. [1, 13-16; official sources, applicability inference]

The 2020 recollection describes a prior-year experience. The 2022 advice uses another exam experience and gives a different grouping. Neither source can confirm a change in the real SM test, because neither supplies a current organizer blueprint. Duplicate uploads are not independent corroboration. [17-18; weak]

The publicly accessible examination PDF explicitly dates its schedule to 2021. Its format and timing are historical evidence only; the2025 report[24] confirms online delivery more recently, but does not establish2026 format/timing or extend the2021 item specification. The one-hour appointment window and 45-minute answering period are different quantities. Its 15-minute versus 30-minute login instructions are internally inconsistent. [2; official, historical]

## 6. Open questions

- Obtain an organizer-issued 2026 examination guide, invitation, sample, or topic list that establishes parts, names, languages, topic depth, and Science inclusion. Current opened organizer pages publish no such list. Without it, academic scope remains unknown. [1-5; unknown]
- Confirm current multiple-choice delivery, option count, stem styles, calculator rules, time constraints, and score/penalty rules. Historical official instructions cannot establish present rules. [2; unknown current applicability]
- Verify current subtest proportions and topic weights directly. No acceptable published or verified figures were found; do not infer them from weak recollections. [1-5, 17-18; unknown]
- Resolve the weak historical grouping conflict with stronger evidence before treating language, numerical, nonverbal, or Science candidates as confirmed requirements. Organizer silence is not exclusion. [1-5, 17-18; unknown]
- Confirm cohort preparation, SHS core completion, science-track substitutions, ALS exposure, and later strengthened-SHS policy for any future cycle. This report does not establish that all takers met any SHS guide. STEM-only guides cannot supply common requirements. [1, 9-16, 20-23; unknown applicability]
- The undated process flow and the 2021 result instructions describe different notification procedures. No current organizer source resolves their cycle applicability. Do not infer a change in academic content from that difference. [2, 5; unknown current procedure]
- Access limitations: organizer web-reader 403 errors were recovered by non-UI HTTP; process PDF empty text was recovered by in-memory page-image reading; Effective Communication timeout recovered on retry. A separate 2026 reposted Reddit guide timed out and was not used. Source checks must independently reopen all retained claims. [1-5, 16, 19; access evidence]
- Source checker and independent requirement rebuild are pending. No lesson body, outline overlap, structure, standards, quiz quality, or content completeness was evaluated. This file is a research handoff, not combined level-1 acceptance.

Document self-check, October 4, 2026: six required sections; eleven profile rows; twenty-three numbered sources; zero em dashes, trailing-whitespace lines, unresolved research placeholders, or checked non-American spelling variants. These mechanical checks do not verify source interpretation or constitute acceptance.

Lead source resolution, October5,2026: independently downloaded/read source5 diagram, confirming the stated process with edition/cycle unknown. Source18 post-date archive confirmsMay5,2022; source19 exactMarch21 date removed as unverified. Added official2025 report24, with2026current mode stillunknown. Source-access identities retained; focused independent amendment recheck pending.
