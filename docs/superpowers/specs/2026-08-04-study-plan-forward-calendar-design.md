# The study plan: a forward calendar

> **Typography, amended 11 August 2026.** Every mention of a serif below is
> superseded. **The app uses one family, Source Sans 3, everywhere**: the serif
> was retired because Aedwon found it an eyesore, and a reader noticing the
> type is not reading the lesson. Read a "serif 16/700" here as "16/700".
> The round is in `decisions/2026-08-10-typeface-log.md`.
>
> **What the serif carried, the rest of the identity now carries alone**: the
> hairline rules, the underlined section heads, the tabular figures, and the
> absence of tinted callouts, rounded cards and drop shadows.



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

### What the app is actually for

**Amended 4 August 2026, and this is the sentence the whole feature exists to keep.**

> **The app schedules the topics a student has to deal with inside the time they actually have.**
> Someone who starts early is naturally better off: they have more days, so their pacing is
> gentler. Someone who starts late chose to cram, and it is not the app's job to protect them
> from that by covering less.

**Every rule below follows from that sentence.** Where another spec disagrees with it, that
spec is superseded and Section 8 says so.

### The arithmetic

```
quiet stretch = min(7 days, one quarter of the time until the exam)
working days  = days from today until the quiet stretch begins
lessons per day   = lessons remaining   / working days, rounded up
questions per day = questions remaining / working days, rounded up
```

**Both counts, not one.** An earlier version of this spec paced questions only and said nothing
about lessons, which left the daily lesson count computed by nobody. **The same division does
both**, because a student has two kinds of material and the promise covers both.

**No count in this app is ever a fixed number.** Not three lessons, not ten new questions.
Aedwon's test, and it is the one that kills every fixed figure:

> "if they had to review in 10 days, do you seriously think they'll be able to cover all topics
> if you present to them 3 a day only in that situation?"

Eight working days at three lessons a day is twenty four lessons, which is nowhere near a
corpus. **A fixed daily number makes the promise above impossible to keep**, so there are none.

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

### What happens to the student's own control

**The app sets the pace. One switch, "Do more each day", raises it. Nothing lowers it.**

**Amended 4 August 2026 to a switch**, from a Light, Standard and Intense preset. Two of those
three options did nothing: **the computed pace is already the minimum that finishes the material
in time, so there is no slower setting to offer.** Naming three when one acts would be a lie,
and a control with two states is a switch.

This was chosen over two alternatives: letting the control move only the length of the quiet
stretch, which removes a lever students expect; and dropping it entirely, which leaves no sense
of choice. **The chosen rule guarantees the material finishes in time while still letting
someone with months to spare get ahead.**

**This reverses `2026-05-17-quiz-engine-and-modes-design.md` D7**, which said "the user-set
override always wins over the auto-default". **It no longer wins downward.** An override that
lowers the pace below what finishing requires breaks the promise in the sentence at the top of
this section, silently, and the student would not find out until the exam. See Section 8.

**The switch has one home, and it does not exist yet.** A three-way intensity value is stored
in the tree today and is reachable from nothing: the current Settings spec had no row for it,
and D7's separate 5/10/20/30/50 new-card selector is not in Settings either. **There must be
exactly one control, not two**, and it is this switch. Section 8 carries the Settings
amendment, and the stored three-way value collapses to a boolean.

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

**The worked example below is arithmetic, not decoration.** Today is Tuesday 4 August 2026, the
exam is Monday 12 October 2026, 69 days away. The quiet stretch is 7 days, leaving 62 working
days. With 414 questions never seen, that is 7 new a day.

```
Your plan                                  (app bar, back arrow)

UPCAT                                      (rank 2)
Ten weeks to go. Monday 12 October.        (rank 5)

Today                   Tuesday 4 August   (plate + trailing date)
25    questions today.                     (rank 1, then rank 5)
      18 to review, 7 new.

The rest of this week       5 to 9 August  (plate + trailing range)
Wed 5                     14 review, 7 new
Thu 6                     11 review, 7 new
Fri 7                      9 review, 7 new
Sat 8                     13 review, 7 new
Sun 9                      7 review, 7 new

Coming up                                  (plate)
10 Aug
17 Aug                   Next mock unlocks
24 Aug
31 Aug
 7 Sep
14 Sep
21 Sep
28 Sep
 5 Oct              Review only from here
12 Oct                              UPCAT

Seven new questions a day finishes the material by 5 October, a week
before your exam. Daily review counts come from your own schedule.
You can go faster in Settings, not slower.
```

