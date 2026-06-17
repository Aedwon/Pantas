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
mock variant, the floating bar, the results screen, the review screen, and what becomes
of the marks made during the paper.

**Not designed:** the setup screen beyond the one requirement in Section 2, the pause
and strict-forfeit flows, the section-transition moment, the warning overlays, and mock
history. Spec 5 sketches all of these and they stand until redrawn.

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
| ACET, DCAT, MSU-SASE | **Unknown** | None publishes its timing. Aedwon is establishing these |

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
the clock sits alone there, centred, serif 16/700, tabular.

---

## Section 4: The results screen

### The score

Centred, and **the figure alone**:

```
              68%
          Not far off
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
"diagnostic". The middle band currently reads **"Not far off"**, which is provisional.

### The header

The blueprint name in serif 21/700, and **the date alone** beneath it in 12
`inkMuted`. No duration: whether the full time was used is in the Performance table
where it is actionable.

### Performance

A `SectionHeader` reading **"Performance"**, then one row per part: the part name, a
54px inline meter, the accuracy, and time against suggested. Over-time in `rust`. The
meter colours by severity on Home's rule: `rust` below 50, `amber` below 70, `ink`
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

## Open

1. **What Free sees in the review.** Spec 5 D11 gates the whole per-question review
   behind Pro. That predates the **Free records, Pro interprets** rule settled for the
   practice reveal, where Free already gets the mark, the answer and the authored
   explanation. Applying it consistently would give Free every question, the correct
   answer and the explanation, with Pro adding the note on the choice made. The
   counter-argument is that 120 explanations is a lot to hand over and D11 is a clean
   line. **Undecided.** Whichever wins, D11 is formally amended rather than quietly
   ignored.
2. **`sectionalTiming` for ACET, DCAT and MSU-SASE.** Aedwon is establishing these.
   Those three blueprints cannot be completed until he reports back.
3. **The middle band's name.** "Not far off" is provisional.
4. **Whether `quiz_results_page.dart` survives.** The debrief replaced its only entry
   point, since "Review results" was deleted from the session ending. It is now
   unreachable. It either goes, or it becomes the practice equivalent of this review
   screen, reusing the same component for a ten-question session.

## A note on plan size

This spec is smaller than the Quiz tab's and still splits in two:

1. **The paper.** Sectional timing end to end, the blueprint field, the grid's mock
   variant, the floating bar, and the setup screen's statement of the rule.
2. **The endings.** The results screen, the review screen, and the one-time offer.

Both depend on the Quiz tab spec's grid and flag components landing first.
