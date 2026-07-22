# Quiz Tab, Plan 5 of 6: The Debrief

> **Typography, amended 11 August 2026.** Any "serif" below is superseded: the
> app uses one family, Source Sans 3, everywhere. See
> `decisions/2026-08-10-typeface-log.md`.



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

**Goal:** Replace `DoneForTodayCelebration` with the screen the spec draws: what was answered,
what is coming back, why each miss happened, and an optional invitation to say what the app
could not know.

**Architecture:** One pure builder assembles the whole screen's content from the session, the
attempt and two new queries, so the page renders and does no arithmetic. The mistake tags
write to the column Plan 1 already added.

**Tech Stack:** Flutter, Riverpod, drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-28-quiz-tab-design.md` Section 4 in full,
and Section 9's note on short labels.

**Decision log:** `docs/superpowers/decisions/2026-07-28-quiz-tab-decision-log.md`. The
"Review the misses" button was drawn and deleted on 27 July and then partly restored on
28 July as one ruled row; both entries matter and the difference between them is the point.

**Depends on:** Plan 1 (merged: the `mistakeTag` column and the nullable `shortLabel`) and
Plan 4, whose reveal this screen follows.

---

## Two things this plan degrades around, and one it computes rather than quotes

1. **No question has a `shortLabel`.** Plan 1 added the nullable field and the generation
   pass has not run. **Miss rows fall back to the stem, clamped to two lines**, which is what
   Section 9 specifies: "Nullable. Renderers fall back to the stem clamped to two lines."
   **Through the shared renderer, never a plain `Text`**, or a clamped stem shows a raw
   `$F_{net} = ma$`.
2. **The "slipped" cause has a second sentence the app cannot write.** The spec's example
   reads "You had this right on 14 July. **Today you multiplied where you needed to
   divide.**" The first sentence is a stored fact. The second is a claim about *this*
   mistake, which nothing in the app knows: it is the per-choice rationale, and the rationale
   pass has not run. **Render the first sentence alone**, and append the second from
   `Choice.rationale` once that content lands. Writing it any other way would print a
   sentence this project inferred, which the figure rule forbids in prose as well as in
   numbers.
3. **"You'll see all three again tomorrow" is computed, not quoted.** A miss derives
   `Rating.again` and comes back tomorrow, but the interval is on the outcome and the
   sentence must agree with it. Build the sentence from `nextReviewIntervalDays`, so a
   scheduler change cannot make the copy a lie.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand, and never committed.**
- **Check `lib/core/ui/components/` before writing any widget.** `StatsBand` gained `centred`
  and `compact` in Plan 2b and this screen's figures use both.
- **Never invent a figure.** Both figures here are measured: the score is counted and the
  time is the session's own elapsed. The inferred causes are all derived from stored data,
  which is why there are three of them and not five.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no coloured left-border panels, no blur, no shimmer.
- **Colour carries meaning.** The one board button is "Done". The invitation's button is
  **secondary bordered**. Miss marks are rust.
- **Voice.** Contractions throughout: "you've", "it's", "you'll". The plainest correct word
  over the formal one: **"seen"**, not "encountered" or "met". **No system vocabulary**:
  nothing is "booked" or "scheduled". **Nothing praises the student.** **No em dashes.**
  Scores are **points**, never marks.
- **Layering.** R1, R2, R3. **The baseline is 7 violations.** In particular, do not read
  `PerQuestionSpeedSignal` from `features/quiz` for the rushed line; Task 1 adds the query
  where it belongs.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/features/quiz/domain/debrief/miss_cause.dart` — the three causes, pure.
- `lib/features/quiz/domain/debrief/session_debrief.dart` — the whole screen's content,
  pure.
- `lib/features/quiz/presentation/pages/debrief_page.dart`
- `lib/features/quiz/presentation/debrief_providers.dart`
- Tests mirroring each.

**Modify:**
- `lib/core/storage/data/repos/attempts_repository.dart` — the two queries the causes need.
- `lib/features/quiz/presentation/quiz_page.dart` — show the debrief at the end.
- `lib/app/router.dart` — `/quiz/debrief/:attemptId`.

**Delete:**
- `lib/features/quiz/presentation/done_for_today_celebration.dart` and its test.

**Not touched:** the review component, Plan 6. The "Go through all 10" row is built here and
routes to `/review`, which Plan 6 fills.

---

## Task 1: What the causes need

