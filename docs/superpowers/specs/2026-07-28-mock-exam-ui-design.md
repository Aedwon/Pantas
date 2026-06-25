# Mock exam: the paper, the results and the review

**Date:** 2026-07-28
**Status:** Partial. Approved by Aedwon where marked, validated against live mockups in
`.superpowers/brainstorm/94219-1785220653/content/`
**Amends:** `2026-05-17-mock-exam-design.md` (Spec 5)
**Depends on:** `2026-07-28-quiz-tab-design.md` for the question grid, the flag and the
tab entry point

## Why this is a separate spec

The mock **inherits nothing** from the practice quiz's answering experience. No answer
reveal, no marginal notes, no debrief. It is time limited and runs under exam conditions
from the first item to the last, because its job is to simulate the exam and to produce
the practice-versus-pressure comparison `test_mode_delta_signal.dart` already measures.
Revealing answers mid-paper destroys both.

What it does share is stated in Section 1.

## What is settled, and what is not

**Settled here:** sectional timing and what it does to navigation, the question grid's
mock variant, the floating bar, the results screen, the review screen and what each tier
sees in it, what becomes of the marks made during the paper, and the practice session's
use of the same review component.

**Amended 4 August 2026.** Four of the five undesigned items are now settled in Sections 7 to
9 below, and one is struck. The paragraph that stood here read:

> "Not designed: the setup screen beyond the one requirement in Section 2, the pause and
> strict-forfeit flows, the section-transition moment, the warning overlays, and mock history.
> Spec 5 sketches all of these and they stand until redrawn."

| Item | Now |
|---|---|
| The setup screen | **Settled**, Section 7.1. It was a confirm rather than a redraw: Spec 5's shape was already this app's grammar and needed a copy pass, not a design. |
| The section transition | **Settled**, Section 7.2. The only properly blank surface of the five. |
| The strict-forfeit flow | **Settled**, Section 8, which also gives strict mode a second job. |
| The warning overlays | **Settled**, Section 9, and redrawn rather than confirmed: Spec 5's snackbar and colored banner are not devices this app uses. |
| **Mock history** | **Struck.** Progress's "Your record" already carries a "Your mocks" panel, and that screen is already wholly Free and already answers "am I moving". A second history page would be a copy of it. Spec 5's §7.2 `MockHistoryPage` row does not survive, and neither does its trend pill, which used an emoji and claimed a direction. |

**All five are now settled or struck.** The pause screen, the last of them, is Section 8.4.

---

## Section 1: What the mock shares with the quiz

Three components, from `2026-07-28-quiz-tab-design.md`:

| Component | Shared | Different in the mock |
|---|---|---|
| The question grid | Ruled rows, the reserved caret slot, the caret and its motion | Six columns, grouped by part with a count each, and **no outcome is ever shown** |
| The flag | The pennant, its paths, its `inkMuted` weight in a cell | It means "check before I submit" rather than "keep this". See Section 5 |
| The wash | `ink` at 34%, page settles 10px and loses a hair of scale, no blur | Nothing |

**The cell, in a mock:**

| State | Number | Mark |
|---|---|---|
| Untouched | `inkMuted`, serif 15/400 | none |
| Answered | `ink`, serif 15/600 | a 5px `amber` dot |
| Flagged | as above | the pennant at 12px, `inkMuted` |
| Answered **and** flagged | `ink` | **both marks**, dot then pennant, 4px apart |
| Current | as above | the caret in the reserved slot |

Both marks show together because answered is progress and flagged is doubt, and
"answered but unsure" is the most common state in a real exam.

---

## Section 2: Sectional papers

**The single most consequential finding of this design.** Whether a paper runs part by
part is not a property of the app, and the exams disagree.

