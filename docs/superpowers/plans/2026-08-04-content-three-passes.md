# The three content passes: lesson link, rationale, short label

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**This plan is model-agnostic.** It names no harness-specific skill in its tasks. Read
`AGENTS.md` and `SUBAGENTS.md` before writing a line.

**Goal:** Fill the three fields that are empty on every question in the app: which lesson a
question belongs to, why each wrong choice is wrong, and a short label for it.

**Architecture:** Tasks 1 to 3 are a pipeline change and carry **no authoring at all**. Task 4
is content generation over a manifest. **No schema migration is needed:** `questions.lessonId`
and `questions.shortLabel` already exist as nullable columns, and the per-choice rationale rides
inside the existing choices JSON.

**Tech Stack:** Dart tooling, YAML, Drift, flutter_test. No new packages.

---

## What the survey found, and it changes the size of this job

**Checked before writing this plan rather than assumed.**

| Field | Believed | Actually |
|---|---|---|
| Lesson link | A tagging pass over ~1,900 questions | **Fully derivable, zero authoring.** A question at `content/questions/<subject>/<topic>/<subtopic>.yaml` belongs to the lesson `lesson-<topic>-<subtopic>`, and that lesson file sits at the mirror path. The app **already reads** `q['lessonId']` from the seed. The dev seed builder simply never writes it |
| Per-choice rationale | Authored from nothing | **Largely already written, in the wrong shape.** Every question has an `explanation` that discusses the wrong choices in prose. This is a restructuring pass, not authoring |
| Short label | Authored from nothing | **Authored from nothing.** The only one of the three that is |

**The lesson link is therefore a one-line fix, not a pass**, and it unblocks the reader's
ending, lesson filtering in the practice picker, and the deepest level of the progress table.

---

## Global Constraints

- **Do not touch `schemaVersion`.** Both columns exist. If you find yourself writing a
  migration, stop: you have taken a wrong turn.
- **No em dashes.** American spelling. No AI attribution in commit messages.
- **`approved:` stays unset.** Approval is Aedwon's, in Question Studio.
- **Never invent a figure**, and never invent a rationale. A rationale must follow from the
  question, not from a guess about why a student picked something.
- **The validator prints the full converted JSON of every question**, 2.8 MB across the corpus.
  **Redirect it to `/dev/null` and read the exit code**, and scope `--root` to the directory you
  wrote. The tool is at `tools/import_questions/`, not `tool/`.

### Gate command

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
dart run tool/check_layering.dart            # expect 7
dart run tool/check_no_ai_attribution.dart   # expect 0
dart run tools/import_questions/import_questions.dart --root content/questions > /dev/null; echo $?
```

---

### Task 1: The lesson link, which is one line and no authoring

**Files:**
- Modify: `tools/build_dev_seed/build_dev_seed.dart`
- Test: `test/tool/build_dev_seed_test.dart`

**Interfaces:**
- Produces: every question in the built seed carries `lessonId`, formatted
  `lesson-<topicSlug>-<subtopicSlug>`.

- [ ] **Step 1: Write the failing test**

```dart
test('every question carries the lesson it belongs to', () {
  final questions = buildQuestionsFrom(
    fixtureYaml(topic: 'arithmetic-number-sense', subtopic: 'real-imaginary-numbers'),
  );
  expect(
    questions.first['lessonId'],
    'lesson-arithmetic-number-sense-real-imaginary-numbers',
  );
});