**Files:**
- Modify: `lib/core/storage/data/repos/attempts_repository.dart`
- Test: `test/core/storage/data/repos/attempts_repository_history_test.dart` (create)

**Interfaces:**
- Produces, relied on by Task 2:
  - `AttemptsRepository.averageResponseMsByTopic({required ExamId examId, required Map<QuestionId, TopicId> topicOf, required DateTime now, Duration window}) -> Future<Map<TopicId, int>>`
  - `AttemptsRepository.lastCorrectAt({required ExamId examId, required QuestionId questionId, required DateTime before}) -> Future<DateTime?>`

**Why the caller passes `topicOf`.** `attempts_local` stores question ids and no topics, and
this repository is in `core/storage` and must not reach into content to resolve them. The
debrief provider already holds the session's questions, so it knows the mapping.

**`lastCorrectAt` takes `before`** so the current session's own attempt cannot be found as
"a prior correct attempt", which would make every repeat miss read as a slip.

- [ ] **Step 1: Write the failing test**

Create `test/core/storage/data/repos/attempts_repository_history_test.dart` following the
shape of `attempts_repository_outcomes_test.dart` from Plan 2b. Cover:

```dart
  test('the topic average is over that topic only', () async {
    // q_1 and q_2 in topic_algebra at 20s and 40s, q_3 in topic_geometry at 5s.
    // Expect {topic_algebra: 30000, topic_geometry: 5000}.
  });

  test('a topic with no answers is absent rather than zero', () async {
    // Expect the map not to contain the untouched topic.
  });

  test('a prior correct answer comes back with its date', () async {
    // q_1 answered correctly on 14 July, then wrongly on 2 August.
    // lastCorrectAt(before: 2 August) is 14 July.
  });

  test('a prior wrong answer is not a prior correct one', () async {
    expect(await repo.lastCorrectAt(...), isNull);
  });

  test('the current attempt cannot count as its own history', () async {
    // Only one attempt, correct, at exactly `before`.
    expect(await repo.lastCorrectAt(before: thatMoment), isNull);
  });
```

Write the bodies in full.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/repos/attempts_repository_history_test.dart`
Expected: FAIL. Neither method is defined.

- [ ] **Step 3: Add the queries**

```dart
  /// Average time on a question, per topic, inside [window].
  ///
  /// The caller supplies [topicOf] because `attempts_local` stores question
  /// ids and nothing else, and this layer must not reach into content to
  /// resolve them.
  Future<Map<TopicId, int>> averageResponseMsByTopic({
    required ExamId examId,
    required Map<QuestionId, TopicId> topicOf,
    required DateTime now,
    Duration window = const Duration(days: 30),
  }) async {
    final cutoff = now.subtract(window);
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) &
                t.startedAt.isBiggerOrEqualValue(cutoff),
          ))
        .get();

    final totals = <TopicId, int>{};
    final counts = <TopicId, int>{};
    for (final row in rows) {
      for (final item in _hydrate(row).items) {
        final topicId = topicOf[item.questionId];
        if (topicId == null) continue;
        totals[topicId] = (totals[topicId] ?? 0) + item.responseMs;
        counts[topicId] = (counts[topicId] ?? 0) + 1;
      }
    }
    return {
      for (final entry in totals.entries)
        entry.key: (entry.value / counts[entry.key]!).round(),
    };
  }

  /// When this question was last answered correctly before [before], or null.
  ///
  /// [before] excludes the session that is being debriefed, so its own answer
  /// cannot be mistaken for history.
  Future<DateTime?> lastCorrectAt({
    required ExamId examId,
    required QuestionId questionId,
    required DateTime before,
  }) async {
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) & t.startedAt.isSmallerThanValue(before),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();

    for (final row in rows) {
      final attempt = _hydrate(row);
      for (final item in attempt.items) {
        if (item.questionId == questionId && item.isCorrect) {
          return attempt.startedAt;
        }
      }
    }
    return null;
  }
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/storage/data/repos/attempts_repository_history_test.dart`
Expected: PASS, 5 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage test/core/storage
git commit -m "feat(storage): the two reads the debrief's causes need

Four of the five causes the debrief could name need no question at all,
and both of the ones that survive come from attempts already stored: the
topic's usual pace, and whether this question was ever right before."
```

---

## Task 2: `SessionDebrief`

