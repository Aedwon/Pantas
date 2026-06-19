# Study Tab, Plan 4 of 5: The Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the 113-line lesson page with the reader the spec draws: a bar with an
origin and a bookmark, a title strip that grows on scroll, a progress rail, automatic
read-marking with no button, the quiz coda, and a pull that advances to the next lesson.

**Architecture:** One page rebuilt around a single `ScrollController`, with the chrome, the
gap and the pull as widgets under it. Read-marking becomes an observer of scroll position and
elapsed time rather than a button, which is the fix for every downstream coverage figure:
today they all count button presses. The pull is two stacked widgets on one page driven by an
`AnimationController`, so no route transition and no back stack growth.

**Tech Stack:** Flutter, Riverpod, `go_router`, `flutter_test`. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-27-study-tab-and-reader-design.md`,
Section 4.

**Depends on Plan 1** for `LessonBookmarksRepository` and `pushOpenedLesson`, **Plan 2** for
`studyMapProvider`, and **Plan 3a** for `BookmarkRibbon`. Plan 5 adds the page the last pull
lands on; until it exists the pull on a topic's final lesson does nothing, and Task 6 says so
in code.

## The one thing this plan changes that everything downstream depends on

**A lesson is marked read automatically. There is no button.**

Today `lesson_page.dart` marks read on a `BoardButton` press, so every coverage figure in the
app, Home's, the Study map's and Progress's, is a count of button presses. This plan makes it
a count of lessons whose end was actually reached.

**Because there is no manual override, the floor is conservative rather than strict.**
Reaching the end of the body already excludes opening and backing out, so the floor exists
only to catch a flick to the bottom. A strict floor would leave a fast reader with
permanently unread lessons and make coverage under-report for exactly the students most
likely to look at it.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.**
- **Layering (`tool/check_layering.dart`).** R1, R2, R3 as elsewhere.
- **Analysis is `very_good_analysis` with `strict-casts` and `strict-inference`.**
- **Never invent a figure.** The reader prints no number except the rail's fill, which is a
  fraction of lessons and scroll, and the coda's "5 questions", which is the inline quiz's
  actual length. **`estimatedMinutes` may not appear as a personal figure anywhere on this
  screen.**
- **No em dashes in any string.** The one deliberate copy exception in this spec is the
  contraction in Plan 5's day line, not here.
- **Widget tests use `test/helpers/pump_app.dart`**, extensions on `WidgetTester`.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## What is not built, and why it is not an omission

**The "2 of 3" counter and the day sheet.** Spec Section 4 gives the bar two compositions:
from Home in a plan it shows a tappable "2 of 3" counter, and from Study with no plan it
shows the contents glyph. **The study plan feature is stubbed**: its providers throw, and its
entry row was deliberately hidden on 25 July. There is no plan to be 2 of 3 of.

This plan builds **the Study composition only**, and the bar takes an enum with a second
value reserved so the counter drops in without redrawing the bar. The rail's "in a plan"
variant, `(lessons done + progress through this one) / total` with tick marks at lesson
boundaries, is the same: built for the single lesson, with the shape left open.

**Say this to Aedwon rather than shipping it quietly**, because a reader opened from Home
will show the contents glyph until the study plan is real.

---

## File Structure

**Create:**
- `lib/features/lesson/application/reader_providers.dart` — the lesson, its neighbours in
  authored order, its bookmark state, and the read-marking controller.
- `lib/features/lesson/presentation/widgets/reader_bar.dart` — the bar and the collapsing
  title strip.
- `lib/features/lesson/presentation/widgets/reader_rail.dart`
- `lib/features/lesson/presentation/widgets/lesson_contents_sheet.dart`
- `lib/features/lesson/presentation/widgets/reader_gap.dart` — the read line and the coda.
- `lib/features/lesson/presentation/widgets/pull_to_advance.dart`
- the matching tests under `test/features/lesson/`.

**Modify:**
- `lib/features/lesson/presentation/lesson_page.dart` — rebuilt around the above.
- `lib/app/router.dart` — `/lesson/:lessonId` gains `?from=`.
- `lib/features/lesson/presentation/widgets/study_topic_section.dart` and
  `study_head_block.dart` — push `?from=study`.

**Deliberately not touched:**
- `PortableTextRenderer`. The body renders exactly as it does today: `h2` at `displaySmall`,
  `h3` at `headlineMedium`, blockquotes at `bodyLarge` italic with a 2px rule left border,
  normal blocks at `bodyMedium`. Section 4 restates the current behaviour rather than
  changing it.
- The inline quiz. `/quiz/inline/:examId/:lessonId` is already wired and its terms hold: 5
  questions, lesson-scoped, feeds FSRS, no streak credit.

---

## Task 1: What the reader needs to know

**Files:**
- Create: `lib/features/lesson/application/reader_providers.dart`
- Test: `test/features/lesson/application/reader_providers_test.dart`

**Interfaces:**
- Consumes: `studyMapProvider` (Plan 2), `lessonBookmarksRepositoryProvider` and
  `appPreferencesRepositoryProvider` (Plan 1), `lessonByIdProvider`.
- Produces: `class ReaderContext { Lesson lesson; String topicName; StudyLesson? next;
  int positionInTopic; int lessonsInTopic; bool isRead; bool isBookmarked; ExamId examId; }`,
  `readerContextProvider` (`FutureProvider.family<ReaderContext?, LessonId>`),
  `isBookmarkedProvider` (`FutureProvider.family<bool, LessonId>`), and
  `toggleBookmark(WidgetRef, LessonId)`. Tasks 2 to 6 read these.

**The exam id comes from the selected exam, not from the route.** `/lesson/:lessonId`
accepts `?examId=` today, and Plan 2 stopped passing it because the map already knows which
exam is selected. The coda needs one for `/quiz/inline/:examId/:lessonId`, so the reader
reads it from `activeExamFocusProvider` through the map. **A reader that cannot resolve an
exam draws no coda** rather than routing to a broken path.

**The next lesson is the next one in the topic's authored order.** Plan 1's `ordering`
column is what makes that meaningful; before the editorial pass it is glob order, which is
what students see today.

- [ ] **Step 1: Write the failing test**

Create `test/features/lesson/application/reader_providers_test.dart` over an in-memory
database seeded with one topic and three lessons at orderings 1, 2 and 3:

```dart
  test('the reader knows where it sits in the topic', () async {
    final context =
        await container.read(readerContextProvider('l2').future);

    expect(context!.topicName, 'Chemistry');
    expect(context.positionInTopic, 2);
    expect(context.lessonsInTopic, 3);
    expect(context.next!.id, 'l3');
  });

  test('the last lesson in a topic has no next', () async {
    final context =
        await container.read(readerContextProvider('l3').future);

    expect(context!.next, isNull);
  });

  test('a lesson that is not in the corpus is null', () async {
    expect(await container.read(readerContextProvider('l9').future), isNull);
  });

  test('the reader carries the read and bookmarked state', () async {
    await container.read(lessonProgressRepositoryProvider).markRead('l1');
    await container.read(lessonBookmarksRepositoryProvider).mark('l1');

    final context =
        await container.read(readerContextProvider('l1').future);

    expect(context!.isRead, isTrue);
    expect(context.isBookmarked, isTrue);
  });

  test('the reader resolves the selected exam for the coda', () async {
    final context =
        await container.read(readerContextProvider('l1').future);

    expect(context!.examId, 'e1');
  });
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/application/reader_providers_test.dart`
Expected: FAIL. `reader_providers.dart` does not exist.

- [ ] **Step 3: Write the providers**

Build `readerContextProvider` by walking `studyMapProvider`'s subjects for the topic holding
this lesson, then reading the full `Lesson` through `lessonByIdProvider` for its body. The
map carries the title, minutes, read and bookmark state already; only the body needs a
second read.

`toggleBookmark` marks or unmarks through `LessonBookmarksRepository` and then invalidates
`readerContextProvider(lessonId)`, `bookmarkRowsProvider` and `studyMapProvider`, so the
map's ribbon and the head section follow immediately.

- [ ] **Step 4: Run it, then format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/features/lesson test/features/lesson
git commit -m "feat(study): the reader's context, including where it sits

The exam comes from the selected exam rather than a query parameter,
because the map stopped passing one and the coda needs it."
```

