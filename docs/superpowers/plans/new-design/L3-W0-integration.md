# L3 W0: integration (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 3c4569fd.
Level 2 plan: `L2-W0-integration.md` (gate passed Oct 6). Strategy B5, B6.
Base: `integration/new-design-r1` at 1f79d880. Executor: Opus (B7: W0 merge work). One worktree:
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
   validator 0, emdash 0, approved 0, noexams 0; `flutter test test/tool test/core/content` green.
5. Lesson-id check: every `content/questions/<s>/<t>/<l>.yaml` has `content/lessons/<s>/<t>/<l>.md`
   and `meta.subtopic == <l>` (script in the task's evidence). Expect 158 of 158.
Files: none edited (fast-forward). Push the branch.

## Task 2. JSON fields the design adds (app schema stays 25)

Traceability: W0 contract "Data layer", "Recorded-only data"; F-4, N-6, N3-1, N3-9, N4-5, N5-2.
Tests first (`test/core/storage/domain/attempt_json_test.dart`, `test/features/mock_exam/domain/mock_results_json_test.dart`):
- `AttemptItem` JSON with `mistakeTag: "other"` and `mistakeNote` round-trips.
- An unknown `mistakeTag` value (for example `"future"`) decodes as `null` instead of throwing
  (`@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)`), closing N3-9.
- Old JSON without the new fields decodes with them null.
- `MockAnswer` gains nullable `missReason` (`MissReason { misread, slipped, unknown, other }`),
  `blankReason` (`BlankReason { ranOutOfTime, skippedToReturn, didNotKnow, other }`), `reasonNote`;
  `SectionResult` gains `wrong` and `blank` (int, default 0 when absent). Old JSON decodes with
  defaults (N5-2: W0's models default; W4e's decoder reads them).
Implement in `lib/core/storage/domain/attempt.dart` and
`lib/features/mock_exam/domain/mock_results.dart` (declarations and JSON only; W4e fills values).
Sync: `attempt_mapper.dart` and `mock_attempt_mapper.dart` copy the JSON columns raw (checked Oct 6),
so no sync change; a test in `test/core/sync/` asserts a round-trip keeps the new fields.
Checks: the new tests, `flutter test test/core test/features/mock_exam`, `flutter analyze`.

## Task 3. Exam catalog (content schema 9 to 10)

Traceability: W0 contract "Exam catalog"; F-2, N-5, N-20, N3-7; tier spec B1; D-29, D-225.
Decision for N3-7: columns, not a JSON blob, so queries and tests stay typed:
`ContentExams` adds `priceTier` (text), `examGroup` (text), `comingSoon` (bool, default false);
new table `ContentExamSittings` (`examId`, `firstDay`, `lastDay`, `sourceUrl`, `ordering`).
Reader API: `ExamCatalogRepository` in `lib/core/content/data/` with
`Future<ExamCatalogEntry> entry(String examId)` and `Stream<List<ExamCatalogEntry>> watchAll()`;
`ExamCatalogEntry { id, name, shortName, priceTier, group, comingSoon, sittings }`.
Tests first: migration test 9 to 10 (existing rows get `comingSoon=false`, no sittings);
repository returns entries and sittings ordered; an exam with no sittings returns an empty list.
Implement: table changes, `schemaVersion => 10` with `onUpgrade` adding the columns and table in the
same commit; export tool (`tools/build_content_export/build_content_export.dart`) writes the new
fields from a new source file `content/exams/catalog.yaml`; the export also writes
`functions/src/examCatalog.json` (N-20).
`content/exams/catalog.yaml`: the seven roster exams plus the nine Coming soon exams (PSHS-NCE,
NAPOLCOM, AFPSAT, PMA, PNPA, PMMA, MAAP, LET, PNLE) with tier and group per pricing.md and
DECISIONS D-29, D-225. Sittings: only dates Aedwon supplies with a source link (tier spec decision 1).
Stop condition: no dates supplied yet: ship the file with empty `sittings` and record the gap; do
not infer a date. If O_Picker or ST_ExamPick shows an available exam missing from content: stop.
Checks: new tests, `flutter test test/core/content test/tool`, export round-trip test green.

## Task 4. Mock blueprint placeholder marker

Traceability: W0 contract "Mock blueprints"; F-15, N-21.
Tests first: the blueprint parser accepts a value written as `{ value: 40, placeholder: true,
placeholderNote: "..." }` and exposes `isPlaceholder`; plain values parse as before.
Implement in the blueprint parser (`lib/core/content/` mock blueprint model) and the export tool.
W4e writes the CSE and ACET blueprints later.
Checks: parser tests; existing `upcat.yaml` still parses.

## Task 5. Full checks and baseline

Run all required checks (SUBAGENTS Part 5) and `node --test` in `functions/`; paste outputs into
`docs/superpowers/plans/new-design/evidence/W0.md` with the commit SHA. Expect analyze to show only
the known `onReorder` info.

## Task 6. Signed content package (needs Aedwon's authorization)

Traceability: W0 contract "Content package"; L2 §7.
Precondition: Aedwon's explicit permission in chat to use the signing seed (requested with the
start of level 4). Follow `docs/content-key-access.md` exactly (scoped shell, EXIT trap, no
printing). Build with `tools/build_content_package` at the next release sequence; verify with
`tools/verify_content_package` (exit 0). Record hashes, not keys. Without permission: skip and
record; W1 and W3 may start on Task 5's baseline.

## Review and integration

Independent Opus code review of Tasks 2 to 4 (B7) before W1 and W3 start. Update STATUS and the
traceability level 3 column for W0 rows.
