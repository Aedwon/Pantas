# Quiz Engine and Modes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the random quick quiz with a unified quiz engine that powers Today's Session, Drill, Retake Mistakes, and Inline Lesson quiz modes while preserving FSRS scheduling and Spec 3 user-data sync semantics.

**Architecture:** Quiz selection is split into pure selectors and picker strategies under `lib/features/quiz/domain/`, while side-effecting use cases own Drift session persistence, attempt logging, FSRS updates, dirty flags, and streak evaluation. `app.db` stores durable user attempts plus local-only active quiz sessions and new-card counters; `content.db` remains regenerable content and gains additive `subtopicId` metadata for question/lesson filtering.

**Tech Stack:** Flutter, Riverpod, Drift, Freezed, existing FSRS scheduler, in-memory Drift tests, widget tests with provider overrides.

**Target spec:** `docs/superpowers/specs/2026-05-17-quiz-engine-and-modes-design.md`

**Date:** 2026-05-18

**Size:** L

---

## Open Questions

- The Spec 4 design doc status is still "Draft, pending user review" while this request asks for implementation. Tentative choice: treat the user's execution request as approval for the implementation plan and keep any product-level unresolved items out of code.
- Existing content models only have `topicId`; Sanity `subtopic` documents and generated `assets/seed/content.db` may not exist yet. Tentative choice: add nullable `subtopicId` columns and repositories now, with Drill/Inline gracefully falling back to topic-scoped content when fixtures lack subtopic tags.
- Streak storage already exists locally, but Spec 4 says streak is derived locally from `quiz_attempts` and not synced. Tentative choice: keep using local streak storage as a derived/cache surface and never add it to the Spec 3 sync registry.

## External Blockers

- **Skippable: live Sanity schema update.** Add `subtopic` reference fields to Sanity `question` and `lesson` doctypes, and add the `subtopic` doctype with parent topic metadata.
- **Skippable: live Sanity content availability.** Tag real questions and lessons with subtopics; incomplete tagging will show only topic-level or General buckets locally.
- **Skippable: regenerated content seed.** Regenerate `assets/seed/content.db` from live Sanity after the schema change and replace the parked/generated seed artifact.
- **Skippable: Sanity CDN validation.** Verify the app can fetch updated subtopic-tagged content from the configured public dataset.
- **Skippable: Firebase live sync validation.** Validate that quiz attempts with the new `origin` field and FSRS dirty rows push/pull correctly against real Firestore.
- **Skippable: emulator/CI credentials.** Add Firebase emulator or service-account credentials if CI is expected to run rules/functions integration tests against a live emulator.
- **Skippable: production manual verification.** On a real Android device, complete Today's Session, Drill, Retake, and Inline sessions; background/relaunch mid-session; sign in on a named account; confirm attempts restore after reinstall.
- **Skippable: release-store/manual QA.** Verify the Android-only soft-launch build on target hardware after the live content/Firebase projects are available.

## File Structure

- Modify `lib/core/content/` tables, parsers, repos, and tests to carry nullable `subtopicId` on questions and lessons without syncing content.
- Modify `lib/core/storage/data/` tables, migrations, repositories, mappers, and tests for `quiz_sessions`, `daily_new_card_intro`, attempt `origin`, and synced preference keys.
- Create `lib/features/quiz/domain/models/` for `quiz_mode.dart`, `session_origin.dart`, `derived_rating.dart`, `quiz_preferences.dart`, and expand `quiz_session.dart`.
- Create `lib/features/quiz/domain/selectors/` for FSRS due, weakness, new-card, recency, and subtopic filtering.
- Create `lib/features/quiz/domain/picker/` for the `QuestionPicker` interface, `PickContext`, and the five concrete pickers.
- Create/replace `lib/features/quiz/domain/use_cases/` start, submit, resume, quit, and restart use cases.
- Create `lib/features/quiz/data/repos/` for quiz session, attempt-origin helpers, new-card counters, and quiz preferences.
- Update `lib/features/quiz/presentation/`, `lib/app/router.dart`, and lesson screens for the four mode entry points.
- Update sync mapping/import guardrails so only user attempts/FSRS/account preferences sync; `quiz_sessions`, `daily_new_card_intro`, and `content.db` stay local.

