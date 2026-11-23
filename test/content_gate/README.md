# Content gate, layer (a)

Runs every active item in a content export through the app's own code, with
an in-memory database, no network and no hosted calls. It collects every
failure (item id, check, cause) and fails once at the end with the full list.

## What it checks, and from which source

Source A is what students receive: the documents the upload packages
(`tools/upload_content/upload_content.mjs --out-dir`, which runs the upload's
own approval gate, lesson checks and packaging code in `functions/lib`). The
gate loads them through the real `ContentMirror` with a fake remote, then reads
them with the real `ContentRepository`, as the web app does. Source B is
`export.json`; it only feeds the catalog structure (exams, subjects, topics,
mock blueprints) into the packaging, and is not read by the gate directly.

- Sources the upload refuses (A): every source the uploader skips is a failure
  named by file (for example a lesson over the size limit or a YAML parse
  error). Items in a skipped source are not in the set, so they are not checked.
- Each question (A): its set loads and applies, exactly one correct choice,
  2 to 6 choices, unique choice ids, a stem, at least one exam tag, and a
  passage that loads when it names one.
- Grading (A) through `SubmitAnswer`: correct grades correct, a wrong choice
  grades wrong.
- The answer saves into a stored session, resumes from it, completes through
  `QuizCompletionCoordinator`, and the attempt rebuilds for review and results.
- The `question_answered` properties pass `assertPropertiesAllowed` and none is
  dropped.
- The server payload (`studySessionPayload`) passes the server's own limits,
  read from `functions/src/_answers.ts` and `content.ts`.
- Every question renders in the real `QuizQuestionViewer` and every lesson part
  in the real `ContentRenderer`, with no exception and no error widget (phone
  size, one item at a time).
- Every mock blueprint (A, from the catalog the mirror applied) fills every slot
  of every section from active items tagged for its exam, using the real
  `MockSampler` and pool provider. A short section the existing
  `mock-blueprint-topics` check already accepts is listed, not failed.

## Existing checks it reuses, not repeats

`question-id-limits`, `analytics-never-blocks`, `session-stored-order`,
`mock-blueprint-topics`, `bold-stem` and the content approval gate stay in
`dart run tool/checks/run_checks.dart`. The gate adds the runtime proof: the
analytics limit is exercised by the answer save above, and the mock check runs
the sampler against the loaded database.

## Run it

CI builds the served documents before the shards and sets
`PANTAS_CONTENT_SERVED` (see the "Package the content as the upload does" step
in `.github/workflows/ci.yml`). By hand:

```bash
npm ci --prefix functions && npm run build --prefix functions
dart run tools/build_content_export/build_content_export.dart build/export.json
mkdir -p build/served
node tools/upload_content/upload_content.mjs --root content \
  --export build/export.json --out-dir build/served --skip-invalid \
  2> build/served/invalid.txt
PANTAS_CONTENT_SERVED=$PWD/build/served flutter test test/content_gate
```

With `PANTAS_CONTENT_SERVED` unset the test does the packaging itself (needs
`node` and the functions build). `PANTAS_CONTENT_GATE_REPORT=<file>` writes a
markdown report with the failure count per exam.

## Another content tree

The exporter and the uploader take a root. The exporter needs, under that
root, `content/`, `tools/build_content_export/historical_v1.json` and
`tools/lesson_author/outline.json` (copy the last two from this repo):

```bash
dart run tools/build_content_export/build_content_export.dart out.json <root>
node tools/upload_content/upload_content.mjs --root <root>/content \
  --export out.json --out-dir served --skip-invalid 2> served/invalid.txt
PANTAS_CONTENT_SERVED=$PWD/served flutter test test/content_gate/content_gate_test.dart
```

## Proof it can fail

`content_gate_fixture_test.dart` writes a small set of served documents with one broken item
per check (no correct choice, two correct choices, a missing passage, a
101-character id, a mock slot that cannot fill) and asserts each is caught
and the good item stays clean.

## Not covered

- Pro-only wrong-choice notes: the gate loads the Free copy of each set.
- The native seed database (`assets/seed/content.db`, built from
  `export.json`): the web app never installs it (`SeedInstaller` on web
  throws), and the upload reads `export.json` only for catalog structure.
