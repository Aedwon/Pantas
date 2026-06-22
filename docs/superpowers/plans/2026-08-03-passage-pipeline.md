# The passage pipeline: let a text be shared by several questions

> **How to work this plan.** Implement it task by task, in order. For each task: write the
> failing test first, run it and confirm it fails, then write the code that makes it pass. Do
> not skip a step and do not batch tasks.
>
> **Required reading before Task 1:** `AGENTS.md` at the repository root in full,
> `SUBAGENTS.md`, and `docs/superpowers/specs/2026-08-03-passage-based-questions-design.md`
> end to end. **Section 3 is the rule that ripples furthest** and Task 4 exists only because
> of it.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous or looks wrong, **stop and say
> so.**
>
> **Analyzer baseline:** `flutter analyze` reports **27 issues** on a clean tree, every one
> under `tools/` or `test/tool/`. `lib/` is clean. Any issue under `lib/` or `test/` is one
> you introduced.
>
> **Work only inside your worktree.** Never write to the main checkout.

**Goal:** Make a passage a first-class content entity so reading comprehension can ship, with
questions that share a text traveling together through every surface that serves them.

**Architecture:** A `Passages` table beside `Questions`, a nullable `passageId` on `Questions`,
a `passages:` block in the question YAML, and one rule in the session builder and the mock
sampler: a passage set is indivisible.

**Tech Stack:** Dart, Drift, Flutter, Riverpod, `flutter_test`. No new packages.

**Source spec:** `docs/superpowers/specs/2026-08-03-passage-based-questions-design.md`.

## Global Constraints

- **No new dependencies.**
- **Generated files (`*.g.dart`) are never edited by hand and never committed.**
- **`passageId` is nullable and most questions never have one.** No existing behavior changes
  for a free-standing question, and Task 6 proves it.
- **The schema bump and its migration land in the same commit.** A version raised without its
  migration compiles and is broken, and that has happened in this repo before.
- **Never invent a figure.** Reading time in particular is banned: it would be a word count
  multiplied by an assumed reading speed, which is a measurement plus an assumption.
- **Voice:** grade-5-simple, American spelling, no em dashes. Scores are **points**.
- **No AI attribution in commits.** The check reads commit messages.

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| `2026-08-03-content-upgrade-seeder.md` | Both touch `seeder.dart` and both bump the schema. **Whichever runs second takes the next version number and must confirm the current value first.** | No, but read it |
| `2026-08-02-quiz-tab-04-viewer-and-reveal.md` | Task 5 renders the passage in the viewer that plan builds. **If it has not landed, stop after Task 4 and say so.** | Yes, for Task 5 |

## File structure

| File | Responsibility |
|---|---|
| `lib/core/storage/data/tables/passages_table.dart` (create) | The entity. |
| `lib/core/storage/data/tables/questions_table.dart` (modify) | Nullable `passageId`. |
| `lib/core/storage/data/app_database.dart` (modify) | Registration, bump, migration. |
| `tools/import_questions/converter.dart` (modify) | Parse `passages:`, resolve refs. |
| `tools/build_dev_seed/build_dev_seed.dart` (modify) | Emit passages into the seed. |
| `lib/core/storage/data/seeder.dart` (modify) | Insert them. |
| `lib/core/storage/data/repos/content_repository.dart` (modify) | Read a passage, and a set. |
| `lib/features/quiz/domain/passage_set_filler.dart` (create) | Section 4's fill rule. |

---

## Task 1: The entity and the column

**Files:**
- Create: `lib/core/storage/data/tables/passages_table.dart`
- Modify: `lib/core/storage/data/tables/questions_table.dart`, `app_database.dart`
- Test: `test/core/storage/data/passages_schema_test.dart`

**Interfaces:**

