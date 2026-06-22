# Study Tab, Plan 3b of 5: Search Implementation Plan

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

**Goal:** Search across titles, summaries and lesson bodies from the Study map's app bar,
with the matched text shown, and the sentence a body match came from.

**Architecture:** No search infrastructure. A `LIKE` scan over the exam's lesson rows
narrows the corpus, a pure Dart pass over Portable Text extracts the plain body and builds
the snippet, and the results are a flat list. The bar swaps its title for a field in place,
so no route is pushed and the tab bar stays.

**Tech Stack:** Flutter, Riverpod, Drift, `flutter_test`. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-27-study-tab-and-reader-design.md`,
Section 2.

**Depends on Plan 1** for `recentlyOpenedLessonIds` and **Plan 2** for the map page this bar
belongs to. Independent of Plan 3a: they share nothing but the app bar.

## Why there is no FTS5, decided in the spec and not reopened

141 titles and summaries are roughly 15KB, filtered in Dart in well under a millisecond, and
a `LIKE` scan over 141 body rows is tens of milliseconds. FTS5 would earn its place only for
ranking and snippet extraction, **and it is not available in any case**: the app opens
`NativeDatabase` against the OS SQLite with no `sqlite3_flutter_libs` bundled. Any step here
that reaches for `MATCH` or a virtual table is wrong.

Matching is **case-insensitive substring**. No stemming, no fuzzy matching, no relevance
ranking. Results come back in corpus order.

**Why bodies are in scope**, measured against the real corpus:

| Query | Titles | + summaries | + bodies |
|---|---|---|---|
| venn | 1 | 1 | 1 |
| gemdas | 1 | 1 | 1 |
| buoyan | 1 | 1 | 1 |
| isotope | 1 | 1 | 1 |
| swap | 0 | 0 | 1 |

Four of five land from the title alone, because the parentheticals authors wrote into titles
are an index nobody set out to create. "swap" is the case that justifies bodies: the mnemonic
*"Less than means swap the plan"* lives in the text of a lesson titled *Algebraic
Expressions*, and a trick is what a student actually half-remembers.

## Global Constraints

- **No new dependencies.** Especially no search package and no `sqlite3_flutter_libs`.
- **Work only inside your worktree.**
- **Layering (`tool/check_layering.dart`).** R1, R2, R3 as elsewhere. The text extraction and
  the snippet are pure and live in `domain/`, so they import no Flutter.
- **Analysis is `very_good_analysis` with `strict-casts` and `strict-inference`.**
- **Never invent a figure.** The only number printed is a count of matches, and the corpus
  size in the placeholder. Both are counted.
- **No em dashes in any string.**
- **Highlighting uses weight and colour only.** No background fill: `mark` is transparent in
  this identity.
- **Widget tests use `test/helpers/pump_app.dart`**, extensions on `WidgetTester`.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/features/lesson/domain/portable_text_plain.dart` — Portable Text to plain text. Pure.
- `lib/features/lesson/domain/models/lesson_search_hit.dart` — one result row.
- `lib/features/lesson/domain/use_cases/build_search_snippet.dart` — the lead, the trail and
  the ellipses. Pure.
- `lib/features/lesson/application/lesson_search_providers.dart` — the query controller and
  the results.
- `lib/features/lesson/presentation/widgets/search_field_bar.dart` — the bar in its search
  state.
- `lib/features/lesson/presentation/widgets/search_results.dart` — the list, the empty query
  state and the no-match state.
- the matching tests under `test/features/lesson/`.

**Modify:**
- `lib/core/storage/data/repos/content_repository.dart` — `searchLessonRows`.
- `lib/core/storage/storage.dart` — its provider.
- `lib/features/lesson/presentation/learn_tab_home.dart` — the magnifier, and swapping the
  bar.

---

## Task 1: Plain text out of Portable Text

