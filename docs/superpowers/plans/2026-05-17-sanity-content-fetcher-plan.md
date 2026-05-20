# Sanity Content Fetcher + Drift Cache Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace seeded content reads with a Sanity-sourced, regenerable `content.db` cache while preserving the existing app-facing content domain models.

**Architecture:** Content moves behind a new `lib/core/content/` boundary with its own plaintext Drift database, repositories, Sanity parsers/client, sync coordinator, and bundled seed installer. `app.db` remains encrypted user-data only; existing feature code is repointed through compatibility providers after the content database path is green.

**Tech Stack:** Flutter, Riverpod, Drift, Dio, SQLite, Node build tooling, Flutter tests with `NativeDatabase.memory()`.

**Target spec:** `docs/superpowers/specs/2026-05-16-sanity-content-fetcher-design.md`

**Date:** 2026-05-17

**Size:** L

---

## Open Questions

- The spec says `assets/seed/v1.json` is deleted, but also says not to remove the old seed path until the new content path is proven green. Tentative choice: keep `v1.json` during the compatibility phase, stop registering it as a Flutter asset only after content bootstrap/tests pass, and delete the old seeder in the final migration step.
- The current `Question` domain model stores `stem` and `explanation` as strings while the spec stores `stemJson` and `explanationJson` as Portable Text JSON. Tentative choice: keep the public domain model unchanged for Spec 2 by extracting readable text for existing quiz consumers and preserving full Portable Text JSON in `content.db` for future renderer use.
- The spec lists mock/diagnostic content doctypes but no existing domain models for mock blueprints, mock exams, or diagnostic sets. Tentative choice: add minimal content-domain models under `lib/core/content/domain/` for those new doctypes without adding Spec 5 UI or behavior.

## External Blockers

- **Skippable: Sanity project identifiers.** Set `SANITY_PROJECT_ID` and `SANITY_DATASET` for dev/prod builds via `--dart-define`.
- **Skippable: Sanity schema.** Create real Sanity doctypes `exam`, `subject`, `topic`, `question`, `lesson`, `mockExam`, `mockBlueprint`, and `diagnosticSet` with `schemaVersion`, `language`, `isActive`, and `_updatedAt` fields matching the spec.
- **Skippable: Sanity content.** Enter real English content with stable `_id` values that match existing seed IDs where user-data references must survive.
- **Skippable: CDN validation.** Verify `https://{projectId}.apicdn.sanity.io/v2024-01-01/data/query/{dataset}` can be queried without a token for the public read dataset.
- **Skippable: Sanity usage controls.** Configure dashboard spend caps and alerts at 50/80/100%.
- **Skippable: Build-time seed generation from live Sanity.** Run the Node fetch step with live project/dataset/token access and generate a real `assets/seed/content.db`.
- **Skippable: CI secrets.** Add Sanity read token, project ID, dataset, and bundle version/build number variables to CI before wiring the live seed build into release APK jobs.
- **Skippable: Crashlytics dashboard validation.** Confirm content sync non-fatals and bundle-version custom keys appear after Firebase console setup from Spec 1 is complete.

## File Structure

- Create `lib/core/content/content.dart` as the public barrel and provider entrypoint.
- Create `lib/core/content/content_database.dart` plus table files in `lib/core/content/tables/` for the separate `content.db`.
- Create `lib/core/content/domain/` only for new Spec 2 domain types not already present in `lib/core/storage/domain/`.
- Create `lib/core/content/repos/` for content-facing repositories returning existing storage domain models where they already exist.
- Create `lib/core/content/sanity/` for config, Dio client, GROQ strings, schema pins, parser exceptions, and pure parser functions.
- Create `lib/core/content/sync/` for throttling, coordinator, status, and fakeable fetch contracts.
- Create `lib/core/content/bundle/seed_installer.dart` for first-launch asset copy.
- Create `tools/build_content_seed/` for live Sanity fetch scaffolding and local fixture-based seed writing.
- Modify `lib/core/storage/storage.dart`, `lib/app/bootstrap.dart`, and feature consumers only after content repos are covered.

## Phase 1: Content Database Boundary + Schema

### Step 1.1: Add content database tables

**Goal:** Create the separate Drift schema for regenerable content rows without touching `app.db`.