```dart
@DataClassName('PassageRow')
class Passages extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text().references(Topics, #id)();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get language => text()();
  IntColumn get wordCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

`Questions` gains `TextColumn get passageId => text().nullable().references(Passages, #id)();`

**`wordCount` is stored, not computed at render.** It is internal: the content plan uses it to
police the 150 to 400 range, and **it is never shown to a student.** Reading time derived from
it is banned by the spec.

- [ ] **Step 0: Confirm the current schema version**

```bash
grep -n "schemaVersion" lib/core/storage/data/app_database.dart
```

Note the number. **Your migration takes the next one.** If another plan has landed since this
was written, that is fine; take the next number after what you actually find. **Do not assume
a number from this document.**

- [ ] **Step 1: Write the failing test**

Assert: a passage round-trips; a question with a null `passageId` round-trips unchanged; a
question referencing a missing passage fails the foreign key; and an existing database
migrates without losing a single row of `attempts_local`.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Add the table, the column, the bump and the migration in one commit**
- [ ] **Step 4: Run the gates**

---

## Task 2: The YAML learns about passages

**Files:**
- Modify: `tools/import_questions/converter.dart`
- Test: `test/tool/import_questions/passage_converter_test.dart`

**The format, settled:**

```yaml
meta:
  subject: reading-comprehension
  topic: comprehension-skills
  subtopic: main-idea
  exams: [upcat, acet, dlsucet, ustet]
passages:
  - id: p-comprehension-skills-main-idea-0001
    title: The Palay Harvest
    body: |
      ...150 to 400 words...
questions:
  - id: q-comprehension-skills-main-idea-0001
    passage: p-comprehension-skills-main-idea-0001
    type: main-idea
    difficulty: easy
    stem: |
      What is the main idea of the passage?
    choices: [...]
    explanation: |
      ...
```

**The validator must reject, with the exact id in the message:**

1. A question naming a passage that is not in the same file.
2. A passage with **fewer than 4** or **more than 8** questions.
3. A passage body outside **150 to 400 words**.
4. A passage with no questions at all.

**Those four are the content plan's quality rules, enforced by the tool rather than by a
reviewer's patience.** A reviewer will miss the fourth one every time.

- [ ] **Step 1: Write the failing test**, one case per rejection plus a valid file
- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Parse and validate**
- [ ] **Step 4: Run the gates**

---

## Task 3: The seed carries passages

**Files:**
- Modify: `tools/build_dev_seed/build_dev_seed.dart`, `lib/core/storage/data/seeder.dart`
- Test: `test/core/storage/data/seeder_passage_test.dart`

**Passages are inserted before questions**, because a question references one and foreign keys
are only unenforced until somebody turns the pragma on. The seeder already orders lessons
before questions for exactly this reason; follow it.

**`build_dev_seed.dart` carries two pre-existing `unnecessary_cast` warnings in the analyzer
baseline. Do not fix them here**, or the baseline stops matching for every other plan.

- [ ] **Step 1: Write the failing test**

Assert: a seed with passages inserts them; questions resolve their `passageId`; a seed with
**no** passages still works exactly as today.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Emit and insert**
- [ ] **Step 4: Run the gates**

---

## Task 4: A passage set is indivisible

**Files:**
- Create: `lib/features/quiz/domain/passage_set_filler.dart`
- Modify: the session builder and the mock sampler. **Find them with `grep -rn`.**
- Test: `test/features/quiz/domain/passage_set_filler_test.dart`

**This is the task the spec exists for.** Section 3: a comprehension question without its
passage is unanswerable, so any surface that selects a single question must take the whole set
or none of it.

**Interfaces:**

```dart
/// Fills [size] slots, taking passage sets whole or not at all.
///
/// Section 4 of the spec: a set is taken only while the remaining room is at
/// least the set's size. A session smaller than the smallest available set
/// contains no passage questions, and that is correct rather than a failure.
abstract final class PassageSetFiller {
  static List<Question> fill({
    required int size,
    required List<Question> freeStanding,
    required Map<String, List<Question>> setsByPassageId,
  });
}
```

- [ ] **Step 1: Write the failing test**

Assert:

1. A set that fits is taken whole, and its questions are **consecutive** in the result.
2. A set that does not fit in the remaining room is **not** taken, and is not split.
3. A session of 5 with only a 6-question set available contains **zero** passage questions.
4. The result is never longer than `size`.
5. With no sets at all, the output equals the free-standing selection, unchanged.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Build it, then route the session builder and the mock sampler through it**
- [ ] **Step 4: Run the gates**

---

## Task 5: The reading surface

**Files:**
- Modify: the question viewer from `2026-08-02-quiz-tab-04-viewer-and-reveal.md`, and the
  review component from `2026-08-02-quiz-tab-06-review-component.md`
- Test: widget tests against both

**Check Quiz Plan 4 has landed first. If it has not, stop after Task 4 and say so.** Building
a viewer this plan does not own would collide with the plan that does.

**From spec Section 5, and none of it is negotiable:**

- The passage renders **above** the question, in the **reader's** typography, not the
  question's. Reuse the lesson reader's measure, line height and serif.
- A **hairline rule** separates passage from question, the same device the reader uses between
  sections.
- The passage **scrolls with the question**. No sticky pane: it splits a phone into two cramped
  halves and neither is readable.
- Moving between questions on the same passage **does not re-animate the passage**. A text
  that fades in six times is the app pointing at its own machinery.
- In the **review**, the passage renders **once above its questions**, never once per question.

- [ ] **Step 1: Write the failing tests**

Assert: the passage appears once for a set of six in review; it is absent entirely for a
free-standing question; and no widget in the subtree is a sticky or pinned header.

- [ ] **Step 2: Run them and confirm they fail**
- [ ] **Step 3: Render it**
- [ ] **Step 4: Run the gates**

---

## Task 6: Prove nothing else moved

**Files:**
- Test: `test/features/quiz/passage_regression_test.dart` (create)

**The blast radius claim in spec Section 8 is worth a test rather than a sentence.**

- [ ] **Step 1: Write it**

Assert, against a database with **no passages at all**: a session builds as before, a mock
samples as before, the viewer renders as before, and the review renders as before.

- [ ] **Step 2: Run the full suite**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
dart run tool/check_layering.dart
dart run tool/check_no_ai_attribution.dart
```

- [ ] **Step 3: Commit**

---

## Verification, for the reviewer

- `grep -rn "passageId" lib/` shows the column, the repository read, and the filler. Nothing
  in `features/` reaches past the repository for it.
- A database with no passages behaves identically to today. Task 6 proves it.
- A passage set never splits across sessions. Task 4 proves it.
- No student-facing string anywhere contains a reading time or a passage word count.
- `flutter analyze` 27, layering 7, suite green.

## Done when

- A YAML file can declare passages, and the validator rejects a set that is too small, too
  large, orphaned, or attached to a body outside 150 to 400 words.
- A passage reaches the app through the seed and renders once above its questions.
- A session takes a passage set whole or leaves it, and never shows a comprehension question
  without its text.
- Everything with no passage behaves exactly as it did.
