# Content 01: the corpus becomes the content database

**Plan, 11 August 2026.** Stage 1 of `specs/2026-08-11-content-path-and-the-mock.md`.

> **Required reading before Task 1:** `AGENTS.md` in full, then Sections 2, 4.1
> and 4.2 of the spec above, then `tools/build_dev_seed/build_dev_seed.dart`
> from the top of the file to the end of `main`.

**If what you find disagrees with this plan, stop and say so** rather than
inventing a solution. The counts in this plan were taken from the running
repository and are the check on your work: if yours differ, one of us is wrong
and it matters which.

---

## What this stage does, and what it deliberately does not

**Does:** makes `assets/seed/content.db` carry the real corpus, by having the
authored content under `content/` emit Sanity-shaped documents that
`tools/build_content_seed/seed_writer.dart` already knows how to read.

**Does not:** change a single screen. Nothing reads the content database after
this stage that did not read it before. **The app must behave identically when
you are finished**, which is the point: this stage is verifiable by counting
rows, not by looking at a phone.

**Does not:** touch `assets/seed/v1.json` or its generator. Both keep working
and keep being what the app runs on until Stage 2.

---

## Global constraints

- **Never run `flutter test` with no arguments, `flutter analyze`, or
  `dart run build_runner`.** You may run a single test file. **The full gate
  set is run for you after you finish.** Never use `&`, `nohup`, or any
  background mechanism.
- **Work only inside your worktree.** Run `pwd` before your first write.
- **Commit the moment a task's own test passes**, before starting the next.
- **No em dashes.** American spelling.
- **Do not edit `test/fixtures/sanity/content_sample.json`.** It is a unit
  test's fixture and three tests depend on its exact contents.

### Gate command

```bash
flutter test test/tool/ test/core/content/
```

---

## The facts this plan rests on

Taken from the repository on 11 August 2026. **Re-derive them before you
start**; if a number moved, say so.

| | Value |
|---|---|
| `assets/seed/v1.json` questions | 2,000 |
| lessons | 144 |
| topics | 19 |
| exams | 7, of which UPCAT and CSE Professional carry subjects |
| `assets/seed/content.db`, **built fresh from the fixture** | 1 exam, 1 topic, **1 question**, **1 blueprint** |
| that blueprint | `blueprint_cse`, exam `exam_cse`, "CSE Practice", 90 minutes |
| what CI builds it from | `test/fixtures/sanity/content_sample.json` |

**An earlier version of this plan said 16 questions and 0 blueprints.** Those
came from a stale `content.db` sitting in one working tree, dated 20 July. **The
file is gitignored, so a fresh checkout has none**, and what the pipeline
actually produces is the row above. The first run of this plan stopped and said
so, which is what it was asked to do and why the numbers are right now.

**The fixture's one blueprint is not a usable paper.** It is keyed to `exam_cse`,
which is not an exam the app ships: the seed carries `exam_cse_pro`. Nothing
about the conclusion changes, and the evidence is stronger than it was.

**Id convention is underscores** and does not change: `exam_upcat`,
`topic_upcat_algebra`, `subj_upcat_mathematics`. The hyphenated ids in the
fixture are the fixture's business. **Spec Section 4.2 explains why this is not
a preference**, and a student's stored attempts are the reason.

---

## Task 1: A writer that emits Sanity documents from the corpus

**Files:**
- Create: `tools/build_content_export/build_content_export.dart`
- Test: `test/tool/build_content_export_test.dart`

**It reads the same sources `build_dev_seed` reads** (the outline, the question
YAML under `content/questions/`, the lesson markdown under `content/lessons/`)
and writes one JSON file in the shape `seed_writer.dart` accepts: a top level
object whose keys are doc types, each a list of documents.

```
{ "exam": [...], "subject": [...], "topic": [...],
  "question": [...], "lesson": [...], "mockBlueprint": [] }
```

**Every document carries `_id`, `_updatedAt`, `schemaVersion` and `isActive`.**
The parsers check the schema version and throw on a mismatch; all eight types
are currently version 1, in `lib/core/content/sanity/schema_versions.dart`.

**A question document** carries `topic` and `examIds` as references, `language`,
`version`, `stem` and `explanation` as Portable Text, and its choices with
`_key`, `label`, `text` and `isCorrect`. Read `parsers/question_parser.dart`
for the exact field names rather than trusting this summary.

**`_updatedAt` must be stable across runs for unchanged content.** Deriving it
from the wall clock makes every build look like every document changed, which
defeats the incremental sync this pipeline exists to allow later. Use the
source file's modification time, or a content hash, and say which you chose.

**Test:** run the writer against a two-question fixture and assert the output
parses through the real parsers without throwing.

---

## Task 2: The export builds an openable database with the whole corpus

**Files:**
- Test: `test/tool/content_export_roundtrip_test.dart`

Run the writer, feed its output to `seed_writer.dart`, open the result and
count. **The test asserts the counts above**, not "greater than zero": a
pipeline that silently drops 1,900 questions passes a "not empty" check.

**Assert the ids are underscored**, by reading one exam id back and matching
`exam_upcat`.

---

## Task 3: CI builds the asset from the corpus, not from the fixture

**Files:**
- Modify: `.github/workflows/ci.yml`, `main.yml`, `release.yml`

All three currently run `seed_writer.dart test/fixtures/sanity/content_sample.json`.
They run the export first and feed it that instead.

**Keep the comment explaining why the asset is built and never committed**, and
update it: it currently says the fixture is the same one a test uses, which
stops being the reason.

**`assets/seed/content.db` stays gitignored.** Do not commit it.

---

## Task 4: The local instructions say how to build it

**Files:**
- Modify: `AGENTS.md`

Its "Two content paths" landmine says `content.db` is not declared in
`pubspec.yaml` and `SeedInstaller` has no callers. **Both are now false**: it is
declared at line 101 and installed from `bootstrap`. Correct it, and add the
two commands that build each asset.

---

## Done when

- The export runs and `seed_writer` builds a database holding **2,000
  questions, 144 lessons, 19 topics**.
- The gate command passes.
- The app still runs from `v1.json` and behaves exactly as before.
