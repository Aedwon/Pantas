# Study Tab, Plan 5 of 5: The Endings Implementation Plan

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

**Goal:** The page the last pull lands on: a bookplate for a finished topic, the same plate
with an unread list for one stopped short, a link to what comes next, and the single line
that ends a day.

**Architecture:** One closing page reached by the same pull that moves between lessons, so
the gesture never dies on a handle that goes nowhere. Its content is chosen by a small pure
function over the topic's read state, which is what makes the three endings testable without
pumping a widget.

**Tech Stack:** Flutter, Riverpod, `flutter_test`. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-27-study-tab-and-reader-design.md`,
Section 5.

**Depends on Plan 4** for `PullToAdvance` and `ReaderContext`, and **Plan 2** for
`studyMapProvider`.

## The idea the whole plan is built on

**Ceremony scales with rarity.** A day ends daily. A topic ends eighteen times in an entire
UPCAT campaign. Treating both the same makes the daily one exhausting within a week and
drains the rare one of meaning. So: a topic gets a plate, and a day gets one sentence.

**The ending is a page in the chain.** The last pull works one final time and lands on it.
**There is no pull on the closing page itself**: if the pull also started the next topic the
run would never end, which would spend the ending entirely.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.**
- **Layering (`tool/check_layering.dart`).** R1, R2, R3 as elsewhere.
- **Analysis is `very_good_analysis` with `strict-casts` and `strict-inference`.**
- **Never invent a figure, and this plan is where that rule bites hardest.** See Task 2.
- **No em dashes.** There is exactly one deliberate copy exception in this plan, the
  contraction in "That's enough for today.", and it is called out where it appears.
- **Widget tests use `test/helpers/pump_app.dart`**, extensions on `WidgetTester`.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/features/lesson/domain/models/lesson_ending.dart` — which ending this is, and what it
  carries. Pure.
- `lib/features/lesson/domain/use_cases/decide_ending.dart` — the choice. Pure.
- `lib/features/lesson/presentation/pages/topic_ending_page.dart`
- `lib/features/lesson/presentation/widgets/bookplate.dart`
- `lib/features/lesson/presentation/widgets/next_topic_block.dart`
- the matching tests under `test/features/lesson/`.

**Modify:**
- `lib/app/router.dart` — `/study/ending/:topicId`.
- `lib/features/lesson/presentation/widgets/pull_to_advance.dart` — the last lesson's pull
  now has somewhere to go.
- `lib/features/lesson/presentation/lesson_page.dart` — pass it.

---

## Task 1: Which ending is this

**Files:**
- Create: `lib/features/lesson/domain/models/lesson_ending.dart`
- Create: `lib/features/lesson/domain/use_cases/decide_ending.dart`
- Test: `test/features/lesson/domain/decide_ending_test.dart`

**Interfaces:**
- Consumes: `StudyMap`, `StudyTopic` from Plan 2.
- Produces: `sealed class LessonEnding` with `TopicFinished`, `TopicStoppedShort` and
  `DayFinished`; and `LessonEnding decideEnding({required StudyTopic topic, required
  StudySubject subject, required String examShortName, required String? studentName,
  required DateTime today, required StudyTopic? nextTopic})`. Tasks 2 to 4 render each case.

**Three endings, and the rule that picks one:**

| Ending | When | What it draws |
|---|---|---|
| `TopicFinished` | every lesson in the topic is read | the bookplate, then the next topic block |
| `TopicStoppedShort` | the topic's last lesson was reached with unread lessons behind it | the same plate with a different footing, then the unread list |
| `DayFinished` | the day's plan is done | one line, no plate |

**`DayFinished` cannot fire yet** and the plan does not pretend otherwise: the study plan's
providers throw and its entry row is hidden, so nothing knows what a day is. The case exists
in the sealed class and has its own widget, and `decideEnding` never returns it until a plan
is passed in. **Building it now is deliberate**, because the copy is settled and the
alternative is rewriting the page when plans land.

- [ ] **Step 1: Write the failing test**

