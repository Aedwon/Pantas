# Content 02: the app reads the content database

**Plan, 11 August 2026.** Stage 2 of `specs/2026-08-11-content-path-and-the-mock.md`.

> **Required reading before Task 1:** `AGENTS.md`, then Sections 4.1 and 4.2 of
> the spec, then `lib/core/content/content.dart` in full, then
> `lib/core/storage/data/repos/content_repository.dart`.

**Content 01 and 01b must be merged first.** Both are, as of 11 August. The
content database now carries **2,000 questions, 144 lessons, 19 topics and 32
passages**, and a question carries its lesson, its passage and its short label.

**Task 1's inventory is already written**, at
`docs/superpowers/2026-08-11-content-reader-inventory.md`. Read it, check it is
still true, and extend it rather than starting again.

**Two mappings this plan now names, because two attempts stopped on them.**

- **`isWithdrawn` against `isActive`.** The app's questions table carries
  `isWithdrawn`; the content schema carries `isActive`. They are the same fact
  inverted. **Map it, do not stop on it**, and write the inversion down where
  you map it.
- **`ordering` on lessons.** Added to the content schema on 11 August, after the
  second attempt found the app sorts every lesson list by it.

**The gap that stopped the first attempt is closed.** `content_passages`
exists, and `content_questions` has `lesson_id`, `passage_id` and
`short_label`. **`short_label` is null everywhere**, because the corpus carries
none: that is expected, not a missing mapping.

**Stop and say so if the two schemas disagree in a way this plan does not
name.** A silent adapter that returns an empty list where a field is missing is
the failure mode to avoid: the app would look fine and teach nothing.

---

## What this stage does

**Every screen reads `ContentDatabase` instead of `AppDatabase`'s content
tables.** User data does not move: attempts, review state, lesson progress,
settings and preferences stay exactly where they are.

**This is the stage that can lose a student's history if done carelessly**, so
the constraint from Section 4.2 governs everything below: **question ids, topic
ids and lesson ids do not change.**

---

## Global constraints

- **Never run `flutter test` with no arguments, `flutter analyze`, or
  `dart run build_runner`.** You may run a single test file. **The full gate
  set is run for you after you finish.** Never use `&`, `nohup`, or any
  background mechanism.
- **Work only inside your worktree.** Run `pwd` before your first write.
- **Commit the moment a task's own test passes.**
- **No em dashes.** American spelling.
- **Do not change any id.** If a mapping seems to require it, stop.

### Gate command

```bash
flutter test test/core/storage/ test/features/lesson/ test/features/quiz/ test/features/progress/
```

---

## Task 1: Name every reader

**Files:**
- Create: `docs/superpowers/2026-08-11-content-reader-inventory.md`

**Before moving anything, list what reads content.** Walk
`ContentRepository`'s public methods and record every call site: the method,
the feature, and what it returns.

**This is a deliverable, not a warm-up.** The next four tasks are scoped by it,
and a reader missed here is a screen that goes blank in Stage 3.

Known readers at the time of writing, to check rather than to trust:
`content_repository.dart` serves the reader, the study map, the quiz pickers,
the assessment, the debrief and the performance table.

---

## Task 2: The content repository reads the content database

**Files:**
- Modify: `lib/core/storage/data/repos/content_repository.dart`
- Test: `test/core/storage/repos/content_repository_test.dart`

**Keep the repository's public API exactly as it is.** Its callers do not
change in this task; only where it reads from does. That is what makes this
reversible and what keeps the diff readable.

**`questionsByIds` was added on 11 August** and matters here: the debrief reads
every question of an attempt in one query, and losing that on the way across
would reintroduce a 480-query screen. Its test must still pass.

**Where the two schemas differ, adapt in this file and comment why.** The
content schema stores Portable Text as JSON and the app schema stores the same
thing; if a field has no counterpart, stop and report rather than defaulting.

---

## Task 3: The providers point at the content database

**Files:**
- Modify: `lib/core/storage/storage.dart`
- Modify: `lib/app/bootstrap.dart`

`contentRepositoryProvider` builds its repository from `appDatabaseProvider`
today. It builds from `contentDatabaseProvider` after this task.

**`bootstrap` already installs the bundled database** through `SeedInstaller`
and already overrides `contentDatabaseProvider` through
`bootstrapContentOverrides`. Read both before changing either.

**The seeder that fills `AppDatabase` from `v1.json` stops running.** Leave the
code in place and stop calling it; deleting it belongs to the task below, after
the app has been seen working.

---

## Task 4: The asset stops shipping

**Files:**
- Modify: `pubspec.yaml`
- Modify: `tools/build_dev_seed/build_dev_seed.dart`

Remove `assets/seed/v1.json` from the bundle. **Do not delete the file or its
generator yet**: Stage 3 wants a known-good corpus to compare against, and the
export in Content 01 reads the same sources.

**Mark the generator superseded in its own header comment**, which currently
tells the reader it is the shipping path.

---

## Task 5: The tests that named the old path

**Files:**
- Modify: whatever Task 1's inventory turned up

Several tests build an `AppDatabase` and insert content rows directly. **They
move to building a `ContentDatabase`**, not to being deleted. A test deleted
here is coverage of the thing most likely to break.

---

## Done when

- The app runs with `v1.json` absent from `pubspec.yaml`, showing the same
  2,000 questions and 144 lessons.
- **A student's existing attempts still resolve to their questions.** Verify
  on the device with an account that has history, not on a fresh install.
- The gate command passes.
