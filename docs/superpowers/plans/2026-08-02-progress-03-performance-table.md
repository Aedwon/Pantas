# Progress, Plan 3 of 6: The Performance Table

> **How to work this plan.** Implement it task by task, in order. For each task: write the
> failing test first, run it and confirm it fails, then write the code that makes it pass. Do
> not skip a step and do not batch tasks. Steps use checkbox (`- [ ]`) syntax so progress can
> be tracked.
>
> **Required reading before Task 1:** `AGENTS.md` at the repository root, in full. It carries
> the build commands, the visual identity bans, the voice rules, the never-invent-a-figure
> rule and the landmines, and every one of them applies to this plan whether or not the
> Global Constraints below happen to repeat it.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous, contradicts the spec, or looks
> wrong, **stop and say so** rather than inventing a solution. A plausible invention is more
> expensive than a question, because it looks finished.
>
> **Analyzer baseline:** `flutter analyze` reports **27 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. `lib/` is clean. Any issue under `lib/` or `test/` is
> one you introduced.
>
> **Work only inside your worktree.** Never write to the main checkout. A previous run left a
> half-applied `app_database.dart` in the main tree with `schemaVersion` bumped and no
> migration: a broken state that compiles.
>
> **Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand and never
> committed.** This repo gitignores them.
>
> **No AI attribution in commit messages.** No `Co-Authored-By` trailers, no "Generated with"
> lines, no similar marker.

**Goal:** Build the tab's centre: a sortable table of accuracy and pace, readable at
subject, topic and lesson level, whose labels are its own controls and which prints
nothing it cannot measure.

**Architecture:** One provider answering "accuracy and pace, grouped by this level", a
table head whose cells are the sort controls, a level control in the section header's
right slot, and the rows drawn with Plan 1's `DataRowTile`. The severity helper is shared
with Home, not duplicated.

**Tech Stack:** Flutter, Riverpod, Drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-30-progress-tab-design.md` Section 3
("Performance"), Section 6 (the controls) and Section 7 (Free and Pro).

---

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-progress-01-frame-and-grammar.md` | `DataRowTile`, `TableOrder`, the `_performanceSection` stub | **Blocking** |
| `2026-08-02-home-02-assessment-attempt-row.md` | The assessment writing an attempt row, and the speed signals skipping untimed origins | **Blocking in substance.** Without it this table is blind to the assessment's 21 questions, which for most students is every question they have answered |
| `2026-08-02-home-05-practice-panel.md` | `topicAccuracyProvider` and `severityFor` | **Not blocking, but do not duplicate.** See Task 1 |
| Lesson tagging, all 1,117 questions | The Lesson level | **Not blocking.** Without it the Lesson label is **absent**, not dimmed and not empty |
| A mock actually running | The Time column | **Not blocking.** Without it the column and its head are absent and the sort falls back to Score |

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.**
- **The evidentiary rule.** Accuracy and seconds are T1. Section size is T2. **Nothing is
  multiplied and nothing is projected.** The rows state two facts and the student combines
  them.
- **Pro cannot go deeper on the paper's composition, only on performance.** A topic-level
  item count is the unpublished T4 number that was cut from this tab. **Section size stays
  a subject-level fact at every level of the table.**
- **Time comes from timed mock attempts only.** A claim about the exam clock may not be
  measured on untimed late-night practice.
- **Board green appears nowhere in this table.**
- **A row's colour never changes because the table was re-sorted.**
- **Voice.** Grade-5-simple English, **no em dashes**. Scores are **points**, never
  "marks". The words FSRS, stability, retention, retrievability, algorithm and card never
  appear.
- **Analyzer must be clean.**

## Verification commands

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

---

## File structure

| File | Responsibility |
|---|---|
| `lib/features/progress/application/performance_provider.dart` (create) | Rows at any of the three levels, filtered or not, and whether time is measurable |
| `lib/core/ui/severity.dart` (create or move) | `severityFor(double accuracy, AppColors)`, shared with Home |
| `lib/features/progress/presentation/widgets/table_head.dart` (create) | The three head cells, the caret, and the scope control |
| `lib/features/progress/presentation/widgets/subject_scope_sheet.dart` (create) | The subject list, over the wash |
| `lib/features/progress/presentation/widgets/level_control.dart` (create) | Subject · Topic · Lesson |
| `lib/features/progress/presentation/widgets/performance_section.dart` (create) | Header, head, rows, the empty and partial states |
| `lib/features/progress/presentation/progress_page.dart` (modify) | `_performanceSection` returns the real widget |

