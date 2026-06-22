# The Custom Exam Track, Plan B of 2: The Mock a Student Builds Themselves

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
> **Analyzer baseline:** `flutter analyze` reports **25 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. **The number drifts as those tools change; the
> invariant is that `lib/` and `test/` outside `test/tool/` are clean.** Any issue there is
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

## AMENDED 3 August 2026: this plan takes schema version 17, not 16

**Conflict C2, ruled by Aedwon.** The chain is Study 01 at **15**, custom-track-a at **16**,
this plan at **17**.

**Read `from 15 to 16` as `from 16 to 17`** and the guard accordingly.

**Add this step before the bump:**

- [ ] **Step 0: Confirm the current version**

```bash
grep -n "schemaVersion" lib/core/storage/data/app_database.dart
```

Expected: `int get schemaVersion => 16;`. **Anything else means a prerequisite has not landed:
stop and say so.**

---

**Goal:** Let a student on a custom track say how long their exam is and how it breaks down,
and then sit it, using the mock machinery that already exists.

**Architecture:** A student-authored blueprint stored locally, in the same shape
`BlueprintSection` already parses, so `MockSampler`, the session page and the results page
take it without knowing where it came from. One setup screen and three wheel sheets.

**Tech Stack:** Flutter, Riverpod, drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-08-02-custom-exam-track-design.md`, Section 6.

**Decision log:** `docs/superpowers/decisions/2026-08-02-onboarding-name-and-date-log.md`.

**Depends on:** Plan A, for the track and its scope. And on Plan 2c of the quiz work, whose
mock panel this adds two states to.

---

## Why a student may supply the structure, when Pantas may not invent it

The questions sample from the ticked subjects, which works today. **The structure is what
Pantas does not have**: items per section, minutes per section, whether sections are
separately timed. That is the blueprint, and for a real exam it is published by the testing
body. It matters by a factor of three: USTET runs at 22 seconds an item and CSE at 67.

**The evidentiary rule bans figures Pantas inferred, not facts the student gave us.** The exam
date is their assertion. The track name is their assertion. Numbers read off their school's
handout are the same kind of thing.

**So the custom mock carries no readiness verdict and no comparison against a real paper's
difficulty mix**, because those still need something published. It is a timed paper of the
student's own shape, and it says so.

## The claim this plan corrects, and what follows from it

**The mock viewer is not undesigned.** `lib/features/mock_exam/presentation/pages/mock_session_page.dart`
exists and is built. What is true is narrower: `/mock-exam` is a `_Stub` route at
`router.dart:233`, `MockSetupPage` has no callers, and `content_mock_blueprints` holds zero
rows, so no mock can run today.

**Which produces a consequence worth planning around.** A custom track's blueprint is authored
by the student and stored locally. It never touches `assets/seed/content.db`, which is the
broken piece: undeclared in `pubspec.yaml`, with `SeedInstaller` having no callers. **The
custom mock may therefore be the first mock in Pantas that can actually run**, because it is
the only one whose blueprint does not come through that pipeline. Treat that as a feature of
this plan: it exercises the whole mock path before the content delivery is fixed.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand, and never committed.**
- **A schema bump ships with its migration in the same change.**
- **Never invent a figure.** Every number on these screens was typed by the student or
  counted from the corpus. Nothing is estimated.
- **Check the mock feature before writing anything.** `MockSampler`, `BlueprintSection`,
  `StartMock`, `MockSessionPage` and `MockResultsPage` all exist and none of them need
  changing. **There is no custom-specific viewer, sampler or results screen.**
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no coloured left-border panels, no blur, no shimmer. Sheets carry a
  1px `rule` on their top edge, square corners, no shadow.
- **Colour carries meaning.** The setup screen's one board element is "Save". The refusal's
  number turns `rust`.
- **Voice.** Grade-5-simple English, short sentences, **no em dashes**. It is an **exam** and
  you **take** it. **No string leads with what Pantas cannot do.**
- **Layering.** R1, R2, R3. **The baseline is 7 violations.**
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/core/storage/data/tables/custom_blueprints_local_table.dart`
- `lib/features/mock_exam/data/custom_blueprint_repository.dart`
- `lib/features/mock_exam/domain/custom_blueprint.dart` — the student's paper, pure.
- `lib/features/mock_exam/presentation/pages/custom_mock_setup_page.dart`
- `lib/features/mock_exam/presentation/widgets/value_wheel_sheet.dart`
- Tests mirroring each.

