# USTET requirements and format profile

Status: Research complete, awaiting source check and rebuild. Level 1 only; not accepted.

Project and live access date: October 4, 2026. Startup clock: 12:28:44 UTC.
Policy retrieved from current main `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`.
Audit workstream: `6b43affb58188f36d0cecc14eaf9c2ce25a3a0f4`.
Corpus input remains `765c5dc0fa5586281047bf4f7b30d09ab3707887`, not examined here.

## 1. Sources

1. **Home: UST Admission**, https://ustet.ust.edu.ph/. Publisher: UST Office for Admissions. Accessed October 4, 2026. Confidence: official. Outcome: live HTML opened successfully. Relevant sections: USTET overview, application guidelines, testing centers, LEAPMed test distinction, FAQ 17. Main schedules list test dates in calendar years 2026 and 2027; FAQ 18 explicitly describes admission in A.Y. 2026-2027, and the FAQ update label is August 8, 2025. These are section-specific cycle limits.
2. **USTET Application for A.Y. 2027-2028**, https://ofad.ust.edu.ph/ustet-application-for-a-y-2027-2028/, and **USTET College Application for A.Y. 2027-2028**, https://ofad.ust.edu.ph/ustet-college-application-for-a-y-2027-2028/. Publisher: UST Office for Admissions. Accessed October 4, 2026. Confidence: official. Outcome: live HTML opened successfully; titles independently establish the announced cycle. Image details are not used as topic evidence.
3. **Advisory on the Unauthorized Circulation of USTET Materials**, https://ofad.ust.edu.ph/advisory-on-the-unauthorized-circulation-of-ustet-materials/. Publisher: UST Office for Admissions. Published September 21, 2026; accessed October 4, 2026. Confidence: official. Outcome: HTML opened successfully; the two embedded advisory images were retrieved through direct non-UI HTTP and visually read in memory after the web tool could not open them. Image URLs: https://ofad.ust.edu.ph/wp-content/uploads/2026/09/OFAD-ANNOUNCEMENT-1-2.jpg and https://ofad.ust.edu.ph/wp-content/uploads/2026/09/OFAD-ANNOUNCEMENT-2-2.jpg. UST disclaims official status and endorsement of circulating A.Y. 2027-2028 mock tests and review materials. This prevents treating a reviewer as organizer evidence.
4. **USTET Reminders**, https://ofad.ust.edu.ph/ustet-reminders/. Publisher: UST Office for Admissions. Published September 21, 2026; accessed October 4, 2026. Confidence: official. Outcome: live HTML opened successfully; embedded image retrieved and read in memory through direct non-UI HTTP. Image: https://ofad.ust.edu.ph/wp-content/uploads/2026/09/OFAD-USTET-27-28_RemindersSquare-2-2.png. It confirms testing-center belongings rules, not a paper/computer response mode.
5. **K to 12 Curriculum Guide: Mathematics, Grades 1 to 10**, https://www.deped.gov.ph/wp-content/uploads/2019/01/Math-CG_with-tagged-math-equipment.pdf. Publisher: Department of Education. Document version: August 2016; upload path is January 2019. Accessed October 4, 2026. Confidence: official curriculum, not official USTET scope. Outcome: direct HTTP with Mozilla/5.0 returned 200 and valid PDF bytes; 257 pages parsed in memory. Grade-level standards on PDF page 8 establish the Grade 7-10 preparation summarized below.
6. **K to 12 Curriculum Guide: Science, Grades 3 to 10**, https://www.deped.gov.ph/wp-content/uploads/2019/01/Science-CG_with-tagged-sci-equipment_revised.pdf. Publisher: Department of Education. Document version: August 2016; upload path is January 2019. Accessed October 4, 2026. Confidence: official curriculum, not official USTET scope. Outcome: direct HTTP with Mozilla/5.0 returned 200 and valid PDF bytes; 203 pages parsed in memory. Relevant PDF pages: 4, 7-8, 10, 12-14, and Grade 7-10 competency sections starting at 106, 125, 154, and 176.
7. **K to 12 Curriculum Guide: English, Grades 1 to 10**, https://www.deped.gov.ph/wp-content/uploads/2019/01/English-CG.pdf. Publisher: Department of Education. Document version: May 2016; upload path is January 2019. Accessed October 4, 2026. Confidence: official curriculum, not official USTET scope. Outcome: direct HTTP with Mozilla/5.0 returned 200 and valid PDF bytes; 247 pages parsed in memory. Relevant PDF pages: 205, 212, 214, 216, 231, 235, and 237.
8. **DepEd Memorandum No. 012, s. 2026: Full Implementation of the Strengthened Senior High School Curriculum in School Year 2026-2027**, https://www.deped.gov.ph/wp-content/uploads/DM-12-s.-2026_Full-Implementation-of-the-Strengthened-Senior-High-School-Curriculum-in-School-Year-2026-2027.pdf. Publisher: Department of Education. Dated February 27, 2026. Accessed October 4, 2026. Confidence: official curriculum implementation policy. Outcome: web opener returned 403; direct Mozilla/5.0 HTTP recovered a valid two-page PDF. Text extraction returned no page-1 text; its embedded scan was decoded, correctly oriented, and visually read in memory. Paragraphs 4-5 distinguish existing-curriculum Grade 12 learners from continuing strengthened-curriculum pilot learners.
9. **Strengthened SHS Program**, https://www.deped.gov.ph/strengthened-shs-program/. Publisher: Department of Education. Accessed October 4, 2026. Confidence: official curriculum index, not USTET scope. Outcome: web opener returned 403; direct Mozilla/5.0 HTTP returned 200. Current core-subject guide links were read from live HTML, not inferred from search snippets.
10. **K to 12 SHS Core Curriculum: General Mathematics**, https://lrmds.deped.gov.ph/detail/14511, with guide https://depedwebsitestorage.blob.core.windows.net/upload/2019/01/SHS-Core_General-Math-CG.pdf. Publisher: Department of Education. Guide: May 2016; portal listing: September 25, 2018. Accessed October 4, 2026. Confidence: official curriculum. Outcome: live competency listing opened successfully; direct HTTP recovered a valid six-page PDF and page 1 was read. The portal's full competency listing supplies functions, financial mathematics, and logic details.
11. **K to 12 SHS Core Curriculum: Reading and Writing Skills**, https://lrmds.deped.gov.ph/detail/14520, with guide https://depedwebsitestorage.blob.core.windows.net/upload/2019/01/SHS-Core_Reading-and-Writing-CG.pdf. Publisher: Department of Education. Guide: December 2013; portal listing: September 25, 2018. Accessed October 4, 2026. Confidence: official curriculum. Outcome: live competency listing opened successfully; direct HTTP recovered a valid eight-page PDF and page 1 was read. Listing identifies Grades 11/12; it does not prove completion before each USTET date.
12. **K to 12 SHS Core Curriculum: Statistics and Probability**, https://lrmds.deped.gov.ph/detail/14521. Publisher: Department of Education. Portal publication: September 25, 2018. Accessed October 4, 2026. Confidence: official curriculum. Outcome: live competency listing opened successfully. Anonymous download buttons are disabled; a tested 2019 storage filename returned 404. Findings below use the accessible official competency listing, not an unread PDF. Grade allocation: 11/12.
13. **K to 12 SHS Core Curriculum: Earth and Life Science**, https://lrmds.deped.gov.ph/detail/14509. Publisher: Department of Education. Portal publication: September 25, 2018. Accessed October 4, 2026. Confidence: official curriculum. Outcome: live competency listing opened successfully; a tested storage filename returned 404. Findings use the official listing. Grade allocation: 11/12. Exact track substitutions and completion before testing require separate verification.
14. **K to 12 SHS Core Curriculum: Physical Science**, https://lrmds.deped.gov.ph/detail/14519. Publisher: Department of Education. Portal publication: September 25, 2018. Accessed October 4, 2026. Confidence: official curriculum. Outcome: live competency listing opened successfully; a tested storage filename returned 404. Findings use the official listing. Grade allocation: 11/12. Exact track substitutions and completion before testing require separate verification.
15. **K to 12 SHS Core Curriculum: Oral Communication in Context**, https://depedwebsitestorage.blob.core.windows.net/upload/2019/01/SHS-Core_Oral-Communication-CG.pdf. Publisher: Department of Education, official website storage endpoint. Guide version: December 2013. Accessed October 4, 2026. Confidence: official curriculum. Outcome: web opener recovered the valid seven-page PDF and its text. The older deped.gov.ph path returned 404 through direct HTTP. Relevant pages: 1-4; grade allocation: 11/12.
16. **Strengthened SHS Curriculum: General Mathematics, Grade 11**, https://www.deped.gov.ph/wp-content/uploads/GENERAL-MATHEMATICS-1.pdf. Publisher: Department of Education. Guide date not stated on the retrieved cover. Accessed October 4, 2026. Confidence: official curriculum, with version limitation. Outcome: current index [9] links this guide; direct Mozilla/5.0 HTTP returned 200 and a valid eight-page PDF. Pages 1-6 were read in memory. Its quarterly organization does not establish that this exact revision was taught in every 2025-2026 pilot school.
17. **Strengthened SHS Curriculum: General Science, Grade 11**, https://www.deped.gov.ph/wp-content/uploads/GENERAL-SCIENCE-1.pdf. Publisher: Department of Education. Guide date not stated on the retrieved cover. Accessed October 4, 2026. Confidence: official curriculum, with version limitation. Outcome: current index [9] links this guide; direct Mozilla/5.0 HTTP returned 200 and a valid eight-page PDF. Pages 1-8 were read in memory. Exact pilot-school revision applicability remains unverified.
18. **Strengthened SHS Curriculum: Effective Communication, Grade 11**, https://www.deped.gov.ph/wp-content/uploads/Effective-Communication-1.pdf. Publisher: Department of Education. Guide date not stated on the retrieved cover. Accessed October 4, 2026. Confidence: official curriculum, with version limitation. Outcome: current index [9] links this guide; direct Mozilla/5.0 HTTP returned 200 and a valid nine-page PDF. Pages 1-8 were read in memory. Page 2 identifies separate English and Filipino strands within a core subject for all Grade 11 learners. This is a school-language rule, not a USTET language rule.
19. **USTET Reviewer and Exam Guide**, https://edgeprep.ph/ustet-exam-guide. Publisher: EdgePrep PH. Page says updated July 2026; accessed October 4, 2026. Confidence: weak, unofficial reviewer. Outcome: live page opened successfully. It describes topic families and item styles, but its statement that UST does not publish an exam/grades ratio conflicts with official source [1]. Its item counts, timing, proportions, and weighting claims are not adopted. No official sample provenance was demonstrated.
20. **K to 12 SHS STEM Specialized Subject: Pre-Calculus Curriculum Guide**, https://lrmds.deped.gov.ph/detail/14427. Publisher: Department of Education. Portal publication: September 21, 2018. Accessed October 4, 2026. Confidence: official curriculum classification. Outcome: live listing opened successfully. It identifies Grade 11 STEM-specialized preparation, not a common-core course or USTET requirement.
21. **K to 12 SHS STEM Specialized Subject: Biology 1 Curriculum Guide**, https://lrmds.deped.gov.ph/detail/14410. Publisher: Department of Education. Portal publication: September 20, 2018. Accessed October 4, 2026. Confidence: official curriculum classification. Outcome: live listing opened successfully. It identifies Grades 11/12 STEM-specialized preparation; its more detailed cellular competencies are not promoted to universal USTET requirements.

