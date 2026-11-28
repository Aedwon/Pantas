# Quiz answer save audit

Policy origin/main ecfeaf0d1. Application 67ed1b52b. Content trees are the supplied production snapshot d97de9415 and this worktree's content/. Static source trace and local bank scan.

### A session write can fail after the review was already committed
- Severity: major
- Evidence: lib/features/quiz/domain/use_cases/submit_answer.dart:70-128, lib/features/quiz/data/repos/quiz_session_repository.dart:132-185, lib/features/quiz/presentation/quiz_controller.dart:572-625, lib/features/quiz/presentation/quiz_page.dart:1631, lib/core/error/state_patterns.dart:37.
- Failure: Missing stored session row or an answer out of stored order -> the Check action reports “Could not save your progress.” Review state and possibly the review log have already been written. Retrying can schedule the same question again and append another review log. A question missing from a present row instead returns normally without persisting the session answer. A repeated question ID resolves to its first position and can likewise return without saving the later occurrence.
- Fix idea: Commit review state, review log and the session outcome together using a stable per-position operation key.

### One out-of-catalog answer can permanently exclude a completed quiz from server progress
- Severity: major
- Evidence: functions/src/ingestSession.ts:37-53,59-104, functions/src/_answers.ts:27-46, lib/features/home/data/study_observations.dart:126-169,188-225, firestore.rules:167-169.
- Failure: A locally answerable item absent from the server's named exam, an invalid answer ID, an oversized chosen ID, or an invalid response time/version -> the device can show the result, but ingest rejects the whole session and the client leaves a permanent rejected receipt. Server reviews, totals and roadmap omit that session. A custom exam refreshes corpus membership, drops only its unknown answers, and acknowledges even when none remain. These Admin writes are independent of direct client Firestore rules.
- Fix idea: Validate bank and payloads against the serving catalog before rollout and give rejected observations a recoverable status.

### A web Mock answer can be ignored or block every save carrying it
- Severity: major
- Evidence: lib/features/mock_exam/presentation/pages/server_mock_route.dart:474-485,607-618, lib/features/mock_exam/application/server_mock_session.dart:282-317,475-509,630-648, functions/src/mock.ts:362-417,425-467, functions/src/mockAnswers.ts:7-16.
- Failure: Unavailable choice or empty/overlong choice ID -> the tap is ignored. A client-accepted answer with an ingest-invalid question ID or timestamp -> the server rejects the batch containing it and the web Mock shows “Could not save your progress.” Since saving carries a snapshot of answers, later taps can repeat the rejection. A choice must also belong to a pinned, distinct question and a writable part to survive the server save.
- Fix idea: Validate every pinned question and its wire IDs before starting the Mock, and surface a specific error for an unusable question.

### The web answer reveal can precede durable IndexedDB storage
- Severity: major
- Evidence: lib/core/storage/data/durable_writes.dart:5-26, lib/core/storage/data/database_opener_web.dart:49-92, lib/features/quiz/presentation/quiz_controller.dart:591-612.
- Failure: A student checks an answer and immediately reloads/closes the tab before the scheduled 50 ms flush, or the flush fails -> an answer can appear saved and then disappear on resume in IndexedDB storage. The answer check does not await this flush and the background flush suppresses errors.
- Fix idea: Await the durability barrier before acknowledging an answer on IndexedDB.

### A review-log ID collision fails Check after rescheduling the question
- Severity: major
- Evidence: lib/features/quiz/domain/use_cases/submit_answer.dart:70-105, lib/core/storage/data/repos/review_log_repository.dart:24-46, lib/core/storage/data/tables/review_logs_table.dart:33-34.
- Failure: The same question with the same clock microsecond, for example with two concurrent submissions sharing the time -> append-only primary key collision. The second call already upserted review state, fails before session persistence, and can show “Could not save your progress.”
- Fix idea: Use an operation ID stable across retries and store the review and outcome in one transaction.

### A single malformed server review aborts the session transaction
- Severity: major
- Evidence: functions/src/serverReviews.ts:9-31, functions/src/ingestSession.ts:91-104, functions/src/mockAnswers.ts:26-36, lib/features/home/data/study_observations.dart:199-225.
- Failure: A saved server review with a different embedded question ID -> failed-precondition for the whole quiz or Mock submission. Invalid saved JSON can also abort the transaction. Quiz observations record identity failures as permanently rejected, while web Mock reports a submit failure. An otherwise valid review newer than the attempt is intentionally preserved.
- Fix idea: Repair the incompatible review row with an explicit, auditable recovery path.

