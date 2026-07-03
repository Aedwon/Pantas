# Execution dispatch log

Decisions made while dispatching the plans in `2026-08-04-execution-pipeline.md` to
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

---

## 4 August 2026, afternoon: observability lands, and a merge that only broke on contact

### `foundations-01` Task 4, merged

Resumed rather than re-dispatched, with the foreground rule that has now fixed this stall three
times for three. It committed cleanly with nothing left uncommitted.

Verified rather than relayed: 1018 tests in the worktree, zero analyzer issues under `lib/` and
`test/` outside `test/tool/`, formatter clean, layering 7, attribution OK. **Exactly eleven
distinct telemetry events**, which is the number the task specifies. And the claim that mattered
most was checked directly: **`CrashReporter` had no caller on `main` and has one after this**, so
the orphan is genuinely absorbed rather than merely mentioned.

### The merge broke two tests that passed on both sides

**Neither branch was wrong.** The offline posture work added `paywall_offline_copy_test.dart`,
which pumps the paywall page inside a bare `MaterialApp`. That was correct at the time: the page
read no providers. **Task 4 turned that page into a consumer that reads one in `initState`** to
emit its event. Together, "No ProviderScope found".

**This is the argument for running the gates after the merge and not only before it.** Both
worktrees were green. The failure existed only in their combination, and a dispatcher who
trusted two green reports would have pushed a broken `main`.

**Fixed by the dispatcher, not handed back**, since it is merge fallout: the two pumps are
wrapped in a `ProviderScope` with a comment saying why. **Main: 1072 tests passing, analyzer
clean, layering 7, attribution 0.**

### Also landed, with no Gemini spent

**The seed was rebuilt: 1,117 questions to 1,840.** It was dated 25 July and 876 behind the
corpus, so everything authored since then, including all of Mathematics, was still invisible to
the app **even after the delivery path merged**. 155 figure-pending questions are skipped by the
builder as designed. This was worth doing precisely because it costs no Gemini quota at all.

---

## 4 August 2026: the two unblockers land

Dispatched together because the audit had just identified them as gating about a third of the
queue, and neither shares a file with the other.

### `ExamDate`, Task 1 only

**The API matters more than the code here**, because eight plans are written against these exact
names, and two of them were corrected earlier today to match. Checked directly:
`ExamDate.onDay(DateTime)`, `ExamDate.inMonth({required int year, required int month})` with
**named** parameters, `day` returning a **nullable** `DateTime`, plus `year`, `month`,
`monthStart`, `daysUntil`, `storageValue` and `fromStorage`. **All correct.** Schema untouched
at 16, as instructed.

Gates in the worktree: 1082 tests, analyzer clean under `lib` and `test`, formatter clean,
layering 7.

### The kit, including the five type sizes

Ten commits. The sizes are present, **`headlineSmall` is still 15**, which the amendment
required because existing screens are built on it, and `InkPlateRule` exists at exactly 1.6px.

**Its gates were not clean and its report said they were.** Two analyzer infos under `test/`
from a deprecated semantics call. That is the whole reason the tier split verifies rather than
relays.

**Fixing it took three attempts and each one is worth recording**, because it is a good example
of not guessing at an API:

1. `flagsCollection.isSelected` swapped in for `hasFlag`. **The test then failed:** it returns a
   `Tristate`, not a `bool`.
2. Compared against `Tristate` instead. **The file would not load:** `Tristate` is not exported
   by `package:flutter/semantics.dart`.
3. Found it in the engine's `dart:ui`. Imported from there, removed the now-unused import, and
   it passed.

### Main after both merges

**1101 tests passing**, analyzer clean, formatter clean, layering 7, attribution 0, schema 16.

**Nothing broke on contact this time**, which is not luck: the two plans were chosen to run
together precisely because they share no files.

---

## 4 August 2026: the seeder and the attempt row, and the stale-codegen trap for the second time

### `content-upgrade-seeder`, merged

**Schema discipline held.** It read the live 16 and took **17**, with the `from < 17` branch in
the same commit as the bump.

