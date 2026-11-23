# Content gate, layer (a)

Runs every active item in a content export through the app's own code, with
an in-memory database, no network and no hosted calls. It collects every
failure (item id, check, cause) and fails once at the end with the full list.

## What it checks

- Every document maps with the app's parsers (exam, subject, topic, passage,
  question, lesson part, mock blueprint). A document that does not map is named.
- Each question: exactly one correct choice, 2 to 6 choices, unique choice ids,
  a stem, at least one exam tag, and a passage that loads when it names one.
- Grading through `SubmitAnswer`: the correct choice grades correct, a wrong
  choice grades wrong.
- The answer saves into a stored session, resumes from it, completes through
  `QuizCompletionCoordinator`, and the attempt rebuilds for review and results.
- The `question_answered` properties pass `assertPropertiesAllowed` and none is
  dropped.
- The server payload (`studySessionPayload`) passes the server's own limits.
  The limits are read from `functions/src/_answers.ts` and `content.ts`.
- Every question renders in the real `QuizQuestionViewer` and every lesson part
  in the real `ContentRenderer`, with no exception and no error widget (phone
  size, one item at a time).
- Every mock blueprint fills every slot of every section, from active items
  tagged for its exam, using the real `MockSampler` and the real pool provider.

## Existing checks it reuses, not repeats

`question-id-limits`, `analytics-never-blocks`, `session-stored-order`,
`mock-blueprint-topics`, `bold-stem` and the content approval gate stay in
`dart run tool/checks/run_checks.dart`. The gate adds the runtime proof: the
analytics limit is exercised by the answer save above, and the mock check runs
the sampler against the loaded database.

## Run it

```bash
dart run tools/build_content_export/build_content_export.dart build/export.json
PANTAS_CONTENT_EXPORT=$PWD/build/export.json flutter test test/content_gate
```

CI sets `PANTAS_CONTENT_EXPORT`. With it unset the test builds an export from
this tree. Set `PANTAS_CONTENT_GATE_REPORT=<file>` to also write a markdown
report with the failure count per exam.

## Another content tree

The exporter takes a root with a `content/` folder, plus
`tools/build_content_export/historical_v1.json` and
`tools/lesson_author/outline.json` under that root (copy them from this repo):

```bash
dart run tools/build_content_export/build_content_export.dart out.json <root>
PANTAS_CONTENT_EXPORT=out.json flutter test test/content_gate/content_gate_test.dart
```

## Proof it can fail

`content_gate_fixture_test.dart` builds a small export with one broken item
per check (no correct choice, two correct choices, a missing passage, a
101-character id, a mock slot that cannot fill) and asserts each is caught
and the good item stays clean.

## Not covered

Items served at run time by the server (`getContent`, the mirror path) are not
in the export, so their server-side build is not exercised. Only the bundled
path is.