**Modify:**
- `lib/core/storage/data/app_database.dart` — the table, the bump, the migration.
- `lib/features/mock_exam/presentation/widgets/mock_panel.dart` — two states.
- `lib/features/mock_exam/application/mock_availability_provider.dart` — the custom path.
- `lib/app/router.dart`.

---

## Task 1: The student's blueprint

**Files:**
- Create: `lib/features/mock_exam/domain/custom_blueprint.dart`
- Create: `lib/core/storage/data/tables/custom_blueprints_local_table.dart`
- Create: `lib/features/mock_exam/data/custom_blueprint_repository.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Test: `test/features/mock_exam/domain/custom_blueprint_test.dart`
- Test: `test/features/mock_exam/data/custom_blueprint_repository_test.dart`

**Interfaces:**
- Produces, relied on by every later task:

```dart
class CustomBlueprintSectionDraft { TopicId? subjectId; String name; int questions; int minutes; }

class CustomBlueprint {
  ExamId examId; int totalQuestions; int totalMinutes;
  List<CustomBlueprintSectionDraft> sections;   // empty means one continuous paper
  bool sectionsTimedSeparately;

  bool get hasBreakdown;
  int get effectiveQuestions;   // the sum when there is a breakdown
  int get effectiveMinutes;
  String toSectionsJson(Map<SubjectId, List<TopicId>> topicsBySubject);
}
```

**`toSectionsJson` emits exactly what `BlueprintSection.parseList` reads**, so the student's
paper enters the existing sampler unchanged. Read `blueprint_section.dart` first and match its
field names and its required types: `id`, `name`, `questionCount`, `suggestedMinutes`,
`topicIds`, and optional weights.

**Without a breakdown it is one continuous paper**, sampled evenly across the ticked subjects.
`BlueprintSection._readWeights` already distributes evenly when weights are absent, so emit
one section covering every scoped topic and **omit the weights entirely** rather than writing
equal ones.

**The breakdown overrides the totals.** Once sections exist, `effectiveQuestions` and
`effectiveMinutes` are their sums. **The sections win because they are the more specific
claim**: a student who sets 120 at the top and enters sections adding to 100 has told us two
things, and nothing else can decide which is the paper.

**Storage is local and per exam.** One blueprint per custom track, replaced on save.

- [ ] **Step 1: Write the failing model test**

```dart
  test('no breakdown means the totals stand', () {
    expect(blueprint.hasBreakdown, isFalse);
    expect(blueprint.effectiveQuestions, 120);
    expect(blueprint.effectiveMinutes, 120);
  });

  test('a breakdown overrides the totals', () {
    // Top rows say 120 and 120; sections sum to 100 and 90.
    expect(blueprint.effectiveQuestions, 100);
    expect(blueprint.effectiveMinutes, 90);
  });

  test('one continuous paper emits one section over every topic', () {
    final sections = BlueprintSection.parseList(
      blueprint.toSectionsJson(topicsBySubject),
    );
    expect(sections, hasLength(1));
    expect(sections.single.topicIds, hasLength(6));
    expect(sections.single.questionCount, 120);
  });

  test('a breakdown emits one section per subject', () { ... });

  test('the emitted json parses with no weights', () {
    // Weights absent, so the sampler distributes evenly on its own.
    expect(sections.single.topicWeights, isEmpty);
  });