### An invalid raw question path can strand Pro synchronization
- Severity: major
- Evidence: lib/core/sync/engine/local_sync_mutation_recorder.dart:64-151, lib/core/sync/engine/push_pipeline.dart:64-115, lib/core/sync/firestore/firebase_firestore_gateway.dart:170-187, firestore.rules:91-128,240-319.
- Failure: A question ID unusable as a Firestore document segment, or a generated review-log ID that exceeds the document-ID byte limit -> its local save can succeed, but raw path interpolation fails during Pro sync. A SyncGatewayException leaves the row queued and ends the drain after the current batch. An unexpected local/path exception can abort the drain earlier. Account or generation rejection causes the same cloud-only split.
- Fix idea: Define a safe canonical document ID for each row independent of the payload ID and isolate permanently invalid rows from the drain.

### Exam-tag changes can reject attempts backed by the other snapshot
- Severity: major
- Evidence: functions/src/ingestSession.ts:55-89, functions/src/_examContentBuild.ts:63-87, lib/features/home/data/study_observations.dart:199-225. The full ID and source paths are in the four cross-snapshot rule rows below.
- Failure: With main-snapshot membership on the device and the supplied prod membership on the server, 1,287 question IDs have at least one named exam membership missing on prod (ACET 364, DLSU-CET 1,067, USTET 745, UPCAT 280). All these IDs exist somewhere in the prod corpus. The reverse comparison affects 1,886 prod IDs, including 1,264 entirely absent from main. This is a conditional mismatch check. It does not establish which snapshot a reporting device used. Same-snapshot membership passes for every source question.
- Fix idea: Keep ingestion compatible with still-supported catalog revisions and verify exam memberships during content rollout.

### Production has short passage pools under the legacy importer rule
- Severity: minor
- Evidence: tools/import_questions/converter.dart:257-284, functions/src/contentUpload.ts:82-109, build/audit/codex-bank-passage-pool-size.txt. For example, q-comprehension-skills-authors-purpose-tone-pov-0021 in build/audit/prodtree/content/questions/reading-comprehension/comprehension-skills/authors-purpose-tone-pov.yaml.
- Failure: 29 prod questions use a same-file passage with fewer than four questions. The legacy passage converter would refuse them. The current upload packages the referenced passage without enforcing this count and answer saving has no passage-size guard.
- Fix idea: Align the legacy converter rule with the supported passage pools if that importer is still used.

### A missing correct choice can prevent the question from rendering
- Severity: major
- Evidence: lib/core/storage/domain/question.dart:58-61, lib/features/quiz/presentation/quiz_page.dart:547-554, lib/features/quiz/domain/use_cases/submit_answer.dart:47-57, lib/core/content/remote/question_set_mapper.dart:75-99, lib/core/content/remote/content_mirror.dart:607-621.
- Failure: Zero correct choices -> the renderer can throw before Check. If the question reaches SubmitAnswer, that same lookup throws before any write and the Check wrapper shows “Could not save your progress.” Multiple correct choices use the first in displayed order in regular quiz grading. Seven choices can fail during hydration because the readers index a six-element label array. Both banks have zero violations.
- Fix idea: Enforce two through six choices and exactly one correct choice before publishing or hydrating a set.

### Passage regrouping can block the second answer in a quiz
- Severity: major
- Evidence: lib/features/quiz/domain/quiz_session.dart:57-69, lib/core/storage/domain/passage_set_filler.dart:48-71, lib/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart:77-97, lib/features/quiz/domain/use_cases/start_today_session.dart:130-146, lib/features/quiz/domain/use_cases/start_drill.dart:75-92, lib/features/quiz/domain/use_cases/start_retake.dart:81-94, lib/features/quiz/domain/use_cases/restart_session.dart:31-51, lib/features/quiz/data/repos/quiz_session_repository.dart:146-168.
- Failure: A selector returns [passage A item 1, other item, passage A item 2] -> the screen groups both passage A items together, but these start paths store the pre-grouped IDs. The first answer saves. Check on passage A item 2 commits its review, then fails the session order check and shows “Could not save your progress.” The lesson picker shuffles individual questions so a split passage can occur. Quick quiz and Practice already persist the final session order. Today, Drill, Retake and Restart are exposed when their input order changes under grouping.
- Fix idea: Persist the session's final question sequence from every entry point.

