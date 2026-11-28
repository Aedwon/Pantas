# Consolidated QA Audit Findings (CSE Release R1)

- Policy commit: `origin/main` `47ac60058` (`AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`, `docs/workflow/process-improvement.md`)
- App code worktree: `qa/cse-release-r1` (`67ed1b52b`, read-only audit)
- Inputs consolidated (all in `docs/superpowers/verification/2026-11-22-cse-qa/`): `ui-1-findings.md`, `ui-2-findings.md`, `codex-findings.md`, `gemini-findings.md`, `content-findings.md`

---

## Counts by Severity and Group

Disagreements between sources keep both severities (marked `blocker (cond.) / major` or `major / minor`).

| Group | Blocker (cond.) | Blocker (cond.) / major | Major | Major / minor | Minor | Total |
|---|---:|---:|---:|---:|---:|---:|
| (a) Save and sync robustness | 0 | 1 | 18 | 2 | 2 | 23 |
| (b) Reports (finding 6 and 5) | 0 | 0 | 2 | 0 | 1 | 3 |
| (c) Layout and spacing (finding 1) | 0 | 0 | 2 | 0 | 11 | 13 |
| (d) Unspecced text (finding 2) | 0 | 0 | 5 | 0 | 22 | 27 |
| (e) Button sizing (finding 3) | 0 | 0 | 2 | 1 | 7 | 10 |
| (f) Public-launch items (G4, P10, sign-in limits) | 1 | 0 | 5 | 1 | 8 | 15 |
| (g) Content tooling (C3) | 0 | 0 | 1 | 0 | 3 | 4 |
| (h) Everything else | 0 | 0 | 7 | 1 | 22 | 30 |
| **Total** | **1** | **1** | **42** | **5** | **76** | **125** |

Counts by ID prefix: `S1` to `S25` (25), `U1` to `U96` (96), `C1` to `C4` (4). Total active deduplicated findings: 125 (49 blocker/major including split-severity items, 76 minor).

---

## Already Fixed and Merged (Excluded from Active Table)

