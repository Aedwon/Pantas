# The FSRS optimizer: fitting the schedule to one student

**Spec, 9 August 2026.** Approved for specification by Aedwon the same day:

> **"spec the optimizer now. FSRS is one of the USPs of this app so there's no room for
> deferring this"**

Companion: `decisions/2026-08-08-fsrs-version-log.md` records why we are on FSRS-4.5, why the
move is to 6 and not 7, and what the upgrade costs.

---

## Section 1: What this is for, and the claim it lets us make

**Today every student gets the same 17 numbers.** They were fitted on hundreds of millions of
other people's reviews. They are a good average and they are not about anyone in particular.

**FSRS's entire advantage over a fixed-interval scheduler is that it can be fitted to a
person.** Without that, we ship a better-than-SM-2 average and call it personalization. With
it, the schedule is genuinely derived from how this student forgets.

**That is the difference between "we use FSRS" and "we use FSRS for you", and only the second
is worth saying out loud.**

---

## Section 2: The evidentiary position, which governs everything below

Per `AGENTS.md` and Section 1 of the Progress spec: **a figure shown to a student is measured,
published by the testing body, or the output of a named algorithm used as designed.**

**Optimized parameters are the third kind and they stay the third kind.** They are the output
of FSRS's own fitting procedure over the student's own reviews. That is legitimate.

**What is not legitimate, and must never appear:**

- **Any accuracy claim about the optimization.** Not "12% better retention", not "we improved
  your schedule by". We do not measure retention against a counterfactual and we never will.
- **A confidence figure on the parameters themselves.**
- **A prediction of exam performance derived from the fitted model.**

**The parameters may change the schedule silently. They may not become a number on a screen.**

---

## Section 3: The rating problem, stated plainly because it caps everything

**Anki asks the student to press Again, Hard, Good or Easy. We do not.** We infer the rating
from whether they were right and how fast they answered, in `FsrsRatingHeuristic`.

**So the optimizer fits parameters to our heuristic's guesses, not to what the student felt.**

**This is a deliberate trade and it stands.** Asking a student to grade their own recall after
every question is a real cost in friction, and self-reports are noisy in their own way. But it
is the ceiling on this feature, and it is a larger ceiling than the version number ever was.

**The consequence for design:** the heuristic and the optimizer are now coupled. **Changing the
rating heuristic invalidates every parameter set fitted under the old one.** Section 7 says
what to do about that.

---

## Section 4: What has to be written down, starting now

**This is the urgent half of the work and it is not the optimizer.**

**Today the rating is computed, used to schedule the card, and discarded.** The review state
table keeps only the card's current stability, difficulty and interval, overwritten every
review. The attempts log keeps timestamps, correctness and response time.

**Past ratings cannot be faithfully reconstructed.** The heuristic needs the interval the card
was on *at the moment of that review*, and that value is overwritten. Not approximately
recoverable: the input that decides Hard from Good is gone.

**Therefore every day without a review log is a day of history the optimizer can never use.**
The log ships with the FSRS-6 upgrade, not after it.

### What a review log row is

One row per review, appended, never updated:

| Field | Why |
|---|---|
| `questionId` | Which card |
| `reviewedAt` | The instant, for ordering and for `delta_t` |
| `rating` | **The rating as given at the time.** The whole point of the table |
| `elapsedDays` | Days since that card's previous review, as FSRS saw it |
| `scheduledDays` | The interval the card was on, which the heuristic read |
| `stateBefore` | Stability and difficulty before the review, so a fit can be replayed |
| `responseMs` | Kept because the heuristic reads it and may be revised |
| `isCorrect` | Kept for the same reason |
| `heuristicVersion` | **Which rating heuristic produced this rating.** Section 7 |

**`scheduledDays` and `responseMs` are stored even though the rating is stored too.** The
rating is derived from them, and keeping the inputs means a revised heuristic can re-derive
old ratings rather than discarding the history. **This is the mistake we are correcting; do
not repeat its shape.**

### Retention and size

**A review row is small and a student generates a few thousand a year.** No pruning in v1.
**If pruning is ever added, it must thin oldest-first and never drop a card's first review**,
because initial stability is fitted from exactly those.

---

## Section 5: Where it runs

**On the device, in Dart.** Chosen by Aedwon from three options, with the alternatives and
their costs recorded in the decision log.

**Why it is defensible despite being our own numerical code:**

- **This is not deep learning.** It is 21 parameters fitted by gradient descent over a few
  thousand rows, minimizing log loss between predicted and observed recall.
- **It runs rarely**, not per review.
- **A student's review history never leaves their phone**, which is the easier promise and
  removes a class of privacy question entirely.
- **It works offline**, which matters for the same reason the cached-wins entitlement rule does.

**The cost, stated honestly:** we own it alone. There is no second implementation to compare
against and no upstream fix. **Section 8 is how we make that survivable.**

---

## Section 6: When it runs, and what happens to the schedule

### When

- **At 200 reviews**, as a named constant, not a magic number in a branch.

  **FSRS imposes no minimum. The number is ours.** Anki went from 1000 to 400 to no hard limit,
  fitting fewer parameters when there is less data.

  **200 rather than the conventional 400, and the reason is the exam date.** At roughly 15
  questions a session, 400 reviews is about a month of daily use. For a student sitting in
  eight weeks, a threshold that trips in week five has nearly no time left to help. A general
  flashcard app can wait because it has no deadline; every user of this one has a date in their
  head. **The held-out guard below is what makes reaching earlier safe.**