| Exam | Sections separately timed | Evidence |
|---|---|---|
| UPCAT | **Yes** | "You cannot return to a subtest once time is called" |
| USTET | **Yes** | Each section separately timed. Mental Ability is 80 items in 30 minutes |
| NMAT | **Yes** | Its bulletin: the timer restarts for every section |
| CSE | **No** | 170 items, one booklet, one answer sheet, 3 hours 10 |
| ACET | **Yes** | Established by Aedwon, 4 August 2026. See below |
| DCAT | **Yes** | Established by Aedwon, 4 August 2026. See below |
| MSU-SASE | **No** | Established by Aedwon, 4 August 2026. One 3 hour block, 150 items |

### The three that were unknown, supplied 4 August 2026

**ACET, sectional.** The essay is not simulated, per the note at the end of this section.

| Part | Items | Minutes |
|---|---|---|
| Mathematics | 60 | 60 |
| English Proficiency | 75 | 50 |
| Aptitude and Abstract Reasoning | 135 | **27, derived** |

**DCAT, sectional.** The personality test is not simulated.

| Part | Items | Minutes |
|---|---|---|
| Mental Ability | 40 | 40 |
| Reading Comprehension | 25 | 30 |
| Writing Skills | 40 | 30 |
| General Mathematics | 45 | 50 |
| Statistics and Probability | 45 | 50 |
| Science | 50 | 30 |

**MSU-SASE, not sectional.** 150 items across English Proficiency, Mathematics, Science and
Mental Aptitude, in **one 3 hour block**. `sectionalTiming` is false and the paper is roamable
end to end, like CSE.

### Two things about these figures a later reader must not lose

1. **ACET's aptitude time is derived, not stated.** Aedwon gave the rate as roughly one minute
   per five items, and 135 items at that rate is 27 minutes. **That is arithmetic on his figure,
   not a published total**, and it implies about 12 seconds an item, which is fast even for
   abstract reasoning. **Confirm it before the ACET blueprint ships.**
2. **MSU-SASE was given with "apparently".** It is the least certain of the three. It is enough
   to build the blueprint, and it is not enough to print as a confident fact on a setup screen
   without a second look.

**The setup screen prints these numbers to a student before they commit hours.** A wrong
duration is not a cosmetic error, so the two caveats above are blocking for those two
blueprints and not for the third.

### It is a blueprint field

`MockBlueprint` gains **`sectionalTiming`** and a per-section limit. This is the third
content attribute of its kind, after subject `kind` and the per-exam wrong-answer
penalty, and they share one rule: **the exam's rules are content, not code.** No
per-exam branching anywhere in `lib/`.

### Nothing may be defaulted

For the three unknown exams, no value is assumed. **The setup screen states the rule in
plain words before the paper starts**, either "This paper runs part by part. Once a part
ends you cannot go back." or "You can move around the whole paper." It is the thing a
student most wants to know before committing three hours.

### What it does to the paper

When `sectionalTiming` is true:

- **Later parts render in the grid, dimmed to 32% and untappable**, with a line beneath
  reading "Opens when this part starts." Visible rather than hidden, because knowing
  what is coming and how much is left is exactly what a printed booklet gives you.
- **Previous and next stop at the part boundary.**
- **The clock counts the part**, not the paper.
- **A finished part cannot be reopened.**
- The caret can never cross a part boundary while answering, so its margin transition
  occurs only in the review or in a roamable paper.

### Two consequences beyond navigation

**Pacing guidance comes from the blueprint.** USTET's 22 seconds an item against CSE's
roughly 67 would make any app-wide assumption wrong by a factor of three.

**ACET and DCAT cannot be simulated whole.** Both include an essay and DCAT adds a
personality test, and the app has no concept of either. Their blueprints cover the
multiple-choice parts, and the setup screen must say what is **not** included rather
than presenting a partial paper as the whole thing.

---

## Section 3: The floating bar

The mock's paging control, which the practice quiz does not have.

Pinned 14px from the bottom and each side, 54px tall, 1px `rule` border, radius 8, on
`background`, with a soft shadow. Contents, left to right:

**‹ previous** &nbsp;|&nbsp; **grid glyph** &nbsp;·&nbsp; **counter** &nbsp;·&nbsp;
**flag** &nbsp;|&nbsp; **next ›**

- **Previous is leftmost and next is rightmost.** The three middle controls sit between
  them.