### A first-seen question can report a failure after its answer is already stored
- Severity: major
- Evidence: lib/features/quiz/domain/use_cases/submit_answer.dart:70-128, lib/features/quiz/data/repos/new_card_intro_repository.dart:23-57, lib/features/quiz/data/repos/quiz_session_repository.dart:148-153, lib/features/quiz/presentation/quiz_page.dart:1615-1631.
- Failure: Local daily-counter write failure after a first review -> “Could not save your progress” despite a stored answer. Retrying sees an existing review, so it can append another log and never retries the failed counter increment. Existing questions bypass this branch.
- Fix idea: Make the first-introduction count part of the same idempotent answer transaction.

### Reviews can fail at Finish after all questions were answered on screen
- Severity: major
- Evidence: lib/features/quiz/data/repos/review_batch_repository.dart:387-415,494-506,573-595, lib/features/quiz/data/repos/quiz_session_repository.dart:252-279, lib/features/quiz/application/quiz_completion_coordinator.dart:68-123, lib/features/quiz/presentation/quiz_page.dart:1633-1642.
- Failure: A missing, retagged or version-changed item discovered during batch hydration is reconciled, or the chunk becomes unavailable if no usable items remain. A stale in-memory session differing from the stored chunk or one stored outcome at terminal verification -> Finish reports “Could not save your progress” and rolls back the completed Attempt. This is distinct from Check.
- Fix idea: Reconcile the visible Reviews session against its stored chunk before finishing and preserve the already-answered prefix.

### Native Mock can lose an answer across content changes while still showing results
- Severity: major
- Evidence: lib/features/mock_exam/application/mock_session_controller.dart:271-278, lib/features/mock_exam/domain/use_cases/compute_results.dart:30-55, lib/features/mock_exam/application/mock_answer_recorder.dart:93-109, lib/features/mock_exam/presentation/pages/mock_start_route.dart:511-545,657-689.
- Failure: Native Mock stores the selected index under the question ID. A removed question is excluded from scoring and review. If its choices change before scoring, the index can grade a different choice or be skipped in review when out of range. A zero-correct question grades against index -1 and can throw in the separate review conversion. The saved Mock still shows results when review conversion fails. A local progress write failure shows “Could not save your mock progress.”
- Fix idea: Pin the choice identity and grading version with each native Mock answer.

### A missing passage blocks Check before the save path starts
- Severity: major
- Evidence: lib/features/quiz/presentation/quiz_page.dart:165-190, lib/features/quiz/presentation/quiz_controller.dart:541-578, functions/src/contentUpload.ts:96-109, lib/core/content/remote/content_mirror.dart:631-644.
- Failure: An item names a passage unavailable in the local reader -> its screen stays on a skeleton while loading, then shows the quiz load error with retry. It never marks the item ready, so Check cannot run. Both source trees have all referenced same-file passages. Runtime cache or installation loss remains possible.
- Fix idea: Update passage records and their referencing questions atomically and recover a missing passage from its source set.

### An all-due Reviews sitting can exceed the server answer limit
- Severity: major
- Evidence: lib/features/quiz/domain/models/review_batch.dart:63-87, lib/features/home/application/today_questions.dart:192-224, functions/src/_answers.ts:4,27-29, lib/features/home/data/study_observations.dart:199-224.
- Failure: If the All Due option selects 301 or more reviews in one sitting, the local completion can succeed and its server observation is permanently rejected. Each eligible item may sync through Pro separately, but server study totals and scheduling miss the whole sitting. The bank can supply more than 300 items in multiple exams. The threshold depends on the student's due state.
- Fix idea: Bound a submitted sitting to the ingest limit or send idempotent bounded chunks.

### Five-question Reviews can skip a whole passage group
- Severity: minor
- Evidence: lib/features/quiz/domain/models/review_batch.dart:50-87, lib/features/home/application/today_questions.dart:213-224.
- Failure: When six or more questions from one passage are due together, selecting a five-question sitting excludes the entire group. Other groups can still start. This is an explicit selection rule, before Check.
- Fix idea: Tell the student why the passage group was deferred and provide an eligible session size.

### Content refresh can leave obsolete exam memberships on the device
- Severity: major
- Evidence: lib/core/content/remote/content_mirror.dart:323-348,484-504,625-628,645-675, lib/core/storage/data/repos/content_repository.dart:148-166, functions/src/ingestSession.ts:86-89, build/audit/codex-bank-named-main-missing-prod.txt.
- Failure: A question stays in the corpus but loses an exam tag -> the catalog and set mirror paths insert current links and leave old links in place. A device with an old link can still offer that question for the removed exam, then the server rejects the completed session. The 1,287-ID main-to-prod membership difference gives concrete input cases, conditional on the device having held the old links.
- Fix idea: Replace exam links with the authoritative membership during a versioned mirror update.

