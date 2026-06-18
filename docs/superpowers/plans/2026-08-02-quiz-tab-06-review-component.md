# Quiz Tab, Plan 6 of 6: The Review Component

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the list of questions with their answers and their notes, and put it behind
its three entrances: the debrief's row, the Quiz tab's Flagged row, and a finished mock.

**Architecture:** One component in `lib/core/ui/components/` so both features can draw it,
fed by three small feature-side providers that differ only in where their questions come from.
`quiz_results_page.dart` is rebuilt as one of the three rather than deleted.

**Tech Stack:** Flutter, Riverpod, drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-28-mock-exam-ui-design.md` Sections 5 and 6,
plus `2026-07-28-quiz-tab-design.md` Section 1's flagged section and Section 3's notes.

**Decision log:** `docs/superpowers/decisions/2026-07-28-quiz-tab-decision-log.md`.

**Depends on:** Plan 4 for `AnswerReveal` and `PennantMark`, Plan 5 for the debrief row that
opens it, and Plan 2c for the Flagged row that this plan finally makes tappable.

---

## Why this is last, and why it is a component

Section 5's note on plan size lists it sixth because "every one of its three entrances is
built above it, and it is the piece that makes `quiz_results_page.dart` worth keeping".

**`quiz_results_page.dart` is unreachable code today.** Its only entry was the "Review
results" button on the session ending, which the debrief deleted. Rather than delete the
page, Plan 5's debrief gained one ruled row opening this review scoped to the session just
finished.

**Three differences the data forces, and nothing else:**

| | Mock review | Practice review | Flagged list |
|---|---|---|---|
| Grouping | By subject, with a count | Flat | By subject |
| Filters | All, Wrong, Flagged | The same row, same **Wrong** default | None: everything in it is flagged |
| The one-time offer | Present | **Absent** | Absent |
| The footer | None | None | Board **"Practice these 12"** |

## The tier rule, and the amendment it carries

**Free gets every question, the correct answer and the authored explanation**, which is note
A. **Pro adds note B**, the note addressed to the choice that student actually made. The
review is otherwise identical on both tiers.

**This formally amends Spec 5 D11**, which reads "Free: score + section + top-3 weak topics +
Drill CTA. Pro: full per-question review with explanations." D11 predates the Free-records
Pro-interprets rule and **is reversed rather than quietly ignored**. Three arguments decided
it, and the third could not be answered:

1. Gating the mock alone is not a line, it is a delay. The mock draws from the same bank as
   practice, where Free already sees note A.
2. The mock already carries the tab's only visible paywall, one per 14 days. Gating its
   review charges twice on one surface.
3. **A gated review is a dead end, and this was checked rather than assumed.**
   `AttemptsRepository.recentIncorrects` queries `attemptsLocal` only. Mock attempts live in
   `mock_attempts_table`, and D4 keeps mocks out of FSRS on purpose. So mock misses never
   reach "Your mistakes" and never come back through the scheduler. Gate the review and a
   Free user's 38 wrong answers have nowhere left to go at all.

**Do not add a locked state, an upgrade line or a blurred note.** Note B is simply absent for
Free, which is Section 3's rule for the reveal and applies unchanged here.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand, and never committed.**
- **Check `lib/core/ui/components/` before writing any widget.** After Plans 4 and 5 it holds
  `AnswerReveal`, `PennantMark`, `QuestionGridSheet`, `InkCheckbox`, `PortableTextRenderer`,
  `SectionHeader`, `InkTableRow`, `BoardButton`, `EmptyState`.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no coloured left-border panels, no blur, no shimmer. **No pills** on
  the filter row: plain labels separated by 1px by 12px `rule` ticks, the active one in `ink`
  w700.
- **Colour carries meaning.** The one board button in this plan is the Flagged list's
  "Practice these N". The one-time offer's buttons are secondary.
- **Voice.** Grade-5-simple English, short sentences, **no em dashes**. Scores are **points**.
- **Layering.** R1, R2, R3. **The baseline is 7 violations.** The component lives in
  `core/ui/` precisely so `features/mock_exam` and `features/quiz` can both draw it without
  importing each other.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/core/ui/components/review_list.dart` — the filters, the grouping and the expanding
  rows.