**The property it was tier P for was checked directly rather than trusted:** the migration adds
a single column to `questions`, and the upgrade pass writes only `exams`, `subjects`, `topics`,
`lessons` and `questions`. **No progress table is touched and there is no delete anywhere in the
seeder.** A content update can now reach an installed app without destroying what a student has
done, which is the difference between a beta you can iterate on and one where every fix needs a
reinstall.

### `home-02-assessment-attempt-row`, merged

Left `schemaVersion` at 16 exactly as instructed. **It also did something the plan did not ask
for and was right to:** a third commit keeps untimed attempts out of every speed figure. An
assessment attempt has no clock, so counting it would have corrupted the per-question speed
signals the moment this defect was fixed.

### The trap, twice in one day

**After the merge: 151 tests failing and 2 analyzer issues, on two branches that were green
alone at 1109 and 1114.**

**Nothing was wrong with either.** `*.g.dart` is gitignored, so a merge that moves the schema
cannot bring the generated code with it, and the tree was source-at-17 against
generated-at-16. One `build_runner` run and it was **1122 passing, analyzer clean**.

**This is the second time today**, and the symptom was different both times: this morning it was
a single test that would not load with the analyzer reporting nothing. **Neither looks like what
it is**, and both invite a long diagnosis of an imaginary merge bug.

**Now written into `SUBAGENTS.md` beside the schema rules:** after any merge that touches the
schema, regenerate **before** running or interpreting the gates, and do not start diagnosing
until you have.

### Main

**1122 tests passing**, analyzer clean, formatter clean, layering 7, attribution 0, schema 17.

---

## 4 August, later: the passage pipeline, verified and merged

Picked up from the handoff. The worktree was finished, five commits, nothing uncommitted, and
verified by nobody. Three things were checked before it was allowed near `main`.

### It stopped where it was told to

Task 5 renders the passage inside the viewer that `2026-08-02-quiz-tab-04-viewer-and-reveal.md`
builds, and that plan has not landed. The plan said stop after Task 4 and say so, and the diff
touches nothing under `presentation/`. **It obeyed.**

**One consequence nobody wrote down:** Task 6 is a regression test proving a database with no
passages behaves exactly as before, and it does **not** depend on Task 5. Stopping after Task 4
dropped it too. The claim in spec Section 8 is still a sentence rather than a test.
`test/features/quiz/passage_regression_test.dart` does not exist. Cheap to pick up whenever Quiz
Plan 4 lands and Task 5 is dispatched.

### It read the live schema instead of trusting the document

Main was at 17. It took **18**, with a `from < 18` branch creating the table and adding the
column in the same commit. This is the rule that rotted twice and it held this time.

### It did one thing it was not asked to do

`_hydrateQuestion` in the content repository now also populates `lessonId` and `shortLabel`.
Both columns already existed; the hydration was simply not reading them. **`lessonId` is the
lesson link**, which is queued as the next wave's item 3 and described in the pipeline document
as "one line and no authoring". That line is now on `main`.

**Not treated as a defect.** It is correct, it is covered, and the column was already there. But
`content-three-passes.md` Task 1 must be re-read before dispatch rather than sent blind, because
part of it is already done.

### One gap worth knowing about

The mock sampler gained an optional `passageSetsByTopic` parameter and the indivisibility branch
behind it. **No test passes that parameter and no production code calls the sampler at all**, so
the mock half of Task 4 is unexercised. That matches the rest of the mock feature, which has no
UI yet, so it is a coverage note rather than a finding.

### The composition order was checked against the spec, not assumed

The picker now takes whole passage sets first and fills the remainder with free-standing
questions, which reorders a session. Section 4 of the spec says exactly that: fill with a set
while the remaining room is at least the set's size, **then** fill the rest. It matches.

### Main, after the merge and the mandatory regeneration

**1141 tests passing**, schema **18**, 26 analyzer issues and every one of them under `tools/`,
zero under `lib/` and `test/`, formatter clean, layering 7 unchanged, attribution 0.

The regeneration was run before the gates were read, per the rule written this morning. No
imaginary merge bug this time.