### Scan found actual passage groups susceptible to order mismatch
- Severity: major
- Evidence: lib/features/quiz/domain/picker/drill_picker.dart:13-32, lib/features/quiz/domain/picker/inline_lesson_picker.dart:14-36, build/audit/codex-bank-drill-regroup-candidate.txt, build/audit/codex-bank-lesson-regroup-candidate.txt.
- Failure: The scan found 286 prod and 260 main passage-linked IDs whose topic pool allows a sibling and intervening question in shuffled Drill order. Main also has 260 candidates in same-lesson pools with room for three picks. Prod has zero in its same-lesson pools. These are exposure counts, since the failure depends on session order. For example, main can arrange q-comprehension-skills-authors-purpose-tone-pov-0016, rc-cs-ap-0001, q-comprehension-skills-authors-purpose-tone-pov-0017 before regrouping.
- Fix idea: Add an answer-write regression using that order and the final persisted session sequence.

### Seven shared IDs change the correct choice under the same version
- Severity: major
- Evidence: lib/core/content/remote/content_mirror.dart:579-619, lib/core/storage/domain/choice_order.dart:18-26, lib/features/mock_exam/domain/use_cases/compute_results.dart:30-55, build/audit/codex-bank-correct-slot-changed.txt.
- Failure: A native Mock shows one revision then grades from the other -> the stored index can change from right to wrong or wrong to right. For example, q-code-of-conduct-ra-6713-duties-and-prohibited-acts-0018 changes its authored correct slot from first to second. Both revisions hydrate version 1. No shared ID changes its number of choices.
- Fix idea: Store the picked choice ID and pin the grading revision for each native Mock.

### The current mirror already applies passages and questions atomically per set
- Severity: minor
- Evidence: lib/core/content/remote/content_mirror.dart:323-341,631-644.
- Failure: The missing-passage finding applies to a cache/installation gap or unresolved source set. These writes already share a transaction for each set, so splitting those writes was not identified as its cause.
- Fix idea: Recover the missing passage from its set before leaving the student on retry.

### Entry-point qualifications for passage ordering
- Severity: minor
- Evidence: lib/app/routes/quiz_routes.dart:234-295, lib/features/quiz/application/quiz_providers.dart:333-373, lib/features/roadmap/domain/sitting_planner.dart:127-144, lib/features/quiz/domain/picker/today_topic_picker.dart:69-77, lib/features/quiz/domain/picker/today_interleaved_picker.dart:19-42.
- Failure: The route table exposes Retake, Today and in-lesson inline sessions. The old Drill controller and page mode remain in source with no current route constructing that mode. The roadmap Today selector already groups ordinary passages, which protects those orders. The alternate interleaved picker can concatenate draws with a later sibling in a fallback draw. Retake preserves mistake order and can put another question between siblings.
- Fix idea: Have every caller persist the final order even when its current selector usually returns a grouped sequence.

### A late web Mock save can silently miss a closed part
- Severity: major
- Evidence: lib/features/mock_exam/presentation/pages/server_mock_route.dart:607-618, lib/features/mock_exam/application/server_mock_session.dart:282-317,492-509, functions/src/mock.ts:388-403, functions/src/_mockParts.ts:139-150.
- Failure: A valid tap arrives shortly before a timed part ends. The client displays the selection and sends it immediately near the boundary, but the server settles its clock first and ignores input for the part if it has already closed. The request can succeed without the answer being in the saved paper. A missing hydrated question can also make the tap return before it is queued.
- Fix idea: Return and surface an explicit per-answer acknowledgment for taps that miss a part boundary.

### An invalid attempt JSON can hold up observation delivery
- Severity: major
- Evidence: lib/core/storage/data/repos/attempts_repository.dart:411-424, lib/features/home/data/study_observations.dart:126-169, lib/core/sync/mapping/attempt_mapper.dart:33-43, firestore.rules:240-247.
- Failure: A corrupt stored attempt with invalid JSON or one mistyped answer item -> hydration throws before the per-observation error guard. That pass stops before later attempts and lesson reads. The stored quiz answer remains local and the lifecycle logs the error. Direct Pro rules restrict the attempt field names but do not inspect nested answers in itemsJson.
- Fix idea: Isolate payload decoding per attempt and retain a recoverable error record for unreadable inputs.

## Part A constraint trace