---

## Task 2: The bar and the collapsing title

**Files:**
- Create: `lib/features/lesson/presentation/widgets/reader_bar.dart`
- Test: `test/features/lesson/presentation/reader_bar_test.dart`

**Interfaces:**
- Consumes: `ReaderContext` from Task 1, `BookmarkRibbon` from Plan 3a Task 3.
- Produces: `ReaderBar({required String title, required ReaderOrigin origin, required bool
  isBookmarked, required VoidCallback onBookmark, required VoidCallback onContents, required
  double scrollOffset})` and `enum ReaderOrigin { home, study }`.

**From Section 4:**

- Height 56, `background`. `AppBarTheme` is themed once and the map uses 56, so the reader
  matches it. The mockups drew 52; that was listed as open and is settled here at 56.
- **Leading:** a back chevron at 15px, stroke 1.6, plus the origin word in 13.5 `inkMuted`.
  Two origins only, **"Home"** and **"Study"**. The back arrow is the only exit, since the
  reader is pushed outside the tab shell.
- **Trailing, in this order, bookmark always outermost:** the contents glyph, then the
  ribbon. The rule is **[context] [bookmark]**, so the ribbon never moves.
- **The contents glyph**: three hairline rules of decreasing length, drawn at 21 to 23px with
  stroke 1.5 and round caps, paths `M4 7h16`, `M4 12h12`, `M4 17h8`. Rejected: dots with
  rules, one step from a vertical-dots overflow menu and will be tapped expecting settings.
  Rejected: stacked pages, which collides with the Progress tab's folded sheet.