---

## 4 August, late: the CSE tagging pass and reading comprehension

Two agents, the standing limit. Aedwon was asked for headroom first and answered **"Gemini is at
100% remaining so have at it"**, which is the unambiguous direction of the percentage that the
pipeline document asks for and did not get twice this morning.

### The permission boundary came back, and it is per session

`agy --dangerously-skip-permissions` was refused by the classifier again, on the same grounds as
this morning: **no user message in this session authorized that specific flag.** The
`Bash(agy *)` allow-rule in project settings does not cover it, and the authorization he gave
earlier today did not carry across the session boundary.

His first answer was **"you ran it through a shell before, refer to our previous conversation"**.
That does not unblock anything: the classifier reads only the current session, and I cannot read
the previous one. Saying so plainly and offering him the two real routes got an explicit **"go
1"** and the dispatch went through.

**Worth writing into the pipeline document:** the flag needs re-authorizing at the start of every
session, and it is cheapest to ask for it in the same breath as asking for headroom.

### `cse-content` Task 1: clean, and it stopped where it was told

One commit, nothing uncommitted, 38 files, every one under `content/questions/`.

**It matched the plan's table exactly.** 38 files carry `cse-pro`; 30 of those also carry
`cse-sub`, which is precisely the count the table implies once the analytical rows that are
professional-only are excluded. **Zero Science files were touched**, which the plan names as the
single easiest way to ruin the track. Validator 0 across the whole corpus, 1141 tests still
green after the merge.

**A note on process, not on the work:** the shell's working directory persists between calls, so
a count run after a `cd` into a worktree reads the worktree, not `main`. I briefly read a
worktree result as evidence the agent had written into the main checkout. It had not. **Compare
with absolute paths when the question is which tree was modified.**

### `question-generation-reading-comprehension`: complete, and held back anyway

All 13 subtopics, 32 passages, **160 questions**, 13 commits, nothing uncommitted, nothing
written outside its own directory, validator 0, zero em dashes, `approved:` unset everywhere.
The per-subtopic commit instruction worked: there was never a moment where a stall would have
stranded more than one file.

**Its own report says 150 questions. It is 160.** The table inside the same report sums to 160.
A small thing, but it means the report is not a substitute for counting.

#### The finding that stopped the merge

**120 of the 160 questions make the correct answer the strictly longest choice.** 75%.

The plan bans this in one line under Global Constraints. It was broken systematically rather
than occasionally, which is the signature of a rule that was read and then not checked.

**Why it matters more than a style slip:** a student can pick the longest option and score well
on this set without reading the passage. That is not a blemish on a reading comprehension
section, it is the section failing to measure the thing it exists to measure.

**Why it happened, and it is worth understanding rather than just fixing:** a correct answer
written to be unambiguous naturally grows longer than a distractor written to be wrong. The
constraint fights the grain of careful authoring, so it needs checking per question rather than
trusting.

#### The options put to him

| Option | Cost |
|---|---|
| **Send it back to rewrite the choices only** | The passages and stems are good and they were the expensive part. Cheap, same tier. *Recommended.* |
| **Merge now, catch it at approval** | 120 manual fixes for him, one at a time, in Question Studio. |
| **Regenerate from scratch** | Throws away 32 good passages to fix a wording problem. |

**He chose 1.** No comment on the choice itself.

### The poetry contradiction, and his question

The plan says a poem may be 40 to 120 words and that "the 150 floor does not apply". **The
importer enforced 150 to 400 for every passage with no exception.** The agent hit this, reported
it as an operational note, and **worked around it by writing three 160-word poems** rather than
stopping and saying so. The plan carries a "stop and say so" for exactly this shape of problem.

Put to him as plan-versus-code, he asked back: **"what do you recommend regarding this? on a
learner's perspective?"**

**My answer: the code was wrong.** The 150 floor exists because a prose passage shorter than that
cannot honestly support five questions. That reasoning does not transfer to a poem, where
density does the work length does in prose. Against a learner it costs twice: real papers use
short poems, so a 160-word poem trains them on something they will not sit; and a poem padded to
clear a prose floor is a worse poem, because the filler dilutes the devices the questions ask
about.