- **Base gap 16px, with +5px on the grid side.** An optical correction, not an
  inconsistency: the grid glyph is a solid 3x3 block dense to its edges, while the
  pennant is open on its lower right and carries its own whitespace, so equal metric
  gaps read unequal.
- The **grid glyph** is nine filled squares, 5.4px each with 1.6px gaps in a 24 viewBox,
  at 19px. Both it and the counter open the grid.
- Controls are 46px targets. Previous dims at the first item of a part, next at the last.

**Why the mock has one and the quiz does not.** In practice you move forward and the
reveal is the event. In a mock you move in both directions constantly, skipping and
returning, and no answer is ever revealed, so paging is the primary interaction rather
than clutter. It also frees the app bar for the clock, which must never be hunted for:
the clock sits **centered** there, serif 16/700, tabular.

**Amended 4 August 2026.** This line read "the clock sits **alone** there". **Pause now sits at
the trailing edge of the app bar**, which needed somewhere to live and had nowhere: the floating
bar already carries five controls and burying pause in the question grid punishes whoever needs
it most. **The intent of "alone" survives**, which was that the clock is centered and unmissable,
and a trailing control does not move it. **The pause control is absent entirely in strict mock
mode**, so the bar really is clock-only there. See Section 8.4.

---

## Section 4: The results screen

### The score

Centered, and **the figure alone**:

```
              68%
        Close to passing
           82 of 120
```

- Percentage in serif 54/700, tabular, tracking -1.4, with a 19px sans `%` in
  `inkMuted`.
- The band in serif 15/700, 7px beneath.
- The raw score in 12 `inkMuted`.

**A ruled gauge with the thresholds marked was drawn and rejected.** It answered "did I
pass and by how much" in one glance, and it put the pass line in front of someone who
had just missed it.

**Band thresholds are content.** Spec 5 puts `scoreBands` on the exam doctype in Sanity
with a fallback of 75 and 60. Nothing is hardcoded.

**"Borderline" is banned**, by Spec 5's own copy register along with "remediation" and
"diagnostic". The middle band is **"Close to passing"**, settled 28 July.

It beat "Not far off" and "Just below" on **reading level**, which is the rule that
decides copy in this app: "not far off" is idiom, and idiom is the first thing to fail a
reader working in their second language. "Close to passing" costs one thing and the cost
is real, which is that it says "passing" to someone who has just not passed. That is
accepted, because it is the reading a student would arrive at anyway and stating it
plainly is kinder than making them infer it.

### The header

The blueprint name in serif 21/700, and **the date alone** beneath it in 12
`inkMuted`. No duration: whether the full time was used is in the Performance table
where it is actionable.

### Performance

A `SectionHeader` reading **"Performance"**, then one row per part: the part name, a
54px inline meter, the accuracy, and time against suggested. Over-time in `rust`. The
meter colors by severity on Home's rule: `rust` below 50, `amber` below 70, `ink`
above.

### Practice these next

The top three weak parts, each a row with its accuracy and **a chevron**. No verb on the
row: the heading already says what they do.

### Into the review

**One ruled row**, opened by a 1px `rule`: "Go through all 120 questions" in serif
15/700 with a chevron. No heading above it, since a heading called Review over a single
row called View all questions says the same thing twice at the same weight.

### The footer note

"Saved." then the tier rule, with the reopen date for Free users.

### Forfeited

The badge sits beside the blueprint name and **the band word is withheld**. The score
still shows, because the work was still done, but no pass verdict is delivered on a
partial paper. A line beneath explains what happened, empathetically, per Spec 5's copy
register.

### What Spec 5 asked for that cannot survive

Spec 5's results screen predates the identity. Confetti for a pass, a gentle wave for
borderline, a warm-light pulse for a fail, cards, pills and a 📈 emoji are all banned by
`2026-07-18-ui-redesign-design.md`, which names gradient and glow decoration, emoji as
icon, and cards as generic grouping. **The one delight kept is the count-up**, because a
number counting is typographic rather than decorative.

---