## Added 2 August: the subject filter

The spec gained a subject filter after this plan was written. It is **Task 2a**, inserted
between the head and the level control, and it changes Task 1's provider signature and
Task 2's `TableHead`. Read the spec's "The subject filter" and "Controls appear only when
they can do something" before starting, and
`decisions/2026-07-29-progress-tab-decision-log.md`, 2 August, for what was rejected.

**The one-line summary:** the left head cell is the control. It is inert at Subject level,
reads `All topics` at Topic level, `Science topics` when filtered, and opens a sheet over
the wash. Zero added height, no new row, no Settings row.

---

### Task 1: The rows, at three levels

**Files:**
- Create: `lib/features/progress/application/performance_provider.dart`
- Create or move: `lib/core/ui/severity.dart`
- Test: `test/features/progress/application/performance_provider_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`; `AttemptItemReader`; `SignalContentHelpers`;
  `MockPacingSignal`; `TableLevel` from Plan 1; `activeExamFocusProvider`.
- Produces:

```dart
@immutable
class PerformanceRow {
  const PerformanceRow({
    required this.id,
    required this.title,
    required this.subtext,
    required this.correct,
    required this.answered,
    required this.secondsPerQuestion,
  });

  final String id;
  final String title;

  /// The row's parent at topic and lesson level. At subject level, the
  /// section's published size: "60 of 180 questions". T2.
  final String? subtext;

  final int correct;
  final int answered;

  /// Null when no timed mock has touched this row. Never estimated from
  /// practice.
  final double? secondsPerQuestion;

  double? get accuracy => answered == 0 ? null : correct / answered;
}

@immutable
class PerformanceTable {
  const PerformanceTable({
    required this.rows,
    required this.timeIsMeasurable,
    required this.lessonLevelAvailable,
  });

  final List<PerformanceRow> rows;

  /// False until a full length mock has been sat. The Time column and its
  /// head are then absent, not filled with placeholders.
  final bool timeIsMeasurable;

  /// False until questions carry a lessonId. The Lesson label is then
  /// absent, not dimmed and not empty.
  final bool lessonLevelAvailable;
}

/// The level, plus the subject the table is scoped to. Null subject means
/// all subjects.
@immutable
class PerformanceQuery {
  const PerformanceQuery({required this.level, this.subjectId});
  final TableLevel level;
  final String? subjectId;
}

final performanceProvider =
    FutureProvider.family<PerformanceTable, PerformanceQuery>(...);
```

`PerformanceTable` also carries **`List<({String id, String name, int rowCount})>
subjects`**, so the sheet in Task 2a can print a count beside each subject without a
second query. It is empty when fewer than two subjects have data, which is exactly the
condition under which the control does not render.

**Where the numbers come from.** `SubjectAffinitySignal` already returns `correct`, `total`
and `averageMs` keyed by subject, which is the subject level exactly. **Topic and lesson
levels need the same query grouped differently**, and both run on existing tables.

**Home's `topicAccuracyProvider` is this provider at `TableLevel.topic`.** Whichever plan
runs second must collapse the two: have Home watch
`performanceProvider(TableLevel.topic)` and delete its own ranking. Two rankings of the
same data is how the app tells a student a topic is weak on Home and strong on Progress.
**Home's sample floor stays a Home concern**: this table prints what it measures at any
sample size, because the student chose to look at a table.

**Time comes from `MockPacingSignal` and the mock payloads, never from
`SubjectAffinitySignal.averageMs`.** That field exists and is not what this column shows.
Home plan 2 made it divide by timed items only, which is correct for what it is, and it
still includes untimed practice.

**`timeIsMeasurable` is false when no mock has been submitted.** Not when the mock is
in progress, and not when the mock was forfeited part way, which still measured the
questions it reached.

**Section size is T2 and subject level only.** At topic and lesson level the subtext is the
row's parent. Do not divide a section's item count across its topics to make a
topic-level size: that is the exact T4 figure that was cut from this tab.

- [ ] **Step 1: Write the failing test**

Use a real in-memory `AppDatabase`.

