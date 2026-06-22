# Mock Exam, Plan 2 of 2: The Endings

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

## AMENDED 3 August 2026: Task 2 is struck. Quiz Plan 6 owns the review component.

**Conflict C3, ruled by Aedwon.** Task 2 of this plan created
`lib/core/ui/components/question_review_list.dart`, and
`2026-08-02-quiz-tab-06-review-component.md` Task 1 creates
`lib/core/ui/components/review_list.dart`. Two components in the same directory, for the same
purpose, each defining a model called `ReviewEntry`, and each giving the same reason for the
location.

**Quiz 6 already builds the mock's configuration.** It cites this spec's Sections 5 and 6 as
its source, carries a table of all three configurations including the mock's, makes
`chosenChoiceId` nullable specifically because a mock question can be left blank, and creates
`mock_review_page.dart` itself. **Task 2 here was written as though Quiz 6 did not exist.**

**So Task 2 is struck, not merged.** Do not create `question_review_list.dart`.

**What this plan still owns**, and it is genuinely its own:

- `lib/features/mock_exam/presentation/widgets/score_headline.dart`
- `lib/features/mock_exam/presentation/widgets/exam_marks_offer.dart`, the one-time offer
- The results screen in Task 1
- Task 3 and Task 4 as written

**The offer is passed into Quiz 6's component through its header slot.** If Quiz 6 has not
landed when you reach this plan, **stop and say so.** Do not build a second list to unblock
yourself.

---

**Goal:** Build the results screen a student lands on when the clock stops, the review
screen behind it, the one-time offer that spends the marks made under the clock, and the
practice form of the same review that finally gives `quiz_results_page.dart` an entrance.

**Architecture:** The review is a **component**, not a page, because two endings render
it: the mock's and the practice session's. One results page, one review component with
two configurations, and one row added to the debrief.

**Tech Stack:** Flutter, Riverpod, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-28-mock-exam-ui-design.md` Sections 4, 5
and 6.

---

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-mock-01-the-paper.md` | `ScoreBands`, `ScoreBand.close`, the nullable `bandFor` | **Blocking for Task 1** |
| `2026-08-02-quiz-tab-04-viewer-and-reveal.md` | `AnswerReveal` in `core/ui`, `PennantMark` | **Blocking for Task 2.** The review renders the mock's answers through the same reveal |
| `2026-08-02-quiz-tab-06-review-component.md` | The practice review's shell | **Check first.** Quiz 6 rebuilds `quiz_results_page.dart` behind `/review`. If it has landed, Task 4 is a configuration, not a build |
| `2026-08-02-quiz-tab-05-debrief.md` | The debrief, which Task 4 adds a row to | **Blocking for Task 4** |
| A per-choice rationale in the content | Note B | **Not blocking.** Note B is simply absent without it, which is the drawn appearance for Free anyway |

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.**
- **Never invent a figure.** Section size and item counts are published facts, accuracy
  and time are measured. **Nothing is projected.** A blueprint that published no
  `scoreBands` gets no band word: an unpublished threshold is not a reason to invent one.
- **Ink & Rule identity.** Spec 5's results screen predates it, and confetti for a pass, a
  gentle wave for close, a warm-light pulse for a fail, cards, pills and the chart emoji
  are all banned. **The one delight kept is the count-up on the score**, because a number
  counting is typographic rather than decorative.
- **No gauge with the thresholds marked.** It was drawn and rejected: it puts the pass
  line in front of someone who has just missed it.
- **Voice.** Grade-5-simple English, **no em dashes**. It is an **exam** and you **take**
  it: never "paper", never "sit". Scores are **points**, never "marks". "Borderline",
  "diagnostic" and "remediation" are banned. The middle band is **"Close to passing"**.
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
| `lib/features/mock_exam/presentation/pages/mock_results_page.dart` (modify) | The score, the header, Performance, Practice these next, the review row, the footer |
| `lib/features/mock_exam/presentation/widgets/score_headline.dart` (create) | The centred figure, the count-up, the band or its absence |
| `lib/core/ui/components/question_review_list.dart` (create) | The review, in both configurations |
| `lib/features/mock_exam/presentation/widgets/exam_marks_offer.dart` (create) | The one-time offer |
| `lib/features/quiz/presentation/pages/quiz_results_page.dart` (modify) | The practice configuration of the same component |