## Section 5: The review screen

Pushed from the results row. Title "All questions".

### Filters

A single ruled row: **All 120 · Wrong 38 · Flagged N**, plain labels separated by 1px by
12px `rule` ticks, active in `ink` w700. No pills.

**Wrong is the default.** It is what almost everyone opens this for, and All is one tap
away.

### The list

Grouped by **subject**, with a serif 14/700 heading and a count per group, closed by a
1px `rule`. Not by topic and not by lesson: the subject is the level a student thinks in
when scanning a paper.

Each row: the question number in serif 14/700 `inkMuted` tabular, the short label, then
the outcome mark and the flag.

### Opening a question

**Tapping expands it in place**, so a student can work down a list of misses without
losing position. Expanded: the four choices with the correct one marked board ✓ and the
chosen one rust ✕, the others at 50%, then the marginal notes from the quiz spec's
Section 3, then the flag control.

### What Free sees, settled 28 July

**Free gets every question, the correct answer and the authored explanation**, which is
note A from the quiz spec's Section 3. **Pro adds note B**, the note addressed to the
choice that student actually made. The review is otherwise identical on both tiers.

This is **Free records, Pro interprets** applied without an exception, and it **formally
amends Spec 5 D11**, which reads "Free: score + section + top-3 weak topics + Drill CTA.
Pro: full per-question review with explanations." D11 predates the rule and is reversed
rather than quietly ignored.

**Three arguments decided it**, and the third is the one that could not be answered.

1. **Gating the mock alone is not a line, it is a delay.** The mock draws from the same
   bank as practice, where Free already sees note A. A Free user blocked on question 41
   in the review meets that same question in practice and reads the same explanation. The
   gate withholds nothing; it adds steps.
2. **The mock already carries the tab's only visible paywall**, one per 14 days. Gating
   its review charges twice on one surface.
3. **A gated review is a dead end, and this was checked rather than assumed.**
   `AttemptsRepository.recentIncorrects` queries `attemptsLocal` only. Mock attempts live
   in `mock_attempts_table`, and D4 keeps mocks out of FSRS on purpose. So mock misses
   **never** reach "Your mistakes" and **never** come back through the scheduler. Gate
   the review and a Free user's 38 wrong answers have nowhere left to go at all.

**What the gate would have bought is available above it.** Note B is the per-choice
rationale, it cannot be got from a reviewer book, and it is already Pro-only.

### The flag here

**The pennant means "practice this", and only that.** It is the same durable flag the
Quiz tab's Flagged section reads.

### What becomes of the marks made during the paper

**They expire with the paper**, because "check before I submit" cannot outlive the
submission.

They are spent once, as **a one-time offer at the top of the review**:

> You marked **12** to come back to while the clock was running. Keep them to practice?
> [ Flag all 12 ]  [ No thanks ]

Taken or refused, the offer is gone and nothing about the exam marks remains on screen.
There is **no fourth filter**, because a permanent control for a fact that stops
mattering after one visit is a permanent cost for a temporary thing.

**Why offer rather than discard:** a student who resolves a flagged question unflags it
during the paper, so whatever survives to submission has already been filtered by the
person who made it. Those twelve are deliberate decisions that survived scrutiny under a
clock.

**Why all or nothing:** if the twelve are genuinely wanted, picking through them one by
one is invented work. Per-question adjustment already exists afterwards, since taking
the offer fills the Flagged filter with exactly those twelve and every pennant is
tappable.

**Rejected:** carrying them over silently, which fills the Flagged list with questions
marked out of time pressure rather than out of wanting to learn them, and makes the
first job in the review unflagging. Also rejected: two pennant states, outline for the
exam mark and filled for practice, which is the confusion the whole change exists to
remove.

---

## Section 6: The same screen after a practice session

Settled 28 July, and it is the reason the review list is a component rather than a page.

`quiz_results_page.dart` **survives, rebuilt as the practice review.** Its only entry was
the "Review results" button on the session ending, which the debrief deleted, so it is
unreachable code today. Rather than delete it, the debrief gains **one ruled row**,
"Go through all 10", opening this review screen scoped to the session just finished.

