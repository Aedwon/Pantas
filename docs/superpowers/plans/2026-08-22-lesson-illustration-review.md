# Lesson Illustration Review Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a local, digest-bound illustration approval workflow to Lesson Author for the 52 new code figures, four Commons assets, and three founder assets.

**Architecture:** A Flutter harness renders the real lesson figure widgets into light and dark review PNGs. A pure Node review module builds the 59-item catalog, computes current digests, and writes review state atomically. Lesson Author consumes that interface and shows each illustration inside its lesson.

**Tech Stack:** Flutter widget tests and PNG rendering, Node.js HTTP server and tests, browser HTML/CSS/JavaScript, JSON review state, Python completion audits.

**Spec:** `docs/superpowers/specs/2026-08-22-lesson-illustrations-completion-and-review-design.md`

## Global Constraints

- Run this plan after Tasks 1 through 6 of `2026-08-22-original-lesson-code-figures.md` pass.
- Review scope is exactly 59 keys: 52 `original-code-*` rows, four open rows, and three founder rows.
- Render code previews from the same Flutter figure widgets used by the app. Do not create a separate browser drawing implementation.
- Render both light and dark previews at a 390 logical-pixel lesson width.
- Bind approval to the current visual digest. A changed visual resets approval to pending.
- Missing founder files cannot be approved.
- Review writes only `docs/content/illustrations/review.json`. Review actions never edit lessons.
- The tool remains local. No network request, push, Sanity write, or upload.
- Keep the existing Lesson Author authoring flow intact.
- Use two Gemini 3.7 Flash High workers for each independent wave. Do not ask Aedwon for remaining Gemini usage.
- Gemini 3.1 Pro High verifies without editing. Codex owns interface integration, browser verification, and final checks.
- Commits and merges require explicit authorization. Never push.

---

### Task 1: Render exact light and dark previews

**Owner:** Gemini 3.7 Flash High worker A, Wave 7

**Files:**
- Create: `tools/lesson_author/illustration_preview_renderer.dart`
- Create: `tools/lesson_author/render_illustration_previews_test.dart`
- Create: `test/tools/lesson_illustration_preview_renderer_test.dart`

**Interfaces:**
- `findReviewFigureSpecs(Directory repositoryRoot) -> Map<String, Map<String, Object?>>`
- `renderReviewPreviews({required Directory repositoryRoot, required Directory outputRoot}) -> Future<ReviewPreviewManifest>`
- Output: `build/lesson_author/illustration_previews/manifest.json`
- Manifest entry: `key`, `lightPath`, `darkPath`, `digest`, `width`, and `height`.

- [ ] **Step 1: Write failing extraction tests.** Use temporary lessons with valid, duplicate, missing, and malformed `illustrationKey` fields. Require exactly one spec for every `original-code-*` key.

```dart
expect(
  specs['science/biology/cell-biology#1']?['kind'],
  'biology-diagram',
);
```

- [ ] **Step 2: Write a failing render test for one fixture.** Require two PNG signatures and a 64-character lowercase digest that changes when either PNG changes.

- [ ] **Step 3: Run the tests and confirm the renderer is absent.**

```bash
flutter test test/tools/lesson_illustration_preview_renderer_test.dart
```

- [ ] **Step 4: Implement marker extraction and exact widget rendering.** Wrap `LessonFigureWidget` in the production light or dark Pantas theme, constrain it to 390 logical pixels, capture a `RepaintBoundary`, and write PNG bytes under the build directory.

- [ ] **Step 5: Add the executable Flutter test entry.** It calls the renderer for the live repository, asserts 52 entries, and prints one stable summary.

```bash
flutter test tools/lesson_author/render_illustration_previews_test.dart --reporter compact
```

Expected: `52 figures, 104 previews, 0 render errors`.

- [ ] **Step 6: Run focused tests, analysis, and format checks.** Confirm no preview PNG is written outside `build/lesson_author/illustration_previews/`.

### Task 2: Build the review catalog and local server interfaces

**Owner:** Gemini 3.7 Flash High worker B, Wave 7

**Files:**
- Create: `tools/lesson_author/illustration_review.mjs`
- Create: `tools/lesson_author/illustration_review.test.mjs`
- Modify: `tools/lesson_author/server.mjs`
- Modify: `tools/lesson_author/package.json`
- Modify: `tools/lesson_author/package-lock.json`

