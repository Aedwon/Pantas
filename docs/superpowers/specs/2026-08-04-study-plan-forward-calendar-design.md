# The study plan: a forward calendar

**Date:** 4 August 2026
**Status:** Approved by Aedwon, validated against
`.superpowers/brainstorm/92781-1785816810/content/plan-calendar-v2.html`
**Decision log:** `docs/superpowers/decisions/2026-08-04-study-plan-log.md`
**Supersedes:** `2026-05-18-study-plan-design.md` (Spec 6) on scope, surface, pacing and tier.
Spec 6's preference storage and its Firestore partial-update rule survive. Everything it says
about mastery, pace curves, tolerance bands and coaching verdicts is struck.

**Assumes nothing in the tree survives.** Like every spec in this project it describes the
destination. Code observations belong in the plan.

---

## Section 1: What this is, and the two sentences that define it

**The study plan is a calendar that looks forward. It is the only surface in the app that
does.** Every other surface talks about now: the quiz tab starts today's session, home ranks
what to work on, progress reports what has happened.

**It never tells a student whether they are doing well.** No pace verdict, no readiness, no
projection, no "on track". It shows what is scheduled and when the fixed points fall.

### Why the scope is this narrow, recorded so it is not widened back

The May design put a coaching surface here: today's session, a pace curve, an on-track band, a
Free and Pro depth split. **Almost all of it now exists somewhere better.**

| What Spec 6 put here | Where it actually lives |
|---|---|
| "Start today's session" and its composition line | The Quiz tab, fully designed with a caught-up state |
| The pacing sentence | Progress, under "Your pace", already Free, already restricted to arithmetic |
| What to work on next | Home's Practice panel, three weakest topics with figures |
| The nearest mock | The Quiz tab's mock panel |

**Building those again here would give the student two doors to the same room and two chances
to disagree with themselves.** What was left after removing them is the forward view, and that
is the whole of this spec.

---

## Section 2: The evidentiary line, which is what shaped the screen

Section 1 of `2026-07-30-progress-tab-design.md` binds this spec. **A figure must be measured
from the student's own use, published by the testing body, or the output of a named algorithm
used as designed.**

**Two things were cut under that rule and they must not return:**

1. **The pace curve.** A projection from a starting mastery to a target mastery is this
   project's own inference about a future that has not happened. The target was authored here,
   not published by any testing body.
2. **The on-track verdict and its tolerance band.** A claim about whether a student will be
   ready is the same class of statement as a score projection, which this project banned when
   it reserved "readiness".

**"Mastery" leaves the app's vocabulary entirely.** Progress prints Score and accuracy and
never says mastery, because mastery is a construct laid over a measurement. This surface now
agrees with it.

### What may be counted, and where counting stops

| Figure | Why it is allowed |
|---|---|
| Today's review count | The scheduler already holds those dates. Algorithm used as designed |
| Each remaining day this week | The same |
| The daily new-question figure | Arithmetic: material remaining, divided by days before the quiet stretch |
| Days or weeks to the exam | The date the student gave us |
| Where the mocks and the exam fall | Fixed dates |

**Counting stops at the end of this week.** Every question answered today changes next week's
schedule, so a count printed for three weeks out is a guess wearing the clothes of a fact.
**Aedwon chose this against a fuller alternative that estimated every week**, on the same
reasoning that killed the curve.

**Weeks beyond this one carry no numbers at all.** They earn their place by showing where the
fixed points fall, not by being filled in.

---

## Section 3: The pacing rule

**The plan paces new material so that it is all introduced before a quiet stretch at the end,
and those last days are review only.**

### The arithmetic

```
quiet stretch = min(7 days, one quarter of the time until the exam)
working days  = days from today until the quiet stretch begins
new per day   = material remaining / working days, rounded up
```

**The quiet stretch is the shorter of seven days and a quarter of the window.** A fixed seven
days breaks at short windows: a student with eight days would get one day of new material and
a week of reviewing almost nothing. Ten weeks gives a full week of review, ten days gives about
two, four days gives one.

### When only the month is known, plan to the first of that month

**Added 4 August 2026 after Aedwon asked what happens to a student who gave a month rather than
a day.** The spec said what not to print and never said what the arithmetic uses.

**A month with no day is treated as the first of that month.**

