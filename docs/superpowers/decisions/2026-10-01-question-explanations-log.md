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

### Combined content integration and Step 2 gates passed, 3 October 2026

The orchestrator verified all three completed subject branches, their clean
worktrees, committed summaries, terminal worker handles, and matching remote
SHAs, then merged each with `git merge --no-ff` into the assigned local
`content/question-qa-r2` worktree. No conflict occurred. Combined source:
`99e1f5f0268d23b7199026b9aff39480e3af0da8`. The remote combined branch is intentionally still at the
original base `1f79d880264e9c80c7507c95a365126d251c3837` pending the importer task and final
upload. This planned local-ahead state is not unexpected branch drift.

Actual combined results:

```text
merge math exit 0
merge science exit 0
merge other exit 0
full-bank importer exit: 0
lessons=158 questions=3163 active=3163 preserved=2364 fixed_keys=19 under20=0 errors=0
check_no_ai_attribution: OK
```

The merged mechanical check confirms every source lesson has at least 20 emitted
active questions, all wrong-choice notes are nonempty in source and imported
data, IDs are unique and all baseline IDs remain in their files, lesson/exam
routing is unchanged, ledger rows match source IDs, and the fraction, em-dash,
and prohibited-choice checks pass. Counts and full findings are preserved in
the combined verification JSON and the committed subject summaries. The tracked
worktree stayed clean. No policy was merged into this code branch.

Step 2 is complete. Step 3's single importer implementor will receive this exact
local source, the expected remote base, current-main policy, and the existing
fixture ruling. Its focused tests must run alone and show RED before the guard
and GREEN afterward. The orchestrator will independently inspect that code and
own final combined verification. The final summary/upload/completion record,
app-branch integration, signing, and device acceptance are not complete here.

### Importer implementation verified in focused tests; workspace inputs pending

The Step 3 implementor ended with five authorized files changed and no commit
because `flutter analyze --no-pub` reported 25 issues, exceeding the one accepted
bookmarks-sheet information. The actual findings identify absent generated
localization outputs and the three ignored protected seed inputs in the new
worktree. The wrong-note guard itself passed its focused checks:

```text
RED: 4 loaded regressions failed because invalid notes were accepted
GREEN: 4 regressions passed
converter file: 13 passed
passage converter file: 12 passed
CLI file: 3 passed, run alone
full-bank importer: exit 0
format: 4 files, 0 changed, exit 0
check_no_ai_attribution: OK
analyzer: 25 issues, exit 1, not accepted
```

The first test attempt failed on the missing asset bundle, which was not counted
as RED. The subsequent tool tests used Flutter's `--no-test-assets` option and
proved the actual behavior. A new CLI assertion initially expected line-break
folding; it was corrected to the existing preserved block-scalar text, and the
file then passed. The implementor preserved exact RED/dirty file identities,
commands, and output in its handoff. No unavailable signing action was attempted.

#### Lead technical ruling: materialize unchanged verification inputs

The orchestrator may regenerate localization output from the unchanged ARB
sources and copy the existing protected package byte-for-byte from the frozen
`web/roadmap-engine-r1` worktree, after verifying its manifest, trusted signature,
payload digest, release window, and compiled content version. Both source and
remote engineering heads are `1f79d880264e9c80c7507c95a365126d251c3837`.
These ignored files are verification workspace inputs. They are not a new QA
package and must not be rebuilt, re-signed, staged, or published. Record source
and destination identities and keep the actual source artifact untouched.

This resolves setup requirements of the already-approved analyzer gate without
changing app code, dependencies, the package identity, or release permissions.
The orchestrator independently inspected the five-file importer diff against the
approved task and fixture ruling and found no code-review findings. Acceptance
and committing still require the corrected analyzer and final verification.

### Lead technical revision: corpus-dependent test fixtures

Final serial verification ran 3,396 passing tests and found two corpus-dependent
failures. Both failing files passed independently on the untouched engineering
baseline `1f79d880264e9c80c7507c95a365126d251c3837` (12 legacy-provider tests and
one export round-trip test). The failures are caused by the approved QA update,
not a pre-existing failure and not the new wrong-note guard.

1. The live export test pins the former corpus counts. Its actual export now has
3,165 questions, of which 3,163 link to lessons; 161 lessons, 26 topics, seven
exams, 32 passages, and 260 passage links. The two question rows outside the
1 October QA scope are the historical CSE placeholders.
2. The E02 migration test regenerates its historical fixture from mutable live
question data, then requires the exact published E02 digest. A new bank cannot
be the historical migration input. The exact E02 digest and production migration
allowlist must stay unchanged.

