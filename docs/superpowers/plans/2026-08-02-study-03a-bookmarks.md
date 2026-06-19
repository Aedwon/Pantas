# Study Tab, Plan 3a of 5: Bookmarks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bookmarks end to end, everywhere except the reader's control: the ribbon glyph and
its ink rise, the four-way order and where it is stored, the three-row section on the Study
map, and the sheet with its drag ordering, edit mode and undo.

**Architecture:** One painted glyph in the kit with the rise animated by an
`AnimationController`. One feature repository for the chosen order over `account_prefs`, so
it follows the student between devices the way the hand ordering already does. One providers
file that joins `LessonBookmarksRepository`'s rows to the `StudyMap` built in Plan 2, so no
row needs a query of its own. One bottom sheet.

**Tech Stack:** Flutter, Riverpod, Drift, `flutter_test`. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-27-study-tab-and-reader-design.md`,
Section 3 (Bookmarks) and the Bookmarks block of Section 1.

**Depends on Plan 1** for `LessonBookmarksRepository` and **Plan 2** for `studyMapProvider`
and `StudyMap`. **Search is Plan 3b**, a separate file, because the two share nothing but
the app bar they sit in.

**Nothing here can set a bookmark.** The ribbon control lives in the reader, which is Plan 4.
Until that lands, every surface in this plan is reachable and empty, which is exactly what
the spec asks for: no empty state, no placeholder, nothing rendered at all until a bookmark
exists. Test it by writing a row with the repository.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Layering (`tool/check_layering.dart`).** R1: `lib/core/**` must not import
  `lib/features/**`. R2: one feature must not import another. R3: `domain/` must not import
  Flutter. The ribbon goes in `core/ui/components/` because the reader and the map both draw
  it and they are the same feature, but the kit is where glyphs live.
- **Analysis is `very_good_analysis` with `strict-casts` and `strict-inference`.**
- **Never invent a figure.** The only number this plan prints is a count of bookmark rows.
- **No em dashes in any string.** Use a colon or a comma.
- **The word is bookmark, never flag.** `MockSessionState.flags` is the set of question ids
  flagged inside a timed mock, and `question_flags_local` is the durable version of that.
  They are a different feature. No string, class or file in this plan says "flag".
- **Widget tests use `test/helpers/pump_app.dart`**, which declares extensions on
  `WidgetTester`: `tester.pumpApp(widget)` and
  `tester.pumpAppWithProviders(widget, overrides: [...])`.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/core/ui/components/bookmark_ribbon.dart` — the glyph and its rise. One mark, four
  surfaces, so the feature explains itself.
- `lib/core/ui/components/ink_checkbox.dart` — **check whether it already exists first.**
  Three other plans name it (Quiz 3, Quiz 5 and custom track A) and whichever runs first
  builds it. If `lib/core/ui/components/ink_checkbox.dart` is already there, use it and skip
  Task 6's Step 3.
- `lib/features/lesson/domain/models/bookmark_order.dart` — the four-way order and its
  storage codec.
- `lib/features/lesson/data/repos/bookmark_prefs_repository.dart` — read and write the
  chosen order over `account_prefs`.
- `lib/features/lesson/application/bookmark_providers.dart` — the ordered rows, the order
  controller, the count.
- `lib/features/lesson/presentation/widgets/bookmarks_section.dart` — the three rows on the
  map.
- `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart` — the sheet, its order
  control, its drag ordering and its edit mode.
- The matching tests, one file per unit, under `test/features/lesson/` and
  `test/core/ui/components/`.

**Modify:**
- `lib/features/lesson/presentation/widgets/study_topic_section.dart` — draw the ribbon on a
  topic row that holds a bookmark. Plan 2 computed `hasBookmark` and deliberately drew
  nothing.
- `lib/features/lesson/presentation/learn_tab_home.dart` — place the Bookmarks section
  between the head block and the index.

**Deliberately not touched:**

- **The reader.** Setting and unsetting a bookmark is Plan 4. This plan's glyph takes an
  `isSet` and an `onTap` and does not care who supplies them.
- **Search.** Plan 3b.
- **`question_flags_local` and anything in the Quiz feature.** Different concept, different
  table, and R2 forbids the import anyway.

---

## Task 1: The order, and where it is kept

**Files:**
- Create: `lib/features/lesson/domain/models/bookmark_order.dart`
- Create: `lib/features/lesson/data/repos/bookmark_prefs_repository.dart`
- Test: `test/features/lesson/domain/bookmark_order_test.dart`
- Test: `test/features/lesson/data/bookmark_prefs_repository_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `enum BookmarkOrder { recent, bySubject, oldest, custom }` with
  `String get storageValue`, `static BookmarkOrder fromStorage(String?)` and
  `static const defaultOrder = BookmarkOrder.recent`; and
  `BookmarkPrefsRepository(AppDatabase db)` with `Future<BookmarkOrder> readOrder()` and
  `Future<void> saveOrder(BookmarkOrder)`. Task 2 wraps both in providers.

**`account_prefs`, not `device_prefs`.** `PreferencesMapper` syncs account preferences, and
`lesson_bookmarks_local.sortIndex` already syncs, so keeping the order device-local would
mean a hand-arranged list arriving on a second device displayed in a different order. The
key is `bookmark_order`.

**Recent is the default** and needs nothing but the timestamp the table already carries. The
section is a shortcut back to what just lost you.

- [ ] **Step 1: Write the failing enum test**

Create `test/features/lesson/domain/bookmark_order_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/lesson/domain/models/bookmark_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every order round-trips through storage', () {
    for (final order in BookmarkOrder.values) {
      expect(BookmarkOrder.fromStorage(order.storageValue), order);
    }
  });

  test('an absent or unrecognised value falls back to recent', () {
    expect(BookmarkOrder.fromStorage(null), BookmarkOrder.recent);
    expect(BookmarkOrder.fromStorage(''), BookmarkOrder.recent);
    expect(BookmarkOrder.fromStorage('alphabetical'), BookmarkOrder.recent);
  });

  test('recent is the default', () {
    expect(BookmarkOrder.defaultOrder, BookmarkOrder.recent);
  });

  test('each order has the label the control prints', () {
    expect(BookmarkOrder.recent.label, 'Recent');
    expect(BookmarkOrder.bySubject.label, 'By subject');
    expect(BookmarkOrder.oldest.label, 'Oldest');
    expect(BookmarkOrder.custom.label, 'Custom');
  });
}
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/domain/bookmark_order_test.dart`
Expected: FAIL. `bookmark_order.dart` does not exist.

- [ ] **Step 3: Write the enum**

Create `lib/features/lesson/domain/models/bookmark_order.dart`:

```dart
/// How the bookmark list is arranged. All four are visible on one row in the
/// sheet rather than hidden behind a picker: Custom is the feature, and nobody
/// finds a feature inside a menu they never open.
enum BookmarkOrder {
  recent('recent', 'Recent'),
  bySubject('by_subject', 'By subject'),
  oldest('oldest', 'Oldest'),
  custom('custom', 'Custom');

  const BookmarkOrder(this.storageValue, this.label);

  final String storageValue;

  /// The word the order control prints. "By subject" replaced "Index", which
  /// implied a lesson ordering that did not exist at the time.
  final String label;

  static const defaultOrder = BookmarkOrder.recent;

  static BookmarkOrder fromStorage(String? raw) {
    for (final order in BookmarkOrder.values) {
      if (order.storageValue == raw) return order;
    }
    return defaultOrder;
  }
}
```

- [ ] **Step 4: Write the failing repository test**

Create `test/features/lesson/data/bookmark_prefs_repository_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/lesson/data/repos/bookmark_prefs_repository.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/models/bookmark_order.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late BookmarkPrefsRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = BookmarkPrefsRepository(db);
  });

  tearDown(() => db.close());

  test('an untouched install reads the default order', () async {
    expect(await repo.readOrder(), BookmarkOrder.recent);
  });

  test('a chosen order round-trips', () async {
    await repo.saveOrder(BookmarkOrder.custom);

    expect(await repo.readOrder(), BookmarkOrder.custom);
  });

  test('a stored value nobody recognises falls back rather than throwing',
      () async {
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(
            key: BookmarkPrefsRepository.orderKey,
            value: 'sideways',
          ),
        );

    expect(await repo.readOrder(), BookmarkOrder.recent);
  });
}
```

- [ ] **Step 5: Run it to verify it fails**

Run: `flutter test test/features/lesson/data/bookmark_prefs_repository_test.dart`
Expected: FAIL. `bookmark_prefs_repository.dart` does not exist.

- [ ] **Step 6: Write the repository**

Create `lib/features/lesson/data/repos/bookmark_prefs_repository.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/models/bookmark_order.dart';

/// The chosen bookmark order, in `account_prefs` so it syncs. The hand
/// ordering in `lesson_bookmarks_local.sortIndex` already does, and an order
/// arriving on a second device without the setting that displays it would
/// show the arrangement to nobody.
class BookmarkPrefsRepository {
  BookmarkPrefsRepository(this._db);

  static const orderKey = 'bookmark_order';

  final AppDatabase _db;

  Future<BookmarkOrder> readOrder() async {
    final row = await (_db.select(_db.accountPrefs)
          ..where((pref) => pref.key.equals(orderKey)))
        .getSingleOrNull();
    return BookmarkOrder.fromStorage(row?.value);
  }

  Future<void> saveOrder(BookmarkOrder order) async {
    await _db.into(_db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: orderKey,
            value: order.storageValue,
          ),
        );
  }
}
```

- [ ] **Step 7: Run both tests, then format, analyze and commit**

Run: `flutter test test/features/lesson/`

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/features/lesson test/features/lesson
git commit -m "feat(study): the bookmark order, and somewhere to keep it

An account preference rather than a device one, because the hand
ordering it displays already syncs."
```

---

## Task 2: The ordered rows

**Files:**
- Create: `lib/features/lesson/application/bookmark_providers.dart`
- Test: `test/features/lesson/application/bookmark_providers_test.dart`

**Interfaces:**
- Consumes: `LessonBookmarksRepository` (Plan 1), `studyMapProvider` (Plan 2),
  `BookmarkPrefsRepository` and `BookmarkOrder` (Task 1).
- Produces: `class BookmarkRow { LessonId lessonId; String title; String topicName; int
  estimatedMinutes; }`, `bookmarkRowsProvider` (`FutureProvider<List<BookmarkRow>>`, in the
  chosen order), `bookmarkCountProvider` (`FutureProvider<int>`), and
  `bookmarkOrderProvider` (`AsyncNotifierProvider<BookmarkOrderController, BookmarkOrder>`
  with `Future<void> choose(BookmarkOrder)`). Tasks 4 to 7 watch these.

**Every row's title, topic and minutes come from the `StudyMap`.** It is already built,
already ordered by subject then topic then authored lesson order, and already in memory. A
per-row query would be one round trip per bookmark for data the screen behind it is holding.

**"By subject" is just the map's own walk order**, filtered to bookmarked lessons. That is
why it is composed here and not in the repository: the repository has no subject tree, and
reaching for one from `core/storage` would be the wrong seam.

- [ ] **Step 1: Write the failing test**

Create `test/features/lesson/application/bookmark_providers_test.dart`. Seed a database with
two subjects, two topics and four lessons, mark three of them, and assert each order:

```dart
  test('recent order is newest first', () async {
    await repo.mark('l1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l3');

    await container.read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.recent);

    expect(
      (await container.read(bookmarkRowsProvider.future))
          .map((row) => row.lessonId)
          .toList(),
      ['l3', 'l1'],
    );
  });

  test('oldest order is its reverse', () async {
    await repo.mark('l1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l3');

    await container.read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.oldest);

    expect(
      (await container.read(bookmarkRowsProvider.future))
          .map((row) => row.lessonId)
          .toList(),
      ['l1', 'l3'],
    );
  });

  test('by subject follows the corpus, not the marking', () async {
    // l3 is in the second subject and was marked first.
    await repo.mark('l3');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l1');

    await container.read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.bySubject);

    expect(
      (await container.read(bookmarkRowsProvider.future))
          .map((row) => row.lessonId)
          .toList(),
      ['l1', 'l3'],
    );
  });

  test('custom order puts hand-placed rows ahead of unplaced ones', () async {
    await repo.mark('l1');
    await repo.mark('l3');
    await repo.reorder(['l3']);

    await container.read(bookmarkOrderProvider.notifier)
        .choose(BookmarkOrder.custom);

    expect(
      (await container.read(bookmarkRowsProvider.future))
          .map((row) => row.lessonId)
          .toList(),
      ['l3', 'l1'],
    );
  });

  test('a row carries the title, topic and minutes its row prints', () async {
    await repo.mark('l1');

    final row = (await container.read(bookmarkRowsProvider.future)).single;

    expect(row.title, 'Lesson l1');
    expect(row.topicName, 'Chemistry');
    expect(row.estimatedMinutes, 13);
  });

  test('a bookmark whose lesson is gone is dropped, not drawn blank',
      () async {
    await repo.mark('l1');
    await db.delete(db.lessonBookmarksLocal).go();
    await db.into(db.lessonBookmarksLocal).insert(
          LessonBookmarksLocalCompanion.insert(
            lessonId: 'l_missing',
            markedAt: DateTime.now(),
          ),
        );

    expect(await container.read(bookmarkRowsProvider.future), isEmpty);
  });

  test('the count is the number of rows', () async {
    await repo.mark('l1');
    await repo.mark('l3');

    expect(await container.read(bookmarkCountProvider.future), 2);
  });
```

The last-but-one test needs the foreign key to be unenforced, which it is: nothing in this
app runs `PRAGMA foreign_keys = ON`. If a future change turns it on, that insert fails and
the test should be deleted rather than worked around.

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/application/bookmark_providers_test.dart`
Expected: FAIL. `bookmark_providers.dart` does not exist.

- [ ] **Step 3: Write the providers**

Create `lib/features/lesson/application/bookmark_providers.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/application/study_map_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/data/repos/bookmark_prefs_repository.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/models/bookmark_order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:cse_cet_reviewer/features/lesson/domain/models/bookmark_order.dart';

/// What one bookmark row prints. Everything on it comes from the map the
/// screen behind is already holding, so a row costs no query of its own.
class BookmarkRow {
  const BookmarkRow({
    required this.lessonId,
    required this.title,
    required this.topicName,
    required this.estimatedMinutes,
  });

  final LessonId lessonId;
  final String title;
  final String topicName;
  final int estimatedMinutes;
}

final bookmarkPrefsRepositoryProvider = Provider<BookmarkPrefsRepository>(
  (ref) => BookmarkPrefsRepository(ref.watch(appDatabaseProvider)),
);

class BookmarkOrderController extends AsyncNotifier<BookmarkOrder> {
  @override
  Future<BookmarkOrder> build() =>
      ref.read(bookmarkPrefsRepositoryProvider).readOrder();

  Future<void> choose(BookmarkOrder order) async {
    await ref.read(bookmarkPrefsRepositoryProvider).saveOrder(order);
    state = AsyncData(order);
  }
}

final bookmarkOrderProvider =
    AsyncNotifierProvider<BookmarkOrderController, BookmarkOrder>(
  BookmarkOrderController.new,
);

final bookmarkRowsProvider = FutureProvider<List<BookmarkRow>>((ref) async {
  final map = await ref.watch(studyMapProvider.future);
  if (map == null) return const [];

  final order = await ref.watch(bookmarkOrderProvider.future);
  final repo = ref.watch(lessonBookmarksRepositoryProvider);

  // The map's own walk is subject order, then topic order, then the authored
  // lesson order, which is exactly what "By subject" means.
  final byLessonId = <LessonId, BookmarkRow>{};
  final corpusOrder = <LessonId>[];
  for (final subject in map.subjects) {
    for (final topic in subject.topics) {
      for (final lesson in topic.lessons) {
        corpusOrder.add(lesson.id);
        byLessonId[lesson.id] = BookmarkRow(
          lessonId: lesson.id,
          title: lesson.title,
          topicName: topic.name,
          estimatedMinutes: lesson.estimatedMinutes,
        );
      }
    }
  }

  final ordered = switch (order) {
    BookmarkOrder.recent => await repo.recentFirst(),
    BookmarkOrder.oldest => await repo.oldestFirst(),
    BookmarkOrder.custom => await repo.customOrder(),
    BookmarkOrder.bySubject => null,
  };

  if (ordered != null) {
    return [
      // A bookmark whose lesson is no longer in the corpus is dropped rather
      // than drawn as a blank row. Content can be withdrawn between releases.
      for (final row in ordered)
        if (byLessonId[row.lessonId] case final bookmark?) bookmark,
    ];
  }

  final marked = await repo.markedIds();
  return [
    for (final lessonId in corpusOrder)
      if (marked.contains(lessonId))
        if (byLessonId[lessonId] case final bookmark?) bookmark,
  ];
});

final bookmarkCountProvider = FutureProvider<int>((ref) async {
  return (await ref.watch(bookmarkRowsProvider.future)).length;
});
```

`bookmarkCountProvider` counts the rows the screen would draw rather than calling
`repo.count()`, so a bookmark on withdrawn content cannot make the heading say four when
three are visible.

- [ ] **Step 4: Run it to verify it passes**

Run: `flutter test test/features/lesson/application/bookmark_providers_test.dart`
Expected: PASS, 7 tests.

- [ ] **Step 5: Check layering, format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/features/lesson test/features/lesson
git commit -m "feat(study): bookmark rows in whichever order is chosen

By subject is the map's own walk filtered to the marked lessons, which
is why it is composed here and not in a repository with no subject tree."
```

---

## Task 3: The ribbon

**Files:**
- Create: `lib/core/ui/components/bookmark_ribbon.dart`
- Test: `test/core/ui/components/bookmark_ribbon_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `BookmarkRibbon({required bool isSet, VoidCallback? onTap, double width = 15,
  double height = 18})`. Tasks 4, 5 and 7 draw it, and Plan 4's reader supplies the `onTap`
  that sets it.

**The geometry is exact and comes from the spec.** A 12 by 16 viewBox rendered at 15 by 18:

- Unset: outline, stroke 1.4, `inkMuted`, path `M1.6 1.6h8.8v12.8l-4.4-3.9-4.4 3.9z`
- Set: solid fill, `ink`, no stroke, path `M1 1h10v14l-5-4.4-5 4.4z`

**It cannot be board green.** The colour budget spends board on the primary action, progress
indicators and done checks, and the reader's rail sits directly beneath this control.

**The rise, from Section 3:**

- **The fill falls from the top**, where the navigation bar's rises from the bottom. A tab
  rises from the bottom because it sits there; a ribbon falls from the top because it hangs
  there, and the notch filling last is the better final beat.
- 400ms on `cubic-bezier(.22, 1, .36, 1)`, the settled navigation constant.
- **Unsetting drains instantly.** An outgoing state does not animate.
- **Disabled under reduce-motion**, falling back to a plain swap.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/bookmark_ribbon_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/bookmark_ribbon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('the ribbon paints at its drawn size', (tester) async {
    await tester.pumpApp(const BookmarkRibbon(isSet: false));

    expect(
      tester.getSize(find.byType(BookmarkRibbon)),
      const Size(15, 18),
    );
  });

  testWidgets('tapping calls back', (tester) async {
    var tapped = false;
    await tester.pumpApp(
      BookmarkRibbon(isSet: false, onTap: () => tapped = true),
    );

    await tester.tap(find.byType(BookmarkRibbon));
    expect(tapped, isTrue);
  });

  testWidgets('setting fills over the settled duration', (tester) async {
    await tester.pumpApp(const BookmarkRibbon(isSet: false));
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BookmarkRibbon(isSet: true))),
    );

    // Part way through, the fill is neither absent nor complete.
    await tester.pump(const Duration(milliseconds: 200));
    final midway = tester.state<BookmarkRibbonState>(
      find.byType(BookmarkRibbon),
    );
    expect(midway.fillFraction, greaterThan(0));
    expect(midway.fillFraction, lessThan(1));

    await tester.pumpAndSettle();
    expect(midway.fillFraction, 1);
  });

  testWidgets('unsetting drains at once', (tester) async {
    await tester.pumpApp(const BookmarkRibbon(isSet: true));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BookmarkRibbon(isSet: false))),
    );
    await tester.pump();

    expect(
      tester
          .state<BookmarkRibbonState>(find.byType(BookmarkRibbon))
          .fillFraction,
      0,
    );
  });

  testWidgets('reduce motion swaps rather than rises', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: Scaffold(body: BookmarkRibbon(isSet: false))),
      ),
    );
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: Scaffold(body: BookmarkRibbon(isSet: true))),
      ),
    );
    await tester.pump();

    expect(
      tester
          .state<BookmarkRibbonState>(find.byType(BookmarkRibbon))
          .fillFraction,
      1,
    );
  });
}
```

`BookmarkRibbonState` must be public for these assertions, so name the state class without a
leading underscore and expose `double get fillFraction`. Asserting on painted pixels would be
a golden test, which this repo does not use.

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/core/ui/components/bookmark_ribbon_test.dart`
Expected: FAIL. `bookmark_ribbon.dart` does not exist.

- [ ] **Step 3: Write the ribbon**

Create `lib/core/ui/components/bookmark_ribbon.dart`. The shape is a `Path` scaled from the
12 by 16 viewBox, and the fill is that path clipped to a rectangle growing downward from the
top:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The bookmark mark. The same glyph appears on Study map rows, in the head
/// section, in the sheet and in the reader: one mark on four surfaces, so the
/// feature explains itself.
///
/// It is never board green. The colour budget spends board on the primary
/// action, progress and done checks, and the reader's rail sits directly
/// beneath this control.
class BookmarkRibbon extends StatefulWidget {
  const BookmarkRibbon({
    required this.isSet,
    this.onTap,
    this.width = 15,
    this.height = 18,
    super.key,
  });

  final bool isSet;
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  BookmarkRibbonState createState() => BookmarkRibbonState();
}

class BookmarkRibbonState extends State<BookmarkRibbon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    value: widget.isSet ? 1 : 0,
  );

  /// How much of the glyph is filled, 0 to 1. Public so a widget test can
  /// assert the rise without a golden.
  double get fillFraction => _controller.value;

  @override
  void didUpdateWidget(BookmarkRibbon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSet == oldWidget.isSet) return;

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!widget.isSet || reduceMotion) {
      // Unsetting drains at once: an outgoing state does not animate, the
      // same rule the navigation bar's tabs follow.
      _controller.value = widget.isSet ? 1 : 0;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _RibbonPainter(
            fill: _controller.value,
            outlineColor: colors.inkMuted,
            fillColor: colors.ink,
          ),
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter({
    required this.fill,
    required this.outlineColor,
    required this.fillColor,
  });

  final double fill;
  final Color outlineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 12;
    final scaleY = size.height / 16;

    Path shape(double left, double top, double width, double height) {
      final right = left + width;
      final bottom = top + height;
      final notch = bottom - height * 0.27;
      return Path()
        ..moveTo(left * scaleX, top * scaleY)
        ..lineTo(right * scaleX, top * scaleY)
        ..lineTo(right * scaleX, bottom * scaleY)
        ..lineTo((left + width / 2) * scaleX, notch * scaleY)
        ..lineTo(left * scaleX, bottom * scaleY)
        ..close();
    }

    // Unset: M1.6 1.6h8.8v12.8l-4.4-3.9-4.4 3.9z
    final outline = shape(1.6, 1.6, 8.8, 12.8);
    // Set: M1 1h10v14l-5-4.4-5 4.4z
    final solid = shape(1, 1, 10, 14);

    canvas.drawPath(
      outline,
      Paint()
        ..color = outlineColor
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    if (fill <= 0) return;

    // The fill falls from the top, where the navigation bar's rises from the
    // bottom: a tab sits at the bottom of the screen, a ribbon hangs from the
    // top of its row, and the notch filling last is the better final beat.
    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, size.width, size.height * fill))
      ..drawPath(solid, Paint()..color = fillColor)
      ..restore();
  }

  @override
  bool shouldRepaint(_RibbonPainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.outlineColor != outlineColor;
}
```

The curve is not applied above. Drive it with a `CurvedAnimation` on
`Cubic(0.22, 1, 0.36, 1)`, the settled navigation constant, and read that animation's value
rather than the controller's:

```dart
  late final Animation<double> _rise = CurvedAnimation(
    parent: _controller,
    curve: const Cubic(0.22, 1, 0.36, 1),
  );
```

and have `fillFraction` return `_rise.value`.

- [ ] **Step 4: Run it to verify it passes**

Run: `flutter test test/core/ui/components/bookmark_ribbon_test.dart`
Expected: PASS, 5 tests.

- [ ] **Step 5: Draw it on a topic row**

In `lib/features/lesson/presentation/widgets/study_topic_section.dart`, Plan 2 carried
`topic.hasBookmark` and drew nothing. `InkTableRow` has no slot for a glyph beside the
title, so pass it as the row's `category` equivalent is wrong: **add a `leadingMeta` widget
slot to `InkTableRow`** taking an optional `Widget`, drawn before the meta column, and pass
`BookmarkRibbon(isSet: true, width: 11, height: 13)` when `hasBookmark` is true.

If adding a slot to the shared row feels like too much for one glyph, the alternative is to
wrap the row in a `Stack`, and it is worse: the glyph would not participate in the row's
layout and would collide with the fraction at long topic names. **Take the slot.**

- [ ] **Step 6: Run the lesson suite, then format, analyze and commit**

Run: `flutter test test/features/lesson/ test/core/ui/`

```bash
dart format lib test
flutter analyze
git add lib/core/ui lib/features/lesson test
git commit -m "feat(ui): the bookmark ribbon and its rise

The fill falls from the top where the nav bar's rises from the bottom:
a tab sits at the bottom of the screen and a ribbon hangs from the top."
```

---

## Task 4: The Bookmarks section on the map

**Files:**
- Create: `lib/features/lesson/presentation/widgets/bookmarks_section.dart`
- Modify: `lib/features/lesson/presentation/learn_tab_home.dart`
- Test: `test/features/lesson/presentation/bookmarks_section_test.dart`

**Interfaces:**
- Consumes: `bookmarkRowsProvider` and `bookmarkCountProvider` from Task 2,
  `BookmarkRibbon` from Task 3.
- Produces: `BookmarksSection()`, a `ConsumerWidget` that renders nothing when there are no
  bookmarks. Task 5's sheet is opened from its "See all".

**From Section 1:**

- Rendered **only** when at least one bookmark exists. No empty state, no placeholder, no
  "you have no bookmarks yet". A block that teaches itself by nagging is worse than one that
  appears the moment it has something to say.
- Heading "Bookmarks" in `headlineSmall`, the total count beside it in `bodySmall`
  `inkMuted`, and **"See all"** in 12/600 `board` as the trailing action, **shown only when
  the count exceeds three**.
- A 1px rule beneath the heading row.
- **Exactly three rows, whatever the total.** The head must have a ceiling so the index
  always starts in the same place however heavily a student bookmarks.
- Each row: the ribbon leading in `inkMuted`, the lesson title in `bodyMedium`, the topic and
  minutes beneath in `bodySmall` `inkMuted` as "Chemistry, 13 min", a trailing chevron.
- The three shown follow whatever order the sheet is set to.

`SectionHeader` already draws a serif heading with a trailing action on the same baseline.
Use it, and put the count in the title string is wrong: **add an optional `trailingCount`**
or draw the heading row by hand. Prefer drawing by hand here rather than growing
`SectionHeader` for one caller.

- [ ] **Step 1: Write the failing test**

Create `test/features/lesson/presentation/bookmarks_section_test.dart` with five tests:

```dart
  testWidgets('no bookmarks renders nothing at all', (tester) async {
    await tester.pumpAppWithProviders(
      const BookmarksSection(),
      overrides: [
        bookmarkRowsProvider.overrideWith((ref) async => const []),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Bookmarks'), findsNothing);
    expect(find.byType(BookmarkRibbon), findsNothing);
  });

  testWidgets('three or fewer bookmarks hide See all', (tester) async {
    await pumpWith(tester, rows: 3);

    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('See all'), findsNothing);
  });

  testWidgets('more than three shows See all and still draws three',
      (tester) async {
    await pumpWith(tester, rows: 7);

    expect(find.text('See all'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.byType(BookmarkRibbon), findsNWidgets(3));
  });

  testWidgets('a row prints its topic and minutes together', (tester) async {
    await pumpWith(tester, rows: 1);

    expect(find.text('Chemistry, 13 min'), findsOneWidget);
  });
```

Write `pumpWith` to build N `BookmarkRow`s with predictable titles and override both
providers.

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/presentation/bookmarks_section_test.dart`
Expected: FAIL. `bookmarks_section.dart` does not exist.

- [ ] **Step 3: Write the section**

Create `lib/features/lesson/presentation/widgets/bookmarks_section.dart`. Return
`const SizedBox.shrink()` when the rows are empty or still loading, draw the heading row,
the rule, then `rows.take(3)` as `InkTableRow`s with `chevron: InkRowChevron.link`, a
`subtitle` of `'$topicName, $estimatedMinutes min'`, the ribbon in the `leadingMeta` slot
added in Task 3, and `onTap: () => context.push('/lesson/${row.lessonId}')`.

"See all" opens the sheet from Task 5. Until that task lands, wire it to a no-op and **do
not draw it**: gate it on `count > 3` as the spec says, and Task 5 replaces the callback.

- [ ] **Step 4: Place it on the map**

In `lib/features/lesson/presentation/learn_tab_home.dart`, put `const BookmarksSection()`
between the head block and the first subject section. Plan 2 left the slot.

- [ ] **Step 5: Run it, then format, analyze and commit**

Run: `flutter test test/features/lesson/`

```bash
dart format lib test
flutter analyze
git add lib/features/lesson test/features/lesson
git commit -m "feat(study): three bookmarks at the head of the map

Exactly three whatever the total, so the index always begins at the same
place however heavily someone bookmarks."
```

---

## Task 5: The sheet

**Files:**
- Create: `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart`
- Modify: `lib/features/lesson/presentation/widgets/bookmarks_section.dart`
- Test: `test/features/lesson/presentation/bookmarks_sheet_test.dart`

**Interfaces:**
- Consumes: `bookmarkRowsProvider`, `bookmarkOrderProvider` from Task 2.
- Produces: `Future<void> showBookmarksSheet(BuildContext context)`, and the private sheet
  widget behind it. Task 4's "See all" calls it. Tasks 6 and 7 extend the same file.

**Chrome, from Section 3:**

- A bottom sheet, not a route. 8px top radius per `bottomSheetTheme`, a 1px `rule` top
  border, capped at **74% of the screen**, drag down to dismiss, tap the wash to close.
- **Wash: `ink` at 34%.** The page behind settles 10px down and loses a hair of scale on the
  same curve. **No blur**: it is a glass metaphor in a paper identity and a per-frame GPU
  pass on budget Androids.
- A 34 by 3 grab handle in `rule`, radius 2, 9px above and 2px below.
- Header: "Bookmarks" in serif 18/700, and **Edit / Done** in 13/600 `board` on the right.
  **Not "Save"**: drags and deletions apply immediately, so "Save" would promise a Cancel
  that does not exist.

**The order control:** four labels on one row, closed by a 1px rule.

> Recent · By subject · Oldest · Custom

12.5px `inkMuted`, the active one in `ink` at w700, separated by 1px by 12px `rule` ticks
with 10px margins either side. **No pills**, which the identity bans. Every option visible
rather than behind a picker.

**Known weak point, recorded in the spec's Deferred section:** the `ink` wash at 34% is the
one surface that has only been glanced at in dark theme, where ink on near-black separates
poorly. If it looks wrong on a device, the fix is the `background` token in dark, not a
different opacity.

- [ ] **Step 1: Write the failing test**

Create `test/features/lesson/presentation/bookmarks_sheet_test.dart`:

```dart
  testWidgets('the sheet lists every bookmark, not three', (tester) async {
    await pumpSheet(tester, rows: 7);

    expect(find.byType(BookmarkRibbon), findsNWidgets(7));
  });

  testWidgets('the four orders are all visible', (tester) async {
    await pumpSheet(tester, rows: 2);

    for (final label in ['Recent', 'By subject', 'Oldest', 'Custom']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('the active order is the heavy one', (tester) async {
    await pumpSheet(tester, rows: 2, order: BookmarkOrder.oldest);

    expect(
      tester.widget<Text>(find.text('Oldest')).style?.fontWeight,
      FontWeight.w700,
    );
    expect(
      tester.widget<Text>(find.text('Recent')).style?.fontWeight,
      isNot(FontWeight.w700),
    );
  });

  testWidgets('choosing an order writes it', (tester) async {
    await pumpSheet(tester, rows: 2);

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    expect(chosenOrder, BookmarkOrder.custom);
  });

  testWidgets('the header offers Edit, never Save', (tester) async {
    await pumpSheet(tester, rows: 2);

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });
```

`chosenOrder` comes from a fake `BookmarkOrderController` overriding `choose`, in the shape
Plan 2's `_FakeOpenTopic` uses.

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/presentation/bookmarks_sheet_test.dart`
Expected: FAIL. `bookmarks_sheet.dart` does not exist.

- [ ] **Step 3: Write the sheet**

Create `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart` with
`showBookmarksSheet` calling `showModalBottomSheet`:

```dart
Future<void> showBookmarksSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Ink at 34%. No blur: a glass metaphor in a paper identity, and a
    // per-frame GPU pass on the budget Androids this ships to.
    barrierColor: context.colors.ink.withValues(alpha: 0.34),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.74,
    ),
    builder: (_) => const _BookmarksSheet(),
  );
}
```

`withValues(alpha:)` is the idiom here. This repo is on Flutter 3.44.6 and every existing
call site uses it, for example `delete_account_page.dart:164`. `withOpacity` is deprecated
and will trip the analyzer.

The order control is a `Row` of `GestureDetector`s over `Text`, with 1px by 12px `Container`
ticks between them. Each label needs a 48dp tap height; give the row `SizedBox(height: 48)`
and centre the labels rather than padding each one differently.

- [ ] **Step 4: Wire "See all"**

In `bookmarks_section.dart`, replace the no-op with
`onAction: () => showBookmarksSheet(context)`.

- [ ] **Step 5: Run it, then format, analyze and commit**

Run: `flutter test test/features/lesson/`

```bash
dart format lib test
flutter analyze
git add lib/features/lesson test/features/lesson
git commit -m "feat(study): the bookmarks sheet and its order control

All four orders sit on one row rather than behind a picker: Custom is
the feature, and nobody opens a menu to find one."
```

---

## Task 6: Custom order and drag

**Files:**
- Modify: `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart`
- Test: `test/features/lesson/presentation/bookmarks_sheet_test.dart`

**Interfaces:**
- Consumes: `LessonBookmarksRepository.reorder` and `.clearCustomOrder` from Plan 1 Task 4.
- Produces: no new public API.

**From Section 3:**

- **Drag is always live in Custom**, with a grip on every row. **No mode to enter.**
- A new bookmark **lands at the top** in Custom. Plan 1's `mark()` already does this.
- **Positions are retained silently** when the order is switched away and back. **No
  dialogue, ever**: a prompt on every sort change punishes exploring.
- An explicit **"Reset order"** lives in the sheet for anyone who wants it gone.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('grips appear only in custom order', (tester) async {
    await pumpSheet(tester, rows: 3, order: BookmarkOrder.recent);
    expect(find.byKey(const ValueKey('bookmark-grip')), findsNothing);

    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);
    expect(find.byKey(const ValueKey('bookmark-grip')), findsNWidgets(3));
  });

  testWidgets('dragging a row writes the new order', (tester) async {
    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);

    await tester.drag(
      find.byKey(const ValueKey('bookmark-grip')).first,
      const Offset(0, 120),
    );
    await tester.pumpAndSettle();

    expect(reorderedIds, isNotEmpty);
  });

  testWidgets('switching away from custom asks nothing', (tester) async {
    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);

    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('reset order is offered only in custom', (tester) async {
    await pumpSheet(tester, rows: 3, order: BookmarkOrder.recent);
    expect(find.text('Reset order'), findsNothing);

    await pumpSheet(tester, rows: 3, order: BookmarkOrder.custom);
    expect(find.text('Reset order'), findsOneWidget);
  });
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/presentation/bookmarks_sheet_test.dart`
Expected: FAIL on all four.

- [ ] **Step 3: Build it**

In Custom, render the list through `ReorderableListView.builder` with
`buildDefaultDragHandles: false` and a `ReorderableDragStartListener` around a grip glyph
keyed `bookmark-grip`. On reorder, move the id in a local copy and call
`repo.reorder(ids)`, then invalidate `bookmarkRowsProvider`.

`ReorderableListView`'s `onReorder` reports a `newIndex` that is one too high when a row
moves down, because it is the slot index before the row is lifted out:

```dart
      onReorder: (oldIndex, newIndex) async {
        final ids = [for (final row in rows) row.lessonId];
        final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
        final moved = ids.removeAt(oldIndex);
        ids.insert(target, moved);

        await ref.read(lessonBookmarksRepositoryProvider).reorder(ids);
        ref.invalidate(bookmarkRowsProvider);
      },
```

"Reset order" is a text action at the foot of the sheet, in Custom only, calling
`clearCustomOrder()`.

- [ ] **Step 4: Run it, format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/lesson test/features/lesson
git commit -m "feat(study): drag is always live in the custom order

No mode to enter, and no prompt when the order is switched away: a
dialogue on every sort change punishes looking at the other three."
```

---

## Task 7: Edit mode and undo

**Files:**
- Modify: `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart`
- Create: `lib/core/ui/components/ink_checkbox.dart` **only if it does not already exist**
- Test: `test/features/lesson/presentation/bookmarks_sheet_test.dart`

**Interfaces:**
- Consumes: `LessonBookmarksRepository.unmarkAll` and `.mark` from Plan 1.
- Produces: `InkCheckbox({required bool isSelected, required VoidCallback onTap})` if it has
  to be built here.

**`InkCheckbox` is named by four plans now** and built by none of them specifically: Quiz 3,
Quiz 5, custom track A, and this one. **Check `lib/core/ui/components/ink_checkbox.dart`
before writing a line.** If it exists, use it. If two of these plans are executed in
parallel, this is where the collision happens.

Its spec, from Section 3: 15 by 15, radius 3, a 1.4px `inkMuted` border, filling `board`
with a white check when selected.

**From Section 3:**

- Entered with "Edit", left with "Done".
- In Custom, grips remain, so a row can carry both a grip and a checkbox. This is the
  platform convention and needs no explanation.
- A footer closed by a 1px `rule` top: "N selected" in `bodySmall` `inkMuted`, a secondary
  "Select all", and **"Remove"** as a secondary button bordered and lettered in `rust`.
- **Undo on bulk removal**, as a ruled banner reusing `ErrorBanner`'s variant and action
  slot: "3 bookmarks removed" with "Undo". **No undo on reordering**, because "undo which
  drag" has no clear answer. A single bookmark is trivially recovered by reopening the
  lesson, so undo exists for the bulk case.
- Rows carry a chevron outside Edit mode, since each opens its lesson. **Inside Edit mode a
  tap selects, so the chevron is not drawn.**

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('Edit swaps to Done and reveals checkboxes', (tester) async {
    await pumpSheet(tester, rows: 3);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    expect(find.byType(InkCheckbox), findsNWidgets(3));
  });

  testWidgets('a row in edit mode selects rather than opening',
      (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lesson 1'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
    expect(find.byType(InkChevron), findsNothing);
  });

  testWidgets('select all selects every row', (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    expect(find.text('3 selected'), findsOneWidget);
  });

  testWidgets('removing offers an undo naming the count', (tester) async {
    await pumpSheet(tester, rows: 3);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('3 bookmarks removed'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('undo puts them back', (tester) async {
    // ... remove all three, tap Undo
    expect(remarked, hasLength(3));
  });

  testWidgets('removing one says bookmark, not bookmarks', (tester) async {
    // ... select exactly one, Remove
    expect(find.text('1 bookmark removed'), findsOneWidget);
  });
```

The last test is the plural that ships wrong if nobody writes it down.

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/presentation/bookmarks_sheet_test.dart`
Expected: FAIL.

- [ ] **Step 3: Build `InkCheckbox` if it is missing**

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A 15 by 15 selection box: a hairline border unselected, filled board with
/// a white check when selected. Named by several plans; whichever ran first
/// built it.
class InkCheckbox extends StatelessWidget {
  const InkCheckbox({
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: isSelected ? colors.board : null,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isSelected ? colors.board : colors.inkMuted,
            width: 1.4,
          ),
        ),
        child: isSelected
            ? Icon(Icons.check, size: 11, color: colors.onBoard)
            : null,
      ),
    );
  }
}
```

- [ ] **Step 4: Build edit mode**

Hold `editing` and a `Set<LessonId> selected` in the sheet's state. The footer's Remove
calls `unmarkAll(selected)`, then shows an `ErrorBanner` with `variant:
ErrorBannerVariant.success`, the message `'$n bookmark${n == 1 ? '' : 's'} removed'`, and
`actionLabel: 'Undo'`.

Undo re-marks each removed id. **`mark()` writes a fresh `markedAt` and, in Custom, a fresh
top-of-list `sortIndex`**, so an undone bulk removal comes back at the top rather than where
it was. Say so in the commit message; restoring the exact prior positions would mean
snapshotting every row's `sortIndex` before the delete, which is worth doing only if Aedwon
asks.

- [ ] **Step 5: Run the whole suite**

Run: `flutter test`
Expected: PASS. This is the last task in the plan, so the suite is the gate.

- [ ] **Step 6: Check layering, format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): edit mode, bulk removal and one undo

Undo is for the bulk case: a single bookmark is recovered by reopening
the lesson, and undo which drag has no clear answer."
```

---

## What this plan deliberately does not do

- **Nothing sets a bookmark.** The reader's ribbon control is Plan 4. Every surface here is
  reachable and empty until it lands, which is the drawn behaviour: the section renders
  nothing at all rather than teaching itself by nagging.
- **No search.** Plan 3b.
- **No undo on reordering**, by decision. "Undo which drag" has no clear answer.
- **Undo does not restore prior positions**, only the rows. Noted in Task 7.
- **Nothing touches `question_flags_local`.** Different feature, different table, and the
  word "flag" appears nowhere in this plan's code.

## Verification

```bash
flutter analyze                                  # clean
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # no new violations
flutter test                                     # all pass
grep -rn "flag" lib/features/lesson              # no matches
```

By hand, once Plan 4 can set one:

- A bookmark set in the reader appears at the head of the map, and its topic row gains a
  ribbon.
- Four bookmarks show "See all"; three do not, and the head still draws exactly three.
- Custom order drags, survives switching away and back, and takes a new bookmark at the top.
- Removing several offers one undo that names the count, and says "bookmark" for one.
- **The sheet's wash in dark theme.** The known weak point.

## Decided without asking, reversible in one line

- **The chosen order lives in `account_prefs`**, so it syncs. Stated with its reason in
  Task 1.
- **A bookmark whose lesson is no longer in the corpus is dropped**, and the count follows
  the visible rows. The alternative, a row that cannot be opened, is worse.
- **`InkTableRow` gains a `leadingMeta` widget slot** so the ribbon has somewhere to sit.
  The alternative was a `Stack`, which would not participate in the row's layout.