**Interfaces:**
- `loadIllustrationCatalog({repoRoot, previewManifestPath}) -> Promise<{items, summary}>`
- `saveIllustrationReview({repoRoot, key, status, notes, observedDigest}) -> Promise<ReviewItem>`
- `GET /api/illustrations`
- `POST /api/illustration-review`
- `POST /api/illustration-previews/rebuild`
- `GET /api/illustration-preview?key=<key>&theme=light|dark`

- [ ] **Step 1: Write failing catalog tests.** Fixtures cover 52 original rows, four open rows, three missing founder rows, two reference manifests, two Commons manifests, and an empty review file.

```js
assert.deepEqual(catalog.summary, {
  total: 59,
  pending: 56,
  approved: 0,
  changesRequested: 0,
  missing: 3,
});
```

- [ ] **Step 2: Write failing state tests.** Cover approve, changes requested, notes, unknown key, invalid status, digest mismatch, stale approval after digest change, missing-file rejection, and atomic-write preservation after an injected failure.

- [ ] **Step 3: Run Node tests and confirm the review module is absent.**

```bash
node --test tools/lesson_author/illustration_review.test.mjs
```

- [ ] **Step 4: Implement the pure review module.** Add `yaml` version `^2.4.5`, matching Illustration Studio. Parse TSV and YAML without accepting paths from callers. Preserve notes on a stale item. Write sorted JSON through a temporary file and rename.

- [ ] **Step 5: Add server routes through the module interface.** Recompute the current digest before every review write. Allow only one preview-rebuild child process at a time. Return a plain error when the build fails.

- [ ] **Step 6: Serve previews by catalog key only.** Reject unknown keys, unknown themes, absolute paths, traversal segments, and manifest paths outside the build preview root.

- [ ] **Step 7: Add the package test command and run it.**

```json
{
  "scripts": {
    "start": "node server.mjs",
    "test": "node --test illustration_review.test.mjs"
  }
}
```

Expected: all Node tests pass and the existing lesson read and save routes behave unchanged.

### Task 3: Integrate the preview and review interfaces

**Owner:** Codex integration after Wave 7

**Files:**
- Modify only the files from Tasks 1 and 2 when interface corrections are required

- [ ] **Step 1: Inspect both worker diffs.** Reject extra paths and confirm neither worker touched the other's ownership.
- [ ] **Step 2: Run the preview build, then point the catalog at its real manifest.**
- [ ] **Step 3: Confirm all 52 code previews load by key in both themes.** Confirm the four Commons rows load their local files and the three founder rows report missing.
- [ ] **Step 4: Start Lesson Author with `--no-open` and exercise every local interface through HTTP.** Stop the server after the checks.
- [ ] **Step 5: Run both test suites again after integration.**

### Task 4: Add Illustration Review mode to Lesson Author

**Owner:** Gemini 3.7 Flash High worker A, Wave 8

**Files:**
- Create: `tools/lesson_author/public/illustration_review.mjs`
- Create: `tools/lesson_author/illustration_review_ui.test.mjs`
- Modify: `tools/lesson_author/public/index.html`
- Modify: `tools/lesson_author/server.mjs` only to serve the new static module
- Modify: `tools/lesson_author/package.json`

**Interfaces:**
- The browser module consumes only the four local HTTP interfaces from Task 2.
- It exports pure `filterReviewItems`, `reviewProgress`, and `effectiveReviewStatus` functions for Node tests.

- [ ] **Step 1: Write failing pure UI-model tests.** Cover the four filters, missing precedence, stale approval, next and previous queue order, and progress counts.

- [ ] **Step 2: Run the test and confirm the browser module is absent.**

```bash
node --test tools/lesson_author/illustration_review_ui.test.mjs
```

- [ ] **Step 3: Add an Author and Illustration review mode switch.** Author mode must retain its current layout and behavior.

- [ ] **Step 4: Add the review queue.** Show Pending, Needs changes, Approved, and Missing filters with counts. Selecting an item changes the current lesson and scrolls to its marker.

- [ ] **Step 5: Insert the current illustration into the lesson preview.** For code figures, show light and dark renders together on wide screens and a theme toggle on narrow screens. For open and founder assets, show the local PNG on both lesson backgrounds.