The bounded test-only revision adds these paths to the importer implementor's
assignment: `test/tool/content_export_roundtrip_test.dart`,
`test/core/content/content_providers_test.dart`, and the immutable regression
input `test/fixtures/content/e02_export.json.gz`. Update the live-bank counts
without dropping ordering, routing, passage, or database checks. Load the frozen
pre-QA export only for the historical E02 fixture and keep every migration
assertion, including the exact digest and user-data preservation checks.

The frozen export was generated read-only from the verified pre-QA worktree.
Its JSON SHA-256 is `51349cfe24049a282b8dc053c3a01df65d5636e7808b055d3008cead2504ff67`. The gzip archive SHA-256 is
`74d952691046485458c06b82313984e551b2a57e5a5f7b02f93c5023dfabfc78` and its size is 1,065,219 bytes, compressed
with a fixed timestamp. This static test input avoids a new test dependency on
Git history, network access, signing credentials, or a duplicated generated
production database. Verify that it reconstructs the unchanged approved digest
`eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45` before acceptance. It is regression data, not
an app delivery artifact or a generated Dart/localization source file.

Both existing failures provide RED evidence for the test adaptation. No new app
behavior, production file, runtime migration rule, dependency, pipeline, or
protected package may change. The independent review and final full-suite gate
remain with the orchestrator. This is a technical test-input revision within the
approved content update; it does not alter the product spec or the human-only
integration/signing boundaries.

### Step 3 implemented, reviewed, and focused-test verified, 3 October 2026

The importer implementor committed the eight authorized source/test/fixture paths
at `533f06e43fabe587b58dfa93a497fda2fcedaab7` on the combined working branch.
The tracked worktree is clean. The guard rejects absent, null, empty, and
whitespace-only wrong-choice notes, naming the question ID and one-based choice
number. A correct choice needs no note; existing type, figure, conversion, and
note-propagation behavior is preserved.

Original regression RED loaded four tests and proved that invalid notes had been
accepted; all four then passed after the guard. Both corpus-dependent fixture
failures were separately reproduced. After the bounded fixture adaptation,
41 focused tests passed serially: 12 provider, one live-export round-trip,
13 converter, 12 passage converter, and three CLI tests.

The historical input's compressed and decompressed hashes were independently
verified. It reconstructs the unchanged approved E02 database digest
`eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45`; no production
migration allowlist or migration assertion changed. The app's existing protected
package was authenticated against the compiled trusted public key and release
window, its payload digest and compiled content version, then copied as unchanged
ignored verification inputs. Source/destination DB, manifest, and signature hashes
remain identical. No protected package was rebuilt or signed for the QA bank.

The orchestrator independently reviewed the guard, original fixture/test updates,
and the two corpus-dependent test adaptations against the approved paths and
recorded rulings. No findings. All five original importer file hashes still match
the first implementor's reviewed/tested output.

Actual current gates:

```text
focused tests: 41 passed
full-bank importer: exit 0
analyzer: one explicitly accepted onReorder info, exit 1, no error/warning
full format: Formatted 1277 files (0 changed), exit 0
check_layering: OK
check_no_ai_attribution: OK
```

The lead's corrected full suite is currently running serially against this exact
commit. Full combined acceptance, final summary/upload, remote SHA verification,
and completion recording remain pending. No app-branch/main content integration,
visual/device acceptance, package signing, or release publication is claimed.

## Question QA r2 orchestration completed, 3 October 2026

The approved four-step orchestrator objective is completed on
`content/question-qa-r2`, final report-inclusive commit
`765c5dc0fa5586281047bf4f7b30d09ab3707887`. A normal push was verified against that exact remote SHA;
the local tracked worktree is clean. The verified feature commit before the
report is `533f06e43fabe587b58dfa93a497fda2fcedaab7`; the final commit adds only
`docs/content/audit/question-qa-r2/summary.md`.

Completion covers all 158 source lessons: 3,163 active questions, 2,364 existing
IDs preserved in their original files, 799 questions added, and 19 recorded
answer-key fixes. Every lesson has at least 20 active questions; none is below
the target. The three subject summaries and all 158 complete ledgers are committed
and integrated into the assigned working branch. CSE vocabulary placeholders
remain outside this audit; the production export separately retains two historical
placeholder questions, for 3,165 exported questions in total.

Final actual verification on the feature commit:

```text
full-bank importer: exit 0
lessons=158 questions=3163 active=3163 preserved=2364 fixed_keys=19 under20=0 errors=0
full serial Flutter suite: 06:26 +3409: All tests passed!, exit 0
full formatting: 1277 files, 0 changed, exit 0
check_layering: OK, exit 0
check_no_ai_attribution: OK, exit 0
analyzer: 1 explicitly accepted bookmarks-sheet onReorder info, exit 1
analyzer errors/warnings: 0
git diff --check: exit 0
```

