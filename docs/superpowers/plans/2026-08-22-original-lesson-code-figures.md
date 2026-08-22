# Original Lesson Code Figures Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the 52 blocked open-asset lesson markers with exact original Flutter code figures and retain the four verified Commons assets.

**Architecture:** The 52 rows move from `open` to `code` and use six domain painter modules behind the existing `FigureRegistry` seam. Each marker carries a stable `illustrationKey`. Two factual-reference manifests support verification without turning references into image credits.

**Tech Stack:** Flutter `CustomPainter`, Dart, Markdown `FIGURE` markers, YAML factual-reference manifests, Python audits, existing PNG metadata and upload tools.

**Spec:** `docs/superpowers/specs/2026-08-22-lesson-illustrations-completion-and-review-design.md`

## Global Constraints

- Read `AGENTS.md`, `SUBAGENTS.md`, the supplemental spec, the original illustration spec, the original plan, and the completion decision log in full before editing.
- Exact totals become `code=241 open=4 native=23 cut=8 founder=3`, total 279.
- Keep the four open keys named in the supplemental spec. Reclassify the other 52 former open rows as code.
- Preserve every frozen description. Do not add a label, value, percentage, or relationship that the marker or lesson does not state.
- Draw original compositions. Do not trace or reconstruct a third-party diagram.
- Factual reference URLs are evidence, not image credits. Commons assets retain their exact license-required credits.
- Keep `FigureRegistry.build(Map<String, Object?>)` as the only dispatch seam.
- Each new marker includes its exact `illustrationKey`.
- Use Source Sans 3 and the current theme colors. No shadows, large radii, decorative color, or hardcoded black and white.
- No new Flutter package. Never edit generated Dart files. Ignore demo work.
- Aedwon waived further Gemini-usage questions for this work. Run two Gemini 3.7 Flash High workers when their ownership is isolated. Gemini 3.1 Pro High verifies without editing.
- Codex owns strategy changes, shared interfaces, registry integration, conflict rulings, and final verification.
- Commits and merges still require explicit authorization. Never push. Never upload to Sanity under this plan.

## Current Baseline

- Local `main` is at `e9837a42` and is clean when this plan was written.
- The original code, native, and cut waves are on `main`.
- Four Pro-verified Commons assets remain isolated in `codex/lesson-illus-w5a` and `codex/lesson-illus-w5b`.
- The live worklist contains 59 unresolved `ILLUSTRATION` markers: 52 rows that this plan converts to code, four Commons rows, and three founder rows.
- Focused figure tests pass. The full suite has 2,387 passing tests. Analyzer has 103 existing demo and mock findings.

---

### Task 1: Revise the frozen strategy and audit contract

**Owner:** Codex architecture and integration

**Files:**
- Modify: `docs/content/illustrations/strategy.tsv`
- Modify: `tools/audit/check_lesson_illustrations.py`
- Modify: `tools/audit/list_illustrations.py`
- Modify: `test/tools/check_lesson_illustrations_test.dart`

**Interfaces:**
- Produces exact totals `241/4/23/8/3`.
- Produces two isolated batches: `original-code-a` with 27 keys and `original-code-b` with 25 keys.
- Keeps `inventory` compatible with the future `review-ready` and `complete` phases from the review plan.

- [ ] **Step 1: Change the production-total test first.** Expect the exact revised line.

```dart
expect(
  result.stdout.toString(),
  contains('total=279 code=241 open=4 native=23 cut=8 founder=3'),
);
```

- [ ] **Step 2: Add a regression test for the exact four open keys.** Parse the production TSV and assert that its `open` keys equal the four-key set in the supplemental spec.

- [ ] **Step 3: Run the focused test and confirm it fails on the old `189/56` contract.**

```bash
flutter test test/tools/check_lesson_illustrations_test.dart
```

- [ ] **Step 4: Reclassify the exact 52 rows.** Assign Reading, Biology, Chemistry, and Physics Mechanics to `original-code-a`. Assign Earth Science and Physics Energy to `original-code-b`. Leave the four accepted Commons rows in their current open batches.

- [ ] **Step 5: Update the checker totals, messages, and known kinds.** Add the six planned figure kinds. Do not weaken duplicate, missing-key, lesson-placement, or unknown-kind checks.

```python
EXPECTED_TOTALS = {
    "code": 241,
    "open": 4,
    "native": 23,
    "cut": 8,
    "founder": 3,
}
```

- [ ] **Step 6: Update the worklist summary.** When `strategy.tsv` exists, print the revised totals without adding a generated strategy column to `worklist.tsv`.

- [ ] **Step 7: Run the focused tests and live inventory.**

```bash
flutter test test/tools/check_lesson_illustrations_test.dart
python3 tools/audit/check_lesson_illustrations.py --phase inventory
```

