# CSE Subprofessional requirements and format profile

Status: Research complete, awaiting source check and rebuild. Level 1 only. No acceptance or coverage claim.

Actual access date: October 5, 2026, Asia/Manila. Tool clock at startup: October 4, 2026, 17:27 UTC, equivalent to October 5, 2026, 01:27 Manila.
Policy: current main `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`.
Workstream: `docs/content-coverage-audit-r1`, observed HEAD `63147ad7b6eefa596a38248a58fa07c4b3394ed4`.
Corpus input: `765c5dc0fa5586281047bf4f7b30d09ab3707887`, not read for this requirements assignment.
The lead verified live main; fetch is blocked by read-only Git metadata. No Git mutation attempted. This assignment changes this report only.

## 1. Sources

1. **Examination Announcement No. 03, s. 2026: Conduct of 09 August 2026 CSE-PPT**, CSC, published April 20, 2026. [Announcement page](https://www.csc.gov.ph/examination-advisories/examination-announcement-no-03-s-2026-conduct-of-career-service-examination-pen-and-paper-test-cse-ppt-for-professional-and-subprofessional-levels-09-august-2026). Accessed October 5, 2026 Manila. Confidence: official. Outcome: HTML opened; links to the signed announcement. Supports cycle identity; coverage comes from source 2.
2. **Signed Examination Announcement No. 03, s. 2026**, CSC. [PDF](https://csc.gov.ph/phocadownload/userupload/erpo/announcements/2026/ExamAnn_2026_03_Conduct%20of%2009%20Aug%202026%20CSE-PPT_orig%20signed.pdf). Accessed October 5, 2026 Manila. Confidence: official. Outcome: 10-page PDF opened with extracted text. Page 7, sections F and G, supplies scope and passing rating. Page 8 supplies review-material disclaimer; page 9 prohibits calculators. The two-column scope assigns Clerical Ability to Subprofessional and Analytical Ability to Professional.
3. **Examination Announcement No. 08, s. 2025: 2026 PPT Exam Calendar**, CSC, published September 25, 2025. [Page](https://www.csc.gov.ph/examination-advisories/examination-announcement-no-08-s-2025-2026-ppt-exam-calendar). Accessed October 5, 2026 Manila. Confidence: official. Outcome: HTML opened. Regular CSE-PPT cycles listed for March 8 and August 9, 2026.
4. **Examination Advisory No. 02, s. 2026: School Assignment and Important Reminders for 08 March 2026 CSE-PPT**, CSC, signed February 18, 2026; landing page published February 23, 2026. [PDF](https://csc.gov.ph/phocadownload/userupload/erpo/advisories/2026/ExamAdvisory_2026_02_School%20Assignment%20Impt%20Reminders%20for%2008%20March%202026%20CSE-PPT%20Sgd.pdf). Accessed October 5, 2026 Manila. Confidence: official. Outcome: six-page PDF opened. Pages 4 and 5 distinguish the two levels; page 5 records Subprofessional test proper, descriptive questionnaire, and time limit.
5. **CSC issues Rules on Grant of Additional Points for Qualified Government Workers**, CSC, published July 13, 2026. [Page](https://csc.gov.ph/csc-issues-rules-on-grant-of-additional-points-for-qualified-government-workers). Accessed October 5, 2026 Manila. Confidence: official. Outcome: HTML opened. Describes CSC Resolution No. 2600729, May 25, 2026, and conditional eligibility preference ratings. This is a separate application route, not an item-scoring formula.

6. **Examination Advisory No. 10, s. 2026: School Assignment and Important Reminders for 09 August 2026 CSE-PPT**, CSC, signed July 16, 2026; landing page published July 23, 2026. [PDF](https://csc.gov.ph/downloads/examination/category/552-2026?download=3801:examination-advisory-no-10-s-2026-school-assignment-and-important-reminders-for-examinees-of-the-09-august-2026-career-service-examination-pen-and-paper-test-cse-ppt). Accessed October 5, 2026 Manila. Confidence: official. Outcome: eight-page PDF opened. Page 6 confirms scope and counts; page 7 confirms time limit. Page 5 says the examinee guide is reached through ONSA and is for examinees' exclusive use; that guide was not retrieved.
7. **09 August CSE PPT Cancellation**, CSC NCR, published August 9, 2026. [Page](https://csc.gov.ph/regional-offices/ncr/09-august-cse-ppt-cancellation). Accessed October 5, 2026 Manila. Confidence: official. Outcome: HTML opened. Confirms suspension at all NCR testing centers; does not establish a replacement cycle's content.
8. **CSC Exam Portal, Subprofessional Computer Examination result record**, CSC. [Record](https://exam.csc.gov.ph/detail_examinee.php?id=458212). Accessed October 5, 2026 Manila. Confidence: official. Outcome: HTML opened; computer-delivered CSE Subprofessional dated February 3, 2026 appears in the official record. Personal identity is not copied here. This record establishes a computer administration, not its test content, item format, or current booking availability.
9. **CSC releases 1st semester 2019 COMEX schedule**, CSC, published January 9, 2019. [Article](https://csc.gov.ph/csc-releases-1st-semester-2019-comex-schedule). Accessed October 5, 2026 Manila. Confidence: official. Outcome: HTML opened; describes COMEX as computer administration of CSE and lists separate Subprofessional dates. Historical context only. Access gaps on the same date: [COMEX overview](https://comex.csc.gov.ph/user/help/index.html) failed with 523; [COMEX FAQ](https://comex.csc.gov.ph/user/faq/index.html) and [reservation list](https://comex.csc.gov.ph/user/reservation/list) returned tool fetch errors. Their snippets are not evidence of current availability.
10. **K to 12 Mathematics Curriculum Guide, Grades 1 to 10**, DepEd, August 2016 edition. [PDF](https://www.deped.gov.ph/wp-content/uploads/2019/01/Math-CG_with-tagged-math-equipment.pdf). Accessed October 5, 2026 Manila. Confidence: official for curriculum, not exam scope. Outcome: 257-page PDF opened in web reading and verified via HTTP 200, PDF signature and in-memory extraction. Page 6 names whole numbers, fractions, decimals, ratio, proportion, percent, integers, sequences, and simple equations by the end of Grade 6. Pages 106-112 include arithmetic and fractions competencies; pages 160, 164 and 190 cover percent, sequence rules and ratio/integer preparation.
11. **K to 12 English Curriculum Guide, Grades 1 to 10**, DepEd, May 2016 edition. [PDF](https://www.deped.gov.ph/wp-content/uploads/2019/01/English-CG.pdf). Accessed October 5, 2026 Manila. Confidence: official for curriculum, not exam scope. Outcome: web retrieval failed; non-UI HTTP with Mozilla/5.0 returned 200, application/pdf, PDF signature, 247 pages, extracted in memory. Pages 87-88 include context clues, significant details, sequencing, and clear grammatical sentences. Page 15 includes spelling using phonic, semantic and morphemic knowledge. Pages 103 and 106 support context clues, main idea, supporting details and subject-verb agreement.
12. **K to 12 Filipino Gabay Pangkurikulum, Baitang 1 to 10**, DepEd, May 2016 edition. [PDF](https://www.deped.gov.ph/wp-content/uploads/2019/01/Filipino-CG.pdf). Accessed October 5, 2026 Manila. Confidence: official for curriculum, not exam scope. Outcome: web retrieval failed; non-UI HTTP with Mozilla/5.0 returned 200, application/pdf, PDF signature, 190 pages, extracted in memory. Pages 82 and 84-86 contain word meaning, outlining, verb time, prediction from listened-to text, descriptive paragraph writing, and adverbial usage. Page 120 contains sequencing of a read informational text, and page 140 lists connectors for cause/effect and persuasion. Listening and writing competencies are background preparation, not evidence of matching exam delivery.
13. **K to 12 Araling Panlipunan Gabay Pangkurikulum, Baitang 1 to 10**, DepEd, May 2016 edition. [PDF](https://www.deped.gov.ph/wp-content/uploads/2019/01/AP-CG.pdf). Accessed October 5, 2026 Manila. Confidence: official for curriculum, not exam scope. Outcome: HTTP 200, application/pdf, PDF signature, 240 pages, extracted in memory. Rights, duties, and community environmental issues appear at pages 55-57 and 65. Pages 138 and 142 include human-rights challenges during martial law and social/environmental issues; these are historical curricular topics, not confirmed CSE item selections.
14. **K to 12 Science Curriculum Guide, Grades 3 to 10**, DepEd, August 2016 edition. [PDF](https://www.deped.gov.ph/wp-content/uploads/2019/01/Science-CG_with-tagged-sci-equipment_revised.pdf). Accessed October 5, 2026 Manila. Confidence: official for curriculum, not exam scope. Outcome: HTTP 200, application/pdf, PDF signature, 203 pages, extracted in memory. Pages 4, 7 and 13 support environmental protection, conservation, and human impacts on ecosystems as preparation only.

15. **FAQs on the MATATAG Curriculum**, DepEd; publication date not established from the retrieved PDF. [PDF](https://www.deped.gov.ph/wp-content/uploads/FAQs-ON-THE-MATATAG-CURRICULUM.pdf). Accessed October 5, 2026 Manila. Confidence: official for curriculum transition, not exam scope. Outcome: web returned 403; Mozilla/5.0 HTTP returned 200, application/pdf, PDF signature, five pages, extracted in memory. Page 3 describes phased implementation from SY 2024-2025, with a stated full-implementation year of SY 2026-2027; other grades follow MELCs-based curriculum until their phase. This explains why the 2016 guides are historical preparation references, not a single present-day cohort blueprint.
16. **Civil Service Exam Reviewer 2024 [Free PDF Downloads]**, FilipiKnow. [Page](https://filipiknow.net/civil-service-reviewer/comment-page-1/). Publication date not established; page title says 2024, internal reviewer heading says 2023. Accessed October 5, 2026 Manila. Confidence: weak. Outcome: HTML opened, including separate Clerical/Subprofessional and Analytical/Professional sections. Reviewer gives additional grammar, math and General Information preparation topics, but its language/count claims conflict with or exceed current official detail.
17. **Alphabetizing Rules for Clerical Operations**, FilipiKnow, Jewel Kyle Fabula; publication date not established. [Page](https://filipiknow.net/alphabetical-filing/). Accessed October 5, 2026 Manila. Confidence: weak. Outcome: HTML opened; sections 1-9 show rules/examples for personal and organization names. No CSC endorsement or official filing-convention adoption established.
18. **Clerical Ability Practice Test, Set 1: Alphabetical Filing**, FilipiKnow; publication date unknown, URL directory June 2021. [PDF](https://filipiknow.net/wp-content/uploads/2021/06/Clerical-Ability-Practice-Test-Set-1.pdf). Accessed October 5, 2026 Manila. Confidence: weak. Outcome: seven-page PDF opened. Page 1 has four lettered answer arrangements for name-ordering tasks; later pages continue business/name tasks. These are reviewer examples, not actual CSC items.
19. **General Information Practice Test, Set 1**, FilipiKnow; publication date unknown, URL directory June 2021. [PDF](https://filipiknow.net/wp-content/uploads/2021/06/General-Information-Practice-Test-Set-1.pdf). Accessed October 5, 2026 Manila. Confidence: weak. Outcome: five-page PDF opened. Page 1 has A-E choices with "None of the above" and NOT stems; page 5, item 20, has EXCEPT. Used only for reviewer format and topic-family evidence; answers/facts not validated.
20. **Verbal Ability Practice Questions, Set 1: Identifying Errors**, FilipiKnow; publication date unknown, URL directory November 2020. [PDF](https://filipiknow.net/wp-content/uploads/2020/11/Verbal-Ability-Practice-Questions-Set-1-1.pdf). Accessed October 5, 2026 Manila. Confidence: weak. Outcome: three-page PDF opened. Page 1 has error-location choices, usually A-E with a no-error option; item 4 uses A-D. Used only for format examples, not answer correctness or current CSC choice count.
21. **Correct Spelling, Idiomatic Expressions with Meaning and Examples**, Civil Service Reviewer - Professional and Sub Professional, Blogger, published November 21, 2018; individual author not established. [Page](https://csreviewer-profandsubprof.blogspot.com/2018/11/correct-spelling-idiomatic-expressions.html). Accessed October 5, 2026 Manila. Confidence: weak. Outcome: HTML opened. Idiom item 1 shows four choices and "none of the above"; item 9 uses "All of the above." Shared-level title does not verify Subprofessional attribution or current exam use. This is a historical style lead only.

22. **CSC Exam Portal and CS Digital Exam (CSDEx) 2026 results interface**, CSC; publication date not established. [Portal](https://exam.csc.gov.ph/) and [CSDEx page](https://exam.csc.gov.ph/list_passers?type_id=36). Accessed October 5, 2026 Manila. Confidence: official. Outcome: both HTML pages opened. Portal lists Computer Examination and CS Digital Exam separately, with 2026 links. The page does not publish content, timing or scoring. Subprofessional coverage/availability for CSDEx was not established. A separately opened [CSC CAR COMEX notice](https://www.csc.gov.ph/regional-offices/car/examination/comex-1), published September 24, 2025, concerns last-quarter 2025 slots, not a current 2026 scope statement.

## 2. Subtests and languages

CSC calls these examination coverage areas. Separate timed subtests or their order are unknown. The August advisory corroborates the scope below. [2, 4, 6; official]

- General Information: English. [2, 4; official]
- Verbal Ability: English and Filipino; allocation between languages unknown. [2, 4; official]
- Numerical Ability: English. [2, 4; official]
- Clerical Ability: English. [2, 4; official]

## 3. Required topics and skills

### Confirmed

These are the organizer's named topics, not a detailed competency blueprint. Required depth and finer skills remain unknown. [2, 4; official]

**General Information**

- Philippine Constitution: constitutional knowledge; specific articles and depth unknown. [2, 4; official]
- Code of Conduct and Ethical Standards for Public Officials and Employees, R.A. 6713: knowledge of this code; provision-level selection unknown. [2, 4; official]
- Peace and human rights issues and concepts: topic named; specific issues, instruments, and depth unknown. [2, 4; official]
- Environment management and protection: topic named; specific laws and concepts unknown. [2, 4; official]

**Verbal Ability, in English and Filipino**

- Word meaning: determine meaning. [2, 4; official]
- Sentence completion: complete sentences. [2, 4; official]
- Error recognition: recognize errors. [2, 4; official]
- Sentence structure: work with sentence structure. [2, 4; official]
- Paragraph organization: organize paragraphs. [2, 4; official]
- Reading comprehension: understand reading material. [2, 4; official]

**Numerical Ability**

- Basic operations: perform basic operations. [2, 4; official]
- Number sequence: recognize or complete number sequences. [2, 4; official]
- Word problems: solve word problems. [2, 4; official]

**Clerical Ability**

- Filing: filing skills; exact ordering conventions unknown. [2, 4; official]
- Spelling: English spelling; vocabulary range unknown. [2, 4; official]

### Supported, curriculum

The following are curriculum-backed preparation inferences. The guides are common elementary/JHS learning areas, not STEM-only or other SHS strand requirements. No CSC source adopts these guides as a detailed test blueprint. No claim says every adult examinee studied the same curriculum. [2, 4, 6, 10-15; curriculum support only]

**Numerical Ability**

- Arithmetic: use whole numbers, fractions, decimals and integers with basic operations; ratio, proportion and percent support word-problem preparation. Specific number domains are not separately confirmed by CSC. [10 p. 6 and pp. 106-112, 160 and 190; official curriculum, inferred]
- Patterns: recognize sequences, formulate a rule for the next term, and use simple equations to represent numerical relationships. CSC confirms number sequences, not these curriculum boundaries or difficulty. [2, 10 pp. 6 and 164; official curriculum, inferred]

**Verbal Ability**

- English meaning and comprehension: use context clues including synonyms/antonyms/word parts; identify main ideas and supporting details; sequence events. [11 pp. 87-88, 103 and 106; official curriculum, inferred]
- English grammar: construct clear sentences with appropriate grammatical structures, including subject-verb agreement and verb aspects. [11 pp. 88, 103 and 106; official curriculum, inferred]
- Filipino vocabulary: determine meaning through synonyms; grammar: use verbs by time and adverbial phrases appropriately. [12 pp. 82, 84 and 86; official curriculum, inferred]
- Filipino organization: outline a read text, sequence events in read informational text, and use cause/effect connectors. Paragraph writing and inference from listened-to texts offer related preparation, not proof of exam delivery. [12 pp. 82, 84-85, 120 and 140; official curriculum, inferred]

**Clerical Ability**

- English spelling: spell multisyllabic words with phonics, meaning and word-part knowledge. Exact CSC word difficulty remains unknown. [11 p. 15; official curriculum, inferred]
- Specialized filing rules: unknown; no relevant DepEd competency established in the selected guides.

**General Information**

- Rights and responsibilities: relate rights to duties in the community; examine historical human-rights challenges. These do not specify which events CSC selects. [13 pp. 55-57 and 138; official curriculum, inferred]
- Environment: identify community environmental problems, protect and conserve species/resources, and consider human impacts on ecosystems. [13 p. 65; 14 pp. 4, 7 and 13; official curriculum, inferred]
- R.A. 6713-specific curriculum support: unknown; organizer explicitly names the law, but this curriculum pass does not establish provision-level teaching. [2, 13; unknown]

### Supported, weak

The following are reviewer preparation suggestions only. Higher-ranked CSC scope/language wins when reviewer claims conflict. None supplies verified topic weights, finer requirements or answer correctness. [2, 4, 6, 16-21; weak]

**General Information**

- Constitution: prepare state principles, Bill of Rights, branches of government, and officers' powers/qualifications. These are reviewer's finer topic choices inside the broad named area. [16, General Information; 19 pp. 1-3; weak]
- R.A. 6713: review conduct norms, duties, prohibited acts, disclosures and penalties. Specific provisions tested remain unverified. [16, General Information; 19 pp. 2-3; weak]
- Human rights/environment: reviewer examples refer to international rights instruments and environmental protection laws; current-event inclusion and cutoff remain unknown. [16, General Information; 19 pp. 4-5; weak]

**Verbal Ability**

- Grammar/vocabulary: reviewer suggests parts of speech, punctuation, pronoun agreement, verb tense, parallelism, synonyms, antonyms, homonyms and word-part meaning. Some overlap with curriculum, but the full finer list is not CSC-confirmed. [16, Verbal Ability; 20 p. 1; weak]
- Idioms: select an expression's meaning in historical shared-level practice. Not verified as a separate current Subprofessional requirement. [21 items 1-10; weak]

**Numerical Ability**

- Additional preparation: factors/multiples, divisibility, algebraic expressions, exponents, factoring, equations, inequalities, area/volume, central tendency, probability and graphs appear in the shared-level reviewer. The reviewer's list is broader than CSC's three named topics; inclusion/depth remain unconfirmed. [16, Numerical Ability; weak]

**Clerical Ability**

- Alphabetical filing: arrange personal names using surnames and other name units, and compare business/organization names; reviewer illustrates prefixes, hyphens, titles and suffixes. These specific conventions are not CSC-confirmed. [17 sections 1-9; 18 pp. 1-3; weak]
- Spelling: reviewer suggests applying spelling rules and recognizing misspellings. Exact tested word lists remain unknown. [16, Clerical Ability; weak]

**Conflicts and limits**

- Reviewer 16 says Numerical and Clerical may be in English or Filipino. Current CSC specifies English for those areas; CSC wins. [2, 6; official; 16; weak]
- Reviewer 16 supplies approximate per-area item ranges. Do not adopt them as a verified mix or calculate weights from them. Official counts distinguish test proper from EDQ but publish no subtest shares in the material reviewed. [4, 6; official; 16; weak]
- Reviewer 16 places number sequences in its Professional Analytical section. CSC explicitly lists number sequence under the shared Numerical area, including Subprofessional; retain that confirmed requirement. [2, 6; official; 16; weak]

### Unknown

- All areas: detailed skill depth, topic weights, item distribution, and language distribution unknown. Reviewed organizer scope gives no such blueprint. [2, 4]
- General Information: article/provision lists, named environmental laws, current-events date range, and specific peace/human-rights instruments unknown. [2, 4]
- Verbal Ability: exact grammar categories, word lists, passage lengths/genres, and English/Filipino proportions unknown. [2, 4]
- Numerical Ability: tested number domains, specific word-problem families, and sequence rules unknown. [2, 4]
- Clerical Ability: treatment of prefixes, abbreviations, numerals, organizations, and equal surnames in filing unknown. [2, 4]
- Analytical Ability is listed in the Professional column, not the Subprofessional column. Do not import its separate blueprint here. Organizer silence on related reasoning inside other areas does not prove exclusion. [2, 4; official]

## 4. Format profile

| Entry | Value | Source | Checked | Confidence |
|---|---|---|---|---|
| Choices per item | Official count unknown. Reviewer examples vary: clerical four arrangements; General Information five A-E choices; verbal error-location items mostly five, with a four-choice example. Do not infer a uniform real-test count. | 18 p. 1; 19 p. 1; 20 p. 1 | October 5, 2026 | weak |
| Item types per subtest | Official response formats unknown. Reviewer samples show clerical name-order selection, General Information factual completion/selection, and verbal identification of an erroneous segment or no error. CSC names numerical operations, sequences and word problems but supplies no item specimen here. | 2, 6; 18-20 | October 5, 2026 | weak |
| "None of the above" style | Present in General Information reviewer; historical shared-level idiom reviewer also uses it. Actual current CSC use unknown. | 19 p. 1; 21 item 1 | October 5, 2026 | weak |
| "All of the above" style | Historical shared-level idiom reviewer uses it. Subprofessional-specific and current CSC use unknown. | 21 item 9 | October 5, 2026 | weak |
| Negative stems ("NOT", "EXCEPT") | General Information reviewer uses NOT and EXCEPT. Current CSC frequency/use unknown. | 19 pp. 1 and 5 | October 5, 2026 | weak |
| Language per subtest | Verbal: English and Filipino. General Information, Numerical and Clerical: English. Per-language proportion unknown. | 2, 4 | October 5, 2026 | official |
| Timing that affects item length | March and August 2026 Subprofessional: 2 hours, 40 minutes for test proper. No sectional or per-item time published in reviewed material. | 4 p. 5; 6 p. 7 | October 5, 2026 | official |
| Subtest mix by proportion | unknown; total count is not a proportion | 2, 4 | October 5, 2026 | unknown |
| Topic weights | unknown; passing rating is not a topic weight | 2, 4 | October 5, 2026 | unknown |
| Delivery | CSE-PPT: pen-and-paper. Official result record separately verifies a February 2026 computer-delivered Subprofessional administration; its current scope, booking availability and timing remain unknown. Historical COMEX is computer-delivered. | 1, 3, 4, 8, 9 | October 5, 2026 | official |
| Scoring and wrong-answer penalty | Passing general rating: at least 80.00. Raw-score conversion, scaling/equating and wrong-answer penalty unknown. Separate conditional CSE-PR route exists for qualified government workers; it is not ordinary item scoring. | 2 section G; 5 | October 5, 2026 | official |

Both 2026 advisories distinguish 145 test-proper items from 20 Examinee Descriptive Questionnaire entries, total 165. EDQ concerns personal data. These counts establish neither scored subtest shares nor a raw-score formula. [4 p. 5; 6 pp. 6-7; official]

## 5. Version and cycle notes

- Baseline is August 9, 2026 CSE-PPT, the later regular cycle listed by the 2026 calendar. Future cycles are not verified. [1, 3; official]
- March and August organizer scope lists name the same Subprofessional areas/topics and languages. Their advisories also give the same test-proper count and time. This does not prove item pools or finer topic shares are unchanged. [2, 4, 6; official]
- DepEd guides are 2016 editions. The MATATAG FAQ describes a phased change starting SY 2024-2025; current exam takers need not share one school curriculum. No CSC adoption of MATATAG or a SHS strand curriculum is established. [2, 15; official curriculum, exam linkage unknown]
- Weak reviewer material ranges from 2018 examples to a page titled 2024 with an internal 2023 heading. It is not cycle-specific confirmation for 2026. [16, 21; weak]
- The 2026 calendar moves the first regular CSE-PPT to the second Sunday of March. This is scheduling, not evidence of changed topic scope. [3; official]
- CSE-PR policy published July 2026 expands/streamlines a conditional route for government workers. Detailed grant calculation and effective publication date remain outside the verified item-scoring evidence. [5; official]
- An official portal record verifies a February 2026 computer administration. The portal separately lists Computer Examination and CS Digital Exam (CSDEx). Current Subprofessional computer/CSDEx scope, booking and any CAT-specific format remain unknown. Do not equate these variants or reuse PPT timing/counts for them. [8, 9, 22; official for administration/categories only]
- CSC NCR officially suspended its August administration. A replacement date/content announcement was not verified in accessible official material; do not treat a social repost as a new confirmed scope. [7; official]

## 6. Open questions

- Actual current CSC choice count and wording styles remain unknown despite weak reviewer examples. Public organizer scope is not an item specimen. [2, 6, 18-21]
- Current computerized scope, timing, scoring and booking availability remain unknown. Some COMEX pages were inaccessible; historical schedules and results cannot supply those details. CSDEx is separately listed, with Subprofessional availability/scope unestablished. [8, 9, 22]
- Official replacement-cycle content/date for the suspended NCR administration was not verified. Retain August published scope as the accessible baseline; this calendar gap does not prevent documenting that scope. [7]
- Published finer skills, subtest/topic/language proportions and raw-score/penalty formula remain unknown. Do not turn reviewer ranges or the 80.00 threshold into weights or a percent-correct model. [2, 4, 6, 16]
- DepEd common/JHS competencies are historical preparation support. Whether CSC uses a particular curriculum version or exact competency/depth remains unknown. R.A. 6713 and specialized filing need their own preparation evidence beyond these guides. [2, 10-15, 17]
- Conditional CSE-PR grant calculation and exact effectivity were not established from the organizer news summary. Do not assume the extra-rating route changes ordinary question scoring. [5]
- Source check and independent rebuild remain pending. This report does not accept level 1 or authorize later levels.

Author verification: completed the bounded organizer, curriculum and reviewer passes; retained all six required sections and eleven profile rows. Checked this output for unresolved placeholders, source numbering, confidence labels, em dashes, American spelling and whitespace. Independent claim/source checking is still required. No lesson bodies, quizzes, app content or other output files were read for assessment or changed.