| Layer | Constraint and failure surface |
| --- | --- |
| Content, before selection | Set IDs are derived as `qs-<relative path with __ separators>`. Content lookup accepts 1–20 strings matching `^[A-Za-z0-9_.-]{1,160}$`, deduplicates IDs and applies request/delivery limits. The question ID lives inside the set rather than in this request. Both readers generate `<questionId>_<a–f>`, displayed labels A–F, and version 1. The importer requires at least two choices, exactly one boolean-true key, nonempty stem/choices/explanation, and wrong-choice rationale. The A–F array sets the practical upper bound of six. Global question IDs and choice IDs are local keys. A missing set or passage, over-six choices, missing correct choice, unpublished figure, inactive item or missing topic/exam/lesson relationship can stop selection or rendering. The inline reader requires exact active exam/topic/lesson membership. Explicit lesson aliases resolve through the first replacement and require a valid acyclic chain. The server exam builder accepts legacy missing derived links but throws on missing explicit links. The custom catalog also validates authored topic/subject/lesson relationships and rejects duplicate question IDs. `functions/src/content.ts:38-43,90-111,158-165`, `functions/src/_examContentBuild.ts:18-40,63-94`, `functions/src/_examContent.ts:174-233`, `lib/core/content/remote/question_set_mapper.dart:21-45,57-115`, `lib/core/content/remote/content_mirror.dart:554-630`, `lib/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart:50-74`, `tools/import_questions/converter.dart:64-129`. |
| Controller | Quick, Practice, Today, Reviews, Retake and the in-lesson button's inline route use the same Check action. Pick requires running, ready, unanswered, not checking, and a choice ID in the item. Check repeats the state guards. Missing/nonmember pick returns silently. Grading compares selected string with the first correct choice ID. No label or choice text is saved. Runtime labels are generated from displayed order. The known telemetry gate also sees the chosen label and session origin. Device response time is wall-clock difference in ms and has no local bounds check. The controller restores the selection and rethrows a Check exception. Page catches it and displays the save error with retry. Finish uses the same wrapper. `lib/features/quiz/presentation/quiz_page.dart:1615-1704`, `lib/features/quiz/presentation/quiz_controller.dart:541-655`, `lib/features/quiz/domain/use_cases/submit_answer.dart:37-81`, `lib/features/quiz/application/quiz_starts.dart:10-18`, `lib/core/error/state_patterns.dart:35-56`. |
| Drift local | Review state upserts globally by question ID, independent of exam. Existing state keeps its version when rescheduled. Local scheduler uses prior state and timing. DB requires nonnull typed columns such as stage, dates, numeric scheduling values, rating and correctness. No app-level string size or regex constraints appear in the Drift review state, review log, session or Attempt tables. Log insert uses the unique text key `<questionId>-<epoch microseconds>`. Session UUID keys are unique and stored IDs/outcomes are JSON. Answer outcome requires strings for question/chosen/correct IDs and integers for version/time/rating/interval. Repair keeps a matching prefix, recomputes cursor/count, and leaves unreadable question-ID JSON to fail later. Regular resume drops missing items if others remain and refuses mismatched IDs/outcomes. Reviews require unique, nonempty question/session IDs, positive integer versions, matching counts and membership, identical stored outcome ordering, valid owner and batch scope. A new local counter increments after successful review/session saves. SQLite or its browser storage can still reject a write. IndexedDB shares the schema and has the separate flush window above. `lib/core/storage/data/tables/{review_state_local,review_logs,quiz_sessions,attempts_local}_table.dart`, `lib/core/storage/data/repos/review_state_repository.dart:17-44,85-112`, `lib/core/storage/data/repos/review_log_repository.dart:24-46`, `lib/features/quiz/data/repos/quiz_session_repository.dart:132-185,398-483`, `lib/features/quiz/domain/use_cases/resume_session.dart:23-68`, `lib/features/quiz/domain/models/review_batch.dart:38-80,123-195`, `lib/core/storage/data/app_database.dart:94-113`. |
| Completion and delivery | Completed Attempt uses the session UUID, exam, fixed origin, timestamps and item JSON. Its write and closing the session are atomic, and its outbox enqueue shares the transaction. Review states/logs have their own recorded transactions. Stale/empty/quitted session or review-batch mismatch rejects Finish. Streak and notification awaits after terminal commit can surface as Finish failure. Ordinary observations deliver completed nonempty attempts in the allowed origins. They send chosen ID, correctness, response time and version, omit per-answer timestamp, and send exam/account separately. Ordinary and custom receipt keys prefix the UUID, but the wire session ID is the original UUID. Server failures are outside Check. Background delivery logs errors. Permanent codes leave a rejected receipt, temporary errors are retried, and rate exhaustion stops the pass. `lib/features/quiz/application/quiz_completion_coordinator.dart:63-131`, `lib/core/storage/data/repos/attempts_repository.dart:23-55`, `lib/features/home/data/study_writes.dart:7-30`, `lib/features/home/data/study_observations.dart:78-107,126-230`, `lib/features/home/application/study_delivery.dart:156-187`. |
| Ordinary ingest and server reviews | App Check configuration, authenticated active account, and expected UID for attributed payload. Exam must be listed or a lowercase custom v4 UUID with the `exam_custom_` prefix. Origin enum is `today_topic,today_interleaved,new_questions,drill,flagged,retake,inline,assessment`. Session ID matches `^[A-Za-z0-9_-]{8,64}$`. Batch is 1–300 object rows. Question ID matches the content ASCII pattern and is at most 128 UTF-16 units. Chosen is required as null or string up to 130, with no nonempty, character or bank-choice membership check. Correct must be boolean. Optional responseMs must be a safe integer in 0–86,400,000. Optional questionVersion must be a safe integer at least 1. Times are finite numbers since UTC 2020-01-01 through server now plus one day and are truncated. Legacy and Mock require answeredAt, ordinary attributed may omit it. Finished must be at or after started. Duration is finite nonnegative up to one day, or up to attributed wall time when equal to that longer wall time. Rate cap is 200 per account per rolling day. Named sessions require every ID in the exam. Custom drops unknown IDs after a fresh corpus retry. Attributed session-ID replay must match exam/origin/times and ordered normalized answers. No distinct-question rule in ordinary ingest. Null chosen skips scheduling. The server review row uses the URI-encoded question ID and must decode with matching embedded identity and valid typed scheduler state. Storage is atomic with totals and observations. `functions/src/_answers.ts:4-51`, `functions/src/ingestSession.ts:23-120`, `functions/src/_customTrack.ts:9-14`, `functions/src/studyObservations.ts:10-14`, `functions/src/serverReviews.ts:7-33`, `server_dart/review_codec.dart:6-33`. |
| Lesson/topic fields | Neither topic nor lesson ID is sent in quiz answer ingest. They affect content selection, session metadata and server membership/roadmap metadata. A separate read observation requires lesson ID nonempty, at most 128 UTF-16 units, no slash, existing lesson document and valid readAt. It accepts retired documents, keeps the earliest read, and has a 600/hour cap. Active lesson/alias/content fetch IDs also face the 160-character content fetch pattern when used as document identity. `lib/features/home/data/study_writes.dart:14-29`, `functions/src/studyObservations.ts:17-39`, `functions/src/_examContentBuild.ts:17-49,83-94`. |
| Native Mock | Answers are stored as position and elapsed seconds in an ID-keyed JSON map. Paper uses unique sampled IDs by design. No `SubmitAnswer` or `checkAnswers` on native Check/tap. Results reuse current hydrated questions. Review conversion skips missing or out-of-range choices, needs the first correct choice, and writes the Attempt plus review states atomically without individual review logs. Its Attempt origin `mock` does not enter ordinary ingest. The Mock row syncs via direct Pro Firestore. `lib/features/mock_exam/application/mock_session_controller.dart:271-278`, `lib/features/mock_exam/presentation/pages/mock_start_route.dart:505-545,657-689,948-951`, `lib/features/mock_exam/application/mock_answer_recorder.dart:81-155`, `lib/features/home/data/study_observations.dart:148-159`, `firestore.rules:297-308`. |
| Web Mock | Paper decode requires nonempty sections and question strings, globally distinct question IDs of at most 128, at most 300 items and a 10–40 ASCII-alphanumeric mock ID. Saved answers must reference paper IDs once, have nullable string chosen at most 130, boolean correct and integral answeredAt. Tap rejects empty/overlong choice IDs, unavailable position, blocked state or nonreachable question. API repeats length/count checks. Server additionally uses `checkAnswers`, requires pinned distinct question IDs and forbids null chosen with correct true. It accepts the sent nonnull choice and correctness without looking up the choice. Save uses current open paper, named account and configured App Check, up to 600/hour. Submit uses folded paper snapshot including skipped items, reasons student or strict-exit (empty array allowed for strict only), duration <= one day, and 30/hour. Timed parts only merge the running part. Session record ID is internal `mock:<mockId>`. `lib/features/mock_exam/domain/server_mock_paper.dart:110-218`, `lib/features/mock_exam/data/server_mock_api.dart:252-297`, `functions/src/mock.ts:31-33,336-350,362-488`, `functions/src/mockAnswers.ts:7-36`. |
| Pro journal and outbox | Each row and its local mutation record commit together. Journal keyed by collection + row ID. Outbox uniquely keyed by owner/generation/collection/row ID. Promotion requires matching scope and known-absent with no base timestamp or known-version with a timestamp. Pending inputs require nonempty UID/generation/mutation ID. The 500-row drain is per-row, with payload loading, causal compare and server acknowledgment. A stale snapshot can win the row conflict without a Check error. Session cursor rows never upload through this path. Sync callables activate a named Pro generation with App Check, generation ID 1–128 without slash, expected ID or null, staging and expected-active checks, 30/hour. They carry no individual answer, topic, lesson, or review ID. `lib/core/sync/engine/local_sync_mutation_recorder.dart:64-151`, `lib/core/sync/engine/sync_outbox_promoter.dart:24-74,127-141`, `lib/core/sync/engine/pending_queue.dart:327-368`, `lib/core/sync/engine/push_pipeline.dart:49-115`, `lib/core/sync/firestore/firebase_firestore_gateway.dart:232-276`, `functions/src/activateSyncGeneration.ts:20-130`. |
| Firestore | Callable Admin writes under `users/{uid}/server` bypass client rules. Direct client traffic cannot read/write that subtree. Pro sync uses raw document-segment row IDs, constrained by Firestore (nonempty, UTF-8, up to 1,500 bytes, no slash, `.`, `..` or reserved `__.*__`) and its ordinary document/request limits. Relevant field allowlists cover attempts, review states/logs, flags, lesson reads and Mock rows. They enforce active named Pro owner, active/staging nondeleting generation, server timestamp updatedAt, device and mutation IDs as nonempty strings <=128, schemaVersion 1, bool deleted, and disallow direct delete. Payload keys are allowed but not required with separate value checks in these rows. Restore mappers impose typed strings, numbers, booleans, dates, and attempt JSON decoding at use. A malformed payload accepted by rules can therefore fail on restore. Normal validated max-size answer arrays leave ample space under the Firestore 1 MiB document cap. `firestore.rules:7-38,89-128,167-169,240-319`, `lib/core/sync/mapping/{fsrs_card,review_log,attempt,mock_attempt}_mapper.dart`, `lib/core/sync/engine/pull_pipeline.dart:155-195,215-294`. |