Expected: both pass and the live command prints the revised exact totals.

### Task 2: Draw Reading, Biology, Chemistry, and Physics Mechanics

**Owner:** Gemini 3.7 Flash High worker A, Wave 6

**Files:**
- Create: `lib/core/ui/figures/reading_diagram_figure.dart`
- Create: `lib/core/ui/figures/biology_diagram_figure.dart`
- Create: `lib/core/ui/figures/chemistry_diagram_figure.dart`
- Create: `lib/core/ui/figures/physics_mechanics_diagram_figure.dart`
- Create: `test/core/ui/figures/lesson_original_code_a_test.dart`
- Create: `docs/content/illustrations/original-code-a.yaml`
- Modify: only lesson Markdown files for the 27 `original-code-a` strategy rows

**Interfaces:**
- Each painter exposes `static const kind` and `static <Class>? fromSpec(Map<String, Object?> spec)`.
- Every owned marker carries `illustrationKey`, `kind`, `type`, and its complete frozen data.
- The reference manifest contains exactly the 27 owned keys.

- [ ] **Step 1: Read every owned marker in lesson context.** Record the exact 27 keys in the worker report. Stop if the batch count differs.

- [ ] **Step 2: Write data-driven failing parser tests.** Include one case per key. Assert that the exact future JSON resolves to the expected module and that deleting a required field returns null.

```dart
final figure = BiologyDiagramFigure.fromSpec(const <String, Object?>{
  'kind': 'biology-diagram',
  'type': 'cell-protein-flow',
  'illustrationKey': 'science/biology/cell-biology#1',
  'labels': <String>['nucleus', 'mitochondria', 'ribosomes', 'rough ER', 'smooth ER', 'Golgi apparatus'],
});
expect(figure, isNotNull);
```

- [ ] **Step 3: Run the owned test and confirm the four modules are absent.**

```bash
flutter test test/core/ui/figures/lesson_original_code_a_test.dart
```

- [ ] **Step 4: Implement the four deep painter modules.** Keep each module's variant validation and drawing implementation private. Do not edit the registry.

- [ ] **Step 5: Replace the 27 owned markers.** Use one-line JSON. Preserve the original marker's position. Do not rewrite neighboring lesson prose.

- [ ] **Step 6: Add authoritative factual references.** Use primary agencies, universities, or established open textbooks. Each entry follows this shape:

```yaml
version: 1
figures:
  - key: science/biology/cell-biology#1
    references:
      - title: Cell structure reference
        publisher: OpenStax
        url: https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells
```

- [ ] **Step 7: Run the owned tests, audit, analysis, and format check.**

```bash
flutter test test/core/ui/figures/lesson_original_code_a_test.dart
python3 tools/audit/check_lesson_illustrations.py --phase inventory
python3 tools/audit/run_all.py
flutter analyze lib/core/ui/figures test/core/ui/figures/lesson_original_code_a_test.dart
dart format --output=none --set-exit-if-changed lib/core/ui/figures test/core/ui/figures/lesson_original_code_a_test.dart
```

Expected: the owned tests pass, 27 owned `ILLUSTRATION` markers are gone, and no unrelated file changed.

### Task 3: Draw Earth Science and Physics Energy

**Owner:** Gemini 3.7 Flash High worker B, Wave 6

**Files:**
- Create: `lib/core/ui/figures/earth_science_diagram_figure.dart`
- Create: `lib/core/ui/figures/physics_energy_diagram_figure.dart`
- Create: `test/core/ui/figures/lesson_original_code_b_test.dart`
- Create: `docs/content/illustrations/original-code-b.yaml`
- Modify: only lesson Markdown files for the 25 `original-code-b` strategy rows

**Interfaces:**
- Same module and marker interfaces as Task 2.
- The reference manifest contains exactly the 25 owned keys.

- [ ] **Step 1: Read every owned marker in lesson context.** Record the exact 25 keys. Stop if the batch count differs.

- [ ] **Step 2: Write one failing data-driven case per key.** Include required-field rejection for every `type` variant.

```dart
final figure = EarthScienceDiagramFigure.fromSpec(const <String, Object?>{
  'kind': 'earth-science-diagram',
  'type': 'seasonal-orbit',
  'illustrationKey': 'science/earth-science-astronomy/earths-motions#1',
  'earthPositions': 4,
  'axisDirection': 'constant',
});
expect(figure, isNotNull);
```

- [ ] **Step 3: Run the owned test and confirm the modules are absent.**

```bash
flutter test test/core/ui/figures/lesson_original_code_b_test.dart
```

- [ ] **Step 4: Implement the two deep painter modules.** Do not edit the registry or Worker A files.