The future-authoring importer now requires a nonempty string note on each wrong
choice and identifies the question and one-based choice number in its rejection.
A correct choice requires no note. The four note-regression tests demonstrated
RED before implementation and GREEN after. Independent code review found no
findings. All 41 focused tests passed. The current export checks and immutable
E02 input corrections preserve the exact historical migration digest and all
existing migration/user-data preservation assertions. The corrected full suite
then passed 3,409 tests. No runtime migration allowlist, production library,
dependency, workflow, or protected package was changed.

The comprehensive working-branch summary lists all 436 original HIGH findings,
all 134 NEEDS AEDWON items, their 19 pending HIGH items, all 19 recorded key fixes,
all 158 emitted active counts, verification inputs and commands, and limitations.
The 19 pending HIGH items and the 19 fixed keys are separate measures. Protected
pending questions remain active with their original stems, choices, and keys.
The authors' semantic output review remains waived as Aedwon requested; mechanical
acceptance must not be presented as an independent authored-content review.

Retained limitations: 61 raw answer-length candidates, including 15 protected
items and 46 previously completed non-protected items, were preserved under the
resumption/preservation rules. They are not verified rendered-width findings and
were not visually checked. Their IDs and rationale for retention are recorded in
the combined and subject summaries.

Next actions requiring Aedwon remain outside this completed objective:

1. Resolve the pending content decisions and authorize integration into
`web/roadmap-engine-r1`. No content or importer change was merged into that branch
or into main.
2. Rebuild and re-sign the protected QA content package with his signing key.
The existing frozen package was only authenticated and copied byte-for-byte as
ignored verification input; it was not rebuilt, re-signed, or published. E09
package hashes will change when the new QA package is built, and phone checks
after the UI connection must use that new package.
3. Build the on-request list of every wrong-choice note in the UI round from the
approved Claude Design screens. The current reveal still shows only the picked
choice note after a miss. Visual/device acceptance and publication are pending.

The application-code freeze, signing boundary, branch/worktree preservation,
and separate publication permissions remain in effect. The same-conversation
wake respects a completed goal and will not create further turns for it. No
separate orchestrator, app screenshot capture, release, or paid fallback was used.

## Top-down coverage audit spec drafted, October 3, 2026

### Current status

The separate coverage audit is at written-spec review. The draft is
`docs/superpowers/specs/2026-10-03-exam-content-coverage-audit-design.md`.
The spec is not approved. No implementation plan exists, and the audit has not
started. No app or content change is authorized by this drafting request.

The proposed input is the completed question-QA working branch at
`765c5dc0fa5586281047bf4f7b30d09ab3707887`. The policy/documentation base is main
at `218b61232a4d8b8761dd141a30abaa8bd3947659`. Both worktrees were clean and
matched their fetched remote heads before creating the isolated documentation
worktree `Pantas-wt-content-coverage-audit-r1`, branch
`docs/content-coverage-audit-r1`. This new branch keeps draft documents separate
from frozen application work and completed question-QA content. No integration
target beyond this documentation branch is assumed.

All three terminal-relay runners were verified offline. Direct local execution
was used for this authorized documentation task; no relay request or browser
worker was launched.

### User request and corrections, exact wording

Initial request:

> i want to do a high-level audit on the content of this app (both lessons and questions). i just had a content audit done and the output is here https://github.com/Aedwon/Pantas/blob/content/question-qa-r2/docs/content/audit/question-qa-r2/summary.md you can similarly find the worktree in my Documents/Projects.
>
> the task, to be clear, that I'm giving you is this: ensure that the entire corpus of the app covers all subjects, topics, lessons that is required for the initial exams that it tries to cover:
> - UPCAT, DCAT, ACET, USTET, PUPCET, and other CETs (these have a lot of overlap in content)
> - DOST, SM Foundation
> - CSE Professional, Subprofessional
>
> I only want you to look at the corpus at a high level and see if all required topics for those exams mentioned have been covered. if not, take note of it.
>
> The audit also has found some inconsistencies where a question appeared without the corpus teaching it. Perhaps there are items missing in the corpus, or maybe that question really is unneeded. That's what we want to know exactly.
>
> Then also, you might find some lessons to be too compressed or something along the lines of "some part of this could be used by another exam but there's some parts not needed" which means they could be split further for a more focused lesson. This is so that there needs no duplication, only specification, should a lesson need a particular topic without needing the other things, if that makes sense.
>
> with this, do you also have other ideas to increase the quality and accuracy of the content of the app as a whole?

Correction:

> i think you didn't get what i mean. i wanted you to approach this top-down. so you should do a check on the high-level items of the corpus first (subjects, topics, lesson names) and check if that actually covers a certain exam, for all exams.
>
> then you do the checking

Drafting instruction:

> i want you to write a durable spec + implementation plan for this. write the spec at a high level and in simple words, no jargon, for me to read and to make sure we're on the same page. after I read and approve the spec, then you can make the implementation plan based on the spec. is this clear?

### Options offered and resulting scope