## 2. Subtests

College-entry USTET has the following subtests. The current portal's LEAPMed section independently lists the same four; LEAPMed's separate examination is outside this USTET map. [1, official]

- **English:** confirmed subtest; actual item language unknown from the opened organizer pages. Its name alone is not a published language rule. [1, official for subtest; unknown for language]
- **Mathematics:** confirmed subtest; item language unknown. [1, official for subtest; unknown for language]
- **Science:** confirmed subtest; item language unknown. [1, official for subtest; unknown for language]
- **Mental Ability:** confirmed subtest; verbal/nonverbal composition and item language unknown. [1, official for subtest; unknown for language]

## 3. Required topics and skills

The organizer confirms subject disciplines, not a detailed topic syllabus. Curriculum lines below are inferred preparation candidates, not exam requirements. These legacy Grade 7-10 guides support Philippine K to 12 preparation; they do not prove every eligible applicant completed the same program or mastered each skill. [1, 5-8, official sources; curriculum inference]

### English

**Confirmed**

- English is a college USTET discipline; no finer topic list was found in the opened organizer pages. [1, official]

**Supported, curriculum: completed junior high school preparation**

- Reading: identify key ideas, author purpose, explicit and implied information; interpret diagrams and other non-linear texts; draw conclusions from details. [7, PDF pp. 216, 235; official curriculum, inferred relevance]
- Critical reading: evaluate reasoning and supporting details; recognize bias and distinguish claims from evidence. [7, PDF pp. 214, 231; official curriculum, inferred relevance]
- Vocabulary: interpret context clues, including definitions, restatements, synonyms, and antonyms. [7, PDF p. 205; official curriculum, inferred relevance]
- Grammar and usage: apply punctuation, capitalization, modals, active/passive constructions, and direct/indirect speech. [7, PDF pp. 205, 212, 214, 237; official curriculum, inferred relevance]
- Text organization and literary meaning: use cohesion and coherence; identify tone, mood, technique, and author purpose. These competencies do not establish an essay-writing or literature-recall USTET item type. [7, PDF p. 237; official curriculum, inferred relevance]