```dart
  test('every lesson read is a finished topic', () {
    final ending = decideEnding(
      topic: topicWith(read: 9, total: 9),
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: 'Aedwon',
      today: DateTime(2026, 7, 27),
      nextTopic: geometry,
    );

    expect(ending, isA<TopicFinished>());
    expect((ending as TopicFinished).footing, '9 lessons, all read');
  });

  test('one lesson is singular', () {
    final ending = decideEnding(
      topic: topicWith(read: 1, total: 1),
      ...
    );

    expect((ending as TopicFinished).footing, '1 lesson, all read');
  });

  test('lessons left behind is a topic stopped short', () {
    final ending = decideEnding(topic: topicWith(read: 6, total: 9), ...);

    expect(ending, isA<TopicStoppedShort>());
    expect((ending as TopicStoppedShort).footing, '6 of 9 lessons read');
    expect(ending.unread, hasLength(3));
  });

  test('the plate carries the name, the topic, the exam and the subject', () {
    final ending = decideEnding(...) as TopicFinished;

    expect(ending.studentName, 'Aedwon');
    expect(ending.topicName, 'Arithmetic & Number Sense');
    expect(ending.examAndSubject, 'UPCAT, Mathematics');
  });

  test('a skipped name leaves the line absent rather than empty', () {
    final ending = decideEnding(studentName: null, ...) as TopicFinished;

    expect(ending.studentName, isNull);
  });

  test('the date is written out, not a machine format', () {
    final ending = decideEnding(today: DateTime(2026, 7, 27), ...)
        as TopicFinished;

    expect(ending.dateLine, '27 July 2026');
  });

  test('no next topic is allowed, and says so', () {
    final ending = decideEnding(nextTopic: null, ...) as TopicFinished;

    expect(ending.next, isNull);
  });
```

- [ ] **Step 2 to 4: Run, build, run again**

The next-topic meta line reads like "Eight lessons, about an hour and forty of material."
**That sentence is `estimatedMinutes` summed over the topic**, which is a property of the
material, and the phrasing must keep saying so: "of material", never "of your time". Build
it as a helper on `TopicFinished` and test the awkward cases, an hour exactly and under an
hour.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/features/lesson/domain test/features/lesson/domain
git commit -m "feat(study): decide which ending a run has reached

Three endings and one rule, kept pure so the singular and plural cases
are tested without pumping a page."
```

---

## Task 2: The bookplate

**Files:**
- Create: `lib/features/lesson/presentation/widgets/bookplate.dart`
- Test: `test/features/lesson/presentation/bookplate_test.dart`

**Interfaces:**
- Consumes: `TopicFinished` and `TopicStoppedShort` from Task 1.
- Produces: `Bookplate({required String? studentName, required String topicName, required
  String examAndSubject, required String footing, required String dateLine})`.

**The composition:**

```
              Aedwon
    ─────────────────────────
      Arithmetic & Number Sense
        UPCAT, Mathematics
    ─────────────────────────
         9 lessons, all read
            27 July 2026
```

| Line | Style |
|---|---|
| Name | serif 14, `inkMuted`, closed by a 1px `ruleFaint`, 16px below |
| Topic | serif 31/700, tracking -0.6 |
| Exam and subject | 11.5, `inkMuted`, 5px below the topic |
| Footing | 12, `inkMuted`, opened by a 1px `ruleFaint` 14px above |
| Date | 12, `inkMuted`, italic, on its own line |

A hairline box, 1px `rule`, padding 28 by 20, centred. It fades in and rises 8px over 500ms
on the standard curve, 160ms after entry.

**The box is a deliberate exception** to the identity's rule that grouping comes from
whitespace and hairline rules rather than boxes. The ban exists to stop cards being used as
generic grouping. This is not grouping: it is a single object, once, at the end of a run, and
an object is what gives it edges to become an artifact.

**There is no figure on this plate, and none may be added.** Every honest figure was
unavailable and every available one said nothing:

- "11 lessons" restates what the reader just did and what the map already shows, and a 52px
  numeral is what made an earlier draft read as a stats card.
- Any time figure would be `estimatedMinutes`, which describes the material and not the
  student. **Printing an estimate under someone's name, on a page meant to feel earned, is
  the worst possible thing to be approximate about.**

The footing line is the only count, and it is a count of lessons, phrased as a fact about the
topic.

**The name comes from onboarding and is skippable**, so the composition must work with the
name line absent and not look truncated. That is a test, not a note.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the plate carries every line in order', (tester) async {
    await pumpPlate(tester);

    expect(find.text('Aedwon'), findsOneWidget);
    expect(find.text('Arithmetic & Number Sense'), findsOneWidget);
    expect(find.text('UPCAT, Mathematics'), findsOneWidget);
    expect(find.text('9 lessons, all read'), findsOneWidget);
    expect(find.text('27 July 2026'), findsOneWidget);
  });

  testWidgets('a skipped name leaves no gap where it was', (tester) async {
    await pumpPlate(tester, studentName: null);
    final without = tester.getSize(find.byType(Bookplate)).height;

    await pumpPlate(tester, studentName: 'Aedwon');
    final with_ = tester.getSize(find.byType(Bookplate)).height;

    expect(without, lessThan(with_));
    expect(find.text('Aedwon'), findsNothing);
  });

  testWidgets('the plate prints no figure but the footing', (tester) async {
    await pumpPlate(tester);

    // No bare numeral anywhere: the counts live inside the footing sentence.
    expect(find.text('9'), findsNothing);
    expect(find.textContaining('min'), findsNothing);
  });

  testWidgets('a topic stopped short changes only the footing',
      (tester) async {
    await pumpPlate(tester, footing: '6 of 9 lessons read');

    expect(find.text('6 of 9 lessons read'), findsOneWidget);
    expect(find.textContaining('The end of'), findsNothing);
  });
```