**Files:**
- Create: `lib/features/quiz/domain/debrief/miss_cause.dart`
- Create: `lib/features/quiz/domain/debrief/session_debrief.dart`
- Test: `test/features/quiz/domain/debrief/session_debrief_test.dart`

**Interfaces:**
- Consumes: `QuizSession`, `AnswerOutcome`, `Question`, the queries from Task 1.
- Produces, relied on by Tasks 3 and 4:

```dart
sealed class MissCause
class RushedCause   { int responseSeconds; int usualSeconds; String topicName; }
class SlippedCause  { DateTime lastCorrectAt; }
class NewCause      {}

class DebriefMiss {
  QuestionId questionId; String label; bool labelIsStem;
  String topicName; String pickedLabel; String answerLabel;
  MissCause? cause; MistakeTag? tag;
}

class SessionDebrief {
  String headline;          // "Ten answered."
  int correct; int total; int minutes;
  String sourceLine;        // "Today's session. Chemistry, Physics and Biology."
  List<DebriefMiss> misses;
  String returnPromise;     // "You'll see all three again tomorrow."
  bool get isClean;
}
```

**From the spec, Section 4:**

- **"Ten answered."** in serif 22/700, computed from the session length. **Not "Session
  complete"**, which is software talking about itself.
- **Two** centred figures: **correct** and **taken**. **Not "spent"**, which frames the time
  as lost. **No streak figure**: it is on Home and in Progress, and a streak is a fact about
  the month while this page is about the ten questions just answered.
- **"To come back to"** as the section heading, with the count. **Not "What you missed"**:
  these are not losses, they are scheduled returns, which is literally what the scheduler
  just did.
- Each miss: a rust ✕ in the 22px gutter, the question, then "topic · you picked B, answer
  was A" in 12 `inkMuted`.
- **"You'll see all three again tomorrow."** in 12 `inkMuted`, for both tiers. It is the most
  reassuring true sentence available on this screen and it gives the Free version a proper
  ending rather than stopping dead.

**The headline spells the number.** "Ten answered." with a word, not "10 answered.". Sessions
run 3 to 50, so the map has to cover that range.

**The return promise is computed** from the misses' `nextReviewIntervalDays`, not hardcoded.
All-tomorrow is the common case because a miss derives `Rating.again`, but the sentence must
follow the scheduler rather than assert against it.

**A clean session has no misses**, and the section, the promise and the review row all go
with them. It still gets a headline, its figures and its footer.

- [ ] **Step 1: Write the failing test**

Create `test/features/quiz/domain/debrief/session_debrief_test.dart` covering:

```dart
  test('the headline spells the count', () {
    // A session of 10.
    expect(debrief.headline, 'Ten answered.');
  });

  test('the headline handles a length outside the spelled range', () {
    // A session of 47.
    expect(debrief.headline, '47 answered.');
  });

  test('the figures are counted and measured', () {
    expect(debrief.correct, 7);
    expect(debrief.total, 10);
    expect(debrief.minutes, 9);
  });

  test('the source line names the topics in the session', () {
    expect(
      debrief.sourceLine,
      "Today's session. Chemistry, Physics and Biology.",
    );
  });

  test('one topic reads without a list', () {
    expect(debrief.sourceLine, "Today's session. Chemistry.");
  });

  test('a drill names itself differently', () {
    // origin: SessionOrigin.drill
    expect(debrief.sourceLine, startsWith('Practice.'));
  });

  test('every miss carries its pick and its answer', () {
    expect(debrief.misses.single.pickedLabel, 'B');
    expect(debrief.misses.single.answerLabel, 'A');
  });

  test('a miss falls back to its stem when it has no short label', () {
    expect(debrief.misses.single.labelIsStem, isTrue);
  });

  test('a short label is used when the content has one', () {
    expect(debrief.misses.single.label, 'Balancing an equation');
    expect(debrief.misses.single.labelIsStem, isFalse);
  });

  test('the return promise counts the misses and follows the scheduler', () {
    // Three misses, all with nextReviewIntervalDays 1.
    expect(debrief.returnPromise, "You'll see all three again tomorrow.");
  });

  test('one miss reads in the singular', () {
    expect(debrief.returnPromise, "You'll see it again tomorrow.");
  });

  test('a longer interval is said plainly', () {
    // Misses at 1 and 3 days.
    expect(debrief.returnPromise, "You'll see all two again within 3 days.");
  });

  test('a clean session has no misses and no promise', () {
    expect(debrief.isClean, isTrue);
    expect(debrief.returnPromise, isEmpty);
  });
```