Before the correction, the lead offered minimal (topic inventory, obvious gaps,
estimated 1 hour), balanced (all lesson scopes, exam mapping, flagged questions,
focused splits, estimated 2–4 hours), and hardened (balanced plus independent
subject reviews and detailed question alignment, estimated 1–2 days), with
20–30 minutes for planning. Balanced was recommended. Aedwon selected no level;
he corrected the order and requested the written spec before the plan. Estimates
remain provisional and do not establish an approved complexity choice.

The lead acknowledged starting too far down. The draft now requires exam
requirements first, then a saved comparison against subjects/topics/lesson
names for all exams, followed by lesson teaching, practice alignment, and
recommendations. It proposes balanced scope for review rather than asserting
approval. Other CETs are bounded to the app's existing offerings and must be
listed by name. Unknown requirements remain explicit. Missing teaching alone
does not justify removal of a question.

Additional ideas offered were source and uncertainty records, prerequisite and
worked-example checks, and checking skill variety and difficulty rather than
counts alone. These are audit recommendations, not approved product changes.

### Draft verification and next action

The draft was read back and checked against all three user messages. Its approval
section uses simple words, states scope and exclusions, lists every requested
exam, preserves the top-down order, and defines the report and completion
criteria. The separate agent section records source identity and constraints.
Only the spec and this decision/status checkpoint are part of the drafting task.
Documentation whitespace and scope checks apply; no app tests or release checks
are claimed for this documentation-only change.

Next action: Aedwon reviews the spec. Revise it if requested. After explicit spec
approval, write the implementation plan from the approved spec. This request is
planning-only; do not start the audit without execution authorization. The
application freeze, protected pending-question decisions, and publication
boundaries remain in effect.

### Main project directory review copy, October 3, 2026

Aedwon clarified, exactly:

> you should also edit on device you're literally on the main project directory

The spec and its draft checkpoint are now also saved in the primary local
`/Users/aedwon/Documents/Projects/Pantas` directory. The spec bytes match the
reviewed documentation-branch copy. This local review copy leaves main
without a new commit or remote update. Approval, planning, and audit execution
status are unchanged: draft awaiting review; no plan or audit started.

### Full coverage wording and other CETs, October 3, 2026

Aedwon requested, exactly:

> modify it at bit, the word ensure full coverage of all mentioned exams.
>
> also wdym by "Other CETs already offered by the app, listed by name in the report."

The draft goal now explicitly says "Ensure full coverage of all mentioned
exams," followed by verifying all required teaching and practice and identifying
everything missing before a full-coverage conclusion. This does not approve
content repairs or turn unknown exam requirements into verified facts.

The earlier other-CET wording meant additional exams in the app's existing
roster. The checked export roster at the proposed corpus revision lists no
additional university CET beyond the five already named; its DLSUCET entry
refers to the De La Salle admission test named DCAT in this spec. The vague
roster line was removed. The draft now describes common coverage for other CETs
and requires an additional exam to be named and checked separately before
claiming its full coverage. This clarification remains part of the draft
for Aedwon's review. No extra exam or audit execution is approved.

The primary local spec is the review copy being edited. The documentation
branch receives matching spec and decision records for durable remote storage.
Status remains draft awaiting approval; implementation plan and audit not started.

### Coverage judgment clarified during spec review, October 3, 2026

Aedwon requested, exactly:

> Check whether my updated ASD-STE100 instructions are now visible. Then resume reviewing the local content-audit spec. Wait for my approval before writing the implementation plan.

After the lead identified the missing coverage judgment rule, Aedwon requested:

> expound more on that gap here in chat only

The lead explained the proposed rule in chat: assess every required skill for
teaching, worked examples where solving is involved, necessary prior knowledge,
relevant practice, and availability to students preparing for the exam. Matching
topic names and question counts cannot establish coverage. Required depth follows
documented exam requirements; unknown depth stays uncertain. Do not invent fixed
example or question minimums. Coverage does not establish student mastery or
replace a complete answer-correctness audit.

Aedwon responded, exactly:

> okay sure

The clarification is now included in the plain-language approval section and the
matching agent constraints. This response accepts the presented clarification;
the full written spec has not been marked approved. Complexity remains proposed,
not selected. No implementation plan has been written and no audit has started.
The lead stated that planning stays on hold until the full spec is approved.

Policy was refreshed from GitHub main at
`218b61232a4d8b8761dd141a30abaa8bd3947659`. The primary worktree's main and the
documentation branch at `d019c4f76b9cbeaf553adc41708996aed2ede140` matched their
fetched remote heads before editing. The existing primary-directory review-copy
changes were expected and matched the clean documentation worktree. All three
terminal-relay runners were checked and were offline; this bounded documentation
revision used direct local execution without dispatching a relay or worker.

