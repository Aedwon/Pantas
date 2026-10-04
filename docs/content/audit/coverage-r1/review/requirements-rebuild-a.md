# Independent requirements rebuild A

Status: Independent rebuild and comparison complete; flags awaiting lead disposition.

Date: October 5, 2026, Asia/Manila. Live tool clock checked at `2026-10-04 18:09:06 UTC`; October 5 access dates below use Manila time. Policy: main `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`. Audit input HEAD: `63147ad7b6eefa596a38248a58fa07c4b3394ed4`.

Scope: Level 1 only, UPCAT, DCAT, ACET. Findings and recommendations only. This reviewer authored none of the requirements or source-check outputs.

Ordering: The draft was saved before live research, while all corresponding requirements, source-check outputs, and prior review findings were unopened. The UPCAT list was saved first, then DCAT, then ACET. All three organizer lists were saved before the first requirement file was opened for comparison. Source-check outputs and prior review findings remained unopened throughout.

## UPCAT

### Independent organizer list, saved before comparisons

Accessed October 5, 2026. Current cycle: UPCAT 2027, AY 2027-2028, administered August 1-2, 2026.

- U1: [Office of Admissions home](https://upcat.up.edu.ph/), live page opened successfully. The About the UPCAT block confirms four subtests: Language Proficiency, Reading Comprehension, Science, Mathematics. English and Filipino are explicitly specified for the first two only.
- U2: [General Information Bulletin](https://upcat.up.edu.ph/htmls/aboutupcat.html), reached directly through U1's AY 2027-2028 link, live page opened successfully. Admission section repeats the four subtests. Step 6 confirms designated physical test centers, pencils, about five hours of test administration, and prohibited calculating devices. This supports physical pencil-based delivery without establishing exact item format.
- Topic/skill list independently rebuilt: English language proficiency; Filipino language proficiency; English reading comprehension; Filipino reading comprehension; Mathematics, detailed topics unknown; Science, detailed topics unknown. No granular official syllabus found in U1 or U2.
- Format independently rebuilt: language as above; physical test-center delivery; no calculating devices. Choice count, exact item types, negative stems, all/none style, subtest proportions, and topic weights remain unknown. Admission scoring combines standardized UPCAT scores with Grades 8-11 grades for UPG. This does not establish per-item raw scoring or a guessing penalty.
- Wording style and per-subtest length limits remain unknown. Five-hour administration is not a per-item or per-subtest time limit.

Ordering evidence: U1 and U2 were independently opened and this list was saved while all three requirement files and all source checks remained unopened.

### Comparison findings

Compared `requirements/upcat.md` after all three independent lists were saved. No source-check or other review output was read. The current-cycle official four-subtest list, bilingual language/reading allocation, device prohibition, delivery, and UPG description match the organizer rebuild. No omitted organizer-confirmed subtest, invented weights, official granular syllabus, or current scoring-penalty assertion was identified. The weak science/language/math candidates are honestly labeled and are not erroneous extras merely because UP publishes broad domains.

1. **U-F1, missing higher-priority language preparation evidence.** Locators: Section 1 has no DepEd English or Filipino guide; Section 3 Language Proficiency, lines 50-64, and Reading Comprehension, lines 78-90, supply only `Supported, weak` detailed skills. Exact examples: `Filipino grammar and usage. [7, 12]; weak` and `Interpret sawikain and salawikain. [7]; weak`. UP confirms both languages for both verbal domains. Accessible DepEd guides can support a separate curriculum preparation layer above reviewer-only detail. [English guide](https://www.deped.gov.ph/wp-content/uploads/2019/01/English-CG.pdf): May 2016 cover, Grades 1-10, 247 pages; live HTTP 200, valid PDF header, 4,806,754 bytes. PDF pp. 175-179 cover sentence grammar, active/passive voice, idioms in context, skimming, author purpose, and cohesive/parallel structures; p. 235 identifies explicit/implicit information and visual-text interpretation. [Filipino guide](https://www.deped.gov.ph/wp-content/uploads/2019/01/Filipino-CG.pdf): May 2016 cover, Baitang 1-10, 190 pages; live HTTP 200, valid PDF header, 4,026,391 bytes. PDF p. 140, F7PT-Ia-b-1, supports contextual synonyms/antonyms; p. 153, F8PT-Ia-c-19, supports figurative meaning; p. 166, F9WG-Ia-b-41, supports sequencing connectors; p. 175, F10PT-Ia-b-61, supports word meaning through structure. These sources were independently opened after the organizer lists. Proposed disposition: add sourced English and Filipino curriculum preparation with specific locators and cohort limits; preserve unknown official detailed UPCAT requirements. This is a source-hierarchy and preparation-layer gap, not an omitted official syllabus.

2. **U-F2, unsupported universal cohort wording.** Locator: Section 3 Science, line 137. Exact text: `what all takers met by Grade 10`. The [current UP bulletin](https://upcat.up.edu.ph/htmls/aboutupcat.html), Minimum Application Requirements, accepts older senior high graduates and foreign-school equivalents. A DepEd guide establishes prescribed mainstream curriculum, not every taker's completed instruction. The independently opened [Science guide](https://www.deped.gov.ph/wp-content/uploads/2019/01/Science-CG_with-tagged-sci-equipment_revised.pdf), August 2016 cover, Grades 3-10, 203 pages, HTTP 200 with valid PDF header, confirms the sampled pp. 7-8 topics but not universal exposure. The same requirement file already recognizes applicant exceptions for Mathematics at line 157 and Open question 9. Proposed disposition: replace the universal Science wording with mainstream curriculum-supported preparation and apply the same individual/cohort qualification. Keep the supported science topics; this is not an exam-scope exclusion.

3. **U-F3, available curriculum support left at weak confidence.** Locator: Section 3 Mathematics, `Supported, weak`, line 186. Exact text: `Geometry: apply the Pythagorean theorem. [11]; weak`. The independently opened [August 2016 Mathematics guide](https://www.deped.gov.ph/wp-content/uploads/2019/01/Math-CG_with-tagged-math-equipment.pdf), Grades 1-10 cover, 257 pages, live HTTP 200 with valid PDF header, 3,188,806 bytes, provides the theorem at PDF p. 244, M9GE-IIIi-2, and associated right-triangle solving at p. 245, M9GE-IIIj-1. Proposed disposition: attach this curriculum evidence and classify this preparation skill `Supported, curriculum`; actual UPCAT inclusion and depth stay unknown. This changes the source level, not official exam status.

### Curriculum provenance and remaining unknowns

The General Mathematics mirror in source 17 was independently retrieved and identified as a valid five-page December 2013 Grade 11 first-semester core guide, HTTP 200, 322,561 bytes, PDF header and first-page identity checked. It is distinct from the invalid retained scratchpad named in the assignment. DepEd's [General Mathematics portal record](https://lrmds.deped.gov.ph/detail/14511) independently corroborates the core designation and functions, business mathematics, and logic competencies. Neither the mirror nor portal establishes the current applicable course for every UPCAT applicant. Changed Grade 11 preparation and individual completion remain unverified, as the requirements already state. STEM specialization is not common preparation.

Unknowns retained: complete granular official syllabus; current item format and wording; Science/Mathematics languages; essay status; actual raw scoring/guessing penalty; section proportions and weights; actual pre-exam instruction for each applicant. Current-cycle domain confirmation is sufficient to retain the broad official map, not to claim exhaustive detailed coverage.

RESULT: FLAGS 3.

## DCAT

### Independent organizer list, saved before comparisons

Accessed October 5, 2026. Current cycle explicitly printed by DLSU: AY 2027-2028.

- D1: [Legacy first-year page](https://old.dlsu.edu.ph/admissions/undergraduate/freshmen-procedures/), live web open successful; page redirects readers to the current application page. Navigation's academic department names are not test coverage.
- D2: [Current first-year application](https://www.dlsu.edu.ph/admission/admissions-undergraduate-first-year-college-application/), live web reader returned 403; direct non-UI HTTP with Mozilla/5.0 returned 200 and the full AY 2027-2028 admissions page.
- Independent subtest/topic/skill list: unknown. D2 does not state a coverage blueprint or subtest names. No Science, Mathematics, English, Filipino, or reasoning requirements may be upgraded to official coverage from this source's silence.
- Independent format list: D2 confirms onsite Manila, Laguna, provincial, and Animo Lane testing, plus online local/international testing. Online examinees must attend a preceding Mock Online Test. Delivery mode is official; whether onsite tests use paper or computers remains unknown.
- Choice count, item types, language per part, negative stems, all/none choices, per-item scoring, guessing rule, score scale, section proportions, topic weights, and item-length timing remain unknown in D2. Admissions portal mechanics and blended college teaching are not exam format.

Ordering evidence: D1 and D2 were opened independently and this list was saved before any of the three requirements or source checks was opened.

### Comparison and curriculum provenance

Compared `requirements/dcat.md` after all three independent lists were saved. No source-check or other review output was read.

- No omitted organizer requirements identified: Sections 1, 2, 4, and 5 retain D2's AY 2027-2028 cycle and onsite/online delivery. Section 4 Delivery accurately includes required mock online testing and leaves onsite medium unknown.
- No unsupported official extras identified: Section 2 expressly calls all Mathematics, Statistics, Science, language, reasoning, and personality labels historical provisional reports. Sections 3 and 4 consistently distinguish curriculum preparation, weak recollection, and current official unknowns.
- No invented proportions, weights, scoring rule, or language exclusion identified. Section 4 retains these as unknown. English admissions prose does not become test-language evidence.
- Curriculum provenance independently sampled after the organizer rebuild: [DepEd General Mathematics record](https://lrmds.deped.gov.ph/detail/14511) is Grade 11 core and lists functions, finance, and logic; [Reading and Writing Skills record](https://lrmds.deped.gov.ph/detail/14520) is Grades 11/12 core; [Statistics and Probability record](https://lrmds.deped.gov.ph/detail/14521) is Grades 11/12 core; [Physical Science record](https://lrmds.deped.gov.ph/detail/14519) is Grades 11/12; [Pre-Calculus record](https://lrmds.deped.gov.ph/detail/14427) explicitly identifies STEM specialization. All opened successfully October 5, 2026. The document preserves these distinctions instead of universalizing advanced content.
- The English preparation layer has identifiable DepEd sources and preserves uncertain DCAT inclusion. A separate Filipino exam-preparation layer is not required as a confirmed DCAT inclusion; its inclusion remains unknown. Bilingual school communication does not settle it.

Proposed disposition: retain the current conservative requirement list and delivery profile. Do not promote conditional curriculum or historical recollection to a DCAT blueprint.

Remaining unknowns: actual current subtests and detailed skills; item styles/languages; onsite medium; item scoring and omissions; weights; common pre-exam cohort completion. The newer SHS implementation body's access limitation remains recorded. This PASS concerns the independent requirements comparison, not full coverage or organizer blueprint completeness.

RESULT: PASS.

## ACET

### Independent organizer list, saved before comparisons

Accessed October 5, 2026. Current admission cycle locator: SY 2027-2028 on Ateneo's admissions portal search index, ACET held September 2026. This is indexed organizer evidence, not a successful full-page coverage retrieval.

- A1: [Take the ACET](https://www.ateneo.edu/college/admissions/acet), attempted independently through live web reader and direct non-UI HTTP with Mozilla/5.0. Both returned inaccessible/error responses. Slash, non-www, and HTTP variants also failed with 403. No detailed official blueprint was recovered.
- A2: [Apply to Ateneo](https://apply.ateneo.edu/), independent live web and non-UI HTTP attempts failed; /college also returned 403.
- A3: [Organizer admissions portal](https://ateneo.admissions.ph/), live HTTP returned 200 but only a JavaScript shell; web reader returned zero lines. Search index showed Ateneo College Admissions, SY 2027-2028, ACET at Metro Manila Test Sites and Provincial Testing Centers in September 2026. Record as indexed organizer delivery/cycle evidence with limited access. No topic claims can be recovered from this shell.
- Independent subtest/topic/skill list: unknown from accessible organizer full pages. Specific Mathematics, English, General Knowledge, abstract reasoning, essay, Science exclusions, or Filipino exclusions are not independently established by this organizer rebuild.
- Independent format list: indexed portal supports physical test sites, with the access limitation above. Choice count, multiple-choice status, wording style, negative stems, all/none styles, language per part, scoring and guessing rule, proportions, weights, and timing remain unknown from accessible organizer material.

Ordering evidence: A1-A3 were independently attempted and this list was saved before any requirement, source-check, or prior review file was opened. All three independent lists were saved before the first requirement comparison.

### Comparison and curriculum provenance

Compared `requirements/acet.md` after all three independent lists were saved. No source-check or other review output was read.

- No omitted organizer coverage requirement could be independently established. The current-cycle organizer coverage page is inaccessible, so no fake detailed official list was created.
- No unsupported official extras identified. Section 2 labels Mathematics, English, General Knowledge, abstract reasoning, and essay as weak reports. Section 3 preserves unknown detailed requirements, separate essay/application-essay status, and unknown Science/Filipino exclusions. Curriculum topics remain conditional preparation, not official ACET scope.
- Section 4 leaves exact choices, current language allocation, official scoring/penalty, section proportions, and topic weights unknown. Weak reported formats/scoring remain labeled weak. No invented figures identified.
- Section 5 and source 4 explicitly identify the portal shell and search-index limitation. My independently observed portal indexing supplies a stronger organizer-origin cycle/delivery lead than an unofficial cycle lead, but it does not contradict the author's decision to require readable body evidence before calling the cycle or delivery verified. Proposed disposition: retain this conservative boundary and optionally record the independently observed indexed organizer lead. Do not label physical test-center delivery as authenticated paper delivery.
- Curriculum provenance independently sampled after organizer rebuilding: the [English guide](https://www.deped.gov.ph/wp-content/uploads/2019/01/English-CG.pdf) and [Mathematics guide](https://www.deped.gov.ph/wp-content/uploads/2019/01/Math-CG_with-tagged-math-equipment.pdf) covers identify May/August 2016 Grades 1-10 guides; sampled grammar/context/reading and Pythagorean preparation are compatible with the document's curriculum grouping. [General Mathematics](https://lrmds.deped.gov.ph/detail/14511), [Reading and Writing Skills](https://lrmds.deped.gov.ph/detail/14520), and [Statistics and Probability](https://lrmds.deped.gov.ph/detail/14521) official records confirm the reported core subject identities and distinguish Grade 11 from Grade 11/12. The [Pre-Calculus record](https://lrmds.deped.gov.ph/detail/14427) confirms STEM specialization, consistent with keeping calculus/conics and specialized depth unconfirmed common preparation.
- The English curriculum layer is present. Filipino inclusion remains unknown, so absence of a confirmed Filipino layer is not treated as an exclusion or omission. Cohort/completion limitations explicitly cover older, international, and transfer applicants and both SHS pathways. Unread newer memoranda do not become verified policy facts.

Proposed disposition: retain the current conservative requirement list with its source-access boundaries. This PASS concerns the independent requirements comparison; it cannot certify a detailed official ACET blueprint or full coverage.

Remaining unknowns: readable organizer current-cycle coverage and format; all official detailed skills; reported subtest grouping and essay inclusion; exact languages; paper/computer medium; item scoring; topic weights; completed curriculum per cohort. The access limitation prevents independently confirming organizer-specific scope and remains a material limit for later full-coverage claims.

RESULT: PASS.

## Group result

RESULT: FLAGS 3, all in UPCAT. DCAT and ACET independently compared with no substantiated misclassification, subject to their recorded official-scope unknowns. These PASS results are not complete-coverage claims or permission to start Level 2.

No input file, source-check output, application content, or lesson body was changed or inspected beyond this assignment. No source-check or earlier review output was read. Only this review document was written. Git metadata remained unchanged; the lead supplied the live-verified main identity because fetch is blocked. No computer control, browser automation, lesson assessment, quiz assessment, or later-level work was performed.

Comparison input identity, SHA-256 checked after comparison:

```text
upcat.md f2002ef2514e874da94b1b7130c1bcbaeea3e15ec1bb3b124146002874adc01a
dcat.md c033197a0c7f6593f2deba985d7356dfb7a2ecf7810a49623009c53b84f8a1e1
acet.md cc0dd9c8a2b2e5609166fcbd4d5d05a312b82b6a1510c3869992a3ed8e91315e
HEAD 63147ad7b6eefa596a38248a58fa07c4b3394ed4
```

Relevant document verification: all three exam sections and four result lines present; no pending/draft markers or em dashes. No Flutter, content, or answer-correctness checks were required or performed for this read-only requirements review.