## Phase 1: Current Quiz/FSRS/Storage Audit + Route/Provider Inventory

### Step 1.1: Lock the current quiz behavior with characterization tests

**Goal:** Capture the current random quick quiz, submit-answer, attempt-save, and route/provider seams before replacing them.

**Files:**
- Modify: `test/features/quiz/domain/start_quick_quiz_test.dart`
- Modify: `test/features/quiz/domain/submit_answer_test.dart`
- Modify: `test/features/quiz/presentation/quiz_controller_test.dart`
- Modify: `test/app/router_redirect_test.dart`

**Test cases to write first:**
- `start quick quiz can still scope by topic id while migration is in progress`
- `submit answer updates FSRS through ReviewStateRepository and preserves rating semantics`
- `quiz controller still completes an attempt after all questions are answered`
- `quick quiz route continues to resolve until new mode routes are wired`

**Implementation notes:** These are temporary safety tests around existing public seams. Keep assertions behavioral, not tied to class names that will be replaced in later phases.

### Step 1.2: Add a quiz route and provider inventory guardrail

**Goal:** Prevent Spec 4 from accidentally importing live Firebase/Sanity clients directly into picker/domain code.

**Files:**
- Create: `test/tool/quiz_domain_boundary_test.dart`
- Modify: `test/tool/sync_import_boundary_test.dart`

**Test cases to write first:**
- `quiz domain pickers do not import Flutter widgets, Firestore, Firebase Auth, or Dio`
- `quiz session persistence imports app database but not content database`
- `sync registry excludes quiz_sessions and daily_new_card_intro`

**Implementation notes:** Use the existing text-scanning style in `test/tool/*_boundary_test.dart`. This step leaves production code unchanged.

## Phase 2: Additive Content Schema Support for `subTopicId`

### Step 2.1: Add content `subtopicId` storage and parser support

**Goal:** Persist optional subtopic metadata for questions and lessons in regenerable `content.db`.

**Files:**
- Modify: `lib/core/content/tables/content_questions.dart`
- Modify: `lib/core/content/tables/content_lessons.dart`
- Modify: `lib/core/content/content_database.dart`
- Modify: `lib/core/content/sanity/parsers/question_parser.dart`
- Modify: `lib/core/content/sanity/parsers/lesson_parser.dart`
- Modify: `test/fixtures/sanity/content_sample.json`
- Modify: `test/core/content/content_database_test.dart`
- Modify: `test/core/content/sanity/parsers/doctype_parsers_test.dart`

**Test cases to write first:**
- `content database schema includes nullable subtopicId on questions and lessons`
- `question parser reads subtopic reference when present`
- `question parser accepts missing subtopic as null for old seed compatibility`
- `lesson parser reads subtopic reference when present`

**Implementation notes:** Bump only `content.db` schema. Do not add subtopics to `app.db` or Spec 3 sync.

### Step 2.2: Expose subtopic-aware content repository reads

**Goal:** Let Drill and Inline quiz request tagged question pools while keeping topic fallback for untagged fixture data.

**Files:**
- Modify: `lib/core/content/repos/question_repo.dart`
- Modify: `lib/core/content/repos/lesson_repo.dart`
- Modify: `lib/core/content/content.dart`
- Modify: `test/core/content/repos/content_repos_test.dart`

**Test cases to write first:**
- `QuestionRepo.bySubtopic returns active questions for a subtopic`
- `QuestionRepo.bySubtopic excludes inactive questions`
- `LessonRepo.byId exposes nullable subtopicId`
- `QuestionRepo.byTopic still returns untagged and tagged topic questions`

**Implementation notes:** Keep public domain `Question` unchanged unless a field is already needed by tests; use repo-specific query methods for subtopic filtering to avoid broad generated-model churn.

## Phase 3: Review Queue Domain + FSRS Scheduling Integration

### Step 3.1: Add derived rating heuristic in core FSRS

**Goal:** Move MCQ-to-FSRS rating derivation to the core FSRS seam and include next-interval display data.

**Files:**
- Create: `lib/core/fsrs/rating_heuristic.dart`
- Modify: `lib/features/quiz/domain/rating_heuristic.dart`
- Create: `lib/features/quiz/domain/models/derived_rating.dart`
- Modify: `test/core/fsrs/rating_heuristic_test.dart`
- Modify: `test/features/quiz/domain/rating_heuristic_test.dart`