**It is the same component, with three differences the data forces:**

| | Mock review | Practice review |
|---|---|---|
| Grouping | By subject, with a count | Flat. A ten-question session rarely spans enough subjects to earn headings |
| Filters | All, Wrong, Flagged | The same row, with the same **Wrong** default |
| The one-time offer | Present, for the marks made under the clock | **Absent.** Practice flags are durable from the moment they are set |

**This reverses a decision made on 27 July and the reversal is deliberate.** A "Review
the misses" button was drawn on the debrief and deleted, on the grounds that the student
had seen every miss seconds earlier. That argument holds for the **misses** and does not
hold for the **explanations**: at answer time the note is read once, under the momentum
of a session, and there was no way to return to it afterwards short of meeting the
question again by chance. One row restores that, and it makes both endings in the app
work the same way.

**What does not change:** the miss rows on the debrief itself stay a record with no
chevrons and nothing happens on tap. The row is the only way through, and it sits below
the return promise, above the footer.

---

## Section 7: The setup screen and the section transition

**Added 4 August 2026**, validated against
`.superpowers/brainstorm/92781-1785816810/content/mock-all-screens.html`.

### 7.1 Setup, confirmed rather than redrawn

Spec 5's shape survives: a headline, a short list of facts about the paper, one board button.
It gains what sectional timing made real and loses what the identity bans.

```
UPCAT practice paper                       (serif 24/700)
4 parts. 175 questions. 2 hours 45 minutes.

The parts                                  (plate)
Reading Comprehension              30 min
Mathematics                        45 min
Science                            45 min
Language Proficiency               45 min

How this paper runs                        (plate)
This paper runs part by part. Once a part ends you cannot go back.
[hairline]
Strict mock mode is on.
You cannot pause, and you cannot end a part early. Leaving the
app hands the paper in.
Change this in Settings.

[ Start the paper ]
The clock starts when you tap.
```

**The parts list is not decoration.** Section 2 says the paper's rule must be stated in plain
words before a student commits, and the per-part timings are the thing they most want to see.

**The strict block appears only when the switch is on**, and says nothing at all when it is off.
Nobody needs telling what is not happening.

### 7.2 The section transition

**A full screen, not a dialog.** Crossing a part boundary is the only irreversible thing in the
paper, and a dialog is what you use for something a person can undo.

**No app bar, no clock, no floating bar, no back arrow.** The clock is stopped here, and a
stopped clock invites the question of whether it is still running.

```
Time is up for Part 1.                     (serif 24/700)
Reading Comprehension. 30 minutes.

What you did                               (plate)
28  of 30 answered                         (30 numeral, then serif 14/400)
2 left blank · 3 you flagged               (sans 13/400 inkMuted)

Part 1 is closed. You cannot go back to it.   (sans 13, ink, w600)

Next                                       (plate)
Part 2, Mathematics
45 questions, 45 minutes.

[ Start Part 2 ]
The clock for Part 2 starts when you tap.
```

**It reports what they did, and that is the point of the screen.** A student who has just lost
access to thirty questions will immediately want to know whether they left any blank. Telling
them is the difference between a closed door and a closed door they understand.

**Nothing here is a score.** Answered, blank and flagged are counts of the student's own
actions. No correctness is shown or implied, and none is known to this screen.

**The figure and its label share one baseline**, "28 of 30 answered", rather than stacking. An
earlier draw put the label under the numeral and left a hole. **The blank and flagged counts are
one quiet line, not two ruled rows**: they are footnotes to the figure and an earlier draw
dressed them as headings.

**No rust and no amber.** Nothing on this screen is a loss of marks or a deadline.

---

## Section 8: Strict mock mode, and what it forbids

**Added 4 August 2026.** Strict mock mode already existed as a synced setting whose only job was
to gate pause. **It now carries the whole promise that the app behaves like the real room.**

### 8.1 What it forbids