```dart
  test('subject level groups by subject and carries the published size',
      () async {
    final table =
        await container.read(performanceProvider(TableLevel.subject).future);

    final science = table.rows.firstWhere((r) => r.title == 'Science');
    expect(science.answered, 60);
    expect(science.subtext, '60 of 180 questions');
  });

  test('topic level carries the parent, never a size', () async {
    final table =
        await container.read(performanceProvider(TableLevel.topic).future);

    final chemistry = table.rows.firstWhere((r) => r.title == 'Chemistry');
    expect(chemistry.subtext, 'Science');
    expect(chemistry.subtext, isNot(contains('questions')));
  });

  test('with no mock sat, time is not measurable and every row has none',
      () async {
    final table =
        await container.read(performanceProvider(TableLevel.subject).future);

    expect(table.timeIsMeasurable, isFalse);
    expect(table.rows.every((r) => r.secondsPerQuestion == null), isTrue);
  });

  test('practice time never fills the column', () async {
    // 200 practice attempts with real response times, no mock.
    final table =
        await container.read(performanceProvider(TableLevel.subject).future);

    expect(table.timeIsMeasurable, isFalse);
  });

  test('a submitted mock makes time measurable', () async {
    final table =
        await container.read(performanceProvider(TableLevel.subject).future);

    expect(table.timeIsMeasurable, isTrue);
    expect(table.rows.first.secondsPerQuestion, isNotNull);
  });

  test('a forfeited mock still measures the questions it reached', () async {
    final table =
        await container.read(performanceProvider(TableLevel.subject).future);
    expect(table.timeIsMeasurable, isTrue);
  });

  test('assessment attempts count toward accuracy at every level', () async {
    for (final level in [TableLevel.subject, TableLevel.topic]) {
      final table = await container.read(performanceProvider(level).future);
      expect(table.rows.fold<int>(0, (s, r) => s + r.answered), 21);
    }
  });

  test('lesson level is unavailable until questions carry a lessonId',
      () async {
    final table =
        await container.read(performanceProvider(TableLevel.subject).future);
    expect(table.lessonLevelAvailable, isFalse);
  });

  test('a row with no answered questions reports a null accuracy', () async {
    final table =
        await container.read(performanceProvider(TableLevel.topic).future);
    final untouched = table.rows.firstWhere((r) => r.title == 'Physics');

    expect(untouched.answered, 0);
    expect(untouched.accuracy, isNull);
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/progress/application/performance_provider_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write the provider**

- [ ] **Step 4: Share the severity helper**

```dart
// lib/core/ui/severity.dart

/// Rust below 50, amber below 70, plain ink above.
///
/// Home's practice panel and Progress's performance table show the same
/// figure for the same topic, so they must colour it the same way. A
/// second copy of these thresholds is how a student catches the app
/// disagreeing with itself at 49.6%.
Color severityFor(double accuracy, AppColors colors) {
  final pct = accuracy * 100;
  if (pct < 50) return colors.rust;
  if (pct < 70) return colors.amber;
  return colors.ink;
}
```

If Home plan 5 already defined this inside `practice_panel.dart`, **move it here and have
Home import it**. Do not leave two.

- [ ] **Step 5: Run the tests and commit**

```bash
flutter test test/features/progress/ test/features/home/
git add -A
git commit -m "feat(progress): compute the performance table at three levels

Time comes from timed mock attempts only: a claim about the exam clock
may not be measured on untimed late-night practice. With no mock, the
column is absent rather than filled.

Section size stays a subject-level published fact at every level.
Dividing it across a section's topics is the T4 figure this tab was
rewritten to remove.

