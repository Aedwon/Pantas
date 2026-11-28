# Gemini Independent Audit Findings: Quiz Answer Save Path & Question Report Path

Audit baseline:
- Policy: `origin/main` (`ecfeaf0d1`)
- Code worktree: `qa/cse-release-r1`
- Prod content tree: `build/audit/prodtree/content`
- Main content tree: `content/`

Findings are appended immediately as discovered across Parts A, B, C, and D.

---

## Part A: Quiz Answer Save Path (End-to-End Audit)

### A1. Passage-grouping order mismatch between in-memory `QuizSession` and persisted `quiz_sessions` blocks saving with "Could not save your progress."
- Severity: blocker
- Evidence: `lib/features/quiz/domain/quiz_session.dart:68`, `lib/features/quiz/domain/use_cases/start_drill.dart:75-93`, `lib/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart:77-97`, `lib/features/quiz/domain/use_cases/start_retake.dart:81-95`, `lib/features/quiz/domain/use_cases/start_today_session.dart:130-147`, `lib/features/quiz/data/repos/quiz_session_repository.dart:163-168`, `lib/features/quiz/presentation/quiz_page.dart:1615-1628`
- Failure: `QuizSession.start` reorders its in-memory `questions` via `groupPassageSets(questions)`, but `StartDrill`, `StartInlineLessonQuiz`, `StartRetake`, and `StartTodaySession` persist the un-grouped `picked` / `resolved.questions` IDs into `quiz_sessions.question_ids_json` instead of `session.questions`. Whenever a drill, inline lesson quiz, retake, or Today session includes 2+ questions sharing a `passageId` that were not already adjacent in `picked` (routine after `DrillPicker`/`InlineLessonPicker` shuffle or `RetakePicker` recency ordering), answering the first diverged index hits `questionIds[row.currentIndex] != outcome.questionId` in `QuizSessionRepository.recordAnswer`, throws `StateError('Persisted quiz session ... answer order is inconsistent')`, and displays **"Could not save your progress."** with a Try Again button that permanently fails. Because `SubmitAnswer` already wrote `review_state_local` and `review_logs` before `recordAnswer`, every retry also corrupts FSRS state and adds duplicate `review_logs` rows.
- Fix idea: Persist `session.questions.map((q) => q.id).toList()` (matching `StartPractice` and `QuizController.start`) in `StartDrill`, `StartInlineLessonQuiz`, `StartRetake`, and `StartTodaySession`.

### A2. Non-atomic `SubmitAnswer` writes corrupt FSRS state and duplicate `review_logs` (or collide on PK) on retry
- Severity: major
- Evidence: `lib/features/quiz/domain/use_cases/submit_answer.dart:70-128`, `lib/core/storage/data/repos/review_log_repository.dart:24-46`, `lib/core/storage/data/repos/review_state_repository.dart:17-37`
- Failure: `SubmitAnswer.call` executes 4 separate transactions in sequence (`_reviewRepo.upsert`, `_reviewLog.insert`, `_sessions.recordAnswer`, `_newCards.incrementForDay`). If `_sessions.recordAnswer` or `_newCards.incrementForDay` fails (e.g., transient storage error or A1), the student sees **"Could not save your progress."** and taps Try Again. On retry, `_reviewRepo.upsert` reads the already-mutated `ReviewState` and applies a second FSRS update (`reps` and `lapses` double-counted, interval shifted), `_reviewLog.insert` inserts a second log row (or throws SQLite `UNIQUE constraint failed: review_logs.id` if `now.microsecondsSinceEpoch` collides within the same millisecond on web where `DateTime.now()` has ms precision), and `existing == null` becomes false so `_newCards.incrementForDay` is silently skipped.
- Fix idea: Wrap all four writes in one `AppDatabase` transaction (with idempotent `insertOnConflictUpdate` or unique UUID for `review_logs.id`), or make retry guard against already-recorded `ReviewState`/`ReviewLog`.

### A3. `StartPractice.fromQuestionIds` does not deduplicate `questionIds`; duplicate IDs break `recordAnswer` with "Could not save your progress."
- Severity: major
- Evidence: `lib/features/quiz/domain/use_cases/start_practice.dart:176-185`, `lib/features/quiz/data/repos/quiz_session_repository.dart:148-169`
- Failure: `StartPractice.fromQuestionIds` appends every ID in `questionIds` without deduplicating (unlike `StartPractice.call` line 119). If a duplicate question ID enters a session, `recordAnswer` uses `questionIds.indexOf(outcome.questionId)` (line 148), which finds the first occurrence (`at < outcomes.length`) and returns early without incrementing `currentIndex` or appending to `outcomesJson`. On the very next question, `questionIds[row.currentIndex]` still points to the duplicate instead of the new question, throwing `StateError('Persisted quiz session ... answer order is inconsistent')` -> **"Could not save your progress."** permanently.
- Fix idea: Deduplicate `questionIds` in `StartPractice.fromQuestionIds` (and key `recordAnswer` by `row.currentIndex` rather than `questionIds.indexOf`).