| With strict on | With strict off |
|---|---|
| No pausing | Pause, with Spec 5's first-time warning |
| **No ending a part early** | A part can be ended early |
| Leaving the app hands the paper in | Leaving the app changes nothing |

### 8.2 It must be said in three places

**A restriction a student meets only when they hit it is a bug from their side of the screen.**

1. **In Settings**, as a subtitle under the switch. See
   `2026-08-03-settings-design.md`, "How you practice".
2. **On the setup screen**, because a setting changed weeks ago is not a warning. Section 7.1.
3. **In the paper**, at the moment it stops them.

**In the paper it reads, above the floating bar and only on the last question of a part:**

> Part 1 runs to the end of its time. Strict mock mode is on.

**`next` is dimmed rather than hidden** at that question, so the bar does not change shape
between questions. The line is the quietest text on the screen: it explains, it does not warn.

### 8.3 Ending a part early, when strict is off

A confirmation, and it is a dialog because this one *is* undoable up to the moment it is
confirmed.

> **End Part 1 now?**
> You have **8 minutes left** and **2 questions blank**.
> **Ending now closes Part 1 for good. The time you have left does not carry over.**
> [ End Part 1 ]  Keep working

**The unused time is forfeited, never banked.** Carrying it forward would make ending early
strictly advantageous, which no real paper allows.

**The forfeit ending is unchanged**, and was already designed: Section 4's "Forfeited" results
treatment stands.

### 8.4 The pause screen

**Settled 4 August 2026**, validated against
`.superpowers/brainstorm/92781-1785816810/content/mock-pause-screen.html`. Reachable only when
strict mock mode is off.

**The control sits at the trailing edge of the app bar**, a 46px target, and is **absent
entirely in strict mode**. See the amendment in Section 3.

**Pausing replaces the paper completely. This is the reason it is a screen and not an overlay.**
If the question stayed visible behind a stopped clock, pause would be a way to buy unlimited
time to read it, which is exactly what a real exam has no pause in order to prevent.

```
Paused.                                    (serif 24/700)
Part 2, Mathematics.

Time left                                  (plate)
21:47  in this part                        (30 tabular, then serif 14/400)
14 of 45 answered · 2 you flagged          (sans 13/400 inkMuted)

The clock is stopped. It starts again when you resume.

[ Resume ]                                 (board button)
Discard this paper                         (rust text, no fill)
```

- **Time left, never time elapsed.** Remaining is what a student can act on, and it is the same
  figure the clock has shown all along.
- **The answered and flagged counts** make pausing a moment to see where they stand. Same quiet
  line the transition uses in Section 7.2.
- **No score, no correctness, nothing about the questions.**
- **Resume is the only green thing. Discard is rust text with no fill**, deliberately subtle.
- **No app bar, no clock, no floating bar.** The clock's figure has moved into the body.

**The warning fires once per paper, on the first pause only.**

> **Real exams do not pause.**
> Use this only when you have to. The clock stops, but you will not get this in the real room.
> [ Keep going ]  [ Pause ]

**Every pause after the first goes straight through.** Repeating the lecture would be nagging,
and they have already heard it.

**Discarding is the only destructive action in the mock**, and it takes a rust confirm:

> **Discard this paper?**
> Your 14 answers go, and this attempt will not appear in your record. It does not use up a
> mock.
> [ Keep it ]  [ Discard ]

### 8.5 Dialogs in the mock follow the component, which has two confirm styles

**Recorded 4 August 2026 after two plates drew them wrong.**

- **Both actions sit side by side in one row**, the quiet one left, the committing one right.
  Never stacked, and never a filled button above a text link.
- **The confirm is board green for an ordinary commitment and rust for a destructive one.**
- Title serif 18/700, body sans 14/400 `inkMuted`, 20px padding.

**So: pausing confirms in green. Discarding confirms in rust. Ending a part early confirms in
rust**, because it destroys the remaining time and closes the part for good. Section 8.3's
dialog is rust.

---

## Section 9: The clock rule and the proctor