The severity thresholds move to core/ui, shared with Home's practice
panel, because the two surfaces show the same figure."
```

---

### Task 2: The table head, which is the sort control

**Files:**
- Create: `lib/features/progress/presentation/widgets/table_head.dart`
- Test: `test/features/progress/presentation/widgets/table_head_test.dart`

**Interfaces:**
- Consumes: `TableSortKey`, `TableSortDirection` from Plan 1.
- Produces: `class TableHead extends StatelessWidget` taking
  `({required String rowNoun, required bool showTime, required TableSortKey sortKey, required TableSortDirection direction, required ValueChanged<TableSortKey> onSort})`.

**A ruled row.** The left cell names what the rows are, `SUBJECT`, `TOPIC` or `LESSON`, in
**11px uppercase `inkMuted`**. The right cells are **"SCORE"** and **"TIME"**, each a sort
control. Closed by a 1px `rule`.

**Tapping a column head sorts by it. Tapping the active head reverses it.** A **7px solid
caret** shows direction and **appears only on the active head**.

**No separate sort control exists**, because the labels that sort are the labels that name
the data. This is the elegance requirement met by removing the widget rather than
restyling it. **Do not add a dropdown, a chip row or an icon button.**

**The left cell does not sort.** It is a label.

**When `showTime` is false the Time head is absent**, not dimmed and not disabled.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('names the rows and offers two sorts', (tester) async {
    await tester.pumpWidget(harness(rowNoun: 'Topic', showTime: true));
    expect(find.text('TOPIC'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
  });

  testWidgets('the caret appears only on the active head', (tester) async {
    await tester.pumpWidget(
      harness(showTime: true, sortKey: TableSortKey.score),
    );
    expect(find.byKey(const ValueKey('sort-caret')), findsOneWidget);
  });

  testWidgets('tapping the inactive head sorts by it', (tester) async {
    final sorts = <TableSortKey>[];
    await tester.pumpWidget(
      harness(showTime: true, sortKey: TableSortKey.score, onSort: sorts.add),
    );
    await tester.tap(find.text('TIME'));
    expect(sorts, [TableSortKey.time]);
  });

  testWidgets('tapping the active head reverses it', (tester) async {
    final sorts = <TableSortKey>[];
    await tester.pumpWidget(
      harness(showTime: true, sortKey: TableSortKey.score, onSort: sorts.add),
    );
    await tester.tap(find.text('SCORE'));
    expect(sorts, [TableSortKey.score]);
  });

  testWidgets('the row noun does not sort', (tester) async {
    final sorts = <TableSortKey>[];
    await tester.pumpWidget(
      harness(rowNoun: 'Topic', showTime: true, onSort: sorts.add),
    );
    await tester.tap(find.text('TOPIC'), warnIfMissed: false);
    expect(sorts, isEmpty);
  });

  testWidgets('with no time, the head is absent and not dimmed',
      (tester) async {
    await tester.pumpWidget(harness(showTime: false));
    expect(find.text('TIME'), findsNothing);
  });

  testWidgets('no separate sort widget exists', (tester) async {
    await tester.pumpWidget(harness(showTime: true));
    expect(find.byType(DropdownButton<Object>), findsNothing);
    expect(find.byType(PopupMenuButton<Object>), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  });
```

- [ ] **Step 2 to 5: fail, implement, pass, commit**

```bash
git commit -m "feat(progress): make the table head the sort control

The labels that sort are the labels that name the data, so no separate
control exists. That is the elegance requirement met by removing the
widget rather than restyling it."
```

---

### Task 2a: The scope control and its sheet

**Files:**
- Modify: `lib/features/progress/presentation/widgets/table_head.dart` from Task 2
- Create: `lib/features/progress/presentation/widgets/subject_scope_sheet.dart`
- Test: `test/features/progress/presentation/widgets/subject_scope_test.dart`

**Interfaces:**
- Consumes: `PerformanceTable.subjects` from Task 1; `TableLevel`.
- Produces: `TableHead` gains
  `({required String? scopeLabel, required VoidCallback? onScope})`, and
  `Future<String?> showSubjectScopeSheet(BuildContext, {required List<({String id, String name, int rowCount})> subjects, required String? selectedId})`
  returning the chosen subject id, `null` for all subjects, and **nothing at all** if
  dismissed. Distinguish "chose All" from "dismissed": the first clears the filter, the
  second leaves it alone.

**The head cell's three states, and there is no fourth:**

| Level | `scopeLabel` | `onScope` |
|---|---|---|
| Subject | `null`. The cell renders `SUBJECT` as a plain label | `null` |
| Topic, unfiltered | `All topics` | live |
| Topic, filtered | `Science topics` | live |

Lesson level mirrors Topic with `All lessons`.

**The affordance is a 1px dotted underline in `inkMuted`, going solid while the sheet is
open.** Chosen because it cannot be confused with the sort caret two cells to its right.
Do not add a chevron, a triangle or an icon.

**The control does not render at all when fewer than two subjects have data**, which falls
out of `subjects.length < 2`. This is the same rule that hides the Time head before a mock
and the Lesson label before tagging.

**The sheet reuses the mock's wash exactly**: `ink` at 34%, the page settling 10px and
losing a hair of scale, **no blur**. Heading "Show which topics" in serif. Rows are
`All topics` first, then each subject, each with its row count right-aligned in tabular
figures. The table underneath never moves.

