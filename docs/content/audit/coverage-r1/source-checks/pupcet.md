# PUPCET source check

Status: Checked against each numbered source and each cited claim. Four flags remain.

Policy revision: main `cb48097bedf15bec2cfbe4fb3aa7e957753b1727` (live-verified).
Workstream revision: `63147ad7b6eefa596a38248a58fa07c4b3394ed4`.
Input: `docs/content/audit/coverage-r1/requirements/pupcet.md`, SHA-256 `c9a92fdd16d1ca86c9cd1d083250f9b85dfae8fce346a986fd2bbd513ee28487`.
Source policy and format-profile template: `docs/content/source-policy.md` and `docs/content/exam-format-profiles.md` at main revision above. DepEd materials establish curriculum provenance (tier 2), not organizer-confirmed PUPCET scope.
Independent source access date: October 5, 2026. The recorded October 4 access dates are valid historical dates and are not flags.

## Source access log

| # | Loads | Label correct? | Corrected label | Note |
|---|---:|---|---|---|
| 1 | 2 | Yes | official | PUP admission page directly opened. It names first semester AY 2026-2027 and retains AY 2024-2025 eligibility text. No coverage blueprint or sample appeared. |
| 2 | 2 | Yes | official | PUP procedure page opened. It requires a printed ePermit on the scheduled examination date. Online application does not describe test delivery. |
| 3 | 2 | Yes | official | PUP Communication Management Office article opened. It announces the 2026 cycle, repeats AY 2024-2025 eligibility, and gives no content blueprint. No separate publication date appeared in the page body or direct HTML. |
| 4 | 2 | Yes | official, historical campus report | PUP-hosted Campus Journalists report opened. It describes Sta. Mesa testing rooms and a 90-minute examination on January 12, 2025. No separate publication date appeared. |
| 5 | 4 | Yes | weak, campus attribution unconfirmed | Google Sites page states the claimed areas and 75-minute report for May 4, 2025. It self-identifies as an official results portal and credits `pupsmbofficial`. Facebook direct HTTP returned page metadata naming PUP Santa Maria Campus, but no PUP-controlled page authenticated the Google Sites publisher. PUP's Santa Maria page remains under construction. Keep weak confidence. |
| 6 | 2 | Yes | weak | SchoolFinderPH page opened in reader and direct HTTP. Its table lists each candidate area and says it reflects past examinees and reviewer material, not an official syllabus. Displayed July 7, 2026. |
| 7 | 2 | Yes | official curriculum, tier 2 | Direct HTTP returned a valid 257-page August 2016 guide. Printed page 8 supports the cited Grade 6-10 standards. Web PDF reader failed; direct in-memory extraction succeeded. |
| 8 | 2 | Yes | official curriculum, tier 2 | Direct HTTP returned a valid 203-page August 2016 guide. Printed pages 10, 12-14, and 16 were extracted and checked. Web PDF reader failed; direct in-memory extraction succeeded. |
| 9 | 2 | Yes | official curriculum, tier 2 | Direct HTTP returned a valid 247-page May 2016 guide. Printed pages 231, 235, and 237 support the cited skills. Web PDF reader failed; direct in-memory extraction succeeded. |
| 10 | 2 | Yes | official curriculum, tier 2 | Direct HTTP returned a valid 190-page May 2016 guide. Printed pages 148, 165-166, and 181-182 were checked. Web PDF reader failed; direct in-memory extraction succeeded. |
| 11 | 2 | Yes | official curriculum, tier 2 | DepEd Learning Portal record directly opened. It identifies Grade 11, functions, basic business mathematics, and logic; listed competencies support the cited examples. Portal date is September 25, 2018. |
| 12 | 2 | Yes | official curriculum, tier 2 | DepEd Learning Portal record directly opened. It identifies Grades 11-12 and supports the cited critical-reading, claims, and evidence skills. Portal date is September 25, 2018. |
| 13 | 2 | Yes | official curriculum, tier 2 | DepEd Learning Portal record directly opened. It supports the cited random variables, distributions, sampling, estimation, hypothesis testing, correlation, and regression. Portal date is September 25, 2018. |
| 14 | 2 | Yes | official curriculum, tier 2 | DepEd Learning Portal record directly opened. Its Grade 11-12 core label and competencies support the conditional curriculum summary. Portal date is September 25, 2018. |
| 15 | 2 | Yes | official curriculum, tier 2 | DepEd Learning Portal record directly opened. Its Grade 11-12 core label and competencies support the conditional curriculum summary. Portal date is September 25, 2018. |
| 16 | 3 | Yes | official curriculum, tier 2 | DepEd Learning Portal record directly opened and checked. It identifies Grade 11 competencies. The cited legacy PDF URL returned 404; that error was not used as evidence. |
| 17 | 2 | Yes | official curriculum policy, tier 2 | Direct HTTP returned a valid 14-page PDF. In-memory extraction of printed page 4 confirms Grade 11 pilot in SY 2025-2026, continuation into Grade 12 in SY 2026-2027, and other non-pilot Grade 12 learners remaining under the current curriculum. Reader failed. |
| 18 | 2 | Yes | official curriculum, tier 2 | DepEd Learning Portal record directly opened. It identifies Grade 11 STEM-specialized Pre-Calculus and the cited advanced topics. Portal date is September 21, 2018. |
| 19 | 2 | Yes | official curriculum, tier 2 | Direct HTTP returned a valid 240-page May 2016 guide. Printed pages 6-9 were extracted and checked. Reader failed; direct in-memory extraction succeeded. |
| 20 | 3 | Yes | official curriculum, cohort applicability unverified | General Mathematics and Effective Communication guides directly returned valid 8- and 9-page PDFs; covers and course descriptions confirm Grade 11 and no displayed edition date. The listed General Science URL, which reportedly reset on October 4, returned a valid 8-page PDF on October 5; its cover and course description were read. Its October 4 failure is a historical access record; no requirement claim relies on that guide. |
| 21 | 2 | Yes | official index, tier 2 | Direct HTTP returned live DepEd index HTML. Current core guide links and links to DO 017, DM 012, and updated Grade 12 pilot DM 036 were present. Index entries do not verify linked policy bodies or universal cohort applicability. Reader failed. |
| 22 | 2 | Yes | official document identity; body unknown | Direct HTTP returned a valid 100-page PDF. In-memory extraction returned no text on printed pages 1-8. Reader failed. Do not use the unread scanned pages as policy evidence. |

