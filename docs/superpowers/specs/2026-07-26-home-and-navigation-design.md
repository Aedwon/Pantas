# Home and Navigation Redesign

**Date:** 2026-07-26
**Amended:** 2 August 2026, Section 3's "Weakest areas" reopened as design and
replaced by "Practice". See Section 8 and
`decisions/2026-08-02-home-weakest-areas-log.md`.
**Status:** Approved by Aedwon, validated interactively against live mockups in
`.superpowers/brainstorm/72587-1784988095/content/`
**Closes:** UI-009, UI-010, UI-011 (partially), and the masthead half of UI-012's context

## Problem

Three findings from the 2026-07-25 manual pass, recorded in `docs/ui-audit.md`:

- **UI-009**: the bottom navigation is text only and slow to hit by thumb.
- **UI-010**: the masthead greets the user with the exam short name, not a name.
- **UI-011**: Home shows one content block where the approved mock had four.

Working through them surfaced two further problems: the app never captures an
exam date, and Home's blocks read as a waterfall with no grouping.

## Scope

Bottom navigation, the onboarding fields Home depends on, and the Home tab's
full composition. Out of scope: the Study, Quiz and Progress tabs; the study
plan feature; the projection model discussed under "Deferred" below.

---

## Section 1: Bottom navigation

The approved mock used text-only labels. Aedwon's objection was recognition
speed, not decoration, so a decorative active marker was rejected as answering
the wrong question. Icons are added.

| Property | Value |
|---|---|
| Size | 23px |
| Stroke | 1.50 |
| Inactive | Outline glyph, `inkMuted` |
| Active | Filled glyph, `ink`, label at w700 |
| Transition | Ink rise (fill sweeps bottom to top) |
| Duration | 400ms, `cubic-bezier(.22, 1, .36, 1)` |

Glyphs: **Home** a house, **Study** an open book, **Quiz** a single answer
bubble, **Progress** a folded sheet with a rising line.

> **Amended 28 July, and the amendment sat unbuilt until 10 August.** The quiz
> glyph is **three options with their rules**, not a single bubble. A circle has
> no internal structure, so at 23px beside a house and a book it reads as a dot.
> **Only the middle option shades**; the ink rise is unchanged and still means a
> pencil shading an answer. Round: `quiz-glyph-v2.html`. Selection: S1, "Three
> options and rules".
>
> **Every glyph carries its internal detail**, which is what makes it an object
> rather than a silhouette: the house has **a doorway**, the book has **a
> spine**, the sheet has **a folded corner**. The first implementation drew the
> outer shapes only.

Three rules the implementation must hold:

1. The rise plays **only on the tab being activated**. The outgoing tab drains
   instantly. Two glyphs animating at once reads as busy.
2. The animation is **disabled under reduce-motion**, falling back to a plain
   swap. This is an accessibility requirement, not a preference.
3. **No board green anywhere in the bar.** The color budget reserves board for
   primary actions, progress indicators and done-checks. Marking navigation with
   it would cost the primary button meaning.

The bubble glyph was chosen over a question mark or a checklist because the fill
animation *is* the metaphor: ink rising into a bubble is a pencil shading an
answer, and UPCAT and CSE are both shaded answer sheets. The checkmark was
rejected because it already means "done" on lesson and topic rows.

400ms is longer than the platform norm. Aedwon selected it against a live
duration slider rather than from a description. Re-check it on the emulator once
the page transition is also in play, since perceived latency compounds. It is a
single constant.

## Section 2: Onboarding captures name and exam date

Home cannot render its masthead or its countdown without two fields the app
never asks for.

**Name.** A new step **after the exam picker**, so the ask lands once the user
has invested. No prefill from `AuthUser.displayName`: the name is chosen, not
assumed, and signed-out users are the majority during onboarding. The step is
skippable. Storage is a new string key in `SettingsPrefKeys` with a matching
field on `UserSettings`. A Settings row allows editing later.

**Exam date.** Captured on the **same step as the name**, not a separate one:
two short fields after the exam picker, rather than growing onboarding to five
screens. Both fields are optional. `UserSettings.examDate`
and `DriftSettingsRepository.updateExamDate` already exist and validate that the
date is at least tomorrow, but **nothing in the app writes to them**:
onboarding never touches `examDate`, and the Settings row is unwired
(onboarding-polish Task 6, unexecuted). Until this ships, `examDate` is null for
every user and the countdown cannot render for anyone.

