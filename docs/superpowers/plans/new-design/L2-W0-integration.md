# L2 W0: integration (question-qa-r2 merge and baseline)

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 24ce4a98.
Parent: `docs/superpowers/2026-10-05-engineering-restart-strategy.md` (B2, B4).
Spec: `docs/superpowers/specs/2026-10-05-new-design-amendment-design.md` (approved Oct 5).
Traceability rows: every row with workstream `W0` in `traceability.md`.

## 1. Purpose and scope

Bring the approved question QA round into `integration/new-design-r1` so every later workstream
builds on the content and data layer that will ship, and fix the content contracts every other
workstream consumes.

In scope:
- Merge `origin/content/question-qa-r2` (765c5dc0) into `integration/new-design-r1` (1f79d880).
  The merge base is 1f79d880, so this is a fast-forward of 214 commits.
- Optional, amended (level 3 gate review 2): rebuild the protected content package from the merged content only if Aedwon wants a device build before W5; the release package is built once in W5. The package
  is `assets/seed/content.db`, `content.manifest.json` and `content.manifest.sig` at the next release
  sequence. There is no separate dev
  seed: `tools/build_dev_seed` is superseded and must not be restored (AGENTS.md). Without the signed
  rebuild the app keeps reading the old package, so the merged questions reach tests and fixtures
  but not the running app until Aedwon authorizes it.
- Figure credits in lesson image blocks from `content/illustrations/sources/*.yaml` (W0 Task 4b;
  added at level 3 gate review 2).
- Data the design adds (F-4, N-6 of the level 2 gates), as fields inside existing JSON columns, so
  the app database stays at schema 25: in `attempts_local.itemsJson` (`AttemptItem`), `MistakeTag`
  gains `other` and the item gains nullable `mistakeNote` (D-183); in `mock_attempts.answersJson`
  each answer gains nullable `missReason` (`misread`, `slipped`, `unknown`, `other`) and
  `blankReason` (`ranOutOfTime`, `skippedToReturn`, `didNotKnow`, `other`) with nullable
  `reasonNote` (D-196); `sectionResultsJson` (`SectionResult`) gains `wrong` and `blank` counts per
  part. Old rows parse with the new fields null. W0 confirms the sync payload carries these JSON
  columns unchanged; if it maps fields, W0 adds them. W4d and W4e write them.
- Exam catalog storage (N-5): content database schema 9 to 10 with its migration, adding the catalog
  fields to `content_exams` (or a `catalogJson` column), filled by the content export; W0 adds the
  exam rows for the Coming soon exams with `comingSoon: true` and no content. The catalog is also
  written as `functions/src/examCatalog.json` by the export so the webhook can compute pass end dates
  (N-20).
- Full required checks on the merged result; record the new baseline.
- Confirm data facts other plans depend on (section 4).

Out of scope: application code beyond the data and catalog changes above and their tests; content edits (the content track owns content); the
content coverage audit (separate track); the 134 questions the QA round flagged for Aedwon (content
track; their state is carried as-is).

Correction to strategy B1 (recorded in the decision record, Oct 6): question-qa-r2 changes no
application code. Its 328 changed files are question YAML (158 files), audit ledgers under
`docs/content/audit/question-qa-r2/`, one importer rule (`tools/import_questions/converter.dart`:
every wrong choice needs a non-empty rationale), its tests (including
`test/core/content/content_providers_test.dart`), and two fixtures
(`test/fixtures/content/e02_export.json.gz`, `test/fixtures/questions/science/biology/cell-structure.yaml`).

## 2. Inputs

- Branch facts above, checked October 6 with `git diff --stat` against the merge base.
- Restart log: pause lifted for "merging the question-qa-r2 code" (Oct 5).
- `docs/content-key-access.md`: key access is not permission to rebuild the package; a rebuild
  changes artifact identity and invalidates affected stage evidence.