test('the lesson id matches a lesson that actually exists', () {
  // A dangling reference is worse than a null one: the column is a foreign
  // key to lessons, and the seeder will fail on insert rather than at build.
  final questions = buildQuestionsFrom(realCorpusSample());
  final lessonIds = buildLessons().map((l) => l['id']).toSet();
  for (final q in questions) {
    expect(lessonIds, contains(q['lessonId']), reason: '${q['id']}');
  }
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/tool/build_dev_seed_test.dart
```

Expected: FAIL. `lessonId` is absent from the built map.

- [ ] **Step 3: Emit it**

In `_buildQuestions`, the topic and subtopic slugs are already in scope from the file path.
Add one entry to the map built for each question, beside `topicId`:

```dart
        'topicId': topicId,
        // Derived, never authored. A question at
        // content/questions/<subject>/<topic>/<subtopic>.yaml belongs to the
        // lesson at the mirror path, whose _id is lesson-<topic>-<subtopic>.
        'lessonId': 'lesson-$topicSlug-$subtopicSlug',
```

**Use the same slugs the surrounding code already derives for `topicId`.** Do not re-parse the
path, and do not read the lesson file: if the two ever disagree, the second test above is what
catches it.

- [ ] **Step 4: Run the tests**

Expected: PASS, both.

- [ ] **Step 5: Rebuild the seed and confirm the fill rate**

```bash
dart run tools/build_dev_seed/build_dev_seed.dart
python3 -c "
import json;d=json.load(open('assets/seed/v1.json'))
qs=d['questions'];n=sum(1 for q in qs if q.get('lessonId'))
print(f'{n} of {len(qs)} questions carry a lesson')"
```

Expected: **every question**, not most. **If any question lacks one, stop and say so** with the
id: it means a question exists whose subtopic has no lesson, which is a content problem this
task must not paper over.

- [ ] **Step 6: Run the full gate set, then commit**

```bash
git add -A
git commit -m "feat(content): questions carry the lesson they came from"
```

---

### Task 2: Carry the short label and the per-choice rationale through the pipeline

**No content is written in this task.** It makes the fields legal and carried, so Task 4 has
somewhere to put its output.

**Files:**
- Modify: `tools/import_questions/converter.dart`
- Modify: `tools/build_dev_seed/build_dev_seed.dart`
- Modify: `lib/core/storage/data/seeder.dart`
- Test: `test/tool/import_questions/converter_test.dart`
- Test: `test/tool/build_dev_seed_test.dart`

**Interfaces:**
- Produces: an optional `shortLabel` on a question and an optional `rationale` on a choice, both
  validated when present, both carried to the database.

- [ ] **Step 1: Write the failing test**

```dart
test('a short label is optional and carried when present', () {
  final q = convert(questionYaml(shortLabel: 'Whole vs natural numbers'));
  expect(q['shortLabel'], 'Whole vs natural numbers');
});

test('a question without a short label is still valid', () {
  final q = convert(questionYaml());
  expect(q['shortLabel'], isNull);
});

test('a per-choice rationale is carried onto that choice', () {
  final q = convert(questionYaml(choiceRationales: {
    'B': 'One is a natural number as well as a whole number.',
  }));
  final b = (q['choices'] as List).firstWhere((c) => c['label'] == 'B');
  expect(b['rationale'], 'One is a natural number as well as a whole number.');
});

test('the correct choice may carry a rationale and is not required to', () {
  final q = convert(questionYaml());
  final correct = (q['choices'] as List).firstWhere((c) => c['isCorrect'] == true);
  expect(correct['rationale'], isNull);
});

test('an empty rationale is rejected rather than stored', () {
  // A blank string would render as an empty note B, which reads as a bug.
  expect(
    () => convert(questionYaml(choiceRationales: {'B': '   '})),
    throwsA(isA<FormatException>()),
  );
});

test('a short label longer than 60 characters is rejected', () {
  // It has to fit one line of a debrief miss row without clamping.
  expect(
    () => convert(questionYaml(shortLabel: 'x' * 61)),
    throwsA(isA<FormatException>()),
  );
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/tool/import_questions/converter_test.dart
```

Expected: FAIL. Neither field exists.

- [ ] **Step 3: Add both to the converter**

In `converter.dart`, beside the existing `requireText` helpers:

```dart
  final shortLabelRaw = q['shortLabel'];
  String? shortLabel;
  if (shortLabelRaw != null) {
    if (shortLabelRaw is! String || shortLabelRaw.trim().isEmpty) {
      throw FormatException('$id: shortLabel must be a non-empty string');
    }
    shortLabel = shortLabelRaw.trim();
    if (shortLabel.length > 60) {
      throw FormatException(
        '$id: shortLabel is ${shortLabel.length} characters, max 60',
      );
    }
  }
```

And inside the choice loop, after `isCorrect`:

```dart
    final rationaleRaw = c['rationale'];
    String? rationale;
    if (rationaleRaw != null) {
      if (rationaleRaw is! String || rationaleRaw.trim().isEmpty) {
        throw FormatException(
          '$id: choice ${labels[i]} has an empty rationale',
        );
      }
      rationale = rationaleRaw.trim();
    }
```

Add `'rationale': rationale` to the choice map and `'shortLabel': shortLabel` to the question
map.

**Mirror both in `build_dev_seed.dart`**, which builds its own map and does not share this code.
**That duplication already exists and this task does not fix it**, but note it in your report:
two places converting the same YAML is how they drift.

**In `seeder.dart`**, set `shortLabel: Value(q['shortLabel'] as String?)` beside the existing
`lessonId` line. The rationale needs no seeder change: it rides inside the choices JSON.

- [ ] **Step 4: Run the tests, then the full gate set**

Expected: PASS, all six. **The whole-corpus validator must still exit 0**, since both fields are
optional and nothing has them yet.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(content): the pipeline carries short labels and per-choice reasons"
```

---

### Task 3: The app reads them, and degrades honestly without them

**Files:**
- Test: `test/core/storage/data/seeder_test.dart`

**Interfaces:**
- Produces: proof that a question with neither field still renders everywhere.

- [ ] **Step 1: Write the test**

```dart
test('a question with no short label and no rationales still seeds', () async {
  await seedFrom(fixtureWithoutOptionalFields());
  final q = await db.select(db.questions).getSingle();
  expect(q.shortLabel, isNull);
  expect(q.lessonId, isNotNull); // Task 1 makes this non-null for real content
});
```

- [ ] **Step 2: Run it**

Expected: PASS immediately, since both columns are nullable. **This task is a guard, not a
change.** It exists so a later reader cannot assume the fields are required, and so Task 4 can
be run subtopic by subtopic without ever leaving the app in a broken state.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "test(content): the optional fields stay optional"
```

---

### Task 4: Generate the rationales and the short labels

**This is the content pass, and it is the only part with authoring in it.** It runs subtopic by
subtopic, exactly like the question generation plans, and follows `SUBAGENTS.md` Part 4.

**Per subtopic, in this order:**

- [ ] **Step 1: Read the subtopic's questions and its lesson.** The lesson is at the mirror path
      under `content/lessons/`. **The rationale must follow from the lesson and the question, not
      from a guess.**

- [ ] **Step 2: Write a `rationale` on every wrong choice.**

**Most of what you need is already in the question's `explanation`**, which typically discusses
each wrong choice in prose. **This is a restructuring, not authoring.** Split that prose onto the
choices it refers to.

Rules:
- **One sentence, addressed to the choice, never to the student.** "Zero is a whole number but
  not a natural number." Not "You may have thought..."
- **It says why that choice is wrong, not why the right one is right.** The explanation already
  does the second thing.
- **The correct choice gets no rationale.** Leave it absent.
- **Never guess a misconception.** If the explanation does not say why a choice is wrong and the
  lesson does not make it obvious, **leave it absent and report the question id.** An absent
  rationale renders nothing; a wrong one teaches something false.
- Grade-5-simple English, American spelling, no em dashes.

- [ ] **Step 3: Write a `shortLabel` on every question.**

- **Under 60 characters**, and the converter rejects longer.
- **It names what the question is about, not what it asks.** "Whole vs natural numbers", not
  "Which number belongs to the set of whole numbers".
- **It must distinguish questions within the same subtopic.** Fifteen questions labeled
  "Number systems" are fifteen useless rows in a debrief.
- Sentence case, no trailing period.

- [ ] **Step 4: Validate the one directory**

```bash
dart run tools/import_questions/import_questions.dart --root content/questions/<subject>/<topic> > /dev/null; echo $?
```

Expected: `0`.

- [ ] **Step 5: Commit that subtopic and move to the next**

```bash
git add content/questions/<subject>/<topic>/<subtopic>.yaml
git commit -m "content(<subtopic>): reasons per choice and short labels"
```

### The manifest

**Fill the Done column as you go.** The corpus is roughly 1,900 questions across Science,
Mathematics, Language, Reasoning and, once the passage pipeline lands, Reading comprehension.

**Generate the manifest from the tree rather than copying one here**, because a copied list goes
stale and this repo already has a manifest that is behind its own corpus:

```bash
find content/questions -name "*.yaml" | sort
```

**Do the subtopics with the most questions first.** They are the ones whose absence is most
visible in a debrief.

---

## What this plan deliberately does not do

- **No schema migration.** Both columns already exist.
- **It does not fix the duplicated YAML conversion** between the importer and the dev seed
  builder. That is a real problem and it is named in Task 2 so it is not lost.
- **It does not touch the surfaces that read these fields.** The reader's ending, the practice
  picker's lesson filter, the progress table's lesson level, note B on the reveal and the
  debrief's miss rows are all owned by their own plans and all already degrade honestly without
  these fields.

## Verification for the whole plan

```bash
python3 -c "
import json;d=json.load(open('assets/seed/v1.json'));qs=d['questions']
print('lesson:', sum(1 for q in qs if q.get('lessonId')), 'of', len(qs))
print('label :', sum(1 for q in qs if q.get('shortLabel')), 'of', len(qs))
print('reason:', sum(1 for q in qs for c in q['choices'] if c.get('rationale')))"
```

- **Every question carries a lesson id**, and every id names a lesson that exists.
- No short label exceeds 60 characters.
- No rationale is an empty string.
- No correct choice carries a rationale.
- `schemaVersion` is unchanged.
- The whole-corpus validator exits 0.