### A4. Missing/zero correct choices or >6 choices crash question render/save or drop entire question sets
- Severity: blocker (if triggered by content)
- Evidence: `lib/core/storage/domain/question.dart:58-61`, `lib/features/quiz/domain/use_cases/submit_answer.dart:47`, `lib/features/quiz/presentation/quiz_page.dart:553`, `lib/features/mock_exam/application/mock_answer_recorder.dart:109`, `lib/features/assessment/domain/use_cases/complete_assessment.dart:72`, `lib/core/content/remote/content_mirror.dart:558,613,617`, `lib/core/content/remote/question_set_mapper.dart:77,89,90`
- Failure:
  - A question with 0 `isCorrect == true` choices throws `StateError('no correct choice')` in `Question.correctChoice` during `_QuestionContent.build` (render crash) and in `SubmitAnswer.call` (**"Could not save your progress."**), and `StateError('No element')` in `MockAnswerRecorder` / `CompleteAssessment`.
  - A question with 2+ `isCorrect == true` choices marks students wrong when they pick any correct choice other than the first (`firstWhere`).
  - A question with >6 choices throws `RangeError` on `labels[i]` (`['A'..'F']`) in `ContentMirror._applyQuestionSet` (dropping the ENTIRE question set silently) and `questionsFromSet`.
- Fix idea: Enforce 2..6 choices and exactly-one-correct in content validation and `contentUpload.ts`, and guard `correctChoice` / `labels` defensively.

### A5. `isActive: false` questions are served by catalog/mirror but rejected by `ingestSession`, permanently losing the session on server
- Severity: major
- Evidence: `functions/src/_examContentBuild.ts:84`, `functions/src/contentUpload.ts:180-183`, `lib/core/content/remote/content_mirror.dart:571-579`, `lib/core/content/remote/question_set_mapper.dart:70-75`, `functions/src/ingestSession.ts:86-90`, `lib/features/home/data/study_observations.dart:201-223`
- Failure: `buildExamContent` filters out questions with `question.isActive === false`, whereas `catalogItems`, `ContentMirror._applyQuestionSet`, and `questionsFromSet` only filter out undrawn figures and do NOT check `isActive === false`. If a YAML file contains an `isActive: false` question (or if a question is later withdrawn/untagged while still cached on device), the student can answer it locally, but `ingestSession` rejects the whole session with `invalid-argument` ('Question is outside this exam.'). `StudyObservations._send` treats `invalid-argument` as permanent, stores `'rejected'` in `device_prefs`, and never retries, so the entire session's answers are permanently dropped from server totals, roadmap, server FSRS reviews, and diagnosis.
- Fix idea: Filter `isActive === false` consistently in `contentUpload.ts`, `ContentMirror`, and `question_set_mapper.dart`, and filter retired/unknown question IDs in `ingestSession` for listed exams just as custom exams do (lines 61-68).