**Test cases to write first:**
- `wrong answers derive Again`
- `correct answers over 25 seconds derive Hard`
- `correct normal pace answers derive Good`
- `correct under 8 seconds derives Easy only for mature cards`
- `exact boundary values preserve the spec table`

**Implementation notes:** Keep a compatibility wrapper in the old quiz path until `SubmitAnswer` is replaced. Compute the display interval from the scheduler output rather than guessing.

### Step 3.2: Add selector primitives

**Goal:** Implement the pure building blocks for due, weakness, new-card, recency, and subtopic filtering.

**Files:**
- Create: `lib/features/quiz/domain/selectors/fsrs_due_selector.dart`
- Create: `lib/features/quiz/domain/selectors/weakness_selector.dart`
- Create: `lib/features/quiz/domain/selectors/new_card_selector.dart`
- Create: `lib/features/quiz/domain/selectors/recency_filter.dart`
- Create: `lib/features/quiz/domain/selectors/subtopic_filter.dart`
- Test: `test/features/quiz/domain/selectors/fsrs_due_selector_test.dart`
- Test: `test/features/quiz/domain/selectors/weakness_selector_test.dart`
- Test: `test/features/quiz/domain/selectors/new_card_selector_test.dart`
- Test: `test/features/quiz/domain/selectors/recency_filter_test.dart`
- Test: `test/features/quiz/domain/selectors/subtopic_filter_test.dart`

**Test cases to write first:**
- `FsrsDueSelector sorts overdue cards by due date then lapses`
- `FsrsDueSelector filters orphaned FSRS rows when question metadata is missing`
- `WeaknessSelector ranks low rolling accuracy subtopics first`
- `NewCardSelector excludes questions with review state and respects cap remaining`
- `RecencyFilter avoids consecutive same-topic questions when possible`
- `SubtopicFilter returns General topic fallback for null subtopicId when requested`

**Implementation notes:** Use small in-memory fixture objects, not Drift, for selector unit tests. Inject randomness with a seeded `Random` where tie-breaking exists.

### Step 3.3: Add review queue summary domain

**Goal:** Compute Today's topic queue rows and mixed-session counts from selector outputs.

**Files:**
- Create: `lib/features/quiz/domain/models/topic_queue_row.dart`
- Create: `lib/features/quiz/domain/use_cases/build_today_queue.dart`
- Test: `test/features/quiz/domain/build_today_queue_test.dart`

**Test cases to write first:**
- `topic queue shows due weakness and new counts per topic`
- `caught up topics remain visible with zero counts`
- `recommended topic is the largest backlog`
- `new-card cap reached reports zero new cards`

**Implementation notes:** This is a pure use case; provider wiring comes in Phase 5.

## Phase 4: Quiz Session Engine and Mode Contracts

### Step 4.1: Add session-origin and mode models

**Goal:** Represent Today's topic, Today's interleaved, Drill, Retake, and Inline modes explicitly in domain objects.

**Files:**
- Create: `lib/features/quiz/domain/models/session_origin.dart`
- Create: `lib/features/quiz/domain/models/quiz_mode.dart`
- Modify: `lib/features/quiz/domain/quiz_session.dart`
- Modify: `test/features/quiz/domain/quiz_session_test.dart`

**Test cases to write first:**
- `QuizSession.start stores origin topic subtopic lesson and ordered questions`
- `today origins are recognized as streak-eligible`
- `drill retake and inline origins are not streak-eligible`
- `record answer advances index and preserves original mode metadata`

**Implementation notes:** Keep the existing `QuizSession.start` compatibility factory until controller migration is complete.

### Step 4.2: Add local quiz session and new-card tables

**Goal:** Persist active sessions and local daily new-card counts in `app.db`.