- **The lesson title never appears in the bar.** It appears only in a strip beneath it, which
  has **zero height and grows to 30px over the first 90px of scroll**, fading in on the same
  fraction. Serif 13/700, single line, ellipsised. Drawing the title in the bar *and* the
  strip was the crowding that made the trailing controls unreadable. One title, one place.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the origin word names where the reader came from',
      (tester) async {
    await pumpBar(tester, origin: ReaderOrigin.study);
    expect(find.text('Study'), findsOneWidget);

    await pumpBar(tester, origin: ReaderOrigin.home);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('the title is never in the bar itself', (tester) async {
    await pumpBar(tester, title: 'Balancing equations', scrollOffset: 0);

    expect(find.text('Balancing equations'), findsNothing);
  });

  testWidgets('the strip grows over the first ninety pixels of scroll',
      (tester) async {
    await pumpBar(tester, title: 'Balancing equations', scrollOffset: 45);
    final half = tester.getSize(find.byKey(const ValueKey('reader-title-strip')));

    await pumpBar(tester, title: 'Balancing equations', scrollOffset: 90);
    final full = tester.getSize(find.byKey(const ValueKey('reader-title-strip')));

    expect(half.height, greaterThan(0));
    expect(half.height, lessThan(30));
    expect(full.height, 30);
  });

  testWidgets('past ninety the strip does not keep growing', (tester) async {
    await pumpBar(tester, title: 'T', scrollOffset: 400);

    expect(
      tester.getSize(find.byKey(const ValueKey('reader-title-strip'))).height,
      30,
    );
  });

  testWidgets('the bookmark is the outermost trailing element',
      (tester) async {
    await pumpBar(tester);

    expect(
      tester.getCenter(find.byType(BookmarkRibbon)).dx,
      greaterThan(tester.getCenter(find.byType(ContentsGlyph)).dx),
    );
  });

  testWidgets('tapping the ribbon calls back', (tester) async {
    var toggled = false;
    await pumpBar(tester, onBookmark: () => toggled = true);

    await tester.tap(find.byType(BookmarkRibbon));
    expect(toggled, isTrue);
  });
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/presentation/reader_bar_test.dart`
Expected: FAIL.

- [ ] **Step 3: Build it**

`ContentsGlyph` is a `CustomPaint` on the three paths above, in the same shape as
`InkChevron`. Put it in `lib/core/ui/components/contents_glyph.dart`: the mock paper's
review will want the same mark.

The strip's height is `(scrollOffset / 90).clamp(0, 1) * 30`, and its opacity is the same
fraction. Key it `reader-title-strip` so the test can measure it.

- [ ] **Step 4: Run it, then format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): the reader's bar, with the title in one place only

Drawing it in the bar and the strip together is what made the trailing
controls unreadable, so the bar never carries it."
```

---

## Task 3: The rail and the contents sheet

**Files:**
- Create: `lib/features/lesson/presentation/widgets/reader_rail.dart`
- Create: `lib/features/lesson/presentation/widgets/lesson_contents_sheet.dart`
- Test: `test/features/lesson/presentation/reader_rail_test.dart`
- Test: `test/features/lesson/presentation/lesson_contents_sheet_test.dart`

**Interfaces:**
- Consumes: `ReaderContext` from Task 1.
- Produces: `ReaderRail({required double progress})` and
  `Future<void> showLessonContentsSheet(BuildContext context, {required ReaderContext
  reader})`.

**The rail**, from Section 4: directly beneath the strip, 3px tall, `ruleFaint` track,
`board` fill. **With no plan it tracks progress through the single lesson, no ticks.**
`ProgressRule` in the kit is already 3px on `ruleFaint` filling `board`. Use it; do not draw
a second one. The "in a plan" variant with 1px by 5px tick marks at lesson boundaries waits
for the study plan, as stated above.

**The contents sheet** lists the topic's lessons, ticked where read and marked "reading" on
the current one. It is the same component the counter would open, which is why the counter
being unbuilt costs nothing later. Reuse the sheet chrome from Plan 3a Task 5: 8px radius,
1px rule top, capped at 74% of the screen, `ink` at 34% wash, no blur.

- [ ] **Step 1: Write the failing tests**

```dart
  testWidgets('the rail fills to the fraction it is given', (tester) async {
    await tester.pumpApp(const ReaderRail(progress: 0.5));

    final rule = tester.widget<ProgressRule>(find.byType(ProgressRule));
    expect(rule.value, 0.5);
  });

  testWidgets('the sheet ticks what is read and marks what is open',
      (tester) async {
    await pumpSheet(tester);

    expect(find.text('✓'), findsOneWidget);
    expect(find.text('reading'), findsOneWidget);
  });

  testWidgets('tapping a lesson in the sheet opens it', (tester) async {
    // ... expect the router to have been asked for /lesson/l3
  });
```

- [ ] **Step 2 to 4: Run, build, run again, then commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): the reader's rail and its contents sheet