**No-name state.** Users with no name stored, which is every existing install
plus anyone who skips, see an "Add your name" invitation in the masthead slot
that taps through to set it. This is self-healing and needs no migration prompt.
The countdown line degrades the same way: with no exam date it shows the exam
short name alone.

## Section 3: Home composition

### Masthead

Kicker over serif name over a muted meta line:

```
Magandang gabi,
Aedwon
42 days to UPCAT
```

The gear stays as the only right-side element. The meta line carries both the
active exam and the countdown, which frees a stats band slot and keeps the
countdown visible without a permanent streak dateline.

**Amended 2 August.** This sample read `UPCAT · 42 days to go`. The
2 August onboarding spec's Section 4 governs the countdown copy, because it is
where exam-date precision was designed, and it prints three lines rather than
one. Its table is the current statement:

| Precision | The meta line |
|---|---|
| `day` | `42 days to UPCAT` |
| `month` | `Your exam is in October 2026` |
| none | the exam short name alone |

The month state is **not a degraded countdown**. It is the true statement
available, and a day count derived from a month would be a figure made of a
measurement and an assumption, which the Progress spec's Section 1 bans
outright.

The kicker is time-based, as `_greeting()` already implements
(umaga / hapon / gabi).

### Blocks and their separation

Home carries four blocks, each enclosed in a **ruled panel**: a 1px `rule`
border, square corners, on the same paper as the page.

A ruled panel is not a card. What makes a card read as generic is elevation
(shadow), a large radius, a white surface floating above tint, and a colored
header strip. The identity bans those by name. It never banned drawing a box,
and a hairline rectangle around a group of rows is the oldest grouping device in
print. This gives hard separation with nothing borrowed.

Each panel opens with a **plated heading**: serif title underscored by a 1.6px
`ink` rule. Roman numeral prefixes were tried and rejected as meaningless.

Block order:

1. **Stats band** plus the "Lately" line
2. **Up next**
3. **Practice**, formerly "Weakest areas"
4. **Your tendencies** (Section 4)

### Stats band

Two figures, **centered**: accuracy, and lessons read against total. Days to exam
lives in the masthead meta line instead, so it is not repeated here.

Centring amends both the approved mock (`text-align: left`) and the shipped
widget (`StatsBand` uses `CrossAxisAlignment.start`). This is a deliberate
choice for balance against the centered tendency card beneath it, not a drift.

The "Lately" metric atom sits beneath the band, **centered**, separated by a
faint rule.

### Up next

Three unread lessons drawn from the user's weakest topics, each row showing
title and estimated minutes, with "Continue lesson" as the block's action.

This is the **single primary action on Home**. Board green appears nowhere else
except section-header actions, which the reference sweep already sanctions.

### Practice

**Amended 2 August 2026.** This section was "Weakest areas" with "Practice these"
pointing into Study. It was superseded twice over and reopened as design; the
decisions are in `decisions/2026-08-02-home-weakest-areas-log.md` and the causes
are in Section 8 below.

Three topic rows, weakest first, each carrying an `InlineMeter` and a percentage
colored by severity (rust below 50, amber below 70, ink above). Semantic color
on semantic values, within budget. A chevron per row, under the Study spec's rule
that a chevron marks a row that is its own destination.

The plate reads **Practice**. The 26 July rename holds because its reasoning
holds: the two panels stop being duplicates the moment they stop sharing a
destination, and Up next opens the reader while these rows start a session.

**A row starts a topic-scoped session.** `StartTodaySession` already takes an
optional `topicId`, so the row fires it directly rather than routing through the
practice picker. One tap from Home to answering.

**The lead line may not state a length.** The 26 July line "Ten questions on
whichever you tap." is cut: session length is the student's own setting,
`quiz_session_length`, exposed on the Quiz tab under "Change how sessions are
built". Home does not promise a number it does not control.

**The action is "See all", pointing at Progress → Performance**, which is the
same ranking as a full sortable table at three levels. This matches "See full
details" for the tendency deck: Home surfaces the top of a thing and Progress
owns the whole of it. "Practice these" is retired, because once the rows carry
the verb the link only repeated it.

