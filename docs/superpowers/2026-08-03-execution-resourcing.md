# Execution resourcing: who runs what, and the road to beta

> **Routing updated 22 August 2026.** Codex now owns triage, design,
> integration and final verification. The current Antigravity defaults are
> Gemini 3.7 Flash High for settled bulk implementation and Gemini 3.1 Pro High
> for settled high-risk implementation and Flash verification. Older model names
> below record the original 3 August decision.

**Created 3 August 2026**, answering a direct question from Aedwon: given a Claude Pro
subscription at 44% of the week with the session near its cap, and a Google AI Pro
subscription covering Gemini 3.6 Flash and 3.1 Pro through the Antigravity quota, which model
should execute the 46 unexecuted plans?

**This document decides that. It does not change any plan.** The execution order stays
`2026-08-04-execution-pipeline.md`; this says who runs each part of it and what gets cut to
reach a beta.

---

## Section 1: The decision, and the number behind it

**Gemini executes the plans. Claude designs, rules and verifies.**

**The decisive measurement is Aedwon's, not a model's estimate.** Planning from the Home round
through 3 August, roughly 46 plans of writing, consumed **100% of a weekly Claude Pro quota by
Tuesday** following a Saturday 2 pm reset.

Execution is **210 tasks**, each a read, write-test, run, read-failure, write-code, run-gates
loop. Implementation is more tool-call-heavy per unit of output than planning, not less. The
work is therefore larger than the thing that already exhausted a week.

**What is honestly not known:** there is no reliable per-task token figure for Claude on this
codebase, and none is invented here. Section 1 of the Progress spec forbids printing a number
this project did not measure, and that rule binds this document too. The direction is not in
doubt; the magnitude is unmeasured.

## Section 2: Why these plans suit a fast model

This is the return on the 3 August readiness sweep and it is the reason the decision is
available at all.

Every plan carries the actual test code, the exact interfaces, the exact file paths, and
verification commands with expected values. All 47 open with a model-agnostic preamble that
names no harness-specific skill. `SUBAGENTS.md` carries the contract a dispatched run works
under.

That is the profile a cheap fast model executes well: **high volume, low judgment,
mechanically verifiable.**

**The risk is not capability. It is that a fast model which finished something wrong looks
identical to one that finished it right, until someone checks.** The whole of Section 4
exists because of that.

## Section 3: The split

### Gemini 3.6 Flash: the bulk, roughly 150 tasks

Widget trees, copy, layout and tests against a spec that already decided everything.

| Thread | Plans |
|---|---|
| Settings | 01, 03, 04, 05, 06 |
| Home | H1, H3, H4, H5, H6 |
| Study | S2, S3a, S3b, S4, S5 |
| Quiz | Q2, Q3, Q4, Q5, Q6 |
| Progress | G1 to G6 |
| Onboarding | polish (9 tasks), flow and new steps |

### Gemini 3.1 Pro: roughly 30 tasks where a wrong answer is expensive to detect

| Plan | Why it is not Flash work |
|---|---|
| `foundations-01-observability` | It is the thing that catches everyone else's mistakes. Build it wrong and the next 40 plans fail silently. |
| `content-upgrade-seeder` | A migration that touches progress rather than content is data loss, found by a student. |
| `study-01-foundations`, `custom-track-a`, `custom-track-b` | Schema migrations. A version raised without its migration compiles and is broken, and that has already happened here once. |
| `quiz-tab-02b-session-panel` | Selector wiring, nine tasks, and the plan that must make the session builder read what Settings writes. |
| Anything touching `lib/core/sync/` | Silent failures reach a student's own data. |

### Claude: a short list, and the quota is held for it

1. **The three design rounds** in `2026-08-03-next-rounds.md` Part 1. Judgment work, and it is
   what stalls everything downstream.
2. **The money path.** The paywall plan does not exist, the Pro specimen fallback is
   undesigned, and `RevenueCatGateway` is a stub that returns Free from `purchase()`. A wrong
   entitlement rule takes Pro from someone who paid for it.
3. **Verification of every merge.** See Section 4.
4. **Any plan where an implementor hits a "stop and say so".** Six plans carry one
   deliberately, and a fast model is exactly the kind most likely to invent past it.

## Section 4: Verification is not optional and it is cheap

**Reading a diff and a gate log costs a fraction of generating the code.** That asymmetry is
what makes the whole split work.

**The evidence that it is needed is already in this repository.** The first background
implementor run wrote outside its worktree, leaving a half-applied `app_database.dart` in the
main checkout with `schemaVersion` raised and no migration: a broken state that compiled. Its
final report also claimed zero new analyzer issues when there were nine.