No retained local PDF was used. DepEd PDFs were fetched and inspected in memory after the web reader returned errors. The direct result for General Science supersedes neither the valid October 4 access log nor the explicitly bounded statement that no requirements claim used that guide.

## Claim problems

| Exact claim | Citation | Issue | Source-supported correction (under 25 words) |
|---|---|---|---|
| SHS reading: identify a text's topic and key-word meanings, explain its ideas, compare text characteristics, use cohesive devices, and use logical relationships between ideas. The portal identifies Grade 11 preparation. | [16] | Portal competencies support topic and key-word meanings, explaining ideas, cohesive devices, and logical relationships. They do not state a competency to compare text characteristics. | Identify topics and key-word meanings, explain ideas, use cohesive devices, and apply logical relationships; the portal does not state a comparison competency. |
| Language per subtest confidence: “unknown current rule; weak preparation evidence” | Format profile, Language per subtest; [1-3, 5-6] | The profile policy requires exactly one confidence label. This cell combines unknown and weak. | unknown |
| Timing that affects item length confidence: “official historical report; weak historical campus report; unknown current rule” | Format profile, Timing that affects item length; [4-5] | The profile policy requires exactly one confidence label. Historical evidence and the current-cycle unknown belong in the value or note. | unknown |
| Delivery confidence: “official logistics; unknown medium” | Format profile, Delivery; [2, 4] | The profile policy requires exactly one confidence label. Logistics evidence and unknown test medium belong in the value or note. | unknown |

Source checks confirmed the cited JHS curriculum topics, the cited SHS competencies, the weakly sourced candidate areas, the 2025 campus-specific timing reports, and the stated unknowns. Sources 1-3 provide no exam content blueprint. No DepEd curriculum item was promoted to confirmed PUPCET scope. Source 5 remains explicitly weak because its publisher is not authenticated by PUP-controlled material.

RESULT: FLAGS 4