```

- [ ] **Step 2 to 4: Run it, write the model and the table, run it again**

The table:

```dart
/// The paper a student described for their own track.
///
/// Local and never synced through the content pipeline: this is the student's
/// assertion about their exam, not a published blueprint, and it is the only
/// blueprint in Pantas that does not arrive through `assets/seed/content.db`.
@DataClassName('CustomBlueprintRow')
class CustomBlueprintsLocal extends Table {
  TextColumn get examId => text().references(Exams, #id)();
  IntColumn get totalQuestions => integer()();
  IntColumn get totalMinutes => integer()();
  TextColumn get sectionsJson => text()();
  BoolColumn get sectionsTimedSeparately =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {examId};
}
```

Bump `schemaVersion` from 15 to 16 **and write the migration in the same change.**

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(mock): a blueprint the student writes

It emits the same sectionsJson BlueprintSection already parses, so the
sampler, the session page and the results page take it without knowing
where it came from. A breakdown overrides the totals because it is the
more specific claim."
```

---

## Task 2: The ceiling

**Files:**
- Create: `lib/features/mock_exam/domain/corpus_ceiling.dart`
- Test: `test/features/mock_exam/domain/corpus_ceiling_test.dart`

**Interfaces:**
- Produces:

```dart
class CorpusFit { int requested; int available; bool get fits; }

abstract final class CheckCorpusFit {
  static CorpusFit call({required int requested, required int available});
}
const questionWheelCeiling = 240;
```

**From the spec, "The ceiling":** a student whose exam really is 150 questions may have ticked
only Science, which holds 60. **Their true answer does not fit.** The wheel therefore runs to
**240** rather than stopping at the corpus, and **the refusal happens at Save**.

**Two alternatives were drawn and rejected, and neither may come back:**

- **Capping the wheel at the corpus** was the original recommendation and was reversed on
  sight. It is the only option that **throws the student's true answer away**: they know their
  exam is 150 items, the app has nowhere to put that, and so Pantas never learns it either.
  That is the same demand-signal argument that makes the naming field valuable.
- **Accepting 150 and running 60**, confessing on the results screen, was ruled out outright.
  A mock sells fidelity. That sells it, delivers a shorter paper, and tells the student only
  after they have sat the whole thing.

**The remaining cost is real and accepted**: a student cannot start any mock, not even a short
one, until they widen. With the Settings link, widening is a single tap and is almost always
what they wanted anyway.

**`available` is counted from the scoped topics**, through Plan A's `scopedTopicsProvider`, so
it follows the track rather than the corpus.

- [ ] **Step 1: Write the failing test**

```dart
  test('a paper the corpus can carry fits', () {
    expect(CheckCorpusFit.call(requested: 60, available: 60).fits, isTrue);
  });

  test('a paper larger than the corpus does not', () {
    expect(CheckCorpusFit.call(requested: 150, available: 60).fits, isFalse);
  });

  test('the wheel reaches 240 whatever the corpus holds', () {
    expect(questionWheelCeiling, 240);
  });
```

- [ ] **Step 2 to 4: Run it, write it, run it again**

- [ ] **Step 5: Commit**

```bash
git commit -m "feat(mock): the corpus fit check

The wheel runs past what the corpus holds on purpose. Capping it is the
one option that throws away the student's true answer, and their answer
is the signal that says which exam to author next."
```

---

## Task 3: The wheel sheets

**Files:**
- Create: `lib/features/mock_exam/presentation/widgets/value_wheel_sheet.dart`
- Test: `test/features/mock_exam/presentation/value_wheel_sheet_test.dart`

**Interfaces:**
- Consumes: `LengthWheel` from Plan 3 of the quiz work, if its column geometry suits.
- Produces:

```dart
Future<int?> showValueWheelSheet({required BuildContext context, required String title,
                                  required List<int> values, required int initial,
                                  String Function(int)? format});
Future<(int, int)?> showTwoColumnWheelSheet({...});
```

**From the spec, "The three pickers":** bottom sheets with a **1px `rule` along the top
edge**, square corners, no shadow. The same shape the Quiz tab's question grid uses. Each
carries a serif 14/700 title and a board 12.5/600 "Done".

| Sheet | Columns | Range and step | Notes |
|---|---|---|---|
| Questions | one | 10 to 240, in fives | No published paper is 117 items long, so fives |
| Time | one | 15 minutes to 6 hours, in fives, rendered `2h 00m` | **One column, not hours beside minutes.** Two columns for a single duration means two gestures to say "two hours" |
| One section | two, labelled Questions and Minutes | as above, per section | **Two columns earn their place here** because these are two different quantities rather than one |

The selected value is serif 21/700 in `ink`, its neighbours sans 19 in `inkMuted`, over a
`boardTint` band, **matching the practice picker's wheel**.

**Reuse `LengthWheel` if you can.** Plan 3 built a horizontal scroll-snapped wheel with a
`boardTint` band at exactly this treatment. Its neighbours are 14.5 where these are 19; add a
size parameter rather than writing a second wheel. **If the geometry genuinely differs enough
that a parameter is a lie, say so and write the second one deliberately.**

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the questions sheet steps in fives', (tester) async {
    expect(questionValues.first, 10);
    expect(questionValues, isNot(contains(117)));
    expect(questionValues.last, 240);
  });

  testWidgets('time renders as hours and minutes', (tester) async {
    expect(formatDuration(120), '2h 00m');
    expect(formatDuration(15), '0h 15m');
  });

  testWidgets('the time sheet is one column', (tester) async { ... });

  testWidgets('the section sheet labels its two columns', (tester) async {
    expect(find.text('Questions'), findsOneWidget);
    expect(find.text('Minutes'), findsOneWidget);
  });

  testWidgets('Done returns the value under the band', (tester) async { ... });