**This is the opposite of the rule the paywall uses, and the difference is deliberate.** The
plans screen prices to the *last* day of a stated month so a student is never left without
cover. **Here that direction would be dangerous.** A student sitting on 2 October, planned
against 31 October, would be paced to meet new material for three weeks after their exam.

| Direction | What it costs |
|---|---|
| **First of the month** | Some extra review days if the exam is late in the month |
| Last of the month | Material they have never seen on the day they sit the paper |

**Finishing early costs review time. Finishing late costs the exam.** The two surfaces
therefore round in opposite directions, and each rounds toward the thing its own student cannot
afford to lose.

**The header still prints no day count at month precision.** Planning against a date and
printing that date are different acts: the first is arithmetic the student never sees, the
second would be telling them we know something we do not.

*This proportional rule is the only part of Section 3 that is not Aedwon's own instruction. It
is mechanical rather than a question of values, and it is written down so it is easy to
reverse.*

### What happens to the intensity preference

**The app sets a minimum pace. The student's Light, Standard or Intense setting can push it
higher, never lower.**

This was chosen over two alternatives: letting the setting move only the length of the quiet
stretch, which removes a control students expect; and dropping the setting entirely, which
leaves no sense of choice. **The chosen rule guarantees the material finishes in time while
still letting someone with months to spare work harder than they need to.**

### When there is not enough time

**Divide it all in and let them cram. The app does not triage and does not warn.**

Aedwon's reasoning, and it overruled mine: *"how do you decide which one's worth the most
marks? doesn't make sense. let them cram. if they started studying with 10 days left they
definitely decided before to cram."*

**Two things were wrong with the triage I proposed.** The app has no defensible basis for
ranking what is worth most to a particular student, and a student who starts ten days out has
already made their decision. Ranking topics for them would be the app second-guessing a choice
already taken.

---

## Section 4: The screen

**A full-screen page, pushed rather than a tab.** Reached from wherever the plan is entered,
with a back arrow. Title: `Your plan`.

### Composition, in order

```
Your plan                                  (app bar, back arrow)

UPCAT                                      (rank 2)
Ten weeks to go. Sunday 12 October.        (rank 5)

Today                    Monday 4 August   (plate + trailing date)
24    questions today.                     (rank 1, then rank 5)
      18 to review, 6 new.

The rest of this week      5 to 10 August  (plate + trailing range)
Tue 5                     14 review, 6 new
Wed 6                     11 review, 6 new
Thu 7                      9 review, 6 new
Fri 8                     13 review, 6 new
Sat 9                      7 review, 6 new
Sun 10                     5 review, 6 new

Coming up                                  (plate)
11 Aug
18 Aug                           Mock exam
25 Aug
 1 Sep
15 Sep                           Mock exam
29 Sep
 5 Oct              Review only from here
12 Oct                              UPCAT

Six new questions a day finishes the material by 5 October, a week
before your exam. Daily review counts come from your own schedule.
You can go faster in Settings, not slower.
```

### The hierarchy, six ranks

**A figure outranks a heading, and a heading always outranks its own rows.** That is the
grammar Progress already uses and this screen does not invent a new one.

| Rank | What | Size |
|---|---|---|
| 1 | **Today's number.** The one thing to take away | serif 30/700 |
| 2 | The exam name, naming the page once | serif 24/700 |
| 3 | Section headings, each on a 1.6px `ink` rule | serif 16/700 |
| 4 | Dates, the spine the eye scans | serif 14/700 |
| 5 | Counts and detail, read after the day is found | sans 13/400 |
| 6 | The closing sentence, quietest thing on the page | sans 11.5/400 `inkMuted` |

**Today is its own section, not the first of seven rows.** An earlier draw made every day
identical and nothing stood out. Today now carries the only large figure on the screen.

### Color, and there is very little

- **Amber marks the fixed points only**: the day new material stops, the exam, and the day the
  next mock unlocks. A handful of marks on a full screen, so the eye finds them at once.
- **No board green anywhere. No button.** Starting a session belongs to the Quiz tab, and a
  button here would only be a second door to it. **This is a screen to read, not to press**,
  and that is a deliberate departure from every other full-screen page in the app.
- **Rules, never cards.** One hairline under each row, one heavy rule under each heading.

### The mock marker, and what it actually means

**Corrected 4 August 2026. An earlier draw marked mock exams as though the plan scheduled them.
It does not, and nothing in the app does.** The only rule that exists is a restriction: a Free
student may take one mock every 14 days.

