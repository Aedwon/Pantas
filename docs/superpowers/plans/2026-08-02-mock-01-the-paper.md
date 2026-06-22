# Mock Exam, Plan 1 of 2: The Paper

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

**Goal:** Make a mock paper run the way its exam actually runs, part by part where the
testing body times parts separately and roamable where it does not, with a floating pager,
a six-column grid grouped by part, and a setup screen that states the rule before the
student commits three hours.

**Architecture:** Two new content fields on the blueprint (`sectionalTiming` and
`scoreBands`) with their parser and migration, a mock variant of the question grid, a new
floating bar widget, and the session page taught to respect part boundaries. The exam's
rules stay content; **no per-exam branching anywhere in `lib/`**.

**Tech Stack:** Flutter, Riverpod, Drift, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-28-mock-exam-ui-design.md` Sections 1, 2
and 3, plus Section 4's "Band thresholds are content".

---

## Why this is one of two plans, not one of five

The spec's own closing note splits its work in two: **the paper** (sectional timing end to
end, the blueprint field, the grid's mock variant, the floating bar, and the setup
screen's statement of the rule) and **the endings** (the results screen, the review
screen, the one-time offer, and the practice variant that replaces
`quiz_results_page.dart`). This plan is the first. Plan 2 is the second.

**The 2 August work checkpoint said this spec still needed a design round.** It did not.
That entry read the spec's two-plan split as two open design questions, and was corrected
on 2 August after Aedwon asked why a settled design was being reopened.

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-content-seed-delivery.md` | `content.db` actually installing | **Blocking to run, not to build.** `MockSetupPage` takes a blueprint as a required argument and `mockBlueprintsProvider` has no callers, so no mock can start at all today. Its Task 1 also asserts the wrong SQLite magic: it expects `'SQLite format 3 '` with a trailing space and the real 16-byte header ends in a NUL. Fix that before executing it |
| `2026-08-02-quiz-tab-04-viewer-and-reveal.md` | `QuestionGridSheet` and `PennantMark` | **Blocking for Tasks 3 and 4.** The mock consumes both; it does not define them |
| Aedwon | `sectionalTiming` for ACET, DCAT and MSU-SASE | **Not blocking.** Nothing may be defaulted, so those three blueprints carry no value and the setup screen says so. That is the designed behaviour, not a gap |

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.** Both databases are
  Drift; run `dart run build_runner build --delete-conflicting-outputs` and do not
  `git add` the output.
- **The exam's rules are content, not code.** `sectionalTiming` and `scoreBands` are the
  third and fourth attributes of this kind, after subject `kind` and the per-exam
  wrong-answer penalty. **If you find yourself writing `if (examId == ...)` anywhere, stop
  and say so.**
- **Nothing may be defaulted.** For an exam whose timing is unpublished, the app states
  that it does not know rather than guessing. A wrong guess about whether a student can go
  back is the most expensive wrong guess this screen can make.
- **No answer, no outcome, no reveal, anywhere in the paper.** The mock inherits nothing
  from the practice quiz's answering experience. Revealing mid-paper destroys both the
  simulation and the practice-versus-pressure comparison `TestModeDeltaSignal` measures.
- **Ink & Rule identity**, with **one named exception**: the floating bar carries radius 8
  and a soft shadow, per Section 3. It is a floating control over scrolling content and
  Aedwon approved it against live mockups. It is the only shadow in the app; do not
  propagate it, and do not "fix" it to match the ban.
- **Voice.** Grade-5-simple English, **no em dashes**. It is an **exam**, and you **take**
  it: never "paper" and never "sit" in a user-facing string. Scores are **points**, never
  "marks". "Diagnostic", "remediation" and "borderline" are banned by Spec 5's copy
  register.
- **Analyzer must be clean.**