**Fix the plural in "all two" before writing the implementation.** "all two" is not English.
Use "You'll see both again within 3 days." for two, "all three" for three and up. Write the
test that way and delete this note when it passes.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/debrief/session_debrief_test.dart`
Expected: FAIL. Neither file exists.

- [ ] **Step 3: Write the causes**

Create `lib/features/quiz/domain/debrief/miss_cause.dart`:

```dart
/// Why a miss happened, as far as stored data can say.
///
/// Three, not five. Four of the five causes the debrief could name need no
/// question at all; the fifth, misreading, is invisible to every signal the
/// app has, and it is the only thing the tagging in Section 4 buys.
sealed class MissCause {
  const MissCause();
}

/// Answered far faster than this student usually answers in this topic.
class RushedCause extends MissCause {
  const RushedCause({
    required this.responseSeconds,
    required this.usualSeconds,
    required this.topicName,
  });

  final int responseSeconds;
  final int usualSeconds;
  final String topicName;

  /// "You answered in 4 seconds. You usually take 21 on Chemistry."
  String get line =>
      'You answered in $responseSeconds seconds. '
      'You usually take $usualSeconds on $topicName.';
}

/// Right before, wrong now.
class SlippedCause extends MissCause {
  const SlippedCause(this.lastCorrectAt);

  final DateTime lastCorrectAt;

  /// The spec's example continues "Today you multiplied where you needed to
  /// divide", which is a claim about this particular mistake. Nothing in the
  /// app knows that: it is the per-choice rationale, and that content pass has
  /// not run. Only the stored fact is stated here.
  String line(String day) => 'You had this right on $day.';
}

/// Never seen before.
class NewCause extends MissCause {
  const NewCause();

  String get line => "It's the first time you've seen this one.";
}

/// How much faster than usual counts as rushed.
///
/// Half the topic's own average, so it scales with the student rather than
/// against a constant somebody picked.
const rushedFraction = 0.5;

/// Below this many answers there is no usual pace to be faster than.
const rushedMinimumAnswers = 5;
```

- [ ] **Step 4: Write the debrief builder**

Create `lib/features/quiz/domain/debrief/session_debrief.dart` with `BuildSessionDebrief.call`
taking the session, the outcomes, a `Map<TopicId, String>` of topic names, the topic averages
and answer counts from Task 1, a `Map<QuestionId, DateTime?>` of prior correct dates, and
`proIsActive`.

Cause selection, in order:

```dart
    // Order matters. A question never seen before cannot have been slipped,
    // and a slip is more specific than a rush, so the most specific fact the
    // data supports wins.
    MissCause? causeFor(...) {
      if (!proIsActive) return null;
      final lastCorrect = priorCorrect[question.id];
      if (lastCorrect != null) return SlippedCause(lastCorrect);
      if (!hasAnyHistory) return const NewCause();

      final usualMs = topicAverageMs[question.topicId];
      final answers = topicAnswerCount[question.topicId] ?? 0;
      if (usualMs == null || answers < rushedMinimumAnswers) return null;
      if (outcome.responseMs > usualMs * rushedFraction) return null;
      return RushedCause(
        responseSeconds: (outcome.responseMs / 1000).round(),
        usualSeconds: (usualMs / 1000).round(),
        topicName: topicNames[question.topicId] ?? 'this topic',
      );
    }
```

**A cause is optional.** Where the data supports none, the miss row carries no italic line,
and that is correct rather than a gap to fill.

The spelled numbers:

```dart
/// Sessions run 3 to 50. Beyond the spelled range the digits are used, which
/// is what a sentence does anyway once the number gets long.
const _spelled = <int, String>{
  1: 'One', 2: 'Two', 3: 'Three', 4: 'Four', 5: 'Five', 6: 'Six',
  7: 'Seven', 8: 'Eight', 9: 'Nine', 10: 'Ten', 11: 'Eleven',
  12: 'Twelve', 15: 'Fifteen', 20: 'Twenty',
};
```

The source line:

```dart
    // "Today's session" only when it was one. A drill is not today's session
    // and saying so would be the app describing itself wrongly.
    final opener = switch (origin) {
      SessionOrigin.todayTopic || SessionOrigin.todayInterleaved =>
        "Today's session.",
      SessionOrigin.drill => 'Practice.',
      SessionOrigin.retake => 'Your mistakes.',
      SessionOrigin.inline => 'From the lesson.',
    };