### A6. `MAX_ANSWERS = 300`, `MAX_ID_LENGTH = 128`, `chosen <= 130`, and `responseMs` bounds (`0..86_400_000`) permanently drop completed sessions in `ingestSession` (and block web mocks)
- Severity: major
- Evidence: `functions/src/_answers.ts:4-5,28-41`, `functions/src/content.ts:43`, `functions/src/ingestSession.ts:43,50-51`, `lib/features/quiz/presentation/quiz_controller.dart:589`, `lib/features/home/data/study_writes.dart:11-29`, `lib/features/home/data/study_observations.dart:201-223`, `lib/features/mock_exam/domain/server_mock_paper.dart:141,174,211,216`, `lib/features/mock_exam/application/server_mock_session.dart:295-299`, `lib/features/mock_exam/data/server_mock_api.dart:286-298`, `functions/src/mockReader.ts:142`
- Failure:
  - **Length mismatch (`160` vs `128` vs `64`)**: `content.ts` `ID_PATTERN` allows 1-160 chars (`^[A-Za-z0-9_.-]{1,160}$`), but `_answers.ts`, `ServerMockPaper.decode`, `ServerMockApi`, and `updateMockReview` cap `questionId` at **128** chars and `chosen` (`${id}_${letter}`) at **130** chars. A question ID of 129-160 chars is served to students, fails `ServerMockSession.answer` (silently ignoring the tap on web mock!), fails `ServerMockPaper.decode` (mock won't open), and permanently fails `ingestSession` with `invalid-argument` ('Bad question id.').
  - **Unclamped `responseMs`**: `QuizController.check` computes `now.difference(s.questionShownAt!).inMilliseconds` using wall clock `DateTime.now()`. A backward clock jump (NTP/manual) yields `responseMs < 0`, and leaving a quiz open >24h before tapping Check yields `responseMs > 86_400_000`. Both pass local Drift save but fail `checkAnswers` (`Bad answer time.`), permanently rejecting the entire session in `StudyObservations`. Similarly, backward clock skew between `startedAt` and `completedAt` throws `StateError('Completed session timing required')` in `studySessionPayload`, also permanently marked `'rejected'`.
  - **Session length > 300**: "All due" (`QuizPreferences.allDueSessionLength`) or a large multi-topic Practice session can exceed `MAX_ANSWERS = 300`; local save succeeds, then `ingestSession` permanently rejects the entire session (`Send 1 to 300 answers.`).
  - **Characters outside `ID_PATTERN`**: Any question ID with characters outside `[A-Za-z0-9_.-]` fails `checkAnswers` (`Bad question id.`), and any ID containing `/` or reserved Firestore names (`.`, `..`, `__.*__`) breaks Pro Sync `PushPipeline._rowPath` (which does not URL-encode `row.rowId`).
- Fix idea: Enforce one shared ID schema (`<= 64` or `<= 128` chars, `[A-Za-z0-9_-]`) at content upload, clamp `responseMs` to `[0, 86_400_000]` and `finishedAt >= startedAt` before sending `ingestSession`, and chunk or cap quiz sessions at `<= 300` answers.

### A7. `PushPipeline._flushSerialized` does not catch `FirebaseException` from `FirebaseFirestoreGateway.commitRowIfBaseMatches`, stalling the entire Pro sync outbox on one bad row
- Severity: major
- Evidence: `lib/core/sync/engine/push_pipeline.dart:74-107`, `lib/core/sync/firestore/firebase_firestore_gateway.dart:100-114,144-154,242-266`, `lib/core/sync/runtime/production_sync_runtime_engine.dart:402-429`
- Failure: `PushPipeline._flushSerialized` catches only `SyncGatewayException` (line 99) to record per-row failures and continue draining later rows. However, `FirebaseFirestoreSdkClient.runTransaction` and `readDocument` (used by `commitRowIfBaseMatches`) let raw `FirebaseException` (e.g., `permission-denied`, `invalid-argument`, doc > 1 MiB) and `ArgumentError` (e.g., `/` in `rowId`) propagate uncaught without wrapping them in `SyncGatewayException`. One un-pushable `fsrs_cards`, `review_logs`, or `quiz_attempts` row aborts `_flushSerialized` immediately without calling `_queue.markFailure`, emitting `SyncRuntimeFailure` and starving every subsequent row in the outbox (retried every 30s forever).
- Fix idea: Catch `FirebaseException` in `FirebaseFirestoreSdkClient.runTransaction`/`readDocument` (wrapping as `SyncGatewayException`, matching `readCollection` line 91) and handle non-retryable per-row errors in `PushPipeline` without starving the queue.

### A8. `answerTotals` `MAX_ID_BYTES = 150_000` silently drops distinct questions beyond ~2,800-3,500 answered questions
- Severity: minor
- Evidence: `functions/src/_answerTotals.ts:36-37,103-108`
- Failure: `addSession` caps the `answerTotals` question table at `MAX_QUESTIONS = 6000` and `MAX_ID_BYTES = 150_000` (sum of UTF-8 byte lengths of `JSON.stringify(questionId)`). Once a student's seen distinct question IDs exceed 150,000 bytes (below the 4,427-question prod bank; exact bank byte totals measured in Part B), subsequent new questions are silently skipped from `totals.questions` (`continue` at line 104), so their correctness, history, and topic mastery stop updating in the roadmap while `totals.answers` still increments.
- Fix idea: Raise `MAX_ID_BYTES` (or use shorter IDs / compact indexing) while verifying the resulting `answerTotals` document stays safely under Firestore's 1 MiB limit.

### A9. Web IndexedDB transaction commits wait 50ms for a best-effort plain `SELECT 1` flush; tab close/crash loses the last saved answer
- Severity: minor
- Evidence: `lib/core/storage/data/durable_writes.dart:14-27`, `lib/core/storage/data/database_opener_web.dart:88-91`
- Failure: On web IndexedDB (`sharedIndexedDb` / `unsafeIndexedDb`), Drift commits transactions in memory without flushing to IndexedDB until a plain statement runs. `flushAfterWrites` schedules `SELECT 1` after a 50ms debounce and swallows errors with `.catchError((Object _) {})`. A fast tab close, reload, or browser kill within 50ms of answering a question (or after a silent flush error) loses the answer even though the UI showed the reveal.
- Fix idea: Flush immediately (or await `waitForDurableWrites()` on `pagehide` / session completion) and report flush failures instead of swallowing them.

### A10. Layer-by-layer limit & shape reference table (Part A summary)
- Severity: info
- Evidence:
  - **Quiz UI / Controller** (`quiz_controller.dart:541-627`, `quiz_page.dart:1615-1628`): `question.correctChoice` requires >=1 `isCorrect` choice (`StateError` -> **"Could not save your progress."**); `responseMs = now - questionShownAt` unclamped; `_runWrite` catches ANY throw from `check()`, `next()`, or `_toggleFlag()` and shows **"Could not save your progress."**.
  - **Telemetry** (`telemetry.dart:83-114`, `submit_answer.dart:60-68`): `question_id`, `chosen_label`, `origin` must match `^[a-zA-Z0-9_-]{1,64}$` (throws `ArgumentError` before save -> **"Could not save your progress."**; hotfix in review). `chosen_label` falls back to `chosenChoiceId` (`len = id.len + 2`) if choice is not in `question.choices`.
  - **Content hydration** (`content_mirror.dart:558,613`, `question_set_mapper.dart:77,89`): `choices.length <= 6` (`labels = A..F`, else `RangeError`); choice id = `${id}_${label.toLowerCase()}`; `isActive: false` not filtered.
  - **Local Drift (SQLite / Web WASM)** (`app_database.dart`, `review_state_repository.dart`, `review_log_repository.dart`, `quiz_session_repository.dart`): no length caps; `review_logs.id = '${question.id}-${now.microsecondsSinceEpoch}'` PK uses `insert()` (throws on PK collision); `quiz_sessions.recordAnswer` requires exact order match `questionIds[row.currentIndex] == outcome.questionId` (`StateError` -> **"Could not save your progress."**) and existing session row (`getSingle()`).
  - **Pro Sync Outbox & Firestore Rules** (`push_pipeline.dart:113-115`, `firestore.rules:91-109,240-341`): `rowId` placed verbatim in Firestore doc path (`fsrs_cards/{questionId}`, `review_logs/{questionId-micros}`, `quiz_attempts/{uuid}`) without URL-encoding (forbids `/`, `.`, `..`, `__.*__`, >1,500 UTF-8 bytes); `originDeviceId`/`mutationId` `1..128` chars; `schemaVersion == 1`; doc size <= 1 MiB; strict field allowlists per collection.
  - **Server `ingestSession` / `_answers.ts` / `mock.ts` / `serverReviews.ts` / `studyObservations.ts`**:
    - `sessionId`: `/^[A-Za-z0-9_-]{8,64}$/` (`ingestSession.ts:24`); `<= 128` & `ID_PATTERN` (`sessionDiagnosis.ts:32`).
    - `mockId`: `/^[A-Za-z0-9]{10,40}$/` (`mock.ts:366,429`).
    - `answers.length`: `1..300` (`_answers.ts:4,28`; 0 allowed only on `strict-exit`).
    - `questionId`: `ID_PATTERN = /^[A-Za-z0-9_.-]{1,160}$/` AND `length <= 128` (`_answers.ts:5,35`, `mockReader.ts:142`, `server_mock_paper.dart:141`).
    - `chosen`: `null` or string `length <= 130` (`_answers.ts:36`, `server_mock_paper.dart:216`); `_answerTotals.ts:114` & `sessionDiagnosis.ts:96` expect `${questionId}_[a-f]`.
    - `responseMs`: safe int `0..86_400_000` (`_answers.ts:38-39`).
    - `questionVersion`: safe int `>= 1` (`_answers.ts:40-41`).
    - `startedAt`, `finishedAt`, `answeredAt`: `>= 2020-01-01T00:00:00Z` and `<= now + 86_400_000`, with `finishedAt >= startedAt` (`_answers.ts:6-7,15`, `ingestSession.ts:44-46`).
    - `durationMs`: `0..max(86_400_000, wallMs)` for attributed sessions (if `> 86_400_000`, must equal `wallMs`) (`ingestSession.ts:49-51`).
    - `origin`: one of 8 allowed strings (`ingestSession.ts:36`).
    - `lessonId` (`recordLessonRead`): `1..128` chars, no `/`, must exist in `content/lessons/items/{lessonId}` (`studyObservations.ts:23,36`).
    - `getContent` `ids`: `1..20` per call, each matching `ID_PATTERN = /^[A-Za-z0-9_.-]{1,160}$/` (`content.ts:42-43`).
    - `DAILY_SESSIONS = 200` per rolling 24h (`ingestSession.ts:23,52`).
- Fix idea: Centralize all ID/payload invariants in a shared spec and automated content+contract check so client, sync, and server enforce identical bounds.

---

## Part B: Full Content Audit (Prod `build/audit/prodtree/content` & Main `content/`)

Every question, lesson, passage, set, topic, and mock blueprint across all exams in both content trees was checked programmatically with Ruby (`YAML.safe_load`). Per-rule failing ID lists are written to `build/audit/gemini-bank-<tree>-<rule>.txt`.

### B1. Prod content tree (`build/audit/prodtree/content`): 4,427 questions across 189 YAML files and 9 exams
- Severity: blocker (`qid-over-64` on unpatched prod) / major (`answerTotals` byte ceiling) / minor (`lesson-id-over-64`)
- Evidence: `build/audit/prodtree/content/questions/**/*.yaml`, `build/audit/prodtree/content/lessons/**/*.md`, lists:
  - `build/audit/gemini-bank-prod-qid-over-64.txt`
  - `build/audit/gemini-bank-prod-choice-id-over-64.txt`
  - `build/audit/gemini-bank-prod-choice-count-not-4.txt`
  - `build/audit/gemini-bank-prod-lesson-id-over-64.txt`
- Failure & rule counts across all 4,427 questions (unique IDs: 4,427; active + drawn: 4,427; YAML parse errors: 0; totals per exam: `acet: 1978, cse-pro: 1751, cse-sub: 1523, dlsucet: 2236, dost-sei: 2210, pshs-nce: 101, pupcet: 1074, upcat: 3228, ustet: 2750`):
  - **`qid-over-64` (fails `telemetry.dart` `^[a-zA-Z0-9_-]{1,64}$`)**: **261 questions** (max length **85**: `q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0001`). Per exam: `acet: 50, cse-pro: 261, cse-sub: 211, dlsucet: 28, dost-sei: 22, pshs-nce: 0, pupcet: 0, upcat: 28, ustet: 50`.
  - **`choice-id-over-64` (`${id}_${letter}` > 64, fails telemetry if `orElse` fallback triggers)**: **284 questions**. Per exam: `acet: 71, cse-pro: 282, cse-sub: 211, dlsucet: 49, dost-sei: 43, pshs-nce: 2, pupcet: 0, upcat: 49, ustet: 71`.
  - **`qid-over-128` / `choice-id-over-130` (fails `_answers.ts` / `ServerMockApi` / `ServerMockPaper`)**: **0** (max question ID is 85, max choice ID is 87, max review log ID is 102).
  - **`qid-bad-telemetry-chars` / `qid-bad-server-pattern` / non-ASCII / `/` / `.` / `..` / `__.*__`**: **0**.
  - **`duplicate-qid` (within or across files)**: **0**.
  - **`choice-count-bad` (< 2 or > 6 choices)**: **0** (distribution: 4,332 have 4 choices, 95 have 5 choices; `choice-count-not-4` per exam: `pshs-nce: 82`, `acet/cse-pro/cse-sub/dlsucet/dost-sei/upcat/ustet: 13` each).
  - **`correct-count-not-1` (0 or >1 correct choices)**: **0**.
  - **`empty-choice-text` / `empty-stem` / `empty-explanation` / `duplicate-choice-texts` / `choiceKind=figure` missing figures**: **0**.
  - **`is-active-false` / `undrawn-figure`**: **0**.
  - **`missing-passage-ref` / bad passage ID**: **0** (68 unique passages; 289 questions carry `passageId`: `acet: 229, cse-pro: 189, cse-sub: 189, dlsucet: 229, upcat: 289, ustet: 269` -> direct blast radius for A1!).
  - **`missing-explicit-lesson-ref` / `missing-derived-lesson-ref` / `broken-retired-lesson-ref` / `inactive-lesson-ref` / `keypoint-out-of-range` / `lesson-topic-mismatch`**: **0**.
  - **`set-id-bad` (`qs-...` > 160 or bad chars)**: **0** (max set ID length **103**).
  - **`lesson-id-over-128` (fails `recordLessonRead`)**: **0** (max lesson ID length **92**: `lesson-philippine-constitution-bill-of-rights-backward-penal-laws-and-legislative-punishment`).
  - **`lesson-id-over-64` (would fail `telemetry.dart` if ever logged)**: **138 of 1,271 lessons** (`build/audit/gemini-bank-prod-lesson-id-over-64.txt`).
  - **`unknown-topic` / `unknown-exam` / `missing-meta` / bad topic ID**: **0**.
  - **`answerTotals` `MAX_ID_BYTES = 150,000` exceeded across bank**: Total unique question ID JSON bytes = **203,233 bytes** (135% of `MAX_ID_BYTES`). Single-exam peaks: `upcat: 135,370` (90%), `ustet: 115,335` (77%), `dost-sei: 96,352`, `dlsucet: 95,973`, `cse-pro: 92,481`. Any student who studies two exams (or custom track across exams) exceeds 150,000 bytes and hits silent question drops in `_answerTotals.ts:104`.
  - **Mock blueprint totals**: `ustet.yaml` has `totalQ = 300` (exactly at `MAX_ANSWERS = 300`, zero headroom); `upcat = 250`, `dcat = 235`, `cse-pro = 155`, `cse-sub = 145`.
- Fix idea: Shorten or enforce max ID length in content CI, raise `_answerTotals.ts` `MAX_ID_BYTES`, and add CI checks for all Part A limits.

### B2. Main content tree (`content/`): 3,163 questions across 158 YAML files and 8 exams (plus `historical_v1.json`)
- Severity: blocker (`qid-over-64` on unpatched prod) / minor
- Evidence: `content/questions/**/*.yaml`, `content/lessons/**/*.md`, `tools/build_content_export/historical_v1.json`, lists:
  - `build/audit/gemini-bank-main-qid-over-64.txt`
  - `build/audit/gemini-bank-main-choice-id-over-64.txt`
  - `build/audit/gemini-bank-main-choice-count-not-4.txt`
  - `build/audit/gemini-bank-main-lesson-id-over-64.txt`
- Failure & rule counts across all 3,163 questions (unique IDs: 3,163; active + drawn: 3,163; YAML parse errors: 0; totals per exam: `acet: 1700, cse-pro: 1060, cse-sub: 880, dlsucet: 2543, dost-sei: 1683, pupcet: 880, upcat: 2543, ustet: 2723`):
  - **`qid-over-64` (fails `telemetry.dart`)**: **80 questions** (max length **67**: `q-peace-and-human-rights-humanitarian-law-and-human-rights-law-0001`). Per exam: `acet: 20, cse-pro: 80, cse-sub: 40, dlsucet: 0, dost-sei: 20, pupcet: 0, upcat: 0, ustet: 20`.
  - **`choice-id-over-64`**: **100 questions**. Per exam: `acet: 40, cse-pro: 100, cse-sub: 40, dlsucet: 0, dost-sei: 40, pupcet: 0, upcat: 0, ustet: 40`.
  - **`historical_v1.json`** (2,361 legacy bundled questions): **49 questions** have ID length 66-67 (> 64); 0 have choice/correctness issues.
  - **`qid-over-128` / `choice-id-over-130` / bad chars / duplicates / `choice-count-bad` / `correct-count-not-1` / `is-active-false` / `undrawn-figure` / missing refs**: **0** across all rules (choice counts: 3,150 have 4 choices, 13 have 5 choices; 52 passages across 260 passage questions in `acet/dlsucet/upcat/ustet`).
  - **`lesson-id-over-64`**: **4 of 158 lessons** (max length **67**); **`lesson-id-over-128`**: **0**.
  - **`answerTotals` unique ID JSON bytes**: **140,007 bytes** (93.3% of `MAX_ID_BYTES = 150,000`).
  - **Mock blueprint totals**: `acet = 270`, `upcat = 250`, `cse-pro = 155`, `cse-sub = 145`.
- Fix idea: Apply the same unified content-validation gate across both `main` and release content branches.

---

## Part C: Question Report Path (End-to-End Audit)

### C1. End-to-end trace, offline/online behavior, and data-loss risks in the report path
- Severity: major (reports never leave the device; silent loss on web wipe/reinstall/clear-data; no length cap; misleading copy)
- Evidence: `lib/core/ui/components/report_form.dart:26-386`, `lib/core/storage/data/report_queue.dart:5-98`, `lib/features/quiz/presentation/quiz_page.dart:832-846,1262-1292`, `lib/features/quiz/presentation/quiz_review_page.dart:277-278,348-352`, `lib/features/assessment/presentation/assessment_page.dart:453-462,517-532`, `lib/core/sync/local_state_wiper.dart:70-142`, `lib/core/storage/data/database_opener_web.dart:35-46,88-91`
- Failure / exact end-to-end behavior:
  1. **Entry points**: `openQuestionReport(context, questionId, queue: ReportQueue(db))` is wired on phone and wide web in `QuizPage`, `QuizReviewPage`, `FlaggedQuestionViewerPage`, and `AssessmentPage`. (Not wired in `MockSessionPage` / `MockReviewPage`.)
  2. **UI init (`ReportForm._load`, `report_form.dart:96-116`)**: Calls `queue.pending()` and `queue.limit(questionId, DateTime.now())` (reading `device_prefs` key `'quiz_question_reports'`).
     - Per-question lifetime cap: **3 reports** (`report_queue.dart:43`) -> shows *"You reported this question before."* and disables input + Save button.
     - Per-local-day cap: **20 reports** (`report_queue.dart:46`) -> shows *"You've sent a lot of reports today. You can send more tomorrow."* and disables input + Save button.
     - Previously reported 1-2 times: shows *"You reported this question before. Feel free to add any other concern so we can work on it right away."* (note: *"so we can work on it right away"* and *"Tell us and we'll check it."* imply the report reaches Pantas!).
     - No `maxLength` on `PantasField` (`report_form.dart:230-242,345-357`) and no length check in `ReportQueue.add` (`report_queue.dart:52-85`): unbounded text can be saved into a single JSON array row in `device_prefs`.
  3. **Submission (`ReportForm._send` -> `ReportQueue.add`)**: Trims text; inside one Drift transaction, re-checks limits, appends `{questionId, message, createdAt}` to the JSON array under `device_prefs.key = 'quiz_question_reports'`, and upserts the row.
     - **Offline vs Online**: Identical! There is ZERO network call. `ReportQueue.sendPending()` (`report_queue.dart:87-89`) is an empty no-op (`// No approved backend endpoint. Never discard an unsent report.`) and is **never even called anywhere in `lib/`**.
     - **What the student sees**:
       - On **phone** (`report_form.dart:145,169-186`): form turns into *"Saved on this device."* for 2,300 ms, then auto-closes and highlights the report icon (`_reported.add(question.id)` in memory for the current screen instance).
       - On **wide web** (`report_form.dart:142-143`, `quiz_page.dart:1262-1291`): `onSaved` immediately pops the panel; `QuizPage` shows *"Saved on this device."* beside the top-bar icon for 4 seconds (`AssessmentPage` and `QuizReviewPage` pop silently without showing that text!).
       - If `queue.pending()` or `queue.add()` throws (e.g. corrupted JSON in `device_prefs` or storage error): shows `saveFailureLine` = **"Could not save your progress."** (`report_form.dart:244,359`).
  4. **What is lost and when**:
     - **Never sent**: Every report ever filed by any student sits stranded in local `device_prefs` (`pantas.db` on native / `pantas-study-v2` IndexedDB or OPFS on web) and never reaches Pantas.
     - **Lost on**: app uninstall, OS storage clear, browser site-data clear / private browsing close, web `_UnreadableDatabase` auto-delete (`database_opener_web.dart:35-46`), or web tab close within 50ms of Save before `flushAfterWrites` persists IndexedDB (`durable_writes.dart:14-27`).
     - **Survives**: `SyncLocalStateWiper.wipeAll()` (`local_state_wiper.dart:70-142`) does NOT delete `quiz_question_reports` from `device_prefs` (so on a shared device/browser, account B inherits account A's pending reports and per-question/daily limits!).
     - **Corrupt JSON lock**: If the single JSON array in `device_prefs['quiz_question_reports']` ever fails `jsonDecode` or type cast (`report_queue.dart:30-37`), every future `openQuestionReport` fails permanently with **"Could not save your progress."**.
- Fix idea: Add an idempotent `submitQuestionReport` callable (details in C2), cap message length (e.g., 1,000 chars), flush pending reports on save and app resume/reconnect, and wipe/scope `quiz_question_reports` per account or remove items once server-acknowledged.

### C2. Backend design requirements for question reports (callable vs direct write, rules, App Check, daily write cost)
- Severity: info
- Evidence: `firestore.rules:167-169,176-179,448-450`, `functions/src/_limits.ts:3-27`, `functions/src/_appCheck.ts:4`, `functions/src/_accountAccess.ts`, `functions/src/clientTelemetry.ts:194-195`
- Failure / gap & backend specification:
  - **Callable vs direct Firestore write**: **Use a Cloud Function callable** (`submitQuestionReport` via `onAccountCall`, `region: 'asia-southeast1'`, `enforceAppCheck: enforceAppCheck`), NOT a direct client Firestore write. Reasons:
    1. Matches Pantas's repo-wide security posture (`firestore.rules` blocks all direct client writes to `betaFeedback`, `server/**`, and top-level triage collections; `betaFeedback` and `ingestSession` use callables).
    2. Allows atomic server-side validation (`questionId` length `<= 128` & `ID_PATTERN`, `message` trimmed `1..1000` chars, optional `clientReportId` UUID for idempotent retry deduplication, optional `appVersion`/`examId`) and server-side rate limiting via `allowAtMost(uid, 'questionReports', 20, 86_400_000)` + per-question cap (`<= 3` per `(uid, questionId)`).
    3. Allows both anonymous and named accounts (matching `getContent` / `ingestSession`, using `onAccountCall` so withdrawn/deleted accounts are rejected) without exposing other users' reports or letting a client forge timestamps or flood unbounded text.
  - **Firestore storage & rules**: Store in a server-only collection, e.g. `questionReports/{reportId}` (deterministic ID `${uid}_${clientReportId}` for idempotent retries, or auto-ID + clientReportId check), with fields `{uid, questionId, message, examId?, appVersion?, createdAt: serverTimestamp(), clientCreatedAt, status: 'open'}`. Keep `match /questionReports/{id} { allow read, write: if false; }` in `firestore.rules` (Admin SDK writes only, zero client read/write surface).
  - **App Check**: Set `enforceAppCheck: enforceAppCheck` (same as `ingestSession` and `reportClientTelemetry`). `consumeAppCheckToken` is not required because reports are non-financial and already bounded by per-UID rate limits (unlike payments/mock start).
  - **Per-day Firestore write cost**:
    - Using `allowAtMost` (`users/{uid}/limits/questionReports`): **2 writes per accepted report** (1 limit-doc write + 1 `questionReports` doc write) and **1-2 reads** (limit doc + optional dedupe/per-question count check).
    - Worst-case per malicious/active account per day (at 20/day limit): **40 writes/day** (~$0.000072/day at $0.18 per 100k Firestore writes).
    - Realistic scale: 1,000 DAU with 2% reporting rate = 20 reports/day = **40 Firestore writes/day** (well inside Spark/Blaze free tier of 20,000 writes/day). Even 10,000 DAU at 5% = 500 reports/day = **1,000 writes/day** (~$0.05/month).
    - Client-side outbox change: Add a stable `id` (UUID v4) and `sentAt` (or separate sent-count table) to `ReportQueue` so `sendPending()` can delete/mark sent reports without losing the local 3-per-question / 20-per-day counter, and call `sendPending()` after `add()`, on startup, and on reconnect.
- Fix idea: Ship `submitQuestionReport` callable with `onAccountCall`, `enforceAppCheck`, `allowAtMost(uid, 'questionReports', 20, DAY_MS)`, 1,000-char message cap, and Admin-only `questionReports/{id}` collection.

---

## Part D: Other Student-Visible Failure Paths With the Same Shape (Optional Side Effects Awaited Before/Blocking Real Work)

### D1. `OnboardingConsentStep._continue` awaits analytics/Crashlytics SDK toggles before saving Terms acceptance, blocking onboarding on SDK failure
- Severity: major
- Evidence: `lib/features/onboarding/presentation/onboarding_consent_step.dart:89-93,107-109`, `lib/features/settings/data/settings_repository.dart:157-206`, `lib/app/telemetry_consent_controller.dart:52-116`, `lib/core/telemetry/firebase_telemetry.dart:68-117`
- Failure: Tapping Continue on Terms and Privacy awaits `repo.updateHelpImproveApp(...)` **before** `setSetupAcceptanceVersion` and `recordPolicyAcceptance()`. When opted IN (`enabled: true`), `updateHelpImproveApp` awaits `_analytics.setAnalyticsCollectionEnabled(enabled: true)` (which calls `setEnabled(false)` then `setEnabled(true)` on Firebase Analytics + Crashlytics) **before** persisting the preference. Even when opted OUT (`enabled: false`), it awaits `setUserIdentifier('')` and `setEnabled(false)` and rethrows `gatewayError` (line 186). If Firebase Analytics/Crashlytics throws (e.g., browser tracker blocker, restricted cookies, or native SDK error), `_continue` catches it and shows **"Could not save your progress."**, permanently blocking the student from completing onboarding even when they declined usage sharing.
- Fix idea: Persist `helpImproveApp`, `setupAcceptanceVersion`, and `policyAcceptedAt` first, and treat runtime SDK `setEnabled`/`setUserIdentifier` failures as non-blocking (re-applied at next startup via `applyPersistedTelemetryConsent`).

### D2. Account deletion and sign-out await `notifications.cancelAll()` before wiping local data or deleting the account
- Severity: major
- Evidence: `lib/app/routes/settings_account_deletion.dart:1-13`, `lib/app/routes/settings_routes_native.dart:350`, `lib/core/sync/local_state_wiper.dart:70-72`, `lib/core/auth/auth_repository.dart:444-452,463-482`, `lib/features/settings/presentation/pages/delete_account_page.dart:64-68`
- Failure:
  - `deleteAccountFromSettings` awaits `cancelNotifications()` (line 7) **before** calling `wipeAnonymousData()` or `deleteNamedAccount()`. If `flutter_local_notifications` `cancelAll()` throws a `PlatformException`, neither local wipe nor server account deletion runs, and the student sees *"We could not complete deletion."*
  - Independently, `SyncLocalStateWiper.wipeAll()` awaits `_notifications?.cancelAll()` (line 71) **before** wiping the local Drift database. During `AuthRepository._signOut()` (line 448), a notification plugin error aborts sign-out before wiping local data or signing out of Firebase. During `AuthRepository._deleteAccount()` (line 478), the server account was **already deleted** at line 476, yet a `cancelAll()` throw aborts the local wipe and Firebase sign-out, leaving deleted-account data on disk and displaying deletion failure.
- Fix idea: Wrap `cancelNotifications()` / `_notifications?.cancelAll()` in best-effort `try/catch` (logging failure) so local wipe, sign-out, and account deletion always proceed.

### D3. `QuizCompletionCoordinator._complete` and `CompleteQuiz` await `_notifications?.onSessionCompleted()` before returning the completed `Attempt`
- Severity: major
- Evidence: `lib/features/quiz/application/quiz_completion_coordinator.dart:115-131`, `lib/features/quiz/domain/use_cases/complete_quiz.dart:44-50`, `lib/features/quiz/presentation/quiz_controller.dart:642-655`, `lib/features/quiz/presentation/quiz_page.dart:1615-1642`
- Failure: After committing the `Attempt` and closing `quiz_sessions.completedAt`, `_complete` awaits `_notifications?.onSessionCompleted()` (`_gateway.cancel(NotificationIds.streakSave)`) before returning `attempt` to `QuizController.next()`. Because `QuizPage._next()` wraps `controller.next()` in `_runWrite`, any exception from the notification plugin prevents transitioning to `QuizComplete` and displays **"Could not save your progress."** on the final question even though the session is already saved.
- Fix idea: Catch and swallow/report errors from `_notifications?.onSessionCompleted()` (and run `unawaited`) so notification cancellation can never fail quiz completion.

### D4. `SettingsActions.updateStudyDays` and `saveReminderTime` await notification rescheduling inside the save call, blocking Onboarding and Settings
- Severity: major
- Evidence: `lib/features/settings/application/settings_providers.dart:128-136,210-217`, `lib/features/onboarding/presentation/onboarding_study_days_step.dart:117-122`, `lib/features/settings/presentation/pages/exam_page.dart:328`
- Failure: `updateStudyDays` persists study days locally and to the server, then awaits `notificationServiceProvider.rescheduleForForeground()` (which performs 4 reads + 4 cancels + OS scheduling). If notification rescheduling throws (e.g., Android exact-alarm or notification channel error), `OnboardingStudyDaysStep._save` catches it, does **not** advance (`widget.onCompleted()` is skipped), and shows **"Could not save your progress."** even though study days were saved. Similarly, `saveReminderTime` awaits `scheduleDailyReminder` before `_ref.invalidate(userSettingsProvider)`.
- Fix idea: Isolate `rescheduleForForeground()` / `scheduleDailyReminder()` in `try/catch` (reporting to telemetry) after invalidating `userSettingsProvider` so saving study days cannot be blocked by local notifications.

### D5. Nine Settings `catch` blocks `await telemetry.recordError(error, stack)` before updating error UI state
- Severity: major
- Evidence: `lib/features/settings/presentation/pages/account_page.dart:134,521,554`, `lib/features/settings/presentation/pages/backup_page.dart:79`, `lib/features/settings/presentation/pages/delete_account_page.dart:67`, `lib/features/settings/presentation/pages/name_page.dart:68,100`, `lib/features/settings/presentation/pages/whats_included_page.dart:200`, `lib/features/settings/presentation/carry_over_prompt.dart:180`
- Failure: Every one of these `catch` blocks executes `await telemetry.recordError(error, stack);` **before** `setState(() => _failed = true)` (or `_errorMessage = ...`). If `recordError` throws (e.g., Crashlytics plugin failure), `setState` is skipped, so the student sees no error message or Retry button, and on `NamePage._typed` (line 68) and `AccountPage._confirmSignOut` (line 554) an uncaught exception escapes.
- Fix idea: Replace `await telemetry.recordError(...)` with `reportFailure(telemetry, ...)` (which uses `try` + `unawaited(...catchError)`) or update UI state first.

### D6. `try { unawaited(telemetry.log(...)); } on Object {}` does not catch async rejections in `QuizController` and `LessonPage` (and unguarded `.log()` calls elsewhere)
- Severity: minor
- Evidence: `lib/features/quiz/presentation/quiz_controller.dart:110-139`, `lib/features/lesson/presentation/lesson_page.dart:965-979`, `lib/app/web_route_shell.dart:95-98`, `lib/features/shell/presentation/app_shell.dart:46-49`, `lib/features/onboarding/presentation/onboarding_page.dart:90-92,157-160`, `lib/features/paywall/application/paywall_controller.dart:28-69`, `lib/features/quiz/domain/use_cases/start_today_session.dart:150-155`, `lib/features/mock_exam/application/mock_session_controller.dart:57,335,358`
- Failure: `QuizController._logStudyLoop` and `LessonPage._logLesson` wrap `unawaited(telemetry.log(...))` in `try/catch` assuming it absorbs errors, while the other call sites fire-and-forget `.log(...)` without `.ignore()` or `.catchError(...)`. Because `FirebaseTelemetry.log` is `async`, any `ArgumentError` from `assertPropertiesAllowed` (e.g., if `trigger` in `PaywallController.logPaywallShown` or a custom `exam_id` violates `^[a-zA-Z0-9_-]{1,64}$`) or Analytics SDK throw becomes an unhandled async error reaching `PlatformDispatcher.onError` / `ClientReporter` (unlike `ScreenViewTracker`, which calls `.ignore()`). Does not directly block the UI write, so severity is minor, but undermines the stated guard.
- Fix idea: Attach `.ignore()` (or make `Telemetry.log` non-throwing at the `GatedTelemetry`/`FirebaseTelemetry` boundary) on all fire-and-forget analytics calls.

STAGE-DONE