## Verification commands

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
dart run build_runner build --delete-conflicting-outputs
```

---

## File structure

| File | Responsibility |
|---|---|
| `lib/core/content/domain/mock_blueprint.dart` (modify) | Gains `sectionalTiming` and `scoreBands` |
| `lib/core/content/tables/content_mock_blueprints.dart` (modify) | Two nullable columns |
| `lib/core/content/content_database.dart` (modify) | Schema 2 to 3, with the migration |
| `lib/core/content/sanity/parsers/mock_blueprint_parser.dart` (modify) | Reads both, absent stays absent |
| `lib/features/mock_exam/domain/use_cases/compute_results.dart` (modify) | `bandFor` takes thresholds instead of hardcoding 75 and 60 |
| `lib/features/mock_exam/presentation/pages/mock_setup_page.dart` (modify) | States the rule, and what is not included |
| `lib/features/mock_exam/presentation/widgets/mock_question_grid.dart` (create) | Six columns, grouped by part, later parts dimmed |
| `lib/features/mock_exam/presentation/widgets/mock_floating_bar.dart` (create) | The pager |
| `lib/features/mock_exam/presentation/pages/mock_session_page.dart` (modify) | Part-bounded paging, the part clock, the app bar |

---

### Task 1: `sectionalTiming` and `scoreBands` as content

**Files:**
- Modify: `lib/core/content/domain/mock_blueprint.dart`,
  `lib/core/content/tables/content_mock_blueprints.dart`,
  `lib/core/content/content_database.dart`,
  `lib/core/content/sanity/parsers/mock_blueprint_parser.dart`
- Test: `test/core/content/sanity/parsers/mock_blueprint_parser_test.dart` (extend)
- Test: `test/core/content/content_database_migration_test.dart` (create or extend)

**Interfaces:**
- Produces:

```dart
/// How the testing body times this exam's parts.
///
/// `null` means unpublished, and it is a real state: ACET, DCAT and
/// MSU-SASE publish nothing. It is never defaulted to either value,
/// because guessing wrong about whether a student can go back is the most
/// expensive wrong guess this app can make.
enum SectionalTiming { sectional, roamable }

/// The percentage at which this exam calls a score a pass, and the one
/// above which it is close. Content, per exam. `null` means the exam has
/// not published them.
@immutable
class ScoreBands {
  const ScoreBands({required this.passAtPercent, required this.closeAtPercent});
  final int passAtPercent;
  final int closeAtPercent;
}
```

`MockBlueprint` gains `final SectionalTiming? sectionalTiming;` and
`final ScoreBands? scoreBands;`. `BlueprintSection` gains
`final int? sectionalMinutes;`, the per-part limit, which is meaningful only when
`sectionalTiming == SectionalTiming.sectional`.

**`scoreBands` is here rather than in Plan 2** because it is content and this is the
content task. Section 4 of the spec already settled its design twice: "Band thresholds are
content. Spec 5 puts `scoreBands` on the exam doctype in Sanity with a fallback of 75 and
60. Nothing is hardcoded." What was missing was only the column, the parser and the
argument. `ComputeResults.bandFor` hardcodes 75 and 60 today
(`compute_results.dart:82-83`), which the 17 May spec called a stand-in.

**Absent is absent.** A blueprint with no `sectionalTiming` key parses to `null`, not to a
default. Assert that in the test, because a parser that quietly fills in a value is how a
student gets told they can go back on an exam where they cannot.

- [ ] **Step 1: Write the failing test**

```dart
  test('a blueprint with no timing parses to null, not a default', () {
    final blueprint = parser.parse(jsonWithout('sectionalTiming'));
    expect(blueprint.sectionalTiming, isNull);
  });

  test('sectional and roamable both round-trip', () {
    expect(
      parser.parse(jsonWith(sectionalTiming: 'sectional')).sectionalTiming,
      SectionalTiming.sectional,
    );
    expect(
      parser.parse(jsonWith(sectionalTiming: 'roamable')).sectionalTiming,
      SectionalTiming.roamable,
    );
  });

  test('an unrecognised timing value is null, never a guess', () {
    expect(parser.parse(jsonWith(sectionalTiming: 'wibble')).sectionalTiming,
        isNull);
  });

  test('score bands round-trip and absent stays absent', () {
    expect(
      parser.parse(jsonWith(pass: 70, close: 55)).scoreBands?.passAtPercent,
      70,
    );
    expect(parser.parse(jsonWithout('scoreBands')).scoreBands, isNull);
  });

  test('a per-section minute limit round-trips', () {
    final sections =
        BlueprintSection.parseList(sectionsJsonWithMinutes(first: 30));
    expect(sections.first.sectionalMinutes, 30);
  });

  test('a section with no limit is null', () {
    final sections = BlueprintSection.parseList(sectionsJsonWithoutMinutes());
    expect(sections.first.sectionalMinutes, isNull);
  });
