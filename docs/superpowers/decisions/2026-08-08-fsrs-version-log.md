# FSRS: which version we are on, and whether to move

Opened 8 August 2026, because Aedwon asked, mid-session and unprompted:

> **"i want to flag now than later. confirming, we're using FSRS 4.5 right? why 4.5? why not the
> latest one? this worries me because there might be algorithms that we're using that are not
> updated"**

He was right to ask and he was right on the facts. **This entry exists mostly to record that I
answered from memory first and was wrong.**

---

## What we actually run, read from the code and not from memory

**FSRS-4.5.** `lib/core/fsrs/default_weights.dart` says so in its first line and the numbers
match: **17 weights**, `DECAY = -0.5`, `FACTOR = 19/81`, target retention `0.9`.

**The weights are never anything but the defaults.** `kFsrsDefaultWeights` has exactly one
reader, the scheduler's default argument, and **there is no optimizer anywhere in the
codebase.** Nothing reads a student's review history and fits parameters to it.

**That is the more important fact and it is not a version problem.** FSRS's whole claim over
SM-2 is that it fits the individual. Every student we have gets the same seventeen numbers,
which were themselves fitted on other people's reviews.

---

## The version history, verified against the source

| Version | Parameters | What it changed |
|---|---|---|
| v4 | 17 | `DECAY = -1`, `FACTOR = 1/9` |
| **4.5, ours** | **17** | The forgetting curve: `DECAY = -0.5`, `FACTOR = 19/81`. Steeper before stability, flatter after |
| 5 | 19 | New difficulty initialization; mean reversion retargeted from `D₀(3)` to `D₀(4)` |
| **6** | **21** | **Same-day reviews get a real formula**, and the curve's decay becomes a trainable parameter instead of a constant |
| 7 | **35** | **Dual forgetting curves** combined by weights that depend on stability, plus a long-term to short-term memory transition |

---

## What I got wrong, and what he got right

**I told him 6 was the latest.** He searched and came back with **"i found fsrs 7 upon
searching"**, and FSRS-7 is real: 35 parameters, dual forgetting curves, in the
`srs-benchmark` repository.

**So the correction matters, but the conclusion does not move**, for a reason worth writing
down: **FSRS-7 is research, not a release.** The reference implementation, `py-fsrs`, is on
**6.3.1** and its notes still describe the FSRS-6 model. v7 exists in the benchmark suite
beside v1 through v6, which is where new models are evaluated, not where shipped ones live.

**The lesson is not "he was right about 7 and I was wrong".** It is that **"latest" splits into
two questions**, and only one of them was worth asking:

- **The newest model that exists:** 7.
- **The newest model anyone ships:** 6.

**For a scheduler that decides when a student sees a card again, the second is the one that
counts.** Adopting a benchmark-stage model means we own every bug in it alone, with no other
implementation to compare against and no upstream fixes.

---

## Can we upgrade? Yes, and the state survives

**The blocking question for a shipped app is whether stored progress carries over.** It does.
Every FSRS version from 4.5 to 7 keeps the same two per-card state variables, **stability in
days and difficulty on 1 to 10**. Our `review_states` rows hold exactly those. **A version
change re-interprets them, it does not invalidate them**, so no migration throws away a
student's history.

The work, for 4.5 to 6:

- **Swap the weight vector**, 17 values to 21. The FSRS-6 defaults are published.
- **Change four formulas:** difficulty initialization, difficulty mean reversion, stability
  after a same-day review, and the forgetting curve.
- **Stop treating decay as a constant.** `kFsrsDecay` becomes `w[20]`, and `kFsrsFactor` is
  derived from it rather than fixed at `19/81`.
- The scheduler is **158 lines** and has tests. This is a contained change, not a rewrite.

---

## What the upgrade actually buys, honestly

**One of FSRS-6's two headline improvements does nothing for us yet.** Trainable decay is a
parameter the optimizer learns. **With no optimizer, `w[20]` is a constant we did not fit**,
exactly like the constant we already have.

**The other one is worth real money to this app.** FSRS-6 gives same-day reviews a proper
stability formula. **A student cramming the week before an exam answers the same card twice in
a day, and 4.5 has no model for that**: it is the single behavior an exam reviewer sees most
and the one our version handles worst. This is not a general-purpose flashcard app where
same-day repeats are an edge case.

---

## The options, and their costs

| Option | Cost |
|---|---|
| **Stay on 4.5** | Free. Keeps the same-day gap, which is the one that bites hardest here. Defensible only while nothing optimizes anyway. |
| **Move to 6** | A contained change to a 158-line scheduler with tests, and a published weight vector. Fixes same-day reviews now; the trainable decay sits dormant until an optimizer exists. *Recommended.* |
| **Move to 7** | 35 parameters and a dual-curve model **that nobody ships**. We would be the only implementation, debugging it alone, on the piece of the app hardest to tell is subtly wrong. |
| **Build the optimizer first** | The largest win by far and the largest job. Needs a review log we already store, a fitting routine, and a decision about doing it on device or on a server. **Worth its own spec.** |

**Recommendation: move to 6, and treat the optimizer as a separate and larger piece of work.**
The version bump is cheap and fixes a real behavior. The optimizer is what makes any version
of FSRS worth having, and no version bump substitutes for it.

---

## Open, for Aedwon