**Supported, curriculum: SHS preparation with cohort and scheduling limits**

- Existing curriculum, reading and writing: distinguish organization patterns, coherent discourse, claims of fact/policy/value, and evidence for assertions and counterclaims; identify academic text purposes. Grades 11/12 scheduling means pre-test completion is not universal. [11; official curriculum, inferred relevance, completion unverified]
- Existing curriculum, oral communication concepts: recognize speaker purpose, speech context/style, speech acts, communication breakdown, and repair strategies. Written knowledge of these concepts does not establish an oral USTET task. Grades 11/12 allocation limits completion claims. [15, PDF pp. 1-4; official curriculum, inferred relevance, completion unverified]
- Strengthened curriculum candidates: infer intent, main messages, implicit meaning, and bias; interpret charts, tables, and unfamiliar academic vocabulary; use cohesive language and citation ethics. The retrieved revision's match to the already-completed pilot Grade 11 curriculum is unverified. [18, PDF pp. 3-7; official curriculum, inferred relevance, version limited]

**Supported, weak**

- Vocabulary in context, grammar/sentence usage, reading passages, and verbal reasoning are reviewer-described preparation areas. No finer tested skill boundaries are verified. [19; weak]

**Unknown**

- Current-cycle detailed English syllabus, tested reading genres, passage length, vocabulary range, listening/speaking tasks, literary recall, and depth are unknown. Organizer silence does not exclude these areas. [1-3; unknown]

