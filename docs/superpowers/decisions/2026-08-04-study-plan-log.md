# Study plan decision log

The design round on the study plan, the largest outstanding design job. Chronological.
Later entries append; they never edit earlier ones.

---

## 4 August 2026: the scope question, and Aedwon catching me overstating the problem

**The round opened on the question `2026-08-03-next-rounds.md` Part 1.2 says to ask first:**
does v1 ship this at all, or ship with the entry row still hidden?

### What I put to him, and what was wrong with it

I reported three blockers:

1. The feature's targeting hangs on `quizPickerCalibrationProvider` from Spec 4, and that
   identifier appears nowhere in `lib/`.
2. `exam.targetMastery` is not wired.
3. The engine is denominated in **mastery**, a construct the Progress tab deliberately refuses
   to print, and its pace curve produces an "on track" verdict that is a claim about the future.

**He did not accept it.** Verbatim:

> "are you sure these problems don't get resolved from other specs?"

**He was right, and on the largest of the three.**

- **Targeting is already solved under a different name.** `topicAccuracyProvider`, built by
  `home-05-practice-panel`, answers "which topics are weakest" from live attempts with a
  three-question floor. The collision map already lists it as shared by H4, H5 and G3. The
  study plan needs no calibration provider of its own. **I treated an unbuilt identifier named
  in a May spec as a missing subsystem, when the job it does had since been built elsewhere.**
- **Sizing inputs are fine too.** `lib/core/fsrs/` exists, so "what is due today" is measured.

### What survived the check

Verified properly the second time:

- `targetMastery` appears in Spec 6 and its own two plans. **Nowhere else** in any spec, plan
  or line of code.
- The Progress spec says "mastery" **zero times** and explicitly rejects difficulty calibration
  "for the circularity reason in Section 10".
- `TopicMastery` exists, but only inside the assessment feature. It freezes on assessment day
  and each percentage rests on at most three questions, which is why Home was rewritten to read
  attempts instead.

So the feature has a **measured half** that is nearly free, and one **unfounded piece**:
`pace_curve.dart`, `daily_sizer.dart`'s ±5% tolerance band, and the "on track" verdict.

### The options, re-priced after the correction

| Option | Cost |
|---|---|
| **Ship the measured half, cut the curve** | Loses the pacing story. Two of the thirteen files get deleted rather than wired. Cheap, because targeting comes free. |
| Ship it all, rule on the curve first | Needs an evidentiary ruling before any drawing, and `targetMastery` still has to come from somewhere real per exam. |
| Keep the row hidden | The coach pillar loses its spine and two shipped plans keep carrying reservations. Weaker once most of the feature turns out reachable. |
| Draw first, decide after | One round before any decision. |

### What he chose

**Ship the measured half, cut the curve.**

### The lesson worth keeping

**My first framing overpriced the work by treating a May spec's vocabulary as the current
state of the tree.** The check that fixed it was three greps. Run them before reporting a
blocker, not after being challenged on one.

---

## 4 August 2026, later: the surface shrinks to the one job nothing else does

**Found while preparing to draw**, after he asked for the screen drawn against the current
identity. Checking the neighbouring specs first, per the rule that both rejected plates in the
Progress work were rejected for inventing something already decided:

- **"Start today's session" is already fully designed on the Quiz tab**, with its two figures,
  its composition line and a caught-up state.
- **The pacing sentence is already designed in Progress, under "Your pace"**, already wholly
  Free, and already carrying the hard rule *"this stays arithmetic. It may never become a score
  projection."* That is the same conditional-arithmetic shape I had just recommended inventing
  for the study plan, and it existed already.
- **What to work on next is Home's Practice panel.** The nearest mock is the Quiz tab's.

**So cutting the curve left a screen that was mostly a second copy of three screens already
designed.** This was not visible when the scope decision was taken earlier the same day, and it
reopened it.

### The options put to him

| Option | Cost |
|---|---|
| **Forward calendar only** | Keeps the one job nothing else does: what the next days and weeks hold and where the mock sits. Deletes everything that competes with a better version of itself. Much smaller than what was agreed an hour earlier. |
| Drop the screen entirely | Everything valuable is already reachable. The coach pillar keeps no surface of its own. |
| Build it all as decided | Accepts the duplication across three tabs. |

### What he chose

**Option 1, the forward calendar.**

> "for the options you gave, let's go with 1 - build as a forward calendar"

**This reverses the earlier decision on the same day, and the earlier one stays above.** It went
from "ship the measured half" to "ship only the part that looks forward", because the measured
half turned out to be mostly already shipped elsewhere.

### What I got wrong

**I recommended re-founding the plan on a pacing sentence that Progress had already specced,
word for word in spirit, months earlier.** I checked the study plan's own dependencies
carefully and did not check whether its job had already been done by a neighbour. That is the
second time in one round the same mistake shape appeared: reasoning from one document instead
of from the current state of the whole design.

---

## 4 August 2026, the pacing rules, and cramming left alone

### The counting horizon

Options put to him on the plate, after the whole screen was drawn:

| Option | Cost |
|---|---|
| **A. Stop counting after this week** | Honest. The far view still earns its place by showing where the mock falls. Loses the sense of a full workload ahead. |
| B. Estimate every week | Fuller, and it makes the plan feel like a plan. Those figures would be this project's own guess about a schedule that has not happened yet. |

**He chose A.** Same reasoning that cut the pace curve: this week's counts are real because the
review schedule already knows those dates, and anything past that is a guess wearing the
clothes of a fact.

### He put pacing back, on a footing that is allowed

> "am I right to assume the app algorithmically adjusts the plan based on the length of today
> until the exam date right? then can you make sure for whether they have a long time or a
> short time, you should consider that all new topics should be consumed so that the last few
> days are just pure review and nothing new?"