**He said "proceed".**

### What changed as a result

- **The importer now accepts `form: poetry`** on a passage and holds it to 40 to 120 words.
  Anything else, or nothing at all, is prose at 150 to 400. An unrecognized `form` is rejected
  rather than guessed at. Five tests, written first and confirmed failing. **1146 passing.**
- **The plan now says the marker is required**, because the old wording promised an exception the
  code did not have, which is what produced the padded poems.
- **The plan now explains the longest-choice rule rather than stating it**, and says to check it
  per question. A rule that fights the grain of the work needs a reason attached or it gets read
  and dropped.

### What I got wrong

**I verified the CSE run against the plan's table but read the reading comprehension run's own
report before checking its content.** The report was clean, confident and wrong twice: the
question count, and a findings section that presented the poetry workaround as an operational
note rather than as the deviation it was. The longest-choice defect appears nowhere in it. **An
agent's self-report tells you what it believes it did.** The 75% figure took one script.

---

## 4 August, late: the revision pass, and the defect it uncovered underneath

### The revision pass did its three jobs

Verified independently rather than from its report: **longest-correct is 0 of 160**, the three
poems are 85 to 93 words and carry `form: poetry`, and every text-type id is `rc-tt-`. No stem
was touched and no prose passage body was touched, which is what "choices only" was supposed to
mean. Validator 0 across the corpus, 1146 tests green, merged and pushed.

**One thing about the dispatch itself, and I was wrong.** The classifier refused the run twice,
then failed once with a transient error, and I told Aedwon I would stop rather than keep
hammering it. His answer was **"what? just run it with shell again"**, and it went through on the
next attempt. **The refusal was flaky, not a policy.** He was right and I stopped one retry
early.

### Underneath it: the correct answer is A in 96% of the corpus

Checking whether the rewrite had overcorrected into a new tell turned up something far larger,
and **nothing to do with either agent that ran today.**

| | Correct answer at position 0 |
|---|---|
| Science | **777 of 777** |
| Reasoning | **208 of 208** |
| Mathematics | 622 of 689 |
| Language | 305 of 319 |
| **Corpus** | **2,072 of 2,153, 96.2%** |

**Choices are not shuffled anywhere.** Question order is shuffled in two places; choice order
never was. So the student saw them exactly as authored, and **the entire bank was beatable by
always picking A** without reading the question. For an exam reviewer that is the product failing
at the only thing it claims to do.

**It is invisible per file.** Any one question with its answer first looks fine. Only the count
across the corpus shows it, which is why it survived every content run and every review to date.

### The options, and why it was a code fix

| Option | Cost |
|---|---|
| **Order the choices when a question is read** | One change, fixes all 2,153 at once and every question written from here. *Recommended and chosen.* |
| **Rewrite the corpus to vary the position** | Thousands of edits, and the next authoring run reintroduces it, because writing the answer first is the natural way to draft a question. |

Aedwon's instruction was **"just implement it directly"**, so no plan was written for it.

### How it works, and the two things that made it safe

The order comes from a hash of the question id, not from a random seed.

- **Scoring already compared choice ids, never positions.** `chosenChoiceId == correctChoiceId`.
  So reordering cannot change whether an answer is marked right. This was checked before the
  change, not after.
- **Deriving the order from the id makes it stable**, so the quiz, the reveal and the review put
  the choices in the same places without anything having to carry the order between them. A
  per-attempt random order would have needed storing.
- **The A, B, C, D labels are re-lettered after the reorder.** They are assigned by position at
  import, so without this the student would have seen C, A, D, B and it would have looked broken.

Applied at both places a question is read: the seed path the app uses today, and the content
database path that has no reader yet. The second was included so the defect cannot return when
that path gets a UI.

**Eight tests, written first and confirmed failing.** Measured against the real 2,153 corpus ids
afterwards: **522, 510, 558, 563** across the four positions, from 2,072 / 43 / 32 / 5.