**So: never merge on an agent's own report.** Run the gates yourself and read the output.

```bash
flutter test
flutter analyze                              # expect ~25; the invariant is zero under lib/
dart format --output=none --set-exit-if-changed lib test
dart run tool/check_layering.dart            # expect 7
dart run tool/check_no_ai_attribution.dart   # expect 0, and it reads commit messages
```

## Section 5: The beta cut, honestly sized

**There is no shortcut hiding here.** A beta is roughly **160 of the 210 tasks**, not 50. That
was looked for and it is not there. Saying so is more useful than a cut that does not survive
contact.

### Deferred out of beta

| Deferred | Tasks | Why it costs nothing |
|---|---|---|
| **The paywall and the live gateway** | not yet planned | **Run a closed beta with Pro granted to everyone.** Removes the entire money path from the critical path, and it is the single largest deferral available. |
| **Mock exams**, M1 and M2 | ~8 | Blocked on Mathematics content and on sectional timings for three exams. Deferring costs nothing that was not already waiting. |
| **Custom tracks**, A and B | 11 | Last in the queue already, and depends on two threads finishing. |
| **Notification engagement** | 4 | The daily reminder and streak save already work. |
| **Accessibility sweep**, Tasks 2 and 3 | 3 | Its Task 1 stays in: it puts the rules into the plans so new components are built right. |
| **l10n, feedback, review prompt** | 3 | Blocked on a URL and two dependency decisions anyway. |
| **Exam switching** | 2 | |

### What cannot be deferred, and one of them is not obvious

**The error boundary and crash reporting ship in the beta.** `foundations-01` is not
infrastructure polish here: **a beta without crash reporting produces no signal, which makes
it an unpaid demo rather than a test.** Today an uncaught exception shows a student the
framework error screen and nobody is ever told.

**The seeder upgrade ships too.** Without it, a content fix found during the beta cannot reach
a tester who already installed. That is the difference between a beta you can iterate on and
one where every fix needs a reinstall that destroys their progress.

## Section 6: Cadence

1. **Phase 0 first**, all four plans, since none depends on anything.
2. **Then dispatch 3 to 4 Gemini agents in parallel**, one worktree each, checking
   `2026-08-04-execution-pipeline.md` Part 4 before every pair.
3. **Verify and merge each one before dispatching its successor** in the same thread.
4. **Claude holds quota for the design rounds** and the money path.

**One thing to expect:** `lib/app/router.dart` is touched by **25 plans**. Parallel agents will
conflict there constantly. It is merge noise rather than logic error, but merge it deliberately
and never let an agent resolve a router conflict on its own.

**Content agents and code agents never conflict.** Content writes `content/` and
`assets/seed/`; code writes `lib/` and `test/`. Aedwon's question generation can run alongside
any of this.

## Section 6b: Dispatch efficiency, learned the expensive way on 3 August

Six agents ran on 3 August. What they cost, and what to do differently.

**The single largest waste was the validator.** `import_questions.dart` prints the full
converted JSON of every question under `--root`, **2.8 MB across the corpus**, and
`SUBAGENTS.md` plus all five content plans told every agent to run it after every subtopic.
An eight-subtopic run ingested that dump eight times to learn one exit code. Fixed: redirect
to `/dev/null`, read the exit code, scope `--root` to the directory being written.

**Four rules that follow:**

1. **Dispatch prompts are three lines, not three pages.** The plans and `SUBAGENTS.md` already
   carry every rule. Restating them inline pays for the same words twice.
   *"Execute `plans/X.md`, rows N to M. Follow `SUBAGENTS.md` Part 4."* is the whole prompt.
2. **Fewer, larger agents.** Every agent cold-reads roughly 900 lines of required documents
   before writing anything. Splitting Mathematics five ways paid that five times; two agents
   would have done the same work for less.
3. **Resume, never re-dispatch.** When a run stops part-way, send it a message rather than
   spawning a replacement. A new agent re-reads everything from cold.
4. **Never ask an agent for a wide diagnostic.** Give it the one command in `SUBAGENTS.md`
   Part 4 and have it paste the output.

**And one rule for whoever is verifying:** use the single content-gate command rather than six
separate shell calls. The verifier's own token cost is small per plan, and it is what makes
the whole split work, so keep it small.

- **Mathematics.** Still the only open item in Gate 0 of the launch checklist.
- **`url_launcher` and `in_app_review`.** Two tasks stop and ask on the first.
- **Whether the beta is closed or open.** The Pro-granted approach in Section 5 assumes closed.
