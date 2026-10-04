# UPCAT source check, refresh

Status: COMPLETE. All numbered sources were checked; five citation or scope flags remain. Inaccessible copies are not treated as verified.

Input: `docs/content/audit/coverage-r1/requirements/upcat.md`  
Input SHA-256: `f2002ef2514e874da94b1b7130c1bcbaeea3e15ec1bb3b124146002874adc01a`  
Policy: `origin/main` commit `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`. Read `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`, `docs/workflow/startup.md`, `docs/content/source-policy.md`, and `docs/content/exam-format-profiles.md` from main. Organizer evidence has priority; DepEd tier 2 establishes curriculum preparation only, not organizer requirements. Profile confidence uses official, strong secondary, weak, or unknown. Existing check preserved at `source-checks/upcat.md`; its coverage ended at source 15.

This check reads every numbered cited source and checks each claim and locator in the input. Unverifiable claims are flagged unless expressly labeled unknown or bounded. Failed URL access is recorded separately from verification of a retained document.

Checked: October 5, 2026 (Asia/Manila).

| Source number | Loads | Label correct | Corrected label if wrong | Note |
|---:|:---:|:---:|---|---|
| 1 | Yes | Yes |  | Current UP Office of Admissions page. Confirms four subtests, English and Filipino for Language Proficiency and Reading Comprehension, standardized scores combined with Grades 8 to 11, about five hours, and device prohibition. |
| 2 | Yes | Yes |  | Current AY 2027-2028 bulletin. Confirms four subtests, bilingual language subtests, grades, UPCAT 2027 dates August 1-2, 2026, about five hours, pencils/eraser, and no calculating devices. Does not publish detailed competencies, sectional time, choice count, or weights. |
| 3 | Indexed only | Yes |  | Direct open showed the portal shell; search-indexed portal text exposes the public AY 2027-2028 bulletin without login and matches source 2. |
| 4 | Yes | Yes |  | Current official UPCAT 2026 portal states the prior cycle exam date as August 2-3, 2025. |
| 5 | Yes | Yes |  | Official UPOA 2023 charter PDF, 17 pages. PDF page 8 states 3 hours 20 minutes excluding between-subtest instructions and collection/checking of materials; page 9 gives approximate total administration time. |
| 6 | Yes | Yes |  | FilipiKnow explicitly says its coverage compiles recent examinee experiences. Opened the math, science, language, and reading sections; evidence remains weak and historical. |
| 7 | Yes | Yes |  | Review Masters reviewer page; weak evidence. Confirms cited topic labels and its advice against calculus, but does not establish current official coverage. |
| 8 | Yes | Yes |  | Super Tutor Science page displays title and September 24, 2026 update. Checked every listed Earth science, astronomy, biology, chemistry, and physics subtopic cited in the requirements. |
| 9 | Yes | Yes |  | 36-page 2011 simulated reviewer. Verified four-choice Science item 61, Science item 67 “all of the above,” item 73 “none of the above,” item 125 “EXCEPT,” and negative stems. Printed/PDF locators align. |
| 10 | Yes | Yes |  | 17-page Review Masters Mathematics compilation. Verified item 89 on PDF page 15, five choices including “none of the above,” and its negative stem. Printed page 11 locator aligns. |
| 11 | Yes | Yes |  | Super Tutor Math page displays title and September 24, 2026 update. Checked number sense, algebra, geometry, trigonometry, and statistics claims; it lists prime factorization, GCF, and LCM. |
| 12 | Yes | Yes |  | Super Tutor Language and Reading page displays title and September 24, 2026 update. Checked language skills, Filipino grammar/idioms, passage question types, and statement of unknown passage lengths and language splits. |
| 13 | Indexed only | Yes |  | Direct page open returned an internal error. Search-indexed official UP text confirms its older four-hour wording; it is correctly treated as non-current-cycle evidence. |
| 14 | Yes | Yes |  | 948-page official 2025 charter. Printed page 291/PDF page 292 covers UPCAT administration; four hours includes pre-test instructions and exam, total 5 hours 40 minutes. |
| 15 | Indexed only | Yes |  | Direct page open returned an internal error. Search index exposed the GMA/VERA Files article dated August 3, 2012; it says an essay was added for UPCAT 2013. Historical limitation is explicit. |
| 16 | No (403); retained PDF yes | Yes |  | Direct DepEd URL returned HTTP 403. Official retained PDF verified read-only: cover identifies August 2016 Grades 1-10; 257 pages. Checked key-stage page 6 and grade-level pages 7-8. |
| 17 | No; alternate official PDF yes | Partial | DepEd curriculum, inferred for UPCAT; cited mirror/version unverified | Cited Dinagat mirror returned invalid HTML, not a PDF. Official DepEd endpoint provides a six-page May 2016 Grade 11 General Mathematics guide supporting the same topic families; the cited December 2013 copy/version remains unverified. |
| 18 | Indexed only | Yes |  | Direct UP page access failed. Search-indexed official page text confirms four subtests, the first-three-years grade rule, prior-test exclusion, and device-use disqualification warning; the input correctly marks it stale. |
| 19 | Yes; retained PDF | Yes |  | Official DepEd Science guide opened and verified read-only: cover identifies August 2016 Grades 3-10; 203 pages. Checked grade standards pp. 7-8, spiral pp. 9-10, and content pp. 163, 196. |

Retained-file verification used the given read-only scratchpad copies. The Python `pypdf` package inspected sources 16 and 19. The retained General Mathematics file is invalid HTML and was not evidence; source 17's claims were checked against the official DepEd May 2016 PDF and the cited DepEd learning-portal entry. Direct web access failures remain separate from retained-file verification.

## Claim problems

| Exact claim | Citation | Problem | Source-supported correction (under 25 words) |
|---|---|---|---|
| “SHS Core Curriculum, General Mathematics, Grade 11, December 2013.” | [17] | The cited mirror is invalid HTML, so its edition cannot be confirmed. The matching official DepEd guide opened is dated May 2016. | “The official May 2016 guide supports these Grade 11 topic families; the cited December 2013 copy remains unverified.” |
| “Interpret rational, exponential, and logarithmic functions and graphs; use logarithm laws and solve related equations and inequalities.” | [11, 17, PDF pages 1-2] | Source 17's mirror is invalid HTML. The official May 2016 guide confirms this Grade 11 topic family. | “The official May 2016 guide confirms these Grade 11 functions and logarithm competencies.” |
| “Represent propositions, determine truth values, and assess syllogisms and fallacies.” | [17, M11GM-IIg-1 to M11GM-IIi-3, PDF pages 3-4] | Source 17's mirror is invalid HTML. The official May 2016 guide confirms these logic competencies, but the cited 2013 copy remains unverified. | “The official May 2016 guide confirms these Grade 11 logic competencies.” |
| “Current required school level, quantitative depth, diagram and experimental-data skills, and discipline-specific inclusion.” | [2, 3] | The bulletin sets eligibility at Grade 11 completion or equivalent, while tested content depth remains unspecified. The broad wording obscures that distinction. | “Eligibility requires completed Grades 8–11 or equivalent; tested content depth remains unknown.” |
| “Senior High School science beyond the core subjects is strand-specific.” | No citation given; nearby curriculum sources are [16, 19]. | Neither cited guide establishes this Senior High School claim. The science guide covers Grades 3–10; the other guide covers General Mathematics. | “The cited Grade 7–10 guide does not establish Senior High School science requirements.” |

RESULT: FLAGS 5