**Files:**
- Create: `lib/features/lesson/domain/portable_text_plain.dart`
- Test: `test/features/lesson/domain/portable_text_plain_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `String portableTextToPlain(List<Map<String, dynamic>> blocks)`. Tasks 2 and 3
  both call it.

**Why this exists rather than searching the JSON directly.** `bodyJson` is a serialised
Portable Text array. A `LIKE` over it matches `_type`, `marks`, style names and span keys, so
"block" would hit all 141 lessons and "strong" would hit every bolded one. The SQL scan is a
**narrowing** step only; the match is confirmed against the extracted plain text, and the
snippet is cut from it.

- [ ] **Step 1: Write the failing test**

Create `test/features/lesson/domain/portable_text_plain_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/lesson/domain/portable_text_plain.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> block(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text, 'marks': <String>[]},
      ],
    };

void main() {
  test('spans in a block join without a gap', () {
    final plain = portableTextToPlain([
      {
        '_type': 'block',
        'style': 'normal',
        'children': [
          {'_type': 'span', 'text': 'Less than means ', 'marks': <String>[]},
          {'_type': 'span', 'text': 'swap', 'marks': ['strong']},
          {'_type': 'span', 'text': ' the plan.', 'marks': <String>[]},
        ],
      },
    ]);

    expect(plain, 'Less than means swap the plan.');
  });

  test('blocks are separated by a space', () {
    expect(
      portableTextToPlain([block('First block.'), block('Second block.')]),
      'First block. Second block.',
    );
  });

  test('headings are part of the searchable text', () {
    expect(
      portableTextToPlain([block('Core Concept', style: 'h2')]),
      'Core Concept',
    );
  });

  test('a block with no children contributes nothing', () {
    expect(
      portableTextToPlain([
        {'_type': 'block', 'style': 'normal'},
        block('Only this.'),
      ]),
      'Only this.',
    );
  });

  test('a non-block entry is skipped rather than throwing', () {
    expect(
      portableTextToPlain([
        {'_type': 'image', 'asset': 'whatever'},
        block('Only this.'),
      ]),
      'Only this.',
    );
  });

  test('an empty body is an empty string', () {
    expect(portableTextToPlain(const []), '');
  });
}
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/domain/portable_text_plain_test.dart`
Expected: FAIL. `portable_text_plain.dart` does not exist.

- [ ] **Step 3: Write it**

Create `lib/features/lesson/domain/portable_text_plain.dart`:

```dart
/// Flattens Portable Text to the words a student typed into search.
///
/// A `LIKE` over the stored JSON would match `_type`, `marks` and style names,
/// so "block" would hit every lesson. The SQL scan narrows; this decides.
String portableTextToPlain(List<Map<String, dynamic>> blocks) {
  final parts = <String>[];

  for (final block in blocks) {
    if (block['_type'] != 'block') continue;
    final children = block['children'];
    if (children is! List) continue;

    final buffer = StringBuffer();
    for (final child in children) {
      if (child is! Map) continue;
      final text = child['text'];
      if (text is String) buffer.write(text);
    }
    if (buffer.isNotEmpty) parts.add(buffer.toString());
  }

  return parts.join(' ');
}
```

- [ ] **Step 4: Run it, then format, analyze and commit**

Run: `flutter test test/features/lesson/domain/portable_text_plain_test.dart`
Expected: PASS, 6 tests.

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/features/lesson/domain test/features/lesson/domain
git commit -m "feat(study): flatten a lesson body to searchable text

A LIKE over the stored JSON matches _type and marks, so it can only ever
narrow. This is what decides whether a lesson actually matched."
```

---

## Task 2: The snippet