The sheet is the component the plan counter would open, so building it
now costs nothing when the study plan becomes real."
```

---

## Task 4: A lesson marks itself read

**Files:**
- Modify: `lib/features/lesson/application/reader_providers.dart`
- Test: `test/features/lesson/application/read_marking_test.dart`

**Interfaces:**
- Consumes: `LessonProgressRepository.markRead`, `AppPreferencesRepository.pushOpenedLesson`.
- Produces: `class ReadMarkingController` with
  `void onScroll({required double offset, required double maxExtent})` and
  `Future<void> onOpen()`, and the constant `readDwellFloor`. Task 6's page drives it.

**The rule:** a lesson is marked read on **reaching the end of the body past a dwell floor**.
Reaching the end already excludes opening and backing out, so the floor exists only to catch
a flick to the bottom.

**The floor is 15 seconds from opening, and this number is not in the spec.** The spec says
"conservative rather than strict" and gives no value. Fifteen seconds is long enough that a
flick from the top to the bottom of a 10 minute lesson does not count, and short enough that
someone rereading a lesson they know, or reading a two minute one properly, is never denied
the mark. **Flagged for Aedwon in the closing section; it is one constant.**

**Opening a lesson also records it as recently opened**, through `pushOpenedLesson`, which
feeds the map's "Last opened" row and search's empty state.

- [ ] **Step 1: Write the failing test**

```dart
  test('reaching the end after the floor marks it read', () async {
    await controller.onOpen();
    clock.advance(readDwellFloor);
    controller.onScroll(offset: 1000, maxExtent: 1000);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isTrue);
  });

  test('flicking to the end inside the floor does not mark it', () async {
    await controller.onOpen();
    clock.advance(const Duration(seconds: 2));
    controller.onScroll(offset: 1000, maxExtent: 1000);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isFalse);
  });

  test('a flick then waiting still marks it on the next scroll', () async {
    await controller.onOpen();
    controller.onScroll(offset: 1000, maxExtent: 1000);
    clock.advance(readDwellFloor);
    controller.onScroll(offset: 995, maxExtent: 1000);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isTrue);
  });

  test('stopping short of the end never marks it', () async {
    await controller.onOpen();
    clock.advance(const Duration(minutes: 5));
    controller.onScroll(offset: 600, maxExtent: 1000);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isFalse);
  });

  test('a lesson shorter than the viewport is at its end immediately',
      () async {
    await controller.onOpen();
    clock.advance(readDwellFloor);
    controller.onScroll(offset: 0, maxExtent: 0);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isTrue);
  });

  test('marking happens once, not on every scroll frame', () async {
    // ... assert the repository was called exactly once
  });

  test('opening records it as recently opened', () async {
    await controller.onOpen();

    expect(await prefs.lastOpenedLessonId('e1'), 'l1');
  });