- [ ] **Step 5: Replace the 25 owned markers and add the factual-reference manifest.** Keep lesson prose unchanged.

- [ ] **Step 6: Run the owned tests, audit, analysis, and format check.**

```bash
flutter test test/core/ui/figures/lesson_original_code_b_test.dart
python3 tools/audit/check_lesson_illustrations.py --phase inventory
python3 tools/audit/run_all.py
flutter analyze lib/core/ui/figures test/core/ui/figures/lesson_original_code_b_test.dart
dart format --output=none --set-exit-if-changed lib/core/ui/figures test/core/ui/figures/lesson_original_code_b_test.dart
```

Expected: the owned tests pass, 25 owned `ILLUSTRATION` markers are gone, and no unrelated file changed.

### Task 4: Integrate the six new figure kinds

**Owner:** Codex integration after both Wave 6 workers finish

**Files:**
- Modify: `lib/core/ui/figures/figure_registry.dart`
- Modify: `lib/core/ui/figures/lesson_figure_widget.dart` only if the existing interface cannot preserve the semantics label
- Modify: `test/core/ui/figures/lesson_figure_widget_test.dart`

**Interfaces:**
- `FigureRegistry.build` remains the only dispatcher.
- The six new `kind` values resolve without exposing their variants to callers.

- [ ] **Step 1: Inspect both worker diffs and reject overlap or extra files.** Confirm counts 27 and 25 before integration.

- [ ] **Step 2: Add failing registry cases for all six new kinds and for an unknown kind.**

- [ ] **Step 3: Run the focused tests and confirm only registry dispatch fails.**

```bash
flutter test test/core/ui/figures/lesson_figure_widget_test.dart test/core/ui/figures/lesson_original_code_a_test.dart test/core/ui/figures/lesson_original_code_b_test.dart
```

- [ ] **Step 4: Add the six imports and switch arms.** Do not add a second dispatcher.

- [ ] **Step 5: Run focused tests, analysis, formatting, layering, and attribution checks.**

```bash
flutter test test/core/ui/figures
flutter analyze lib/core/ui/figures test/core/ui/figures
dart format --output=none --set-exit-if-changed lib/core/ui/figures test/core/ui/figures
dart run tool/check_layering.dart
dart run tool/check_no_ai_attribution.dart
```

### Task 5: Integrate the four verified Commons assets

**Owner:** Codex integration

**Files:**
- Create: the two accepted PNGs and `open-a.yaml` from `codex/lesson-illus-w5a`
- Create: the two accepted PNGs and `open-b.yaml` from `codex/lesson-illus-w5b`

**Interfaces:**
- `loadOpenStrategy` sees exactly four open keys.
- The uploader dry-run reports four ready files and no missing open file.

- [ ] **Step 1: Compare the four files and two manifests to the final Pro report.** Do not restore any deleted or rejected asset.

- [ ] **Step 2: Bring only the four PNGs and two final manifests into the integration worktree.** Preserve their byte digests.

- [ ] **Step 3: Run metadata, uploader, and digest tests.**

```bash
node --test tools/illustration_studio/open_asset_metadata.test.mjs
flutter test test/tools/upload_lesson_assets_test.dart
dart run tools/lesson_illustrations/upload_assets.dart --dry-run --strategy open
```

Expected dry-run: `4 ready, 0 missing, 0 writes, 0 unchanged, 0 replaced`.

### Task 6: Pro verification of Wave 6 and the four Commons assets

**Owner:** Gemini 3.1 Pro High, read-only

- [ ] Read both specs, this plan, both Flash reports, the 52 original descriptions, and the final Wave 5 source report.
- [ ] Inspect all 52 marker specs against their original marker and lesson context.
- [ ] Confirm every stated label and relationship is present. Report every invented value or label.
- [ ] Open every factual-reference URL and confirm it supports the relevant diagram.
- [ ] Confirm no painter traces or reproduces a third-party composition.
- [ ] Validate the four Commons source pages, licenses, credits, digests, and PNG metadata.
- [ ] Run all commands from Tasks 1 through 5 and paste raw output.
- [ ] Report findings only. Do not edit.

### Task 7: Codex local acceptance for the figure plan

**Owner:** Codex

- [ ] Rule on every Pro finding. Send corrections back to the owning Flash worker and rerun Pro verification for changed rows.
- [ ] Run the complete focused figure suite, full test suite, analyzer, format check, audits, layering, and attribution gate.
- [ ] Confirm the repository has 241 `FIGURE` markers and seven `ILLUSTRATION` markers.
- [ ] Confirm the 52 new figures have not produced or uploaded any third-party asset.
- [ ] Continue to the Lesson Author review plan. Do not call the illustration work complete before Aedwon's digest-bound review.
- [ ] Do not push or upload to Sanity.