**Files:**
- Create: `lib/features/lesson/domain/use_cases/build_search_snippet.dart`
- Test: `test/features/lesson/domain/build_search_snippet_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `class SearchSnippet { String text; int matchStart; int matchLength; }` and
  `SearchSnippet? buildSearchSnippet({required String source, required String query, int
  lead = 34, int trail = 46})`, returning null when the query is not in the source. Task 3
  attaches it to a hit; Task 5 renders it.

**From Section 2:** when the match is not in the title, a third line carries the sentence it
came from, with an ellipsis on each truncated side, roughly **34 characters of lead and 46
of trail**. Without this a body match is a row with no visible reason to be there.

The snippet carries where the match sits so the renderer can weight it, rather than the
renderer searching the snippet again and finding a different occurrence.

- [ ] **Step 1: Write the failing test**

Create `test/features/lesson/domain/build_search_snippet_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/build_search_snippet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sentence =
      'When you divide or multiply by a negative number, less than means '
      'swap the plan and the sign turns around the other way entirely.';

  test('a query that is not there has no snippet', () {
    expect(buildSearchSnippet(source: sentence, query: 'isotope'), isNull);
  });

  test('matching is case insensitive', () {
    expect(buildSearchSnippet(source: sentence, query: 'SWAP'), isNotNull);
  });

  test('the snippet points at the match it found', () {
    final snippet = buildSearchSnippet(source: sentence, query: 'swap')!;

    expect(
      snippet.text.substring(
        snippet.matchStart,
        snippet.matchStart + snippet.matchLength,
      ),
      'swap',
    );
  });

  test('a truncated lead and trail are elided', () {
    final snippet = buildSearchSnippet(source: sentence, query: 'swap')!;

    expect(snippet.text.startsWith('...'), isTrue);
    expect(snippet.text.endsWith('...'), isTrue);
  });

  test('a match near the start is not elided on the left', () {
    final snippet = buildSearchSnippet(source: sentence, query: 'When')!;

    expect(snippet.text.startsWith('...'), isFalse);
    expect(snippet.matchStart, 0);
  });

  test('a match near the end is not elided on the right', () {
    final snippet = buildSearchSnippet(source: sentence, query: 'entirely')!;

    expect(snippet.text.endsWith('...'), isFalse);
  });

  test('a short source comes back whole', () {
    final snippet = buildSearchSnippet(source: 'Venn diagrams', query: 'venn')!;

    expect(snippet.text, 'Venn diagrams');
    expect(snippet.matchStart, 0);
    expect(snippet.matchLength, 4);
  });

  test('an empty query has no snippet', () {
    expect(buildSearchSnippet(source: sentence, query: ''), isNull);
  });
}
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/domain/build_search_snippet_test.dart`
Expected: FAIL. `build_search_snippet.dart` does not exist.

- [ ] **Step 3: Write it**

Create `lib/features/lesson/domain/use_cases/build_search_snippet.dart`:

```dart
/// A cut of matched text, and where the match sits inside it.
class SearchSnippet {
  const SearchSnippet({
    required this.text,
    required this.matchStart,
    required this.matchLength,
  });

  final String text;

  /// An index into [text], not into the source. The renderer weights exactly
  /// this range rather than searching the snippet again and finding a
  /// different occurrence.
  final int matchStart;
  final int matchLength;
}

const _ellipsis = '...';

/// Cuts [lead] characters before the first match and [trail] after it,
/// eliding each side only when it was actually truncated. Null when the query
/// is not in the source, which is how a caller tells a title match from a
/// body one.
SearchSnippet? buildSearchSnippet({
  required String source,
  required String query,
  int lead = 34,
  int trail = 46,
}) {
  if (query.isEmpty) return null;

  final at = source.toLowerCase().indexOf(query.toLowerCase());
  if (at < 0) return null;

  final start = at - lead < 0 ? 0 : at - lead;
  final endCandidate = at + query.length + trail;
  final end = endCandidate > source.length ? source.length : endCandidate;

  final elideLeft = start > 0;
  final elideRight = end < source.length;

  final body = source.substring(start, end);
  final text = '${elideLeft ? _ellipsis : ''}$body'
      '${elideRight ? _ellipsis : ''}';

  return SearchSnippet(
    text: text,
    matchStart: at - start + (elideLeft ? _ellipsis.length : 0),
    matchLength: query.length,
  );
}
```

- [ ] **Step 4: Run it, then format, analyze and commit**

Run: `flutter test test/features/lesson/domain/build_search_snippet_test.dart`
Expected: PASS, 8 tests.

```bash
dart format lib test
flutter analyze
git add lib/features/lesson/domain test/features/lesson/domain
git commit -m "feat(study): cut the sentence a body match came from