### Mathematics

**Confirmed**

- Mathematics is a college USTET discipline; no finer topic list was found in the opened organizer pages. [1, official]

**Supported, curriculum: completed junior high school preparation**

- Numbers and measurement: use integers, fractions, decimals, ratios/proportions, and percentages; use sets and the real-number system; convert measurement units. These include Grade 6 prerequisites as well as Grade 7 concepts. [5, PDF p. 8; official curriculum, inferred relevance]
- Algebra: manipulate expressions, factor polynomials, and solve linear equations, inequalities, and systems; solve rational and quadratic equations and inequalities. [5, PDF p. 8; official curriculum, inferred relevance]
- Functions and patterns: interpret quadratic and polynomial functions, sequences, series, radicals, and variation. [5, PDF p. 8; official curriculum, inferred relevance]
- Geometry and trigonometry: use polygon properties, congruence, triangle inequalities, similarity, parallel/perpendicular lines, circles, coordinate geometry, and introductory trigonometry. [5, PDF p. 8; official curriculum, inferred relevance]
- Statistics and probability: interpret collected data and graphs, central tendency, variability, and position; reason about simple events and combinatorics. [5, PDF p. 8; official curriculum, inferred relevance]

**Supported, curriculum: SHS preparation with cohort and scheduling limits**