**Corrected 4 August 2026.** An earlier version of this block dated 4 August as a Monday, 12
October as a Sunday, and printed 6 new a day. All three were wrong: the weekdays were invented
and the daily figure did not match the spec's own rule. **Any implementer should check the
arithmetic in this block rather than copying it**, which is how these were caught.

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

## Section 6: The two reservations elsewhere, and what fills them

**Rewritten 4 August 2026. An earlier version of this section said the chain was not coming and
that these reservations should be closed. That was wrong**, and it was wrong because this spec
paced only questions at the time.

- `plans/2026-08-02-study-04-reader.md` reserves a slot for a plan counter, a "2 of 3", and a
  ticked rail.
- `plans/2026-08-02-home-04-up-next.md` ships rows that open their own lesson, and reserves a
  start index for a three-lesson daily chain.

**Both are filled by the daily lesson count in Section 3.** The plan already knows how many
lessons today needs; nothing separate has to be designed and no chain has to be invented.

**"Three" is struck everywhere it appears.** It came from
`2026-07-26-home-and-navigation-design.md` and was never derived from anything. The reader's
counter reads **"2 of N"** where N is today's computed count, and Home's panel starts at the
right index into the same list.

**Consequences for those two plans, and they are amendments rather than rewrites:**

| Plan | What changes |
|---|---|
| `home-04-up-next` | Its provider answers "which lessons today", not "which three lessons". The count is a parameter, not a constant, and its lead sentence must survive N of 1 and N of 12. |
| `study-04-reader` | The counter renders "2 of N". The ticked rail has N marks. |

**A day with a large N is not a bug.** A student with ten days to go gets a lot of lessons a
day, because that is what covering the material in ten days requires. Section 3's opening
sentence is the authority.

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

**Items 5 to 8 were added 4 August 2026 when the pacing was extended to lessons. They are
contradictions found by checking, not by assuming.**

1. **`2026-05-18-study-plan-design.md` (Spec 6).** Superseded on scope, surface, pacing and
   tier. D1, D2, D5, D8, D9, D10, D11 and D13 are struck. **D3, D4, D7 and D12 stand**: the
   exam-window framing, exam-date editing, compute-on-read, and Firestore partial-field
   updates. Its `plan_prefs` storage survives unchanged.
2. **`2026-07-30-progress-tab-design.md`.** Unchanged, but its "Your pace" section and this
   spec's closing sentence must be written from the same arithmetic. **If they ever drift they
   will contradict each other in front of a student.** Note the two say different things on
   purpose: **Progress describes the rate the student is actually going at, and this spec
   prescribes the rate that finishes in time.** Both are honest and they are not the same
   number.
3. **`2026-07-28-quiz-tab-design.md`.** Unchanged. It keeps sole ownership of today's session.
4. **`2026-08-02-pro-entitlement-consolidation-design.md`.** Add a row: the study plan is wholly
   Free, no gate.
5. **`2026-05-17-quiz-engine-and-modes-design.md` D7, superseded in two ways.**
   - **Its formula is replaced.** D7 named a bucket heuristic, "cap 10 if more than 60 days to
     exam, 20 if 30 to 60, 40 if under 30". **That was a guess standing in for an arithmetic
     that now exists.** The daily new-question count is Section 3's division, and the buckets
     are struck.
   - **"The user-set override always wins" is reversed.** It no longer wins downward. See
     Section 3.
   - **D7's own fallback stands and is worth keeping**: if the plan is not available, a static
     default is sufficient and the engine must never hard depend on this spec.
6. **`2026-08-03-settings-design.md` needs one row it does not have.** The pace control is
   stored in the tree as a three-way value and reachable from nothing. **It becomes a boolean.** It belongs under "How you practice", beside
   "How sessions are built", as a **switch**, and **it replaces D7's 5/10/20/30/50 selector
   rather than joining it.** Two controls for one number is how they end up disagreeing.
   > **Do more each day**
   > Your plan already paces you to finish everything before your exam. Turn this on to go
   > faster and leave yourself more time to review.
7. **`2026-08-02-home-04-up-next.md`** takes a count rather than a constant three. Section 6.
8. **`2026-08-02-study-04-reader.md`** renders "2 of N". Section 6.

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