**Files:**
- Create: `lib/core/content/content_database.dart`
- Create: `lib/core/content/tables/content_exams.dart`
- Create: `lib/core/content/tables/content_subjects.dart`
- Create: `lib/core/content/tables/content_topics.dart`
- Create: `lib/core/content/tables/content_questions.dart`
- Create: `lib/core/content/tables/content_choices.dart`
- Create: `lib/core/content/tables/content_question_exams.dart`
- Create: `lib/core/content/tables/content_lessons.dart`
- Create: `lib/core/content/tables/content_mock_blueprints.dart`
- Create: `lib/core/content/tables/content_mock_exams.dart`
- Create: `lib/core/content/tables/content_diagnostic_sets.dart`
- Create: `lib/core/content/tables/content_meta.dart`
- Test: `test/core/content/content_database_test.dart`

**Test cases to write first:**
- `content database creates all content tables at schema version 1`
- `content_question_exams enforces composite uniqueness`
- `app database schema does not include content tables`
- `content_meta upserts key value rows`

**Implementation notes:**
- Use `NativeDatabase.memory()` in tests and Drift `customSelect` against `sqlite_master` for table assertions.
- Include `schemaVersion`, `isActive`, and `updatedAt` on all content doctypes.
- Store question Portable Text columns as `stemJson` and `explanationJson`, plus separate `choices` and `questionExam` rows instead of JSON blobs.
- Commit: `feat(content): add content database schema`

### Step 1.2: Add content database opener and provider boundary

**Goal:** Open plaintext `<appSupportDir>/content.db` separately from encrypted user-data and expose test-overridable providers.

**Files:**
- Create: `lib/core/content/content_database_opener.dart`
- Create: `lib/core/content/content.dart`
- Modify: `lib/core/storage/storage.dart`
- Test: `test/core/content/content_providers_test.dart`

**Test cases to write first:**
- `contentDatabaseProvider throws until bootstrap override is supplied`
- `content repository providers use contentDatabaseProvider rather than appDatabaseProvider`
- `bootstrap content override returns a ContentDatabase instance`

**Implementation notes:**
- Keep `openContentDatabase()` plaintext and covered with `coverage:ignore-file` like the encrypted opener.
- Do not call the opener from app bootstrap until the seed installer exists.
- Keep the existing `contentRepositoryProvider` name as a compatibility alias so feature churn stays small.
- Commit: `feat(content): add content database providers`

## Phase 2: Repository Compatibility Layer

### Step 2.1: Add exam, subject, topic, question, and lesson repos

**Goal:** Return the existing `Exam`, `Subject`, `Topic`, `Question`, `Choice`, and `Lesson` models from the new content database.

**Files:**
- Create: `lib/core/content/repos/exam_repo.dart`
- Create: `lib/core/content/repos/subject_repo.dart`
- Create: `lib/core/content/repos/topic_repo.dart`
- Create: `lib/core/content/repos/question_repo.dart`
- Create: `lib/core/content/repos/lesson_repo.dart`
- Modify: `lib/core/content/content.dart`
- Test: `test/core/content/repos/content_repos_test.dart`

**Test cases to write first:**
- `ExamRepo.activeExams returns active exams with ordered subjects`
- `TopicRepo.byExam flattens subject topics in ordering order`
- `QuestionRepo.byTopic filters inactive questions by default`
- `QuestionRepo.byExam uses content_question_exams junction`
- `QuestionRepo.findById returns retired questions for history`
- `LessonRepo.byTopic filters inactive lessons and preserves bodyJson`

**Implementation notes:**
- Extract plain text from Portable Text JSON for `Question.stem` and `Question.explanation` to preserve current quiz UI behavior.
- `findById` methods may return inactive rows; list/browse methods filter `isActive`.
- Preserve existing method names through a compatibility `ContentRepository` facade if changing consumers in one commit would be too broad.
- Commit: `feat(content): add content repository compatibility layer`

### Step 2.2: Add new doctype repos for future specs

**Goal:** Persist and read mock blueprint, mock exam, and diagnostic set content without building Spec 5 UI.

**Files:**
- Create: `lib/core/content/domain/mock_blueprint.dart`
- Create: `lib/core/content/domain/mock_exam.dart`
- Create: `lib/core/content/domain/diagnostic_set.dart`
- Create: `lib/core/content/repos/mock_blueprint_repo.dart`
- Create: `lib/core/content/repos/mock_exam_repo.dart`
- Create: `lib/core/content/repos/diagnostic_set_repo.dart`
- Modify: `lib/core/content/content.dart`
- Test: `test/core/content/repos/future_content_repos_test.dart`