```

And a migration test:

```dart
  test('a schema 2 database opens at 3 with both columns null', () async {
    // Open at 2, insert a blueprint row, close, reopen at 3.
    final row = await db.select(db.contentMockBlueprints).getSingle();
    expect(row.sectionalTiming, isNull);
    expect(row.scoreBandsJson, isNull);
  });
```

- [ ] **Step 2: Run them to make sure they fail**

Run: `flutter test test/core/content/`
Expected: FAIL, `The getter 'sectionalTiming' isn't defined`.

- [ ] **Step 3: Add the columns and bump the content schema**

```dart
  TextColumn get sectionalTiming => text().nullable()();
  TextColumn get scoreBandsJson => text().nullable()();
```

`content_database.dart` goes from `schemaVersion => 2` to `3`, with an `onUpgrade` adding
both columns. **This is the content database, not `app_database.dart`.** Do not touch
`app_database.dart`'s `schemaVersion`, which is 14 and belongs to the other stack.

- [ ] **Step 4: Add the parser reads and the domain fields**

- [ ] **Step 5: Run the generator, then the tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/content/
```
Expected: PASS.

- [ ] **Step 6: Make `bandFor` take its thresholds**

```dart
  /// Thresholds are content, per exam. The 75 and 60 that used to sit here
  /// were a stand-in the 17 May spec named as such. A blueprint that
  /// publishes no bands gets no band printed, which Plan 2's results screen
  /// handles: an unpublished threshold is not a reason to invent one.
  ScoreBand? bandFor({
    required int scoreRaw,
    required int scoreTotal,
    required ScoreBands? bands,
  }) {
    if (bands == null || scoreTotal == 0) return null;
    final percent = (scoreRaw / scoreTotal) * 100;
    if (percent >= bands.passAtPercent) return ScoreBand.pass;
    if (percent >= bands.closeAtPercent) return ScoreBand.close;
    return ScoreBand.fail;
  }
```

**`ScoreBand.borderline` is renamed to `ScoreBand.close`.** "Borderline" is banned by Spec
5's own copy register and the middle band was settled on 28 July as **"Close to passing"**.
Rename the enum value so the code and the copy agree, and fix every reference:
`grep -rn "borderline" lib test`.

**The return type becomes nullable.** A mock whose exam publishes no thresholds gets no
band. Plan 2's results screen draws the score and omits the band line; it does not print
"Fail" because nothing said what passing is.

- [ ] **Step 7: Run everything and commit**

```bash
flutter test
flutter analyze
git add -A
git commit -m "feat(content): make sectional timing and score bands content

Both are properties of the exam, not of the app, and they join subject
kind and the wrong-answer penalty under the same rule. Absent parses to
null and is never defaulted: guessing wrong about whether a student can
go back is the most expensive wrong guess this screen can make.