```

- [ ] **Step 2 to 4: Run it, build the sheets, run it again**

- [ ] **Step 5: Commit**

```bash
git commit -m "feat(mock): the setup wheels

One column for a duration, because two columns mean two gestures to say
two hours. Two columns for a section, because questions and minutes are
two different quantities rather than one."
```

---

## Task 4: The setup screen

**Files:**
- Create: `lib/features/mock_exam/presentation/pages/custom_mock_setup_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/mock_exam/presentation/custom_mock_setup_page_test.dart`

**Interfaces:**
- Consumes: Tasks 1, 2 and 3.
- Produces: `/quiz/mock/custom-setup`.

**From the spec, "The setup screen":** a **pushed route** reached from the mock panel, so it
carries an app bar with a back chevron and the word "Quiz", the same treatment the practice
picker gets.

> ‹ Quiz
>
> **Set up your mock**
> We'll build the mock exam based on what you tell us.
>
> Questions                          120  ›
> Time                            2h 00m  ›
> ─────────────────────────────────────────
> I know the section breakdown            ›
>
> You'll be timed here, and you'll get used to it before exam day.
>
> [ Save ]

**Two ruled rows, each opening a wheel.** Not two inline wheels, which would fight for one
screen, and not typed fields, which invite nonsense and raise a keyboard over everything.

**The breakdown is collapsed by default.** Opened, it gives one row per ticked subject taking
items and minutes, plus a single toggle for whether sections are timed separately. **Most
students never open it. The ones who can fill it in have the handout in front of them.**

**Once sections exist, the two top rows stop being editable and become their sum**, drawn in
`ink` with no chevron. **Collapsing the breakdown restores the top rows to editable and keeps
the last summed value.**

**The refusal:**

> Questions                          **150**  ›
>
> ─────────────────────────────────────────────
> You've ticked subjects with 60 questions. A 150 question paper needs more.
> **Tick more subjects ›**
>
> [ Save ]  (dead)

The number stays on screen in `rust`. "Tick more subjects" is a board text action straight to
Settings, "What's included", which Plan A builds. Save is disabled until the corpus can carry
the paper.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the two rows open wheels rather than keyboards',
      (tester) async {
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Questions'));
    await tester.pumpAndSettle();
    expect(find.byType(ValueWheelSheet), findsOneWidget);
  });

  testWidgets('the breakdown is collapsed to begin with', (tester) async {
    expect(find.text('I know the section breakdown'), findsOneWidget);
    expect(find.text('Mathematics'), findsNothing);
  });

  testWidgets('opening the breakdown freezes the totals', (tester) async {
    // Expect the two top rows to lose their chevrons and equal the sum.
  });

  testWidgets('collapsing it restores them and keeps the sum',
      (tester) async { ... });

  testWidgets('a paper larger than the corpus refuses at Save',
      (tester) async {
    expect(
      find.text("You've ticked subjects with 60 questions. A 150 question "
          'paper needs more.'),
      findsOneWidget,
    );
    expect(saveButton.onPressed, isNull);
    // And the number is still on screen.
    expect(find.text('150'), findsOneWidget);
  });

  testWidgets('widening is one tap away', (tester) async {
    expect(find.text('Tick more subjects'), findsOneWidget);
  });

  testWidgets('a paper that fits saves', (tester) async { ... });
```

- [ ] **Step 2 to 4: Run it, build the screen, run it again**

- [ ] **Step 5: Commit**

```bash
git commit -m "feat(mock): setting up your own paper

The refusal keeps the student's number on screen and offers the one tap
that fixes it, because the alternative is throwing away the only thing
they know for certain about their exam."
```

---

## Task 5: The panel's two new states

**Files:**
- Modify: `lib/features/mock_exam/presentation/widgets/mock_panel.dart`
- Modify: `lib/features/mock_exam/application/mock_availability_provider.dart`
- Test: `test/features/mock_exam/presentation/mock_panel_custom_test.dart`

**Interfaces:**
- Consumes: `CustomBlueprintRepository` from Task 1.
- Produces: nothing new. The panel gains a fifth and sixth state.

**From the spec. Nothing set up:**

> **Mock exam**
> You can build your own mock exam. Tell us how many questions and how long it runs, and we'll
> set it up for you.
>
> [ Set one up ]

