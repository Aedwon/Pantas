# USTET source check

Status: independently checked October 5, 2026. Level 1 only.

Policy: `origin/main` commit `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`, live identity recorded in the task brief. Workstream: `63147ad7b6eefa596a38248a58fa07c4b3394ed4`. Input: `docs/content/audit/coverage-r1/requirements/ustet.md`, SHA-256 `622f923919690c50a362a40964ca11622cd2cb6108d4a5cb59781ceb40decac4`.

## Source access

| # | Loads | Label correct | Corrected label | Note |
|---|---|---|---|---|
| 1 | Yes, HTML 200 | Yes |  | UST admissions portal. Read current USTET overview, four-subtest statement, FAQ 17-18, 80/20 admission rating, grade-preparation guidance, and current schedule. |
| 2 | Partial | Yes |  | College application page loaded, titled A.Y. 2027-2028. The separately cited general application URL returned 404. |
| 3 | Page and image bytes load | Yes |  | OFAD page is official and dated September 21, 2026. Its two embedded images returned 200, but their text could not be independently read here. |
| 4 | Page and image bytes load | Yes |  | OFAD page is official and dated September 21, 2026. Its embedded image returned 200, but its text could not be independently read here. |
| 5 | Yes, PDF 200, 257 pages | Yes |  | DepEd Mathematics guide, August 2016. Read cited page 8. Curriculum support only. |
| 6 | Yes, PDF 200, 203 pages | Yes |  | DepEd Science guide, August 2016. Read cited pages 4, 7-8, 10, 12-14, 106, 125, 154, and 176. Curriculum support only. |
| 7 | Yes, PDF 200, 247 pages | Yes |  | DepEd English guide, May 2016. Read cited pages 205, 212, 214, 216, 231, 235, and 237. Curriculum support only. |
| 8 | PDF bytes load, 200, 2 pages | Yes |  | DepEd memorandum is a scan. Both pages yielded no text extraction; the web opener returned 403. Its cited paragraph claims remain unreadable. |
| 9 | Yes, HTML 200 | Yes |  | DepEd strengthened-SHS index loaded. Confirmed its live links to sources 16-18. |
| 10 | Yes, listing and PDF 200 | Yes |  | DepEd Learning Portal listing and linked General Mathematics guide loaded. Read listing competencies and guide cover/page 1. |
| 11 | Yes, listing and PDF 200 | Yes |  | DepEd Learning Portal listing and linked Reading and Writing guide loaded. Confirmed Grades 11/12 and listed competencies. |
| 12 | Yes, HTML 200 | Yes |  | Official DepEd Learning Portal competency listing loaded. The cited guide PDF was not available at the tested storage location. |
| 13 | Yes, HTML 200 | Yes |  | Official DepEd Learning Portal competency listing loaded. The cited guide PDF was not available at the tested storage location. |
| 14 | Yes, HTML 200 | Yes |  | Official DepEd Learning Portal competency listing loaded. The cited guide PDF was not available at the tested storage location. |
| 15 | Yes, PDF 200, 7 pages | Yes |  | Official DepEd storage PDF loaded. Read pages 1-4 and confirmed Grade 11/12 allocation and cited oral-communication concepts. |
| 16 | Yes, PDF 200, 8 pages | Yes |  | Current DepEd index links this strengthened General Mathematics guide. Read cover and cited pages 2-6; cover gives no guide date. |
| 17 | Yes, PDF 200, 8 pages | Yes |  | Current DepEd index links this strengthened General Science guide. Read cover and cited pages 2-8; cover gives no guide date. |
| 18 | Yes, PDF 200, 9 pages | Yes |  | Current DepEd index links this strengthened Effective Communication guide. Read cover and cited pages 2-8; cover gives no guide date. |
| 19 | Yes, HTML 200 | Yes |  | EdgePrep reviewer loaded. Weak evidence label is correct. Verified its multiple-choice, topic-family, mental-ability, language, and scoring-ratio statements. |
| 20 | Yes, HTML 200 | Yes |  | Official DepEd Learning Portal identifies Pre-Calculus as a Grade 11 STEM-specialized guide. |
| 21 | Yes, HTML 200 | Yes |  | Official DepEd Learning Portal identifies Biology 1 as a STEM-specialized guide for Grades 11-12. |

## Claim problems

| Exact claim | Citation | Issue | Source-supported correction, under 25 words |
|---|---|---|---|
| “UST disclaims official status and endorsement of circulating A.Y. 2027-2028 mock tests and review materials.” | [3] | The claim is contained in unreadable embedded images. The official page title and date do not establish the image wording. | Keep this claim unverified until the advisory image text can be read independently. |
| “USTET Reminders confirms testing-center belongings rules, not a paper/computer response mode.” | [4] | The image text could not be checked. The transparent-bag rule is independently stated on [1], but [4]'s precise scope is unverified. | Cite [1] for the bag rule; leave [4]'s image scope unverified. |
| “Paragraphs 4-5 distinguish existing-curriculum Grade 12 learners from continuing strengthened-curriculum pilot learners.” | [8] | The official two-page PDF loaded, but both scanned pages were unreadable through available non-UI text access. | Keep this cohort distinction unverified until the scan is readable. |

## Qualifier review

No curriculum-supported candidate was promoted to an organizer-confirmed exam requirement. The report consistently distinguishes DepEd curriculum provenance from inferred USTET relevance and limits SHS exposure claims by cohort, grade scheduling, track, or version where applicable. Source 19 is correctly treated as weak evidence, and its conflicts with organizer source 1 are explicitly resolved in favor of source 1. The profile confidence values use the allowed categories; limitations appear in values and notes.

The reported failures to load the general-application URL and to read image/scan content are separate from the successfully loaded organizer pages, image binaries, and DepEd PDFs/listings. No claim was inferred from unreadable source content.

RESULT: FLAGS 3