- `lib/features/quiz/presentation/review_providers.dart` — the practice and flagged sources.
- `lib/features/quiz/presentation/pages/flagged_list_page.dart`
- Tests mirroring each.

**Modify:**
- `lib/features/quiz/presentation/quiz_results_page.dart` — rebuilt as the practice review.
- `lib/features/mock_exam/presentation/pages/mock_results_page.dart` — the row into the
  review.
- `lib/features/mock_exam/presentation/pages/mock_review_page.dart` — create if absent; the
  mock's own review, with the one-time offer.
- `lib/features/quiz/presentation/quiz_tab_home.dart` — the Flagged row opens.
- `lib/app/router.dart` — `/review`, `/quiz/flagged`, and the mock's review route.

**Not touched:** the mock's results screen beyond its one row, which belongs to the mock UI
spec's own plans.

---

## Task 1: `ReviewEntry` and the filters

**Files:**
- Create: `lib/core/ui/components/review_list.dart` (the models first)
- Test: `test/core/ui/components/review_model_test.dart`

**Interfaces:**
- Produces, relied on by every later task:

```dart
enum ReviewFilter { all, wrong, flagged }

class ReviewEntry {
  int number;                 // the question's position in its paper or session
  Question question;
  ChoiceId? chosenChoiceId;   // null when it was left blank in a mock
  bool isFlagged;
  String subjectName;
  String label;               // short label, or the stem
  bool labelIsStem;
  bool get isCorrect;
  bool get isAnswered;
}

class ReviewCounts { int all; int wrong; int flagged; }

abstract final class FilterReviewEntries {
  static List<ReviewEntry> call(List<ReviewEntry> entries, ReviewFilter filter);
  static ReviewCounts count(List<ReviewEntry> entries);
  static Map<String, List<ReviewEntry>> groupBySubject(List<ReviewEntry> entries);
}
```

**From the spec, Section 5, "Filters":** a single ruled row, **All 120 · Wrong 38 · Flagged
N**, plain labels separated by 1px by 12px `rule` ticks, active in `ink` w700. **No pills.**

**Wrong is the default.** It is what almost everyone opens this for, and All is one tap away.

**Grouping is by subject**, not by topic and not by lesson: "the subject is the level a
student thinks in when scanning a paper".

**An unanswered question is not a wrong one.** In a mock a question may be left blank, and
blank is its own thing. It counts in All, and it counts in Wrong, because from the student's
point of view a blank is a question they did not get. **State that in the code**, because the
opposite reading is equally defensible and a later reader will wonder.

- [ ] **Step 1: Write the failing test**

```dart
  test('counts split the paper three ways', () {
    // 5 entries: 3 right, 1 wrong, 1 blank, 2 of them flagged.
    expect(counts.all, 5);
    expect(counts.wrong, 2);      // the wrong one and the blank one
    expect(counts.flagged, 2);
  });

  test('the wrong filter keeps blanks', () {
    expect(
      FilterReviewEntries.call(entries, ReviewFilter.wrong).map((e) => e.number),
      equals([4, 5]),
    );
  });

  test('the flagged filter keeps only flags', () { ... });

  test('the all filter keeps the order it was given', () { ... });

  test('grouping keeps subjects in first-seen order', () {
    // Entries in paper order across two subjects, interleaved.
    expect(grouped.keys, equals(['Mathematics', 'Science']));
  });

  test('grouping keeps question order inside a subject', () { ... });
```

Write the bodies in full, building `ReviewEntry` values directly.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/ui/components/review_model_test.dart`
Expected: FAIL.

- [ ] **Step 3: Write the models**

```dart
enum ReviewFilter { all, wrong, flagged }

/// One question as the review lists it.
class ReviewEntry {
  const ReviewEntry({
    required this.number,
    required this.question,
    required this.isFlagged,
    required this.subjectName,
    required this.label,
    required this.labelIsStem,
    this.chosenChoiceId,
  });