bandFor no longer hardcodes 75 and 60, which the 17 May spec called a
stand-in, and returns null when the exam published no thresholds.
ScoreBand.borderline becomes ScoreBand.close: borderline is banned by the
copy register and the band is Close to passing."
```

---

### Task 2: The setup screen states the rule

**Files:**
- Modify: `lib/features/mock_exam/presentation/pages/mock_setup_page.dart`
- Test: `test/features/mock_exam/presentation/pages/mock_setup_page_test.dart`

**Interfaces:**
- Consumes: `MockBlueprint.sectionalTiming`, `BlueprintSection.sectionalMinutes`.
- Produces: nothing later tasks read.

**The three statements, and there is no fourth:**

| `sectionalTiming` | The line |
|---|---|
| `sectional` | `This exam runs part by part. Once a part ends you cannot go back.` |
| `roamable` | `You can move around the whole exam.` |
| `null` | `We do not know yet whether this exam lets you go back between parts. This practice run lets you move around the whole thing.` |

**The null case says what the app is doing and why**, because a student who later sits the
real exam and finds it sectional must not feel the app misled them. It is the honest
statement: we do not know, and here is what we chose in the absence of knowing.

**ACET and DCAT must say what is not included.** Both have an essay and DCAT adds a
personality test, and the app has no concept of either. Drive this from the blueprint, not
from the exam id: if the blueprint's section list covers fewer questions than a
`totalPublishedItems` field states, say so. **If that field does not exist, add it to the
blueprint in Task 1 rather than branching on the exam id here.**

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('a sectional exam says you cannot go back', (tester) async {
    await tester.pumpWidget(harness(timing: SectionalTiming.sectional));
    expect(
      find.text(
        'This exam runs part by part. Once a part ends you cannot go back.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a roamable exam says you can move around', (tester) async {
    await tester.pumpWidget(harness(timing: SectionalTiming.roamable));
    expect(find.text('You can move around the whole exam.'), findsOneWidget);
  });

  testWidgets('an unknown exam says it does not know', (tester) async {
    await tester.pumpWidget(harness(timing: null));
    expect(find.textContaining('We do not know yet'), findsOneWidget);
  });

  testWidgets('the rule is stated before the start control', (tester) async {
    await tester.pumpWidget(harness(timing: SectionalTiming.sectional));
    final ruleY = tester.getTopLeft(find.textContaining('part by part')).dy;
    final buttonY = tester.getTopLeft(find.byType(BoardButton)).dy;
    expect(ruleY, lessThan(buttonY));
  });

  testWidgets('the copy never says paper or sit', (tester) async {
    for (final timing in [null, ...SectionalTiming.values]) {
      await tester.pumpWidget(harness(timing: timing));
      expect(find.textContaining('paper'), findsNothing);
      expect(find.textContaining('sit '), findsNothing);
      expect(find.textContaining('—'), findsNothing);
    }
  });
```

- [ ] **Step 2 to 5: fail, implement, pass, commit**

```bash
flutter test test/features/mock_exam/presentation/pages/mock_setup_page_test.dart
```

```bash
git commit -m "feat(mock): state the timing rule before the exam starts

It is the thing a student most wants to know before committing three
hours, and for the three exams that publish nothing the screen says so
rather than implying either answer."
```

---

### Task 3: The grid's mock variant

**Files:**
- Create: `lib/features/mock_exam/presentation/widgets/mock_question_grid.dart`
- Test: `test/features/mock_exam/presentation/widgets/mock_question_grid_test.dart`

**Interfaces:**
- Consumes: `QuestionGridSheet` and `PennantMark` from Quiz Plan 4. **Check what
  `QuestionGridSheet` exposes before writing this.** The Quiz spec says it is built at six
  columns for the mock, so it may already take a column count and a grouping, in which
  case this file is a thin configuration and not a second grid.
- Produces: `class MockQuestionGrid extends StatelessWidget` taking
  `({required List<MockGridPart> parts, required int currentIndex, required ValueChanged<int> onTap})`
  and `class MockGridPart { String name; int startIndex; int count; bool isOpen; }`.

**Six columns, grouped by part, with a count on each part heading.**

**The cell states, from Section 1, and no outcome is ever shown:**

| State | Number | Mark |
|---|---|---|
| Untouched | `inkMuted`, serif 15/400 | none |
| Answered | `ink`, serif 15/600 | a 5px `amber` dot |
| Flagged | `ink`, serif 15/600 | the pennant at 12px, `inkMuted` |
| Answered and flagged | `ink`, serif 15/600 | **both**, dot then pennant, 4px apart |
| Current | as its own state above | the caret in the reserved slot |

**Both marks show together** because answered is progress and flagged is doubt, and
"answered but unsure" is the most common state in a real exam.

**A part that has not opened renders dimmed to 32% and untappable**, with
`Opens when this part starts.` beneath its heading. Visible rather than hidden, because
knowing what is coming and how much is left is what a printed booklet gives you.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('six columns', (tester) async { /* ... */ });

  testWidgets('each part heading carries its count', (tester) async {
    await tester.pumpWidget(harness(parts: [part('Reading', 40), part('Maths', 30)]));
    expect(find.text('40'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
  });

  testWidgets('answered and flagged shows both marks', (tester) async {
    await tester.pumpWidget(harness(cell: answeredAndFlagged));
    expect(find.byKey(const ValueKey('mock-cell-dot')), findsOneWidget);
    expect(find.byType(PennantMark), findsOneWidget);
  });

  testWidgets('no cell ever shows an outcome', (tester) async {
    await tester.pumpWidget(harness(parts: aFullPaperWithKnownAnswers));
    expect(find.text('✓'), findsNothing);
    expect(find.text('✗'), findsNothing);
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(t.style?.color, isNot(AppColors.light.rust));
      expect(t.style?.color, isNot(AppColors.light.board));
    }
  });

  testWidgets('an unopened part is dimmed and untappable', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(
      harness(parts: [openPart, closedPart], onTap: taps.add),
    );
    await tester.tap(find.text('41'), warnIfMissed: false);
    expect(taps, isEmpty);
    expect(find.text('Opens when this part starts.'), findsOneWidget);
  });