The last assertion guards a deletion: an earlier draft had a headline, "The end of Algebra",
and it was **deleted rather than rewritten** because the plate states the fact and a headline
has no job. Nothing on this page reads as a scolding.

- [ ] **Step 2 to 4: Run, build, run again, then commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): the bookplate

A box, which the identity bans for grouping. This is not grouping: it is
one object at the end of a run, and the edges are what make it an
artifact. It carries no figure, deliberately."
```

---

## Task 3: The closing page

**Files:**
- Create: `lib/features/lesson/presentation/pages/topic_ending_page.dart`
- Create: `lib/features/lesson/presentation/widgets/next_topic_block.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/lesson/presentation/topic_ending_page_test.dart`

**Interfaces:**
- Consumes: `decideEnding` (Task 1), `Bookplate` (Task 2).
- Produces: `TopicEndingPage({required TopicId topicId})` at `/study/ending/:topicId`.

**The bar: back control only.** No bookmark, since there is no lesson to act on. No contents
glyph, because "Back to Study" already lands on the map with the topic still expanded and
every lesson one tap away, so a sheet would be duplicate navigation.

**The rail runs to 100% as the page arrives**, 120ms after entry, over 550ms on
`cubic-bezier(.22, 1, .36, 1)`.

**A finished topic** shows the plate, then a block opened by a 1px rule:

```
Next
Geometry
Eight lessons, about an hour and forty of material.
```

Kicker 11.5 `inkMuted`, name serif 17/700, meta 12.5 `inkMuted`, with a **static chevron** on
the right. It is a link, not the pull. Finishing a topic is the best moment there will ever
be to make the next one look small, and "eight lessons, about an hour and forty" is what
makes it look small.

**A topic stopped short** shows the same plate with the other footing, then a block: the
kicker "Still unread" in 11.5 `inkMuted`, then the remaining lessons as rows with their
minutes and a chevron each.

**The exit** is a ruled row opened by a 1px rule, 15px vertical padding, centred, reading
"Back to Home" or "Back to Study" in 14/600 **`board`**. Within the colour budget rather than
an exception: the closing page has exactly one action, so this is its primary action. A
filled green button would be shouting about the door on a page whose primary act is already
done. The full row width carries the 48dp target.

**There is no pull on this page.** Assert it.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('a finished topic shows the plate and what is next',
      (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.byType(Bookplate), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Geometry'), findsOneWidget);
  });

  testWidgets('a topic stopped short lists what is unread', (tester) async {
    await pumpEnding(tester, read: 6, total: 9);

    expect(find.text('Still unread'), findsOneWidget);
    expect(find.byType(InkTableRow), findsNWidgets(3));
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('the closing page cannot be pulled onward', (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.byType(PullToAdvance), findsNothing);
  });

  testWidgets('the bar carries a back control and nothing else',
      (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.byType(BookmarkRibbon), findsNothing);
    expect(find.byType(ContentsGlyph), findsNothing);
  });

  testWidgets('the exit is a ruled row, not a filled button', (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.text('Back to Study'), findsOneWidget);
    expect(find.byType(BoardButton), findsNothing);
  });

  testWidgets('the exit row meets the tap target', (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(
      tester.getSize(find.byKey(const ValueKey('ending-exit'))).height,
      greaterThanOrEqualTo(48),
    );
  });
```

- [ ] **Step 2 to 4: Run, build, run again**

Register the route **outside** the shell branches, beside `/lesson/:lessonId`, since the
reader chain is pushed over the tab shell.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): the closing page a finished topic lands on