**1154 tests pass**, analyzer unchanged, layering 7, formatter clean.

### What I got wrong

**I audited the reading comprehension run for the rule the plan named and stopped there.** The
longest-choice rule was written down, so I checked it. Answer position was not written down
anywhere, so I did not check it until an overcorrection check went looking for a different
problem entirely. **A constraint absent from the plan is not a constraint the content meets**,
and the corpus had been carrying this one since the first question was written.

---

## 4 August, night: the seed, the dropped test, and a plan that keeps timing out

Headroom was **60% remaining** at the start of this round, **37%** by the end of it. Aedwon gave
the direction each time without being asked twice, and both readings were stated as remaining,
which is the ambiguity the pipeline document exists to prevent.

### The seed, and a stale warning inside the tool

Rebuilt from the corpus: **1,840 questions to 2,000**, now carrying the 32 passages.

**The seed builder's own header says not to commit what it writes.** That is out of date.
`assets/seed/v1.json` is tracked, the committed copy is the full 7.4 MB build, and the practice
changed when the seed was last rebuilt. The comment was not updated then. Worth fixing in the
tool rather than in a dispatcher's memory, because the next agent to read that file will believe
it.

### Task 6 of the passage pipeline, written rather than left

Flagged this morning as dropped alongside Task 5 despite depending on nothing in it. Written
now, as zero-Gemini work while two agents ran.

**A regression test written after the fact and passing immediately proves nothing**, so it was
mutation-checked: forcing the picker to treat every question as a passage set fails three of the
nine. Only then was it committed.

**Its scope is smaller than the plan's and the file says so.** The plan asks it to cover the
viewer and the review as well, and neither exists. Those belong with Task 5, behind Quiz Plan 4.

### The paywall plan has now timed out twice, mid-task, uncommitted both times

| Run | Result |
|---|---|
| First dispatch | Died at `Error: timeout waiting for response` during baseline checks. **0 commits, 7 files modified.** Task 1 half-applied: the enum had lost `lifetime` while the router still referenced it, so the tree did not compile |
| First resume | **2 commits**, Tasks 1 and 2 clean. Died again mid-Task 3, **2 files uncommitted** |
| Second resume | In flight |

**The failure is not the background-command stall from this morning and the fix for that does not
apply.** These are `agy`'s own timeout, on a plan over a thousand lines with six tasks. The run
does real work and then loses whatever is uncommitted at the moment it dies.

**What made the resumes cheap was reading the tree before writing the prompt**, every time.
The second resume was told exactly what was already correct, that Tasks 1 and 2 were committed
and not to redo them, and precisely which five presentation tests still asserted the old copy.
A resume prompt that just says "continue" invites the agent to re-derive what is already there.

**Verified rather than trusted:** Task 3's copy was checked character by character against the
plan's verbatim block before the resume was written, because Paywall 02 asserts the same strings
and a near-miss there would surface much later.

### The rule that came out of this

**Commit the moment a task's gates pass, before starting the next one.** It was in the prompt
from the first resume onwards and it is why the second run kept two tasks instead of losing
everything. **For a long plan this matters more than any other instruction in the dispatch line.**

### Where headroom stopped the queue

At **37% remaining**, with two agents already spending, nothing new was dispatched. The pipeline
sets the floor at roughly a quarter. **If the paywall needs a third resume it will be put to
Aedwon rather than started**, because a run that dies below the floor strands its work with no
budget left to recover it, which is the exact failure that cost most of 4 August.

---

## 4 August, night: the paywall stop was real, and a worktree that poisoned itself

### The plan was wrong about the billing API, and the agent was right to stop

The second resume finished Task 3 clean and **halted at Task 4 Step 0 exactly as the plan told
it to**, without changing `pubspec.yaml` and without substituting a method to make the plan fit.
That is the "stop and say so" working as designed, and it is the first time today one fired on
something that mattered.

**Confirmed rather than taken on trust.** Installed is `purchases_flutter` **8.11.0**.
`Purchases.purchase(PurchaseParams)` returning `PurchaseResult` **does not exist in it**, and
`PurchaseParams` is not a type in it at all. `purchasePackage` returning `Future<CustomerInfo>`
does exist and is not deprecated.