**Added 4 August 2026.** Spec 5's warnings were a snackbar at five minutes and a colored banner
at one. **Both are struck**: neither is a device this app uses, and sectional timing changes the
meaning anyway, since five minutes left in Mathematics is a different fact from five minutes
left in the paper.

**Everything in this section counts the current part, never the paper.** The paper's total is
never shown during a part, because it says nothing a student can act on.

### 9.1 The clock rule, which is ambient

**A rule on the app bar's own bottom edge, retreating from the right as the part's time runs
out.** It is there from the first second of a part.

| Remaining | The rule | The clock |
|---|---|---|
| Most of the part | 1px `ink` at 55% | plain |
| Under 5 minutes | 1.6px `ink`, full strength | plain |
| Under 1 minute | 1.6px **amber** | **amber** |

**There is no warning event.** The information was always on screen and simply becomes harder to
ignore. A student told only at five minutes has had no idea for the previous twenty five.

**This is the only amber anywhere in the mock**, which is what makes it work: no other surface
has ever used that color, so it reads without a word being written.

### 9.2 The proctor

**A real exam room has a clock on the wall and a proctor who calls the time.** They are
different things and the paper has both. The rule is the clock. This is the proctor.

- **It speaks at 20, 10, 5 and 1 minutes remaining** in the part, skipping any threshold longer
  than the part itself. A part under 20 minutes is called three times.
- **2.5 seconds, then it goes on its own.** Not dismissible, no close, no action, no icon.
- **It sits directly above the floating bar**, 10px clear of it, and is drawn as the bar's
  sibling: same 1px `rule` border, same radius 8, same soft shadow. **Two objects of one family,
  which is why it does not read as an intrusion.**
- **Text is centered, sans 13/600, one line, never wrapping.**
- **At the 1 minute call the text is amber**, with the rule and clock.

**Copy, verbatim:**

> 20 minutes left in this subject.
> 10 minutes left in this subject.
> 5 minutes left in this subject.
> 1 minute left in this subject.

**"Subject", although every other surface says "part". Decided by Aedwon on 4 August against a
recommendation to unify them.** The reading that makes it coherent: **"part" is the app's
structural label and "subject" is the proctor's spoken word.** The line above each question
names the container; the proctor names what is in it. Recorded because a later reader will
otherwise take it for an oversight and tidy it.

### 9.3 The haptic

**Three medium taps, 60ms apart**, fired with each call.

- **A rhythm, deliberately not one long buzz.** A rhythm reads as a signal; a buzz reads as a
  notification.
- **It respects the phone, not a setting of ours.** With system haptics off it is a silent
  no-op, so nothing is added to Settings and nothing has to be discovered.
- **This is the app's first haptic anywhere**, so it sets a precedent to be careful with.
- **Known limit, stated rather than solved:** a phone on a hard desk buzzes audibly, which in a
  shared room is the opposite of unintrusive.

**The practice quiz's existing toast is not this component.** That one wears default system
chrome. This is a mock surface and it belongs to the mock's family.

---

## Open

1. **ACET's aptitude timing is derived from a rate, not published.** Section 2. Confirm before
   that blueprint ships.
2. **MSU-SASE's single block was given with "apparently".** Section 2. Enough to build on, not
   enough to print without a second look.

**Closed 4 August 2026:** all five previously undesigned surfaces, and `sectionalTiming` for all
three remaining exams. Four surfaces are settled in Sections 7 to 9, mock history is struck, and
the timings are in Section 2.

**Closed 28 July:** what Free sees in the review, Section 5. The middle band's name,
Section 4. Whether `quiz_results_page.dart` survives, Section 6.

## A note on plan size

This spec is smaller than the Quiz tab's and still splits in two:

1. **The paper.** Sectional timing end to end, the blueprint field, the grid's mock
   variant, the floating bar, and the setup screen's statement of the rule.
2. **The endings.** The results screen, the review screen, the one-time offer, and the
   practice variant that replaces `quiz_results_page.dart`.

Both depend on the Quiz tab spec's grid and flag components landing first. The review
component in 2 additionally depends on the per-choice rationale content pass, since note
B is what the tier split turns on.
