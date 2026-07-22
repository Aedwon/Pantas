# Content 01b: the content schema gains what the app needs

**Plan, 11 August 2026.** A stage the spec did not know it needed, inserted
between Content 01 and Content 02.

> **Required reading before Task 1:** `AGENTS.md`, then Sections 4.1 and 4.2 of
> `specs/2026-08-11-content-path-and-the-mock.md`, then
> `lib/core/storage/data/tables/questions_table.dart` and
> `lib/core/content/content_database.dart`.

**Content 01 is merged.** Content 02 is blocked on this and must not start
until this is merged.

---

## Why this exists

**Content 02 stopped in its second task and it was right to.** Moving the app's
readers onto `ContentDatabase` is impossible while that database cannot hold
what the app reads. The spec assumed the two schemas were equivalent. They are
not, and the differences are structural rather than cosmetic.

Counted against the shipped seed:

| Missing from the content schema | Cost of proceeding without it |
|---|---|
| `content_passages` table, entirely | **32 passages gone**, and the **160 reading comprehension questions that need them become unanswerable** |
| `content_questions.lesson_id` | **1,998 of 2,000 questions lose their lesson**, which breaks the lesson-level performance table and every "quiz yourself on this lesson" path |
| `content_questions.passage_id` | The 160 above cannot find their passage even if the table existed |
| `content_questions.short_label` | The review list falls back to printing a full stem where a short label was authored |
| `content_exams.is_custom` | The custom exam track cannot mark its own exam |

**None of these may be defaulted.** A null lesson id is a silently broken
feature; an absent passage is a question a student cannot answer.

---

## Global constraints

- **Never run `flutter test` with no arguments, `flutter analyze` across the
  repository, or `dart run build_runner`,** except once at the start: your
  worktree is a fresh checkout, so `flutter gen-l10n` and
  `dart run build_runner build --delete-conflicting-outputs` are allowed once,
  for missing generated files only. Never use `&`, `nohup`, or any background
  mechanism.
- **`assets/seed/content.db` is gitignored and absent from a fresh checkout.**
  `flutter analyze` warns and `flutter test` fails on the missing asset until
  you build it. Build it first:
  ```bash
  mkdir -p build
  dart run tools/build_content_export/build_content_export.dart build/export.json
  dart run tools/build_content_seed/seed_writer.dart build/export.json assets/seed/content.db
  ```
  The export exits 65 on six known unmapped topics. That is expected.
- **Work only inside your worktree.** Run `pwd` before your first write.
- **Commit the moment a task's own test passes.**
- **Run `flutter analyze` on the files you create or change and leave them
  clean.**
- **No em dashes.** American spelling.

### Gate command

```bash
flutter test test/core/content/ test/tool/
```

---

## Task 1: The content schema carries passages

**Files:**
- Create: a passages table for `ContentDatabase`, beside its existing tables
- Modify: `lib/core/content/content_database.dart`, its schema version
- Create: `lib/core/content/sanity/parsers/passage_parser.dart`
- Modify: `lib/core/content/sanity/schema_versions.dart`
- Test: a parser test and a table test

**Mirror the app's `Passages` table**, which is the shape the corpus already
produces: id, topic, title, body, language, word count. Read it rather than
inventing a shape.

**Add `passage` to the GROQ queries** in `groq_queries.dart`, both the full and
the incremental form, so the eventual live fetch carries them too.

**The content database's schema version increments.** `SeedInstaller` compares
versions and reinstalls when the bundled copy is newer, so an older installed
database is replaced rather than migrated. Confirm that is what happens before
you rely on it.

---

## Task 2: A question carries its lesson, its passage and its short label

**Files:**
- Modify: the content questions table, `question_parser.dart`
- Test: extend the question parser test

**All three are nullable**, exactly as they are in the app's schema: 1,998 of
2,000 questions carry a lesson, 160 carry a passage, and a short label is
authored only where a stem is too long to list.

**`content_exams` gains `is_custom`**, defaulting false, for the custom track.

---

## Task 3: The export emits them

**Files:**
- Modify: `tools/build_content_export/build_content_export.dart`
- Modify: `test/tool/content_export_roundtrip_test.dart`

**The corpus already has all of it.** `v1.json` carries 32 passages as a top
level list, `lessonId` on 1,998 questions and `passageId` on 160. The export
reads the same sources; it simply has not been asked for these yet.

**The roundtrip test asserts the numbers, not their presence**: 32 passages,
1,998 lesson links, 160 passage links. A pipeline that emits three passages
passes a "not empty" check.

---

## Task 4: Prove a reading comprehension question survives the trip

**Files:**
- Test: `test/core/content/reading_comprehension_roundtrip_test.dart`

**Take one real passage set from the corpus**, build it through the export and
`seed_writer`, read it back from `ContentDatabase`, and assert the questions
resolve to their passage and the passage's body is intact.

**This is the test that would have caught the gap**, and it is the reason this
stage exists: a schema can look complete and still lose a whole feature.

---

## Done when

- `ContentDatabase` holds 32 passages, and questions carry lesson, passage and
  short label.
- The roundtrip test asserts each count.
- A reading comprehension question read from the content database still finds
  its passage.
- The gate command passes and the files you touched are analyzer clean.