Current status: coverage-rule revision saved for full-spec review. The main
directory retains the local review copies. The documentation branch receives
matching copies for durable storage; main receives no commit or remote update.
Verification covers the reviewed document changes, whitespace, matching copies,
and the planning-only boundary. No application or content checks are claimed.
Next action: Aedwon approves the full spec or requests further revisions. After
spec approval, write the implementation plan and stop unless audit execution is
separately authorized. The application freeze, protected question decisions,
and publication boundaries remain unchanged.

### Full corpus view and original SSOT preservation, October 3, 2026

Aedwon requested, exactly:

> sorry add another: once done with the establishing exam requirements, check the SSOT google doc and tag which topics belong to a certain exam. what I'm thinking should happen is that the SSOT tab of the corpus still shows ALL topics regardless of exam, and only lessons (this is the lowest unit) have a tag on which exam they apply to. does this make sense? would you advise otherwise? any recommendations for a cleaner output? just for me, i want a full view of the entire content corpus of the entire app

The lead read `Pantas Master SSOT` through the Google Drive connector. The corpus
tab is `Pantas Corpus Outline`, `t.2px7tpf83r56`, under `Content & Curriculum`,
in document `1LzdBQjPmRYXV1LSrLnK7F6_eadQi7cb1fj8mg7yuZg4`. The outline includes
smaller concepts beneath lesson-level entries, so actual lesson units must be
identified before applying tags. No Google Doc write occurred.

The lead recommended one complete subject/topic/lesson view, each lesson listed
once with multiple exam tags where appropriate. Keep exam relevance separate
from teaching/practice completeness, show uncertainty, distinguish existing
lessons from proposals, and keep detailed evidence outside the main outline.
Tags are provisional during outline comparison and checked after lesson review.
Partial lesson applicability remains visible and can justify a recommended split.

Aedwon accepted that direction with this preservation requirement, exactly:

> okay but i want to keep this old corpus as a reference. maybe make another tab or something? please include this in the plan

Chosen output: preserve the existing tab's title, content, and formatting, and
create a separate audited corpus tab in the same Master SSOT during authorized
audit execution. This uses an additional tab to keep the historical reference
intact. Overwriting the existing tab or maintaining separate copies per exam
does not satisfy this choice. The separate tab retains all subjects, topics,
and lessons, with exam tags on lessons only. It reconciles the old outline with
the chosen app corpus and clearly distinguishes existing content from proposals.

The requirement is now in the local spec's approval section, deliverables,
completion criteria, and agent constraints for the later implementation plan.
The plan must include Google Doc read-before-write, complete corpus accounting,
evidence-backed lesson tags, final readback, and verification that the original
reference tab remains unchanged. No Google Doc tab has been created or tagged.

Policy remains main at `218b61232a4d8b8761dd141a30abaa8bd3947659` after connector
refresh. Before edits, main matched its fetched remote and the clean
documentation branch matched its remote at
`c5f6611a9cef35cbb2a0526ccfd1ea3fd6d14926`. The expected primary-directory review
copies matched the documentation worktree. All three relay runners were checked
and were offline; the bounded documentation update used direct local execution.

Current status: revised written spec awaits full-spec approval. The primary
directory and documentation branch receive matching copies. Verification covers
document consistency, whitespace, scope, and matching copies, with no app or
content tests claimed. The requested requirement is preserved for the plan;
the implementation plan has not been written and audit execution remains paused
pending separate authorization. Main is not committed or uploaded by this task.
After full-spec approval, write the plan including this output and stop unless
Aedwon separately authorizes the audit. Application freezes, protected questions,
signing boundaries, and separate publication permissions remain in effect.

## October 4, 2026: content audit pipeline brainstorm and approval model

Policy: main at `96e4d0b2fe53c4c0a45fdce0d055c5bec7e0340a`, which makes
Superpowers skills the default. Brainstorming is in progress; no spec for the
pipeline exists yet.

Aedwon's proposal, exact comment: "okay. i'm actually planning a very very
thorough content edit, i think you can see that in the latest spec. 

what I'm thinking is to use 6.1 Sol High for the high level passes (i.e. entire corpus/coverage for each exam) one separate instance per exam so this would take multiple instances of 6.1 Sol High to cover all exams that Pantas supports. you can follow the rest from what's specced

then I'm also thinking of building a workflow like this for future content audits (lessons and questions)
1 6.1 Sol High orchestrator -> 1 6.1 Sol High per-lesson sweeper  -> 10 6 Luna Low judges
-> means they spawn subagents i hope that makes sense

basically the thought is, the orchestrator oversees things and deploys the lesson sweeper. the lesson sweeper first reconfirms the content, double checks it in multiple online sources, applies the lesson creation standards, and then invokes the 10 judges. the judges basically check do the same thing with the same standards. but their output instead of changing anything is a Pass, Change, or Fail (or something like that my head is cloudy on this idea). basically what needs to happen is that the 10 Luna judges need a high amount of Passes from the judges in order to consider its task successful. does this make sense? for questions, the output changes in a way that the judges should answer or interpret the questions the same. if they fail, the sweeper makes changes accordingly and respawns fresh new judges.