#### The figures are live, not the assessment's

`AssessmentResult.topicMasteries` is written once by `CompleteAssessment` and
never recomputed, so it freezes on assessment day and each percentage rests on at
most three questions. **This panel reads attempts instead**, using the same
topic-level query Progress's Performance table needs, so the two surfaces can
never disagree and the panel moves as the student works.

**The floor governs the figure, not the ranking.** A topic with fewer than
**three** answered questions is still ranked and still tappable, but its row
prints **no percentage and no meter**: the meta slot is empty and the figure
appears the moment the third question is answered.

This is the only rule that survives both ends of the assessment. Once all 18
topics carry questions, `AssessmentQuestionSelector` gives each contributing topic
`max(1, min(3, 35 ~/ 18))`, which is **one question**. A floor that excluded
topics from the ranking would therefore empty this panel completely on the day the
question bank is finished, which is the opposite of the intended behavior. A
one-question sample is a fine reason to put Chemistry at the top of a list to work
on. It is not a reason to print "0%" in rust.

**The floor is one constant**; say so if you want it moved.

#### Two prerequisites this creates

1. **The assessment must write an `attempts_local` row**, under a new
   `SessionOrigin.assessment`. It currently writes only `assessment_results_local`
   and FSRS state, so every signal and the whole of Progress's Performance table
   are blind to its twenty-one questions. Without this the panel is empty
   immediately after the assessment, which is the moment it is most needed.
2. **The speed-based signals must exclude that origin.**
   `MetricAttemptItem.responseMs` is required and the assessment captures no
   per-question timing, so zeros would tell `PerQuestionSpeedSignal` that
   twenty-one questions were answered instantly, and Progress's "answered too
   fast" count reads that distribution. Lift the exclusion when the assessment
   captures timing. This panel needs correctness only and is unaffected either
   way.

#### Free and Pro

**These three rows are free**, and they are the teaser for Progress's table.
Progress Section 7 fixes Free at Subject level and sells Topic and Lesson; this is
a deliberate, stated opening in that gate, on the same principle as the tendency
deck. Knowing your three worst topics is the diagnosis; sorting, filtering and
reading the whole table at three levels is what Pro buys. See Section 8,
amendment 5.

#### Carried forward, not fixed here

Under the default interleaved ordering `start_today_session.dart:89` writes the
session's `topicId` as null, and a passed `topicId` narrows the pool to one topic
so the interleaved picker interleaves it with itself. A row from this panel
therefore starts a session that is topic-scoped in fact and unlabelled in storage.
It belongs to the Quiz thread, beside the interleaved-tail item plan 2b raised.

## Section 4: "Your tendencies"

A Pro-gated panel presenting four behavioral insights, one at a time.

The name matters. The redesign spec reserves the word "readiness" until a real
projection model backs it, so the panel avoids it. "Your tendencies" is accurate:
these are patterns that repeat, not scores.

### The four insights

| Insight | Signal | Source | Prerequisite |
|---|---|---|---|
| Under pressure | X1 | `test_mode_delta_signal.dart` → `PressureDelta` | One full mock plus practice on matching topics |
| Stamina | P4 | `mock_stamina_signal.dart` → `StaminaDelta` | One completed full-length mock |
| How you study | D1 | `read_then_quiz_signal.dart` → `WorkflowRatio` | One lesson read, then a quiz on that topic |
| How you answer | P1 | `per_question_speed_signal.dart` → `LatencyDistribution` | Any quiz with response timing |

All four signals are already written. None of them duplicates anything else on
Home, which was the deciding criterion: a paywall over information already on
screen converts nobody. Variants that restated the band or the weakest-areas
rows were discarded for exactly this reason.

**"How you study" was renamed on 2 August**, from "What works for you", and the
rename is an evidentiary correction rather than a copy preference.
`WorkflowRatio` holds `readThenQuizCount` and `quizFirstCount` and **no accuracy
at all**: the signal counts lessons by whether they were read before or after
the first attempt on that topic. So the app knows which order the student does
more often and nothing about which order works.

