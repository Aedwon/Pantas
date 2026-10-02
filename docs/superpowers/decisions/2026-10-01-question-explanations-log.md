# Question explanations, wrong-choice notes and the question audit

Date: 1 October 2026.

## The rule

> "okay let's change that
> 1. it explains why the correct answer is correct (maybe a solution or something if solving is involved)
> 2. (Pro gated) if they got it right, it should explain why other choices are distractors and they might get tricked [this is only upon request by the user]
> 3. (Pro gated) if they answered wrong, it should first explain how to get the right answer, and then explain that their choice was a distractor, and upon request they can show why other choices are wrong similar to #2
>
> so like this is a system to increase the value of using Pro."

Lead additions, all accepted ("yes the shared explanation should only say why the correct answer
is correct and its solution", "yes", "yes exactly"):

1. The shared explanation (Free and Pro) no longer discusses any wrong choice; that moved to the
   Pro notes. Existing explanations are reworked to match.
2. Every wrong-choice note has a fixed shape: the mistake it catches, why it looks right, one
   check to avoid it next time.
3. What a Free student sees beside a miss beyond the explanation (for example a Pro teaser) is a
   design decision for Claude Design.

> "yes please do the necessary changes even to the guidelines to ensure future question
> generations follow this consistently"

**Before:** the explanation said why the answer is right and why the main distractor is wrong;
Pro saw the note for the picked choice only after a miss (quiz-tab decision, 28 July, "Add why
yours was wrong"). The style guide had no rule for the notes; 27 wrong choices lacked one.

**Unchanged:** Free sees the answer and the explanation everywhere, including the mock review
(28 July).

**Changed in this commit:** `AGENTS.md` voice rules, `docs/content/question-style-guide.md`
(explanation, required wrong-choice note and its shape, notes written to read both to the student
who picked it and in a list, no position-dependent choices because the app shuffles, ids never
renumbered, at least 20 active questions per lesson), the authoring runbook step 4, a note on each
subject blueprint, and the UI brief's Free and Pro rows for the answer reveal and review screens.
The app's reveal still shows only the picked choice's note after a miss; the on-request list of
every note is built with the UI round from Aedwon's Claude Design screens.

## Question audit and expansion

> "can you please have codex do a thorough quality audit on all the questions in the entire
> corpus? then as have it add more questions per lesson ... can we do like at least 20 per lesson?"

> "you don't need to audit its output, once codex confirms it's done then just report to me that
> it's done"

> "you may invoke codex 6.1 Sol High for this, you can run things in parallel but make sure they
> don't touch each other's work. you can run 3 at a time"

State at the start (seed on `web/roadmap-engine-r1`): 2,361 active questions, 161 active lessons,
average 14.7 per lesson, 155 lessons under 20. The three CSE vocabulary lessons (two placeholder
questions, no lesson link) are a separately scoped exam and are left out. About 1,030 questions
passed an earlier QA round (r1), mostly Mathematics and Language; this pass covers all.

Execution: Codex edits the question YAML on a content branch cut from `web/roadmap-engine-r1`,
three subject groups at a time, each in its own directory, and the importer then requires a note
on every wrong choice. Per Aedwon, the lead does not review Codex's output.

Release consequence: the protected content package (`assets/seed/content.db`, manifest,
signature) must be rebuilt and re-signed with the content signing key after this lands, so the
E09 package hashes change. Phone checks already wait for the UI connection.

## Lead rulings during the run, 2 October 2026

The run for Language, Reasoning, Reading Comprehension and General Information stopped on two gaps:

1. **Figures.** The Reasoning blueprint puts a figure on every Spatial-Abstract and
   Mechanical-Technical question, and the brief forbade figures on new questions. Ruling: a
   question with a figure the app can already draw (an existing figure kind, in the existing
   field shape, checked against its renderer) is active and counts toward 20. No new figure
   kinds, no figure-pending questions, and no prose stand-ins where the blueprint forbids them.
   A lesson that cannot reach 20 within that is reported with its count.
2. **General Information has no blueprint.** Ruling: use the style guide, the lesson, and the
   question types already in use there. No blueprint is written in this job.

## Usage reset during execution, 2 October 2026

Aedwon said:

> i used a reset

At 04:34:02 UTC, the current session record showed 87% used in the five-hour
window and 95% used in the weekly window. At 04:36:24 UTC, after Aedwon's
message, the current record showed 0% used in both windows. The same three
content workers remained live, so the orchestrator continued them without
relaunching or duplicating their assignments. The reset changes available
execution capacity; it does not change the approved audit scope, integration
permissions, or application-code freeze. Group completion and combined
acceptance remain pending.

## Persistent continuation requested, 2 October 2026

Aedwon said:

> you're about to hit limits can you set a cron to try to continue every 15 minutes, it should persist limits right

The orchestrator installed a user cron entry to attempt continuation every 15
minutes on this Mac. A process lock prevents duplicate scheduled orchestrators.
The task, worker handles, committed ledgers, and reports persist on disk; each
continuation verifies actual processes and repository state before resuming.
The schedule remains subject to the account's usage limits and requires the Mac
to be awake and connected. It introduces no paid fallback and does not expand
the existing merge, signing, scope, or application-code permissions.

The first installation attempt was interrupted by the usage limit before the
cron entry was saved. Installation and a minimal-environment CLI probe were
verified at 11:10 UTC. All prior worker passes had ended on quota errors and their
completed commits were pushed; combined acceptance remains pending. The prior
quota recognizer missed the curly apostrophe in the error text. It now matches
the limit phrase independently of apostrophe style.

## Correction: wake this existing session only, 2 October 2026

Aedwon clarified:

> not quite, you're the orchestrator aren't you? so it should "wake" this session only and have you resume operations. the expected behavior is that it will continue on with the same goal you have and if the limits are it it will just try and try until the limits are reset again. is that clear?

The earlier cron implementation was wrong: it launched a separate CLI
orchestrator. That cron was removed and its separate orchestrator was stopped.
The original desktop thread remains the sole orchestrator and retains the same
active goal. No task or goal is created, forked, replaced, or delegated by the
corrected scheduler.

The corrected wake connects to the existing app-server Unix socket and targets
only thread `01a0fab1-2cfd-7122-aca4-d54264946301`. It verifies the original goal,
skips an active turn, reads current quota, and sends a continuation to the same
idle thread when capacity is available. An unloaded copy of that same thread
may be resumed by its existing id. Pauses, budget limits, blockers, completion,
and a replaced goal are respected. Quota checks retry every 15 minutes without
a purchase or reset-credit redemption. The same-thread connection and active
turn skip were verified. At this checkpoint, corrected cron installation is
waiting on macOS's permission prompt for Terminal to administer the computer.

### Corrected wake installed after macOS approval

Aedwon confirmed the Terminal permission prompt with the exact reply:

> Allowed

The corrected same-session cron entry was then read back successfully. A probe
from a minimal cron environment connected to the existing app server, verified
the original thread id and goal, and correctly skipped the currently active
turn. The entry runs every 15 minutes and performs no worker dispatch or
separate orchestration itself. The original orchestrator resumed the three
quota-stopped content workers at 11:36 UTC after verifying fresh capacity,
terminal former handles, allowed interrupted files, and matching branch heads.
The full question audit remains in progress; combined acceptance is pending.

## Orchestration resumption and importer fixture ruling, 3 October 2026

At 00:10 Philippine time (16:10 UTC on 2 October), the resumed orchestrator
verified policy at `244d74b661c4aa5a88ddb216c29056a45dca3b75`, the four assigned
worktrees, branch identity, and matching local and remote heads. All prior worker
handles were terminal after usage-limit errors. The three groups had 127
committed lesson ledgers: Mathematics 41, Science 51, and the other subjects 35.
No group summary was committed. Science had interrupted changes confined to its
assigned questions and ledgers; those changes were preserved for its worker.

The live quota showed available capacity (4% of the five-hour window and 33%
of the weekly window used immediately before dispatch). Three disjoint local
workers resumed at 16:10:56, 16:10:59, and 16:11:01 UTC. The relay runners were
offline; execution used the shell-worker path explicitly authorized by the
orchestrator plan. Group acceptance, combined gates, importer enforcement, and
final acceptance remain pending.

The local worker monitor now queries live quota, with a session-record fallback
only when that record is less than one minute old. Missing quota leaves retrying
for the orchestrator. Weekly retries use the plan's ten-minute interval. The
monitor launches only assigned content workers; it does not create another
orchestrator or change the scheduled wake's conversation target.

### Lead ruling: valid importer fixtures under the required-note contract

Step 3's required-note guard invalidates older examples that describe valid
questions without wrong-choice notes. The importer worker may update the existing
valid fixture `test/fixtures/questions/science/biology/cell-structure.yaml` and
the existing tests under `test/tool/import_questions/` to supply those notes.
The seed round-trip test must assert that wrong-choice notes survive conversion
and that the correct choice needs no note, rather than expecting a wrong choice's
note to remain null. Passage tests must continue reaching their original
validation failures after their shared valid question gains its wrong-choice
note. This is a bounded fixture adaptation to the approved requirement, not a
change to question content, app behavior, the protected seed, or integration
permissions. The regression test must demonstrate failure before the importer
implementation changes. Content workers have no additional writable paths.

### Science group completed and mechanically verified, 3 October 2026

The Science worker finished at `1e40ca47e3b8251ed0c97cb01b01634021dd0012`
on `content/question-qa-r2-science`, with a clean worktree and a committed
`docs/content/audit/question-qa-r2/science-summary.md`. A normal push was
verified against the same remote SHA at 16:21 UTC on 2 October.

The orchestrator independently ran the full-bank importer and the scoped
mechanical check against that unchanged source revision:

```text
dart run tools/import_questions/import_questions.dart --root content/questions
exit: 0
lessons=51 questions=1023 active=1023 preserved=777 fixed_keys=8 under20=0 errors=0
check_no_ai_attribution: OK
```

The mechanical check covers source and imported wrong-choice notes, prohibited
choice text, bare fractions, em dashes, unique IDs, baseline ID preservation,
unchanged lesson and exam routing, complete ledger rows, and active counts.
The pass-upload monitor also verified the committed archive's importer result,
the attribution gate, and the assigned-path boundary before the push.

Science totals: 777 existing questions audited, 246 added, eight answer keys
recorded as fixed, 204 HIGH findings recorded, and 33 questions requiring
Aedwon's decision. Seven of those protected out-of-lesson items retain HIGH
findings under the worker brief's preservation rule. None of the 51 lessons
is under 20 active questions. Full findings and the pending IDs are in the
science summary and ledgers on the subject branch.

This accepts the Science group's mechanical gates only. Per Aedwon's instruction,
the orchestrator did not review the authored content. Mathematics and the other
subjects remain in progress. No group has been merged into the combined branch;
combined acceptance, importer enforcement, protected-package signing, app/device
checks, and app-branch integration remain pending.

### Scheduled wake moved to the current conversation, 3 October 2026

The current conversation's existing goal is on thread
`01a0fd47-fa9f-7f01-a121-8721b3d3d8cb`. The earlier wake still targeted
`01a0fab1-2cfd-7122-aca4-d54264946301`, whose goal was usage-limited and whose
runtime thread was not loaded. The orchestrator temporarily held the existing
wake lock to prevent overlapping orchestration while it requested direction.

The exact question was:

> The existing 15-minute wake targets the earlier conversation, while this conversation has its own active goal. Should I move the wake here so there is only one orchestrator?

Options: move the wake here (recommended, retain one current orchestrator and
the same schedule), or keep the earlier conversation as orchestrator.
Aedwon selected exactly:

> Move the wake here (Recommended)

The existing script's target was changed to
`01a0fd47-fa9f-7f01-a121-8721b3d3d8cb`. The original goal objective and its
current active status were verified through the existing runtime. The cron entry
still runs that same script every 15 minutes. No thread or goal was created or
replaced by this update. The temporary lock holder was then stopped. A probe in
a minimal cron environment verified the new thread id and correctly skipped
the currently active turn:

```text
event: same_session_already_working
thread_id: 01a0fd47-fa9f-7f01-a121-8721b3d3d8cb
```

The running Mathematics and remaining-subjects workers, their worktrees, the
worker monitor, and the approved content scope were left running. The Science
group remains verified and pushed; combined acceptance remains pending.

### Mathematics group completed and mechanically verified, 3 October 2026

The Mathematics worker finished at
`0e9cca17558aa48720cd4aebf04930adf8a946b1` on
`content/question-qa-r2-math`, with a clean worktree and committed
`docs/content/audit/question-qa-r2/math-summary.md`. The normal push was verified
against the same remote SHA at 16:50 UTC on 2 October.

The orchestrator independently ran the full-bank importer and the scoped
mechanical check against the unchanged source revision:

```text
dart run tools/import_questions/import_questions.dart --root content/questions
exit: 0
lessons=46 questions=920 active=920 preserved=712 fixed_keys=1 under20=0 errors=0
check_no_ai_attribution: OK
```

The checks cover the same source/import, identifier, routing, note, formatting,
ledger, scope, and active-count boundaries recorded for Science above. The
pass-upload monitor verified committed content and attribution before pushing.
Mathematics totals: 712 existing questions audited, 208 added, one answer key
recorded as fixed, 21 HIGH findings, and 58 questions requiring Aedwon's decision.
Every Mathematics lesson has exactly 20 active questions.

The worker also reported 22 raw-source answer-length candidates. Eight are
protected NEEDS AEDWON items; 14 are in previously completed ledgers that its
resumption instructions require skipping. Source length includes LaTeX, so those
14 candidates are not a verified rendered-length finding. They were not reopened
or visually checked. The Mathematics summary lists all 22 IDs. This limitation
must remain in the combined summary; no visual acceptance or authored-content
review is claimed by the orchestrator.

Science and Mathematics are now mechanically accepted and pushed separately.
They cover 97 completed lessons, 1,943 active questions, 454 added questions, and
nine recorded answer-key fixes. The remaining-subjects worker is still running.
The groups remain unmerged; combined acceptance, importer enforcement, protected
package signing, app/device checks, and app-branch integration remain pending.

### Capacity checkpoint before continuation, 3 October 2026

At `2026-10-02T16:58:55.433525+00:00`, the remaining-subjects worker was verified live at
PID `4536` in its assigned worktree. Its committed revision
was `e389469f78d50b78712ad6b78b035c989c683d24`, with 46 of its 61 lesson
ledgers committed. This gives 143 of 158 committed
lesson ledgers overall; only the 97 Mathematics and Science lessons have final
group mechanical acceptance. The remaining group has no committed summary yet.

The five-hour quota was 98% used and the weekly quota
was 48% used. The primary reset is `2026-10-03T05:08:59+08:00`.
The worker monitor was verified live at PID `7992`. It will
validate and push the completed commits when this pass ends, preserve interrupted
files, and wait for fresh permitted capacity before relaunching. These are live
handle observations at this checkpoint, not an instruction to assume they remain
live on a later resumption. Never launch a replacement without checking them.

The sole scheduled wake targets the current conversation,
`01a0fd47-fa9f-7f01-a121-8721b3d3d8cb`, every 15 minutes. The objective remains
active and unchanged. The combined branch is still unmerged at the original
base. Remaining work: complete and accept the last group, merge the three groups
only into `content/question-qa-r2`, run the merged gates, complete the test-first
importer worker and its required checks, review that code, write the combined
summary, push and verify its remote SHA, and record final completion on main.
No app-branch/main content integration, protected-package signing, or visual and
device acceptance is authorized or claimed here.

### Remaining-subjects checkpoint uploaded and resumed after reset, 3 October 2026

The prior remaining-subjects worker ended normally at a context checkpoint,
not a quota error, after completing 11 additional lessons. Its report records
144 existing questions audited and 76 added, with 20 active questions and a
complete ledger for each completed lesson. The worktree was clean at
`e389469f78d50b78712ad6b78b035c989c683d24`. The monitor verified the committed
archive's importer, attribution, and assigned-path gates and pushed that exact
revision at 16:59:56 UTC on 2 October. The orchestrator verified the remote SHA.

Actual pass evidence:

```text
importer_exit=0
lessons=11 active=220 audited=144 new=76
missing_notes=0 emdash=0 bare_frac=0
```

The orchestrator inspected the terminal handle and the report, then authorized
resumption of this specific context checkpoint. The monitor's permission is
bound to that pass id; a later non-quota terminal result still returns to the
orchestrator. This pass made lesson-commit progress, so the non-quota runaway
counter remains zero. There was no worker question or new product ruling.

The monitor waited at the exhausted primary window until the reset, then
relaunched only the remaining subject group at 21:09:06 UTC (05:09 Philippine
time), PID `23717`, using current-main policy at
`cf2d123e38319b2d35751f122bcc4766f3026c8b`. The resumed orchestrator independently
verified that worker and monitor PID `20874` live, the assigned worktree and
branch, the uploaded checkpoint, and newly available capacity. At 21:10 UTC,
the primary window was 4% used and the weekly window was 49% used.

The earlier turn made concrete progress: Mathematics and Science completed and
passed the orchestrator's mechanical gates, 11 more lessons were committed and
uploaded in the remaining group, and the scheduled wake was moved to this
conversation with Aedwon's approval. The quota wait polled an actual live monitor;
it did not replace or narrow the goal. Fifteen lessons remained at the start of
this new worker pass. The group summary, combined merge/gates, test-first
importer change/review, final summary, and final completion record remain pending.

### Final content group completed and mechanically verified, 3 October 2026

The Language, Reasoning, Reading Comprehension, and General Information worker
finished with a clean worktree and committed group summary at
`25b4e45f09c79948768cb14407a3abffb73c8a9c` on
`content/question-qa-r2-other`. Its normal push was verified against the same
remote SHA at 22:02 UTC on 2 October (06:02 Philippine time).

The orchestrator independently ran the full-bank importer and the scoped
mechanical check against that unchanged revision:

```text
dart run tools/import_questions/import_questions.dart --root content/questions
exit: 0
lessons=61 questions=1220 active=1220 preserved=875 fixed_keys=10 under20=0 errors=0
scope_files=123 out_of_scope=0
check_no_ai_attribution: OK
```

The final group audited 875 existing questions and added 345. Its ledgers record
10 answer-key fixes, 211 HIGH findings, and 43 NEEDS AEDWON items, including 11
HIGH findings retained under the preservation rule. Every lesson has exactly
20 active questions. The worker separately checked passage lengths and references
because the existing question-only CLI does not enforce the passage-file path.
Its summary records the primary sources used for legal and factual verification.

The final group retains 39 raw answer-length candidates: 32 in previously
completed non-protected items and seven protected items. These remain subject to
the resumption/preservation rules and were not visually accepted. Together with
Mathematics, 61 raw-source length candidates are recorded. They are not confirmed
rendered-length findings and must remain visible in the combined summary.

All three content groups are now mechanically accepted and pushed. Totals:
158 lessons, 3,163 active questions, 2,364 baseline IDs preserved, 799 questions
added, 19 recorded answer-key fixes, 436 HIGH findings recorded, and 134
NEEDS AEDWON items. No lesson is below 20 active questions. Nineteen pending
items carry HIGH severity; this is distinct from the 19 recorded key fixes.
The content's independent authored-output review remains waived by Aedwon.

Before the importer task, the orchestrator aligned the combined branch's upstream
to its own agreed remote branch, verified both at the original base, and ran
`dart run build_runner build --delete-conflicting-outputs`. Missing generated
files were regenerated successfully (exit 0, 2,491 outputs); tracked status stayed
clean. Flutter 3.44.6 and Dart 3.12.2 were verified locally. No seed was rebuilt.
The combined merge/gates, importer change/review, and final completion remain
pending. No app-branch or main content integration is authorized here.