**Files:**
- Create: `lib/core/storage/data/tables/quiz_sessions_table.dart`
- Create: `lib/core/storage/data/tables/daily_new_card_intro_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Test: `test/core/storage/data/quiz_session_schema_test.dart`

**Test cases to write first:**
- `app database creates quiz_sessions and daily_new_card_intro at schema version 7`
- `quiz_sessions stores ordered questionIdsJson and currentIndex`
- `daily_new_card_intro primary key is user exam day`
- `content database schema does not include quiz session tables`

**Implementation notes:** These tables are local-only and must not be registered in `lib/core/sync/engine/collection_registry.dart`.

### Step 4.3: Add quiz session repository

**Goal:** Support start, resume, auto-save per answer, complete, quit, and restart semantics.

**Files:**
- Create: `lib/features/quiz/data/repos/quiz_session_repository.dart`
- Test: `test/features/quiz/data/quiz_session_repository_test.dart`

**Test cases to write first:**
- `create stores active session with currentIndex zero`
- `recordAnswer advances currentIndex correctCount and lastAnsweredAt`
- `resume returns the newest uncompleted unquit session for a user`
- `complete sets completedAt and preserves question order`
- `quit sets quitAt without deleting answer progress`
- `restart discards the prior active session only after explicit call`

**Implementation notes:** Store question IDs in the session row and hydrate questions through a repository boundary in use cases, not inside the data repository.

### Step 4.4: Add picker interface and five picker contracts

**Goal:** Make all mode-specific selection rules explicit and independently testable.

**Files:**
- Create: `lib/features/quiz/domain/picker/question_picker.dart`
- Create: `lib/features/quiz/domain/picker/pick_context.dart`
- Create: `lib/features/quiz/domain/picker/today_topic_picker.dart`
- Create: `lib/features/quiz/domain/picker/today_interleaved_picker.dart`
- Create: `lib/features/quiz/domain/picker/drill_picker.dart`
- Create: `lib/features/quiz/domain/picker/retake_picker.dart`
- Create: `lib/features/quiz/domain/picker/inline_lesson_picker.dart`
- Test: `test/features/quiz/domain/picker/today_topic_picker_test.dart`
- Test: `test/features/quiz/domain/picker/today_interleaved_picker_test.dart`
- Test: `test/features/quiz/domain/picker/drill_picker_test.dart`
- Test: `test/features/quiz/domain/picker/retake_picker_test.dart`
- Test: `test/features/quiz/domain/picker/inline_lesson_picker_test.dart`

**Test cases to write first:**
- `TodayTopicPicker uses 60 30 10 composition when due cards exist`
- `TodayTopicPicker uses 70 30 weakness/new composition when no due cards exist`
- `TodayInterleavedPicker avoids consecutive same-topic questions when possible`
- `DrillPicker filters to subtopic and avoids recent same-subtopic attempts`
- `RetakePicker returns recent incorrect question ids from the last 30 days`
- `InlineLessonPicker returns at most five questions from the lesson subtopic`

**Implementation notes:** Bucket backfill goes to the next largest available bucket. Pickers return fewer questions than requested when the pool is genuinely small.

## Phase 5: Today's Session Mode

### Step 5.1: Add quiz preference keys and providers

**Goal:** Expose session length, interleaved mode, and new-card cap through synced `account_prefs` defaults.

**Files:**
- Create: `lib/features/quiz/data/repos/quiz_preferences_repository.dart`
- Create: `lib/features/quiz/domain/models/quiz_preferences.dart`
- Modify: `lib/core/sync/mapping/preferences_mapper.dart`
- Modify: `lib/features/quiz/quiz.dart`
- Test: `test/features/quiz/data/quiz_preferences_repository_test.dart`
- Modify: `test/core/sync/mapping/preferences_mapper_test.dart`

**Test cases to write first:**
- `default quiz preferences are length 10 interleaved false newCardCap 10`
- `sessionLength accepts 5 10 20 and all-due sentinel`
- `preferences mapper includes quiz preference keys from account_prefs`
- `device_prefs do not include quiz preference keys`

**Implementation notes:** UI for Settings lands later; add repository/provider seams only.

### Step 5.2: Implement `StartTodaySession`

**Goal:** Start either a per-topic or interleaved Today's Session and persist it for resume.

**Files:**
- Create: `lib/features/quiz/domain/use_cases/start_today_session.dart`
- Modify: `lib/features/quiz/presentation/quiz_controller.dart`
- Test: `test/features/quiz/domain/use_cases/start_today_session_test.dart`
- Modify: `test/features/quiz/presentation/quiz_controller_test.dart`

**Test cases to write first:**
- `per-topic start builds context for selected topic and stores today_topic origin`
- `interleaved start stores today_interleaved origin`
- `empty picker output returns a user-facing no questions failure`
- `quiz nudge applies only when starting today session`

**Implementation notes:** Keep the legacy quick route calling this use case during transition. Current-session length is frozen at start.

### Step 5.3: Add streak evaluator and completion hook

**Goal:** Fire streak credit exactly once per local day when a Today's Session completes.

**Files:**
- Create: `lib/features/quiz/domain/streak/streak_evaluator.dart`
- Modify: `lib/features/quiz/domain/use_cases/submit_answer.dart`
- Modify: `lib/core/storage/data/repos/streak_repository.dart`
- Test: `test/features/quiz/domain/streak/streak_evaluator_test.dart`
- Modify: `test/features/quiz/integration_test.dart`

**Test cases to write first:**
- `today topic completion awards streak once per local day`
- `today interleaved completion awards streak once per local day`
- `drill retake and inline completions do not award streak`
- `missed day consumes an available freeze before resetting`

**Implementation notes:** Do not add streak to sync mappers. Use injected local-day clock for timezone and midnight tests.

### Step 5.4: Build Today's Session quiz tab surface

**Goal:** Replace the single quick quiz card with resume, topic queue, mixed session, Retake, and Drill CTAs.

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Create: `lib/features/quiz/presentation/today_topic_queue.dart`
- Create: `lib/features/quiz/presentation/retake_mistakes_card.dart`
- Modify: `test/features/quiz/presentation/quiz_tab_home_test.dart`
- Modify: `test/features/quiz/presentation/quiz_tab_nudge_test.dart`

**Test cases to write first:**
- `resume card preempts topic queue when an active session exists`
- `per-topic mode renders due weakness new counts`
- `interleaved mode renders mixed-session start card`
- `Retake Mistakes and Drill a topic CTAs render under Other practice`
- `study-lessons-first nudge appears only for Today start`

**Implementation notes:** Keep presentation dense and utilitarian; do not add paywall UI or progress dashboard summaries.

## Phase 6: Drill Mode and Deep Links

### Step 6.1: Implement `StartDrill`

**Goal:** Start subtopic-scoped practice from user-selected content without awarding streak credit.

**Files:**
- Create: `lib/features/quiz/domain/use_cases/start_drill.dart`
- Test: `test/features/quiz/domain/use_cases/start_drill_test.dart`

**Test cases to write first:**
- `start drill stores drill origin and subtopicId`
- `start drill supports 5 10 20 and all available lengths`
- `start drill falls back to General topic bucket when subtopicId is null`
- `start drill does not call quiz nudge`

**Implementation notes:** "All" means all picked questions available under the selected subtopic/topic, not all exam questions.

### Step 6.2: Add Drill browser route and UI

**Goal:** Let users browse topic/subtopic buckets and start Drill sessions from the Quiz tab.

**Files:**
- Create: `lib/features/quiz/presentation/drill_subtopic_browser.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/quiz/presentation/drill_subtopic_browser_test.dart`
- Modify: `test/app/router_redirect_test.dart`

**Test cases to write first:**
- `drill browser shows topic groups and General bucket counts`
- `length selector changes requested drill length`
- `tapping subtopic navigates to a drill session route`
- `drill route accepts deep link with examId and subtopicId`

**Implementation notes:** Use existing app components and avoid building Settings or Progress screens.

## Phase 7: Retake Missed/Mistakes Mode

### Step 7.1: Add attempt origin and recent incorrect queries

**Goal:** Persist the quiz surface that produced attempts and query recent incorrect answers for Retake.

**Files:**
- Modify: `lib/core/storage/data/tables/attempts_local_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Modify: `lib/core/storage/domain/attempt.dart`
- Modify: `lib/core/storage/data/repos/attempts_repository.dart`
- Modify: `lib/core/sync/mapping/attempt_mapper.dart`
- Test: `test/core/storage/data/attempt_origin_migration_test.dart`
- Modify: `test/core/storage/data/repos/attempts_repository_test.dart`
- Modify: `test/core/sync/mapping/attempt_mapper_test.dart`