**Extending the signal to carry accuracy per branch was rejected**, and not only
on cost. The student chooses which lessons to read first, and they read them on
topics they already find hard, so any accuracy gap between the branches is
selection rather than effect. Printing "reading first works better for you"
would be a measurement combined with an assumption, which the Progress spec's
Section 1 bans outright. It is the same fault that withdrew points recoverable
and the same circularity that keeps `DifficultyCalibrationSignal` unused.

**The card states the pattern and claims nothing about its payoff.** Its
sentence has three states, chosen by the ratio:

- `You usually read the lesson first.`
- `You usually go straight to the questions.`
- `You split about evenly between the two.`

The figures are the two counts, labelled `read first` and `answered first`.

### Presentation

A flat card inside the ruled panel, with **no inner card**. The panel is already
the enclosure; nesting one would be a card in a card.

- **Fixed height, 112px.** All four insights share one shape (a label, two
  compared figures, one sentence), so the height falls out of the content rather
  than being imposed by padding or truncation. Locked cards use the same box, so
  nothing jumps mid-swipe.
- **Swipe only.** No auto-advance: nothing moves while it is being read, and
  reduce-motion is satisfied without a special case.
- **Worst first.** Ordered by points at stake, descending. Cards blocked by a
  missing prerequisite sort last.
- **Content is centered**, matching the stats band above it.
- Dots show position; hollow dots mark cards not yet unlocked.

### Prerequisite state

An insight without enough data shows its name, "Not enough data yet", and the
specific action that unlocks it ("Finish one full-length mock"). This is muted
text, never board, so it does not compete with the single primary action.

This turns the two mock-dependent insights into a nudge toward sitting a mock,
which is the behavior the app wants anyway. A new user sees "How you answer"
immediately and three signposts.

### Free and Pro

Free users **swipe the full deck**. Each card shows the insight's name and both
comparison labels ("practising" against "under time") with rules where the
figures go. Knowing what is being compared is what creates the want. Four
moments of curiosity beat one blank panel.

This introduces Pro gating to Home for the first time. The teaser treatment is
Spec 11 Amendment D's: faint paper-toned bars, "Unlock with Pro" in board green
in the header slot, no lock icons, no blur, no banners.

### "See full details" goes to Progress

Not to a new page. Spec 11 makes Progress the analytical dashboard, and its
trend and weakness panels currently render "Charts land here in an upcoming
update". The tendency work fills those in; Home surfaces one insight and hands
off. Two analytics destinations would drift apart.

## Section 5: Data dependencies

Ships on data the app already stores:

- **Lessons read** counts `lesson_progress_local` rows against `lessons` for the
  active exam.
- **Up next** is unread lessons in the weakest topics, the same two tables asked
  a different question.
- **Accuracy** comes from `AssessmentResult.topicMasteries`, already wired.
- **All four tendencies** come from signals already written in
  `lib/features/metrics/signals/`.

Blocked until Section 2 ships:

- **Days to exam**, which needs `examDate` to be written by something.

Amended 2 August, and no longer shipping on stored data alone:

- **The Practice panel** was listed here as reading `topicMasteries`. It now reads
  attempts at topic level, which needs the two prerequisites in Section 3: the
  assessment writing an `attempts_local` row, and the speed signals excluding that
  origin.

**Deferred, not designed here:**

- **"Today's plan"** and its "2 of 3 done". The only block of the original mock
  that cannot be derived from stored data: a daily plan must decide how much a
  user should do today and track completion, which is mastery scoring, review
  scheduling and daily targets. That remains its own project, tracked as UI-003.
  It does not render at all until then. Nothing is faked in its place.
- **A projected score range.** The most-wanted answer to "am I ready" and the
  one that needs a model mapping practice performance onto exam outcomes.
  Keep it on the roadmap as the eventual headline; it is what would finally
  release the reserved word "readiness".

## Section 6: Amendments this design makes

Each of these contradicts something already approved. Recorded so the change is
deliberate rather than drift.

1. **Bottom nav gains icons.** The approved mock and reference-sweep plan both
   specify text-only labels.
2. **Stats band figures are centered.** The mock and `StatsBand` are left-aligned.
3. **The masthead gains a meta line.** The approved composition was kicker over
   name, with the gear as the only other element.
4. **Home blocks are enclosed.** The identity previously grouped by rules and
   whitespace alone.