- Release-first cuts (Oct 1) and the E09 to E14 plans: content identity proofs (CP-T5) are redone in
  W5 on the new package.
- Traceability: G-b-11, G-b-12, G-b-13, G-h-27 and amendment B3 (recorded-only data).

## 3. Contracts owned

| Contract | Definition |
|---|---|
| Question file format | YAML per lesson at `content/questions/<subject>/<topic>/<lesson>.yaml`; `meta` has `subject`, `topic`, `subtopic`, `exams`; each question has `id`, `type`, `difficulty`, `stem`, `choices` (one `correct: true`; every other choice has a non-empty `rationale`), `explanation`; optional `passage`, `figure`, `shortLabel`. As enforced by `tools/import_questions` at the merged commit. |
| Lesson id on questions | `meta.subtopic` equals the lesson slug (lesson file `content/lessons/<subject>/<topic>/<lesson>.md`). A question's lesson is its file's subtopic. This settles amendment spec B5's open item: the lesson-scoped in-lesson quiz (W4c) keys on it. Checked Oct 6 on 765c5dc0: 158 question files, 158 lesson files, every question path matches a lesson path. W0 repeats the check on the merged tree. |
| Content package | Format v2 manifest, release sequence incremented by one from the shipped package, detached Ed25519 signature with key id `content-signing-v1`, built with `tools/build_content_package` and checked with `tools/verify_content_package`. |
| Data layer | App database (`lib/core/storage/data/app_database.dart`) schema 25, unchanged; content database (`lib/core/content/content_database.dart`) schema 10 after W0 (catalog). The JSON fields in section 1 are part of this contract under these exact names: `AttemptItem.mistakeTag` (`other` added), `AttemptItem.mistakeNote`, mock answer `missReason`, `blankReason`, `reasonNote`, `SectionResult.wrong`, `SectionResult.blank`. No workstream changes either without a level 2 amendment naming the new version and its migration (SUBAGENTS Part 3). |
| Exam catalog | Per exam, from content exam metadata: `priceTier`, `group` (College entrance, High school, Civil service, Licensure, Uniformed services), `comingSoon`, and `publishedSittings` (each with first and last day and the published source). W0 adds the fields to the exam metadata format and content database export; values come from the tier pricing spec (`specs/2026-10-06-tier-pricing-design.md`). An exam with no published sitting has none; nothing is inferred. |
| Mock blueprints | `content/mock/<exam>.yaml`. The blueprint-level `source` and `sourceNote` stay the citation for the whole blueprint. A single value with no published source carries `placeholder: true` and a `placeholderNote` (N-21: field-level, because only some values are placeholders); the app wraps it in W2's `PlaceholderFigure`. Known placeholders: CSE Professional and Subprofessional per-subject item counts; ACET aptitude time (R-20). W4e authors the CSE and ACET blueprints. |
| Recorded-only data | Attempts keep per-answer response time and session timing; mistake tags (`AttemptItem.mistakeTag` with `other`, `AttemptItem.mistakeNote`); mock `missReason`, `blankReason`, `reasonNote`; `SectionResult.wrong`, `SectionResult.blank` (all JSON fields, app schema 25). Also kept, as constraints on the families that rebuild their code: Terms acceptance records the policy version (`lib/features/settings/data/settings_repository.dart`; W4f keeps the write, W4a calls it), backend bookmark sync for Pro (W4c). No `wrapped_revealed` or `wrapped_shared` analytics events exist; none are added (G-g-21; adding them is Aedwon's decision). Consumers delete widgets, never these writes or columns. |
| Offline posture | The rules in `2026-08-03-offline-and-network-posture-design.md` Sections 3, 5, 7 stay in force (no connectivity banner, no blocking spinner on local data, last entitlement stands on network failure). |

Contracts consumed: none.

## 4. Behavior

No student-visible change beyond the content itself: more questions (all 158 lessons have at least
20 active questions per the QA round) and corrected answer keys. Free and Pro: same rules as today.
Placeholders: the mock blueprint marker contract only; W0 sets no placeholder values.

## 5. Motion

None.

## 6. Acceptance

Automated, on the merged and regenerated tree:
- `dart run build_runner build --delete-conflicting-outputs` exit 0.
- `flutter analyze`: only the known `onReorder` info (bookmarks sheet), which W2 removes.
- `dart format --output=none --set-exit-if-changed lib test` exit 0.
- `dart run tool/check_layering.dart` and `dart run tool/check_no_ai_attribution.dart` exit 0.
- `flutter test` all green (baseline was 3,403; expect more from the merged tests), including a
  content database migration test from schema 9 to 10 and parsing of old JSON rows without the new
  fields.
- Figure credits in lesson image blocks (W0 Task 4b, added (level 3 gate review 2)); producing
  `content/illustrations/assets.json` needs a Sanity upload with Aedwon's approval.
- Content gates from SUBAGENTS Part 4 over the whole corpus: validator 0, em dash 0, approved 0,
  noexams 0.
- If the optional package is built: `tools/verify_content_package` exit 0 on it; manifest release
  sequence is one above the previous package.
- `functions` tests (`node --test`) run once and recorded; they were not run in the Oct 5 baseline.

Aedwon: nothing visual. He authorizes the package rebuild (section 7).

## 7. Risks and stop conditions

- **Lesson ids (added Oct 6, Aedwon: "the current content might get split").** Lessons may be
  split, merged or renamed after the content coverage audit. Every saved student record is keyed by
  lesson id (read marks, bookmarks, attempts, plan progress). No lesson id changes or disappears
  without an approved plan that maps old ids to new ones and migrates saved progress; a change
  without one stops at review. Lesson-level prerequisites, if approved, are a roadmap engine change
  and a content format amendment here, planned when the audit reports.

- **Signing authorization.** Rebuilding the package uses the signing seed. Per
  `docs/content-key-access.md` this needs Aedwon's explicit permission. It is requested together
  with the start of level 4. Without it, W0 completes after the merge and the data changes; the
  package is built in W5 (level 3 gate review 2).
- A merge that is not a fast-forward (the integration branch moved): stop and report.
- App schema not 25 after the merge: stop. Content schema 10 lands in one commit with its
  migration.
- Level 3 fixes the catalog storage form (columns or `catalogJson`) and its reader API name before
  any consumer writes a reader (gate N3-7).
- `MistakeTag` gains a fallback for unknown values so an older build syncing an item tagged `other`
  does not fail to decode (gate N3-9).
- Exam dates: only dates Aedwon supplies with a source link (tier spec decision 1); none inferred.
- Any validator error, or an answer key change found outside the QA ledgers: stop and report to the
  content track; do not edit content.
- A failing test unrelated to content: stop (SUBAGENTS Part 6).
- Seed assets are gitignored; never commit them.

## 8. Files and directories

May touch: the integration branch history (the fast-forward), `assets/seed/*` (generated, not
committed), the build output directory, `lib/core/storage/domain/` (JSON models), `lib/features/mock_exam/domain/mock_results.dart` (adds the
mock JSON field declarations only; W4e computes and writes the counts and reasons; before W4e), `lib/core/content/` (content schema 10,
migration), `lib/core/sync/` (payload fields if mapped), `functions/src/examCatalog.json`, content exam metadata format and export tools
(`tools/build_content_export/`, `tools/import_questions/` if exam metadata lives there; `tools/content/markdown_portable_text.dart` and `tools/content/lesson_asset_map.dart` for figure credits, Amended Oct 6 (level 3 gate review 1), L3-6), matching
tests, and the verification record in `docs/superpowers/plans/new-design/`.

## 9. Order and parallelism

First workstream in level 4. W1 and W3 start only after W0's checks pass and the new baseline SHA
is recorded.