Without it a body hit is a row with no visible reason to be in the
list, which is worse than not searching bodies at all."
```

---

## Task 3: The query

**Files:**
- Modify: `lib/core/storage/data/repos/content_repository.dart`
- Modify: `lib/core/storage/storage.dart`
- Create: `lib/features/lesson/domain/models/lesson_search_hit.dart`
- Create: `lib/features/lesson/application/lesson_search_providers.dart`
- Test: `test/core/storage/data/repos/content_repository_search_test.dart`
- Test: `test/features/lesson/application/lesson_search_providers_test.dart`

**Interfaces:**
- Consumes: `portableTextToPlain` (Task 1), `buildSearchSnippet` (Task 2),
  `studyMapProvider` (Plan 2), `recentlyOpenedLessonIds` (Plan 1).
- Produces:
  `ContentRepository.searchLessonRows({required List<TopicId> topicIds, required String
  query})` returning `Future<List<LessonRow>>`;
  `class LessonSearchHit { LessonId lessonId; String title; String topicName; int
  estimatedMinutes; SearchSnippet? titleMatch; SearchSnippet? bodySnippet; }`;
  `searchQueryProvider` (a `StateProvider<String>`), `searchResultsProvider`
  (`FutureProvider<List<LessonSearchHit>>`), `searchCorpusSizeProvider`
  (`FutureProvider<int>`) and `recentlyOpenedLessonsProvider`
  (`FutureProvider<List<StudyLesson>>`). Tasks 4 and 5 read these.

**Ordering is corpus order**: subject, then topic, then the authored lesson order. That is
the `StudyMap`'s own walk, the same source Plan 3a's "By subject" uses. No relevance ranking.

- [ ] **Step 1: Write the failing repository test**

Create `test/core/storage/data/repos/content_repository_search_test.dart`. Seed one topic and
three lessons: one matching in the title, one in the summary, one only in the body, plus one
that matches nothing:

```dart
  test('a title match comes back', () async {
    expect(
      (await repo.searchLessonRows(topicIds: ['t1'], query: 'venn'))
          .map((row) => row.id),
      contains('l_title'),
    );
  });

  test('a body match comes back', () async {
    expect(
      (await repo.searchLessonRows(topicIds: ['t1'], query: 'swap'))
          .map((row) => row.id),
      contains('l_body'),
    );
  });

  test('matching ignores case', () async {
    expect(
      await repo.searchLessonRows(topicIds: ['t1'], query: 'VENN'),
      isNotEmpty,
    );
  });

  test('a topic outside the list is never searched', () async {
    expect(
      await repo.searchLessonRows(topicIds: ['t_other'], query: 'venn'),
      isEmpty,
    );
  });

  test('an empty query returns nothing rather than everything', () async {
    expect(await repo.searchLessonRows(topicIds: ['t1'], query: ''), isEmpty);
  });
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/core/storage/data/repos/content_repository_search_test.dart`
Expected: FAIL. `searchLessonRows` is not defined.

- [ ] **Step 3: Write the query**

In `lib/core/storage/data/repos/content_repository.dart`:

```dart
  /// Narrows the corpus to rows whose title, summary or serialised body
  /// contains [query]. **This can only narrow**: the body column is Portable
  /// Text JSON, so a hit here may be on a key or a mark name. The caller
  /// confirms against the flattened text.
  Future<List<LessonRow>> searchLessonRows({
    required List<TopicId> topicIds,
    required String query,
  }) async {
    if (query.isEmpty || topicIds.isEmpty) return const [];
    final needle = '%${query.toLowerCase()}%';

    return (_db.select(_db.lessons)
          ..where(
            (l) =>
                l.topicId.isIn(topicIds) &
                (l.title.lower().like(needle) |
                    l.summary.lower().like(needle) |
                    l.bodyJson.lower().like(needle)),
          )
          ..orderBy([
            (l) => OrderingTerm.asc(l.ordering),
            (l) => OrderingTerm.asc(l.id),
          ]))
        .get();
  }
