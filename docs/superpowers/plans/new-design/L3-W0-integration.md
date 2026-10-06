# L3 W0: integration (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 3c4569fd.
Level 2 plan: `L2-W0-integration.md` (gate passed Oct 6). Strategy B5, B6.
Base: `integration/new-design-r1` at 1f79d880. Executor: GPT-6.1 Sol High through Codex (strategy B7 as amended Oct 6); the Opus lead
resolves any merge conflict, reviewed separately. One worktree:
`../Pantas-wt-integration-new-design-r1` (the integration branch itself; W0 is a fast-forward plus
data commits, so it runs on the branch directly, serialized before every other workstream).
Closes carry-forward: N3-7, N3-9/N4-5, N5-2 (W0 side).

Every task: write the failing test first where a test is named, run it and confirm it fails for the
expected reason, implement, run the task's checks, commit with a message that says why. Never commit
generated files or `assets/seed/*`.

## Task 1. Fast-forward the QA merge

Traceability: S0-43 context; L2 §1.
1. `git fetch origin`; confirm `integration/new-design-r1` is still 1f79d880 and `origin/content/question-qa-r2`
   is 765c5dc0. If either moved: stop.
2. `git merge --ff-only origin/content/question-qa-r2`. If not a fast-forward: stop.
3. `dart run build_runner build --delete-conflicting-outputs`.
4. Checks: `dart run tools/import_questions/import_questions.dart --root content/questions >/dev/null 2>&1; echo $?`
   expects 0; content gate one-liner from SUBAGENTS Part 4 over `content/questions` expects
   validator 0, emdash 0, noexams 0, and `approved` reported but not required to be 0 (corrected
   Oct 6: the "approved 0" rule in SUBAGENTS Part 4 is for question writers; this merge preserves
   Question Studio approvals, 83 files at 1f79d880 and 158 after the merge); `flutter test test/tool test/core/content` green.