**The review lives in `core/ui`** because two features render it and neither owns it. A
copy in each would drift, and the drift would be invisible until a student noticed the
mock's review behaving differently from practice's.

---

### Task 1: The results screen

**Files:**
- Create: `lib/features/mock_exam/presentation/widgets/score_headline.dart`
- Modify: `lib/features/mock_exam/presentation/pages/mock_results_page.dart`
- Test: `test/features/mock_exam/presentation/widgets/score_headline_test.dart`
- Test: `test/features/mock_exam/presentation/pages/mock_results_page_test.dart`

**Interfaces:**
- Consumes: `MockResults` from `lib/features/mock_exam/domain/mock_results.dart`;
  `ScoreBand` and the nullable `bandFor` from Plan 1; `InlineMeter`; `SectionHeader`.
- Produces: `class ScoreHeadline extends StatefulWidget` taking
  `({required int scoreRaw, required int scoreTotal, required ScoreBand? band, required bool wasForfeited})`.

**The score, centred, and the figure alone:**

```
              68%
        Close to passing
           82 of 120
```

- Percentage in serif **54/700**, tabular, tracking **-1.4**, with a **19px** sans `%` in
  `inkMuted`.
- The band in serif **15/700**, 7px beneath.
- The raw score in **12** `inkMuted`.

**The band words** are `Passing`, `Close to passing`, `Not passing`. "Close to passing"
was settled on 28 July over "Not far off" and "Just below", on reading level: idiom is the
first thing to fail a reader working in their second language. It costs one real thing,
which is that it says "passing" to someone who has just not passed, and that cost was
accepted because it is the reading a student would arrive at anyway.

**Three cases where no band word is printed:**

1. `band == null`, because the exam published no thresholds. The score still shows.
2. `wasForfeited`, per the Forfeited rule below.
3. Never any other case. Do not invent a fourth.

**Forfeited:** the badge sits beside the blueprint name and **the band word is withheld**.
The score still shows, because the work was still done, but no pass verdict is delivered
on a partial exam. A line beneath explains what happened, empathetically.

**The count-up** runs on the percentage only, and it is **disabled under reduce-motion**
like every other animation in the app. Land on the final value immediately in that case.

**The header:** the blueprint name in serif **21/700**, and **the date alone** beneath it
in 12 `inkMuted`. **No duration**: whether the full time was used is in the Performance
table, where it is actionable.

**Performance:** a `SectionHeader` reading "Performance", then one row per part carrying
the part name, a **54px** `InlineMeter`, the accuracy, and time against suggested.
Over-time in `rust`. The meter colours by severity on Home's rule: rust below 50, amber
below 70, ink above. **Use the same helper Home's Practice panel uses**, or the two
surfaces will drift on a boundary.

**Practice these next:** the top three weak parts, each a row with its accuracy and **a
chevron**. **No verb on the row**: the heading already says what they do.

**Into the review:** **one ruled row**, opened by a 1px `rule`,
`Go through all 120 questions` in serif 15/700 with a chevron. **No heading above it**,
since a heading called Review over a single row called View all questions says the same
thing twice at the same weight.