```

`lower()` is drift's `Expression<String>.lower()`. If the analyzer cannot resolve it on this
drift version, use `customExpression` with `lower(lessons.title)` rather than pulling every
row into Dart.

Add the provider in `lib/core/storage/storage.dart` only if a caller outside a provider
needs it; Task 3's providers call the repository directly.

- [ ] **Step 4: Write the failing providers test**

Create `test/features/lesson/application/lesson_search_providers_test.dart`, asserting:

- a title match sets `titleMatch` and leaves `bodySnippet` null
- a body-only match sets `bodySnippet` and leaves `titleMatch` null
- a row whose only "match" is the word `block` inside the JSON structure **is not returned**
- results are in corpus order, not marking order
- an empty query gives an empty list
- `searchCorpusSizeProvider` counts the exam's lessons
- `recentlyOpenedLessonsProvider` returns at most three, newest first

The third is the one that catches the whole design being wrong:

```dart
  test('a JSON key is not a match', () async {
    // Every lesson body serialises the word "block" as a _type.
    expect(await container.read(searchResultsProvider.future), isEmpty);
  }, skip: false);
```

Set `searchQueryProvider` to `'block'` before reading it.

- [ ] **Step 5: Write the hit and the providers**

Create `lib/features/lesson/domain/models/lesson_search_hit.dart` holding the fields listed
under Interfaces, then `lib/features/lesson/application/lesson_search_providers.dart`:

```dart
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    FutureProvider<List<LessonSearchHit>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return const [];

  final map = await ref.watch(studyMapProvider.future);
  if (map == null) return const [];

  // Corpus order, and the topic name every row prints, from the map the
  // screen behind is already holding.
  final topicNameByLessonId = <LessonId, String>{};
  final positionByLessonId = <LessonId, int>{};
  final topicIds = <TopicId>[];
  var position = 0;
  for (final subject in map.subjects) {
    for (final topic in subject.topics) {
      topicIds.add(topic.id);
      for (final lesson in topic.lessons) {
        topicNameByLessonId[lesson.id] = topic.name;
        positionByLessonId[lesson.id] = position++;
      }
    }
  }

  final rows = await ref
      .watch(contentRepositoryProvider)
      .searchLessonRows(topicIds: topicIds, query: query);

  final hits = <LessonSearchHit>[];
  for (final row in rows) {
    final titleMatch = buildSearchSnippet(source: row.title, query: query);
    final summaryMatch =
        buildSearchSnippet(source: row.summary, query: query);

    SearchSnippet? bodySnippet;
    if (titleMatch == null) {
      final plain = portableTextToPlain(
        List<Map<String, dynamic>>.from(jsonDecode(row.bodyJson) as List),
      );
      bodySnippet = buildSearchSnippet(source: plain, query: query) ??
          summaryMatch;
    }

    // The SQL scan can hit a JSON key or a mark name. If neither the title,
    // the summary nor the flattened body contains the query, it did not
    // match anything a student can see.
    if (titleMatch == null && bodySnippet == null) continue;

    hits.add(
      LessonSearchHit(
        lessonId: row.id,
        title: row.title,
        topicName: topicNameByLessonId[row.id] ?? '',
        estimatedMinutes: row.estimatedMinutes,
        titleMatch: titleMatch,
        bodySnippet: bodySnippet,
      ),
    );
  }

  hits.sort(
    (a, b) => (positionByLessonId[a.lessonId] ?? 0)
        .compareTo(positionByLessonId[b.lessonId] ?? 0),
  );
  return hits;
});
```

Add `searchCorpusSizeProvider` as the map's `totalCount`, and
`recentlyOpenedLessonsProvider` joining `recentlyOpenedLessonIds` to the map's lessons,
dropping any id no longer in the corpus.

- [ ] **Step 6: Run both test files, then format, analyze and commit**

Run: `flutter test test/core/storage/ test/features/lesson/`

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): search titles, summaries and bodies

The SQL LIKE runs over serialised Portable Text and can only narrow.
A hit is confirmed against the flattened body, so searching for block
returns nothing rather than all 141 lessons."
```

---

## Task 4: The bar becomes a field

**Files:**
- Create: `lib/features/lesson/presentation/widgets/search_field_bar.dart`
- Modify: `lib/features/lesson/presentation/learn_tab_home.dart`
- Test: `test/features/lesson/presentation/search_field_bar_test.dart`