```

with the topic names joined "A, B and C".

- [ ] **Step 5: Run the tests**

Run: `flutter test test/features/quiz/domain/debrief/`
Expected: PASS.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz/domain/debrief test/features/quiz/domain/debrief
git commit -m "feat(quiz): the debrief's content, computed

Three causes rather than five: the other two are invisible to every
signal the app has. The return promise follows the scheduler's own
intervals rather than asserting tomorrow and hoping."
```

---

## Task 3: The debrief screen

**Files:**
- Create: `lib/features/quiz/presentation/debrief_providers.dart`
- Create: `lib/features/quiz/presentation/pages/debrief_page.dart`
- Test: `test/features/quiz/presentation/pages/debrief_page_test.dart`
- Modify: `lib/features/quiz/presentation/quiz_page.dart`
- Modify: `lib/app/router.dart`
- Delete: `lib/features/quiz/presentation/done_for_today_celebration.dart` and its test

**Interfaces:**
- Consumes: `SessionDebrief` from Task 2, `StatsBand` with `centred` and `compact`.
- Produces: `DebriefPage({required String attemptId, required bool proIsActive})` and
  `sessionDebriefProvider`.

**From the spec, Section 4, "Composition":** app bar with a close ✕ only. Then the headline,
the figures, the source line, "To come back to" with its count, the miss rows, the return
promise, one ruled row **"Go through all 10"**, and a footer with a single board **"Done"**.

**The miss rows are a record, not navigation.** No chevrons, and nothing happens on tap. A
"Review the misses" button was drawn and deleted: the student saw every one of them seconds
ago, a wrong answer already derives `Rating.again` and returns tomorrow, and "Your mistakes"
on the tab is the deliberate path when they want it.

**"Go through all 10" does not reopen that button.** The deleted one re-listed the misses,
which the student had just read. This one reaches the **explanations**, which were read once
under the momentum of a session and were otherwise unreachable afterwards. It sits **below
the return promise, above the footer**, and it is the single way through.