**Inline expansion was rejected** because it jumps the table about 130px on open and moves
the rows being read. Do not implement it as a fallback.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('at Subject level the cell is a plain label with no tap',
      (tester) async {
    await tester.pumpWidget(harness(level: TableLevel.subject));

    expect(find.text('SUBJECT'), findsOneWidget);
    expect(find.byKey(const ValueKey('scope-underline')), findsNothing);
    await tester.tap(find.text('SUBJECT'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(SubjectScopeSheet), findsNothing);
  });

  testWidgets('at Topic level it reads All topics and is underlined',
      (tester) async {
    await tester.pumpWidget(harness(level: TableLevel.topic, subjectId: null));

    expect(find.text('All topics'), findsOneWidget);
    expect(find.byKey(const ValueKey('scope-underline')), findsOneWidget);
  });

  testWidgets('filtered, it states the filter', (tester) async {
    await tester.pumpWidget(
      harness(level: TableLevel.topic, subjectId: 'science'),
    );
    expect(find.text('Science topics'), findsOneWidget);
    expect(find.textContaining('Filtered by'), findsNothing);
  });

  testWidgets('with one subject the control does not render', (tester) async {
    await tester.pumpWidget(
      harness(level: TableLevel.topic, subjects: [oneSubject]),
    );
    expect(find.text('All topics'), findsNothing);
    expect(find.text('TOPIC'), findsOneWidget);
  });

  testWidgets('the sheet lists All first, then subjects with counts',
      (tester) async {
    await tester.pumpWidget(harness(level: TableLevel.topic));
    await tester.tap(find.text('All topics'));
    await tester.pumpAndSettle();

    expect(find.text('Show which topics'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('dismissing leaves the filter alone, choosing All clears it',
      (tester) async {
    await tester.pumpWidget(
      harness(level: TableLevel.topic, subjectId: 'science'),
    );

    await tester.tap(find.text('Science topics'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // the wash
    await tester.pumpAndSettle();
    expect(find.text('Science topics'), findsOneWidget);

    await tester.tap(find.text('Science topics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All topics').last);
    await tester.pumpAndSettle();
    expect(find.text('All topics'), findsOneWidget);
  });

  testWidgets('while filtered no row repeats the subject in its subtext',
      (tester) async {
    await tester.pumpWidget(
      sectionHarness(level: TableLevel.topic, subjectId: 'science'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chemistry'), findsOneWidget);
    expect(find.text('Science'), findsNothing);
  });

  testWidgets('the filter survives a level change and clears at Subject',
      (tester) async {
    await tester.pumpWidget(
      sectionHarness(level: TableLevel.topic, subjectId: 'science'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lesson'));
    await tester.pumpAndSettle();
    expect(find.text('Science lessons'), findsOneWidget);

    await tester.tap(find.text('Subject'));
    await tester.pumpAndSettle();
    expect(find.text('SUBJECT'), findsOneWidget);
    expect(find.textContaining('Science '), findsNothing);
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/progress/presentation/widgets/subject_scope_test.dart`
Expected: FAIL, `No named parameter with the name 'scopeLabel'`.

- [ ] **Step 3: Extend `TableHead` and write the sheet**

- [ ] **Step 4: Run the tests and make sure they pass**

- [ ] **Step 5: Add the fourth preference key**

Plan 1 stored three: sort, direction, level. Add **`progress_table_subject`**, a nullable
subject id, governed by the same retain flag. Update `TableOrder` to carry it and extend
Plan 1's round-trip tests.

Run: `flutter test test/features/progress/`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(progress): make the left head cell the subject filter

It was the one thing in that row that named data and governed nothing, so
it becomes the scope at zero added height. Inert at Subject level, because
filtering four rows to one is not a thing anyone wants.

The list opens as a sheet over the mock's existing wash rather than
inline, which would jump the table 130px and move the rows being read.
While filtered the subtext column drops, since every row repeats the
filter otherwise.

No Settings row governs any of this. Controls appear when they can do
something, which is the rule the Time head and the Lesson label already
followed."
```

---

### Task 3: The level control

**Files:**
- Create: `lib/features/progress/presentation/widgets/level_control.dart`
- Test: `test/features/progress/presentation/widgets/level_control_test.dart`

**Interfaces:**
- Consumes: `TableLevel` from Plan 1; `entitlementProvider`.
- Produces: `class LevelControl extends StatelessWidget` taking
  `({required TableLevel level, required bool isPro, required bool lessonAvailable, required ValueChanged<TableLevel> onChanged})`.

**Three labels in the section header's right slot: Subject · Topic · Lesson.** 12px,
`inkMuted`, active in `ink` at 700, separated by **1px by 11px `rule` ticks**. **No pills.
Nothing hidden behind a picker.**

**Free is fixed at Subject**, and sees the other two labels **dimmed rather than hidden**,
so it knows what Pro opens. Tapping a dimmed label routes to the paywall.

**Lesson level depends on lesson tagging.** Questions carry a `topicId` and no `lessonId`
today. **If Progress ships first, the Lesson label is absent, not dimmed and not empty.**
Absent and dimmed are different states carrying different promises: dimmed says "pay for
this", absent says "this does not exist yet", and showing a Free user a dimmed Lesson
label would sell something that cannot be delivered.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('three labels, active in ink at 700', (tester) async {
    await tester.pumpWidget(
      harness(level: TableLevel.topic, isPro: true, lessonAvailable: true),
    );
    expect(
      tester.widget<Text>(find.text('Topic')).style?.fontWeight,
      FontWeight.w700,
    );
    expect(
      tester.widget<Text>(find.text('Subject')).style?.color,
      AppColors.light.inkMuted,
    );
  });

  testWidgets('Free sees Topic and Lesson dimmed, not hidden',
      (tester) async {
    await tester.pumpWidget(
      harness(level: TableLevel.subject, isPro: false, lessonAvailable: true),
    );
    expect(find.text('Topic'), findsOneWidget);
    expect(find.text('Lesson'), findsOneWidget);
  });

  testWidgets('Free cannot change the level', (tester) async {
    final changes = <TableLevel>[];
    await tester.pumpWidget(
      harness(isPro: false, lessonAvailable: true, onChanged: changes.add),
    );
    await tester.tap(find.text('Topic'));
    expect(changes, isEmpty);
  });

  testWidgets('without lesson tagging the label is absent, not dimmed',
      (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(
        harness(isPro: isPro, lessonAvailable: false),
      );
      expect(find.text('Lesson'), findsNothing);
      expect(find.text('Subject'), findsOneWidget);
      expect(find.text('Topic'), findsOneWidget);
    }
  });

  testWidgets('no pills and no picker', (tester) async {
    await tester.pumpWidget(harness(isPro: true, lessonAvailable: true));
    expect(find.byType(Chip), findsNothing);
    expect(find.byType(DropdownButton<Object>), findsNothing);
    expect(find.byType(SegmentedButton<Object>), findsNothing);
  });
```

- [ ] **Step 2 to 5: fail, implement, pass, commit**

```bash
git commit -m "feat(progress): add the level control

Free sees Topic and Lesson dimmed so it knows what Pro opens. Lesson is
absent rather than dimmed until questions carry a lessonId, because
dimmed says pay for this and absent says this does not exist yet, and
selling the first when the second is true is a promise the app cannot
keep."
```

---

### Task 4: The section

**Files:**
- Create: `lib/features/progress/presentation/widgets/performance_section.dart`
- Modify: `lib/features/progress/presentation/progress_page.dart`
- Test: `test/features/progress/presentation/widgets/performance_section_test.dart`

**Interfaces:**
- Consumes: everything above, plus `tableOrderProvider` from Plan 1 and `DataRowTile`.
- Produces: `class PerformanceSection extends ConsumerWidget`.

**The title is "Performance"**, not "Performance breakdown": the shorter title leaves room
for the level control in the header's right slot.

**The header does not draw its own rule when a table head follows it**, because the head
draws one. **Two rules four pixels apart is the fault caught on the eighth pass.**

**Default order: Score, ascending.** Weakest first, which is the actionable direction.

**Colour.** Severity applies to accuracy wherever accuracy appears. **A row's colour never
changes because the table was re-sorted**, so compute it from the accuracy and never from
the row's position.

**When time is not measurable, one line explains it:**

> Your pace per question appears here after your first full length mock, because that is
> the only place the app can measure you against a real clock.

**A row at Lesson level opens `/lesson/:lessonId`**, the reader, which is the only level
with a destination. Use `context.push`, since the reader sits outside the tab shell.
**Subject and topic rows are not launchers**: the table is a reading surface and Home
already owns starting a session. This **amends decision 7** of the decision log, which
sent a topic row into the Study map.

**No ordering explanation is printed**, because the student chose the order.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('opens on Score ascending, weakest first', (tester) async {
    await tester.pumpWidget(harness(rows: mixedRows));
    await tester.pumpAndSettle();

    expect(firstRowTitle(tester), 'Chemistry');
  });

  testWidgets('no rule between the header and the table head',
      (tester) async {
    await tester.pumpWidget(harness(rows: mixedRows));
    await tester.pumpAndSettle();

    final header = find.text('Performance');
    final rules = find.descendant(
      of: find.ancestor(of: header, matching: find.byType(Column)).first,
      matching: find.byKey(const ValueKey('section-header-rule')),
    );
    expect(rules, findsNothing);
  });

  testWidgets('re-sorting never changes a row colour', (tester) async {
    await tester.pumpWidget(harness(rows: mixedRows));
    await tester.pumpAndSettle();
    final before = colourOfRow(tester, 'Chemistry');

    await tester.tap(find.text('SCORE'));
    await tester.pumpAndSettle();

    expect(colourOfRow(tester, 'Chemistry'), before);
  });

  testWidgets('with no mock, the column is absent and the line explains it',
      (tester) async {
    await tester.pumpWidget(harness(rows: mixedRows, timeMeasurable: false));
    await tester.pumpAndSettle();

    expect(find.text('TIME'), findsNothing);
    expect(
      find.textContaining('after your first full length mock'),
      findsOneWidget,
    );
  });

  testWidgets('with no blueprint the size clause drops and the table renders',
      (tester) async {
    await tester.pumpWidget(harness(rows: rowsWithNullSubtext));
    await tester.pumpAndSettle();

    expect(find.textContaining('of 180 questions'), findsNothing);
    expect(find.byType(DataRowTile), findsNWidgets(rowsWithNullSubtext.length));
  });

  testWidgets('a lesson row opens the reader and a topic row does not',
      (tester) async {
    await tester.pumpWidget(harness(level: TableLevel.lesson));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Balancing equations'));
    await tester.pumpAndSettle();
    expect(pushedRoutes, contains('/lesson/chem-04'));

    await tester.pumpWidget(harness(level: TableLevel.topic));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chemistry'));
    await tester.pumpAndSettle();
    expect(pushedRoutes, hasLength(1));
  });

  testWidgets('no board green anywhere in the table', (tester) async {
    await tester.pumpWidget(harness(rows: mixedRows));
    await tester.pumpAndSettle();

    for (final t in tester.widgetList<Text>(
      find.descendant(
        of: find.byType(PerformanceSection),
        matching: find.byType(Text),
      ),
    )) {
      expect(t.style?.color, isNot(AppColors.light.board));
    }
  });

  testWidgets('no ordering explanation is printed', (tester) async {
    await tester.pumpWidget(harness(rows: mixedRows));
    await tester.pumpAndSettle();
    expect(find.textContaining('sorted by'), findsNothing);
    expect(find.textContaining('Showing'), findsNothing);
  });

  testWidgets('the level survives leaving and returning', (tester) async {
    await tester.pumpWidget(harness(rows: mixedRows, isPro: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topic'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(harness(rows: mixedRows, isPro: true));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('Topic')).style?.fontWeight,
      FontWeight.w700,
    );
  });
```

- [ ] **Step 2 to 4: fail, implement, pass**

- [ ] **Step 5: Wire it in and run everything**

```dart
  Widget _performanceSection(BuildContext context, WidgetRef ref) =>
      const PerformanceSection();
```

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```
Expected: PASS, `No issues found!`, no format diff.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(progress): build the performance table

Default Score ascending, weakest first, which is the actionable
direction. Sorting Score descending is the deliberate other case: it is
the view a student screenshots.

The section header draws no rule when a table head follows it. Two rules
four pixels apart was the fault caught on the eighth pass.

A row is not a launcher except at lesson level, where the reader is a
real destination. This amends decision 7, which sent a topic row into the
Study map: the table is a reading surface and Home owns starting a
session."
```

---

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- With no mock sat, the Time column and its head are absent and Score is the sort.
- With no blueprint, the subject subtext drops its "of 180 questions" clause and the table
  still renders.
- Re-sorting the table never changes any row's colour.
- Sort, direction and level survive a tab switch, and the Settings row turns that off.
- `grep -rn "topicAccuracyProvider" lib` shows one definition, not two.
- `grep -rn "severityFor" lib` shows one definition, in `core/ui`.
- Report as text signals and ask Aedwon to look. Never screenshot the emulator.