**Interfaces:**
- Consumes: `searchQueryProvider`, `searchCorpusSizeProvider` from Task 3.
- Produces: `SearchFieldBar({required VoidCallback onCancel})`, and the magnifier glyph on
  the map's app bar.

**From Section 2:** tapping the magnifier **replaces the bar in place**: the title gives way
to a full-width field, with **Cancel** in 12/600 `board` at the right. **No route is
pushed**, so the tab bar stays and the back stack is untouched. Cancel restores the map at
its previous scroll position.

The field: a 1px `ink` bottom rule, 6px vertical padding, the magnifier leading in
`inkMuted`, input at `bodyLarge`, placeholder **"Search 141 lessons"** where the count is the
corpus size for the active exam.

**The magnifier is drawn, not an icon font.** 19px, stroke 1.6, `inkMuted`: a circle of
radius 6.5 centred at (10.5, 10.5) with a handle from (15.3, 15.3) to (20, 20). Put it in
`lib/core/ui/components/ink_magnifier.dart` beside `InkChevron`, since the field uses it too.

**The app bar has exactly one trailing element and never more.**

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the placeholder counts the corpus', (tester) async {
    await tester.pumpAppWithProviders(
      SearchFieldBar(onCancel: () {}),
      overrides: [
        searchCorpusSizeProvider.overrideWith((ref) async => 141),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Search 141 lessons'), findsOneWidget);
  });

  testWidgets('typing writes the query', (tester) async {
    // ... enterText 'venn', expect the container's searchQueryProvider to read 'venn'
  });

  testWidgets('cancel calls back and clears the query', (tester) async {
    var cancelled = false;
    // ... tap 'Cancel'
    expect(cancelled, isTrue);
    expect(container.read(searchQueryProvider), '');
  });

  testWidgets('the map bar shows one trailing element', (tester) async {
    // ... pump StudyTabHome, expect exactly one InkMagnifier in the bar
    expect(find.byType(InkMagnifier), findsOneWidget);
  });
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/presentation/search_field_bar_test.dart`
Expected: FAIL.

- [ ] **Step 3: Build the magnifier, the field and the swap**

`InkMagnifier` is a `CustomPaint` on the geometry above, in the same shape as `InkChevron`
from Plan 1 Task 7.

In `learn_tab_home.dart`, hold `bool _searching` in the page's state. When false the bar
draws the title and the magnifier; when true it draws `SearchFieldBar`. **Do not push a
route**, and do not rebuild the body's `ScrollController`: keeping the same controller is
what restores the scroll position on Cancel.

Cancel sets `_searching = false` and clears `searchQueryProvider`.

- [ ] **Step 4: Run it, then format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): the app bar becomes a search field in place

No route is pushed, so the tab bar stays and cancelling comes back to
the same scroll position rather than the top of the map."
```

---

## Task 5: Results, and the two states around them

**Files:**
- Create: `lib/features/lesson/presentation/widgets/search_results.dart`
- Modify: `lib/features/lesson/presentation/learn_tab_home.dart`
- Test: `test/features/lesson/presentation/search_results_test.dart`

**Interfaces:**
- Consumes: `searchResultsProvider`, `recentlyOpenedLessonsProvider` from Task 3.
- Produces: `SearchResults()`, replacing the map's body while the bar is in its search state.

**From Section 2:**

- A kicker above the list: "N lessons" in 11.5 `inkMuted`.
- Each row: the title with the matched substring in `ink` at w700 and the rest at normal
  weight, the topic beneath in `bodySmall` `inkMuted`, the minutes right-aligned, a trailing
  chevron.
- **When the match is not in the title**, a third line carries the sentence, in `bodySmall`
  `inkMuted`, with the match in `ink` w700 and an ellipsis on each truncated side.
- **Highlighting uses weight and colour only. No background fill.**

| State | Treatment |
|---|---|
| Field open, empty query | "Recently opened" kicker over the last three lessons opened, each a tappable row |
| No matches | Centred, serif 18 `Nothing matched "swap"`, body "Try a shorter word, or part of one." |

