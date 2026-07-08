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