- Existing Grade 11 General Mathematics: model and evaluate functions, find domain/range, graph and solve rational, inverse, exponential, and logarithmic relationships. [10; official curriculum, inferred relevance]
- Existing Grade 11 financial mathematics: calculate interest, present/future value, annuities, and loan payments; interpret stocks and bonds. [10; official curriculum, inferred relevance]
- Existing Grade 11 logic: use propositions and truth values; evaluate conditional statements, syllogisms, fallacies, and proof/counterexamples. Mapping these skills to Mathematics is curriculum-based, not proof of their USTET subtest placement. [10; official curriculum, inferred relevance]
- Existing Grades 11/12 Statistics and Probability: distinguish random variables, model distributions, use normal probabilities, sampling, estimation, hypothesis testing, correlation, and regression. Completion before the test is not established. [12; official curriculum, inferred relevance, completion unverified]
- Strengthened curriculum candidates: solve percentage/payroll problems, sequences/series, financial applications, measurement/conversion, function models, descriptive statistics, practical trigonometry, and basic random-variable/normal-distribution/sampling problems. Exact prior pilot revision applicability remains unverified. [16, PDF pp. 2-6; official curriculum, inferred relevance, version limited]

**Supported, weak**

- Algebra, geometry, trigonometry, and basic statistics/quantitative problem solving appear in the reviewer's topic list. No detailed official depth is established. [19; weak]

**Unknown**

- Current-cycle mathematical depth, calculator rules, advanced calculus inclusion, topic weights, and which Grade 12 topics are expected by each testing date are unknown. [1-3; unknown]

### Science

**Confirmed**

- Science is a college USTET discipline; no finer topic list was found in the opened organizer pages. LEAPMed's separate named subject areas do not establish ordinary USTET topic scope. [1, official]

**Supported, curriculum: completed junior high school preparation**

- Scientific inquiry: identify variables, controls, evidence, and conclusions in an investigation; read data and representations. [6, PDF pp. 4, 7, 106; official curriculum, inferred relevance]
- Matter and chemistry: distinguish mixtures and substances; explain particles, elements, compounds, bonding, gas behavior, and chemical changes; balance equations and solve simple mole/mass relationships. [6, PDF p. 10; official curriculum, inferred relevance]
- Cells and organisms: relate cells, tissues, organs, and systems; explain digestion, respiration, circulation, and biological feedback. [6, PDF p. 12; official curriculum, inferred relevance]
- Heredity, evolution, and ecology: explain cell division, inheritance and DNA, variation/natural selection, food-energy relationships, photosynthesis/respiration, and ecosystem interactions. [6, PDF pp. 12-13; official curriculum, inferred relevance]
- Force, motion, and energy: interpret motion graphs; apply Newton's laws, work, momentum, mechanical energy, heat transfer, waves/light, and electricity/magnetism. [6, PDF p. 14; official curriculum, inferred relevance]
- Earth and space: explain plate boundaries, earthquakes, volcanoes, weather/climate, seasons, eclipses, and solar-system relationships. [6, PDF pp. 7-8, 176; official curriculum, inferred relevance]

**Supported, curriculum: SHS preparation with cohort and track limits**

- Existing Earth and Life Science: explain Earth systems, rocks/minerals, resources, geologic hazards, cellular energy, heredity, evolution, and ecosystems. The official catalog calls it core, but does not establish universal delivery without track substitutions or Grades 11/12 scheduling checks. [13; official curriculum, inferred relevance, track/completion limited]
- Existing Physical Science: relate atomic and molecular structure to properties, calculate reaction quantities, yield and limiting reactants, explain reaction rates/energy, interpret motion, light, and astronomy models. Track substitutions and pre-test completion remain unverified. [14; official curriculum, inferred relevance, track/completion limited]
- Strengthened curriculum candidates, physics: apply linear/rotational motion, machine efficiency, fluid principles, electricity safety/efficiency, and light/sound properties. [17, PDF pp. 2-3; official curriculum, inferred relevance, prior pilot version unverified]
- Strengthened curriculum candidates, chemistry: interpret product composition, reaction types, metabolism, solutions, and safe chemical handling. [17, PDF pp. 4-5; official curriculum, inferred relevance, prior pilot version unverified]
- Strengthened curriculum candidates, biology: relate structures to functions, cellular energy, coordinated organ systems, and ecosystem/climate effects. [17, PDF p. 6; official curriculum, inferred relevance, prior pilot version unverified]
- Strengthened curriculum candidates, Earth and space: explain Earth's life-supporting conditions, Philippine geology, Earth materials, and hazard mitigation. [17, PDF pp. 7-8; official curriculum, inferred relevance, prior pilot version unverified]