**Test cases to write first:**
- `schema migration backfills existing attempts with today_topic origin`
- `save attempt stores origin`
- `recentIncorrects returns incorrect question ids from last 30 days`
- `attempt mapper syncs origin field and preserves backward-compatible default`

**Implementation notes:** This is durable user data and must remain in `app.db` and Spec 3 sync.

### Step 7.2: Implement `StartRetake`

**Goal:** Start a retake session from recent incorrect attempts with a 30-day window and 50-question cap.

**Files:**
- Create: `lib/features/quiz/domain/use_cases/start_retake.dart`
- Test: `test/features/quiz/domain/use_cases/start_retake_test.dart`

**Test cases to write first:**
- `start retake stores retake origin`
- `start retake dedupes repeated missed question ids`
- `start retake caps the pool at 50 questions`
- `empty mistake pool returns an empty-state result`

**Implementation notes:** Retake uses actual prior question IDs, then hydrates active or retired questions so history remains usable.

### Step 7.3: Wire Retake UI and empty state

**Goal:** Make the Quiz tab Retake CTA functional and friendly when there are no mistakes.

**Files:**
- Modify: `lib/features/quiz/presentation/retake_mistakes_card.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/quiz/presentation/retake_mistakes_card_test.dart`

**Test cases to write first:**
- `retake card shows count of recent mistakes`
- `tap starts retake when mistakes exist`
- `empty pool shows no recent mistakes message`