## Part B full-bank results

Every question row in every recursive questions/*.yaml file was parsed with Ruby YAML. Counts use unique source rows. A question tagged for several exams contributes to each relevant exam. Choice IDs, labels and version were calculated the way the app creates them. Topic slugs were checked against the outline from each local Git revision. Lesson frontmatter, first-replacement aliases, same-file passage definitions and the corresponding named/custom membership were checked against each snapshot. The two retained historical IDs outside each content tree were checked for collisions with the YAML IDs.

The known analytics question-ID limit is excluded as directed. Runtime state checks such as clock bounds, UUID or review-log collisions, stale journals, and paid-account eligibility cannot be inferred from YAML. The All Due eligibility list measures bank capacity only. Passage regroup lists fit the structural input condition and are not a count of failed attempts. Counts are scoped to the supplied snapshots.

| Exam | Prod questions | Main questions |
| --- | ---: | ---: |
| upcat | 3228 | 2543 |
| acet | 1978 | 1700 |
| dlsucet | 2236 | 2543 |
| ustet | 2750 | 2723 |
| pupcet | 1074 | 880 |
| dost-sei | 2210 | 1683 |
| sm-foundation | 0 | 0 |
| pshs-nce | 101 | 0 |
| cse-pro | 1751 | 1060 |
| cse-sub | 1523 | 880 |
| napolcom | 0 | 0 |
| afpsat | 0 | 0 |
| pma | 0 | 0 |
| pnpa | 0 | 0 |
| pmma | 0 | 0 |
| maap | 0 | 0 |
| let | 0 | 0 |
| pnle | 0 | 0 |
| Unique question rows | 4427 | 3163 |

Prod has 189 YAML files, four choices on 4,332 questions and five on 95. Main has 158 YAML files, four choices on 3,150 questions and five on 13. Longest question IDs are 85 and 67 UTF-16 units respectively. Longest generated choice IDs are 87 and 69. Both banks have zero rows flagged inactive or pending a figure under the serving conditions.

Each row below gives counts by tree and exam. An unlisted exam has zero qualifying questions under that rule. ID files include the source path, YAML question position, and detail where applicable.

| Rule | Prod, unique rows and per-exam counts | Main, unique rows and per-exam counts |
| --- | --- | --- |
| [passage-pool-size](codex-bank-passage-pool-size.txt) | 29 (acet 29, cse-pro 29, cse-sub 29, dlsucet 29, upcat 29, ustet 29) | 0 |
| [lesson-regroup-candidate](codex-bank-lesson-regroup-candidate.txt) | 0 | 260 ((custom corpus) 260, acet 260, dlsucet 260, upcat 260, ustet 260) |
| [drill-regroup-candidate](codex-bank-drill-regroup-candidate.txt) | 286 ((custom corpus) 286, acet 226, cse-pro 186, cse-sub 186, dlsucet 226, upcat 286, ustet 266) | 260 ((custom corpus) 260, acet 260, dlsucet 260, upcat 260, ustet 260) |
| [all-due-over-300-capacity](codex-bank-all-due-over-300-capacity.txt) | 4427 ((custom corpus) 4427, acet 1978, cse-pro 1751, cse-sub 1523, dlsucet 2236, dost-sei 2210, pupcet 1074, upcat 3228, ustet 2750) | 3163 ((custom corpus) 3163, acet 1700, cse-pro 1060, cse-sub 880, dlsucet 2543, dost-sei 1683, pupcet 880, upcat 2543, ustet 2723) |
| [correct-slot-changed](codex-bank-correct-slot-changed.txt) | 7 (acet 1, cse-pro 7, cse-sub 7, dlsucet 1, dost-sei 1, pupcet 1, upcat 1, ustet 1) | 7 (acet 2, cse-pro 7, cse-sub 7, dlsucet 2, dost-sei 1, pupcet 1, upcat 2, ustet 2) |
| [named-main-missing-prod](codex-bank-named-main-missing-prod.txt) | 0 | 1287 (acet 364, dlsucet 1067, upcat 280, ustet 745) |
| [named-prod-missing-main](codex-bank-named-prod-missing-main.txt) | 1886 (acet 642, cse-pro 691, cse-sub 643, dlsucet 760, dost-sei 527, pshs-nce 101, pupcet 194, upcat 965, ustet 772) | 0 |
| [custom-prod-missing-main](codex-bank-custom-prod-missing-main.txt) | 1264 (acet 380, cse-pro 531, cse-sub 483, dlsucet 540, dost-sei 527, pshs-nce 101, pupcet 194, upcat 785, ustet 692) | 0 |

Each of these 51 rules has **zero failures in every exam in both trees**.

`id-shape`, `id-pattern`, `id-length`, `duplicate-id`, `choice-shape`, `choice-count-min`, `choice-count-max`, `correct-count`, `correct-type`, `choice-id-length`, `choice-id-duplicate`, `label-shape`, `version`, `ingest-exam`, `exam-meta`, `duplicate-exam`, `topic-meta`, `subtopic-meta`, `subject-meta`, `outline-topic`, `topic-id-format`, `lesson-shape`, `lesson-explicit-missing`, `lesson-derived-missing`, `lesson-resolved-missing`, `lesson-topic`, `lesson-content-id`, `lesson-read-id`, `lesson-alias-invalid`, `passage-shape`, `passage-missing`, `passage-duplicate`, `passage-global-duplicate`, `review-passage-over-5`, `review-passage-over-10`, `review-passage-over-20`, `choice-count-changed`, `figure-pending`, `inactive`, `mirror-server-inactive`, `figure-spec-shape`, `question-display-shape`, `importer-choice-text`, `importer-rationale`, `set-id-format`, `fsrs-doc-id`, `review-log-doc-id`, `keypoint-shape`, `keypoint-bounds`, `custom-main-missing-prod`, `historical-id-collision`.

Rule names use the source constraints in Part A. `passage-pool-size` is the legacy 4–8 rule. `review-passage-over-5/10/20` are the maximum possible due-sibling groups per exam. `correct-slot-changed` compares authored choice ordinals for shared IDs. `named-*-missing-*` compares active exam membership and `custom-*-missing-*` compares active global membership.

## Verification

The local checks matched 1,461 prod and 317 main question, lesson and exam-catalog source files byte-for-byte to their specified Git revisions. The Ruby scan parsed 7,590 YAML question rows across both trees. An independent check reconciled the counts, exam memberships and paths in all eight failing-ID or exposure lists with the report. A Ruby check using the cited main lesson items reproduced the differing displayed and stored second IDs. Device behavior and server outcomes in Part A are conclusions from static code paths.