**The no-match headline quotes the query.** The spec draws it with curly quotes. Use the
plain `"` unless the rest of the app's copy already uses curly ones, and never an em dash.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the kicker counts the matches', (tester) async {
    await pumpResults(tester, hits: 3);

    expect(find.text('3 lessons'), findsOneWidget);
  });

  testWidgets('one match says lesson, not lessons', (tester) async {
    await pumpResults(tester, hits: 1);

    expect(find.text('1 lesson'), findsOneWidget);
  });

  testWidgets('a title match is weighted, not filled', (tester) async {
    await pumpResults(tester, hits: 1);

    final title = tester.widget<RichText>(find.byType(RichText).first);
    final spans = (title.text as TextSpan).children!.cast<TextSpan>();
    final matched = spans.firstWhere((span) => span.text == 'Venn');
    expect(matched.style?.fontWeight, FontWeight.w700);
    expect(matched.style?.backgroundColor, isNull);
  });

  testWidgets('a body match shows the sentence it came from', (tester) async {
    await pumpResults(tester, bodyHit: true);

    expect(find.textContaining('swap the plan'), findsOneWidget);
  });

  testWidgets('an empty query offers the recently opened', (tester) async {
    await pumpResults(tester, query: '', recent: 2);

    expect(find.text('Recently opened'), findsOneWidget);
  });

  testWidgets('no matches names what was typed', (tester) async {
    await pumpResults(tester, query: 'swap', hits: 0);

    expect(find.text('Nothing matched "swap"'), findsOneWidget);
    expect(find.text('Try a shorter word, or part of one.'), findsOneWidget);
  });
```

- [ ] **Step 2: Run it to verify it fails**

Run: `flutter test test/features/lesson/presentation/search_results_test.dart`
Expected: FAIL.

- [ ] **Step 3: Build the list**

Highlighting is a `RichText` built from the snippet's `matchStart` and `matchLength`, in
three spans: before, matched at `FontWeight.w700` in `ink`, and after. **Do not search the
string again inside the widget**: the snippet already carries where the match is, and
searching twice finds a different occurrence when a word repeats.

Rows route with `context.push('/lesson/${hit.lessonId}')`.

- [ ] **Step 4: Run the whole suite**

Run: `flutter test`
Expected: PASS. Last task in the plan, so the suite is the gate.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(study): search results, weighted rather than filled

A body match carries the sentence it came from, because the row is
otherwise a title with no visible reason to be in the list."
```

---

## What this plan deliberately does not do

- **No relevance ranking.** Corpus order, by decision in the spec. 141 lessons and a
  substring match do not need scoring.
- **No stemming and no fuzzy matching.** "swap" does not find "swapping" unless the text
  contains it; that is the trade the spec took to avoid an index.
- **No search history.** The empty-query state offers recently opened lessons, which is what
  the app already knows, not a list of past queries it would have to start recording.
- **No search outside the active exam.** The topic list comes from the map, which is one
  exam's.

## Verification

```bash
flutter analyze                                  # clean
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # no new violations
flutter test                                     # all pass
grep -rn "MATCH\|fts5\|sqlite3_flutter_libs" lib pubspec.yaml   # no matches
```

By hand, on a device:

- The magnifier swaps the bar in place, the tab bar stays, and Cancel returns to the same
  scroll position.
- "venn", "gemdas", "buoyan" and "isotope" each find their lesson from the title.
- **"swap" finds *Algebraic Expressions*** and shows the mnemonic sentence beneath it. That
  is the case the whole body scan exists for.
- "block" finds nothing, which proves the JSON is being confirmed rather than matched.
- Typing into an empty field and clearing it returns to "Recently opened".

## Decided without asking, reversible in one line

- **The placeholder counts the active exam's lessons**, so it reads "Search 16 lessons" on
  CSE Professional today rather than 141. The spec's 141 is UPCAT's number.
- **A summary match is treated as a body match** for the third line, since the spec only
  distinguishes "in the title" from "not in the title".
- **Plain quotes in `Nothing matched "swap"`** unless the app's copy already uses curly ones.