**Implementation notes:** Do not add mock-exam prep analysis; that belongs to Spec 5/11.

## Phase 8: Inline Lesson Quiz Mode

### Step 8.1: Implement `StartInlineLessonQuiz`

**Goal:** Start a five-question lesson coda scoped to the lesson's subtopic or topic fallback.

**Files:**
- Create: `lib/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart`
- Test: `test/features/quiz/domain/use_cases/start_inline_lesson_quiz_test.dart`

**Test cases to write first:**
- `inline lesson quiz stores inline origin lessonId and subtopicId`
- `inline lesson quiz requests exactly five questions`
- `inline lesson quiz falls back to topic when lesson has no subtopicId`
- `inline lesson quiz does not award streak credit`

**Implementation notes:** Lesson read progress remains independent and is not gated on taking the quiz.

### Step 8.2: Add lesson-end CTA

**Goal:** Show the "Quiz yourself" card after lesson content and route into inline quiz.

**Files:**
- Modify: `lib/features/lesson/presentation/lesson_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/lesson/presentation/lesson_page_test.dart`
- Modify: `test/app/router_redirect_test.dart`

**Test cases to write first:**
- `lesson page renders Quiz yourself card after lesson body`
- `tap starts inline lesson quiz route`
- `lesson progress read state still updates independently`

**Implementation notes:** Do not implement notes/bookmarks or Pro explanations here.

## Phase 9: Persistence, Dirty Flags, and Spec 3 Sync Integration

### Step 9.1: Replace submit-answer side effects

**Goal:** On every submitted answer, save attempt progress, update FSRS, update new-card counters, enqueue synced user rows, and auto-save session state.

**Files:**
- Modify: `lib/features/quiz/domain/use_cases/submit_answer.dart`
- Modify: `lib/features/quiz/data/repos/quiz_session_repository.dart`
- Modify: `lib/features/quiz/data/repos/new_card_intro_repository.dart`
- Modify: `lib/core/sync/engine/pending_queue.dart`
- Test: `test/features/quiz/domain/use_cases/submit_answer_test.dart`
- Modify: `test/core/sync/pending_queue_test.dart`

**Test cases to write first:**
- `submit answer writes FSRS dirty state before advancing session`
- `submit answer records attempt item with session origin`
- `submit answer increments new-card intro count only for first-seen cards`
- `submit answer does not advance when Drift write fails twice`
- `submit answer enqueues quiz_attempts and fsrs_cards sync rows`

**Implementation notes:** Keep writes inside one transaction where possible. Retry once on Drift failure, then surface a typed failure without advancing.

### Step 9.2: Add resume, quit, and restart use cases

**Goal:** Support crash recovery and explicit quit/restart flows for all modes.