**Supported, weak**

- Biology, chemistry, physics, and Earth science appear in the reviewer's topic list. The reviewer provides broad families, not a verified USTET syllabus. [19; weak]

**Unknown**

- Current-cycle science topic boundaries, quantitative depth, specialized SHS science inclusion, and the expected completion of Grade 12 content are unknown. [1-3; unknown]

### Mental Ability

**Confirmed**

- Mental Ability is a separate USTET subtest; the organizer does not publish its component skills in the opened pages. [1, official]

**Supported, curriculum**

- No specific curriculum competency is assigned to this subtest without evidence connecting it to Mental Ability. General school reasoning skills alone do not establish its composition. [1, 5-7; unknown for the connection]

**Supported, weak**

- Patterns and sequences: identify a rule and relationships in a sequence. Exact numerical versus visual mix is unverified. [19; weak]
- Logical relationships and spatial reasoning: reason about relationships and spatial information. The reviewer labels this section nonverbal; that claim is not organizer-confirmed. [19; weak]

**Unknown**

- Official confirmation of verbal, numerical, logical, abstract, spatial, and mechanical reasoning inclusion, item language, and required difficulty remains unknown. The weak-supported areas above remain provisional. [1-3, 19; unknown officially]

## 4. Format profile

| Entry | Value | Source | Checked | Confidence |
|---|---|---|---|---|
| Choices per item | unknown; no organizer sample or choice-count statement located | [1-3] | October 4, 2026 | unknown |
| Item types per subtest | Reviewer describes multiple-choice questions in all four subtests; official item-type specification and any additional types remain unknown | [19], checked against [1-3] | October 4, 2026 | unknown |
| "None of the above" style | unknown; no verified official examples | [1-3] | October 4, 2026 | unknown |
| "All of the above" style | unknown; no verified official examples | [1-3] | October 4, 2026 | unknown |
| Negative stems ("NOT", "EXCEPT") | unknown; no verified official examples | [1-3] | October 4, 2026 | unknown |
| Language per subtest | unknown officially. Reviewer labels English, Mathematics, and Science English, and Mental Ability nonverbal, but elsewhere says all sections are administered in English. School-language guides do not resolve this | [19] conflicts internally; [1-3, 18] do not establish exam languages | October 4, 2026 | unknown |
| Timing that affects item length | unknown; no organizer statement connecting timing to stem/passage length was located; reviewer timing claims are not adopted | [1-3, 19] | October 4, 2026 | unknown |
| Subtest mix by proportion | unknown; do not calculate proportions from reviewer counts | [1-3, 19] | October 4, 2026 | unknown |
| Topic weights | unknown; no verified subject/topic allocation found | [1-3] | October 4, 2026 | unknown |
| Delivery | Testing at designated physical centers is confirmed. Paper versus computer response medium remains unknown from the opened official materials. Online application does not establish online testing | [1, 4] | October 4, 2026 | official |
| Scoring and wrong-answer penalty | Overall admission rating: 80% entrance test score and 20% computed English/Mathematics/Science grades. Raw-item scoring, subtest scaling/combination, Mental Ability treatment, and wrong-answer penalty remain unknown. This is not a topic/subtest weight | [1]; conflicting reviewer statement [19] loses to organizer | October 4, 2026 | official |

## 5. Version and cycle notes

