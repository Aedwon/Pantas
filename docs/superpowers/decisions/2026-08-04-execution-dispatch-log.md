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

---

## 4 August 2026, 06:56: the scheduled resume, two merges and two findings

The one-shot job fired as scheduled. Nothing was re-dispatched cold.

### Merged, after running the gates myself rather than reading a report

**`content-seed-delivery`.** The diff against its true base is eight files and nothing outside
the plan's remit. Gates, pasted rather than relayed: **1013 tests pass**; **zero analyzer
issues under `lib/` and `test/` outside `test/tool/`**, the invariant, with the 25 remaining
all in `tools/`; formatter reports 694 files and 0 changed; layering **7**, the accepted
baseline; attribution **OK**. Merged.

**This is the one that mattered.** Until it landed, everything authored since 25 July reached
nobody in a release build.

**Mathematics `real-imaginary-numbers`.** 15 questions. Validator exit **0**, both scoped to the
one directory and across the whole corpus. Merged.

### Two findings, one of which was mine

1. **The 15-question count was fine and the note's worry was unfounded.** The plan's Definition
   of Done says **12 to 20 questions per subtopic**, so 15 is inside the band, not short. Worth
   recording because the handoff note flagged it as a likely problem and it was not one.
2. **I reported the validator as failing at 255 when the failure was my own typo.** I ran it
   from `tool/` when the tool lives in `tools/`. Caught within a minute by reading the error
   instead of the exit code, but it is exactly the kind of thing that gets written into a log as
   an agent's fault when it is the verifier's.

**One piece of staleness found in passing, not fixed.** The Mathematics manifest still shows the
other eight `arithmetic-number-sense` rows unticked, while all nine YAML files exist on disk and
the pipeline reports 43 of 44 subtopics done. **The manifest is behind the corpus**, so it
cannot be trusted as the record of what is written. Left alone rather than bulk-ticked, because
ticking rows I did not verify would make it wrong in a more confident way.

### Resumed, not re-dispatched

`study01` and `offline`, two at a time per the standing constraint, each with its prior commits
listed so it does not start over, and each led with the fix for what actually stalled them:
**run every command in the foreground and wait for it.** `obs04` waits its turn.

### The resume failed, and it was not the prompts and not the quota

Both resumed runs exited within seconds with *"There was a network issue connecting to the
server, please try again."* Neither made a commit. Diagnosed rather than retried:

```
Error: Eligibility check failed: failed to get load code assist response:
Post "https://daily-cloudcode-pa.googleapis.com/v1internal:loadCodeAssist":
read tcp ...->172.217.114.4:443: read: operation timed out
```

Then, to separate a local network fault from a service fault:

```
google.com:          200 in 0.79s
codeassist endpoint: 000 in 931s, unreachable
```

**So the connection is healthy and Google's Code Assist backend is down.** Nothing to do with
the foreground fix, the resume prompts, or the quota window that had just reset.

**Stopped rather than retried.** Nothing further dispatched. All three worktrees keep their
commits and their uncommitted work, and `main` is clean at the two merges. The foreground fix
is still untested against a live service: it addresses the stall that was diagnosed, but it has
not yet been proven, and this log should not read later as though it had.

---

## 4 August 2026, 13:12: the foreground fix works, and two more merges

The scheduled retry ran. **The service was back**, and the earlier diagnosis was right: it had
been a Google outage, not the prompts and not the quota. Worth noting the test call took over
90 seconds to answer, so "hung" and "down" look identical from the outside and the endpoint
probe is what distinguishes them.

### The foreground fix is now proven, not just plausible

Both resumed runs **finished with nothing uncommitted**, where every previous attempt had
stalled part-way with work stranded. The single instruction that changed it: *run every command
in the foreground and wait for it, never in the background*. The earlier log entry recorded
this fix as unproven; it is proven now.

### `study01`, merged after a conflict I resolved by hand

Seven commits, `schemaVersion` at **16** with `onUpgrade` branches for both 15 and 16 present in
the same history. Gates in the worktree: **1045 tests pass**, zero analyzer issues under `lib/`
and `test/` outside `test/tool/`, formatter clean, layering 7, attribution OK.

**It conflicted with the already-merged content work** in the device preferences repository and
its test. Both sides had added keys and methods to the same file. **Resolved by keeping both and
routing the content seed version through the generic device value helpers** that arrived with
the bookmark work, rather than leaving two ways to read one table.

**One thing that cost time and is worth writing down.** After the merge the test would not even
load, and the analyzer reported nothing. The cause was **stale generated database code in the
main checkout**: it is gitignored, so a merge that moves the schema from 14 to 16 cannot bring
it, and it must be regenerated before anything will run. Nothing to do with the merge itself.

### `offline`, merged clean

Three commits. Gates green in the worktree, and the thing this plan was tier P for was checked
directly rather than taken on trust: **stream errors are swallowed so the last known entitlement
stands.** A network failure is not treated as a contradiction, so a paying student keeps Pro in
a dead zone. That is the rule, implemented correctly.

### Main, after both merges

**1063 tests pass. Zero analyzer issues under `lib/` and `test/`. Layering 7. Attribution OK.**
`schemaVersion` is 16, which unblocks the two plans queued behind it: the content upgrade seeder
and the passage pipeline now read the live value and take 17 and 18.

**`obs04` still waits**, with 19 uncommitted files and no commits. It needs a resume prompt
written the same way as the other two.