A secondary button. **No cooldown count, because nothing has been taken.**

**Once set up:**

> **Mock exam**                                                      13d 4h
> 120 questions, 2 hours. You set this up.
> ─────────────────────────────────────────
> **Free users** get one every two weeks. Your next one opens on **15 August**.
>
> Change the setup

"Change the setup" is a board text action, so the numbers are never locked in. Figures, states
and the tier line otherwise follow the quiz spec's Section 1 unchanged.

**The tier rule applies unchanged, and this is not optional.** A custom mock is still a mock:
same corpus, same sampler, same paper. **If custom tracks skipped the cooldown, any Free user
could tick every subject, name the track anything at all, and take unlimited mock exams.**
That is a hole straight through the Pro proposition.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('a custom track with no blueprint offers to build one',
      (tester) async {
    expect(
      find.text('You can build your own mock exam. Tell us how many '
          "questions and how long it runs, and we'll set it up for you."),
      findsOneWidget,
    );
    expect(find.text('Set one up'), findsOneWidget);
    // Nothing has been taken, so there is no count.
    expect(find.textContaining('d '), findsNothing);
  });

  testWidgets('a set up track says what it is', (tester) async {
    expect(find.text('120 questions, 2 hours. You set this up.'),
        findsOneWidget);
    expect(find.text('Change the setup'), findsOneWidget);
  });

  testWidgets('the tier line is stated on a custom track too',
      (tester) async {
    expect(find.textContaining('get one every two weeks'), findsOneWidget);
  });

  testWidgets('a custom track serves the same cooldown', (tester) async {
    // availability: cooldown. Expect no Take button and the count in the
    // header.
  });
```

- [ ] **Step 2 to 4: Run it, add the states, run it again**

`MockPanel` gains `customBlueprint`, nullable. When the exam `isCustom`:

- blueprint null: the "nothing set up" body, secondary "Set one up" pushing
  `/quiz/mock/custom-setup`.
- blueprint present: the summary line, the tier line, "Change the setup", and otherwise the
  ordinary states from Plan 2c.

**Do not branch the cooldown.** `mockAvailabilityProvider` already computes it from the most
recent terminal `submittedAt` and does not care which exam it was, once the exam switching
plan makes it per student. **Until that plan lands it is per exam**, which is the exploit the
switching spec names; note it and do not fix it here, because fixing it in two plans means
fixing it twice.

- [ ] **Step 5: Run the whole suite, then commit**

```bash
flutter test
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(mock): the panel on a custom track

The cooldown applies exactly as it does to a listed exam. Skipping it
would let any free user tick every subject, name a track anything, and
take unlimited papers."
```

---

## What this plan deliberately does not do

- **The mock viewer's redesign.** The mock UI spec is Partial and the paper's own UI is still
  being designed. Nothing in that work is custom-specific: a custom track uses whatever the
  viewer becomes, because it supplies a blueprint and nothing more.
- **The wrong-answer penalty.** Deferred: most CETs do not penalise, and asking about it at
  setup buys little.
- **Making the cooldown per student.** The exam switching plan does it once.
- **A readiness verdict or a difficulty comparison** on a custom mock's results. Both need
  something published.

## Verification

```bash
flutter analyze
dart format --set-exit-if-changed lib test
dart run tool/check_layering.dart                # still 7, not 8
flutter test
```

By hand, on a device:

- A custom track's mock panel offers "Set one up" with no cooldown count.
- The setup screen raises no keyboard: both rows open wheels.
- Setting 150 questions against a 60 question corpus keeps 150 on screen in rust, refuses
  Save, and offers one tap to Settings.
- Opening the breakdown freezes the totals to the sum; collapsing it restores them.
- Saving and starting the mock runs the existing session page, which is the first mock this
  app has ever been able to run.
- A Free user cannot take two custom mocks inside 14 days.

## Self-review notes

Checked against Section 6 in full:

- The blueprint in the sampler's own shape, no custom viewer or sampler: Task 1.
- The breakdown overriding the totals, and the even distribution without one: Task 1.
- The ceiling at 240, the refusal at Save, both rejected alternatives named: Tasks 2, 4.
- Three sheets with their columns, ranges and treatment: Task 3.
- The setup screen's rows, copy and collapse behaviour: Task 4.
- Both panel states and the tier rule applying unchanged: Task 5.
- **One thing deliberately left to another plan**: the cooldown is per exam until the exam
  switching plan makes it per student, which is where that correction belongs.