```

The fifth case matters and is easy to miss: a lesson whose body is shorter than the screen
has `maxScrollExtent == 0`, so "reaching the end" must be true at offset zero rather than
unreachable.

Inject the clock rather than sleeping: take a `DateTime Function()` in the constructor,
defaulting to `DateTime.now`.

- [ ] **Step 2 to 4: Run, build, run again**

Treat "at the end" as `offset >= maxExtent - 24`, so a rubber-band overscroll or a rounding
difference does not deny the mark.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): lessons mark themselves read

Every coverage figure in the app counted button presses until now. The
floor is conservative because there is no manual override: a strict one
would leave fast readers permanently unread."
```

---

## Task 5: The gap, and the coda

**Files:**
- Create: `lib/features/lesson/presentation/widgets/reader_gap.dart`
- Test: `test/features/lesson/presentation/reader_gap_test.dart`

**Interfaces:**
- Consumes: `ReaderContext` from Task 1.
- Produces: `ReaderGap({required bool isRead, required ExamId? examId, required LessonId
  lessonId})`.

**From Section 4:**

- The gap states it plainly: a board `✓`, the word **"Read"**, and **"marked automatically"**
  right-aligned in 11.5 `inkMuted`.
- The coda is an **outlined** button above the pull handle: 1px `ink` border, radius 5,
  padding 11 by 15, 13/600, full width, reading **"Quiz yourself, 5 questions"**. Not a
  filled block, which would compete with advancing, and not a text link, which nobody would
  see.
- It routes to `/quiz/inline/:examId/:lessonId`, already wired.

**No "Mark as read" button, and no minutes.** The old page printed "12 min read" in this
slot. That is `estimatedMinutes`, a property of the material, and printing it under a line
that says what the student just did would read as a claim about them.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('an unread lesson shows no read line', (tester) async {
    await pumpGap(tester, isRead: false);

    expect(find.text('Read'), findsNothing);
    expect(find.text('marked automatically'), findsNothing);
  });

  testWidgets('a read lesson says so, and says how', (tester) async {
    await pumpGap(tester, isRead: true);

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('marked automatically'), findsOneWidget);
    expect(find.text('✓'), findsOneWidget);
  });

  testWidgets('there is no mark as read button anywhere', (tester) async {
    await pumpGap(tester, isRead: false);

    expect(find.text('Mark as read'), findsNothing);
  });

  testWidgets('the coda names its length', (tester) async {
    await pumpGap(tester, examId: 'e1');

    expect(find.text('Quiz yourself, 5 questions'), findsOneWidget);
  });

  testWidgets('no exam means no coda rather than a broken route',
      (tester) async {
    await pumpGap(tester, examId: null);

    expect(find.text('Quiz yourself, 5 questions'), findsNothing);
  });

  testWidgets('the gap never prints the estimated minutes', (tester) async {
    await pumpGap(tester, isRead: true);

    expect(find.textContaining('min'), findsNothing);
  });