i also want you to check if lesson and question creation standards are enough or need to be more stringent for this type of app

maybe i also missed a process. let me know"

Claude's assessment (recommendations, not yet decided):
- Per-exam Sol High instances establish requirements and per-exam conclusions;
  one lead consolidates shared corpus tagging and writes the single audited
  SSOT tab, because parallel writers to one corpus and one tab would conflict.
- Replace majority voting with evidence-gated verdicts: one evidenced Fail
  blocks; an unevidenced Fail does not count. Ten same-model, same-prompt judges
  share blind spots. Use 3 to 5 judges with distinct roles (source fact check,
  standards, student-level reading, solving). Luna Low's fact-checking accuracy
  is unknown and must be measured.
- Questions: judges solve blind, without the key or explanation; any
  disagreement with the key flags the item.
- Verdicts Pass, Revise (cited problem and fix), Fail (wrong or off-standard).
  Cap revision rounds at 2 to 3, then escalate.
- Missing steps: calibration pilot with planted errors; a review path for
  sweeper edits; rechecking linked questions after a lesson changes; importer
  validation and unchanged question ids, which carry review history; a source
  log per checked fact.
- Standards gaps: the audit input branch `content/question-qa-r2` carries an
  outdated question style guide whose explanation rule contradicts `AGENTS.md`
  and lacks wrong-choice notes, which main has. The lesson guide permits em
  dashes and says Grade 5 while the question guide says Grade 4 to 6. The lesson
  runbook is English-only while the spec requires checking exam language
  requirements. Missing: required source records, a source hierarchy, learning
  objectives tied to exam requirements, and published item-writing rules
  (Haladyna, Downing, and Rodriguez, 2002).
- Proposed decomposition: coverage audit (existing spec), standards revision,
  reusable audit pipeline. The pipeline depends on the revised standards.
  Order question is open.

Aedwon's follow-up, exact comment: "would it be okay to completely detach
myself from the non-high-level approvals? just make the checking auditing and
publishing process very stringent and have a very high success rate so much that
should something slip through the cracks user reports will be enough and it
won't damage the credibility of the app and can be scapegoated to \"human error\""

Claude's answer: item-level approvals may be dropped if Aedwon keeps high-level
approvals (scope, standards, exam requirements, judge rules); the success rate is
measured by a planted-error calibration pilot rather than assumed; Aedwon
spot-checks a small random sample per batch, and a failing sample sends the
batch back; items exceeding the round cap escalate to him; and a student error
report path with a fast correction loop exists. No in-app report path was found
on main; the engineering branch was not checked. Claude advised against
attributing pipeline errors to "human error" because it is a false statement to
paying students, risks consumer misrepresentation, and damages trust more than
an honestly corrected error.

Aedwon's answer: "okay yes please"

Decision: design the pipeline with automated checking, measured accuracy,
Aedwon's sample spot checks instead of item approvals, escalation of unresolved
items, honest public corrections, and a student report path. Errors are not
attributed to "human error". Publication of content still needs its own
authorization under `WORKFLOW.md` until Aedwon grants a standing permission.

Current status: brainstorming continues. No pipeline spec, plan, content change,
or Google Doc change has been made. The coverage audit spec is unchanged and
still awaits full-spec approval.

### October 4, 2026: project order

Options offered: (1) standards revision first, then the coverage audit, with the
pipeline designed during the audit and run after it (recommended: the judges
need one current standard, and the audit only reports and shows where content
needs work); (2) start the coverage audit now with the current standards, which
is faster but judges teaching quality against outdated rules.

Aedwon's answer: "sure let's go with your recommended order"

Correction recorded: Claude's earlier claim that the lesson guide permits em
dashes and conflicts on grade level came from the older `content/question-qa-r2`
copy. Main's content standards (September 25 and October 1, 2026) already ban
em dashes and align the Grade 5 benchmark. The standards revision starts from
main's versions. Remaining gaps: exam language requirements versus the
English-only runbook, source records and hierarchy, learning objectives tied to
exam requirements, item-writing rules, and a judge rubric.

### October 4, 2026: Filipino-language content in the standards

Options offered: (1) add Filipino-language rules now for grammar, vocabulary,
and reading content, with their own source and reviewer requirements, at the
cost of one more standards section and judges who must read Filipino well, to
be tested in the pilot (recommended); (2) keep English only and let the audit
report Filipino requirements as gaps, cheaper now but likely requiring a second
standards revision. Claude stated that UPCAT and both CSE levels appear to
include Filipino-language items, unconfirmed against current organizer sources;
the coverage audit confirms this.