**Files:**
- Create: `lib/features/quiz/domain/use_cases/resume_session.dart`
- Create: `lib/features/quiz/domain/use_cases/quit_session.dart`
- Create: `lib/features/quiz/domain/use_cases/restart_session.dart`
- Test: `test/features/quiz/domain/use_cases/resume_session_test.dart`
- Test: `test/features/quiz/domain/use_cases/quit_restart_session_test.dart`

**Test cases to write first:**
- `resume hydrates question N plus saved progress`
- `quit marks the active session quit and keeps answers`
- `restart requires explicit call and creates a new session`
- `completed sessions are not resumable`

**Implementation notes:** Resume should be user-scoped and exam-scoped; cross-device resume is intentionally unsupported.

### Step 9.3: Verify sync and guardrail coverage for quiz data

**Goal:** Ensure only durable user data syncs and local-only quiz state remains local.

**Files:**
- Modify: `test/core/sync/collection_registry_test.dart`
- Modify: `test/tool/sync_import_boundary_test.dart`
- Modify: `test/tool/check_attribution_guardrail_test.dart` if the file exists

**Test cases to write first:**
- `collection registry includes attempts and fsrs cards with origin support`
- `collection registry excludes quiz_sessions and daily_new_card_intro`
- `content database is not referenced by sync mappers`
- `attribution guardrail still passes with new quiz files`

**Implementation notes:** Do not add vendor/tool/model attribution strings in comments, docs, commit messages, or generated files.

## Phase 10: UI/Routing Polish, Diagnostics Seams, CI/Docs

### Step 10.1: Replace quick quiz route with mode-aware session screen

**Goal:** Use one shared session screen for all four user-visible quiz modes and keep legacy quick links redirected.

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_page.dart`
- Create: `lib/features/quiz/presentation/session_screen.dart`
- Create: `lib/features/quiz/presentation/post_answer_toast.dart`
- Create: `lib/features/quiz/presentation/done_for_today_celebration.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/quiz/presentation/session_screen_test.dart`
- Modify: `test/features/quiz/presentation/quiz_page_test.dart`

**Test cases to write first:**
- `submit answer shows correct incorrect feedback and FSRS toast`
- `next advances after feedback`
- `quit button shows confirmation and saves progress`
- `last answer shows minimal completion surface`
- `legacy quick route redirects to today session start`

**Implementation notes:** Keep explanations as the existing short answer-key behavior; no paywall or full worked-solution UI in Spec 4.

### Step 10.2: Add diagnostics/doc guardrails for mode limits

**Goal:** Document implementation limits and keep future specs from confusing quiz mode scope.

**Files:**
- Create: `docs/quiz-modes.md`
- Modify: `test/tool/content_docs_test.dart`
- Modify: `.github/workflows/ci.yml` only if new test paths need explicit inclusion

**Test cases to write first:**
- `quiz mode docs mention content.db is regenerable and app.db holds attempts`
- `quiz mode docs mention Mock Exam and paywall are out of scope`
- `CI includes tool guardrail tests through flutter test`

**Implementation notes:** Keep docs operational and concise; do not add attribution strings.

### Step 10.3: Final verification and fix-forward commit

**Goal:** Run the full non-blocked verification matrix and commit only real fixes.

**Files:**
- Modify only files needed to fix verification failures.

**Test cases to write first:** No new feature tests unless verification exposes an untested behavior. Add regression tests before fixing any discovered bug.

**Implementation notes:** Run `flutter test`, `flutter analyze`, `flutter test test/tool`, and any backend/tooling tests already present. If live Sanity/Firebase validation is unavailable, record it as an external blocker rather than weakening tests.

## Self-Review

- **Placeholder scan:** No implementation step uses open-ended placeholders; every step lists concrete files, tests, and notes.
- **Spec coverage:** The plan covers subtopic schema, selector/picker architecture, all four requested surfaces, session persistence, FSRS rating, attempt origin, local-only session/new-card state, streak semantics, and sync guardrails.
- **Scope drift check:** Mock Exam, Study Plan generation, paywall/RevenueCat UI, notifications, Settings UI, Progress dashboard, and live Sanity authoring are explicitly excluded or external.
- **TDD integrity:** Every implementation step names tests to write before production edits and a focused green-state boundary.
- **External blockers:** Live Sanity, regenerated `content.db`, Firebase live validation, emulator/CI credentials, production manual verification, and release QA are all marked skippable.