- [ ] **Step 6: Add the evidence panel.** Show the frozen brief and factual references for original figures. Show creator, source, license, credit, and modification details for Commons assets. Show Pantas ownership for founder assets.

- [ ] **Step 7: Add review controls.** Approve and Needs changes send the currently observed digest. Save notes with the selected status. On a 409 digest mismatch, reload the item and show that the preview changed.

- [ ] **Step 8: Add Refresh previews.** Disable it while the server builds. Reload the catalog after success. Preserve the selected key.

- [ ] **Step 9: Run Node tests and confirm author mode still loads, edits, drafts, navigates, and saves lessons.**

Update the final package test command to run both suites:

```json
"test": "node --test illustration_review.test.mjs illustration_review_ui.test.mjs"
```

### Task 5: Add review-ready and complete audit gates

**Owner:** Gemini 3.7 Flash High worker B, Wave 8

**Files:**
- Modify: `tools/audit/check_lesson_illustrations.py`
- Modify: `test/tools/check_lesson_illustrations_test.dart`
- Create: `docs/content/illustrations/review.json`

**Interfaces:**
- `--phase review-ready` allows missing founder files but requires all other local work.
- `--phase complete` requires all 59 current digests to be approved.

- [ ] **Step 1: Write failing `review-ready` fixtures.** Require 241 valid figures, seven image markers, four Commons PNGs, 52 two-theme previews, and 59 catalog keys. Prove one missing preview fails. Prove three missing founder files are reported without failing.

- [ ] **Step 2: Write failing `complete` fixtures.** Cover all approved, pending, needs changes, stale digest, missing founder file, and an extra unknown review key.

- [ ] **Step 3: Run the focused tests and confirm both phases are absent.**

```bash
flutter test test/tools/check_lesson_illustrations_test.dart
```

- [ ] **Step 4: Implement the two phases without weakening inventory checks.** Recompute every preview digest from the current light and dark PNG hashes before accepting review state. The initial production review file contains version 1 and no fabricated approval.

```json
{
  "version": 1,
  "items": {}
}
```

- [ ] **Step 5: Run the focused tests and the live review-ready gate.**

```bash
flutter test test/tools/check_lesson_illustrations_test.dart
python3 tools/audit/check_lesson_illustrations.py --phase review-ready
```

Expected: tests pass. The live gate reports 52 code previews ready, four Commons files ready, and three founder files missing.

### Task 6: Pro verification of Waves 7 and 8

**Owner:** Gemini 3.1 Pro High, read-only

- [ ] Read the supplemental spec, both plans, all worker reports, and every changed file.
- [ ] Confirm preview PNGs come from production Flutter widgets, not a browser reimplementation.
- [ ] Confirm the digest covers both light and dark bytes and stale approvals cannot pass.
- [ ] Test path traversal, unknown keys, concurrent rebuilds, malformed review JSON, and interrupted atomic writes.
- [ ] Confirm author mode behavior remains intact.
- [ ] Run the Flutter, Node, audit, analysis, format, layering, and attribution commands from the plan.
- [ ] Report findings only. Do not edit.

### Task 7: Codex final local verification and Aedwon handoff

**Owner:** Codex

- [ ] Resolve every Pro finding through the original owner and rerun the affected verification.
- [ ] Run the full test suite and record its exact count.
- [ ] Run analyzer and separate new findings from the measured demo and mock baseline.
- [ ] Run both seed builders only as far as local unresolved image mapping permits. Do not invent CDN URLs.
- [ ] Run `inventory`, `review-ready`, lesson audits, formatting, layering, and attribution checks.
- [ ] Use the local browser to verify mode switching, queue filters, lesson jumps, light and dark previews, notes, digest conflicts, and author-mode regression.
- [ ] Give Aedwon the existing Lesson Author launcher and ask him to review all 59 items. Do not take emulator screenshots or approve anything for him.
- [ ] After Aedwon supplies the three founder files, rerun preview generation and keep those items pending for his review.
- [ ] `complete` may pass only after Aedwon approves every current digest.
- [ ] Do not push or upload to Sanity. A later explicit authorization is required for the four Commons and three founder uploads.