1. **Analytics throw on long question IDs (PR #82)**
   - `gemini-findings.md` / `B1. Prod content tree`: `qid-over-64` (261 prod questions, max 85), `choice-id-over-64` (284 prod questions), `lesson-id-over-64` (138 of 1,271 prod lessons).
   - `gemini-findings.md` / `B2. Main content tree`: `qid-over-64` (80 main questions, max 67), `choice-id-over-64` (100 main questions), `historical_v1.json` (49 questions > 64), `lesson-id-over-64` (4 of 158 main lessons).
   - `gemini-findings.md` / `A10` telemetry row; `codex-findings.md` Part B (already excluded at source).

2. **Passage-order save failure (PR #83)**
   - `gemini-findings.md` / `A1. Passage-grouping order mismatch between in-memory QuizSession and persisted quiz_sessions blocks saving with "Could not save your progress."` (blocker) and `B1` note (289 prod passage questions).
   - `codex-findings.md` / `Passage regrouping can block the second answer in a quiz` (major).
   - `codex-findings.md` / `Scan found actual passage groups susceptible to order mismatch` (major; 286 prod and 260 main drill-regroup candidates, 260 main lesson-regroup candidates).
   - `codex-findings.md` / `Entry-point qualifications for passage ordering` (minor).

---

## Verified Clean and Informational Entries (Not Open Gaps)

- **P8 phone reader bar keyboard/hover/focus**: Closed in `48812779c` (`ui-1-findings.md` / `Phone reader bar: Tab stop, hover and focus defect (checklist row P8)`). One minor residual animation note stays active as `U75`.
- **C4 unapproved CSE questions on prod**: Pass. All 1,795 CSE-tagged questions (1,751 `cse-pro`, 1,523 `cse-sub`) and all 4,427 prod questions are hash-approved in `approved.json` (`content-findings.md` / `C4-1`). Gate/backlog cleanup stays active as `C3`.
- **Other verified-clean records**: Phone tab bar matches board (`ui-2` Slice A); no offline banner by design (`ui-2` Slice A); Home Free vs Pro matches boards (`ui-2` Slice B); Mock session flag, paper swap, panel motion, keyboard shortcuts, and end/submit dialogs match boards (`ui-2` Slice D); layer-by-layer constraint reference tables (`codex-findings.md` Part A, `gemini-findings.md` `A10`).

---

## 1. Deduplicated Findings Table

| ID | Group | Surface | One-line gap | Severity | Sources (file + heading) | Free/Pro | Phone/Web | Needs a board | Fix size |
|---|---|---|---|---|---|---|---|---|---|
| S1 | (a) | Quiz Check (`SubmitAnswer`) | Non-atomic 4-step answer write corrupts FSRS state, duplicates `review_logs`, collides on PK, or miscounts first-seen intro on retry | major | `codex-findings.md`: A session write can fail after the review was already committed; A review-log ID collision fails Check after rescheduling the question; A first-seen question can report a failure after its answer is already stored. `gemini-findings.md`: A2. Non-atomic `SubmitAnswer` writes corrupt FSRS state and duplicate `review_logs` (or collide on PK) on retry | Both | Both | no | M |
| S2 | (a) | Quiz session (`StartPractice`, `recordAnswer`) | `StartPractice.fromQuestionIds` does not deduplicate IDs, and `recordAnswer` uses `indexOf`, permanently breaking saves on duplicates or dropping missing IDs | major | `gemini-findings.md`: A3. `StartPractice.fromQuestionIds` does not deduplicate `questionIds`; duplicate IDs break `recordAnswer` with "Could not save your progress." `codex-findings.md`: A session write can fail after the review was already committed | Both | Both | no | S |
| S3 | (a) | Quiz ingest and delivery (`ingestSession`, `StudyObservations`) | One out-of-catalog/retagged item, question ID over 128 chars, or unclamped `responseMs`/clock skew permanently rejects the entire completed quiz on server | major | `codex-findings.md`: One out-of-catalog answer can permanently exclude a completed quiz from server progress; Exam-tag changes can reject attempts backed by the other snapshot. `gemini-findings.md`: A5 (server rejection); A6. `MAX_ANSWERS = 300`, `MAX_ID_LENGTH = 128`, `chosen <= 130`, and `responseMs` bounds (`0..86_400_000`) permanently drop completed sessions in `ingestSession` (and block web mocks) | Both | Both | no | M |
| S4 | (a) | Content mirror and upload (`ContentMirror`, `contentUpload`) | Content refresh leaves obsolete exam links on device and mirror/upload/mapper do not filter `isActive: false` questions | major | `codex-findings.md`: Content refresh can leave obsolete exam memberships on the device. `gemini-findings.md`: A5. `isActive: false` questions are served by catalog/mirror but rejected by `ingestSession`, permanently losing the session on server | Both | Both | no | M |
| S5 | (a) | Reviews and Practice ingest (`ReviewBatch`, `_answers.ts`) | All-Due Reviews or large Practice sittings over 300 answers are permanently rejected by `ingestSession` (`ustet.yaml` is at 300 with zero headroom) | major | `codex-findings.md`: An all-due Reviews sitting can exceed the server answer limit. `gemini-findings.md`: A6 (Session length > 300); B1 (`ustet.yaml` totalQ = 300) | Both | Both | no | M |
| S6 | (a) | Web IndexedDB storage (`durable_writes.dart`) | Web answer reveal precedes a 50 ms best-effort `SELECT 1` flush whose errors are swallowed, risking answer loss on quick close/reload | major (codex) / minor (gemini) | `codex-findings.md`: The web answer reveal can precede durable IndexedDB storage. `gemini-findings.md`: A9. Web IndexedDB transaction commits wait 50ms for a best-effort plain `SELECT 1` flush; tab close/crash loses the last saved answer | Both | Web | no | S |
| S7 | (a) | Server reviews (`serverReviews.ts`) | One malformed or mismatched-ID server review aborts the entire quiz or web Mock transaction | major | `codex-findings.md`: A single malformed server review aborts the session transaction | Both | Both | no | M |
| S8 | (a) | Pro sync push pipeline (`PushPipeline`, `FirebaseFirestoreGateway`) | Raw unencoded document path or uncaught `FirebaseException` on one bad row aborts drain and stalls the entire Pro sync outbox | major | `codex-findings.md`: An invalid raw question path can strand Pro synchronization. `gemini-findings.md`: A7. `PushPipeline._flushSerialized` does not catch `FirebaseException` from `FirebaseFirestoreGateway.commitRowIfBaseMatches`, stalling the entire Pro sync outbox on one bad row | Pro | Both | no | M |
| S9 | (a) | Observation delivery (`AttemptsRepository`, `StudyObservations`) | Corrupt stored `Attempt` JSON throws before the per-observation error guard, blocking all later attempts and lesson reads | major | `codex-findings.md`: An invalid attempt JSON can hold up observation delivery | Both | Both | no | S |
| S10 | (a) | Reviews completion (`ReviewBatchRepository`, `QuizCompletionCoordinator`) | Stale in-memory session or stored-outcome mismatch fails Finish with "Could not save your progress." after all questions were answered | major | `codex-findings.md`: Reviews can fail at Finish after all questions were answered on screen | Both | Both | no | M |
| S11 | (a) | Web Mock answer save (`server_mock_session.dart`, `functions/src/mock.ts`) | Unavailable or overlong choice ID is silently ignored; bad question ID or timestamp fails the snapshot save and blocks later taps | major | `codex-findings.md`: A web Mock answer can be ignored or block every save carrying it. `gemini-findings.md`: A6 (web mock 128/130 char limit) | Both | Web | no | M |
| S12 | (a) | Web Mock timed parts (`server_mock_session.dart`, `_mockParts.ts`) | A valid tap near a timed-part end can miss the server's closed part and succeed without saving the answer | major | `codex-findings.md`: A late web Mock save can silently miss a closed part | Both | Web | no | M |
| S13 | (a) | Native Mock grading (`MockSessionController`, `ComputeResults`) | Native Mock stores choice index instead of choice ID/version; 7 shared question IDs changed correct slot under version 1 | major | `codex-findings.md`: Native Mock can lose an answer across content changes while still showing results; Seven shared IDs change the correct choice under the same version | Both | Phone (native) | no | M |
| S14 | (a) | Question hydration and grading (`question.dart`, `ContentMirror`) | Zero correct choices or >6 choices crash render/save or drop the entire question set (defensive gap; 0 violations in current banks) | blocker if triggered (gemini) / major (codex) | `gemini-findings.md`: A4. Missing/zero correct choices or >6 choices crash question render/save or drop entire question sets. `codex-findings.md`: A missing correct choice can prevent the question from rendering | Both | Both | no | S |
| S15 | (a) | Quiz passage load (`quiz_page.dart`, `ContentMirror`) | Missing local passage leaves question stuck on skeleton/error so Check never runs; needs recovery from source set (mirror writes are already atomic per set) | major | `codex-findings.md`: A missing passage blocks Check before the save path starts; The current mirror already applies passages and questions atomically per set (minor clarification) | Both | Both | no | M |
| S16 | (a) | Server answer totals (`functions/src/_answerTotals.ts`) | `MAX_ID_BYTES = 150,000` is exceeded by the 4,427-question prod bank (203,233 bytes), silently dropping new distinct questions from roadmap/mastery | major (gemini B1) / minor (gemini A8) | `gemini-findings.md`: A8. `answerTotals` `MAX_ID_BYTES = 150_000` silently drops distinct questions beyond ~2,800-3,500 answered questions; B1. Prod content tree; B2. Main content tree | Both | Both | no | S |
| S17 | (a) | Onboarding consent (`onboarding_consent_step.dart`) | Continue awaits analytics/Crashlytics SDK toggles before saving Terms acceptance, blocking onboarding on SDK error even when opted out | major | `gemini-findings.md`: D1. `OnboardingConsentStep._continue` awaits analytics/Crashlytics SDK toggles before saving Terms acceptance, blocking onboarding on SDK failure | Both | Both | no | S |
| S18 | (a) | Account deletion and sign-out (`local_state_wiper.dart`, `auth_repository.dart`) | Deletion and sign-out await `notifications.cancelAll()` before wiping local data or deleting account, risking aborted wipe after server delete | major | `gemini-findings.md`: D2. Account deletion and sign-out await `notifications.cancelAll()` before wiping local data or deleting the account | Both | Both | no | S |
| S19 | (a) | Quiz completion (`quiz_completion_coordinator.dart`, `complete_quiz.dart`) | Completion awaits `_notifications?.onSessionCompleted()` before returning `Attempt`, showing save failure after the session is already saved | major | `gemini-findings.md`: D3. `QuizCompletionCoordinator._complete` and `CompleteQuiz` await `_notifications?.onSessionCompleted()` before returning the completed `Attempt` | Both | Both | no | S |
| S20 | (a) | Onboarding study days and Settings reminders (`settings_providers.dart`) | `updateStudyDays` and `saveReminderTime` await notification rescheduling inside the save call, blocking Onboarding advance and Settings save | major | `gemini-findings.md`: D4. `SettingsActions.updateStudyDays` and `saveReminderTime` await notification rescheduling inside the save call, blocking Onboarding and Settings | Both | Both | no | S |
| S21 | (a) | Settings error handlers (6 Settings pages) | Nine Settings `catch` blocks `await telemetry.recordError()` before updating error UI state, hiding error/Retry if Crashlytics throws | major | `gemini-findings.md`: D5. Nine Settings `catch` blocks `await telemetry.recordError(error, stack)` before updating error UI state | Both | Both | no | S |
| S22 | (a) | Telemetry `.log()` callers across app | `try { unawaited(telemetry.log(...)); }` and unguarded `.log()` calls let async rejections escape to `PlatformDispatcher.onError` | minor | `gemini-findings.md`: D6. `try { unawaited(telemetry.log(...)); } on Object {}` does not catch async rejections in `QuizController` and `LessonPage` (and unguarded `.log()` calls elsewhere) | Both | Both | no | S |
| S23 | (a) | Reviews selection (`review_batch.dart`) | Selecting a 5-question sitting silently skips an entire due passage group of 6+ questions | minor | `codex-findings.md`: Five-question Reviews can skip a whole passage group | Both | Both | no | S |
| S24 | (b) | Question report queue and backend (`report_queue.dart`, `report_form.dart`) | Reports stay on device forever (`sendPending()` is an uncalled no-op); no message length cap, not wiped on sign-out, silent loss on storage clear (finding 6) | major | `ui-1-findings.md`: Report a question (all platforms): reports are saved on the device and never sent. `gemini-findings.md`: C1. End-to-end trace, offline/online behavior, and data-loss risks in the report path; C2. Backend design requirements for question reports (info) | Both | Both | no | L |
| U1 | (b) | Phone Quiz and review report form (`report_form.dart`, `floating_bar.dart`) | Reporting opens a separate dialog overlay over the bottom bar instead of morphing the bar in place, with wrong button size/color vs `QN_Report` (finding 5) | major | `ui-1-findings.md`: Quiz session and review (phone): reporting a question does not morph the bottom bar (Aedwon finding 5) | Both | Phone | no | M |
| U2 | (b) | Report states and icon (`report_form.dart`, `quiz_page.dart`, `assessment_page.dart`) | Reported icon resets to gray on re-entry (not seeded from queue); wide web Assessment/Review pop silently; per-question limit and icon placement drift | minor | `ui-1-findings.md`: Report states vs boards (`QN_Report`, `QN_ReportSent`, `QN_ReportOffline`, `QN_ReportAgain`, `QN_ReportLimit`). `gemini-findings.md`: C1 (wide Assessment/Review silent pop; not wired in Mock) | Both | Both | no | S |
| U3 | (c) | Study and Quiz tab titles (`learn_tab_home.dart`, `quiz_tab_screen.dart`) | Phone Quiz title sits 40 px lower than Study title (Study y=6, Quiz y=46 vs board y=50); wide web Study h1 has extra 4 px side inset (finding 1) | major | `ui-1-findings.md`: Study and Quiz tabs (phone): Quiz title sits 40 px lower than Study title (Aedwon finding 1) | Both | Both | no | S |
| U4 | (c) | Phone Study tab states (`learn_tab_home.dart`) | Study title sits at three different heights across states (y=0 loading/empty/error, y=6 loaded vs board y=50) | minor | `ui-1-findings.md`: Study tab (phone): the "Study" title sits at three different heights across its own states | Both | Phone | no | S |
| U5 | (c) | Phone Mock proctor toast (`proctor_toast.dart`, `mock_session_page.dart`) | Proctor call is an 8 s in-flow bar that shifts the question list by ~48 px instead of a 2.5 s 44 px pill overlay | major | `ui-2-findings.md` (Slice D): Session (phone): proctor call is a layout-shifting toast that stays 8 s; board is a 2.5 s overlay | Both | Phone | no | S |
| U6 | (c) | Wide web sidebar (`web_shell.dart`) | Sidebar is 2 px low at top (20 vs 22), 4 px short between search and Home (14 vs 18), and brand letter-spacing drifts (-0.264 vs -0.44) | minor | `ui-2-findings.md` (Slice A): Shell: wide sidebar is 2 px low at the top and 4 px short between search and Home | Both | Wide web | no | S |
| U7 | (c) | Sign-in layout breakpoint (`sign_in_parts.dart`) | Sign-in and waiting screens switch to laptop layout at 720 px while onboarding and app switch at 1024 px | minor | `ui-2-findings.md` (Slice A): Sign-in: sign-in screens switch to the laptop layout at 720, the app at 1024 | Both | Web | no | S |
| U8 | (c) | Phone Quiz session bar (`quiz_page.dart`) | At 390 px width (<400), bar hint wraps to two lines and flag moves out of the bar into the question header | minor | `ui-1-findings.md`: Quiz session bar (phone): hint wraps, flag leaves the bar at 390 px | Both | Phone | no | S |
| U9 | (c) | Phone Pro page bar and hero (`pro_page.dart`, `phone_pro_hero.dart`) | Bottom bar padding/gaps drift from `ST_ProFree`; "PANTAS PRO" eyebrow sits outside hero (including lapsed/owned) and hero radius is 22 vs 24 | minor | `ui-2-findings.md` (Slice C): Pro page (phone): bottom bar padding and spacing differ from `ST_ProFree`; Pro page (phone): hero eyebrow and phone hero spacing vs board | Both | Phone | no | S |
| U10 | (c) | Phone Account and Settings root (`account_page.dart`, `settings_home_page.dart`) | Account name is 22 px instead of 24 px, header/block gaps are 6/10/20 vs 8/8/22, and Settings root name weight is 700 vs 600 | minor | `ui-2-findings.md` (Slice C): Account (phone and web): header, spacing and weight | Both | Phone | no | S |
| U11 | (c) | Phone ExamSwitch and ChangeExam2 (`carry_over_prompt.dart`, `exam_page.dart`) | Stacked bottom buttons have 0 px gap instead of the boards' 8 px (`ST_ExamSwitch`) and 6 px (`L_ChangeExam2`) gaps | minor | `ui-2-findings.md` (Slice C): Practice and Exam pages: no gaps found beyond spacing between stacked buttons | Both | Phone | no | S |
| U12 | (c) | Phone Mock setup and session header (`mock_setup_page.dart`, `mock_session_page.dart`) | Setup gaps/padding differ by 1-2 px (24/8/32 vs 22/7/30); session header min-height is 44 vs 50 and left inset 4 vs 8 (clock 2 px off-center) | minor | `ui-2-findings.md` (Slice D): Setup (phone): small spacing differences versus `MK_SetupCSE`; Session (phone): header height and side padding | Both | Phone | no | S |
| U13 | (c) | Wide web Mock question list (`mock_session_page.dart`) | Question list header puts a 40 px hide icon on the right instead of a 36 px icon on the left before "Questions" | minor | `ui-2-findings.md` (Slice D): Session (wide web): question list header has the icon on the wrong side and larger than the board | Both | Wide web | no | S |
| U14 | (c) | Phone Home week strip (`home_masthead.dart`) | Long "CSE Subprofessional" chip shrinks phone week strip to 3-5 days and wraps to 3 lines at large text; no board shows a CSE-length name | minor | `ui-2-findings.md` (Slice B): Home: long CSE names in the week strip and notices (CSE specific) | Both | Phone | yes | S |
| U15 | (c) | Phone Mock setup skeleton (`mock_skeletons.dart`) | Loading skeleton renders a Material AppBar titled "Mock exam" with 20 px margins, shifting sideways and swapping title on load | minor | `ui-2-findings.md` (Slice D): Setup/skeleton (phone): loading state shows a text the page does not have | Both | Phone | no | S |
| U16 | (d) | Study, Home, reader, ending, search, contents (`lesson_label.dart` + 17 sites) | "Part X of Y · N questions" label appears across 17 sites (including read rows, reader header, pull-up, Home) with no Aedwon approval and no redrawn boards (finding 2) | major | `ui-1-findings.md`: Study, reader, ending, search, contents, Home: the "Part X of Y · N questions" label (Aedwon finding 2). `ui-2-findings.md`: LEAD: finding 2 on my surfaces; (Slice B) Home: lesson rows carry "Part X of Y · N questions" and the topic line where the Home boards show subject and "10 min" | Both | Both | yes | M |
| U17 | (d) | Wide web Mock bottom bar (`mock_session_page.dart`, `web_components.dart`) | Compact bar shows false "Saved on this device" hint on server mocks and jumps in width on every answered question | major | `ui-2-findings.md` (Slice D): Session (wide web): "Saved on this device" hint in the bottom bar is false on web and resizes the bar | Both | Wide web | yes | S |
| U18 | (d) | Mock setup, results, finale (`mock_title.dart`, `mock_results_providers.dart`) | Exam is named three different ways ("CSE Professional simulation", "CSE Professional Practice Paper", "CSE Professional") instead of "`<Exam>` simulation" | major | `ui-2-findings.md` (Slice D): Setup/Results/Resume (both): the exam is named three different ways | Both | Both | no | S |
| U19 | (d) | Plan History (`plan_data.dart`) | Six common plan-change causes fall back to generic "Your plan changed on `<date>`." instead of specific sentences from stored facts | major | `ui-2-findings.md` (Slice B): Plan: History entries for six causes show the generic "Your plan changed on Oct 8." | Pro | Both | no | S |
| U20 | (d) | Pro page trial and lapsed states (`pro_page.dart`) | Trial view omits countdown/charge detail and uses wrong row labels ("Monthly trial", "Charges"/"Ends"); lapsed view keeps "SAVE 32%", per-month line, and exam-specific header | major | `ui-2-findings.md` (Slice C): Pro page (Pro, trial and lapsed states): trial wording and rows differ from `ST_RootTrial` and `ST_ProLapsed` | Both (trial Pro / lapsed Free) | Both | no | M |
| U21 | (d) | CSE one-block Mock wording (`proctor_toast.dart`, `mock_session_page.dart`, `mock_results_page.dart`) | One-block CSE paper uses multi-part copy ("in this subject", "in this part", "during Part 1") and wide proctor omits board's gray pill | minor | `ui-2-findings.md` (Slice D): Session (both): proctor wording "in this subject" on a one-block paper; Session (phone): questions sheet help line part; Results figures table (strict forfeit "Part N") | Both | Both | yes | S |
| U22 | (d) | Mock session timer (`mock_session_page.dart`, `pantas_timer.dart`) | Clock warning tag always reads "5 min left" even under 1 minute, and boards draw no tag (README vs board conflict) | minor | `ui-2-findings.md` (Slice D): Session (both): the clock tag always reads "5 min left", even in the last minute | Both | Both | no | S |
| U23 | (d) | Wide web Performance table (`web_performance_layout.dart`) | Table renders an uppercase header row (`SUBJECT / ANSWERED / ACCURACY`) absent from `PF_*` boards | minor | `ui-2-findings.md` (Slice B): Performance: table header row on wide web has text the board does not draw | Both | Wide web | yes | S |
| U24 | (d) | Wide web Home checklist footer (`home_today_checklist.dart`) | Dropping unmeasured time captions leaves the footer band holding only a right-aligned button with no board ruling | minor | `ui-2-findings.md` (Slice B): Home: footer time captions ("About 35 min left today", "About 12 min", "10 min") dropped, no ruling recorded for the empty space | Both | Wide web | yes | S |
| U25 | (d) | Plan past-day state (`plan_screen.dart`) | "Your plan had not started on this day." is unrequested, plain unstyled text with no board | minor | `ui-2-findings.md` (Slice B): Plan: "Your plan had not started on this day." has no board | Both | Both | yes | S |
| U26 | (d) | Pro page loading and error (`pro_page.dart`) | "Loading subscriptions..." (uses ellipsis) and "Could not load your passes." are plain default text with no board or `StateView` | minor | `ui-2-findings.md` (Slice C): Pro page: "Loading subscriptions...", "Could not load your passes." and "Try Again" have no board and no styling | Free | Both | yes | S |
| U27 | (d) | Pro page Weekly/Yearly/web CTA (`pro_page.dart`) | Weekly, Yearly, and web CTA labels, confirming text, and missing fine print have no board (`L_Purchase` end state also omitted) | minor | `ui-2-findings.md` (Slice C): Pro page: purchase button labels and fine print for Weekly, Yearly and web | Free | Both | yes | S |
| U28 | (d) | Onboarding save-failure line (`onboarding_guardian_step.dart`, `state_patterns.dart`) | Guardian step reports failed link send as "Could not save your progress.", and the shared `saveFailureLine` layout has no board | minor | `ui-2-findings.md` (Slice A): Onboarding: guardian step reports a failed link as "Could not save your progress."; Onboarding: the save-failure line has no board | Both | Both | yes | S |
| U29 | (d) | Onboarding exam picker states (`exam_picker_screen.dart`) | Error and empty copy and styling differ between phone ("your exams", "Try Again", `StateView`) and wide web ("exams", "Retry", `h3`) | minor | `ui-2-findings.md` (Slice A): Onboarding: picker error and retry copy differ between phone and wide | Both | Both | yes | S |
| U30 | (d) | Full-screen error state (`state_view.dart`) | Prints "Nothing you've done is lost." on every route error without verifying that nothing was lost | minor | `ui-2-findings.md` (Slice A): States: full-screen error says "Nothing you've done is lost." for every failure | Both | Both | no | S |
| U31 | (d) | Wide web update-required page (`update_required_page.dart`) | Omits the wide board's second line ("It takes a few seconds. Your progress is safe.", unmeasured claim); board should be updated | minor | `ui-2-findings.md` (Slice A): States: update-required page on wide web omits the board's second line | Both | Wide web | yes | S |
| U32 | (d) | Home install card (`install_card.dart`, `home_install_slot.dart`) | Replaces full-screen `OB_Install` board with an unboarded Home card that makes an unmeasured "Pantas opens faster" claim | minor | `ui-2-findings.md` (Slice A): States: install card on Home is not the `OB_Install` board and its copy differs | Both | Web | yes | S |
| U33 | (d) | Home trial notice (`home_notices.dart`) | Web trial notice drops price/charge wording with no redrawn `HM_Trial` board; native sentence starts "Google Play charges" instead of "You'll be charged" | minor | `ui-2-findings.md` (Slice B): Home: trial notice wording differs from the web board. `ui-2-findings.md` (Slice C): Home notices for trial and welcome (`HM_Trial`, `HM_ProWelcome`): wording differs from the boards | Pro (trial) | Both | yes | S |
| U34 | (d) | Phone native Free Account (`account_page.dart`) | Footer says progress stays on this phone only, contradicting the sign-out dialog's "Your progress is saved to your account." | minor | `ui-2-findings.md` (Slice C): Account (phone): Free signed-in user is told two different things about where progress lives | Free | Phone (native) | no | S |
| U35 | (d) | Legal documents (`legal_document.dart`, `legal_document_page.dart`) | Terms describe only web no-charge trial and Civil Service plans (clashing with native Play charging trial), and title casing differs from board | minor | `ui-2-findings.md` (Slice C): Legal documents: title case, Terms trial text vs native Play trial | Both | Both (clash native) | no | S |
| U36 | (d) | Settings About page (`about_page.dart`) | Adds unspecced "Send speed and error reports" toggle, printed DPO email, and title casing; omits board note and "Shared links" row | minor | `ui-2-findings.md` (Slice C): About: rows and copy beyond the board; version string | Both | Both | yes | S |
| U37 | (d) | Settings Appearance page (`appearance_page.dart`) | Adds unspecced "Lesson Text Size" header and wide zoom footer; Automatic sentence corrects board's inaccurate "light by day, dark at night" | minor | `ui-2-findings.md` (Slice C): Appearance and Practice: small copy and control differences | Both | Both | yes | S |
| U38 | (d) | Settings dialogs (`whats_included_page.dart`, `sync_reconciliation_gate.dart`) | Tier-change dialog (using unboarded "days ahead in your plan" copy) and sync reconciliation gate dialog have no board | minor | `ui-2-findings.md` (Slice C): Dialogs on Settings: whats-included tier dialog and sync gate have no board | Both | Both | yes | S |
| U39 | (d) | Wide web Mock flag offer (`mock_review_page.dart`) | Uses phone wording ("while the clock was running. Do you want to save them?") instead of `MK_ReviewFlagged` ("during the mock. Save them?") | minor | `ui-2-findings.md` (Slice D): Review (wide web): the flag offer wording differs from the board | Both | Wide web | no | S |
| U40 | (d) | Mock pause discard dialog (`pause_page.dart`) | Zero-answer discard wording ("Nothing is answered yet...") has no board | minor | `ui-2-findings.md` (Slice D): Pause (both): dialog and page text match the boards | Both | Both | yes | S |
| U41 | (d) | Phone Free Tendencies (`tendencies_page.dart`) | Section label reads "YOUR TENDENCIES" vs wide board's "What we found" (verify against `YO_Free`) | minor | `ui-2-findings.md` (Slice B): Tendencies (phone and wide web): Free page matches except one label | Free | Phone | no | S |
| U42 | (d) | Web onboarding exam picker (`exam_picker_screen.dart`) | Tags all held-back non-CSE exams as "Coming soon" with no explanation; confirm wording with Aedwon | minor | `ui-2-findings.md` (Slice A): Onboarding: web picker shows every non-CSE exam as "Coming soon" with no explanation for the student | Both | Web | no | S |
| U43 | (e) | Phone borderless buttons (`PantasButton`, `PantasSheet._CloseAction` + 26 sites) | Phone tertiary buttons default to 52 px full width across 9 sheets (adding 94-114 px footer, plus 32 px on New questions), Onboarding, and 14 other sites (finding 3) | major | `ui-1-findings.md`: Borderless and text buttons across the whole app (Aedwon finding 3). `ui-2-findings.md`: LEAD: finding 3; (Slice A) Sheets: Cancel and Close on a phone sheet are 52 high, full width, no border; Onboarding: tertiary buttons are 52 px full width on the phone; (Slice B) Home (phone): extra "Close" button under the Lessons, Reviews and New questions sheets; Home (phone): extra "Cancel" button under the exam date sheet; Performance (phone): extra "Cancel" button under the Subjects filter sheet; (Slice D) Session (phone): questions sheet draws a Close button the board does not have | Both | Phone | yes | M |
| U44 | (e) | Phone Pro page Restore (`pro_page.dart`) | "Restore Purchases" is a 52 px full-width bar button instead of a 24 px 15/600 line (Free) or a card row with no bar (Pro and lapsed) | major | `ui-2-findings.md` (Slice C): Pro page (phone): "Restore Purchases" is a 52 px full-width text button, board draws a plain 15/600 line; Pro page (phone, Pro and lapsed): Restore is a bottom-bar button, boards draw a list row with no bar | Both | Phone | no | S |
| U45 | (e) | Wide web `WebButton` tertiary (dialogs, notices, Pro, Account, Onboarding) | Borderless tertiary buttons are 44 px high with 20 px side padding (or 16 on notices) instead of board 40-42 px / 14 px (or 48/16 on `OB_Days`), shifting aligned labels | major (Slice A Dialogs) / minor (Slices A, B, C) | `ui-2-findings.md`: (Slice A) Dialogs: wide dialog "Cancel" is 44 high with 20 px side padding, the board is 40 to 42 with 14; Onboarding: wide "Every Day" has 20 px side padding, the board has 16; (Slice B) Home (wide web): exam date dialog "Cancel" is larger than the board's; Home (wide web): notice buttons "Later", "Got It", "Not Yet", "Learn More" are larger than the board's; (Slice C) Pro page (wide web): Restore Purchases and Switch on Free are 44 px with padding 20; Settings wide web: Account "Sign Out" and "Delete Account" start 6 px later; Dialogs (phone): wide Cancel note | Both | Wide web | no | S |
| U46 | (e) | Wide web sign-in buttons (`sign_in_parts.dart`) | "Continue", "Use Google Instead", and "Use a Different Email" fill the 420 px form width, violating HANDOFF natural-width rule | minor | `ui-2-findings.md` (Slice A): Sign-in: wide sign-in buttons are full width | Both | Wide web | no | S |
| U47 | (e) | Sign-in inline text links (`sign_in_parts.dart`) | "Resend Code" and `support@pantas.study` have a 19.5 px tap target, below the 44 px touch minimum | minor | `ui-2-findings.md` (Slice A): Sign-in: inline text links have a 19.5 px tap target | Both | Phone web | no | S |
| U48 | (e) | Wide web Onboarding Back link (`web_components.dart`, `onboarding_web_page.dart`) | Back link is 40 px high with 0 left padding vs board 36 px / 4 left padding (DS vs board conflict) | minor | `ui-2-findings.md` (Slice A): Onboarding: wide Back link is 40 high with 0 left padding, the board is 36 with 4 | Both | Wide web | no | S |
| U49 | (e) | Wide web Home drawer CTA (`web_side_overlay.dart`) | Reviews/New questions drawer button is full width (matches `HM_ReviewsPanel`, conflicts with HANDOFF hard rule) | minor | `ui-2-findings.md` (Slice B): Home (wide web): no ruling for the Reviews and New questions drawer button being full width | Both | Wide web | no | S |
| U50 | (e) | Phone error "Try Again" and Home offline (`state_view.dart`, `home_tab.dart`) | Phone "Try Again" is a full-width rounded rectangle instead of `DT_Error`'s natural-width pill; Home offline state has no board | minor | `ui-2-findings.md` (Slice B): Home: first-time loading and error states | Both | Phone (button), Both (offline) | yes | S |
| U51 | (e) | Plan History "See more" (`plan_web.dart`, `plan_page.dart`) | Wide web uses a `WebTextLink` with "Loading" text instead of a bordered 44 px white button; phone row is 52 px / 600 weight instead of ~49 px / 400 | minor | `ui-2-findings.md` (Slice B): Plan (wide web): History "See more" is a link, board is a white button; and a "Loading" label; Plan (phone): History "See more" row is 52 px high | Pro | Both | no | S |
| U52 | (e) | Wide web Reader end-of-part quiz CTA (`reader_gap.dart`) | "Quiz yourself, N questions" lost its `#EDEDF0` gray fill and became a borderless tertiary button (dead `WebButton(white)` branch remains) | minor | `ui-1-findings.md`: Reader end of part (wide web): "Quiz yourself, N questions" lost its fill | Both | Wide web | no | S |
| U53 | (f) | Web beta gate (`beta_gate.dart`, `email_sign_in_page.dart`, `docs/deploy-prod.md`) | `BETA_GATE=true` blocks every non-listed public web visitor at "This email isn't on the beta list"; `deploy-prod.md` omits `BETA_GATE` and still says Nov 9-15 (G4) | blocker (conditional: if release keeps `BETA_GATE=true`) | `ui-2-findings.md`: LEAD: G4 (rows 1-7, Functions notes); (Slice A) Sign-in: the beta gate puts every web visitor on a sign-in with a "not on the beta list" dead end | Both | Web | no | S |
| S25 | (f) | Public sign-in email cap (`functions/.env.pantas-prod`, `signInCode.ts`) | `SIGN_IN_DAILY_SEND_CAP=20` caps non-tester sign-in codes at 20 per Manila day, refusing the 21st new public student | major (unrated launch-limit note in source) | `ui-2-findings.md`: LEAD: G4 (`Functions behavior after Nov 23`, Related launch limit) | Both | Both | no | S |
| U54 | (f) | Settings Beta Pro switch (`beta_pro_row.dart`, `webEntitlement.ts`) | "Beta: Pro Features" row is visible to any caller while `betaProUntil` is active (failing for non-testers), with hard-coded "until Nov 23" and ellipsis "Turning On…" (G4) | major (before Nov 23) / minor (cleanup after Nov 23) | `ui-2-findings.md`: LEAD: G4 (rows 13-15); (Slice C) Beta items in Settings: "Beta: Pro Features" switch, note date and BETA mark | Free | Both | no | S |
| U55 | (f) | Web link preview (`web/index.html`, `web/og-image.png`) | `og:image:alt` and `og-image.png` show "Pantas beta" and a teal BETA mark on every shared link preview (G4) | minor | `ui-2-findings.md`: LEAD: G4 (row 18) | Both | Web | no | S |
| U56 | (f) | Beta waiting screen (`beta_waiting_page.dart`) | Dead post-Nov-9 waiting screen hard-codes "The beta starts Nov 9", mixes "days/hours/min", and links to tester guide (G4) | minor | `ui-2-findings.md`: LEAD: G4 (rows 8-9); (Slice A) Sign-in: waiting screen hard-codes "The beta starts Nov 9" and mixes tile labels | Both | Web | no | S |
| U57 | (f) | Beta Home notices and Feedback pages (`home_notices.dart`, `settings_home_page.dart`, `beta_feedback/`) | Tester-only beta Home notices, Settings "Feedback" BETA badge, and `/settings/beta-feedback` pages stay live after beta week with hard-coded Nov 9-22 dates, lowercase "Try again", and unexported canvas (G4) | minor | `ui-2-findings.md`: LEAD: G4 (rows 10-12, 16); (Slice B) Home: beta wording on Home; (Slice C) Feedback (Beta) pages: no approved board in the export; copy and structure | Both (testers) | Both | yes | M |
| U58 | (f) | CSE Subprofessional Mock setup (`mock_setup_page.dart`, `content/mock/cse-sub.yaml`) | Prints Pantas's invented even-split counts (36/36/36/37) and unconfirmed 145 / 20 items as plain official facts with no caveat or practice label (P10) | major | `ui-2-findings.md`: LEAD: P10, Mock setup: Subprofessional even-split counts printed as plain facts, no caveat; (Slice D) Setup (both): header, counts and unrequested lines versus `MK_SetupCSE` | Both | Both | yes | S |
| U59 | (f) | CSE Professional Mock setup (`mock_setup_page.dart`, `content/mock/cse-pro.yaml`) | Prints one examinee's counts (20/55/35/45, 155 + 15) with no "reported" marker, contradicting Sub's own 2020 CSC advisory (150 + 20) (P10) | major | `ui-2-findings.md`: LEAD: P10, Mock setup: Professional counts are one examinee's recollection, and contradict the Sub note's own CSC advisory; (Slice D) Setup (both): header, counts and unrequested lines versus `MK_SetupCSE` | Both | Both | yes | S |
| U60 | (f) | Record weekly accuracy (`record_page.dart`, `record_provider.dart`) | Labels the last week with answers as "this week" even when weeks old; empty-line message misstates calendar weeks (P10) | major | `ui-2-findings.md`: LEAD: P10 summary; (Slice B) Record: "61% this week" is not always this week | Both | Both | no | S |
| U61 | (f) | Record streak and Home day-off (`record_provider.dart`, `streak_evaluator.dart`) | "N day streak" (and Home "your streak is safe") is not decayed against today when study days are missed (P10) | major | `ui-2-findings.md`: LEAD: P10 summary; (Slice B) Record: "N day streak" is not decayed when days are missed | Both | Both | no | S |
| U62 | (f) | Home exam-day warm-up (`home_exam_day.dart`, `build_roadmap.dart`) | "10 easy reviews" uses an unsourced fixed cap of 10 and calls reviews "easy" with no difficulty field (P10) | minor | `ui-2-findings.md`: LEAD: P10 summary; (Slice B) Home: "easy reviews" warm-up on exam day | Both | Both | no | S |
| U63 | (f) | CSE Professional overall accuracy (`overall_accuracy.dart`) | Uses weighted mean (5/30/35/30, not CSC-published; Aedwon-approved Nov 5) with no minimum answer count before displaying gauge (P10) | minor | `ui-2-findings.md`: LEAD: P10 summary; (Slice B) Performance: overall accuracy for CSE Professional is a weighted mean | Both | Both | no | S |
| U64 | (f) | Record totals (`record_provider.dart`) | "questions answered" counts blank mock items (paper size) and "time in sessions" uses uncapped wall clock (P10) | minor | `ui-2-findings.md` (Slice B): Record: "questions answered" counts every mock item and "time in sessions" uses wall clock | Both | Both | no | S |
| U65 | (f) | Tendencies peak hour and archetypes (`how_you_work_provider.dart`, `archetype_catalog.dart`) | "Peak hour" uses ungated bucket accuracy (1 right answer sets peak) and archetype cutoffs are invented (P10) | minor | `ui-2-findings.md`: LEAD: P10 summary; (Slice B) Tendencies: "Peak hour" and the archetype use ungated bucket accuracy | Pro | Both | no | S |
| U66 | (f) | Pro trial length and About version (`pro_page.dart`, `about_page.dart`) | Trial strings hard-code "7" instead of reading from offer, and About hard-codes "0.1.0" instead of reading package version (P10) | minor | `ui-2-findings.md`: LEAD: P10 summary; (Slice C) Pro page: hard-coded "7" in every trial string, not read from the product; About: version string | Both | Both | no | S |
| C1 | (g) | Content audit sweep (`tools/audit/run_all.py`, `sweep_illustrations.py`) | Aborts on sweep 3 with 618 stale-strategy errors on prod content, masking sweeps 4-11 (0 broken CSE visuals reach students; `sweep_questions.py` regex parser also causes 43 false-positive blockers; no `--root`) | major | `content-findings.md`: C3-1. `tools/audit/run_all.py` aborts on sweep 3 with 618 stale-strategy illustration errors on prod content, masking sweeps 4 to 11 | n/a | n/a | no | M |
| C2 | (g) | Content audit script (`tools/audit/run_all.py`, `check_lesson_illustrations.py`) | Crashes with `IndexError` on `main` (backlog C10) due to non-tabbed stdout summary line, and `ModuleNotFoundError` under `python3 -I` | minor | `content-findings.md`: C3-2. `tools/audit/run_all.py` crashes with `IndexError` on `main` (backlog C10) and `ModuleNotFoundError` under `python3 -I` | n/a | n/a | no | S |
| C3 | (g) | Content approval gate and backlog (`content_gate.dart`, `docs/superpowers/backlog.md`) | Gate still keeps `legacy.json` fallback scoped per topic (spec B6 says subject) and backlog still lists stale "968 unapproved" (prod C4 passes with 0 unapproved) | minor | `content-findings.md`: C4-1. Zero unapproved CSE questions exist in prod today (1,795 of 1,795 CSE questions approved; 4,427 of 4,427 total prod questions approved) | n/a | n/a | no | S |
| C4 | (g) | Legacy question importer (`tools/import_questions/converter.dart`) | 29 prod questions use a same-file passage with fewer than 4 questions, which the legacy importer would reject (current uploader accepts them) | minor | `codex-findings.md`: Production has short passage pools under the legacy importer rule | n/a | n/a | no | S |
| U67 | (h) | Sign-in and waiting screens (`email_sign_in_page.dart`, `beta_waiting_page.dart`) | Beta sign-in, code step, not-on-list, and waiting screens have no exported board in `web-design/pantas-handoff` (canvas `EBQopPTcLczwabNWkTSake` not exported) | major | `ui-2-findings.md` (Slice A): Sign-in: beta sign-in, code step, not-on-list and waiting screens have no exported board | Both | Both | yes | S |
| U68 | (h) | Settings confirm dialogs (`centered_dialog.dart`, Settings callers) | Confirm dialogs opened via `showPantasDialog` skip the design system 420 ms rise-and-fade dialog motion | major | `ui-2-findings.md` (Slice A): Dialogs: confirm dialogs opened with `showPantasDialog` skip the design system dialog motion | Both | Both | no | S |
| U69 | (h) | CSE Pro page (`pro_page.dart`, `products.dart`) | CSE boards show Monthly and Season Pass only, while code and `pricing.md` add Weekly (₱49) and Yearly (₱1,199) | major | `ui-2-findings.md` (Slice C): Pro page (CSE): board shows Monthly and Season Pass only; code and `pricing.md` add Weekly and Yearly | Free | Both | yes | M |
| U70 | (h) | Delete account (`delete_account_page.dart`) | Phone shows plain "Deleting..." / "Deletion request completed." with no steps screen; wide web merges two stages into one and does not tick stages | major (phone) / minor (wide) | `ui-2-findings.md` (Slice C): Delete account (phone): "Deleting..." and "Deletion request completed." text; no steps screen; Delete account (wide web): "Deleting" screen does not tick the real stages | Both | Both | no | M |
| U71 | (h) | Phone native Settings Reminders (`settings_home_page.dart`) | Reminders row pushes `/settings/reminders`, which has no route or page (causes a router error on Android/iOS) | major | `ui-2-findings.md` (Slice C): Reminders (phone native): the row opens a route that does not exist; no Reminders page is built | Both | Phone (native) | no | S |
| U72 | (h) | Phone native Mock start (`mock_start_route.dart`, `mock_start_preparation_page.dart`) | Shows a second "Start the Paper" screen after Setup's Start, violating HANDOFF hard rule and diverging from web | major | `ui-2-findings.md` (Slice D): Setup to run (phone native): a second "Start the Paper" screen after setup's Start | Both | Phone (native) | yes | M |
| U73 | (h) | Phone Mock review note card (`mock_review_page.dart`) | Uses web labels and saves on instant tap with no Cancel / Add Note pair (`MK_ReviewQNote`, `MK_ReviewBlank`) | major | `ui-2-findings.md` (Slice D): Review (phone): the note card differs from `MK_ReviewQNote` and `MK_ReviewBlank` | Pro | Phone | no | S |
| U74 | (h) | Free mock interval (`mock_card.dart`, `quiz_routes.dart`) | Free mock interval is 14 days on native phone vs 30 days on web, and both mobile and web QZ boards still say 14 | major | `ui-2-findings.md` (Slice D): Setup/Quiz card (both): Free interval is 14 days on phone and 30 days on web; boards still say 14 | Free | Both | yes | S |
| U75 | (h) | Phone reader bar bookmark (`reader_bar.dart`) | Bookmark draws its own `GestureDetector` `.82` press scale inside `PantasTapArea` `.98` `PressScale`, double-scaling on press | minor | `ui-1-findings.md`: Phone reader bar: Tab stop, hover and focus defect (checklist row P8), residual note (a) | Both | Phone | no | S |
| U76 | (h) | Study lesson rows (`quiz_starts.dart`, `lesson_bite_label.dart`) | Runs one database query per row for question count (76 queries on Philippine Constitution) and flashes a blank second line while loading | minor | `ui-1-findings.md`: Study rows (phone and web): one database query per row for the question count | Both | Both | no | S |
| U77 | (h) | Sign-in gate loading/error (`beta_gate.dart`) | Loading uses raw radius-0 square blocks; error uses lowercase "Try again" and untappable plain `support@pantas.study` text | minor | `ui-2-findings.md` (Slice A): Sign-in: gate error and loading states are raw, off-system | Both | Web | yes | S |
| U78 | (h) | Wide web sidebar account block (`web_route_shell.dart`, `web_shell.dart`) | First paint renders blank person icon and empty name until settings load | minor | `ui-2-findings.md` (Slice A): Shell: sidebar account block is blank until settings load | Both | Wide web | no | S |
| U79 | (h) | Home Pro welcome notice (`home_notices.dart`, `home_notice_strip.dart`) | Shows on every new device/browser until dismissed (not "once"), and "See What's New" opens Performance | minor | `ui-2-findings.md` (Slice B): Home: Pro welcome notice is not "once" | Pro | Both | no | S |
| U80 | (h) | Wide web Home "More about you" (`home_web_layout.dart`) | Uses Material glyphs and `WebRow` padding instead of the board's drawn SVGs and 18/18/18/20 card padding | minor | `ui-2-findings.md` (Slice B): Home: "More about you" icons on wide web differ from the board | Both | Wide web | no | S |
| U81 | (h) | Performance loading skeleton (`performance_screen.dart`) | Performance loading skeleton has no approved board (`L_ProgressSlow` is for Tendencies) | minor | `ui-2-findings.md` (Slice B): Performance (phone): loading skeleton has no board | Both | Both | yes | S |
| U82 | (h) | Phone Wrapped deep link (`wrapped_routes.dart`) | Deferred `/wrapped/:artifactId` route remains reachable by deep link on phone (redirected on wide web) | minor | `ui-2-findings.md` (Slice B): Wrapped entry points (HANDOFF: deferred) | Both | Phone | no | S |
| U83 | (h) | Phone native Pro pending (`pro_page.dart`) | "Open Google Play" is an inline 52 px text button inside the card (no envelope icon) instead of the filled bottom-bar CTA | minor | `ui-2-findings.md` (Slice C): Pro page (phone, Pending): "Open Google Play" is an inline text button, board draws the bar CTA | Free | Phone (native) | no | S |
| U84 | (h) | Wide web Pro pending (`pro_page.dart`) | Web pending-payment board state (`ST_ProPending`) is not implemented (`pending` forced null on web) | minor | `ui-2-findings.md` (Slice C): Pro page (wide web): pending-payment state in the web board is not implemented | Free | Wide web | yes | S |
| U85 | (h) | Wide web Pro owned boards (`pro_page.dart`) | Web boards (`ST_Pro`, `ST_RestoreDone`) still show "Renews" and "Manage Subscription" instead of prepaid "Ends" | minor | `ui-2-findings.md` (Slice C): Pro page (wide web, Pro): no "Manage Subscription" and "Renews" per board; code says "Ends" | Pro | Wide web | yes | S |
| U86 | (h) | Account page extra rows (`account_page.dart`) | "Continue with Email", "Email" row, and minor's "I'm 18 now" row have no approved board | minor | `ui-2-findings.md` (Slice C): Account (phone and web): extra rows and a button with no board | Both | Both | yes | S |
| U87 | (h) | Backup page (`backup_page.dart`) | Omits offline and Pro-not-signed-in states and draws a 52 px filled "Back Up Now" button where `ST_BackupDetails` draws a list row | minor | `ui-2-findings.md` (Slice C): Backup page: single row and a 52 px filled "Back Up Now"; boards draw a detail list and states | Pro | Both | yes | M |
| U88 | (h) | Notifications rationale page (`permission_rationale_page.dart`) | Unrouted dead code with unboarded "streak-save warning" copy | minor | `ui-2-findings.md` (Slice C): Notifications: permission rationale page is unrouted dead code | Both | Phone (native) | no | S |
| U89 | (h) | Guardian pages (`lib/features/guardian/`) | Confirm, Waiting, Manage, Withdrawn, and contact pages have no approved board in the export (Waiting also stacks two 52 px tertiary buttons) | minor | `ui-2-findings.md` (Slice C): Guardian pages (Confirm, Waiting, Manage, Withdrawn, contact): no approved board in the export | Both | Both | yes | S |
| U90 | (h) | Mock last-minute clock color (`mock_session_page.dart`) | Clock stays amber in the last minute vs `MK_LastMinute` red (board vs HANDOFF/Timer README conflict; Aedwon rules) | minor | `ui-2-findings.md` (Slice D): Session (both): last-minute clock color | Both | Both | no | S |
| U91 | (h) | Web Mock save-failure line (`server_mock_route.dart`) | Save-failure line floats transparently over answer rows and leaves student on paper at `0:00` after a failed final submit | minor | `ui-2-findings.md` (Slice D): Session (web): save-failure line floats over the paper with no surface | Both | Web | yes | S |
| U92 | (h) | Wide web Mock pause timing (`pause_page.dart`) | Entry runs 3.9 s (board 3.4 s), delaying blink and tip loop (~4.4 s and ~9.3 s vs 0.5 s and 5.4 s) and combining staggered fades | minor | `ui-2-findings.md` (Slice D): Pause (wide web): entry runs 3.9 s; the board's last keyframe ends near 3.4 s, so blink and tip start late | Both | Wide web | no | S |
| U93 | (h) | Mock empty results fallback (`mock_results_route.dart`) | "Results not available" fallback renders bare `Text` plus a 52 px tertiary Back instead of `StateView` | minor | `ui-2-findings.md` (Slice D): Results (both): everything matches the boards except naming; Free/Pro lines checked | Both | Both | no | S |
| U94 | (h) | Mock finale timing (`mock_results_route.dart`, `cse_mock_finale.dart`) | Phone finale runs 9.65 s controller vs 11.35 s board hold and silently skips on question-count mismatch | minor | `ui-2-findings.md` (Slice D): Results (both): finale only plays for a fresh, completed, count-matching result; timings | Both | Both | no | S |
| U95 | (h) | Mock tab/app leave behavior (`server_mock_route.dart`, `mock_session_page.dart`) | Leaving tab auto-pauses non-strict mock without warning; strict mode gives 10 s grace despite Setup copy saying "instantly" | minor | `ui-2-findings.md` (Slice D): Session (web): leaving the tab pauses a non-strict mock without the warning | Both | Both (web mostly) | yes | S |
| U96 | (h) | Mock folder dead code (`lib/features/mock_exam/presentation/widgets/`) | Unused `mock_resume_sheet`, `exam_marks_offer`, `mock_status_card`, and `score_headline` (holds pass-band words) remain in source | minor | `ui-2-findings.md` (Slice D): Dead code in the mock folder | n/a | n/a | no | S |

---

## 2. Fix-Plan Groups (with Exact Evidence for Every Blocker and Major)

### (a) Save and sync robustness

#### Blockers and Majors

- **S1 [major]** Non-atomic `SubmitAnswer` writes corrupt FSRS state, duplicate `review_logs`, collide on PK, or miscount first-seen intro on retry.
  - Evidence (`codex-findings.md`, A session write can fail after the review was already committed): `lib/features/quiz/domain/use_cases/submit_answer.dart:70-128, lib/features/quiz/data/repos/quiz_session_repository.dart:132-185, lib/features/quiz/presentation/quiz_controller.dart:572-625, lib/features/quiz/presentation/quiz_page.dart:1631, lib/core/error/state_patterns.dart:37.`
  - Evidence (`codex-findings.md`, A review-log ID collision fails Check after rescheduling the question): `lib/features/quiz/domain/use_cases/submit_answer.dart:70-105, lib/core/storage/data/repos/review_log_repository.dart:24-46, lib/core/storage/data/tables/review_logs_table.dart:33-34.`
  - Evidence (`codex-findings.md`, A first-seen question can report a failure after its answer is already stored): `lib/features/quiz/domain/use_cases/submit_answer.dart:70-128, lib/features/quiz/data/repos/new_card_intro_repository.dart:23-57, lib/features/quiz/data/repos/quiz_session_repository.dart:148-153, lib/features/quiz/presentation/quiz_page.dart:1615-1631.`
  - Evidence (`gemini-findings.md`, A2): `` `lib/features/quiz/domain/use_cases/submit_answer.dart:70-128`, `lib/core/storage/data/repos/review_log_repository.dart:24-46`, `lib/core/storage/data/repos/review_state_repository.dart:17-37` ``

- **S2 [major]** `StartPractice.fromQuestionIds` does not deduplicate IDs; `recordAnswer` uses `indexOf`, breaking saves on duplicates or dropping missing IDs.
  - Evidence (`gemini-findings.md`, A3): `` `lib/features/quiz/domain/use_cases/start_practice.dart:176-185`, `lib/features/quiz/data/repos/quiz_session_repository.dart:148-169` ``
  - Evidence (`codex-findings.md`, A session write can fail after the review was already committed): `lib/features/quiz/data/repos/quiz_session_repository.dart:132-185`

- **S3 [major]** One out-of-catalog/retagged item, question ID over 128 chars, or unclamped `responseMs`/clock skew permanently rejects the entire completed quiz in `ingestSession`.
  - Evidence (`codex-findings.md`, One out-of-catalog answer can permanently exclude a completed quiz from server progress): `functions/src/ingestSession.ts:37-53,59-104, functions/src/_answers.ts:27-46, lib/features/home/data/study_observations.dart:126-169,188-225, firestore.rules:167-169.`
  - Evidence (`codex-findings.md`, Exam-tag changes can reject attempts backed by the other snapshot): `functions/src/ingestSession.ts:55-89, functions/src/_examContentBuild.ts:63-87, lib/features/home/data/study_observations.dart:199-225.` (1,287 main IDs missing a named exam membership on prod; 1,886 prod IDs missing on main, 1,264 absent from main.)
  - Evidence (`gemini-findings.md`, A6): `` `functions/src/_answers.ts:4-5,28-41`, `functions/src/content.ts:43`, `functions/src/ingestSession.ts:43,50-51`, `lib/features/quiz/presentation/quiz_controller.dart:589`, `lib/features/home/data/study_writes.dart:11-29`, `lib/features/home/data/study_observations.dart:201-223`, `lib/features/mock_exam/domain/server_mock_paper.dart:141,174,211,216`, `lib/features/mock_exam/application/server_mock_session.dart:295-299`, `lib/features/mock_exam/data/server_mock_api.dart:286-298`, `functions/src/mockReader.ts:142` ``

- **S4 [major]** Content refresh leaves obsolete exam memberships on device and mirror/upload/mapper do not filter `isActive: false` questions.
  - Evidence (`codex-findings.md`, Content refresh can leave obsolete exam memberships on the device): `lib/core/content/remote/content_mirror.dart:323-348,484-504,625-628,645-675, lib/core/storage/data/repos/content_repository.dart:148-166, functions/src/ingestSession.ts:86-89, docs/superpowers/verification/2026-11-22-cse-qa/codex-bank-named-main-missing-prod.txt.`
  - Evidence (`gemini-findings.md`, A5): `` `functions/src/_examContentBuild.ts:84`, `functions/src/contentUpload.ts:180-183`, `lib/core/content/remote/content_mirror.dart:571-579`, `lib/core/content/remote/question_set_mapper.dart:70-75`, `functions/src/ingestSession.ts:86-90`, `lib/features/home/data/study_observations.dart:201-223` ``

- **S5 [major]** All-Due Reviews or large Practice sittings over 300 answers are permanently rejected by `ingestSession` (`ustet.yaml` is at 300 with zero headroom).
  - Evidence (`codex-findings.md`, An all-due Reviews sitting can exceed the server answer limit): `lib/features/quiz/domain/models/review_batch.dart:63-87, lib/features/home/application/today_questions.dart:192-224, functions/src/_answers.ts:4,27-29, lib/features/home/data/study_observations.dart:199-224.`
  - Evidence (`gemini-findings.md`, A6 & B1): `` `functions/src/_answers.ts:4-5,28-41`, `lib/features/home/data/study_observations.dart:201-223`; `ustet.yaml` has `totalQ = 300` ``

- **S6 [major (codex) / minor (gemini)]** Web answer reveal precedes a 50 ms best-effort IndexedDB flush whose errors are swallowed.
  - Evidence (`codex-findings.md`, The web answer reveal can precede durable IndexedDB storage): `lib/core/storage/data/durable_writes.dart:5-26, lib/core/storage/data/database_opener_web.dart:49-92, lib/features/quiz/presentation/quiz_controller.dart:591-612.`
  - Evidence (`gemini-findings.md`, A9): `` `lib/core/storage/data/durable_writes.dart:14-27`, `lib/core/storage/data/database_opener_web.dart:88-91` ``

- **S7 [major]** A single malformed server review aborts the entire quiz or web Mock transaction.
  - Evidence (`codex-findings.md`, A single malformed server review aborts the session transaction): `functions/src/serverReviews.ts:9-31, functions/src/ingestSession.ts:91-104, functions/src/mockAnswers.ts:26-36, lib/features/home/data/study_observations.dart:199-225.`

- **S8 [major]** Invalid raw document path or uncaught `FirebaseException` in `PushPipeline` stalls the entire Pro sync outbox.
  - Evidence (`codex-findings.md`, An invalid raw question path can strand Pro synchronization): `lib/core/sync/engine/local_sync_mutation_recorder.dart:64-151, lib/core/sync/engine/push_pipeline.dart:64-115, lib/core/sync/firestore/firebase_firestore_gateway.dart:170-187, firestore.rules:91-128,240-319.`
  - Evidence (`gemini-findings.md`, A7): `` `lib/core/sync/engine/push_pipeline.dart:74-107`, `lib/core/sync/firestore/firebase_firestore_gateway.dart:100-114,144-154,242-266`, `lib/core/sync/runtime/production_sync_runtime_engine.dart:402-429` ``

- **S9 [major]** Corrupt stored `Attempt` JSON throws before the per-observation error guard, blocking later observation delivery.
  - Evidence (`codex-findings.md`, An invalid attempt JSON can hold up observation delivery): `lib/core/storage/data/repos/attempts_repository.dart:411-424, lib/features/home/data/study_observations.dart:126-169, lib/core/sync/mapping/attempt_mapper.dart:33-43, firestore.rules:240-247.`

- **S10 [major]** Reviews can fail at Finish with "Could not save your progress." after all questions were answered on screen.
  - Evidence (`codex-findings.md`, Reviews can fail at Finish after all questions were answered on screen): `lib/features/quiz/data/repos/review_batch_repository.dart:387-415,494-506,573-595, lib/features/quiz/data/repos/quiz_session_repository.dart:252-279, lib/features/quiz/application/quiz_completion_coordinator.dart:68-123, lib/features/quiz/presentation/quiz_page.dart:1633-1642.`

- **S11 [major]** Web Mock answer with unavailable/overlong choice is silently ignored; invalid question ID or timestamp fails the snapshot save and blocks later taps.
  - Evidence (`codex-findings.md`, A web Mock answer can be ignored or block every save carrying it): `lib/features/mock_exam/presentation/pages/server_mock_route.dart:474-485,607-618, lib/features/mock_exam/application/server_mock_session.dart:282-317,475-509,630-648, functions/src/mock.ts:362-417,425-467, functions/src/mockAnswers.ts:7-16.`

- **S12 [major]** Late web Mock save near a timed-part boundary can silently miss the closed part while reporting success.
  - Evidence (`codex-findings.md`, A late web Mock save can silently miss a closed part): `lib/features/mock_exam/presentation/pages/server_mock_route.dart:607-618, lib/features/mock_exam/application/server_mock_session.dart:282-317,492-509, functions/src/mock.ts:388-403, functions/src/_mockParts.ts:139-150.`

- **S13 [major]** Native Mock stores choice index instead of choice ID/version; 7 shared question IDs changed correct slot under version 1.
  - Evidence (`codex-findings.md`, Native Mock can lose an answer across content changes while still showing results): `lib/features/mock_exam/application/mock_session_controller.dart:271-278, lib/features/mock_exam/domain/use_cases/compute_results.dart:30-55, lib/features/mock_exam/application/mock_answer_recorder.dart:93-109, lib/features/mock_exam/presentation/pages/mock_start_route.dart:511-545,657-689.`
  - Evidence (`codex-findings.md`, Seven shared IDs change the correct choice under the same version): `lib/core/content/remote/content_mirror.dart:579-619, lib/core/storage/domain/choice_order.dart:18-26, lib/features/mock_exam/domain/use_cases/compute_results.dart:30-55, docs/superpowers/verification/2026-11-22-cse-qa/codex-bank-correct-slot-changed.txt.`

- **S14 [blocker if triggered (gemini) / major (codex)]** Zero correct choices or >6 choices crash render/save or drop the entire question set (0 violations in current banks).
  - Evidence (`gemini-findings.md`, A4): `` `lib/core/storage/domain/question.dart:58-61`, `lib/features/quiz/domain/use_cases/submit_answer.dart:47`, `lib/features/quiz/presentation/quiz_page.dart:553`, `lib/features/mock_exam/application/mock_answer_recorder.dart:109`, `lib/features/assessment/domain/use_cases/complete_assessment.dart:72`, `lib/core/content/remote/content_mirror.dart:558,613,617`, `lib/core/content/remote/question_set_mapper.dart:77,89,90` ``
  - Evidence (`codex-findings.md`, A missing correct choice can prevent the question from rendering): `lib/core/storage/domain/question.dart:58-61, lib/features/quiz/presentation/quiz_page.dart:547-554, lib/features/quiz/domain/use_cases/submit_answer.dart:47-57, lib/core/content/remote/question_set_mapper.dart:75-99, lib/core/content/remote/content_mirror.dart:607-621.`

- **S15 [major]** Missing local passage blocks Check before the save path starts (mirror writes already share a transaction per set, so the gap is cache/install loss recovery).
  - Evidence (`codex-findings.md`, A missing passage blocks Check before the save path starts): `lib/features/quiz/presentation/quiz_page.dart:165-190, lib/features/quiz/presentation/quiz_controller.dart:541-578, functions/src/contentUpload.ts:96-109, lib/core/content/remote/content_mirror.dart:631-644.`
  - Evidence (`codex-findings.md`, The current mirror already applies passages and questions atomically per set): `lib/core/content/remote/content_mirror.dart:323-341,631-644.`

- **S16 [major (gemini B1) / minor (gemini A8)]** `answerTotals` `MAX_ID_BYTES = 150,000` is exceeded by the prod bank (203,233 bytes), silently dropping distinct questions from roadmap/mastery.
  - Evidence (`gemini-findings.md`, A8): `` `functions/src/_answerTotals.ts:36-37,103-108` ``
  - Evidence (`gemini-findings.md`, B1 & B2): `docs/superpowers/verification/2026-11-22-cse-qa/prodtree/content/questions/**/*.yaml` (203,233 bytes = 135% of `MAX_ID_BYTES`; single-exam `upcat: 135,370`, `ustet: 115,335`, `cse-pro: 92,481`); `content/questions/**/*.yaml` (140,007 bytes = 93.3%).

- **S17 [major]** `OnboardingConsentStep._continue` awaits analytics/Crashlytics SDK toggles before saving Terms acceptance, blocking onboarding on SDK failure.
  - Evidence (`gemini-findings.md`, D1): `` `lib/features/onboarding/presentation/onboarding_consent_step.dart:89-93,107-109`, `lib/features/settings/data/settings_repository.dart:157-206`, `lib/app/telemetry_consent_controller.dart:52-116`, `lib/core/telemetry/firebase_telemetry.dart:68-117` ``

- **S18 [major]** Account deletion and sign-out await `notifications.cancelAll()` before wiping local data or deleting account.
  - Evidence (`gemini-findings.md`, D2): `` `lib/app/routes/settings_account_deletion.dart:1-13`, `lib/app/routes/settings_routes_native.dart:350`, `lib/core/sync/local_state_wiper.dart:70-72`, `lib/core/auth/auth_repository.dart:444-452,463-482`, `lib/features/settings/presentation/pages/delete_account_page.dart:64-68` ``

- **S19 [major]** `QuizCompletionCoordinator._complete` and `CompleteQuiz` await `_notifications?.onSessionCompleted()` before returning the completed `Attempt`.
  - Evidence (`gemini-findings.md`, D3): `` `lib/features/quiz/application/quiz_completion_coordinator.dart:115-131`, `lib/features/quiz/domain/use_cases/complete_quiz.dart:44-50`, `lib/features/quiz/presentation/quiz_controller.dart:642-655`, `lib/features/quiz/presentation/quiz_page.dart:1615-1642` ``

- **S20 [major]** `SettingsActions.updateStudyDays` and `saveReminderTime` await notification rescheduling inside the save call, blocking Onboarding and Settings.
  - Evidence (`gemini-findings.md`, D4): `` `lib/features/settings/application/settings_providers.dart:128-136,210-217`, `lib/features/onboarding/presentation/onboarding_study_days_step.dart:117-122`, `lib/features/settings/presentation/pages/exam_page.dart:328` ``

- **S21 [major]** Nine Settings `catch` blocks `await telemetry.recordError(error, stack)` before updating error UI state.
  - Evidence (`gemini-findings.md`, D5): `` `lib/features/settings/presentation/pages/account_page.dart:134,521,554`, `lib/features/settings/presentation/pages/backup_page.dart:79`, `lib/features/settings/presentation/pages/delete_account_page.dart:67`, `lib/features/settings/presentation/pages/name_page.dart:68,100`, `lib/features/settings/presentation/pages/whats_included_page.dart:200`, `lib/features/settings/presentation/carry_over_prompt.dart:180` ``

#### Minors
- **S22** Unguarded async rejections on `telemetry.log(...)` across Quiz, Lesson, Shell, Onboarding, Paywall, Mock.
- **S23** Five-question Reviews sitting silently skips an entire due passage group of 6+ questions.

---

### (b) Reports (finding 6 and 5)

#### Blockers and Majors

- **S24 [major]** Question reports are saved only on the device and never sent; unbounded message length, shared across accounts on wipe, lost on storage clear (finding 6). Backend design (`gemini-findings.md` C2): ship `submitQuestionReport` callable (`onAccountCall`, `enforceAppCheck`, `allowAtMost` 20/day, 1,000-char cap, Admin-only `questionReports/{id}`, 2 Firestore writes/report).
  - Evidence (`ui-1-findings.md`, Report a question): `` `lib/core/storage/data/report_queue.dart:87-89` `sendPending()` is empty ("No approved backend endpoint. Never discard an unsent report.") and nothing calls it; limits 3 per question and 20 per day are local (`:42-52`). `docs/superpowers/decisions/2026-11-02-founder-app-log.md:313` and `:369`; `report_form.dart:224-225`; `docs/ui-audit.md:2490` (stale). ``
  - Evidence (`gemini-findings.md`, C1): `` `lib/core/ui/components/report_form.dart:26-386`, `lib/core/storage/data/report_queue.dart:5-98`, `lib/features/quiz/presentation/quiz_page.dart:832-846,1262-1292`, `lib/features/quiz/presentation/quiz_review_page.dart:277-278,348-352`, `lib/features/assessment/presentation/assessment_page.dart:453-462,517-532`, `lib/core/sync/local_state_wiper.dart:70-142`, `lib/core/storage/data/database_opener_web.dart:35-46,88-91` ``
  - Evidence (`gemini-findings.md`, C2): `` `firestore.rules:167-169,176-179,448-450`, `functions/src/_limits.ts:3-27`, `functions/src/_appCheck.ts:4`, `functions/src/_accountAccess.ts`, `functions/src/clientTelemetry.ts:194-195` ``

- **U1 [major]** Phone report form opens as a separate dialog overlay over the bottom bar instead of morphing the bar in place, with wrong button styling vs `QN_Report` (finding 5). Note: "Save" / "Saved on this device." copy was Aedwon-approved (`2026-10-19-pwa-launch-log.md:2389`).
  - Evidence (`ui-1-findings.md`, Quiz session and review (phone): reporting a question does not morph the bottom bar): `` `lib/core/ui/components/report_form.dart:26-65`, `:145`, `:169-186`, `:251-262`; `lib/core/ui/motion/web_overlay_motion.dart:45-53`; `quiz_page.dart:833-845,936-960,1262-1266`; `quiz_question_viewer.dart:229-238,386-392,616-650`; `quiz_review_page.dart:278,348`; `assessment_page.dart:454,518`; `floating_bar.dart:40,62,89-92`; `mobile/project/QN_Report.dc.html`; `docs/design/SCREENS.md:279`; `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2389`. ``

#### Minors
- **U2** Report states: top-right reported icon not seeded from queue (resets to gray on re-entry); wide web `AssessmentPage`/`QuizReviewPage` pop silently; per-question limit copy unboarded; not wired in Mock.

---

### (c) Layout and spacing (finding 1)

#### Blockers and Majors

- **U3 [major]** Phone Quiz title sits 40 px lower than Study title (Study y=6, Quiz y=46 vs board y=50); wide web Study h1 has extra 4 px side inset (finding 1).
  - Evidence (`ui-1-findings.md`, Study and Quiz tabs (phone): Quiz title sits 40 px lower than Study title): `` Quiz `lib/features/quiz/presentation/quiz_tab_screen.dart:160-165` titlePadding top `PantasSpace.s44`, inside `PantasPage` `lib/core/ui/components/pantas_page.dart:432` scroll top padding `s2` (46 px). Study `lib/features/lesson/presentation/learn_tab_home.dart:297,299-304` page padding top `s6`, `lib/core/ui/components/search_field.dart:266-292` (6 px). Boards `mobile/project/ST_Map.dc.html` and `mobile/project/QZ_Tab.dc.html` (y 50). `docs/ui-audit.md:2567`; `settings_home_page.dart:251`; wide web `web_study_layout.dart:160-163` and `quiz_tab_screen.dart:253`. ``

- **U5 [major]** Phone Mock proctor call is an 8 s in-flow bar that shifts the question list by ~48 px instead of a 2.5 s 44 px pill overlay.
  - Evidence (`ui-2-findings.md`, Slice D, Session (phone): proctor call is a layout-shifting toast that stays 8 s): `presentation/proctor_toast.dart:17` (`proctorToastDisplayDuration = Duration(seconds: 8)`), `:59-72`; `pages/mock_session_page.dart:158-166, 197-199, 253-262`; board `mobile/MK_Proctor.dc.html` (`position:absolute; left:16; right:16; bottom:98px; height:44px; border-radius:22px`, 2.5 s).

#### Minors
- **U4** Phone Study tab title sits at y=0 (loading/empty/error) and y=6 (loaded) vs board y=50.
- **U6** Wide web sidebar top padding 20 vs 22, search-to-Home 14 vs 18, brand letter-spacing -0.264 vs -0.44.
- **U7** Sign-in and waiting screens switch to laptop layout at 720 px vs app's 1024 px.
- **U8** Phone Quiz session bar hint wraps to two lines and flag leaves bar under 400 px.
- **U9** Phone Pro page bar bottom padding/gap and hero eyebrow placement/radius drift from boards.
- **U10** Phone Account name 22 vs 24, gaps 6/10/20 vs 8/8/22; Settings root name weight 700 vs 600.
- **U11** Phone ExamSwitch and ChangeExam2 stacked bottom buttons miss 8 px and 6 px gaps.
- **U12** Phone Mock setup (24/8/32 vs 22/7/30) and session header (44 vs 50, left 4 vs 8) minor spacing drifts.
- **U13** Wide web Mock question list puts 40 px hide icon on right instead of 36 px on left.
- **U14** Phone Home week strip shrinks to 3-5 days for long "CSE Subprofessional" chip (needs a board).
- **U15** Phone Mock setup skeleton renders Material AppBar "Mock exam" and 20 px sides, jumping on load.

---

### (d) Unspecced text (finding 2)

#### Blockers and Majors

- **U16 [major]** "Part X of Y · N questions" label appears across 17 call sites (Study, Home, reader header, pull-up, ending, search, contents) with no Aedwon approval and no redrawn boards (finding 2).
  - Evidence (`ui-1-findings.md`, Study, reader, ending, search, contents, Home: the "Part X of Y · N questions" label): `` `lib/core/ui/components/lesson_label.dart:9-18,21-25,44-129`; `lib/features/lesson/application/lesson_bite_label.dart:34`; 17 call sites: `study_topic_section.dart:219`, `web_study_layout.dart:1197`, `lesson_page.dart:1424,1490,1662-1670`, `web_reader_layout.dart:628,866`, `ending_content.dart:198`, `web_ending_layout.dart:214`, `lesson_contents_sheet.dart:200`, `search_results.dart:58,237`, `web_lesson_search.dart:362`, `home_today_screen.dart:919,933`, `home_today_checklist.dart:324,587`, `pull_to_advance.dart:274-277`, `reader_gap.dart:38`. Boards: `mobile/project/ST_TopicOpen.dc.html`, `W_Study.dc.html`, `SD_Search.dc.html`, `RD_Real`, `RD_End`, `RD_Contents`, `W_Reader`. Spec/ruling: `docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md:3-5,12-15,60,87,104-108,443,446-447`; `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:3250,3490-3493,3584`; `docs/superpowers/plans/2026-11-14-bite-sized-lessons-pilot.md:194,316-321`. ``
  - Evidence (`ui-2-findings.md`, Slice B, Home: lesson rows carry "Part X of Y · N questions"): `lib/features/home/presentation/widgets/home_today_checklist.dart:324-330, 587-593`; `home_today_screen.dart:919, 933`; `lib/core/ui/components/lesson_label.dart:9-18`; boards `HM_Free`, `HM_Everything`, `HM_LessonsPanel`, `HP_Free`, `HP_Pro`, `HE_ManyLessons`; commit `4f4b01135`; `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:3248-3250, 3286, 3490`.

- **U17 [major]** Wide web Mock bottom bar shows false "Saved on this device" hint on server mocks and jumps in width on every answered question.
  - Evidence (`ui-2-findings.md`, Slice D, Session (wide web): "Saved on this device" hint in the bottom bar is false on web): `pages/mock_session_page.dart:1091-1101` (`hint: _isAnswered(...) ? 'Saved on this device' : null`, `compact: true`); `core/ui/web/web_components.dart:1556-1565,1696`; `data/server_mock_view_cache.dart:7-9`; `design/system/components/FloatingBar/README.md:23`; `design/system/patterns.md:115,122`; boards `MK_NavHidden`, `MK_SubmitCSE`.

- **U18 [major]** Mock exam is named three different ways across Setup, native Results ("Practice Paper"), and web Results ("CSE Professional") instead of "`<Exam>` simulation".
  - Evidence (`ui-2-findings.md`, Slice D, Setup/Results/Resume (both): the exam is named three different ways): `domain/mock_title.dart:1-11`; `application/mock_results_providers.dart:241-246, 261`; `mock_start_route.dart:226`; `mock_results_route.dart:203`; `widgets/mock_resume_sheet.dart:32`; boards `mobile/MK_Results`, `web/MK_ResultsFirst`.

- **U19 [major]** Plan History falls back to generic "Your plan changed on `<date>`." for six common causes instead of board sentences from stored facts.
  - Evidence (`ui-2-findings.md`, Slice B, Plan: History entries for six causes show the generic "Your plan changed on Oct 8."): `lib/features/home/application/plan_data.dart:38-62`; `lib/features/roadmap/domain/roadmap.dart:109-125`; boards `web/PL_History`, `PL_HistoryEnd`, `mobile/DP_History`.

- **U20 [major]** Pro page trial and lapsed states miss trial countdown/charge detail, use wrong row labels ("Monthly trial", "Charges"/"Ends"), and keep SAVE 32%/per-month on lapsed.
  - Evidence (`ui-2-findings.md`, Slice C, Pro page (Pro, trial and lapsed states): trial wording and rows differ from `ST_RootTrial` and `ST_ProLapsed`): `pro_page.dart:751-757`, `:1083-1098`, `:1114-1121`, `:1210-1216`, `:1293`, `:1444-1451`; boards `web/project/ST_RootTrial.dc.html`, `ST_ProLapsed` (phone and web); `STATUS.md:1264`.

#### Minors
- **U21** CSE one-block Mock uses multi-part wording ("in this subject", "in this part", "during Part 1") and wide proctor omits gray pill.
- **U22** Mock clock warning tag always says "5 min left" even under 1 minute; boards draw no tag.
- **U23** Wide web Performance table renders uppercase header row absent from `PF_*` boards.
- **U24** Wide web Home checklist footer band sits empty after dropping unmeasured time captions.
- **U25** Plan "Your plan had not started on this day." is plain unstyled text with no board.
- **U26** Pro page "Loading subscriptions..." (ellipsis) and "Could not load your passes." unstyled text have no board.
- **U27** Pro page Weekly, Yearly, and web CTA labels, confirming text, and missing fine print have no board.
- **U28** Onboarding guardian step reports failed link send as "Could not save your progress."; shared `saveFailureLine` has no board.
- **U29** Onboarding exam picker error/empty copy and styling differ between phone and wide web.
- **U30** Full-screen error claims "Nothing you've done is lost." without checking.
- **U31** Wide web update-required page omits board's unmeasured "It takes a few seconds. Your progress is safe."
- **U32** Home install card replaces full-screen `OB_Install` and makes unmeasured "Pantas opens faster" claim.
- **U33** Home trial notice wording differs from `HM_Trial` board (web no-charge wording unboarded; native starts "Google Play charges").
- **U34** Phone native Free Account footer contradicts sign-out dialog's "saved to your account".
- **U35** Legal Terms describe only web prepaid no-charge trial and Civil Service plans (clashes with native Play trial) plus title casing.
- **U36** Settings About adds unspecced rows/copy (speed/error toggle, printed DPO email, casing) and omits "Shared links".
- **U37** Settings Appearance adds unspecced "Lesson Text Size" header, wide zoom footer, and corrected Automatic sentence.
- **U38** Settings whats-included tier-change dialog and sync reconciliation dialog have no board.
- **U39** Wide web Mock flag-offer copy uses phone wording instead of `MK_ReviewFlagged`.
- **U40** Mock pause `n=0` discard copy ("Nothing is answered yet...") has no board.
- **U41** Phone Free Tendencies section header reads "YOUR TENDENCIES" vs wide "What we found".
- **U42** Web onboarding exam picker tags all held-back non-CSE exams "Coming soon" with no explanation.

---

### (e) Button sizing (finding 3)

#### Blockers and Majors

- **U43 [major]** Phone borderless tertiary buttons default to 52 px full width (`PantasButton` / `PantasSheet._CloseAction` across 9 sheets, Onboarding, and 14 other phone call sites; New questions sheet adds 32 px bottom padding) (finding 3).
  - Evidence (`ui-1-findings.md`, Borderless and text buttons across the whole app): `` `lib/core/ui/components/pantas_button.dart:44,151-160,307-318`; `pantas_button_spec.dart:191-198`; `design/system/components/bundle.css`; Button README line 15; `pantas_sheet.dart:404-428`; `design/system/components/sheet/README.md:64`; `lib/core/ui/components/today_questions.dart:78-132`; 9 sheet callers (`performance_page.dart:397-400`, `home_tab.dart:183-188`, `quiz_tab_screen.dart:286-291`, `home_today_screen.dart:686-697`, `practice_picker_screen.dart:397-402`, `quiz_page.dart:1093-1096`, `learn_tab_home.dart:290-295`, `lesson_page.dart:1438-1440`, `new_design/question_grid_sheet.dart:195-200`) + 17 other phone 52 px tertiary sites in `ui-1-findings.md:71-151`. ``
  - Evidence (`ui-2-findings.md`, Slice A Sheets & Onboarding): `lib/core/ui/components/pantas_sheet.dart:404-432`; `mobile/project/L_ChangeExam2.dc.html`; `design/system/components/Sheet/README.md:24`; `lib/features/onboarding/presentation/onboarding_study_days_step.dart:169-175`, `onboarding_exam_date_step.dart:186-197`; `mobile/project/O_Days.dc.html`, `O_Flow.dc.html`.
  - Evidence (`ui-2-findings.md`, Slice B Home & Performance): `lib/features/home/presentation/home_today_screen.dart:686-701`, `home_tab.dart:183-199`, `performance_page.dart:397-434`; `pantas_sheet.dart:340-348,365-368,402-428`; boards `mobile/project/HE_ManyLessons.dc.html`, `HP_NoDate.dc.html`, `HP_MonthOnly`, `DT_FilterFlow.dc.html`.
  - Evidence (`ui-2-findings.md`, Slice D Questions sheet): `core/ui/components/pantas_sheet.dart:404-430`, `core/ui/components/new_design/question_grid_sheet.dart:200`; boards `mobile/MK_Sheet.dc.html`, `MK_SheetCSE.dc.html`; `design/system/components/Sheet/README.md:17,93,103`.

- **U44 [major]** Phone Pro page "Restore Purchases" is a 52 px full-width bar button instead of a 24 px 15/600 line (Free) or a card row with no bar (Pro and lapsed).
  - Evidence (`ui-2-findings.md`, Slice C, Pro page (phone): "Restore Purchases" & Pro/lapsed): `lib/features/settings/presentation/pages/pro_page.dart:1040-1052`; `lib/core/ui/components/pantas_button.dart:152, :293`; `design/system/components/Button/README.md:39`; boards `mobile/project/ST_ProFree.dc.html`, `ST_ProCSE`, `ST_ProCSEPass`, `ST_ProPending`, `ST_ProRestoreOffline`, `ST_ProPro.dc.html`, `ST_ProPassHave.dc.html`, `ST_ProLapsed.dc.html`.

- **U45 [major (Slice A Dialogs) / minor (Slices A, B, C)]** Wide web `WebButton` tertiary buttons are 44 px / 20 px pad instead of board 40-42 px / 14-16 px pad across Dialogs, Home notices/date dialog, Pro, Account, and Onboarding.
  - Evidence (`ui-2-findings.md`, Slice A Dialogs & Onboarding): `lib/core/ui/components/centered_dialog.dart:150-156`; `design/system/components/Dialog/README.md:23`; `web/shared/pantas.css:73` (`.btn3` 42/14); `web/project/QN_ReportLimit.dc.html`, `HM_NoDateModal.dc.html`; `lib/features/onboarding/presentation/onboarding_web_page.dart:275-278`; `web_components.dart:186-191`; `web/project/OB_Days.dc.html`.
  - Evidence (`ui-2-findings.md`, Slice B Home): `lib/features/home/presentation/widgets/home_exam_date_sheet.dart:~146-152`; `lib/core/ui/components/pantas_button_spec.dart:101-109`; `lib/features/home/presentation/widgets/home_web_layout.dart:466-475`; `lib/core/ui/components/notice_strip.dart:208-216`; `web/project/HM_NoDateModal.dc.html`, `HM_NoDate.dc.html`.
  - Evidence (`ui-2-findings.md`, Slice C Pro & Account): `pro_page.dart:880-897`; `account_page.dart:274-292`; `web/project/ST_Paywall.dc.html`, `ST_ProCSE`, `ST_Account.dc.html`, `ST_SignOut`.

#### Minors
- **U46** Wide web sign-in buttons fill the 420 px form width, violating HANDOFF natural-width rule.
- **U47** Sign-in inline text links (`Resend Code`, `support@pantas.study`) have a 19.5 px tap target.
- **U48** Wide web Onboarding Back link is 40 px / 0 left pad vs board 36 px / 4 left pad.
- **U49** Wide web Home Reviews/New questions drawer button is full width (matches board, conflicts with HANDOFF).
- **U50** Phone Home/StateView "Try Again" is a full-width rounded rectangle instead of `DT_Error`'s natural-width pill; Home has no offline board.
- **U51** Plan History "See more" is a `WebTextLink` with "Loading" text on wide web (vs bordered white 44 px button) and 52 px / 600 weight on phone (vs ~49 px / 400).
- **U52** Wide web Reader end-of-part "Quiz yourself, N questions" lost its gray fill (dead `WebButton(white)` branch remains).

---

### (f) Public-launch items (beta surfaces G4, figures P10, sign-in limits)

#### Blockers and Majors

- **U53 [blocker (conditional: if release keeps `BETA_GATE=true`)]** Web beta gate blocks every non-listed public web visitor behind "This email isn't on the beta list"; `deploy-prod.md` omits `BETA_GATE` and still says Nov 9-15 (G4).
  - Evidence (`ui-2-findings.md`, Lead G4 & Slice A): `lib/app/beta_gate.dart:13-19, 21-27, 36-40, 63-80, 83-136`; `lib/app/sign_in/email_sign_in_page.dart:662-681, 688-690, 932-942, 960, 987`; `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2564, 2673, 2959, 3748, 4052`; `docs/deploy-prod.md:1, 8, 41-43`; `HANDOFF.md` / `OB_Welcome`, `OB_SignIn`, `L_SignIn`.

- **S25 [major (unrated launch-limit note in source)]** Public sign-in email daily send cap is `SIGN_IN_DAILY_SEND_CAP=20` for non-testers, refusing the 21st new public student per Manila day.
  - Evidence (`ui-2-findings.md`, Lead G4 Functions behavior after Nov 23): `functions/.env.pantas-prod:11` (`SIGN_IN_DAILY_SEND_CAP=20`), `functions/src/signInCode.ts:153-175` (40 reserved for listed testers and existing accounts; open bucket caps strangers at 20/day).

- **U54 [major (before Nov 23) / minor (cleanup after Nov 23)]** "Beta: Pro Features" switch is shown to any account while `betaProUntil` is active (failing for non-testers), with hard-coded "until Nov 23" and ellipsis "Turning On…" (G4). Auto-hides at Nov 23 00:00 PHT cutoff (`BETA_CUTOFF`).
  - Evidence (`ui-2-findings.md`, Lead G4 rows 13-15 & Functions notes & Slice C): `lib/features/settings/presentation/widgets/beta_pro_row.dart:42, 67, 80, 86, 97, 126-127`; `lib/features/settings/application/settings_providers.dart:227-236`; `lib/features/paywall/application/beta_pro_provider.dart:10, 23-24, 42-78`; `functions/src/betaPro.ts:16-22, 41-47, 55`; `functions/src/webEntitlement.ts:20`; `functions/.env.pantas-prod:2`, `functions/.env.pantas-staging:2`.

- **U58 [major]** Mock setup prints Pantas's invented CSE Subprofessional even-split counts (36/36/36/37) and unconfirmed 145 / 20 items as plain official facts with no caveat (P10).
  - Evidence (`ui-2-findings.md`, Lead P10 & Slice D): `content/mock/cse-sub.yaml:12-24`; `lib/features/mock_exam/domain/mock_title.dart:13-21`; `lib/features/mock_exam/presentation/pages/mock_setup_page.dart:145-147, 171-188, 316-323, 426-428, 485-545`; `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md:96` (A17); `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:1055, 4038`; board `mobile/MK_SetupCSE.dc.html`.

- **U59 [major]** Mock setup prints CSE Professional counts (20/55/35/45, 155 + 15) from one examinee with no "reported" marker, contradicting Sub's own 2020 CSC advisory (150 + 20) (P10).
  - Evidence (`ui-2-findings.md`, Lead P10 & Slice D): `content/mock/cse-pro.yaml:12-24`; `content/mock/cse-sub.yaml:12-17`; `lib/features/mock_exam/presentation/pages/mock_setup_page.dart:146, 180, 320, 485-545`; `lib/core/content/repos/mock_blueprint_repo.dart:32-33` (`source` and `sourceNote` stored, never read by presentation); `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:1050-1055`.

- **U60 [major]** Record "61% this week" labels the last week with answers as "this week" even if weeks old; empty-line message misstates calendar weeks (P10).
  - Evidence (`ui-2-findings.md`, Slice B, Record: "61% this week" is not always this week): `lib/features/home/presentation/record_page.dart:~154-185`; `lib/features/home/application/record_provider.dart:317-345`; board `web/project/MY_Record.dc.html`.

- **U61 [major]** Record "N day streak" (and Home "your streak is safe") is not decayed when study days are missed (P10).
  - Evidence (`ui-2-findings.md`, Slice B, Record: "N day streak" is not decayed when days are missed): `lib/features/home/application/record_provider.dart:~196`; `lib/features/quiz/domain/streak/streak_evaluator.dart:26-85`; `home_state_card.dart:60`; boards `MY_Record`, `MY_RecordRest`.

#### Minors
- **U55** Link preview `web/og-image.png` and `web/index.html` alt text still show "Pantas beta" / BETA mark (G4).
- **U56** Dead `beta_waiting_page.dart` hard-codes "The beta starts Nov 9", mixes "days/hours/min", and links to tester guide (G4).
- **U57** Tester-only beta Home notices, Settings "Feedback" BETA badge, and `/settings/beta-feedback` pages stay live after beta week with hard-coded Nov 9-22 dates, lowercase "Try again", and unexported canvas (G4; keep reward card for earners).
- **U62** Home exam-day "10 easy reviews" uses unsourced cap of 10 and "easy" claim with no difficulty field (P10).
- **U63** Performance CSE Professional overall accuracy uses weighted mean (5/30/35/30, not CSC-published; Aedwon-approved Nov 5) with no minimum answer count (P10).
- **U64** Record "questions answered" counts blank mock items and "time in sessions" uses uncapped wall clock (P10).
- **U65** Tendencies "Peak hour" uses ungated bucket accuracy and archetype cutoffs are invented (P10).
- **U66** Pro page hard-codes "7" in trial strings and About hard-codes "0.1.0" version constant (P10).

---

### (g) Content tooling (C3)

#### Blockers and Majors

- **C1 [major]** `tools/audit/run_all.py` aborts on sweep 3 (`sweep_illustrations`) with 618 stale-strategy errors on prod content, masking sweeps 4-11 (tooling/CI gate broken; 0 broken CSE visuals reach students).
  - Evidence (`content-findings.md`, C3-1): `` `tools/audit/run_all.py:18-45`; `tools/audit/sweep_illustrations.py:37-49`; `tools/audit/check_lesson_illustrations.py:22-24,51-74,180-325`; `docs/content/illustrations/strategy.tsv` (frozen at 279 rows); `tools/upload_content/upload_content.mjs:82-112`; `tools/upload_content/lesson_illustrations.mjs:48-118`; `lib/core/content/remote/content_mirror.dart:349-354,521-552`; `lib/core/content/remote/lesson_markdown.dart:61-132`; `lib/core/ui/components/content_renderer.dart:219-231,769-800,2067-2261`; `lib/core/ui/figures/figure_registry.dart:27-56`; `lib/core/ui/figures/question_figure.dart:18-79`; `content_repository.dart:171-189`. Masked sweeps 4-11 false-positive blockers: `corruption-and-its-effects.yaml:375-460`, `prime-factorization-gcf-lcm.yaml:306`, `more-figure-rules.yaml:217`. All 52 active CSE `ILLUSTRATION` markers resolve to preflight-clean SVGs (436 files, 0 failures) and all 6 active CSE `FIGURE` markers plus 94 CSE question `figureSpec` items use registered kinds. ``

#### Minors
- **C2** `tools/audit/run_all.py` crashes with `IndexError` on `main` (backlog C10) and `ModuleNotFoundError` under `python3 -I`.
- **C3** `tool/content/content_gate.dart` still keeps `legacy.json` fallback scoped per topic (spec B6 requires subject) and `docs/superpowers/backlog.md:170` still lists stale "968 unapproved" (prod C4 passes with 0 unapproved).
- **C4** 29 prod questions use a same-file passage with fewer than 4 questions under legacy importer rule (`tools/import_questions/converter.dart`).

---

### (h) Everything else

#### Blockers and Majors

- **U67 [major]** Beta sign-in, code step, not-on-list, and waiting screens have no exported board in `web-design/pantas-handoff`.
  - Evidence (`ui-2-findings.md`, Slice A, Sign-in: beta sign-in, code step, not-on-list and waiting screens have no exported board): `docs/ui-audit.md` (round 2 fix list); `lib/app/sign_in/email_sign_in_page.dart:577-584`; `sign_in_parts.dart:855`; `beta_waiting_page.dart:204, ~246, 285`; `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2568, 2649` (canvas `EBQopPTcLczwabNWkTSake`).

- **U68 [major]** Confirm dialogs opened via `showPantasDialog` skip the design system 420 ms rise-and-fade dialog motion.
  - Evidence (`ui-2-findings.md`, Slice A, Dialogs: confirm dialogs opened with `showPantasDialog` skip the design system dialog motion): `lib/core/ui/components/centered_dialog.dart:270-283`; callers `lib/app/routes/settings_routes_native.dart:506`, `lib/features/settings/presentation/pages/account_page.dart:535`, `whats_included_page.dart:246`; contrast `lib/core/ui/web/web_components.dart:2326`, `lib/core/ui/components/report_form.dart:33`, `features/mock_exam/.../web_mock_dialog.dart`; `design/system/motion.md:91`.

- **U69 [major]** CSE Pro page boards show Monthly and Season Pass only, while code and `pricing.md` add Weekly (₱49) and Yearly (₱1,199).
  - Evidence (`ui-2-findings.md`, Slice C, Pro page (CSE): board shows Monthly and Season Pass only): boards `mobile/project/ST_ProCSE.dc.html`, `web/project/ST_ProCSE`, `ST_PassSoon`, `ST_PassNoDate`, `ST_PassEnded`; `docs/pricing.md` (Civil Service row); `lib/features/paywall/domain/products.dart` (`pantas_cs_weekly`, `pantas_cs_yearly`); `pro_page.dart:720-730, 1442`.

- **U70 [major (phone) / minor (wide)]** Phone Delete account shows plain "Deleting..." / "Deletion request completed." with no steps screen; wide web merges the two stages into one and does not tick stages.
  - Evidence (`ui-2-findings.md`, Slice C, Delete account (phone) & Delete account (wide web)): `delete_account_page.dart:100-120, 371-386`; boards `mobile/project/L_Delete.dc.html`, `L_Rules.dc.html`.

- **U71 [major]** Phone native Settings "Reminders" row pushes `/settings/reminders`, which does not exist (router error; no Reminders page built).
  - Evidence (`ui-2-findings.md`, Slice C, Reminders (phone native): the row opens a route that does not exist): `lib/features/settings/presentation/settings_home_page.dart:333-347`; `lib/app/routes/settings_routes_native.dart`, `settings_routes_web.dart` (no `/settings/reminders` route); `lib/features/notifications/presentation/permission_rationale_page.dart`; `docs/superpowers/plans/new-design/STATUS.md:42, 1264`; boards `mobile/ST_Reminders`, `ST_RemindersOff`, `ST_RemindersOffSwitch`.

- **U72 [major]** Phone native Mock shows a second "Start the Paper" screen after Setup's Start, violating HANDOFF hard rule and diverging from web.
  - Evidence (`ui-2-findings.md`, Slice D, Setup to run (phone native): a second "Start the Paper" screen after setup's Start): `lib/features/mock_exam/presentation/pages/mock_start_route.dart:858-872`; `mock_start_preparation_page.dart:75, 115, 122`; `HANDOFF.md` Hard rules; boards `mobile/MK_SetupCSE.dc.html`, `mobile/L_Rules.dc.html`.

- **U73 [major]** Phone Mock review note card uses web labels and saves on instant tap with no Cancel / Add Note pair.
  - Evidence (`ui-2-findings.md`, Slice D, Review (phone): the note card differs from `MK_ReviewQNote` and `MK_ReviewBlank`): `pages/mock_review_page.dart:1306-1396, 1400-1414, 1553-1572`; boards `mobile/MK_ReviewQNote`, `MK_ReviewBlank`, `QN_Wrong`, `MK_ReviewQFree`, `web/MK_ReviewQ`.

- **U74 [major]** Free mock interval is 14 days on native phone vs 30 days on web, and both mobile and web QZ boards still say 14.
  - Evidence (`ui-2-findings.md`, Slice D, Setup/Quiz card (both): Free interval is 14 days on phone and 30 days on web): `widgets/mock_card.dart:23` (`freeMockIntervalDaysWeb = 30`); `app/routes/quiz_routes.dart:183, 203` (native 14); `pages/mock_setup_route.dart:198-202`; boards mobile and web `QZ_Free`, `QZ_First`; `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:520-531`.

#### Minors
- **U75** Phone reader bar bookmark double-scales on press (`.82` inside `PantasTapArea` `.98`).
- **U76** Study lesson rows run one DB query per row for question count (76 queries on Philippine Constitution) and flash a blank second line.
- **U77** Sign-in beta gate loading and error states use raw square skeletons, lowercase "Try again", and untappable support text.
- **U78** Wide web sidebar account block renders blank avatar and empty name until settings load.
- **U79** Home Pro welcome notice shows on every device/browser (not "once"); "See What's New" opens Performance.
- **U80** Wide web Home "More about you" uses Material glyphs and `WebRow` padding instead of board SVGs and card padding.
- **U81** Performance loading skeleton has no approved board.
- **U82** Deferred `/wrapped/:artifactId` deep link stays open on phone (redirected on wide web).
- **U83** Phone native Pro pending puts "Open Google Play" inline inside card (no icon) instead of bar CTA.
- **U84** Wide web Pro pending-payment board state (`ST_ProPending`) is not implemented.
- **U85** Wide web Pro owned boards (`ST_Pro`, `ST_RestoreDone`) still show "Renews" and "Manage Subscription" instead of prepaid "Ends".
- **U86** Account page has three unboarded elements ("Continue with Email", "Email" row, minor's "I'm 18 now" row).
- **U87** Backup page omits offline and Pro-not-signed-in states and uses a 52 px filled "Back Up Now" button instead of list row.
- **U88** Notifications `permission_rationale_page.dart` is unrouted dead code.
- **U89** Guardian pages (Confirm, Waiting, Manage, Withdrawn, contact) have no approved board in the export.
- **U90** Mock last-minute clock stays amber vs `MK_LastMinute` red (board vs HANDOFF/Timer README conflict).
- **U91** Web Mock save-failure line floats transparently over answer rows and stays at `0:00` on failed final submit.
- **U92** Wide web Mock pause entry runs 3.9 s (board 3.4 s), delaying blink and tip loop and merging staggered fades.
- **U93** Mock "Results not available" fallback is bare `Text` + 52 px tertiary Back instead of `StateView`.
- **U94** Mock finale phone timing runs 9.65 s vs 11.35 s board hold and silently skips on count mismatch.
- **U95** Leaving tab auto-pauses non-strict mock without warning; strict mode gives 10 s grace despite "instantly" copy.
- **U96** Dead code remains in mock folder (`mock_resume_sheet`, `exam_marks_offer`, `mock_status_card`, `score_headline`).

STAGE-DONE