No pull here: if the pull also started the next topic the run would
never end, and the ending would be spent entirely."
```

---

## Task 4: The day line, and wiring the last pull

**Files:**
- Modify: `lib/features/lesson/presentation/pages/topic_ending_page.dart`
- Modify: `lib/features/lesson/presentation/lesson_page.dart`
- Test: `test/features/lesson/presentation/topic_ending_page_test.dart`

**Interfaces:**
- Consumes: `DayFinished` from Task 1.
- Produces: the day case rendered, and Plan 4's `PullToAdvance` given a destination on the
  last lesson of a topic.

**A finished day: no plate.** One line, centred, with 26px above:

> **That's enough for today.**

Serif 22 (`displaySmall`), tracking -0.2, and **nothing beneath it**. No facts, no count, no
minutes.

Every other candidate reports; this one releases. For a student opening the app late at night
with a countdown in Home's masthead, being told they have done enough is the rarest thing the
app can say, and it manages it with no praise, no adjective and no exclamation.

**Two things this depends on, and both are recorded rather than assumed:**

1. **Home's "Keep going" affordance must stay a real offer**, or the line is the app sending
   someone to bed. Home is unimplemented, so this is a note for whoever plans it, not a
   dependency this plan can satisfy.
2. **The contraction is a deliberate copy exception.** The identity bans em dashes, emoji and
   all-caps and says nothing about contractions, and this line has to sound like a person.
   Do not "correct" it to "That is enough for today."

**This case cannot fire yet.** `decideEnding` never returns `DayFinished` until a study plan
is passed in. Build the widget, test it directly, and leave the wiring for whoever makes
plans real.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('a finished day is one line and nothing else', (tester) async {
    await pumpDayEnding(tester);

    expect(find.text("That's enough for today."), findsOneWidget);
    expect(find.byType(Bookplate), findsNothing);
    expect(find.textContaining('lesson'), findsNothing);
    expect(find.textContaining('min'), findsNothing);
  });

  testWidgets('the day line keeps its contraction', (tester) async {
    await pumpDayEnding(tester);

    expect(find.text('That is enough for today.'), findsNothing);
  });
```

The second test looks pedantic and is not: the contraction is the whole reason the line
works, and it is exactly the kind of thing a later tidy-up removes.

- [ ] **Step 2: Run it to verify it fails**

- [ ] **Step 3: Build it, then wire the last pull**

In `lesson_page.dart`, when `ReaderContext.next` is null, pass `PullToAdvance` an
`onAdvance` that pushes `/study/ending/${context.topicId}` and a label naming the topic
rather than a lesson. Plan 4 left this as `null` with a comment naming this plan; the comment
goes with it.

- [ ] **Step 4: Run the whole suite**

Run: `flutter test`
Expected: PASS. Last task of the last Study plan, so the suite is the gate for the set.

- [ ] **Step 5: Check layering, format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): the day line, and the last pull has somewhere to land

Ceremony scales with rarity: a day ends daily and gets one sentence, a
topic ends eighteen times a campaign and gets the plate."
```

---

## What this plan deliberately does not do

- **No acknowledgment system.** Trophies for finished subjects, an exam-level artifact and a
  shareable card are deferred with reasons. **The bookplate is the seed**: the same
  composition at a larger size, carrying a name, a subject and a date, *is* that card. That
  is also the answer to UI-013, where `wrapped_share_card.dart` still renders a purple and
  navy gradient with nothing of this identity in it.
- **No sharing.** The plate is not rendered to an image here.
- **No day detection.** `DayFinished` is built and unreachable until study plans are real.
- **No reading time on the plate**, now or later without a new decision. If real reading time
  arrives, putting it on the plate is a design question, not a fill-in-the-blank.

## Verification

```bash
flutter analyze                                  # clean
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # no new violations
flutter test                                     # all pass
```

By hand, on a device:

- Finishing the last lesson of a topic and pulling lands on the plate, which rises 8px as it
  fades in.
- The rail runs to full shortly after the page arrives.
- The plate with a name and without a name both look composed.
- A topic stopped short lists the unread lessons and shows no "Next" block.
- The closing page cannot be pulled onward.
- "Back to Study" returns to the map with the topic still expanded.

## Decided without asking, reversible in one line

- **`DayFinished` is built though nothing can reach it.** The copy is settled and the
  alternative is rewriting the page when study plans land.
- **The date reads "27 July 2026"**, written out. The spec draws it that way; no locale
  handling is added, because every string in this app is English today.
- **The next-topic meta says "of material"**, never "of your time". It is
  `estimatedMinutes`, and the phrasing is what keeps it honest.