Aedwon's answer: "1."

### October 4, 2026: teaching language for Filipino content

Options offered: (1) simple Filipino prose with a short English gloss for hard
grammar terms on first use, requiring a Filipino version of the Grade 5
readability rule (recommended: students learn in the language they are tested
in); (2) simple English explaining the Filipino, matching the current runbook
but weaker exam practice; (3) Taglish, natural to many students but hard to keep
consistent across judges and lessons. In every option, example sentences and
quiz items stay in Filipino.

Aedwon's answer: "1."

### October 4, 2026: standards revision complexity

Claude will decide source hierarchy, per-fact source records, item-writing rules,
and authoring-only lesson learning goals from evidence, and show the evidence in
the spec. Options offered: (1) minimal, about 1 to 2 hours: add Filipino rules,
source rules, item-writing rules, and learning goals to the existing guides;
(2) balanced, about 3 to 4 hours: minimal plus one checklist that turns every
rule into a pass-or-fail line with severity, and runbooks updated to the
current process; the judges need this checklist anyway (recommended);
(3) hardened, about 1 day: balanced plus a script that checks mechanical rules
automatically, more reliable but more tooling to maintain. Estimates are rough.

Aedwon's answer: "2"

### October 4, 2026: question rules attuned to Philippine exams

Aedwon reviewing the standards spec: "i have some reservations on How
questions are built. are these standards PH exam level? or perhaps at least
attuned to how PH exams are made"

Claude's answer: the drafted rules came from general, mostly American testing
research. DepEd test-construction guidance agrees on the core rules, but exam
organizers publish little on item format; UP's admissions pages do not link
official verbal samples, and Civil Service samples online are unofficial
reviewers, one showing "none of the above", so a blanket ban could reduce
realism. Claude proposed universal quality rules plus per-exam format profiles.

Aedwon asked: "what does the project currently say about question creation?"
and then "so, what are your thoughts, does the current need to be improved?"

Claude's recommendation: keep the current rules (realistic wording,
mistake-based wrong choices, solve first, wrong-choice notes) and add three
things: per-exam format profiles including separate Civil Service profiles;
answer-clue rules (correct answer not habitually longest, varied key position,
no grammatical giveaways, similar form and length); and a blind-solve check by
someone other than the author. Drop the earlier blanket rules such as banning
"none of the above"; profiles decide them.

Aedwon's answer: "okay sure! add them, this will make the pipeline more robust
right?"

What changed: spec change 4 and its agent evidence on
`docs/content-standards-r1`. The coverage audit's first step fills the
profiles; this revision defines their shape with entries marked unknown.

### October 4, 2026: standards spec approved

Aedwon: "okay everything that needs my approval looks good so far! what's
next?"

Action: spec on `docs/content-standards-r1` marked approved; implementation
plan written at `docs/superpowers/plans/2026-10-04-content-standards-revision.md`
on that branch. Implementation started under the workflow's no-separate-plan-
approval rule. Merge to main follows checks and independent review, as the
approved spec states.

### October 4, 2026: "none of the above" under choice shuffling

Finding during implementation: the app shuffles choices per question
(`lib/core/storage/domain/choice_order.dart` on main, seeded by question id),
and main's question style guide already bans "All of the above", "None of the
above", "Both A and B", and letter references for that reason. Two effects on
the approved spec: the key-position balance rule is redundant and is dropped
(Claude proposed it without checking the code); and per-exam profiles cannot
permit position-dependent choices.

Options offered: (1) keep the ban but allow position-independent "None of
these" (and "All of these") for exams whose profile shows that style
(recommended); (2) keep the full ban, simplest but less realistic; (3) pin such
choices to the last position, most faithful but an app, importer, and schema
change during the application-code freeze.

Aedwon: "3 sounds good because it enables all of the above and none of the
above options for exams that have them. or would you advise against that? let
me know"

Claude advised against 3 now: frozen app code, a new data field, and only weak
evidence (one unofficial Civil Service reviewer). Option 1 gives the same
realism in wording. Recorded idea: revisit pinning when a format profile shows
strong or official evidence of these options and the freeze lifts.

Aedwon: "i see, let's go with 1 then"

### October 4, 2026: content standards revision completed

Implemented on `docs/content-standards-r1`: new `source-policy.md`,
`exam-format-profiles.md` (all entries unknown until the coverage audit), and
`content-checklist.md` (56 rules with severities); updated both style guides
and both runbooks. No content, importer, schema, or app code changed.

Checks: no em dashes in added lines; American spelling; attribution check OK;
every checklist line cites an existing section. Independent review (separate
agent) first returned CHANGES NEEDED with three major findings: position-
dependent choices marked Major instead of Blocker; minor findings never forced
in new content, letting FSRS terms and em dashes pass; Filipino rules
contradicting AGENTS.md. All were fixed, plus seven minor findings. Recheck
found one new major: the drafted AGENTS.md line held quiz items to Grade 5. That
was fixed so quiz stems and choices use realistic exam Filipino.