**Test cases to write first:**
- `MockBlueprintRepo.byExam filters inactive blueprints`
- `MockExamRepo.byBlueprint filters inactive mock exams`
- `DiagnosticSetRepo.forExam returns ordered question ids`
- `future repos return empty results when no active content exists`

**Implementation notes:**
- Store `sectionsJson` and `questionIdsJson` as JSON strings per spec; validate JSON shape at parser time, not in repo methods.
- Do not add paywall or mock exam screen behavior.
- Commit: `feat(content): add future content repositories`

## Phase 3: Sanity Client + GROQ Query/Parsing Layer

### Step 3.1: Add schema pins, parser exceptions, and Portable Text parser

**Goal:** Centralize schema-version checks and validate Portable Text before storage.

**Files:**
- Create: `lib/core/content/sanity/schema_versions.dart`
- Create: `lib/core/content/sanity/parser_exceptions.dart`
- Create: `lib/core/content/sanity/parsers/portable_text_parser.dart`
- Test: `test/core/content/sanity/parsers/portable_text_parser_test.dart`

**Test cases to write first:**
- `portableTextToJson accepts blocks with span children`
- `portableTextToJson preserves image and math blocks`
- `portableTextToJson rejects non-list values`
- `portableTextToJson rejects span children without text`

**Implementation notes:**
- Parser output is JSON text, not renderer widgets.
- Keep exceptions small and value-rich: doctype, field, got/expected where available.
- Commit: `feat(content): add Sanity parser foundation`

### Step 3.2: Add doctype parsers with fixture tests

**Goal:** Convert Sanity response maps into content database companions and child rows.

**Files:**
- Create: `lib/core/content/sanity/parsers/exam_parser.dart`
- Create: `lib/core/content/sanity/parsers/subject_parser.dart`
- Create: `lib/core/content/sanity/parsers/topic_parser.dart`
- Create: `lib/core/content/sanity/parsers/question_parser.dart`
- Create: `lib/core/content/sanity/parsers/lesson_parser.dart`
- Create: `lib/core/content/sanity/parsers/mock_blueprint_parser.dart`
- Create: `lib/core/content/sanity/parsers/mock_exam_parser.dart`
- Create: `lib/core/content/sanity/parsers/diagnostic_set_parser.dart`
- Create: `test/fixtures/sanity/content_sample.json`
- Test: `test/core/content/sanity/parsers/doctype_parsers_test.dart`

**Test cases to write first:**
- `each parser accepts the fixture happy path`
- `each parser rejects wrong schemaVersion`
- `question parser emits question row choices and exam junction rows`
- `lesson parser rejects malformed body Portable Text`
- `diagnostic parser preserves ordered question ids`

**Implementation notes:**
- Parser functions should be pure and should not import Dio, Riverpod, or Flutter.
- Reference IDs may arrive as `{'_ref': 'id'}` from Sanity; normalize to strings at parser boundaries.
- Per-doctype parser failures are surfaced to sync; parsers should not swallow them.
- Commit: `feat(content): add Sanity parser layer`

### Step 3.3: Add GROQ constants and Dio client

**Goal:** Query Sanity CDN with pinned API version, build-time config, and typed `SanityResponse` results.

**Files:**
- Create: `lib/core/content/sanity/groq_queries.dart`
- Create: `lib/core/content/sanity/sanity_config.dart`
- Create: `lib/core/content/sanity/sanity_client.dart`
- Test: `test/core/content/sanity/sanity_client_test.dart`
- Test: `test/core/content/sanity/groq_queries_test.dart`

**Test cases to write first:**
- `SanityConfig.fromEnvironment returns null when project id or dataset is missing`
- `SanityClient encodes query and params for apicdn endpoint`
- `SanityClient returns networkError for Dio failures`
- `SanityClient returns parseError when parser throws`
- `GROQ delta queries include _updatedAt > $since`

**Implementation notes:**
- Use `Dio.fetch`/custom adapter tests rather than real network calls.
- No token support in the app client.
- Keep Node query mirror in Phase 7 rather than importing Dart into Node.
- Commit: `feat(content): add Sanity client and GROQ queries`

## Phase 4: Sync Coordinator + Throttling/Manual Refresh Seam

### Step 4.1: Add sync status and throttle

**Goal:** Model stale-content decisions and user-visible sync states independently from networking.

**Files:**
- Create: `lib/core/content/sync/sync_status.dart`
- Create: `lib/core/content/sync/sync_throttle.dart`
- Test: `test/core/content/sync/sync_throttle_test.dart`