```

- [ ] **Step 2 to 4: Run, build, run again**

`BoardButton` has a `secondary` variant; check whether it draws a 1px `ink` border at radius
5. If it does, use it. If it draws a `board` border instead, **do not restyle `BoardButton`
for this one caller**: build the outlined button inside `reader_gap.dart` and say so in the
commit.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): the reader's gap states the mark and offers the coda

The minutes line goes: it is a property of the material, and printing it
under a line about what the student just did reads as a claim about them."
```

---

## Task 6: The pull, and the page around it

**Files:**
- Create: `lib/features/lesson/presentation/widgets/pull_to_advance.dart`
- Modify: `lib/features/lesson/presentation/lesson_page.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/features/lesson/presentation/widgets/study_topic_section.dart`
- Modify: `lib/features/lesson/presentation/widgets/study_head_block.dart`
- Test: `test/features/lesson/presentation/pull_to_advance_test.dart`
- Test: `test/features/lesson/presentation/lesson_page_test.dart`

**Interfaces:**
- Consumes: everything above.
- Produces: `PullToAdvance({required Widget child, required String? nextTitle, required
  VoidCallback? onAdvance})`, and `LessonPage` rebuilt.

**The pull always advances to the next lesson**, in both origins. One gesture, one meaning.
With no plan it advances through the topic's authored lesson order. This retires the pull-up
"rest of the topic" sheet, whose job moved to the contents glyph.

**Mechanics, the "plain rise", every number from Section 4:**

- Two stacked widgets on one page driven by an `AnimationController` off a `GestureDetector`.
  **No route transition**, so the back stack stays clean.
- Range **150px**, threshold **90px**.
- The incoming page tracks the pointer, translating from 100% to 0.
- The outgoing page moves up at **1.6x** the pointer and fades **linearly**.
- The handle is **36 by 3** in `rule`, radius 2, becoming **52 by 3 in `board`** when armed,
  transitioning over **120ms linear**.
- The label beneath reads "Pull up for **<next lesson title>**", with the lesson name in
  `ink` w600, turning `board` when armed.
- Release short of the threshold settles back over **320ms** on
  `cubic-bezier(.22, 1, .36, 1)`. Release past it commits on the same curve.

Rejected in the spec: the "refined" variant with a drag-coupled rail and held opacity.

**On the last lesson of a topic there is no next.** Plan 5 builds the closing page the final
pull lands on. Until it exists, pass `onAdvance: null` and draw no handle, and leave a
comment naming Plan 5. **Do not invent a placeholder ending.**

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the handle names the next lesson', (tester) async {
    await pumpPull(tester, nextTitle: 'Real and Imaginary Number Systems');

    expect(
      find.textContaining('Real and Imaginary Number Systems'),
      findsOneWidget,
    );
  });

  testWidgets('no next lesson draws no handle', (tester) async {
    await pumpPull(tester, nextTitle: null, onAdvance: null);

    expect(find.byKey(const ValueKey('pull-handle')), findsNothing);
  });

  testWidgets('a drag short of the threshold settles back', (tester) async {
    var advanced = false;
    await pumpPull(tester, onAdvance: () => advanced = true);

    await tester.drag(find.byType(PullToAdvance), const Offset(0, -60));
    await tester.pumpAndSettle();

    expect(advanced, isFalse);
  });

  testWidgets('a drag past the threshold commits', (tester) async {
    var advanced = false;
    await pumpPull(tester, onAdvance: () => advanced = true);

    await tester.drag(find.byType(PullToAdvance), const Offset(0, -120));
    await tester.pumpAndSettle();

    expect(advanced, isTrue);
  });

  testWidgets('the handle arms past the threshold', (tester) async {
    await pumpPull(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PullToAdvance)),
    );
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();

    final handle = tester.widget<Container>(
      find.byKey(const ValueKey('pull-handle')),
    );
    expect(tester.getSize(find.byKey(const ValueKey('pull-handle'))).width, 52);

    await gesture.up();
  });