  final int number;
  final Question question;

  /// Null where the question was left blank, which a mock allows and a
  /// practice session does not.
  final ChoiceId? chosenChoiceId;

  final bool isFlagged;
  final String subjectName;

  /// The authored short label, or the stem when the content pass has not
  /// reached this question.
  final String label;
  final bool labelIsStem;

  bool get isAnswered => chosenChoiceId != null;

  bool get isCorrect =>
      chosenChoiceId != null && chosenChoiceId == question.correctChoice.id;
}

class ReviewCounts {
  const ReviewCounts({
    required this.all,
    required this.wrong,
    required this.flagged,
  });

  final int all;
  final int wrong;
  final int flagged;
}

abstract final class FilterReviewEntries {
  /// A blank counts as wrong.
  ///
  /// Not because it is graded the same, but because the student opening this
  /// filter is looking for what they did not get, and a question they never
  /// answered is one of those. The opposite reading is defensible; this one is
  /// chosen and stated so a later reader does not have to guess.
  static bool _isMiss(ReviewEntry entry) => !entry.isCorrect;

  static List<ReviewEntry> call(
    List<ReviewEntry> entries,
    ReviewFilter filter,
  ) =>
      switch (filter) {
        ReviewFilter.all => entries,
        ReviewFilter.wrong => entries.where(_isMiss).toList(),
        ReviewFilter.flagged =>
          entries.where((entry) => entry.isFlagged).toList(),
      };

  static ReviewCounts count(List<ReviewEntry> entries) => ReviewCounts(
        all: entries.length,
        wrong: entries.where(_isMiss).length,
        flagged: entries.where((entry) => entry.isFlagged).length,
      );

  /// First-seen order, so the groups follow the paper rather than the
  /// alphabet.
  static Map<String, List<ReviewEntry>> groupBySubject(
    List<ReviewEntry> entries,
  ) {
    final grouped = <String, List<ReviewEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.subjectName, () => []).add(entry);
    }
    return grouped;
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/ui/components/review_model_test.dart`
Expected: PASS, 6 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/ui/components/review_list.dart \
        test/core/ui/components/review_model_test.dart
git commit -m "feat(ui): the review list's model

Grouped by subject because that is the level a student thinks in when
scanning a paper. A blank counts as wrong: the filter is for what you did
not get, and a question you never answered is one of those."
```

---

## Task 2: The list

**Files:**
- Modify: `lib/core/ui/components/review_list.dart`
- Test: `test/core/ui/components/review_list_test.dart`

**Interfaces:**
- Consumes: `AnswerReveal` and `PennantMark` from Plan 4, the models from Task 1.
- Produces:

```dart
ReviewList({
  required List<ReviewEntry> entries,
  required bool proIsActive,
  required bool grouped,
  required ValueChanged<QuestionId> onToggleFlag,
  Widget? header,     // the mock's one-time offer
  Widget? footer,     // the flagged list's "Practice these 12"
  ReviewFilter initialFilter = ReviewFilter.wrong,
  bool showFilters = true,
})
```

**From the spec, Section 5, "The list":** grouped by subject, with a serif 14/700 heading and
a count per group, closed by a 1px `rule`. Each row: the question number in serif 14/700
`inkMuted` tabular, the short label, then the outcome mark and the flag.

**"Opening a question":** **tapping expands it in place**, so a student can work down a list
of misses without losing position. Expanded: the four choices with the correct one marked
board ✓ and the chosen one rust ✕, the others at 50%, then the marginal notes from the quiz
spec's Section 3, then the flag control.

**Expanding in place is the whole point.** Do not push a detail route: the student is working
down a list and a push loses their position, which is the behaviour this replaced.

**The flag here means "practice this", and only that.** It is the same durable flag the Quiz
tab's Flagged section reads, and every pennant is tappable so unflagging is one tap.

**`AnswerReveal` gets `nextReviewIntervalDays: null` here.** Nothing was just scheduled, so
there is no interval to state.