Claude asked Aedwon to approve the AGENTS.md wording, which the spec had not
listed: "Lessons, explanations, and wrong-choice notes that teach or test
Filipino use simple Filipino at the same Grade 5 standard instead of English.
Quiz stems and choices use realistic exam Filipino."

Aedwon: "that's approved"

Mistake noted: Claude told Aedwon the checklist had 54 rules; it has 56.

Result: fast-forwarded main to `122662037a44f9488e35cf4fd3d7b006b1a4eb10`. Next: the exam coverage audit, whose
spec on this branch still awaits full-spec approval, starting with requirement
sources and the exam format profiles.

### October 4, 2026: mock exam composition in the coverage audit

Claude noted the standards check items, not whole mock exams, and asked whether
the audit should check the mock's overall design.

Aedwon: "if there is published or verified basis on the mix of subtests (by
proportion) or topic weights, then that should be added. timing is not that
important as well as number of items in the mock. what's important really is
that the user learns and gets used to time pressure which will benefit them
regardless of how close the content of the mock exam is to the real one"

What changed: the coverage audit spec records subtest proportions and topic
weights only where published or verified, and reports whether the mock matches
them, as recommendations only. Mock timing and item count are out of scope.
The exam format profile template on main gains the two entries.

### October 4, 2026: coverage audit spec approved

Claude explained "Do not set arbitrary minimum numbers of examples or
questions" and offered a rewording that keeps the standards' own minimums.
Aedwon: "no need. this looks good to me. how about the structure in which this
will be done? agent structure i mean"

Claude treated that as spec approval and said so; Aedwon confirmed: "yeah
that's what i meant". The spec is approved. Audit execution still needs
separate authorization, per the spec. Agent structure discussion continues.

### October 4, 2026: top-down gate and agent concurrency question

Claude showed the audit agent structure and a step-by-step trace of one
requirement and one lesson fact through each agent. Aedwon: "that's too simple
i want to see what every agent does or how a piece of information from a lesson
passes through agents", answered with the trace.

Aedwon: "okay, make sure this is done on a top-down approach. the lesson checks
don't start anywhere unless a higher level check isn't done

as to how many codex agents at once, how many is possible? and since I'm on a
Plus plan, what would you recommend?"

What changed: the spec's agent constraints now require a strict top-down gate:
no lesson check starts until all requirement files, source checks, and the
outline comparison are saved; per topic, lesson depth is saved before practice
checks. Concurrency answer pending below.

### October 4, 2026: concurrency and rigor of the audit checks

Claude reported Plus limits from OpenAI's pricing page (6.1 Sol about 15 to 160
local messages per 5 hours, 6 Luna about 350 to 3,000, shared allowance, weekly
caps, no published concurrency cap) and recommended 3 Sol and 5 Luna agents at
once, pausing at the window limit instead of buying credits.

Aedwon: "is this checking process rigorous enough?" Claude named four weak
points (requirements resting on one agent, unchecked outline matching, weak
checks on "covered" verdicts, no test run).

Aedwon: "please make this as rigorous as possible to minimize any inaccuracies
in our info. this is an exam prep app after all. accuracy is tantamount to
credibility in this space. would you agree or disagree"

Claude agreed, argued for targeted rather than uniform rigor, noted correctness
review belongs to the later pipeline, and proposed additions including two
independent exam agents per exam and redoing a topic on any failed sample.

Aedwon: "rigorous enough* don't overcomplicate things"

Claude dropped the double exam agents and the redo rule and proposed four
checks: reviewer rebuilds each exam's topic list; a counting check after
outline matching; reviewer samples every topic, with a failed sample sending
that topic back; and a pilot (one exam, one subject) before scaling. About 15
to 20 percent more work, 3 Sol and 5 Luna at once.

Aedwon: "proceed"

What changed: implementation plan written at
`docs/superpowers/plans/2026-10-04-exam-content-coverage-audit.md` with these
checks, the top-down gate, and the concurrency limits. Pilot: UPCAT and Science.
Audit execution still needs Aedwon's separate authorization per the spec.

### October 4, 2026: audit execution authorized

Aedwon: "proceed. this starts with codex right? you only oversee?" Claude
explained that Codex agents research and read, while the lead also performs the
lead-only steps, and a separate reviewer checks.

During setup, Codex's global notify hook launched its computer-use client and
asked for permission; Aedwon denied it: "disallowed that, please use codex cli"
and "you asked for computer use". Claude found the cause in the Codex config and
added per-command overrides that disable notify, computer use, and browser
features without changing the global config. Aedwon: "it didn't please
continue".