- **Approve the move to 6?**
- **Does the optimizer get a spec now**, or is it parked behind launch? It is the difference
  between "we run FSRS" and "we run FSRS for you", and the second is the claim worth making.

## Sources

- The Algorithm, `awesome-fsrs` wiki: version history and parameter counts
- `py-fsrs` releases: latest is 6.3.1, implementing FSRS-6
- `srs-benchmark`: FSRS v7, 35 parameters, dual forgetting curves, benchmark only
- Expertium, A technical explanation of FSRS: the FSRS-6 formulas

---

## 9 August: decided

**Aedwon, on both questions at once:**

> **"go with 1, and write the review log into the plan. i'm anxious now that we might not have
> implemented something crucial to this app."**

and, on the optimizer:

> **"spec the optimizer now. FSRS is one of the USPs of this app so there's no room for
> deferring this"**

**So: FSRS-6, the optimizer runs on the device in Dart, and the review log ships with the
upgrade rather than after it.** Spec at `specs/2026-08-09-fsrs-optimizer-design.md`, plan at
`plans/2026-08-09-fsrs-6-and-the-review-log.md`.

### The rating question he asked in the middle, which was the right one

> **"so you're saying we need the rating system for every question for fsrs 6 to be at its
> best?"**

**No, and the distinction matters.** The rating system exists and works: every review produces
one of the four ratings and schedules the card with it. **FSRS-6 needs nothing new there.**

**What is missing is that we never keep the rating.** It is computed, used, and discarded. That
costs nothing today and costs everything to the optimizer, because the heuristic reads the
interval the card was on at that moment and the review overwrites it. **The input that
separates Hard from Good is gone within milliseconds of being used.**

### The ceiling, recorded because it is easy to forget later

**Our ratings are inferred, not chosen.** Anki asks the student to press a button; we guess
from correctness and response speed. **An optimizer will therefore fit to our guesses.** That
is a deliberate trade against asking a student to grade themselves after every question, and it
is a larger limit on this feature than the version number ever was.

### The anxiety, and what an audit of it actually found

His words were **"i'm anxious now that we might not have implemented something crucial"**, so
the honest response was to go looking rather than to reassure.

| Found | State |
|---|---|
| **The review log** | **Genuinely missing and tracked nowhere.** The find of the day |
| **Firebase is never initialized** | The boot adapter's `initialize` is an empty body with a comment. **Auth, sync, crash reporting and App Check are all inert.** Recorded in the launch checklist, **absent from the pipeline document that a dispatcher actually reads** |
| Three stub routes, the study plan providers | Deliberate placeholders, marked as such |

**So: not a pattern of things quietly missing.** One real gap, one large known one filed where
nobody looks, and some honest scaffolding. **The Firebase item should be moved into the
pipeline**, because a thing everyone knows and nobody reads is only half tracked.

---

## 9 August, later: the threshold, the guard I got wrong, and who FSRS cannot help

### The threshold: 200, not the conventional 400

**FSRS-6 imposes no minimum.** The number is a property of the fitting procedure, not the
algorithm, so it is entirely ours. Anki went 1000, then 400, then dropped the hard limit
altogether and instead fits fewer parameters when there is less data.

**200 was chosen because this app has a deadline and a flashcard app does not.** At roughly 15
questions a session, 400 reviews is a month of daily use. A student sitting in eight weeks
would be fitted in week five, with almost no time left to benefit.

### The guard in my own spec was wrong, and it would have failed silently

**As first written, Section 6 said a fit is kept only if it beats the defaults on the same
data.** That is close to worthless. **21 parameters fitted to a dataset will nearly always
score better on that same dataset, because that is what fitting means.** The guard would have
waved through exactly the overfitted parameters it existed to catch, and **it would have done
so most often for the students with the least data**, which is precisely who a lowered
threshold exposes.

**Corrected to a held-out comparison:** fit on the earlier reviews, score both sets on the
later ones. **This is what makes 200 safe rather than reckless**, and the two decisions are
therefore one decision: the lower threshold is only defensible because the guard was fixed.

**Section 9 now carries a test that watches the guard reject an overfit.** A guard nobody has
seen fail is not a guard, and this one was wrong once already.

### What he noticed, which was sharper than the threshold question

> **"wait this means the fsrs algorithm won't really work on someone cramming right? well, not
> that it would matter since they're cramming anyway"**

**Right about the optimizer.** Two weeks does not reach a meaningful fit at any threshold. A
crammer runs on the defaults from first launch to exam day.

**But it inverts into something useful.** FSRS-6's same-day review formula is exactly the
crammer's case: answering the same card twice in a day is what cramming is, and 4.5 has no
model for it. **The version upgrade is worth most to the students the optimizer can never
reach.** The two pieces of work serve different people.

**Where I pushed back:** "not that it would matter since they're cramming anyway" is worth
measuring rather than assuming. **If most students arrive with three weeks, the optimizer is a
smaller selling point than its billing and the same-day fix is a much larger one**, and that
changes which we would put in a store listing. Recorded as Section 9b of the spec, open until
there are real users to measure.

### Settled

- **Threshold 200**, with the held-out guard.
- **The Settings line ships in v1.** Not for the state or the date, but because **it carries the
  revert control**: we own this optimizer alone, and without a student-facing way back to the
  defaults, a bad fit in the field needs an app update to undo.

Aedwon: **"okay proceed with that"**.