**The footer note:** `Saved.` then the tier rule, with the reopen date for Free users.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('prints the figure, the band and the raw score', (tester) async {
    await tester.pumpWidget(
      harness(scoreRaw: 82, scoreTotal: 120, band: ScoreBand.close),
    );
    await tester.pumpAndSettle();

    expect(find.text('68'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
    expect(find.text('Close to passing'), findsOneWidget);
    expect(find.text('82 of 120'), findsOneWidget);
  });

  testWidgets('an exam with no published thresholds prints no band',
      (tester) async {
    await tester.pumpWidget(
      harness(scoreRaw: 82, scoreTotal: 120, band: null),
    );
    await tester.pumpAndSettle();

    expect(find.text('68'), findsOneWidget);
    expect(find.textContaining('passing'), findsNothing);
    expect(find.textContaining('Passing'), findsNothing);
  });

  testWidgets('a forfeited exam shows the score and withholds the verdict',
      (tester) async {
    await tester.pumpWidget(
      harness(
        scoreRaw: 30,
        scoreTotal: 120,
        band: ScoreBand.fail,
        wasForfeited: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('30 of 120'), findsOneWidget);
    expect(find.textContaining('passing'), findsNothing);
  });

  testWidgets('reduce-motion lands on the figure immediately', (tester) async {
    await tester.pumpWidget(
      harness(scoreRaw: 82, scoreTotal: 120, band: ScoreBand.close,
          disableAnimations: true),
    );
    await tester.pump();
    expect(find.text('68'), findsOneWidget);
  });

  testWidgets('no gauge, no confetti, no emoji', (tester) async {
    await tester.pumpWidget(harness(scoreRaw: 110, scoreTotal: 120,
        band: ScoreBand.pass));
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(t.data ?? '', isNot(matches(RegExp(r'[\u{1F300}-\u{1FAFF}]',
          unicode: true))));
    }
  });

  testWidgets('the header carries the name and the date, never a duration',
      (tester) async {
    await tester.pumpWidget(resultsHarness());
    await tester.pumpAndSettle();

    expect(find.text('UPCAT full length'), findsOneWidget);
    expect(find.text('2 August 2026'), findsOneWidget);
    expect(find.textContaining('3 hours'), findsNothing);
  });

  testWidgets('the review row stands alone with no heading above it',
      (tester) async {
    await tester.pumpWidget(resultsHarness(total: 120));
    await tester.pumpAndSettle();

    expect(find.text('Go through all 120 questions'), findsOneWidget);
    expect(find.text('Review'), findsNothing);
  });

  testWidgets('Practice these next rows carry a chevron and no verb',
      (tester) async {
    await tester.pumpWidget(resultsHarness());
    await tester.pumpAndSettle();

    expect(find.text('Practice these next'), findsOneWidget);
    expect(find.textContaining('Practice these next'), findsOneWidget);
    expect(find.text('Practice'), findsNothing);
    expect(find.text('Start'), findsNothing);
  });

  testWidgets('the copy never says paper, sit, marks or borderline',
      (tester) async {
    await tester.pumpWidget(resultsHarness());
    await tester.pumpAndSettle();
    for (final word in ['paper', 'Borderline', 'borderline', 'marks', '—']) {
      expect(find.textContaining(word), findsNothing);
    }
  });
```

- [ ] **Step 2 to 5: fail, implement, pass, commit**

```bash
git commit -m "feat(mock): rebuild the results screen on the identity

The figure alone, centred, with the count-up as the one kept delight: a
number counting is typographic, and Spec 5's confetti, wave, pulse,
cards, pills and emoji are all banned by the redesign.

A ruled gauge with the thresholds marked was drawn and rejected. It
answered the question in one glance and put the pass line in front of
someone who had just missed it.

An exam that published no thresholds gets no band word, and a forfeited
exam keeps its score and loses its verdict."
```

---

### Task 2: The review component

**Files:**
- Create: `lib/core/ui/components/question_review_list.dart`
- Test: `test/core/ui/components/question_review_list_test.dart`

**Interfaces:**
- Consumes: `AnswerReveal` and `PennantMark` from Quiz Plan 4.
- Produces:

```dart
enum ReviewGrouping { bySubject, flat }

@immutable
class ReviewEntry {
  const ReviewEntry({
    required this.questionId,
    required this.number,
    required this.shortLabel,
    required this.subjectName,
    required this.isCorrect,
    required this.isFlagged,
  });
  // ...
}

class QuestionReviewList extends StatefulWidget {
  const QuestionReviewList({
    required this.entries,
    required this.grouping,
    required this.onToggleFlag,
    this.header,
    super.key,
  });

  final List<ReviewEntry> entries;
  final ReviewGrouping grouping;
  final ValueChanged<QuestionId> onToggleFlag;

  /// The mock passes the one-time offer here. Practice passes null.
  final Widget? header;
}
```

**Filters:** a single ruled row, `All 120 · Wrong 38 · Flagged N`, plain labels separated
by 1px by 12px `rule` ticks, active in `ink` w700. **No pills.**

**Wrong is the default.** It is what almost everyone opens this for, and All is one tap
away.

**There is no fourth filter**, ever. A permanent control for a fact that stops mattering
after one visit is a permanent cost for a temporary thing.

**The list**, at `ReviewGrouping.bySubject`: grouped by **subject**, serif 14/700 heading
with a count per group, closed by a 1px `rule`. Not by topic and not by lesson: the
subject is the level a student thinks in when scanning an exam. At `flat`, no headings at
all, because a ten-question session rarely spans enough subjects to earn them.

**Each row:** the question number in serif 14/700 `inkMuted` tabular, the short label,
then the outcome mark and the flag. Without a short label in the content, fall back to the
stem clamped to two lines through the renderer.

**Tapping expands in place**, so a student can work down a list of misses without losing
position. Expanded: the four choices with the correct one marked board ✓ and the chosen
one rust ✕, the others at 50%, then the marginal notes, then the flag control.

**Both tiers see every question, the correct answer and note A.** Pro adds **note B**, the
note addressed to the choice that student actually made. **This formally reverses Spec 5's
D11**, which is struck through in Spec 5 itself rather than left to read as current. The
third argument is the one that decided it and it was checked rather than assumed:
`AttemptsRepository.recentIncorrects` queries `attempts_local` only, mock attempts live in
`mock_attempts_table`, and D4 keeps mocks out of FSRS on purpose. **So mock misses never
reach "Your mistakes" and never come back through the scheduler.** Gate the review and a
Free user's 38 wrong answers have nowhere left to go at all.

**The pennant here means "practice this", and only that.** It is the same durable flag the
Quiz tab's Flagged section reads.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('opens on Wrong', (tester) async {
    await tester.pumpWidget(harness(entries: mixed120));
    expect(activeFilterLabel(tester), startsWith('Wrong'));
    expect(find.byType(ReviewRow), findsNWidgets(38));
  });

  testWidgets('three filters and never a fourth', (tester) async {
    await tester.pumpWidget(harness(entries: mixed120));
    expect(find.textContaining('All 120'), findsOneWidget);
    expect(find.textContaining('Wrong 38'), findsOneWidget);
    expect(find.textContaining('Flagged'), findsOneWidget);
    expect(find.byType(FilterLabel), findsNWidgets(3));
  });

  testWidgets('bySubject groups with counts, flat has no headings',
      (tester) async {
    await tester.pumpWidget(
      harness(entries: mixed120, grouping: ReviewGrouping.bySubject),
    );
    expect(find.text('Science'), findsOneWidget);

    await tester.pumpWidget(
      harness(entries: mixed120, grouping: ReviewGrouping.flat),
    );
    expect(find.text('Science'), findsNothing);
  });

  testWidgets('tapping expands in place and keeps the rows below',
      (tester) async {
    await tester.pumpWidget(harness(entries: mixed120));
    final belowBefore = find.text('Q41');
    await tester.tap(find.text('Q12'));
    await tester.pumpAndSettle();

    expect(find.byType(AnswerReveal), findsOneWidget);
    expect(belowBefore, findsOneWidget);
  });

  testWidgets('Free sees the answer and note A, and not note B',
      (tester) async {
    await tester.pumpWidget(harness(entries: mixed120, isPro: false));
    await tester.tap(find.text('Q12'));
    await tester.pumpAndSettle();

    expect(find.text('The correct answer is B.'), findsOneWidget);
    expect(find.byKey(const ValueKey('note-a')), findsOneWidget);
    expect(find.byKey(const ValueKey('note-b')), findsNothing);
  });

  testWidgets('Pro adds note B and changes nothing else', (tester) async {
    await tester.pumpWidget(harness(entries: mixed120, isPro: true));
    await tester.tap(find.text('Q12'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('note-a')), findsOneWidget);
    expect(find.byKey(const ValueKey('note-b')), findsOneWidget);
  });

  testWidgets('every pennant is tappable', (tester) async {
    final toggled = <String>[];
    await tester.pumpWidget(
      harness(entries: mixed120, onToggleFlag: toggled.add),
    );
    await tester.tap(find.byType(PennantMark).first);
    expect(toggled, hasLength(1));
  });

  testWidgets('the header slot renders where given and nothing where not',
      (tester) async {
    await tester.pumpWidget(
      harness(entries: mixed120, header: const Text('offer')),
    );
    expect(find.text('offer'), findsOneWidget);

    await tester.pumpWidget(harness(entries: mixed120, header: null));
    expect(find.text('offer'), findsNothing);
  });
```

- [ ] **Step 2 to 5: fail, implement, pass, commit**

```bash
git commit -m "feat(ui): add the question review list, shared by both endings

Free gets every question, the correct answer and note A; Pro adds note B.
This reverses Spec 5's D11, and the argument that decided it was checked
rather than assumed: recentIncorrects queries attempts_local, mock
attempts live in mock_attempts, and D4 keeps mocks out of FSRS, so a
gated review leaves a Free user's wrong answers with nowhere to go at
all.

The component lives in core/ui because two features render it and
neither owns it."
```

---

### Task 3: The one-time offer

**Files:**
- Create: `lib/features/mock_exam/presentation/widgets/exam_marks_offer.dart`
- Test: `test/features/mock_exam/presentation/widgets/exam_marks_offer_test.dart`

**Interfaces:**
- Consumes: `MockSessionState.flags`.
- Produces: `class ExamMarksOffer extends StatelessWidget` taking
  `({required int count, required VoidCallback onKeepAll, required VoidCallback onDismiss})`.

**The marks made during the exam expire with the exam**, because "check before I submit"
cannot outlive the submission. They are spent once, at the top of the review:

> You marked **12** to come back to while the clock was running. Keep them to practice?
> [ Flag all 12 ]  [ No thanks ]

**Taken or refused, the offer is gone** and nothing about the exam marks remains on
screen. Persist the dismissal against the attempt so reopening the review does not offer
again.

**All or nothing, deliberately.** If the twelve are genuinely wanted, picking through them
one by one is invented work, and per-question adjustment already exists afterwards: taking
the offer fills the Flagged filter with exactly those twelve and every pennant is
tappable.

**Two things were rejected and must not be reintroduced:** carrying the marks over
silently, which fills the Flagged list with questions marked out of time pressure rather
than out of wanting to learn them and makes the first job in the review unflagging; and
two pennant states, outline for the exam mark and filled for practice, which is the
confusion this whole change exists to remove.

**With no marks made, the offer does not render at all.**

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('offers the exact count', (tester) async {
    await tester.pumpWidget(harness(count: 12));
    expect(
      find.textContaining(
        'You marked 12 to come back to while the clock was running.',
      ),
      findsOneWidget,
    );
    expect(find.text('Flag all 12'), findsOneWidget);
    expect(find.text('No thanks'), findsOneWidget);
  });

  testWidgets('one mark reads "1", singular throughout', (tester) async {
    await tester.pumpWidget(harness(count: 1));
    expect(find.text('Flag all 1'), findsOneWidget);
  });

  testWidgets('no marks renders nothing', (tester) async {
    await tester.pumpWidget(harness(count: 0));
    expect(find.byType(ExamMarksOffer), findsNothing);
  });

  testWidgets('taking it fills the Flagged filter with exactly those',
      (tester) async { /* integration, through the review */ });

  testWidgets('reopening the review does not offer again', (tester) async {
    /* dismiss, rebuild, expect nothing */
  });

  testWidgets('there is no fourth filter for exam marks', (tester) async {
    await tester.pumpWidget(reviewHarness(withOffer: true));
    expect(find.textContaining('Marked'), findsNothing);
  });
```

- [ ] **Step 2 to 5: fail, implement, pass, commit**

```bash
git commit -m "feat(mock): spend the exam's marks once, as an offer

Check before I submit cannot outlive the submission, so the marks are
offered once and then gone. All or nothing: whatever survived to
submission was already filtered by the person who made it, under a clock,
so picking through them one by one is invented work."
```

---

### Task 4: The practice ending gets the same screen

**Files:**
- Modify: `lib/features/quiz/presentation/pages/quiz_results_page.dart`
- Modify: the debrief page from Quiz Plan 5
- Test: `test/features/quiz/presentation/pages/quiz_results_page_test.dart`

**Interfaces:**
- Consumes: `QuestionReviewList` at `ReviewGrouping.flat`, `header: null`.
- Produces: an entrance for a page that has had none since the debrief replaced the
  session ending.

**`quiz_results_page.dart` survives, rebuilt.** Its only entry was a "Review results"
button the debrief deleted, so it is unreachable code today. It also **lists questions by
raw `questionId`**, which no student should ever see. Rebuild it behind `/review` as the
practice configuration of Task 2's component. **Check Quiz Plan 6 first**: it owns this
rebuild, and if it has landed, this task is a configuration change rather than a build.

**The debrief gains one ruled row**, `Go through all 10`, below the return promise and
above the footer.

**This reverses a decision made on 27 July, deliberately.** A "Review the misses" button
was drawn on the debrief and deleted, on the grounds that the student had seen every miss
seconds earlier. That argument holds for the **misses** and does not hold for the
**explanations**: at answer time the note is read once under the momentum of a session,
and there was no way to return to it short of meeting the question again by chance.

**What does not change:** the miss rows on the debrief itself stay a record with no
chevrons, and nothing happens on tap. The row is the only way through.

**The offer is absent here.** Practice flags are durable from the moment they are set, so
there is nothing to spend.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the debrief carries one row into the review', (tester) async {
    await tester.pumpWidget(debriefHarness(sessionLength: 10));
    expect(find.text('Go through all 10'), findsOneWidget);
  });

  testWidgets('the miss rows stay a record and do nothing on tap',
      (tester) async {
    await tester.pumpWidget(debriefHarness(sessionLength: 10));
    await tester.tap(find.byType(MissRow).first);
    await tester.pumpAndSettle();
    expect(find.byType(QuestionReviewList), findsNothing);
  });

  testWidgets('the practice review is flat and offers nothing',
      (tester) async {
    await tester.pumpWidget(practiceReviewHarness());
    await tester.pumpAndSettle();

    expect(
      tester.widget<QuestionReviewList>(find.byType(QuestionReviewList))
          .grouping,
      ReviewGrouping.flat,
    );
    expect(find.byType(ExamMarksOffer), findsNothing);
  });

  testWidgets('no raw question id is ever printed', (tester) async {
    await tester.pumpWidget(practiceReviewHarness());
    await tester.pumpAndSettle();
    expect(find.textContaining('q-'), findsNothing);
  });

  testWidgets('the practice review also opens on Wrong', (tester) async {
    await tester.pumpWidget(practiceReviewHarness());
    await tester.pumpAndSettle();
    expect(activeFilterLabel(tester), startsWith('Wrong'));
  });
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
git commit -m "feat(quiz): give the practice ending the same review

quiz_results_page.dart has had no entrance since the debrief replaced the
session ending, and it listed questions by raw questionId. It is rebuilt
as the practice configuration of the shared review component.

This reverses a 27 July decision. The argument for deleting the button
held for the misses and not for the explanations: a note read once under
the momentum of a session could not be returned to except by meeting the
question again by chance."
```

---

## What this plan deliberately leaves undone

- **The pause and strict-forfeit flows, the section-transition moment, the warning
  overlays, and mock history.** The spec lists all five as not designed and says Spec 5's
  sketches stand until redrawn. Do not design them inside this plan.
- **Note B's content.** It needs a per-choice rationale in the content, which is a content
  pass. Without it note B is simply absent, which is the drawn appearance for Free anyway.
- **Short labels.** Without them the rows fall back to the stem clamped to two lines
  through the renderer, which is the designed degradation.

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- An exam whose blueprint published no `scoreBands` shows a score and no band word.
- A forfeited exam shows a score and no band word.
- Both reviews open on **Wrong**, and neither has a fourth filter.
- A Free user and a Pro user see the same review except for note B.
- Taking the offer once means it never appears again for that attempt.
- `grep -rn "borderline\|Borderline" lib test` returns nothing.
- Report as text signals and ask Aedwon to look. Never screenshot the emulator.