**More than one row may be open at once.** The spec says a student works *down* a list; it
does not say the previous one closes. Leaving them open is also what makes the flag control
reachable without reopening.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('Wrong is the default filter', (tester) async {
    // 5 entries, 2 misses.
    expect(find.byType(ReviewRow), findsNWidgets(2));
  });

  testWidgets('the filter row counts each and uses no pills',
      (tester) async {
    expect(find.text('All 5'), findsOneWidget);
    expect(find.text('Wrong 2'), findsOneWidget);
    expect(find.text('Flagged 1'), findsOneWidget);
    // No pills: nothing with a rounded, filled decoration.
  });

  testWidgets('All is one tap away', (tester) async {
    await tester.tap(find.text('All 5'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewRow), findsNWidgets(5));
  });

  testWidgets('grouped mode heads each subject with a count',
      (tester) async {
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('flat mode has no headings', (tester) async {
    // grouped: false
    expect(find.text('Mathematics'), findsNothing);
  });

  testWidgets('tapping a row expands it in place', (tester) async {
    expect(find.byType(AnswerReveal), findsNothing);
    await tester.tap(find.text('Balancing an equation'));
    await tester.pumpAndSettle();
    expect(find.byType(AnswerReveal), findsOneWidget);
    // Still on the same screen, nothing pushed.
    expect(find.byType(ReviewList), findsOneWidget);
  });

  testWidgets('two rows can be open at once', (tester) async {
    // Tap two rows, expect two AnswerReveals.
  });

  testWidgets('Free sees note A and nothing about note B', (tester) async {
    // proIsActive: false, the chosen choice carrying a rationale.
    await tester.tap(find.text('Balancing an equation'));
    await tester.pumpAndSettle();

    expect(find.text('the answer'), findsOneWidget);
    expect(find.text('what you picked'), findsNothing);
    expect(find.textContaining('Pro'), findsNothing);
  });

  testWidgets('Pro sees note B', (tester) async {
    expect(find.text('what you picked'), findsOneWidget);
  });

  testWidgets('the pennant is tappable and reports the question',
      (tester) async {
    await tester.tap(find.byType(PennantMark).first);
    await tester.pumpAndSettle();
    expect(toggled, equals(['q_1']));
  });

  testWidgets('a footer renders when one is given', (tester) async {
    expect(find.text('Practice these 12'), findsOneWidget);
  });
```

Write the bodies in full.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/ui/components/review_list_test.dart`
Expected: FAIL.

- [ ] **Step 3: Write the list**

The filter row, ticks and no pills:

```dart
class _FilterRow extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    // Plain labels with rule ticks between them. No pills: a pill is a
    // filled shape, and the only filled shapes in this identity are the
    // board button and a set mark.
    return Row(
      children: [
        for (var i = 0; i < ReviewFilter.values.length; i++) ...[
          if (i > 0)
            Container(
              width: AppDimensions.hairline,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 9),
              color: colors.rule,
            ),
          InkWell(
            onTap: () => onChanged(ReviewFilter.values[i]),
            child: Text(
              _label(ReviewFilter.values[i], counts),
              style: styles.bodySmall.copyWith(
                color: active == ReviewFilter.values[i]
                    ? colors.ink
                    : colors.inkMuted,
                fontWeight: active == ReviewFilter.values[i]
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
```

The row, collapsed and expanded:

```dart
class ReviewRow extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          // Expands in place. A pushed detail route loses the student's
          // position, which is the whole reason this is a list they work
          // down rather than a stack they climb.
          onTap: onToggleExpanded,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${entry.number}',
                  style: styles.headlineSmall.copyWith(
                    fontSize: 14,
                    color: colors.inkMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Expanded(
                child: PortableTextRenderer(
                  text: entry.label,
                  maxLines: entry.labelIsStem ? 2 : null,
                ),
              ),
              _OutcomeMark(entry: entry),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => onToggleFlag(entry.question.id),
                child: PennantMark(isSet: entry.isFlagged),
              ),
            ],
          ),
        ),
        if (isExpanded)
          AnswerReveal(
            question: entry.question,
            chosenChoiceId: entry.chosenChoiceId ?? '',
            proIsActive: proIsActive,
            // Nothing was just scheduled here, so there is no interval to
            // state and no verdict to deliver: the marks already said it.
            nextReviewIntervalDays: null,
          ),
      ],
    );
  }
}
```

**A blank question has no `chosenChoiceId`.** `AnswerReveal` must handle an id matching no
choice: the correct row still marks `correctMissed` and nothing marks incorrect. **Check that
Plan 4's `_stateFor` already behaves that way**; it does, because an unmatched id falls
through to the `choice.isCorrect` branch. Add a test for it here rather than assuming.

- [ ] **Step 4: Run the tests**

Run: `flutter test test/core/ui/components/review_list_test.dart`
Expected: PASS, 11 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
dart run tool/check_layering.dart
git add lib/core/ui test/core/ui
git commit -m "feat(ui): the review list

Rows expand in place so a student can work down a list of misses without
losing their position. Free gets every question, the answer and the
authored note; Pro adds the note addressed to the choice they made."
```

---

## Task 3: The practice review

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_results_page.dart`
- Create: `lib/features/quiz/presentation/review_providers.dart`
- Test: `test/features/quiz/presentation/practice_review_test.dart`
- Modify: `lib/app/router.dart`

**Interfaces:**
- Consumes: `ReviewList`, `AttemptsRepository.byId`, `ContentRepository`.
- Produces: `practiceReviewProvider`, a `FutureProvider.family<List<ReviewEntry>, AttemptId>`,
  and `/review?attemptId=` rendering the rebuilt page.

**From the spec, Section 6:** flat, not grouped. "A ten-question session rarely spans enough
subjects to earn headings." The same filter row with the same **Wrong** default. **No
one-time offer**: practice flags are durable from the moment they are set.

**And it fixes a shipping defect.** `quiz_results_page.dart:190` lists every question by its
**raw `questionId`**. Section 9 names it. The label is the short label where the content pass
has written one and the clamped stem otherwise, through the renderer either way.

**Title "All questions"**, per Section 5.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the practice review is flat', (tester) async {
    expect(find.text('All questions'), findsOneWidget);
    // No subject headings even with two subjects in the session.
    expect(find.text('Mathematics'), findsNothing);
  });

  testWidgets('it opens on Wrong', (tester) async { ... });

  testWidgets('there is no one-time flag offer', (tester) async {
    expect(find.textContaining('Keep them to practice?'), findsNothing);
  });

  testWidgets('questions are named, not identified', (tester) async {
    // An attempt over questions with no short label.
    expect(find.textContaining('q_'), findsNothing);
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/practice_review_test.dart`
Expected: FAIL.

- [ ] **Step 3: Write the provider**

```dart
/// Every question in one finished practice attempt, in the order it was
/// asked.
final practiceReviewProvider =
    FutureProvider.family<List<ReviewEntry>, AttemptId>((ref, attemptId) async {
  final attempt = await ref.watch(attemptsRepositoryProvider).byId(attemptId);
  if (attempt == null) return const [];

  final content = ref.watch(contentRepositoryProvider);
  final flagged = await ref.watch(flaggedIdsProvider.future);

  final entries = <ReviewEntry>[];
  for (var i = 0; i < attempt.items.length; i++) {
    final item = attempt.items[i];
    final question = await content.questionById(item.questionId);
    if (question == null) continue;
    final topic = await content.topicById(question.topicId);
    entries.add(
      ReviewEntry(
        number: i + 1,
        question: question,
        chosenChoiceId: item.chosenChoiceId,
        isFlagged: flagged.contains(question.id),
        // Flat lists never show this, but the component takes it and the
        // flagged list groups on it.
        subjectName: topic?.name ?? '',
        label: question.shortLabel ?? question.stem,
        labelIsStem: question.shortLabel == null,
      ),
    );
  }
  return entries;
});
```

`topicById` returns a `Topic`, which carries `subjectId` and not a subject name. **Resolve the
subject name properly** rather than putting the topic's name in the subject slot: add
`ContentRepository.subjectById` if it is missing, following `topicById`'s shape. The flagged
list in Task 4 groups on this and a topic name there would be wrong.

- [ ] **Step 4: Rebuild the page and route it**

Replace `quiz_results_page.dart`'s body with the `ReviewList`, `grouped: false`. Keep the
file and the class name: the row that opens it is `/review?attemptId=`, and the router's
existing `/review` stub becomes this.

`proIsActive` comes from the router, which already reads `entitlementProvider`.

- [ ] **Step 5: Run the tests**

Run: `flutter test test/features/quiz/`
Expected: PASS.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(quiz): the practice review

quiz_results_page had no entrance since the debrief replaced the session
ending, and it listed every question by its raw id. It is now what the
debrief's one row opens."
```

---

## Task 4: The flagged list

**Files:**
- Create: `lib/features/quiz/presentation/pages/flagged_list_page.dart`
- Modify: `lib/features/quiz/presentation/review_providers.dart`
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/quiz/presentation/pages/flagged_list_page_test.dart`

**Interfaces:**
- Consumes: `ReviewList`, `flaggedIdsProvider` from Plan 4, `StartPractice` from Plan 3.
- Produces: `flaggedReviewProvider`, and `/quiz/flagged/:examId`.

**From the quiz spec, Section 1, "The flagged section":** the row opens a list, not a session.
It is the review component in its practice form: the flagged questions, **grouped by
subject**, each expanding in place to its choices and its notes, **every pennant tappable so
unflagging is one tap**. A board **"Practice these 12"** sits at the bottom and starts the
session.

**Straight into a session was rejected**, though it is the cheaper build. A flag is a
judgment made weeks earlier, in a different mood, about a question the student may since have
learned. Without a list there is no way to see what accumulated and no way to prune it, so
the only exit from a flag is answering it again inside a session, which is a one way door.

**The practice action is at the bottom** rather than the top, because the list is the thing
being read and the session is what you do after deciding the list is right.

**The count in the button follows the list**, so unflagging four turns "Practice these 12"
into "Practice these 8" as it happens.

**No filters.** Everything in this list is flagged, so a Flagged filter is a no-op and All is
the same list. Pass `showFilters: false`.

**Unflagging to zero** leaves an empty list. Show `EmptyState` with "Flag anything you want to
come back to", which is the same sentence the tab's row uses when empty.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the flagged list groups by subject', (tester) async { ... });

  testWidgets('it has no filter row', (tester) async {
    expect(find.textContaining('Wrong'), findsNothing);
  });

  testWidgets('the button counts what is in the list', (tester) async {
    expect(find.text('Practice these 3'), findsOneWidget);
  });

  testWidgets('unflagging updates the count as it happens', (tester) async {
    await tester.tap(find.byType(PennantMark).first);
    await tester.pumpAndSettle();
    expect(find.text('Practice these 2'), findsOneWidget);
  });

  testWidgets('emptying the list says what to do', (tester) async {
    expect(
      find.text('Flag anything you want to come back to'),
      findsOneWidget,
    );
    expect(find.textContaining('Practice these'), findsNothing);
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/pages/flagged_list_page_test.dart`
Expected: FAIL.

- [ ] **Step 3: Write the provider and the page**

`flaggedReviewProvider` reads `flagsNewestFirst()` from `QuestionFlagsRepository`, hydrates
each question, resolves its subject, and numbers them by position in the list. **Questions
whose row no longer resolves are dropped**, not rendered as blanks: a flag can outlive a
content update.

The footer starts the session through `StartPractice` with one unit per flagged question:

```dart
  Future<void> _practice(List<ReviewEntry> entries) async {
    // One unit per question, one question each, so the session is exactly the
    // list that was just read and pruned.
    await ref.read(quizControllerProvider.notifier).startPractice(
          examId: widget.examId,
          units: [
            for (final entry in entries)
              PracticeUnit(topicId: entry.question.topicId),
          ],
          perUnit: 1,
        );
```

**That is wrong and you must fix it.** `PracticeUnit` draws from a topic's pool, so one unit
per flagged question would draw arbitrary questions from those topics rather than the flagged
ones. **Add a use case or widen `StartPractice`** to take an explicit list of question ids,
which is what this entrance needs and what "Practice these 12" promises. Do it as a named
constructor or a second method, and keep the unit path for the picker:

```dart
  Future<StartPracticeResult> fromQuestionIds({
    required String userId,
    required ExamId examId,
    required List<QuestionId> questionIds,
    required DateTime now,
  })
```

Write a test for it in `test/features/quiz/domain/use_cases/start_practice_test.dart` before
using it.

Then make the tab's row tappable, which Plan 2c deliberately left inert:

```dart
        InkTableRow(
          title: 'Questions you flagged',
          subtitle: ...,
          bottomRule: false,
          onTap: flags == null || flags.count == 0
              ? null
              : () => context.push('/quiz/flagged/${exam.id}'),
        ),
```

- [ ] **Step 4: Run the tests**

Run: `flutter test test/features/quiz/`
Expected: PASS.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(quiz): the flagged list

Going straight into a session was the cheaper build and was rejected: a
flag is a judgment made weeks earlier about a question you may since have
learned, and without a list there is no way to prune it."
```

---

## Task 5: The mock review and its one-time offer

**Files:**
- Create: `lib/features/mock_exam/presentation/pages/mock_review_page.dart`
- Create: `lib/features/mock_exam/application/mock_review_providers.dart`
- Modify: `lib/features/mock_exam/presentation/pages/mock_results_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/mock_exam/presentation/mock_review_page_test.dart`

**Interfaces:**
- Consumes: `ReviewList`, `MockAttempt`, `QuestionFlagsRepository`.
- Produces: `mockReviewProvider` and `/mock/review/:attemptId`.

**From the spec, Section 5:** pushed from the results row. Title **"All questions"**. Grouped
by subject with a count per group. All, Wrong and Flagged, Wrong the default.

**"What becomes of the marks made during the paper":** they expire with the paper, because
"check before I submit" cannot outlive the submission. They are spent once, as **a one-time
offer at the top of the review**:

> You marked **12** to come back to while the clock was running. Keep them to practice?
> [ Flag all 12 ]  [ No thanks ]

**Taken or refused, the offer is gone** and nothing about the exam marks remains on screen.
There is **no fourth filter**: a permanent control for a fact that stops mattering after one
visit is a permanent cost for a temporary thing.

**Why offer rather than discard:** a student who resolves a flagged question unflags it during
the paper, so whatever survives to submission has already been filtered by the person who made
it.

**Why all or nothing:** if the twelve are genuinely wanted, picking through them one by one is
invented work. Per-question adjustment already exists afterwards, since taking the offer fills
the Flagged filter with exactly those twelve and every pennant is tappable.

**Rejected:** carrying them over silently, and two pennant states.

**"The offer is gone" must persist.** Refusing it and reopening the review must not offer
again. Store the decision per attempt: check whether `mock_attempts_table` has a spare
nullable column, and if not add one, `flagsOfferedAt`, with a migration. **Say which you
did**, because a migration bumps the schema version and Plan 1's lesson applies: never bump
`schemaVersion` without writing the migration in the same change.

**The marks come from `mock_attempt.flagsJson`**, a `Set<String>` of question ids, and taking
the offer writes each one through `QuestionFlagsRepository.flag`. Nothing writes there
automatically, per Section 6 of the quiz spec.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the offer counts the marks made under the clock',
      (tester) async {
    expect(
      find.textContaining('You marked 12 to come back to while the clock '
          'was running.'),
      findsOneWidget,
    );
    expect(find.text('Flag all 12'), findsOneWidget);
    expect(find.text('No thanks'), findsOneWidget);
  });

  testWidgets('taking it flags them all and the offer goes', (tester) async {
    await tester.tap(find.text('Flag all 12'));
    await tester.pumpAndSettle();

    expect(find.text('Flag all 12'), findsNothing);
    // And all twelve are now in the durable table.
  });

  testWidgets('refusing it also ends it', (tester) async {
    await tester.tap(find.text('No thanks'));
    await tester.pumpAndSettle();
    expect(find.textContaining('while the clock was running'), findsNothing);
  });

  testWidgets('the offer does not come back on a second visit',
      (tester) async {
    // Refuse, dispose, rebuild the page.
    expect(find.textContaining('while the clock was running'), findsNothing);
  });

  testWidgets('an attempt with no marks makes no offer', (tester) async {
    expect(find.textContaining('while the clock was running'), findsNothing);
  });

  testWidgets('there is no fourth filter', (tester) async {
    expect(find.textContaining('Marked'), findsNothing);
  });

  testWidgets('the mock review groups by subject', (tester) async { ... });

  testWidgets('Free sees every question and the answer', (tester) async {
    // proIsActive: false. Every entry is listed, note A renders.
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/mock_exam/presentation/mock_review_page_test.dart`
Expected: FAIL.

- [ ] **Step 3: Build it**

`mockReviewProvider` reads the attempt, decodes `sampledQuestionsJson` and `answersJson`,
hydrates each question, resolves subjects, and builds `ReviewEntry` values with the paper's
own numbering. A question with no answer gets `chosenChoiceId: null`.

The offer is the list's `header`:

```dart
        header: offerVisible
            ? _FlagOffer(
                count: markedIds.length,
                onKeep: () => unawaited(_keepAll(markedIds)),
                onDismiss: () => unawaited(_endOffer()),
              )
            : null,
```

Both buttons are **secondary**: the board on this screen belongs to nothing, since the review
has no primary action.

Add the row into it on `mock_results_page.dart`, per Section 4's "Into the review".

- [ ] **Step 4: Run the whole suite**

Run: `flutter test`
Expected: PASS. This is the last task of the last plan, so the suite is the gate for the
whole tab.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(mock): the review, and the marks made under the clock

A mark made during a paper means check before I submit, which cannot
outlive the submission. It is spent once as an offer rather than carried
over silently, because whatever survived to submission was already
filtered by the person who made it."
```

---

## What this plan deliberately does not do

- **The mock's results screen**, beyond adding the row into the review. It belongs to the
  mock UI spec's own plans.
- **Note B's content.** The rationale pass is Section 9's content work. Pro sees note B
  wherever it is populated.
- **Short labels.** Rows fall back to the clamped stem through the renderer.
- **A fourth filter for the paper's marks.** Rejected by name.
- **Per-question adjustment inside the offer.** Rejected: taking it fills the Flagged filter
  with exactly those questions and every pennant is tappable.

## Verification

```bash
flutter analyze                                  # no issues outside tool/
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # still 7, not 8
flutter test                                     # all pass
```

By hand, on a device:

- The debrief's "Go through all 10" opens a flat list titled "All questions", on Wrong.
- Tapping a row opens the choices and notes underneath it without leaving the list, and a
  second row can be opened too.
- On Free, every question and the answer's note; nothing hinting at a second note.
- The Quiz tab's Flagged row opens a grouped list with "Practice these N" at the bottom, and
  unflagging changes the number as it happens.
- Finishing a mock with marks offers them once; refusing it and reopening does not ask again.

## Self-review notes

Checked against the mock UI spec's Sections 5 and 6 and the quiz spec's Section 1:

- Filters with counts, no pills, Wrong default: Tasks 1, 2.
- Grouped by subject with counts, flat for practice: Tasks 1, 2, 3.
- Expanding in place with choices, notes and the flag: Task 2.
- The tier rule, and D11 reversed rather than ignored: stated at the top, enforced in Task 2.
- The one-time offer, its copy, its two outcomes, its persistence, and no fourth filter:
  Task 5.
- The flagged list grouped, every pennant tappable, the action at the bottom: Task 4.
- `quiz_results_page.dart` rebuilt rather than deleted, and its raw-id defect closed: Task 3.
- **One correction made to an earlier plan while writing this one:** `AnswerReveal` moves to
  `lib/core/ui/components/` and takes primitives, because the mock reaches it through this
  component and `core/**` may not import `features/**`. Plan 4 has been edited to match.