**Test cases to write first:**
- `isStale returns true when lastSyncedAt is missing`
- `isStale returns false inside six hour window`
- `isStale returns true at exactly six hours`
- `SyncStatus exposes idle syncing ok partialFailure and failure states`

**Implementation notes:**
- Use plain sealed classes to avoid generated files.
- Clock is injected for deterministic tests.
- Commit: `feat(content): add sync throttle`

### Step 4.2: Add sync coordinator with fakeable doctype fetchers

**Goal:** Upsert each doctype independently, preserve cached rows on parser/schema failures, and expose manual refresh.

**Files:**
- Create: `lib/core/content/sync/content_sync_coordinator.dart`
- Modify: `lib/core/content/content.dart`
- Test: `test/core/content/sync/content_sync_coordinator_test.dart`

**Test cases to write first:**
- `first sync uses full fetchers when lastSyncedAt is missing`
- `subsequent sync uses delta fetchers with lastSyncedAt`
- `one doctype failure emits partialFailure and leaves prior rows`
- `all doctypes failing emits failure`
- `refreshNow bypasses throttle`
- `syncIfStale no-ops inside throttle window`
- `concurrent sync calls share one in-flight future`

**Implementation notes:**
- Define an internal `ContentDoctypeFetcher` interface so tests do not depend on live Sanity.
- Use insert-on-conflict-update per row; never delete missing rows.
- Update `content_meta.lastSyncedAt` only after at least one doctype succeeds.
- Commit: `feat(content): add content sync coordinator`

## Phase 5: Bundled `content.db` Seed Installer/Build Tooling

### Step 5.1: Add seed installer

**Goal:** Copy `assets/seed/content.db` to app support on first launch and leave existing cache untouched.

**Files:**
- Create: `lib/core/content/bundle/seed_installer.dart`
- Modify: `lib/app/bootstrap.dart`
- Modify: `lib/core/content/content.dart`
- Test: `test/core/content/bundle/seed_installer_test.dart`

**Test cases to write first:**
- `install copies bundled content db when destination is missing`
- `install does not overwrite an existing destination`
- `install throws when asset copy fails`
- `bootstrap installs content before app runs`

**Implementation notes:**
- Implement the installer around injectable asset/destination functions so unit tests use temp files and byte fixtures.
- Do not require a real generated `assets/seed/content.db` in unit tests.
- Crashlytics bundle-key logging is best-effort and must not block startup.
- Commit: `feat(content): add bundled content seed installer`

### Step 5.2: Add seed writer smoke path

**Goal:** Let CI/local tooling build an openable SQLite seed from fixture JSON without live Sanity.

**Files:**
- Create: `tools/build_content_seed/package.json`
- Create: `tools/build_content_seed/build.mjs`
- Create: `tools/build_content_seed/queries.mjs`
- Create: `tools/build_content_seed/seed_writer.dart`
- Create: `test/tool/content_seed_writer_test.dart`
- Modify: `.gitignore`
- Modify: `pubspec.yaml`

**Test cases to write first:**
- `seed_writer creates an openable content database from fixture JSON`
- `build.mjs requires SANITY_PROJECT_ID SANITY_DATASET and SANITY_READ_TOKEN for live fetch`
- `pubspec registers assets/seed/content.db not assets/seed/v1.json after migration`

**Implementation notes:**
- The live Node fetch is skippable without credentials; test the argument/env validation and query exports locally.
- Ignore generated `assets/seed/content.db`; keep a tiny test fixture DB under `test/fixtures/` if needed.
- If the app cannot build without a real seed asset, add a clear tool test failure message rather than committing an empty production seed.
- Commit: `chore(content): add seed build tooling`

## Phase 6: Migration Away From Bundled JSON Seed Where Possible

### Step 6.1: Repoint app content providers and consumers

**Goal:** Make onboarding, quiz, assessment, and lessons read from `content.db` through compatibility providers.

**Files:**
- Modify: `lib/core/storage/storage.dart`
- Modify: `lib/features/assessment/presentation/assessment_page.dart`
- Modify: `lib/features/assessment/presentation/assessment_result_providers.dart`
- Modify: `lib/features/assessment/presentation/assessment_results_page.dart`
- Modify: `lib/features/assessment/domain/services/assessment_question_selector.dart`
- Modify: `lib/features/quiz/domain/use_cases/start_quick_quiz.dart`
- Modify: `lib/features/quiz/presentation/quiz_controller.dart`
- Modify: `lib/features/quiz/presentation/quiz_results_page.dart`
- Modify: `lib/features/lesson/domain/use_cases/get_lesson.dart`
- Modify: `lib/features/lesson/domain/use_cases/get_topic_lessons.dart`
- Modify: `lib/features/lesson/presentation/lesson_list_page.dart`
- Test: existing affected tests under `test/features/assessment/`, `test/features/quiz/`, and `test/features/lesson/`

