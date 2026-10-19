# Free vs Pro split: decision trail

Refs read: origin/main (fetched) and origin/integration/new-design-r1. Read-only. Paths are repo-relative. "main" means origin/main; "integration" means origin/integration/new-design-r1.

## Bottom line

- No approved record lists which lessons or questions are Pro. The 19 Oct PWA plan says so: the split "must come from an approved record; `docs/pricing.md` does not define it" (`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`, main; `docs/superpowers/plans/2026-10-19-pwa-launch.md` C7, main: "If no record defines it, ask Aedwon before building. Do not invent the split.").
- Lessons, the Study map, the reader, Bookmarks, Customize your own and flags are free for everyone (`docs/design/DECISIONS.md`, main, section "Free and Pro (4 Oct...)").
- Content has no Pro field (see last section).

## A. Decided content split (what is free and what is Pro)

Status is approved unless marked.

1. Lessons, Study map, reader, Bookmarks, Customize your own, flags: same for both. Approved 4 Oct. Source: `docs/design/DECISIONS.md` (main), "Free and Pro" section.
2. Today's questions: free. "Free has no cap on Today" (`docs/design/DECISIONS.md`, main).
3. Mock exam: Free one every 14 days; Pro unlimited. "Mock exams: Free one every 14 days... Pro as many as they like." Approved 4 Oct (`DECISIONS.md`, main). Earlier: "1 per 14 days per track" (`docs/superpowers/decisions/2026-07-28-quiz-tab-decision-log.md`, integration).
4. After a mock: Free sees every question with its right answer and explanation until the next mock opens. Then only score and breakdown; questions need Pro. Pro reopens any time. Approved 5 Oct: "Free keeps full review until the next mock opens" (`docs/superpowers/decisions/2026-10-05-engineering-restart-log.md`, main, resulting decision 1). Also 14-day wording in `docs/design/DECISIONS.md` (main) line 197.
5. Answer explanation: free. "The shared explanation (Free and Pro) ... says only why the correct answer is correct." Approved 1 Oct (`docs/superpowers/decisions/2026-10-01-question-explanations-log.md`, main).
6. Wrong-choice notes ("what you picked", distractor reasons): Pro only. Free gets no note and no prompt. Approved 1 Oct (question-explanations log, main); 4 Oct (`DECISIONS.md`, main).
7. Flags: not gated. Approved 4 Oct (`DECISIONS.md`, main, line 197).
8. Your record: free for both. Approved 4 Oct.
9. Your performance (Progress-style table): Free sees the half ring and subject rows. Topics and Lessons levels: Pro. Free gets one "Go deeper with Pro" card. Approved 4 Oct (`DECISIONS.md`, main, lines 103-108).
10. Your plan: Free sees Today. Coming up and History: Pro. Approved 4 Oct (`DECISIONS.md`, main, line 96).
11. Your tendencies: Free sees labels as grey shapes. Findings and "When you work": Pro. Approved 4 Oct (`DECISIONS.md`, main, lines 78, 96; `docs/superpowers/specs/2026-10-01-you-screens-reference.md`, main).
12. Wrapped: free for both. Free gets all moments "at the moment" (`DECISIONS.md`, main). Pro history: still to place. Free after lapse keeps the Free rule for Wrapped history (`docs/superpowers/decisions/2026-10-05-engineering-restart-log.md`, main, Oct 6 answers item 4).
13. Backup and sync: Pro only. Approved 4 Oct (`DECISIONS.md`, main).
14. Pro page and Pro buttons: "Paywalls: never after onboarding... Pro shows only when someone taps a Pro button." Approved 4 Oct (`DECISIONS.md`, main).

Principle, in the approved wording: "nothing a student made is ever paywalled. Free sees what happened; Pro sees why, goes deeper, and has no mock limit." (`DECISIONS.md`, main, 4 Oct.)

## B. Decided feature gates (code)

Code on integration. Gate = a Pro check that changes what the screen shows.