5. **Signals P4, X1 and D1 appear on Home.** The metrics spec assigns them to
   "archetype/Wrapped only, no atom file". They appear here in a panel, not as a
   daily atom, so the atom rule is intact, but the surface allocation is new.
6. **Home carries Pro gating.** Previously all gating lived on Progress.

## Section 7: Copy rules

- **No em dashes in UI copy.** They read as machine-written. Use a colon, a
  comma, or a full stop. The metric atom line becomes `Lately: day 6 streak,
  your longest this month.`
- Sentence case throughout. Stat labels lowercase. No emoji, no all-caps.
- Never promise what the data cannot support. "Readiness" stays reserved.

## Section 8: The Practice amendment, 2 August 2026

### What superseded "Weakest areas"

Three things, two documented and one found in the code during this round.

1. **The Quiz anchor lost its anchor.** On 26 July, in
   `2026-07-26-study-tab-brainstorm-state.md`, this panel became "Practice" with
   rows firing the same call the Quiz tab's own topic rows make, and "See all"
   pointing at that per-topic queue. Two days later the Quiz tab spec deleted the
   queue: its Section 1 opens "It is not a topic queue" and Section 10.1
   supersedes Spec 4 §7.1 by name. The action pointed at nothing from 28 July on.
2. **Progress built the same ranking and gated it.** The 30 July Performance
   table is topics ranked by accuracy, default sort Score ascending, severity
   colored. Its Section 7 fixes Free at Subject level.
3. **The figures were frozen and tiny.** `topicMasteries` is written once by
   `CompleteAssessment` and never recomputed, and
   `AssessmentQuestionSelector` gives each contributing topic at most three
   questions. This is also why Up next and this panel named the same three topics
   every day: one frozen list, read twice.

### Amendments this makes to other specs

5. **`2026-07-30-progress-tab-design.md` Section 7** gains a stated exception:
   Home's three Practice rows show topic-level accuracy to Free users, as the
   teaser for the Performance table. The gate on that table is unchanged.
6. **The 26 July Quiz anchor decision** is superseded in two of its parts, the
   "See all" destination and the `mode: perTopic` call's justification, and
   upheld in three: the Practice name, the chevron rule, and Home never routing
   to a topic page.
7. **`2026-07-27-study-tab-and-reader-design.md` Section 8.1** recorded the 26
   July half of this correctly and predates the 28 July half. It is not wrong,
   only incomplete; this section is the current statement.

## Verification

Per the redesign spec's standing rule: run on the `pantas_pixel` emulator,
screenshot light and night, check against the color budget. Specifically:

- The nav bar at 1.50 stroke on a real screen, both modes, and the 400ms rise
  once page transitions are also running.
- The tendency deck at each of its four cards, plus the prerequisite state, plus
  the Free teaser, confirming the panel never changes height.
- The masthead with a name, without a name, with an exam date, and without one.
- Home with no assessment result at all, which must not render an empty shell.
- **The Practice panel immediately after the assessment**, which must render
  three rows. An empty panel here means the assessment is still writing no
  attempt row.
- **The Practice panel after practising**, which must have moved. A panel still
  naming the assessment's three topics means it is reading `topicMasteries`.
- A topic with one or two answered questions, which must still be **ranked and
  tappable** with an **empty meta slot**, never 0% or 100% behind a meter.
- A Practice row starting a session on its own topic in one tap, and the panel's
  "See all" landing on Progress with no dead end for a Free user.

## Related

- `docs/ui-audit.md`, findings UI-009 through UI-012
- `docs/superpowers/specs/2026-07-18-ui-redesign-design.md`, the identity this
  amends
- `docs/superpowers/specs/2026-06-10-user-facing-metrics-design.md`, the signal
  layer
- `docs/superpowers/specs/2026-06-10-spec-11-progress-amendment-design.md`,
  which owns the analytics surface
- `docs/superpowers/plans/2026-07-25-onboarding-polish.md`, which gains the name
  and exam-date steps
- Mockups: `.superpowers/brainstorm/72587-1784988095/content/`, notably
  `home-tendencies-v3.html` (final Home), `quiz-gallery.html` (glyph field),
  `home-separation.html` (grouping options)