```

**That third test is the one that matters most.** A grid cell that leaks correctness would
destroy the simulation silently, and nothing else in the app would catch it.

- [ ] **Step 2 to 5: fail, implement, pass, commit**

```bash
git commit -m "feat(mock): the question grid at six columns, grouped by part

No cell ever shows an outcome. Later parts render dimmed and untappable
rather than hidden, because knowing what is coming and how much is left
is what a printed booklet gives you."
```

---

### Task 4: The floating bar

**Files:**
- Create: `lib/features/mock_exam/presentation/widgets/mock_floating_bar.dart`
- Test: `test/features/mock_exam/presentation/widgets/mock_floating_bar_test.dart`

**Interfaces:**
- Consumes: `PennantMark` from Quiz Plan 4.
- Produces: `class MockFloatingBar extends StatelessWidget` taking
  `({required int position, required int total, required bool isFlagged, required VoidCallback? onPrevious, required VoidCallback? onNext, required VoidCallback onGrid, required VoidCallback onFlag})`.

```
‹ previous  |  ▦ · 12 of 40 · ⚑  |  next ›
```

- Pinned 14px from the bottom and each side, **54px tall**, 1px `rule` border,
  **radius 8**, on `background`, with a soft shadow. This is the app's one approved
  shadow, per the Global Constraints.
- **Previous leftmost, next rightmost**, the three middle controls between them.
- **Base gap 16px, with +5px on the grid side.** An optical correction, not an
  inconsistency: the grid glyph is a solid 3x3 block dense to its edges while the pennant
  is open on its lower right and carries its own whitespace, so equal metric gaps read
  unequal. **Do not normalise this to 16.**
- The **grid glyph** is nine filled squares, 5.4px each with 1.6px gaps in a 24 viewBox,
  drawn at 19px. **Both it and the counter open the grid**, so the counter is a control,
  not a label.
- Controls are **46px targets**.
- **Previous dims at the first item of a part, next at the last.** Pass `null` for the
  handler and render at reduced opacity; do not hide either control, because a control
  that vanishes moves the ones beside it.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('previous is leftmost and next is rightmost', (tester) async {
    await tester.pumpWidget(harness());
    final prevX = tester.getCenter(find.byKey(const ValueKey('mock-prev'))).dx;
    final gridX = tester.getCenter(find.byKey(const ValueKey('mock-grid'))).dx;
    final nextX = tester.getCenter(find.byKey(const ValueKey('mock-next'))).dx;
    expect(prevX, lessThan(gridX));
    expect(gridX, lessThan(nextX));
  });

  testWidgets('the counter opens the grid too', (tester) async {
    var opened = 0;
    await tester.pumpWidget(harness(onGrid: () => opened++));
    await tester.tap(find.text('12 of 40'));
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    expect(opened, 2);
  });

  testWidgets('previous dims at the first item and stays in place',
      (tester) async {
    await tester.pumpWidget(harness(onPrevious: null));
    final before = tester.getCenter(find.byKey(const ValueKey('mock-grid')));
    expect(find.byKey(const ValueKey('mock-prev')), findsOneWidget);
    await tester.pumpWidget(harness(onPrevious: () {}));
    expect(tester.getCenter(find.byKey(const ValueKey('mock-grid'))), before);
  });

  testWidgets('every control reaches 46', (tester) async {
    await tester.pumpWidget(harness());
    for (final key in ['mock-prev', 'mock-grid', 'mock-flag', 'mock-next']) {
      final size = tester.getSize(find.byKey(ValueKey(key)));
      expect(size.width, greaterThanOrEqualTo(46));
      expect(size.height, greaterThanOrEqualTo(46));
    }
  });

  testWidgets('the bar is 54 tall', (tester) async {
    await tester.pumpWidget(harness());
    expect(tester.getSize(find.byType(MockFloatingBar)).height, 54);
  });
```

