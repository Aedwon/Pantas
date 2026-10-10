# Level 4 lesson standards audit through ChatGPT web chats

Date: October 10, 2026
Status: Revision 2 approved by Aedwon on October 10, 2026, with page mockup
version 3, High effort, and the hand-in issue eraser. Amended the same day with
his pacing rule. Revision 1 (prompts pasted by hand) is superseded.
Parent spec: `2026-10-03-exam-content-coverage-audit-design.md` (Level 4, "Lesson
standards", and "Illustration review"). This spec changes how Level 4 is run. It
does not change what Level 4 must answer.

## For Aedwon to approve

### What changes from revision 1

You no longer paste prompts. A queue on your Mac hands each job to the existing
ChatGPT dispatcher, which opens the chats in its own Brave window. You press
Start and watch. You talk to no chat.

Everything else stays: one chat per lesson per role, two independent reads of
every lesson, a deciding chat for disagreements, the guardrails, the planted
lessons, and the pilot.

### How one lesson gets audited

1. The queue picks the next lesson and registers two jobs with the dispatcher.
2. The dispatcher opens two fresh ChatGPT chats at the same moment and gives
   each its assignment.
3. Each chat reads the lesson's packet from GitHub: the brief, the current
   standards, the lesson, its prerequisite lessons, and its Level 3 findings.
4. Each chat fills a fixed answer form. Every rule gets a verdict. Every finding
   carries an exact quote from the lesson. Every pass on a major rule lists what
   the chat checked.
5. Each chat hands its form in through the relay. A script on your Mac checks
   it and replies. If the form is rejected, the chat fixes it in the same chat.
6. A script compares the two forms rule by rule. Where both agree, the verdict
   stands. Where they disagree, the queue starts a third chat. It sees both
   positions without knowing which chat wrote which, and rules with a quote.
7. The lesson is marked finished and the queue moves to the next one.

One chat handles one lesson and one role. No chat is reused.

**Pacing (your rule, October 10).** One lesson runs at a time. The next lesson
starts only when the current one is fully finished: both forms accepted, every
disagreement ruled, the result saved, and the checks on that result passed. If
the current lesson cannot finish, the run does not skip ahead. It pauses and
asks for you. You then fix it, restart its chats, or put it on hold yourself.

### The local page

Mockup, version 3: `docs/content/audit/coverage-r1/level4/mockups/level4-page-v3.html`.
The dark bar on top only drives the mockup. The light panel is the page. The
built page must match that panel 1:1 in layout, text, controls, colors, and
behavior. Any needed difference comes back to you first. Version 3 keeps the
look you approved in version 2 and replaces the copy button with run controls.

The page shows only what you need:

- **One sentence** saying the state: ready, running, paused, or what needs you.
- **One button** when there is something to press: Start, Pause, or Resume.
- **The current lesson** and one line per chat: not started, working, fixing a
  rejected form, or handed in. A deciding chat line appears only when needed.
- **A strip of all lessons** along the bottom, one mark per lesson, colored by
  state, with lessons finished, lessons on hold, and time left at the run's pace.
- **"Something wrong?"** with two rare actions: restart this lesson's chats, and
  put this lesson on hold.

The page asks for you only in these cases: the pilot has finished, ChatGPT's
usage limit is reached, ChatGPT needs a sign-in, no runner is online, or the run
has stopped because something unexpected changed.

Not shown in the mockup: the pilot report, the summary, the findings, and the
hold list. They are plain read-only lists.

### The guardrails

- **A script checks the mechanical rules.** Banned formatting, heading format,
  frontmatter shape, em dashes, spelling forms, and math notation never go to a
  chat.
- **No rule can be skipped.** The check rejects a form with a missing rule.
- **Quotes must be real.** The check rejects a quote that is not in the lesson.
- **Passes need proof.** A pass on a major rule must list what was checked, such
  as each formula and where the lesson first introduces it.
- **Planted defects measure the miss rate.** Ten lesson copies carry known errors.
  They look like ordinary lessons to a chat. Their answer key never goes to
  GitHub during the run. They are removed from the final findings.
- **Chats cannot change anything else.** The assignment allows one hand-in. The
  script refuses to save if anything else in the audit folder changed, and the
  run stops.
- **Hold list.** A lesson cannot finish if a form fails the check twice in one
  chat, if a chat stalls, if a pair looks copied, or if the deciding chat cannot
  settle a disagreement. The run then pauses for you. A lesson goes on the hold
  list only when you put it there. Held lessons are reported, not forced
  through.
- **Version lock.** Every packet names the lesson version and the standards
  version. The check rejects a form built from a different version.
- **The run never works around a limit.** At a usage limit, a sign-in prompt, or
  a security check, it pauses and asks for you.

### How independent the two reads are

Revision 1 promised that the first result stays off GitHub. That was wrong.
Every hand-in travels through the relay as a GitHub issue, so one chat could in
principle find the other's result. The two reads are kept independent by four
layers instead:

1. Both chats start at the same moment, before either result exists.
2. A script erases the text of each hand-in issue within seconds of saving it.
   This edits issues in your relay repository, and only those hand-in issues.
3. The assignment forbids reading other issues, and titles never name the lesson.
4. The comparer flags any pair of forms that look copied, and the lesson goes to
   the hold list.

This makes copying hard and visible. It does not make it impossible.

### What guardrails cannot do

They cannot raise the model's judgment on the subjective rules: Grade 5
readability, example coverage, and whether a concept is truly explained. The pilot
measures that, and you decide from its numbers.

A chat cannot confirm Filipino spelling against the Komisyon sa Wikang Filipino
source. Those items are recorded as needing a source check, not as pass or fail.

As in the parent spec, Level 4 reports wrong facts and wrong example answers it
finds. It does not claim a complete correctness review.

### Pilot before the full run

The pilot covers five real lessons (two Mathematics, one Science, one Filipino,
one Reading or General Information) and five planted lessons. The run then pauses
by itself.

You get a short report: which planted errors each chat caught or missed, by rule;
how often the two reads disagreed; how many forms were rejected; and the time per
chat. You decide whether to continue, to move some rules to a stronger model, or
to stop. No pass mark is set in advance.

The other five planted lessons are spread through the full run as a continuing
check.

### What you will receive

- Findings for each lesson, each with its rule id, severity, quote, and whether
  both reads agreed or a deciding chat ruled.
- The illustration review for each lesson, as the parent spec defines it.
- A Level 4 summary, a count showing all 158 lessons and every rule accounted
  for, the miss-rate result from the planted lessons, and the hold list.
- A live local page showing the run.

### Cost

- Build: about 10 hours of agent work, including the planted lessons and the
  pilot report.
- Your work: press Start, respond when the page asks, read the pilot report, and
  decide held lessons.
- ChatGPT usage: about 336 chats on GPT 6 Sol at High effort, plus one for each
  lesson where the reads disagree. Each chat also reads the relay's own
  instructions first. Your plan's limits are not known to this spec; the run
  pauses when it meets one.
- Run time is unknown until the pilot measures it.
- While the run is active, a relay runner must be on, your Mac must be awake,
  and the dispatcher needs its own signed-in Brave window.

### Decisions in this revision

1. Approve this section and mockup version 3.
2. The script may erase the text of hand-in issues in your relay repository.
   Confirmed October 10 after you asked whether it is safe.
3. Effort level: High, confirmed October 10.

### What counts as finished

All 158 lessons have two accepted reads, every disagreement is ruled or on the
hold list, the planted lessons are removed from the findings, the counting check
passes, and the Level 4 summary is saved. The status then asks for your review.
Level 5 does not start.

## Agent reference, not the approval section

### Identity

- Policy read from main `168e393dc997de4531f4fdd5b683c66025e75d0e`: `AGENTS.md`,
  `WORKFLOW.md`. Standards at that revision include L05 as amended, L25 to L27,
  and Q20. Refresh from main before the build and before the run.
- Audit branch `docs/content-coverage-audit-r1`, worktree
  `Pantas-wt-content-coverage-audit-r1`.
- Corpus input unchanged: `content/question-qa-r2` at
  `765c5dc0fa5586281047bf4f7b30d09ab3707887`. Read only.
- Relay and dispatcher: `Aedwon/chatgpt-terminal-relay`, `main`. Verified October
  10 from its README and dispatch runbook: `workspace_write_file`,
  `workspace_exec`, and `git_push_current` exist; relay requests run only for
  Issues authored by `Aedwon` titled `[relay]`; results return as an Issue
  comment. The dispatcher has a local `register` command taking an assignment
  file, runs up to three runner workers at once, serializes workers that name
  the same worktree, sets and verifies the visible model and effort, never reads
  assistant text, and stops on sign-in, security, rate, usage, and model
  restrictions. Its foreground supervisor was not running and all three runners
  were offline when checked. Its last recorded live proof used GPT-5.6 Sol at
  High. `workspace_visual_review` is not used.

### Rule scope

- In scope: B01 to B10 and L01 to L27 including L22a, as applied to lessons, plus
  the illustration review.
- L06 (in-lesson quiz items against Q rules) is recorded as deferred to Level 5.
- B04 and B05 (source ledger) are checked by script against existing ledgers and
  reported as record findings.
- Script-only rules: B06, B08, B09, B10, L13 (capitals), L16 (exact titles), L20
  (heading format), L22, L24. B07 is script-assisted: the script lists candidate
  British forms and the chat does not judge it.
- Chat-judged rules: all others. L11 is recorded as `needs-source-check`.
- The plan fixes this split in one table and the form generator reads that table.

### Components

Each is a small script or file under `docs/content/audit/coverage-r1/level4/`
unless stated.

1. **Packet builder.** Reads the pinned corpus, current main standards, the
   Level 3 prerequisite file, and Level 3 lesson findings. Writes one packet per
   lesson with an opaque id, the lesson hash, and the standards commit. Planted
   packets are built the same way from edited lesson copies and are
   indistinguishable by name or shape.
2. **Mechanical checker.** Produces the script-only verdicts per lesson.
3. **Answer form.** One fixed, machine-checkable shape: packet id, lesson hash,
   standards commit, role, one entry per chat-judged rule (verdict, quotes,
   checked-items list for major rules), illustration entries per the parent spec,
   and accuracy concerns.
4. **Hand-in command.** The chat saves its form with `workspace_write_file` to an
   ignored inbox path, then runs one script with `workspace_exec`. The script
   validates the form, refuses on any unexpected change in the audit folder,
   moves the form to a local state directory outside the pushed folder, and
   prints accept or the exact rejection reasons, never the form's content. When
   both reads and any ruling for a lesson are in, the results are written to the
   audit folder.
5. **Issue eraser.** Run by the queue under Aedwon's GitHub login, not by a
   chat. After a hand-in is saved or rejected, it replaces the body of that
   lesson's `workspace_write_file` request Issue with a fixed line. It touches
   only Issues whose title carries this run's opaque hand-in token. It needs his
   confirmation before first use.
6. **Comparer.** Per rule: both pass, both fail with overlapping evidence, or
   disputed. Builds the deciding assignment for disputed rules with the two
   positions labeled A and B in random order. Flags a pair as possibly copied
   when their free-text checked-item lists or quote sets are near-identical.
7. **Queue.** A local process that decides the next job, writes dispatcher
   assignment files, registers them, reads worker state through the dispatcher's
   status command, and applies Pause, Resume, hold, and restart. It registers the
   two reads of one lesson together. Assignments set `worktree` to none so the
   dispatcher does not serialize the pair; the relay's own lock serializes their
   hand-ins. Worker completion handbacks carry no findings.
8. **Local page.** Read-only view of queue state plus the Start, Pause, Resume,
   restart, and hold controls. It implements mockup version 3's markup and
   styles directly, without the mockup's dark control bar and sample data. It
   loads Schibsted Grotesk from Google Fonts with a system fallback.
9. **Planted lessons and key.** Ten copies, each with two or three known defects
   that together cover the major chat-judged rules. The key lives in the local
   state directory until the run ends, then is saved to the audit folder with
   the miss-rate result.
10. **Report builder.** Pilot report, per-lesson findings, the illustration
    list, the counting check, the hold list, and the summary.

### To verify in the plan before building on it

- That the dispatcher schedules two runner workers with no worktree at once.
- The exact visible model label for GPT 6 Sol and that the dispatcher's model
  and effort controls still match ChatGPT's current interface. Use the runbook's
  no-send proof. A mismatch is a blocker to report, not to work around.
- Whether the page may start and stop the dispatcher's foreground supervisor as
  a child process. If not, the page shows the command for Aedwon to run.
- The runbook requires a fresh check of OpenAI's terms before live enablement.
  Do it and record the result before the pilot.
- The dispatcher's LaunchAgent is not activated and this spec does not activate
  it.

### Run control

- The first line of `status.md` must never be `STATE: RUNNING` during this run.
  The existing watcher resumes the Codex orchestrator in that state. Use a
  `BLOCKED` line that names the web chat run, and record why.
- Saving to GitHub reuses the watcher's existing save step for the audit folder.
  If the watcher is off, the lead pushes.
- The lead for this run is the agent session Aedwon assigns. The lead builds the
  system, authors the planted lessons, writes the pilot report, resolves held
  lessons with Aedwon, and accepts the level. Chats never accept their own work.
- The second read is the independent review for each lesson. The lead's final
  acceptance uses the counting check and a fresh run of the validators over all
  saved results.
- Order: topic by topic, prerequisite lessons first where Level 3 found a link.
- Pause lets running chats finish and starts no new one.
- Pacing gate: a lesson is green only after its final result file is written,
  re-read, and re-validated (every in-scope rule present, every quote still
  found in the pinned lesson). Only then may the queue register the next
  lesson. Any failure sets the run to a waiting state; the queue never holds a
  lesson by itself.

### Stop conditions

- Unexpected changes in the audit folder or the corpus worktree.
- A packet whose lesson hash or standards commit no longer matches.
- Main's lesson standards change during the run. Stop, report, and ask whether
  finished lessons need a recheck.
- Any dispatcher stop condition from its runbook. Never retry around one.
- Relay or runner unavailable: wait, do not fall back to another route.

### Boundaries

Findings and recommendations only. No lesson, question, illustration, importer,
schema, roadmap, app, or Google Doc change. No change to the relay or dispatcher
code. No computer control beyond the dispatcher's existing approved browser
actions. The original Level 4 definition, the five-level gates, and the Level 5
model plan are unchanged.