- **Not during a session.** It runs when the app is idle and charging, or on explicit request
  from Settings.
- **At most once a week.** Parameters that move every day produce a schedule that feels
  arbitrary and make any support question unanswerable.

### What happens to cards already scheduled

**Nothing is rescheduled retroactively.** New parameters apply from the next review of each
card.

**A student mid-preparation must never wake to a hundred cards that moved overnight.** The
existing due dates were a promise; the new parameters change the promise made from here.

### If the fit is worse than the defaults

**Keep the defaults.** A fit that does not beat them is discarded. This is the guard that makes
owning the code survivable: the failure mode is falling back to where we already are.

**The comparison is on reviews the fit has never seen.** Split the log by time: fit on the
earlier reviews, score both parameter sets on the later ones, keep the fitted set only if it
scores better there.

**Corrected 9 August, and the first version of this section was wrong.** It said to compare
both sets on the same data the fit used. **That guard is close to worthless:** 21 parameters
fitted to a dataset will nearly always score better on that same dataset, because that is what
fitting means. It would have waved through exactly the overfitted parameters it exists to
catch, and it would have done so most often for the students with the least data.

**This is what makes a low threshold safe.** With a held-out comparison, fitting too early
costs a little computation and nothing else. Without it, fitting early is actively harmful.

---

## Section 7: When the rating heuristic changes

**Every stored rating carries the heuristic version that produced it.**

- **A fit runs over rows from one heuristic version only**, the current one.
- **When the heuristic changes, old rows are not deleted.** Their inputs are stored, so they
  can be re-rated under the new heuristic and re-admitted to the training set.
- **Re-rating is explicit and logged**, never a silent rewrite of history.

---

## Section 8: What the student sees

**Almost nothing, and that is deliberate.**

- **No banner, no celebration, no figure.** The schedule quietly fits better.
- **One line in Settings**, under the existing storage and account rows: whether the schedule
  is running on the defaults or on parameters fitted to this student, and when they were last
  fitted. **A date and a state, not a score.**
- **A way to go back to the defaults.** One control, no consequences beyond the schedule
  reverting.

**Why so little.** Any number here would be a claim about how much better the schedule is,
which Section 2 forbids. **The feature sells in the store listing, not on a card in the app.**

---

## Section 9: How we know it works

**The thing we cannot do is prove a better schedule for a real student.** That needs a
counterfactual we will never have. **So the tests prove the fitting, not the outcome:**

- **A synthetic student.** Generate reviews from FSRS with a known parameter set, run the
  optimizer, and assert it recovers parameters close to the ones used. This is the test that
  catches a wrong gradient.
- **The loss never increases across iterations**, and the result beats the defaults on the same
  data or is discarded.
- **A degenerate history produces the defaults, not a crash and not nonsense**: all-correct,
  all-wrong, one card, ten reviews.
- **The held-out guard actually rejects an overfit.** Feed a small, noisy history and assert
  the fitted set loses on the later reviews and is discarded. **A guard nobody has watched fail
  is not a guard**, and this one was wrong once already.
- **Parameters stay inside FSRS's own bounds.** Difficulty in 1 to 10, stability positive and
  under the ceiling, decay inside its published range.

---

## Section 9b: Who this actually serves, and who it never will

**The optimizer cannot reach a student who is cramming.** Two weeks is not enough to fit
anything before the exam, at 200 reviews or any other threshold. **They run on the defaults
from first launch to exam day, and no tuning changes that.**

**FSRS-6's same-day review formula is exactly their case.** Answering the same card twice in
one day is what cramming is, and FSRS-4.5 has no model for it. **So the version upgrade is
worth most to precisely the students this spec can never help.**

**The two pieces of work serve different people:** the upgrade serves the short runway, the
optimizer serves the long one.

**Which matters more is a question about our users that we cannot answer yet.** If most arrive
with three weeks left, the optimizer is a smaller selling point than its billing suggests and
the same-day fix is a much larger one. If most arrive with three months, the reverse. **Until
the answer is measured rather than assumed, neither claim outranks the other, and the
optimizer's status as a headline feature must not quietly demote the thing that helps a
short-runway student today.**

---

## Section 10: What this deliberately does not do

- **No optimal-retention search.** FSRS can also fit the target retention itself. Out of scope:
  it changes workload as well as scheduling, and it deserves its own round.
- **No cross-student pooling.** Fitting on other students' data to warm-start a new one is a
  real technique and a privacy decision we have not taken.
- **No server fallback.** If on-device fitting proves too slow on the phones our students
  actually own, that is a finding that reopens Section 5, not something to paper over.

---

## Open, for Aedwon

**Both settled 9 August.**

- **The threshold is 200**, reasoned in Section 6 and made safe by the held-out guard.
- **The Settings line ships in v1.** It is the only evidence the personalization is real, it
  gives support something to ask about, and **it carries the revert control**. That last is what
  decided it: we own this optimizer alone, so without a way for a student to fall back to the
  defaults themselves, a bad fit in the field needs an app update to undo.

**Still open, and it is a question about users rather than about code:** what share of students
arrive with weeks rather than months. Section 9b says why the answer moves which of these two
pieces of work we would actually talk about.