- `lib/features/mock_exam/application/mock_availability_provider.dart` lines 31-32, 43: Pro returns "available"; Free uses `mockLimit`.
- `lib/features/paywall/domain/entitlement.dart` lines 209-213: Free next mock = last mock + 14 days.
- `lib/core/ui/components/answer_reveal.dart` line 89: wrong-choice note shown only if Pro, on a miss.
- `lib/core/ui/components/review_list.dart` lines 196-200, 418-424: passes Pro flag to review rows and answer reveal.
- `lib/features/mock_exam/presentation/pages/mock_review_page.dart` line 39: Pro flag to review list.
- `lib/features/mock_exam/presentation/pages/mock_results_route.dart` line 25 and `mock_results_page.dart` line 224: Pro flag; Free copy says "Reopens in 7 days." (CONFLICT, see D.)
- `lib/features/mock_exam/presentation/widgets/mock_panel.dart` line 257 and `mock_card.dart` line 118: tier line copy (Free: "one mock every 14 days").
- `lib/features/quiz/domain/debrief/session_debrief.dart` line 201 and `lib/features/quiz/presentation/pages/debrief_page.dart` lines 213, 363: Pro-only diagnosis and miss cause.
- `lib/features/quiz/presentation/quiz_page.dart` lines 340, 606; `quiz_results_page.dart` line 50; `flagged_list_page.dart` line 71; `lib/app/routes/quiz_routes.dart` lines 40, 151: Pro flag passed through.
- `lib/features/home/presentation/widgets/tendency_card.dart` line 35 and `tendencies_panel.dart` lines 35-37: Free grey card, "Unlock with Pro" to `/paywall`.
- `lib/features/progress/presentation/widgets/why_you_miss_section.dart` line 28: Pro content vs Free teaser.
- `lib/features/progress/presentation/pages/how_you_work_page.dart` lines 107-125: "When you work" Pro only.
- `lib/features/progress/presentation/widgets/performance_section.dart` lines 50-54 and `level_control.dart` lines 48-50: Free sees subject level only.
- `lib/core/sync/eligibility/sync_entitlement.dart` line 20: sync Pro only.
- `lib/features/paywall/domain/entitlement.dart` line ~201-206 `coversExam`: exam coverage, not content.
- No Pro check found in lesson, study or reader code (`lib/features/` has no lesson or study Pro read).
- Debug only: `lib/core/dev/dev_pro_switch.dart`, `FAKE_PRO` in `paywall_providers.dart`.

## C. Content data

- Content on integration: 158 lesson files (`content/lessons/**/*.md`) and 158 question files (`content/questions/**/*.yaml`).
- Lesson front matter keys: `topic`, `title`, `summary`, `subject`, `isActive`, `estimatedMinutes`, `_id`. No tier field.
- Question keys include `exams`, `approved`, `passage`, `choices[].rationale`. No `pro`, `tier`, `premium`, `free` or `access` key in any file (0 hits for those keys).
- `exams` values are exam IDs (for example `upcat`, `acet`, `dlsucet`, `ustet`, `dost-sei`, `cse-pro`, `cse-sub`), not tiers.
- `approved:` is a question flag: `approved: true` 1,289 lines, `approved: false` 180 lines. Meaning is UNCONFIRMED as a Pro flag; it is not one.
- `rationale:` appears 9,502 times in 158 files. This holds the Pro wrong-choice notes. Not a Pro marker by itself.
- Question id lines: about 2,253 ("id: q-" text match). Not checked against a loader.

## D. Conflicts and unconfirmed

- Mock Free reopen: "14 days" (`DECISIONS.md` 4 Oct; `entitlement.dart`) vs "Reopens in 7 days." (`mock_results_page.dart` line 224, integration). Code copy disagrees with the 4 Oct record.
- Home free topic rows: `docs/superpowers/decisions/2026-08-02-paywall-consolidation-log.md` (main) chose "Home's three rows are the free teaser." Later 2 Oct and 4 Oct records (`DECISIONS.md`, main) make topics Pro with one card for Free. UNCONFIRMED whether Home keeps any free topic rows.
- PWA content bundle: `docs/superpowers/specs/2026-10-19-pwa-launch-design.md` (main) says first visit downloads "all CSE lessons and quizzes." The 19 Oct decision (option 2) and plan C7 move Pro items to per-request server fetch. The spec does not reflect the later decision. Plan C7 says the split is not yet decided.
- Free trial on web: D6 "The free tier is the trial" (`docs/superpowers/plans/2026-10-19-pwa-launch.md`, main) vs `docs/pricing.md` "trial on Monthly only". Different channel; UNCONFIRMED how the two apply.
- Superseded: `docs/superpowers/specs/2026-05-21-paywall-entitlement-design.md` (integration) requires a `pro` boolean tag on Sanity content and server fetch. The 2026 content is local now and no `pro` field exists. Treat as superseded (per `DECISIONS.md` 4 Oct and PWA log 19 Oct "getProContent is gone").
- Superseded: Wrapped four moments with "topic turning weak to strong" (`DECISIONS.md`, main, 2 Oct wording) vs three moments (5 Oct, Aedwon: "-no").
- Superseded: 2026-07-29 progress-tab log "one Pro teaser per screen after free content" (main) partly replaced by 4 Oct list.
- Not found: a written count of Pro-only questions or lessons, a per-lesson free flag, or any Pro quiz set.
