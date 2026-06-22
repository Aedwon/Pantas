# Execution dispatch log

Decisions made while dispatching the plans in `2026-08-03-execution-pipeline.md` to
implementors. Chronological. Later entries append; they never edit earlier ones.

---

## 4 August 2026: the first dispatch wave stalled on a permission boundary

**What happened.** Seven agents were dispatched in one go, one git worktree each, following
the pipeline's tier assignments: `content-seed-delivery` (P), `foundations-01` Task 4 (F),
`foundations-02-app-check` (P), `offline-posture` (P), `study-01-foundations` (P),
`home-02-assessment-attempt-row` (F), and Mathematics `real-imaginary-numbers` (F).

**Every one of them failed the same way, and none of them wrote a line of the plan.** The
`gemini-implementor` agent definition tells each agent to run
`agy --dangerously-skip-permissions`. The harness refused it, on the stated grounds that
launching Gemini with that flag creates an autonomous coding loop with shell and file access
and **no user message authorized that specific flag.**

Verified separately, because the agents' own reports were not enough to tell which layer was
refusing:

- `agy` runs fine from the orchestrator, and `gemini-3.1-pro-high` is in `agy models`.
- Without the flag, Gemini's own permission layer auto-denies `write_file` in headless mode:
  *"a tool required the write_file permission that headless mode cannot prompt for, so it was
  auto-denied."* So the flag is not decoration. Without it the tier split produces nothing.

### What I got wrong

**I dispatched seven agents before proving the dispatch mechanism worked at all.** A single
throwaway `agy` call would have found this in under a minute and cost one request. Instead
seven agents each cold-read their plan, wrote a Gemini prompt, and died at the same line.
Section 6b of the resourcing doc is about exactly this class of waste and I added to it.

### The options put to Aedwon, and their costs

| Option | Cost |
|---|---|
| **Scoped allow-rules** in `~/.gemini/antigravity-cli/settings.json` | Narrower than the flag and it persists, so later dispatches just work. But it is still a standing grant on his machine, and the rule syntax would have to be found by trial. *Recommended at the time.* |
| **Authorize the flag** for this run, worktree-isolated | Gemini auto-approves every tool call including shell. Blast radius is one worktree per agent, never the main checkout. It is what the agent definition already assumed. |
| **Drop Gemini, run the plans on Claude** | Works, and it is the 210-task load the resourcing doc measured as larger than the thing that already burned a full week of Pro quota by Tuesday. |
| **Aedwon runs `agy` himself** | No permission question at all, and he is back in the loop for all 46 plans. |

### What he chose

**Authorize the skip-permissions flag.** Selected from the options above; he added no note.

**So the recommendation was not taken, and the record should say so.** The scoped-rules option
was recommended for being narrower; he took the broader grant, which is also the faster one and
the one the tooling was already built around.

Re-verified after the decision: `agy -p ... --dangerously-skip-permissions` now writes files
successfully.

### Two findings from the stall, worth keeping

- **`app_database.schemaVersion` is 14 today.** `study-01-foundations` hard-expects 14 and
  stops otherwise; `content-upgrade-seeder` and `passage-pipeline` both read the live value and
  add one. So study-01 has to land **before** the other two, or two of the three stop. This is
  the collision map's `schemaVersion` row biting for real.
- **A killed run left partial work** in `.claude/worktrees/agent-a22d3d5ddf2a5a2a9`: modified
  `lib/app/bootstrap.dart` and `pubspec.yaml`, plus a new
  `test/core/content/bundle/content_asset_test.dart`. Unverified, from an interrupted run.
  Neither merged nor deleted, pending his call. The main checkout stayed clean throughout,
  which is the thing worktree isolation was adopted to guarantee.

---

## 4 August 2026, 02:45: the first five runs, and why three of them stalled

Dispatched directly with `agy`, one worktree per plan, all branched from `main` at `6e7937a`.
Not through the `gemini-implementor` subagent: that route is dead, see the entry above.

| Worktree | Plan | Tier | Result |
|---|---|---|---|
| `seeddelivery` | content-seed-delivery | P | **Complete.** 2 commits, nothing uncommitted, printed a FINAL REPORT. |
| `mathriq` | Mathematics `real-imaginary-numbers` | F | **Complete.** 1 commit, 15 questions, validator 0. |
| `study01` | study-01-foundations | P | **Stalled.** 4 commits, 8 files uncommitted. Step 0 confirmed schema 14. |
| `offline` | offline-posture | P | **Stalled.** 2 commits, 7 files uncommitted. |
| `obs04` | foundations-01 Task 4 | F | **Stalled.** 0 commits, 19 files uncommitted. |

### The stall has one cause and it is fixable

**Gemini launches long-running commands in the background and then idles waiting for them.**
The logs are almost entirely lines like *"`flutter test` has been launched in the background
(task-316). I will wait for it to complete."* `agy` print-mode then ends with the work
half-done and uncommitted. `obs04` did this eleven times in a row against the same six test
files and never committed anything.

**The fix, for every future prompt:** *"Run every command in the FOREGROUND and wait for it to
finish. Never launch a command in the background or with `&`."* This was not in the prompt
files and it should have been.

### What I got wrong, again

**I let five run at once.** Aedwon's correction was blunt and correct: *"i'm telling you
dispatching many at once burns a lot of tokens."* I had read his *"my 5 hour gemini limit is
only at 20% now"* as headroom being offered and was creating six more worktrees when he
stopped me. Those six were removed before anything launched. The standing rule is now **two at
a time**, and never more in flight than can be verified and merged in the same window.

### Deferred, by his instruction

*"it's 0 now, don't kill them. resume in 4 hours 13 mins from now."* So nothing was killed and
nothing new was dispatched. A one-shot job is scheduled for 06:56 PST to verify and merge the
two complete worktrees, then resume the three stalled ones rather than re-dispatch them cold.

### One thing to check at resume, not assumed now

`mathriq` wrote **15** questions and also edited the Done column of its own plan. The manifest's
target for that row was not confirmed against the delivered count. 15 may be short, and a plan
marking itself done is exactly the kind of claim that needs checking rather than relaying.