**So the marker names the day the next mock unlocks**, 14 days after their last one, and it says
so in those words. It is a fact about a restriction they are under, not a recommendation and
not a schedule.

**A Pro student therefore sees no mock marker at all**, because nothing is locked for them.
Their "Coming up" carries only the review-only marker and the exam. **This is thinner for the
people who paid, and it is still the truthful drawing:** the marker exists to name a limit, and
they do not have one.

**The alternative of having the plan schedule mocks was offered and rejected.** It would have
been the app recommending a cadence rather than reporting a fact, and this surface reports.

### What is not interactive

**Days are not tappable. A future day is a preview, not a command.** Nothing on this screen
opens anything except the back arrow.

---

## Section 5: Tier

**Wholly Free.** Every figure on it is the student's own schedule or their own exam date, and
the constraint in `2026-08-02-pro-entitlement-consolidation-design.md` Section 1 is that
nothing the student produced themselves is ever paywalled.

**This reverses Spec 6's D1**, which split this surface into Free topic-level and Pro
subtopic-level depth. That split existed to sell the coaching layer, and the coaching layer is
gone.

---

## Section 6: Two reservations elsewhere that this design does not fill

**Stated plainly because two shipped plans are waiting on something that is now not coming.**

- `plans/2026-08-02-study-04-reader.md` reserves a slot for a plan counter, a "2 of 3", and a
  ticked rail.
- `plans/2026-08-02-home-04-up-next.md` ships rows that open their own lesson, and reserves a
  start index for a three-lesson daily chain.

**Both wait on a daily lesson chain. This design does not produce one.** The calendar counts
questions per day; it does not name three lessons and put them in an order.

**So those reservations should be closed rather than left open.** Home 4's note that "nothing
is lost when the chain arrives" stays true in the sense that nothing was built wrong, but the
chain is not arriving from here. **Whether a daily lesson chain is worth designing separately
is a decision for Aedwon and it is not part of this spec.**

---

## Section 7: What this depends on

- **The exam date, with its precision.** The header says weeks to the exam, and a student who
  gave only a month must not be shown a day count. That is a measurement combined with an
  assumption.
- **The review scheduler**, for today's and this week's review counts.
- **The count of remaining material**, for the pacing arithmetic.
- **Mock dates**, for the fixed points.

**Nothing here needs the calibration provider Spec 6 named**, which was never built. Targeting
what to study is Home's job and this screen does not do it.

---

## Section 8: Amendments to other specs

1. **`2026-05-18-study-plan-design.md` (Spec 6).** Superseded on scope, surface, pacing and
   tier. D1, D2, D5, D8, D9, D10, D11 and D13 are struck. **D3, D4, D7 and D12 stand**: the
   exam-window framing, exam-date editing, compute-on-read, and Firestore partial-field
   updates. Its `plan_prefs` storage survives unchanged.
2. **`2026-07-30-progress-tab-design.md`.** Unchanged, but its "Your pace" section and this
   spec's closing sentence must be written from the same arithmetic. **If they ever drift they
   will contradict each other in front of a student.**
3. **`2026-07-28-quiz-tab-design.md`.** Unchanged. It keeps sole ownership of today's session.
4. **`2026-08-02-pro-entitlement-consolidation-design.md`.** Add a row: the study plan is wholly
   Free, no gate.

---

## Verification

- **No screen in the study plan prints a verdict.** Grep the feature for "on track", "behind",
  "ahead", "ready" and "mastery" and find nothing.
- **No number appears against any week after the current one.**
- The daily new-question figure times the working days is at least the material remaining.
- The quiet stretch is never longer than a quarter of the time until the exam, and never longer
  than seven days.
- A student whose exam is ten days away still gets a plan, with no warning and no triage.
- The student's intensity setting can raise the daily new count and can never lower it below
  the computed minimum.
- **Exactly zero board green elements and zero buttons on the page.**
- Amber appears only on the review-only marker, the exam date, and the next-mock-unlock date.
- **A Pro student sees no mock marker**, because they have no cap. A Free student sees exactly
  one, dated 14 days after their last mock.
- No date on the screen is described as a scheduled or recommended mock. The plan schedules
  nothing.
- At month precision the header prints no day count, **and the pacing arithmetic runs against
  the first day of that month.** A student who names October is paced to finish by the start of
  October, never by the end of it.
- Nothing on the page is tappable except the back arrow.