- Current official announcements identify A.Y. 2027-2028. [2, official]
- The live portal mixes current schedules with an older FAQ. FAQ 17's general Grade 11/current-grade preparation guidance is retained as older-cycle organizer guidance, not a current detailed syllabus. [1, official with cycle limitation]
- No verified change to the four USTET subtests was found. A current detailed topic list remains unknown. [1, 2; unknown for changes and detailed scope]
- Online review material does not become official merely because it uses USTET's name. [3, official]
- A.Y. 2027-2028 college applicants currently in Grade 12 include existing-curriculum learners and continuing strengthened-curriculum pilot learners. They do not share one identical SHS topic sequence. Non-pilot Grade 12 retains the existing curriculum in SY 2026-2027; pilot schools continue the strengthened curriculum. [1, 2, 8, official; cohort linkage inferred]
- Legacy General Mathematics is Grade 11 core; other opened SHS core guides allow Grades 11/12. Their full content cannot be described as already studied by every test taker. Current strengthened guides also need pilot-revision matching before asserting prior exposure. [10-18; official curriculum, exposure limitation]
- STEM Pre-Calculus and Biology 1 are specialized, rather than universal core preparation. Their full scope is not added to this exam's confirmed requirements. The same restraint applies to unverified advanced content and to applicants from foreign schools, earlier graduating cohorts, or alternative pathways. [1, 20, 21; official classification, applicability limitation]
- No official Filipino subtest appears in the published four-subtest list. This does not establish that every item is in English or that Filipino-language material is excluded within a subtest. Effective Communication's bilingual curriculum does not answer the exam-language question. [1, 18; official subject list, language unknown]
- The accessible evidence cannot establish a complete USTET syllabus or full coverage of this exam. Curriculum breadth and reviewer labels remain preparation evidence only. [1-3, 5-21; scope/depth unknown]

## 6. Open questions

1. **Current detailed syllabus:** obtain a dated A.Y. 2027-2028 topic or competency list if UST publishes one. Current official evidence confirms subjects; it does not verify exhaustive topics or required depth. [1-3; unknown]
2. **Cycle continuity:** the current portal retains FAQ content labeled August 8, 2025. Confirm whether its preparation guidance applies unchanged to the new cycle and to strengthened-curriculum pilot applicants. [1, 2, 8; unknown]
3. **Item languages and types:** official choice count, item examples, negative-stem conventions, and language rules are unknown. The weak reviewer has inconsistent language statements. [1-3, 19; unknown]
4. **Delivery and scoring:** response medium, raw-item scoring, Mental Ability's contribution or threshold, wrong-answer penalty, and subtest scaling remain unknown. Keep the published 80/20 admission ratio separate from mock composition. [1, 4, 19; unknown for missing rules]
5. **Curriculum exposure:** verify the actual 2025-2026 pilot guide revisions, course schedules, and science track substitutions before treating any SHS list as preparation already met by all current applicants. The accessible junior high school guides are a common Philippine-curriculum baseline, not a universal biography of all eligible takers. [1, 8-18, 20, 21; exposure unknown]
6. **Guide access limitations:** legacy Statistics and Probability, Earth and Life Science, and Physical Science PDF storage guesses returned 404; their official competency listings were read instead. The older core-subject index path returned 404 through direct HTTP. No content from failed responses or retained invalid HTML scratchpads is evidence. [12-14; PDF access incomplete]
7. **Unpublished composition:** subtest proportions, topic weights, and any timing-to-item-length constraints remain unknown. Bounded organizer/source searches found no usable published specification; do not infer values from commercial mock tests. [1-3, 19; unknown]
8. **Required next checks:** independent source checking and organizer-only requirement rebuild remain pending. No lesson bodies, quizzes, overlap, structure, or content standards were audited in this assignment.

Lead source resolution, October5,2026: independently downloaded and read the three official notice images[3,4] and DM012 scan[8]. Advisory image1 disclaims official status/endorsement of AY2027-2028 circulating review materials; image2 directs readers to official channels. Reminder image gives transparent-container rules, no response-medium specification. DM012 PDFp1 paragraphs4-5 retain existing Grade12 curriculum except continuing strengthened pilot learners. Download hashes/paths are recorded in source-access-evidence.json. Image extraction was used to read published sources, not computer control.
