# CSE Professional source check

Policy: `origin/main` cb48097bedf15bec2cfbe4fb3aa7e957753b1727; `docs/content/source-policy.md` and `docs/content/exam-format-profiles.md`.
Input: `docs/content/audit/coverage-r1/requirements/cse-professional.md`, SHA-256 `bc34aad7ca9fa13f310d5996a139acc8acb08c37f280b44dbb3ea38112cd1250`.
Workstream: `docs/content-coverage-audit-r1`, commit `63147ad7b6eefa596a38248a58fa07c4b3394ed4`. Source checks completed October 5, 2026, Asia/Manila.

## Source access

| # | Loads | Label correct | Corrected label | Note |
|---|---|---|---|---|
| 1 | Yes, landing page and signed PDF | Yes | official | CSC organizer announcement. Scope, language, passing grade, and disclaimer verified on cited pages. |
| 2 | Yes, CSC index | Yes | official | Index links to August reminders, Koronadal reset, and CY 2027 calendar; it does not itself set coverage. |
| 3 | Yes, CSC announcement | Yes | official | Calendar dates and second-Sunday scheduling note verified. |
| 4 | Yes, 8-page CSC PDF | Yes | official | Coverage, Professional counts, 3:10 limit, and calculator prohibition verified. |
| 5 | Landing page yes; web PDF read failed; Mozilla/5.0 HTTP 200, 939,643-byte PDF read in memory | Yes | official | 22-page July guide cover and cited pages verified. Page 14 confirms five choices and one best/correct answer; page 16 confirms no rounding. |
| 6 | Yes, 8-page CSC PDF | Yes | official | Koronadal-only reset, repeated scope, and 3:10 limit verified. |
| 7 | Yes, CSC announcement | Yes | official | March 14 and August 8, 2027 dates verified; detailed coverage is deferred to specific announcements. |
| 8 | Yes, CSC CAR notice | Yes | official | Notice is for late-2025 COMEX slots only; it does not define 2026 Professional scope or format. |
| 9 | Yes, CSC portal | Yes | official | Separate 2026 Computer Examination and CSDEx categories verified; no equivalence claim is supported. |
| 10 | Web PDF read failed; Mozilla/5.0 HTTP 200, 3,188,806-byte PDF read in memory | Yes | official | DepEd Mathematics curriculum, 257 pages; cover and cited pages checked. Curriculum support only, not CSC scope. |
| 11 | Web PDF read failed; Mozilla/5.0 HTTP 200, 4,806,754-byte PDF read in memory | Yes | official | DepEd English curriculum, 247 pages; cover and cited pages checked. Curriculum support only, not CSC scope. |
| 12 | Web PDF read failed; Mozilla/5.0 HTTP 200, 4,026,391-byte PDF read in memory | Yes | official | DepEd Filipino curriculum, 190 pages; cover and cited pages checked. Curriculum support only, not CSC scope. |
| 13 | Web PDF read failed; Mozilla/5.0 HTTP 200, 2,936,395-byte PDF read in memory | Yes | official | DepEd Araling Panlipunan curriculum, 240 pages; cover and cited pages checked. Curriculum support only, not CSC scope. |
| 14 | Yes, FilipiKnow article | Yes | weak | Unofficial reviewer, not CSC material. Its scope lists and skill examples match the limited claims cited. |
| 15 | Yes, 5-page practice-test PDF | Yes | weak | Items 2 and 20 verify NOT/EXCEPT and none-of-the-above examples. Unofficial, not released CSC questions. |
| 16 | Yes, 5-page practice-test PDF | Yes | weak | Item 6 verifies an all-of-the-above example. Unofficial, not released CSC questions. |

DepEd access failures above refer to the web PDF reader. Each linked PDF then loaded successfully through HTTP and was checked in memory. No extracted files were saved. The separately reported General Math URL returning invalid HTML was not used as evidence; source 10 is the valid tagged Mathematics PDF listed in this input.

## Claim problems

| Exact claim | Citation | Issue | Source-supported correction |
|---|---|---|---|
| “Environment: identify local environmental problems and government responses, AP10IPE-Ie-11/12; explain climate-change effects and environmental decisions, AP10IPE-Ic-8 / AP10IPE-Ii-22.” | [13, pp. 216-218] | The cited Ic-8 competency covers climate change's political, economic, and social aspects. Ii-22 links human activities and decisions to environmental change. Neither states climate-change effects; Id-10 does. | Separate these: AP10IPE-Id-10 covers climate-change effects; AP10IPE-Ic-8 covers its political, economic, and social aspects; AP10IPE-Ii-22 links human decisions to environmental change. |

The remaining cited claims were checked against their stated source and locator. CSC coverage stays distinct between Professional and Subprofessional; the five-choice and scoring claims apply to PPT only. COMEX/CSDEx scope, question weights, and unknowns remain qualified. Curriculum sources remain tier-2 preparation support, not exam requirements. Weak reviewer examples remain explicitly unverified for current CSC use.

RESULT: FLAGS 1