5. Lesson-id check: every `content/questions/<s>/<t>/<l>.yaml` has `content/lessons/<s>/<t>/<l>.md`
   and `meta.subtopic == <l>` (script in the task's evidence). Expect 158 of 158.
Files: none edited (fast-forward). Push the branch.

## Task 2. JSON fields the design adds (app schema stays 25)

Traceability: W0 contract "Data layer", "Recorded-only data"; F-4, N-6, N3-1, N3-9, N4-5, N5-2.
Tests first (`test/core/storage/domain/attempt_json_test.dart`, `test/features/mock_exam/domain/mock_results_test.dart` (constructor defaults: new fields null)):
- `AttemptItem` JSON with `mistakeTag: "other"` and `mistakeNote` round-trips.
- An unknown `mistakeTag` value (for example `"future"`) decodes as `null` instead of throwing
  (`@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)`), closing N3-9.
- Old JSON without the new fields decodes with them null. The dev demo writer
  (`dev_demo_switch.dart`) is left alone; its rows lack the counts, which W4e's null recompute handles.
- `MockAnswer` gains nullable `missReason` (`MissReason { misread, slipped, unknown, other }`),
  `blankReason` (`BlankReason { ranOutOfTime, skippedToReturn, didNotKnow, other }`), `reasonNote`;
  `SectionResult` gains nullable `wrong` and `blank` (`int?`; null means an old row written before
  the counts existed). N5-2: W0 declares only; W4e Task 2 owns the one decoder change.
Implement in `lib/core/storage/domain/attempt.dart` and
`lib/features/mock_exam/domain/mock_results.dart` (`mock_results.dart` has no JSON code: W0 adds the constructor fields only;
`AttemptItem` is freezed, so its JSON is generated; W4e fills and encodes the mock values).
Sync: `attempt_mapper.dart` and `mock_attempt_mapper.dart` copy the JSON columns raw (checked Oct 6),
so no sync change; a test in `test/core/sync/` asserts a round-trip keeps the new fields.
Checks: the new tests, `flutter test test/core test/features/mock_exam`, `flutter analyze`.

## Task 3. Exam catalog (bundled file; content schema stays 9)

Traceability: W0 contract "Exam catalog"; F-2, N-5, N-20, N3-7; tier spec B1; D-29, D-225.
Decision (amended Oct 6 after the worker's stop, evidence 6109ad1b): the catalog is not stored in
the protected content database. A schema bump would break the protected package contract (the
installer, the signed manifest and the pinned schema-8 fixture all fix schema 9). The catalog is
public metadata, so it lives in one hand-edited source file, `content/exams/catalog.json`,
bundled as a Flutter asset and copied into the Functions build. Content schema stays 9; no
protected-content code, seed writer or fixture changes.
1. `content/exams/catalog.json` (hand-edited, never generated): one entry per exam with `id`
   (the content exam id, for example `exam_upcat`), `name`, `shortName`, `priceTier`, `group`,
   `comingSoon`, `publishedSittings` (each `firstDay`, `lastDay`, `sourceUrl`). Entries: the seven
   current exams; `exam_dost_sei` (DOST-SEI Undergraduate Scholarship, DOST, group Scholarships,
   Student tier) and `exam_sm_foundation` (SM Foundation College Scholarship, SM, Scholarships,
   Student tier; no questions yet, a release blocker) (Aedwon, Oct 6: "these should be included");
   the nine Coming soon exams (PSHS-NCE, NAPOLCOM, AFPSAT, PMA, PNPA, PMMA, MAAP, LET, PNLE) with
   tier and group per pricing.md and DECISIONS D-29, D-225. Sittings: CSE Professional and CSE
   Subprofessional on 2027-03-14 and 2027-08-08 (one day each, source CSC Examination Announcement
   No. 05, s. 2026, the link in the decision log); no other dates.
2. `pubspec.yaml`: add `content/exams/catalog.json` to assets.
3. Reader API: `ExamCatalogRepository` in `lib/core/content/data/` with
   `Future<ExamCatalogEntry> entry(String examId)` and `Stream<List<ExamCatalogEntry>> watchAll()`;
   `ExamCatalogEntry { id, name, shortName, priceTier, group, comingSoon, publishedSittings,
   hasContent }`. It loads the asset once and sets `hasContent` from whether the content database
   has that exam row. An exam is selectable only when `comingSoon` is false and `hasContent` is true;
   otherwise the picker shows it as Coming soon.
4. Export tool (`tools/build_content_export/build_content_export.dart`): add `exam_dost_sei` and
   `exam_sm_foundation` to `_rosterExams` the way ACET is added (exam rows only; schema 9). These rows
   reach the app with the next package build (W5 Task 1).
5. A validation test reads `content/exams/catalog.json`: every id is unique, tiers and groups are in
   the allowed sets, dates are ISO with `lastDay >= firstDay` and a `sourceUrl`, every non-Coming
   soon entry other than SM has an exam row in the export.
Tests first: repository returns entries in file order with sittings ordered; an exam with no
sittings returns an empty list; `hasContent` false makes it unselectable; the validation test.
Stop condition: if O_Picker or ST_ExamPick shows an available exam missing from the catalog file:
stop.
Checks: `flutter test test/core/content test/tool` green; `content/exams/catalog.json` passes the
validation test; `dart run tools/build_content_export/build_content_export.dart "$TMPDIR/export.json"`
exits 0 and the output lists `exam_dost_sei` and `exam_sm_foundation`.

## Task 4. Mock blueprint placeholder marker

Traceability: W0 contract "Mock blueprints"; F-15, N-21.
Tests first: the blueprint parser accepts a value written as `{ value: 40, placeholder: true,
placeholderNote: "..." }` and exposes `isPlaceholder`; plain values parse as before.
Implement in the blueprint parser (`lib/core/content/` mock blueprint model) and the export tool.
W4e writes the CSE and ACET blueprints later.
Checks: `flutter test test/core/content` green; `content/mock/upcat.yaml` still parses (existing test).

## Task 4b. Figure credits in lesson blocks

Traceability: D-132, D-137 (credit line under every image), gates L3-6 and L3R2-1.
Fact (Oct 6): image blocks are built in `tools/content/markdown_portable_text.dart` from
`content/illustrations/assets.json`, which is not in the repository; it is written by
`tools/lesson_illustrations/upload_assets.dart` after an upload to Sanity (an external system).
Without it the export emits no image blocks, so no lesson image ships today. Of the seven committed
images, four have a `key` entry with `credit` in `content/illustrations/sources/*.yaml`; three
(reading comprehension) have none.
Tests first (`test/tools/markdown_portable_text_test.dart`): with an asset map entry whose
`creditKey` matches a sources `key`, the image block's `asset` carries `credit`; with no match, the
export drops that image block (no credit, no image) and logs the lesson path. Existing image tests (`markdown_portable_text_test.dart` "resolves image marker
by lesson and sequence" and the sparse-marker case) gain a matching credit entry; in the sparse-marker
case the second image loses its credit entry and becomes the drop case. Implement in
`tools/content/markdown_portable_text.dart` (it serves both export tools) and the sources loader
in `tools/content/lesson_asset_map.dart`.
Stop conditions: running `upload_assets.dart` or producing `assets.json` changes Sanity, so it waits
for Aedwon's approval (requested at the start of level 4). An image with no credit entry does not
ship (D-132: CC BY-SA needs the line): the export drops it, so the three reading-comprehension
images wait for source entries from the content track.
Checks: `flutter test test/tool test/tools` green; `dart run tools/build_content_export/build_content_export.dart "$TMPDIR/export.json"` exits 0.

## Task 5. Full checks and baseline

W0 changes no offline behavior; the offline posture (G-h-27: no connectivity banner, no blocking
spinner on local data, last entitlement snapshot kept) stays a rule every family keeps.
Run all required checks (SUBAGENTS Part 5) and `node --test` in `functions/`; paste outputs into
`docs/superpowers/plans/new-design/evidence/W0.md` with the commit SHA. Expect analyze to show only
the known `onReorder` info.

## Task 6. Signed content package (needs Aedwon's authorization)

Traceability: W0 contract "Content package"; L2 §7.
Precondition: Aedwon's explicit permission in chat to use the signing seed (requested with the
start of level 4). Follow `docs/content-key-access.md` exactly (scoped shell, EXIT trap, no
printing). Build with `tools/build_content_package` at the next release sequence; verify with
`tools/verify_content_package` (exit 0). Record hashes, not keys. Without permission: skip and
record; W1 and W3 may start on Task 5's baseline. This build is optional (gate L3-16): it only gives
Aedwon a device build with the merged QA content before W5. The release package is built once, in
W5 Task 1, after the last content change.
Later exam dates (P3, gate L3-17): when Aedwon supplies dates with sources, the lead edits
`content/exams/catalog.json` (the app reads it as an asset and the Functions build copies it),
runs `flutter test test/core/content test/tool` and `npm test` in `functions/`, and commits on the
integration branch. Any such change lands before W5 Task 1.

## Review and integration

GPT-6 Astra audit and the Opus lead's independent review of Tasks 2 to 4 (B7 as amended) before
W1, W3 and W6 start. Update STATUS and the
traceability level 3 column for W0 rows.