```

- [ ] **Step 2 to 4: Run, build, run again**

- [ ] **Step 5: Rebuild the page and pass the origin**

`LessonPage` becomes a `ConsumerStatefulWidget` holding one `ScrollController`, wiring it to
Task 4's controller, drawing `ReaderBar`, `ReaderRail`, the body, `ReaderGap` and
`PullToAdvance`. It keeps the loading, error and not-found states, with the error message
replaced by fixed copy rather than `e.toString()`, as the map's was in Plan 2.

In `lib/app/router.dart`, add the origin as a query parameter:

```dart
        builder: (_, state) => LessonPage(
          lessonId: state.pathParameters['lessonId']!,
          origin: state.uri.queryParameters['from'] == 'home'
              ? ReaderOrigin.home
              : ReaderOrigin.study,
        ),
```

**Study is the default when the parameter is absent**, which is right: the map is the sole
entrance to all 141 lessons now, and a wrong origin word is a smaller failure than a null.

Drop the now-unused `examId` parameter from `LessonPage`, and update the map's two push
sites to `'/lesson/${lesson.id}?from=study'`.

Then confirm nothing still passes the old parameter:

```bash
grep -rn "lesson/.*examId" lib test
```

- [ ] **Step 6: Run the whole suite**

Run: `flutter test`
Expected: PASS. Last task, so the suite is the gate. The old `lesson_page_test.dart`, if it
asserts on "Mark as read", fails and should be rewritten rather than patched.

- [ ] **Step 7: Check layering, format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): the reader, and one gesture that means one thing

The pull always advances. It replaces the pull-up sheet, whose job moved
to the contents glyph, and it pushes no route so the back stack stays."
```

---

## What this plan deliberately does not do

- **No "2 of 3" counter and no day sheet.** The study plan's providers throw and its entry
  row is hidden. The bar's enum reserves the value.
- **No ticked rail.** Same reason.
- **No closing page.** Plan 5. The last lesson's pull is disabled rather than landing
  nowhere.
- **No reading time recorded.** Auto-marking times the session against the floor, so the
  total is the same timer plus one column, and the spec defers it deliberately. Adding it
  here would put an honest minutes figure on the bookplate in Plan 5 and change what that
  page is.
- **No change to `PortableTextRenderer`.**

## Verification

```bash
flutter analyze                                  # clean
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # no new violations
flutter test                                     # all pass
grep -rn "Mark as read" lib                      # no matches
```

By hand, on a device:

- Opening a lesson from the map shows "Study" beside the back chevron and no title in the
  bar; the strip grows as it scrolls.
- Reaching the bottom after a few seconds marks it read, and the map's fraction moves.
- Flicking straight to the bottom does **not** mark it.
- The ribbon fills from the top, and the map's head section gains the lesson.
- Pulling up past the handle advances to the next lesson with no route transition.
- A short lesson that does not scroll still marks itself read.

## Decided without asking, reversible in one line

- **The dwell floor is 15 seconds.** Not in the spec, which says only "conservative". One
  constant, `readDwellFloor`.
- **"At the end" is within 24px of `maxScrollExtent`**, so an overscroll or a rounding
  difference cannot deny the mark.
- **The origin defaults to Study** when `?from=` is absent.
- **The bar is 56, not 52.** Listed as open in the spec; `AppBarTheme` is themed once and the
  map is 56.
