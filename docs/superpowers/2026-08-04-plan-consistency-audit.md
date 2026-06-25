# Plan consistency audit, 4 August 2026

**A holistic pass over all 89 plans after a day of design rounds**, looking for contradictions,
stale claims, holes and things two plans both believe they own. Every finding below was fixed in
the same pass, and every one was found by checking the tree rather than by reading a plan's own
description of it.

---

## The serious ones

### 1. Three plans would have set the schema to a number already taken

`study-01-foundations` merged today and took `schemaVersion` from 14 to **16**.

| Plan | Claimed | Would have happened |
|---|---|---|
| `quiz-tab-01-storage-and-content-fields` | Sets it to **12** | **Regresses the schema from 16 to 12.** It compiles, and every existing database is then newer than the code opening it. Its table and migration branch **already exist**, so the step was redundant as well as harmful |
| `custom-track-a` | Expects exactly **15**, stops otherwise | Stops for the wrong reason. Study 01 landed and went to 16, so the dependency it is checking is satisfied while the check says it is not |
| `custom-track-b` | Expects exactly **16** | Would proceed and take 17, colliding with the two plans queued ahead of it that also bump |

**Fixed with one pattern everywhere: read the live value, take `current + 1`, and confirm the
dependency by its tables existing rather than by a version number.** Numbers are no longer
written into plans, because this is the second time they have rotted.

### 2. Home 4 and Home 5 would both have written the same provider

`home-04` said "check whether Plan 5 has landed and reuse it rather than writing a second
ranking". **The pipeline ran 04 and 05 in parallel.** Both check at the same moment, both find
the other absent, and **both write a ranking of the weakest topics.**

That is exactly the failure the collision map names: Home calls a topic weak while Progress calls
it strong.

**Fixed:** Plan 5 is the sole owner, Plan 4 waits on it and stops if it is absent, and the
pipeline's Home order is corrected to `01 → 03 → 05 → 04, 06`. **"Write a temporary one" is
explicitly forbidden**, because a temporary ranking is how two rankings ship.

### 3. Two plans gate a third of the queue and neither said so

Nothing anywhere recorded that these two are the highest-leverage work available.

- **`onboarding-flow-and-new-steps` Task 1** creates the exam date with its precision. **Eight
  plans read it.** The study plan and paywall 02 stop dead without it, and today the stored date
  is a bare value with no precision at all, so anything printing a countdown is either blocked or
  inventing one.
- **`settings-01-the-kit`** adds five type sizes that do not exist. **Four plans stop and say
  so** without them.

**Fixed:** both plans now state what waits on them, and the pipeline gained a "Part 3b: the two
that unblock everything else".

---

## The stale ones, all made stale by today's merges and rounds

| Plan | Claimed | Now |
|---|---|---|
| `study-05-endings` | The day-finished ending cannot fire, because the study plan's providers throw | The study plan computes a daily lesson count. **The ending becomes reachable**, and the plan needs no change: the case, the widget and the copy were built for this. One line at the call site, done by whichever plan lands second |
| `study-04-reader` | There is no plan to be "2 of 3" of | There is. The counter reads **"2 of N"** and the rail has N marks |
| `home-04-up-next` | The chain is not built, because the reader cannot draw a counter | It can. The count is a parameter and never three |
| `study-01-foundations` | Unexecuted | **Merged.** Marked so nobody runs it twice |
| `2026-05-21-study-plan-plan` | The plan of record | **Superseded**, and marked. It builds the mastery curve that was cut |

---

## What was checked and found sound

- **`entitlementProvider`.** Offline posture created the cached-wins rule and merged; both
  paywall plans say explicitly not to touch it. **No conflict.**
- **`InkTableRow`.** Nineteen plans reference it; one creates it and it already exists.
- **Progress's "Your pace" against the study plan's pacing.** They say different things **on
  purpose**: Progress describes the rate the student is actually going at, the plan prescribes
  the rate that finishes in time. Both honest, both from the same lesson counts. Recorded in the
  spec so a later reader does not "fix" one into the other.
- **The mock's three new plans** carry their prerequisites as stop conditions.

---

## Left open, deliberately

1. **ACET's aptitude timing is derived from a rate, not published**, and MSU-SASE's single block
   came with "apparently". Both are in the mock spec's Open list. **They print to a student
   before they commit hours**, so they block their own blueprint and nothing else.
2. **The importer and the dev seed builder convert the same YAML twice, in two places.** Named in
   the content passes plan rather than fixed there. Two converters is how they drift.
3. **The 1.6px plate rule is not a text style and no component owns it.** Assigned to the kit
   plan, since every screen blocked on the type sizes needs it too.