**He was half right and the correction matters.** The app does not adjust to the exam date
today: the old design did, but by projecting readiness, which was cut this morning. His proposal
puts pacing back **built on counting rather than guessing**: material remaining divided by days
available. That is arithmetic over known quantities, the same class as Progress's "at three
lessons a week you finish nine days after the exam", so it is permitted where the curve was not.

**It collides with the decision taken earlier the same day**, that the daily new-material amount
comes from the Light / Standard / Intense preset. If the student sets the pace, nothing
guarantees the material finishes before the exam.

| Option for the preset | Cost |
|---|---|
| 1. App sets pace, preset only moves the length of the quiet tail | Tidy, but removes a control students expect |
| **2. App sets a minimum pace, preset can only push faster** | Guarantees finishing in time, and someone with months to spare can still choose to go hard |
| 3. Drop the preset, the date decides everything | Simplest, no sense of choice at all |

**He chose 2.** And **7 days** for the review-only tail.

### Where he overruled me, and he was right

I proposed that when there is not enough time, the app should say so and prioritise the topics
worth the most marks.

> "how do you decide which one's worth the most marks? doesn't make sense. let them cram. if
> they started studying with 10 days left they definitely decided before to cram"

**Two things wrong with my proposal.** The app has no defensible basis for ranking what is worth
most *to this student*, and more importantly a student who starts ten days out has already made
their decision. Triage would be the app second-guessing a choice already made. **No triage. If
the time is short, divide it all in and let them cram.**

### One mechanical hole, closed without asking

A fixed 7 day tail breaks at short windows: 8 days total would leave one day of new material and
a week of reviewing almost nothing. **The tail is therefore the last 7 days, or the last quarter
of the window, whichever is shorter.** Ten weeks gives a full week, ten days gives about two,
four days gives one. Recorded as my call rather than his, because it is mechanical rather than a
question of values, and it should be easy to reverse if he disagrees.

---

## 4 August 2026: his confirming question found a hole in the spec

He read the spec back to check his understanding:

> "this corrects the earlier decision right? so the app will set out what it's supposed to do
> which is to create a plan for the user based on the estimated time from today til their
> specific exam (whether day-specified or not)"

**Both halves were right.** It does correct the morning's decision, which had cut pacing
entirely, and the app does now build the plan from the time until the exam.

**The parenthesis found something the spec did not answer.** It said what not to print at month
precision and never said what the arithmetic should use.

**Fixed: a month with no day is planned against the first of that month.**

**This is deliberately the opposite of the paywall's rule**, which prices to the last day of a
stated month so a student is never left without cover. Here that direction is dangerous: a
student sitting on 2 October, planned against 31 October, would be paced to meet new material
for three weeks after their exam.

**Finishing early costs review days. Finishing late costs the exam.** The two surfaces round in
opposite directions, and each rounds toward the thing its own student cannot afford to lose.

**Worth noting how it surfaced.** He was not raising a problem, he was checking he had followed
the design. The gap turned up because he restated it in his own words, which the spec's own
wording had let me skip past.

---

## 4 August 2026: the mock markers had no foundation, and I put them there

**Found while preparing the implementation plan.** The approved spec said amber marks "each
mock". **Nothing in the app schedules a mock.** The only rule that exists is a restriction: a
Free student may take one every 14 days. I had drawn mock dates on the plate as though they
were planned, and they were invented.

### The options put to him

| Option | Cost |
|---|---|
| 1. Drop the mock markers | Honest. The calendar keeps the review-only marker and the exam, and loses something useful. |
| **2. Mark when the next mock unlocks**, 14 days after the last | Real for Free students. **Meaningless for Pro, who have no cap**, so their calendar carries fewer marks. |
| 3. The plan schedules mocks, one every four weeks plus one near the end | Genuinely useful advice, and it makes this surface recommend rather than report. |

**I recommended 3.** He chose **2**, having been told the Pro objection before choosing.

**So the marker names a restriction, not a plan.** A Pro student sees no mock marker at all and
their "Coming up" carries only the review-only marker and the exam. Thinner for the people who
paid, and still the truthful drawing: the marker exists to name a limit and they do not have
one.

**What I got wrong:** I drew scheduled mocks into a mockup, wrote them into a spec, and got the
spec approved, before checking that anything in the app produced such a date. The check took one
grep. This is the third time in this feature that reasoning from a document instead of from the
tree produced something that had to be pulled back.

---

## 4 August 2026: the worked example in the approved spec was wrong three ways

**Found while writing the implementation plan**, by computing the arithmetic instead of copying
the numbers I had already drawn.

| Claimed | Actually |
|---|---|
| 4 August 2026 is a Monday | **Tuesday** |
| 12 October 2026 is a Sunday | **Monday** |
| 6 new questions a day | **7.** 69 days, minus a 7 day quiet stretch, is 62 working days. 414 unseen questions over 62 days is 6.68, which rounds up to 7 |

The day list was wrong as a consequence: it ran Tue 5 to Sun 10, six days, when the rest of the
week after a Tuesday is Wed 5 to Sun 9, five days.

**All three went through a mockup he looked at, and through a spec he approved.** The weekdays
were invented rather than computed, and the daily figure contradicted the spec's own rule two
sections above it.

**Fixed in the spec, and the corrected block now states its own inputs** so the arithmetic can
be checked at a glance. A note tells any implementer to check the block rather than copy it.

**The pattern, now three for three in this feature.** Reasoning from what I had already written
instead of from the thing itself: first treating a May spec's vocabulary as the state of the
tree, then drawing scheduled mocks nothing schedules, now inventing weekdays. **The check that
caught each one took seconds.** Worth recording plainly rather than filed as a typo.