- [ ] **Step 2 to 5: fail, implement, pass, commit**

```bash
git commit -m "feat(mock): add the floating pager

The mock has one and the practice quiz does not: in practice you move
forward and the reveal is the event, and in a mock you move both ways
constantly with nothing ever revealed, so paging is the primary
interaction. It also frees the app bar for the clock, which must never be
hunted for.

The +5px on the grid side is an optical correction, not an
inconsistency. Do not normalise it."
```

---

### Task 5: The session respects part boundaries

**Files:**
- Modify: `lib/features/mock_exam/presentation/pages/mock_session_page.dart`
- Modify: `lib/features/mock_exam/application/mock_session_controller.dart`
- Test: `test/features/mock_exam/application/mock_session_controller_test.dart`

**Interfaces:**
- Consumes: everything above.
- Produces: on the controller, `int get currentPartIndex`, `bool get canGoPrevious`,
  `bool get canGoNext`, `Duration get remainingInPart`, and
  `Future<void> closeCurrentPart()`.

**When `sectionalTiming == SectionalTiming.sectional`:**

- **Previous and next stop at the part boundary.** They do not wrap and they do not cross.
- **The clock counts the part**, not the exam, and it comes from that section's
  `sectionalMinutes`.
- **A finished part cannot be reopened**, ever, including by the grid.
- **The caret can never cross a part boundary while answering**, which is why the caret's
  margin transition happens only in the review or in a roamable exam. Plan 2 owns the
  review side of that.

**When it is `roamable` or `null`, the whole exam is one part** and every rule above is
vacuously satisfied by a single-part list. Build it that way rather than branching: one
code path, and the blueprint decides how many parts there are.

**The app bar carries the clock alone, centred, serif 16/700, tabular.** No title, no
trailing element.

- [ ] **Step 1: Write the failing test**

```dart
  test('next stops at the last item of a part', () async {
    // Parts of 40 and 30, currently at index 39.
    expect(controller.canGoNext, isFalse);
  });

  test('a roamable exam is one part and pages the whole way', () async {
    // sectionalTiming null, 70 questions, at index 39.
    expect(controller.canGoNext, isTrue);
  });

  test('a closed part cannot be reopened, even by the grid', () async {
    await controller.closeCurrentPart();
    await controller.goTo(3); // an index inside the closed part

    expect(controller.currentIndex, isNot(3));
  });

  test('the clock counts the part, not the exam', () async {
    // Part one is 30 minutes of a 180 minute exam.
    expect(controller.remainingInPart, lessThanOrEqualTo(
      const Duration(minutes: 30),
    ));
  });

  test('closing the last part ends the exam', () async { /* ... */ });
```

- [ ] **Step 2 to 4: fail, implement, pass**

- [ ] **Step 5: Run everything**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```
Expected: PASS, `No issues found!`, no format diff.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(mock): run the exam part by part where the exam does

One code path: a roamable exam is a single-part list, so every boundary
rule is vacuously satisfied and nothing branches on an exam id.

The clock counts the part. A finished part cannot be reopened, including
from the grid, which is what UPCAT means by not returning to a subtest
once time is called."
```

---

## What this plan deliberately leaves undone

- **The results and review screens.** Plan 2.
- **The pause and strict-forfeit flows, the section-transition moment, the warning
  overlays, and mock history.** The spec lists all five as not designed here and says Spec
  5's sketches stand until redrawn. Do not design them inside this plan.
- **The three unknown exams.** `sectionalTiming` stays absent for ACET, DCAT and MSU-SASE
  until Aedwon establishes them, and Task 2 renders the honest statement meanwhile.

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- `grep -rn "examId ==" lib/features/mock_exam lib/core/content` returns nothing. The
  exam's rules are content.
- `grep -rn "borderline" lib test` returns nothing.
- No grid cell and no bar control shows correctness in any state.
- `app_database.dart`'s `schemaVersion` is still **14**. Only `content_database.dart` moved,
  from 2 to 3.
- Report as text signals and ask Aedwon to look. Never screenshot the emulator.