**The row's label counts the session**, so a five-question session reads "Go through all 5".

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the headline speaks plainly', (tester) async {
    expect(find.text('Ten answered.'), findsOneWidget);
    expect(find.text('Session complete'), findsNothing);
  });

  testWidgets('two figures, correct and taken', (tester) async {
    expect(find.text('correct'), findsOneWidget);
    expect(find.text('taken'), findsOneWidget);
    expect(find.text('spent'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
  });

  testWidgets('the section is a return, not a loss', (tester) async {
    expect(find.text('To come back to'), findsOneWidget);
    expect(find.text('What you missed'), findsNothing);
  });

  testWidgets('miss rows do not navigate', (tester) async {
    // Assert no InkWell wraps a miss row and no chevron icon is present.
  });

  testWidgets('the return promise is shown to Free too', (tester) async {
    // proIsActive: false.
    expect(
      find.text("You'll see all three again tomorrow."),
      findsOneWidget,
    );
  });

  testWidgets('the review row counts the session', (tester) async {
    expect(find.text('Go through all 10'), findsOneWidget);
  });

  testWidgets('a clean session drops the section and the row',
      (tester) async {
    expect(find.text('To come back to'), findsNothing);
    expect(find.textContaining('Go through all'), findsNothing);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('the inferred cause is Pro only', (tester) async {
    // Same debrief, proIsActive false then true.
    expect(find.textContaining('You usually take'), findsNothing);
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/pages/debrief_page_test.dart`
Expected: FAIL.

- [ ] **Step 3: Write the page**

The miss row, with the rust ✕ in the same 22px gutter the reveal's notes use:

```dart
class _MissRow extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    // A record, not navigation. No InkWell, no chevron, nothing on tap: the
    // student read every one of these seconds ago.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text('✕', style: styles.bodyMedium.copyWith(color: colors.rust)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A clamped stem still carries LaTeX and markdown, so it goes
                // through the renderer even when it is only two lines.
                PortableTextRenderer(
                  text: miss.label,
                  maxLines: miss.labelIsStem ? 2 : null,
                ),
                const SizedBox(height: 2),
                Text(
                  '${miss.topicName} · you picked ${miss.pickedLabel}, '
                  'answer was ${miss.answerLabel}',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
                if (miss.cause != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    causeLine(miss.cause!),
                    style: styles.bodySmall.copyWith(
                      color: colors.inkMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

`PortableTextRenderer` may not take `maxLines`. **Add it rather than clamping with a plain
`Text`**, and if that is impractical, say so and clamp with the renderer inside a
`ConstrainedBox` sized to two lines.

The review row, below the promise and above the footer:

```dart
        if (!debrief.isClean) ...[
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colors.rule, width: AppDimensions.hairline),
              ),
            ),
            child: InkTableRow(
              title: 'Go through all ${debrief.total}',
              bottomRule: false,
              // Not the deleted "Review the misses" button. That one re-listed
              // what had just been read. This reaches the explanations, which
              // were read once under the momentum of a session and had no way
              // back.
              onTap: () => context.push('/review?attemptId=$attemptId'),
            ),
          ),
        ],
```

`/review` exists in the router as a stub. Plan 6 fills it.

Wire `quiz_page.dart` to push the debrief on `QuizComplete` instead of rendering
`DoneForTodayCelebration`, then delete that widget and its test.

- [ ] **Step 4: Run the tests**

Run: `flutter test test/features/quiz/`
Expected: PASS. Tests referencing `DoneForTodayCelebration` are deleted with it.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add -A lib/features/quiz test/features/quiz lib/app/router.dart
git commit -m "feat(quiz): the debrief replaces the celebration

The rows are a record: the student read every miss seconds ago. One row
below the promise reaches the explanations instead, which were read once
under the momentum of a session and had no way back."
```

---

## Task 4: The invitation

**Files:**
- Modify: `lib/features/quiz/presentation/pages/debrief_page.dart`
- Modify: `lib/features/quiz/presentation/debrief_providers.dart`
- Modify: `lib/core/storage/data/repos/attempts_repository.dart`
- Test: `test/features/quiz/presentation/pages/debrief_tagging_test.dart` (create)

**Interfaces:**
- Consumes: `MistakeTag`, which Plan 1 added to `AttemptItem`.
- Produces: `AttemptsRepository.tagItem({required AttemptId attemptId, required QuestionId questionId, required MistakeTag tag}) -> Future<void>`.

**From the spec, Section 4, "The invitation":** **Pro only, optional, and offered once for the
whole screen** rather than per row. Opened by a 1px `rule`:

> These are the notes Pantas could write on its own. **You're the only one who knows the
> rest.**
>
> [ Finish the notes ]

A **secondary bordered** button. Tapping it arms three choices under every miss: **"I misread
it"**, **"I knew this, I just slipped"**, **"I didn't know it"**, each a 14px checkbox row.

**Any may be left blank, and the screen says so:** "2 of 3 noted. Leave any of them blank, it
costs nothing." When all three are noted: "All three noted. Progress can use them now."

**Why it is a debrief and not a form.** The app goes first with three facts it already knew,
so the student is correcting a draft rather than filling in blanks. And it is after the
session, not inside it, because the error-log method it borrows from is a review pass rather
than a prompt between questions.

**This commits Progress to consuming the tags.** Three taps that surface nowhere would be
worse than never asking. **Note it in the work checkpoint when this task lands.**

**The counter's denominator is the number of misses**, not three. "2 of 3 noted" in the spec
is an example with three misses.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('Free is never invited', (tester) async {
    // proIsActive: false.
    expect(find.text('Finish the notes'), findsNothing);
  });

  testWidgets('Pro is invited once, not per row', (tester) async {
    expect(find.text('Finish the notes'), findsOneWidget);
    expect(
      find.text('These are the notes Pantas could write on its own. '
          "You're the only one who knows the rest."),
      findsOneWidget,
    );
  });

  testWidgets('the invitation arms three choices under every miss',
      (tester) async {
    await tester.tap(find.text('Finish the notes'));
    await tester.pumpAndSettle();

    // Three misses, three choices each.
    expect(find.text('I misread it'), findsNWidgets(3));
    expect(find.text('I knew this, I just slipped'), findsNWidgets(3));
    expect(find.text("I didn't know it"), findsNWidgets(3));
  });

  testWidgets('leaving one blank is stated to cost nothing', (tester) async {
    // Arm, then tag two of three.
    expect(
      find.text('2 of 3 noted. Leave any of them blank, it costs nothing.'),
      findsOneWidget,
    );
  });

  testWidgets('finishing them all says what it bought', (tester) async {
    expect(
      find.text('All three noted. Progress can use them now.'),
      findsOneWidget,
    );
  });

  testWidgets('a tag is written to the attempt', (tester) async {
    // Tag one, then read the attempt back and assert the item's mistakeTag.
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/pages/debrief_tagging_test.dart`
Expected: FAIL.

- [ ] **Step 3: Add the write**

```dart
  /// Records what the student said went wrong, from the debrief.
  ///
  /// Rewrites the whole items blob because they are stored as JSON on the
  /// attempt row. One tag a tap is not a hot path.
  Future<void> tagItem({
    required AttemptId attemptId,
    required QuestionId questionId,
    required MistakeTag tag,
  }) async {
    final attempt = await byId(attemptId);
    if (attempt == null) return;
    await save(
      attempt.copyWith(
        items: [
          for (final item in attempt.items)
            item.questionId == questionId ? item.copyWith(mistakeTag: tag) : item,
        ],
      ),
    );
  }
```

`Attempt` and `AttemptItem` are freezed, so `copyWith` exists. Check that `save` marks the
row for sync; if it does not, set the sync state the way the other writers do, or the tag
never leaves the device.

- [ ] **Step 4: Build the invitation**

The invitation is `StatefulWidget` state on the page: one bool for armed, and the tags come
from the debrief's own `misses`, refreshed by invalidating `sessionDebriefProvider` after
each write.

The counter line:

```dart
  String noteCounter(int noted, int total) {
    if (noted == total) {
      return total == 3
          ? 'All three noted. Progress can use them now.'
          : 'All $total noted. Progress can use them now.';
    }
    return '$noted of $total noted. Leave any of them blank, it costs nothing.';
  }
```

The choices are checkbox rows at 14px, reusing the picker's `_PickerCheckbox` shape from Plan
3. **That widget is private to the picker page.** Either promote it to
`lib/core/ui/components/` as `InkCheckbox` and use it in both, or write a small local one
here. **Promoting is better** and Plan 3's is already the right shape; say which you did.

- [ ] **Step 5: Run the whole suite**

Run: `flutter test`
Expected: PASS. This is the last task, so the suite is the gate.

- [ ] **Step 6: Record the commitment, then commit**

Add to `docs/superpowers/2026-08-02-work-checkpoint.md`, under the open items:

```markdown
- **Progress must consume the mistake tags.** The debrief now asks for them and writes
  `AttemptItem.mistakeTag`. Three taps that surface nowhere would be worse than never
  asking. Plan 5 Task 4 landed the asking; the Progress side is unbuilt.
```

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test docs
git commit -m "feat(quiz): the debrief asks what it could not know

The app goes first with three facts it already had, so the student is
correcting a draft rather than filling in blanks. Offered once for the
screen, and every one of them may be left blank."
```

---

## What this plan deliberately does not do

- **The review component.** Plan 6. The "Go through all 10" row routes to `/review` and that
  route is still a stub when this plan lands.
- **The short-label content pass.** Miss rows fall back to the clamped stem, through the
  renderer, which is what Section 9 specifies.
- **The slipped cause's second sentence.** It needs the per-choice rationale. The stored
  fact is stated alone until that content lands.
- **Consuming the tags in Progress.** Recorded as owed in Task 4.
- **A confidence step at answer time.** Rejected in Section 3; this screen is what recovers
  what it would have bought.

## Verification

```bash
flutter analyze                                  # no issues outside tool/
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # still 7, not 8
flutter test                                     # all pass
```

By hand, on a device:

- Finishing a session lands on "Ten answered." with two figures and no streak.
- The misses list, with no chevrons, and tapping one does nothing.
- On Free: the promise and the review row, and no invitation anywhere.
- On Pro: an italic cause under the misses the data can explain, and none under the ones it
  cannot.
- "Finish the notes" arms three choices under every miss and the counter updates as they are
  used.
- A question with LaTeX in its stem reads as mathematics in the miss row.

## Self-review notes

Checked against Section 4 in full:

- Headline, two figures, the source line, the section heading and its count: Tasks 2, 3.
- Miss rows with the gutter mark, the pick and the answer, and no navigation: Task 3.
- The inferred cause, Pro only, three kinds: Tasks 1, 2.
- The return promise on both tiers: Tasks 2, 3.
- The single ruled row and the board footer: Task 3.
- The invitation, its copy, its counters and its writes: Task 4.
- Voice: contractions, "seen", no system vocabulary, no praise.
- **Three documented degradations**, all named above and all closing on content rather than
  on code.