**Test cases to write first:**
- `quiz controller overrides contentRepositoryProvider from core/content`
- `lesson pages resolve topic and lesson through content providers`
- `assessment question selector still tolerates empty content`

**Implementation notes:**
- Prefer keeping provider names stable via exports/aliases to avoid broad feature churn.
- Tests should override both `appDatabaseProvider` and `contentDatabaseProvider` only where user-data and content-data are both needed.
- Commit: `feat(content): repoint feature reads to content cache`

### Step 6.2: Retire JSON seeding after green compatibility

**Goal:** Remove app startup dependence on `assets/seed/v1.json` while leaving user-data schema untouched.

**Files:**
- Modify or delete: `lib/core/storage/data/seeder.dart`
- Modify: `lib/app/bootstrap.dart`
- Modify: `pubspec.yaml`
- Delete: `assets/seed/v1.json`
- Modify/Delete: `test/core/storage/data/seeder_test.dart`
- Modify: `test/features/quiz/integration_test.dart`

**Test cases to write first:**
- `bootstrap no longer calls JSON Seeder`
- `old Seeder shim is a no-op if imports still exist`
- `integration test seeds content database fixture instead of v1 json`

**Implementation notes:**
- Only delete `v1.json` after feature tests pass on `content.db`.
- If old imports remain too risky to remove in one step, leave a no-op shim with a deprecation comment and no asset read.
- Commit: `chore(content): retire bundled json seed`

## Phase 7: CI/Docs

### Step 7.1: Add content authoring and setup docs

**Goal:** Document the manual Sanity setup, immutable-by-id discipline, and local seed generation.

**Files:**
- Modify: `CONTRIBUTING.md`
- Create or modify: `docs/content/sanity-setup.md`
- Test: `test/tool/content_docs_test.dart`

**Test cases to write first:**
- `CONTRIBUTING documents immutable by id and retire via isActive`
- `Sanity setup docs mention project id dataset CDN validation and CI secrets`
- `docs do not contain prohibited attribution strings`

**Implementation notes:**
- Keep docs operational and concise; do not invent actual project IDs or tokens.
- Mark live Sanity and CI secret steps as external/manual.
- Commit: `docs(content): document Sanity setup`

### Step 7.2: Add static CI guard tests for seed config

**Goal:** Make missing content seed and query/tooling drift visible before release builds.

**Files:**
- Create: `test/tool/content_seed_config_test.dart`
- Modify: `.github/workflows/*` if workflows exist
- Modify: `Makefile` if one exists, otherwise document commands only

**Test cases to write first:**
- `pubspec includes assets/seed/content.db`
- `assets/seed/content.db is gitignored`
- `Node and Dart query files expose the same doctype names`
- `release seed workflow references build_content_seed`

**Implementation notes:**
- If no GitHub workflow exists, add the static test and document the CI command instead of inventing a full release pipeline.
- Do not require live Sanity in CI tests.
- Commit: `chore(content): add content seed CI guards`

## Final Verification

- Run `flutter test`.
- Run `flutter analyze`.
- Run `dart test test/tool/content_seed_writer_test.dart` if the seed writer test is a Dart VM test; otherwise run the focused Flutter tool test that covers the seed writer.
- Run any generated-code command needed by Drift, then repeat focused tests affected by generated code.
- Commit any fixes with a conventional commit message and no `--no-verify`.

## Self-Review

- Spec coverage: The plan covers content schema, Sanity client/parsers/GROQ, sync throttle/manual refresh, bundled seed install/build tooling, repository compatibility, migration off JSON seed, CI/docs, and external setup blockers.
- Placeholder scan: No placeholder markers or invented credentials remain. External work is explicitly marked skippable.
- Type consistency: The plan consistently uses `ContentDatabase`, `content.db`, `content_meta.lastSyncedAt`, `schemaVersion`, and repository names under `lib/core/content/`.
- Scope drift check: The plan avoids Spec 3 sync, Spec 5 mock UI, Spec 7 paywall, and Spec 8 Settings UI beyond exposing manual refresh seams.
- TDD integrity: Each implementation step names concrete tests to write first, a focused implementation target, verification expectation, and a commit boundary.