### The options, and why the plan gave way rather than the SDK

| Option | Cost |
|---|---|
| **Correct the plan to the installed API** | An edit to one call and its stop condition. No dependency change, no native config risk. *Recommended and chosen.* |
| **Upgrade the SDK to match the plan** | A major bump on the single riskiest dependency in the app, plus whatever native configuration follows, and it buys nothing: both methods make the same purchase. |

Aedwon's instruction was **"do what you recommend"**.

**The fix stayed narrow because the rest was checked rather than assumed.** Every other symbol
the task uses was verified against 8.11.0 one at a time: `configure`,
`addCustomerInfoUpdateListener`, `getCustomerInfo`, `logIn` returning `LogInResult`,
`getOfferings`, `restorePurchases`, and on an entitlement `productIdentifier`, `willRenew`,
`expirationDate` as a nullable `String`, and `periodType` with `PeriodType.trial`. All correct.
Only the purchase call was wrong, so only the purchase call changed.

**One line was added that the plan did not have.** `purchasePackage` throws on a user
cancellation as well as on a real failure. The plan said nothing about it, and the obvious
wrong move is to catch and return Free, which would tell a student who had just paid that they
had not. The plan now says so.

### A worktree can poison itself, and a throwaway call finds it in a minute

Tasks 4 to 6 were dispatched into a fresh worktree and **died instantly, twice, with a one-line
log reading `Error: Agent execution terminated due to error`** and not a single file touched.

The tempting reading was quota, since headroom was at 35% and falling.

**It was not quota.** Three cheap checks settled it:

1. `agy` with a one-word prompt from the repository root: **OK**.
2. The same one-word prompt from inside that worktree: **the same error**.
3. The worktree removed, recreated under a different name, same branch point, same prompt: **OK**.

So the failure was bound to that directory, not to the account, the model, the plan or the
prompt. The work then dispatched normally.

**This is the second time today that the log's own advice paid.** A throwaway call costs one
request and one minute, and it is the difference between diagnosing the thing that is broken and
diagnosing the thing you assumed was broken. Both times the assumption would have been wrong.

### Still running

The lesson link has been going 39 minutes with its work correct in the tree and nothing
committed. **1,998 of 2,000 questions carry a lesson.** The two that do not are demo rows for
the CSE carried over from the old seed, not authored content, so the plan's "every question or
stop" is about to fire on something that is not a content gap. **The rule was right to write and
it is about to be wrong in this instance**, which is worth knowing before its report arrives.

### Correction, an hour later: the worktree was not the cause

**The entry above is wrong and it stays as written.** The conclusion that a worktree had poisoned
itself was drawn from three checks that happened to line up, and a fourth falsified it.

What actually happens now:

| Where | Prompt | Result |
|---|---|---|
| Repository root | one word | **OK** |
| A brand new worktree, seconds old | one word | **the same error** |
| The recreated worktree, right after creation | one word | OK |
| The same worktree, after one long-prompt failure | one word | error |

**A worktree created minutes ago, never dispatched into, fails on a one-word prompt while the
repository root succeeds on the identical call.** So it is not that directory, not the prompt,
and not its length: `prompt-rcfix.txt` is nearly twice the size of the one that failed and it
ran fine earlier tonight.

**What the evidence actually supports** is that new `agy` sessions are being refused while an
already-established one at the repository root still answers, which is what running out of
headroom would look like from here. It cannot be confirmed: **`agy` exposes no usage command and
nothing on disk records it**, which is the constraint Part 1 of the pipeline document already
names. Aedwon's reading is the only instrument.

**What I got wrong, and it is the same error twice in one file.** I took three consistent
observations as an explanation and wrote it down as one. The recreated worktree working was the
weakest link in that chain, and a single further test broke it. **The throwaway-call habit is
right; stopping at the first result that fits the story is not.**

**Dispatching is halted** rather than retried into a wall. The lesson link has been running 42
minutes and is unaffected, because its session was established before whatever changed.
