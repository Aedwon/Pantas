# Independent requirements rebuild, group B

Status: Independent rebuild complete. Level 1 findings and recommendations only. Access date: October 5, 2026. Requirement acceptance and flag resolution remain with the lead.

Policy: origin/main `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`. Workstream HEAD observed `261f8685b5add6652037cc6ba0f62c21dc8ce8cb`; dispatch cited `63147ad7`; lead confirmed the difference is an expected watcher checkpoint, with matching local/remote audit heads and unchanged corpus. No git metadata mutation. Assigned sole output is this review.

Independence: Reviewer authored none of the requirements or source checks. Organizer-only reconstructions for USTET, PUPCET, and DOST-SEI undergraduate were saved here before opening any requirements. Author source checks and prior reviews were never opened. Organizer silence means unknown, never exclusion. No lesson bodies, overlap, structure, standards, or quizzes are reviewed.

## USTET

### Organizer-only reconstruction, saved before comparison

- **U1:** [UST Admissions portal](https://ustet.ust.edu.ph/), live page and HTTP-readable content, October 5, 2026. The page schedules tests from October 2026 to January 2027 and labels its health protocol USTET 2027. Its FAQ still shows an August 8, 2025 update and an AY 2026-2027 answer. Treat this as a current portal with stale FAQ wording, not a uniformly dated 2027 blueprint.
- Confirmed College USTET parts: English, Mathematics, Science, and Mental Ability (FAQ 17).
- Preparation: current and previous grade-level academic preparation, with Grade 11 specified for College. No detailed official topic or Mental Ability skill list appears.
- The separate LEAPMed test is outside College USTET coverage (LEAPMed tests section).
- Format: testing centers and test permit establish in-person delivery. Overall admission rating combines entrance-test performance (80%) and average English, Mathematics, and Science grades (20%). These are admission weights, not subtest proportions.
- Unknown: choice count, item styles, negative stems, language per subtest beyond the English subject, detailed scoring/penalties, subtest proportions, topic weights, and length-related timing. Additional program screening is distinct from the shared USTET.

### Comparison with the requirement record

Compared against `requirements/ustet.md` after all three organizer-only lists were saved. Input locators refer to the observed workstream snapshot, not a rewritten requirement.

- **No omitted organizer requirement found:** lines 36-41 retain all four parts; lines 45, 51, 79, 109, and 141 limit official detail to broad disciplines. This matches U1 FAQ 17. The separate LEAPMed syllabus stays separate.
- **No unsupported official extra found:** lines 53-69, 81-99, 111-131, and 143-154 explicitly separate curriculum or weak candidates from confirmed coverage. Their detailed preparation topics are not asserted as organizer requirements.
- **Format and scoring:** lines 160-170 preserve unverified item formats/languages/weights and distinguish physical centers from response medium. The 80/20 overall admission calculation matches U1's USTET overview and is correctly separated from mock composition.
- **Cycle and language:** lines 174-182 acknowledge stale FAQ text, current schedules, alternate cohorts, and unknown exam languages. Supplementary live verification after comparison opened [OFAD AY 2027-2028 application announcement](https://ofad.ust.edu.ph/ustet-application-for-a-y-2027-2028/), September 21, 2026. Its title confirms the new cycle; it does not supply a detailed syllabus. No current-year administrative page was used to prove detailed continuity.
- **Proposed disposition:** retain these confidence and uncertainty distinctions. Do not promote the detailed curriculum list or weak Mental Ability taxonomy to official USTET scope.

### Curriculum provenance and remaining unknowns

After the organizer-only reconstruction, official [General Mathematics record](https://lrmds.deped.gov.ph/detail/14511) was independently opened: Grade 11 core, functions/business mathematics/logic. Fresh HTTP retrieval of its [May 2016 guide](https://depedwebsitestorage.blob.core.windows.net/upload/2019/01/SHS-Core_General-Math-CG.pdf) returned a valid six-page PDF with that cover and grade. No retained invalid HTML scratchpad was used. The [Pre-Calculus record](https://lrmds.deped.gov.ph/detail/14427) explicitly identifies Grade 11 STEM specialization. Legacy [Mathematics guide](https://www.deped.gov.ph/wp-content/uploads/2019/01/Math-CG_with-tagged-math-equipment.pdf) returned valid PDF and August 2016 cover; page 8 supports the summarized school progression. These are preparation evidence, not an exam blueprint.

The independently retrieved [Statistics and Probability guide](https://www.deped.gov.ph/wp-content/uploads/2022/02/SHS-Core_Statistics-and-Probability-CG.pdf), December 2013, marks correlation/regression ENRICHMENT on page 6. Keep that exposure limitation when mapping line 94; its current candidate status already avoids a universal or official exam claim. Actual track delivery, pilot-edition matching, pre-test completion, detailed scope/depth, item language, and scoring remain unknown. No Filipino exam requirement follows from a bilingual school curriculum. PASS here means no rebuild defect found, not full exam coverage or verification of every cited curriculum competency.

RESULT: PASS

## PUPCET

### Organizer-only reconstruction, saved before comparison

- **P1:** [PUP iApply PUPCET page](https://www.pup.edu.ph/iapply/pupcet), successful web and HTTP retrieval October 5, 2026. Heading: first semester AY 2026-2027; eligibility text still names AY 2024-2025. Application procedure also retrieved at [PUP procedure](https://www.pup.edu.ph/iapply/procedure/pupcet).
- **P2:** [PUP news, third PUPCET 2026 batch](https://www.pup.edu.ph/news/?go=oQQkZzWML0Y%3D&v=Strong-preparation-marks-PUPCET-2026-third-batch-20260224000031845), published February 24, 2026, successful live open. Describes February 22 testing, test booklets, testing rooms, proctors, and answer sheets.
- Official subtest/topic/skill list: unknown. These sources establish the exam and administration, not coverage. Bounded organizer-domain searches for coverage and General Information found no coverage publication.
- Format: in-person booklet and answer-sheet delivery is confirmed for PUPCET 2026. Online iApply concerns application only.
- Unknown: choice count, item types, language, scoring, negative stems, length-related timing, topic weights, and subtest proportions. No five-subject or Filipino inclusion/exclusion claim follows from organizer silence.
- Historical organizer search result [PUPCETTG2012 PDF](https://www.pup.edu.ph/downloads/files/PUPCETTG2012.pdf) opened as two-page dates/reminders; it contains no coverage and supplies no current blueprint.

### Comparison findings

Compared against `requirements/pupcet.md` only after all three organizer-only lists were saved.

1. **B-PUP-01, missing current organizer delivery evidence.** Locator: line 177, format profile Delivery: "unknown paper versus computer for current cycle." Lines 16 and 174 also use only the official 2025 administration report as dated format evidence. Independently opened P2 is an official 2026 PUP report that explicitly discusses test booklets, answer sheets, testing rooms, and proctors at the February 22, 2026 examination. Therefore booklet/answer-sheet in-person delivery is supported for that 2026 event, with official confidence. **Proposed disposition:** add P2 and update Delivery to confirmed booklet/answer-sheet administration for this documented 2026 batch. Keep computer use at other campuses/forms, future-cycle continuity, and timing unknown. Do not derive item counts, proportions, choice count, languages, or a content blueprint from the administration story. This is an evidence omission, not proof that the original author's cited sources were misread.

### Other comparison checks and proposed disposition

- Lines 38-46 correctly leave official 2026 subtests and detailed coverage unknown. No omitted official subject requirement or falsely official topic was found in P1-P2.
- Lines 48-162 retain English, Filipino, numerical, science, reasoning, and General Information as curriculum/weak candidates. They do not promote the full curriculum to PUPCET scope. Broad official silence does not make these candidates erroneous extras.
- Lines 168-176 and 178 preserve unknown item formats, scoring, and weights. The historical 75/90-minute reports are not converted to current timing or composition. No invented weights found.
- Lines 182-186 preserve inconsistent eligibility years and condition the regular 2026 applicant baseline on actual school pathway. Future strengthened-SHS guide links do not establish current exam coverage.
- **Proposed disposition:** retain the candidate language layer, including Filipino, at its present confidence. Do not call all sections English or exclude Filipino because the admissions page is silent.

### Curriculum provenance and remaining unknowns

Independent verification after organizer reconstruction opened the [Grade 11 Filipino reading guide record](https://lrmds.deped.gov.ph/detail/14516): it identifies a core course and text interpretation, vocabulary, cohesion, and logical relationships. Fresh [Filipino Grades 1-10 guide](https://www.deped.gov.ph/wp-content/uploads/2019/01/Filipino-CG.pdf) retrieval returned a valid 190-page PDF and a May 2016 cover. These support the curriculum layer, not official PUPCET inclusion. General Mathematics and Pre-Calculus records, independently opened for this review, support the core versus STEM-specialized distinction. The Statistics and Probability PDF marks correlation/regression as enrichment; preserve that additional exposure condition when using line 98.

[DepEd DM 012, s. 2026](https://www.deped.gov.ph/wp-content/uploads/DM-12-s.-2026_Full-Implementation-of-the-Strengthened-Senior-High-School-Curriculum-in-School-Year-2026-2027.pdf) was independently retrieved with Mozilla/5.0 after web HTTP 403: HTTP 200, valid two-page PDF, 2,758,551 bytes. Its dated cover was visually checked, with the mirrored scan corrected for reading. Paragraphs 4-5 confirm ordinary Grade 12 continues the existing curriculum in SY 2026-2027 while pilot Grade 12 continues the strengthened curriculum. This supports retaining cohort limits. It does not establish tested topics or actual guide editions/exposure for every applicant.

Current official coverage, Filipino inclusion and exact section arrangement, item formats/languages, scoring, weights, and response practices outside P2's batch remain unknown. Authentication of the author's Google Sites campus report remains unresolved and its weak label is appropriate. This review did not read source-check outputs or authenticate it by assuming a claimed affiliation.

RESULT: FLAGS 1

## DOST-SEI undergraduate

### Organizer-only reconstruction, saved before comparison

- **D1:** [2026 undergraduate primer](https://science-scholarships.ph/pdf/2026_DOST-SEI_UG_Primer.pdf), web text retrieved October 5, 2026; web screenshot returned a Cloudflare queue. Independent HTTP retrieval returned application/pdf, `%PDF-1.7`, 1,199,959 bytes. The extracted cover image was inspected and explicitly identifies the 2026 DOST-SEI Undergraduate Scholarship Examination Primer. Metadata creation date: December 17, 2025. This is undergraduate, not JLSS.
- **D2:** [DOST-SEI helpdesk FAQ](https://helpdesk.sei.dost.gov.ph/faqs), successful web/HTTP access October 5, 2026. Its links identify science-scholarships.ph as the official scholarship service. It names the 2027 undergraduate cycle and admits Strengthened SHS applicants. Current service roots returned sparse application shells; no 2027 primer was established. The administrative FAQ does not prove that the 2026 blueprint continues unchanged.
- Official 2026 list (D1, printed pages 4, 6-13): Creative Reasoning (mechanical, spatial, verbal, Language and Literature); Science (Biology, Chemistry, Earth Science, Physics, Space Science); Mathematics (Algebra, Geometry, Trigonometry, Statistics, Calculus).
- Skills: everyday physics/mechanical-electrical relations/forces; mental rotation and spatial assembly; analytical verbal interpretation; English grammar, syntax, vocabulary, reading; scientific tasks; quantitative relationships and representations.
- Format (printed pages 4-5): four-choice, single-answer multiple choice; booklet and shaded answer sheet; total correct answers; separately timed parts, with no movement between parts. Part durations 45/65/70 minutes are durations, not content proportions.
- Samples show diagrams, passages, analogies, tables, NOT and error-identification stems. No exhaustive detailed topic list, topic weights, subtest item proportions, or assured 2027 continuity is supplied. No sampled style proves exclusivity or required frequency.

### Comparison with the requirement record

Compared against `requirements/dost-sei.md` after all three organizer-only lists were saved.

- **No omitted organizer domain or required skill family found:** lines 36, 48-50, 72, 94, and 122 agree with D1's domain descriptions. Lines 98-108 and 126-136 distinguish preparation detail from published scope. No JLSS source defines undergraduate coverage.
- **No unsupported official extra found:** detailed curriculum topics stay under supported-curriculum headings. STEM specialization is expressly limited. The presence of a confirmed broad mathematical domain does not promote every curriculum method within it to an official requirement.
- **Format and scoring:** lines 150-160 agree with D1's specification and observed samples, while retaining the distinction between a sample convention and a current policy. No invented proportions, weights, or timing-derived content allocation found.
- **Current-cycle evidence verified after comparison:** [2027 application home](https://ugs.science-scholarships.ph/pages/home.html), successfully opened October 5, 2026, identifies the 2027 award and November 14-15, 2026 pen-and-paper examination. Test Permit, Qualifiers, and Award Effectivity sections confirm the current delivery, unpublished cutoff value, and AY 2027-2028 award notes at lines 159-170. The organizer publishes Form E5 for strengthened-SHS pilot applicants. This supplements the initial sparse-root result; it does not turn D1 into a verified 2027 blueprint.
- **Cycle and language:** lines 37-38, 66, 88, 116, 144, and 166-174 preserve the 2026 primer limit and unknown 2027 continuity. An English domain and English samples do not prove exclusion of other languages or exhaustive literary scope.
- **Proposed disposition:** retain the record's distinction between confirmed 2026 coverage, current administrative rules, conditional curriculum candidates, and unknown current detailed scope. PASS does not authorize a current full-coverage claim.

### Curriculum provenance and remaining unknowns

The independently opened [Basic Calculus portal record](https://lrmds.deped.gov.ph/detail/14400) confirms Grade 11 STEM specialization and the listed limits, derivatives, and integral competencies. It supports lines 18 and 135 without establishing every applicant's prior exposure. Fresh General Mathematics PDF and its official portal confirm the core-course classification and legacy Grade 11 allocation. The valid Statistics and Probability guide's enrichment designation matches line 133. The live [Strengthened SHS index](https://www.deped.gov.ph/strengthened-shs-program/) links the new core guides and later policies, but index links alone do not verify pilot-edition continuity.

Separately verified DM 012 paragraphs 4-5 support the ordinary versus pilot Grade 12 distinction retained at lines 168-172. Later implementation details, exact guide editions, track substitutions, and completion before the November exam remain unresolved. The record does not treat them as proven. The 2027 organizer's alternate applicant forms and helpdesk rule support retaining multiple-cohort caveats. Filipino strands in school communication courses remain school preparation, not an established Filipino exam component.

Unresolved organizer details include an accessible 2027 topic blueprint or explicit continuation statement, category-specific forms/scoring, comprehensive task taxonomy and topic depth, current language policy, calculator policy, sample-style frequencies, and content weights. None is repaired with assumptions. Not every curriculum citation or competency was independently re-opened in this rebuild; that exhaustive citation verification belongs to the separate source check.

RESULT: PASS

## Group result

USTET: PASS. PUPCET: FLAGS 1 (B-PUP-01). DOST-SEI undergraduate: PASS.

RESULT: FLAGS 1

The flag requires a scoped delivery-evidence update, not a content rewrite. The three organizer-only lists were saved together before the first requirements read. No author source checks or prior reviews were opened at any point. Later sources discovered through requirement comparison are labeled supplementary and do not replace that independent starting point.

Only this assigned review was written in the repository. No input requirement, content, app source, git metadata, or shared status was edited. No later-level work or browser/desktop control occurred. Scratch source retrieval used temporary files outside the repository; the invalid retained General Mathematics scratchpad was never read.

### Verification identity

Comparison input SHA-256 values, recorded from the files read:

- `requirements/ustet.md`: `622f923919690c50a362a40964ca11622cd2cb6108d4a5cb59781ceb40decac4`.

- `requirements/pupcet.md`: `c9a92fdd16d1ca86c9cd1d083250f9b85dfae8fce346a986fd2bbd513ee28487`.

- `requirements/dost-sei.md`: `0524d2e6e12adaefcba67c683205c69c6f3670fbebc504ff7b69396bd383598c`.


### Document verification

Fresh scoped document check, October 5, 2026, exit 0:

```text
exam_sections: PASS
independent_lists: PASS
exam_results: PASS
unique_flag: PASS
no_em_dash: PASS
no_British_variants: PASS
no_attribution: PASS
no_trailing_space: PASS
source_links: PASS
input_hashes_match: PASS
flags: 1; exams reviewed: 3; lesson/content checks: 0
```

`git diff --check` returned exit 0 without output. HEAD remained `261f8685b5add6652037cc6ba0f62c21dc8ce8cb`. Other workers' dirty/untracked audit files were preserved. Flutter and content checks were not applicable to this research-only document.
