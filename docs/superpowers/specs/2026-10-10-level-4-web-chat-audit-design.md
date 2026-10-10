# Level 4 lesson standards audit through ChatGPT web chats

Date: October 10, 2026
Status: Draft for Aedwon's approval. Nothing is built and Level 4 has not started.
Parent spec: `2026-10-03-exam-content-coverage-audit-design.md` (Level 4, "Lesson
standards", and "Illustration review"). This spec changes how Level 4 is run. It
does not change what Level 4 must answer.

## For Aedwon to approve

### What changes

Level 4 checks all 158 lessons against the lesson standards and reviews their
illustration needs. The parent plan ran it through the Codex orchestrator. You are
saving that usage for engineering, so Level 4 runs in ChatGPT web chats that you
start by pasting a prepared prompt.

The Codex orchestrator stays stopped for Level 4. Level 5 is not approved and is
not part of this spec.

### How one lesson gets audited

1. A local page shows the next lesson and a ready prompt. You copy it into a new
   ChatGPT web chat.
2. The chat reads that lesson's packet from GitHub: the brief, the current
   standards, the lesson, its prerequisite lessons, and its Level 3 findings.
3. The chat fills a fixed answer form. Every rule gets a verdict. Every finding
   carries an exact quote from the lesson. Every pass on a major rule lists what
   the chat checked.
4. The chat hands the form in through the relay. A script on your Mac checks it
   and replies. If the form is rejected, the chat fixes it in the same chat.
5. You start a second new chat for the same lesson. It reads the same packet and
   fills the same form without seeing the first result.
6. A script compares the two results rule by rule. Where both agree, the verdict
   stands. Where they disagree, the page gives you a third prompt. That chat sees
   both positions without knowing which chat wrote which, and rules with a quote.
7. The page marks the lesson finished. You move to the next lesson.

One chat handles one lesson and one role. No chat is reused.

### The guardrails

- **A script checks the mechanical rules.** Banned formatting, heading format,
  frontmatter shape, em dashes, spelling forms, and math notation never go to a
  chat.
- **No rule can be skipped.** The check rejects a form with a missing rule.
- **Quotes must be real.** The check rejects a quote that is not in the lesson.
- **Passes need proof.** A pass on a major rule must list what was checked, such
  as each formula and where the lesson first introduces it.
- **The second read is blind.** The first result stays on your Mac, off GitHub,
  until the second result is handed in. The second chat cannot look it up.
- **Planted defects measure the miss rate.** Ten lesson copies carry known errors.
  They look like ordinary lessons to a chat. Their answer key never goes to
  GitHub during the run. They are removed from the final findings.
- **Chats cannot change anything else.** The prompt allows one hand-in command.
  The script refuses to save if anything else in the audit folder changed, and
  the page shows the stop.
- **Hold list.** A lesson stops and waits if a form fails the check twice in one
  chat, if the relay fails, or if the third chat cannot settle a disagreement.
  Held lessons are reported, not forced through.
- **Version lock.** Every packet names the lesson version and the standards
  version. The check rejects a form built from a different version.

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
one Reading or General Information) and five planted lessons. That is about 20
chats.

You then get a short report: which planted errors each chat caught or missed, by
rule; how often the two reads disagreed; how many forms were rejected; and the
time per chat. You decide whether to continue, to move some rules to a stronger
model, or to stop. No pass mark is set in advance.

The other five planted lessons are spread through the full run as a continuing
check.

### What you will receive

- Findings for each lesson, each with its rule id, severity, quote, and whether
  both reads agreed or a third chat ruled.
- The illustration review for each lesson, as the parent spec defines it.
- A Level 4 summary, a count showing all 158 lessons and every rule accounted
  for, the miss-rate result from the planted lessons, and the hold list.
- A live local page showing each lesson's state.

### Cost

- Build: about 8 hours of agent work, including the planted lessons and the
  pilot report.
- Your work: about 336 pasted prompts (158 lessons and 10 planted lessons, two
  reads each), plus one more for each lesson where the reads disagree.
- Run time is unknown until the pilot measures the time per chat. Expect many
  hours of chat time in total. Your attention per chat should be short.
- At least one relay runner must be on while you work. All three were offline on
  October 10.
- ChatGPT usage limits for the chosen model are not known to this spec.

### Decisions I need from you

1. Approve this section.
2. The local page is a simple internal tool. It reuses the copy-and-paste pattern
   of the question and illustration studios. I recommend no mockup before
   building. Say so if you want to see one first.
3. Confirm the model you will select in ChatGPT web. You wrote "6 Sol". Levels 1
   to 3 used 6.1 Sol at high effort in Codex. The page will remind you which
   model to select, since a chat cannot reliably report its own.

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
  `Pantas-wt-content-coverage-audit-r1`, at `e17c26c19a63c95a99c06295eb4dafea7a2975c0`
  when this spec was written.
- Corpus input unchanged: `content/question-qa-r2` at
  `765c5dc0fa5586281047bf4f7b30d09ab3707887`. Read only.
- Relay: `Aedwon/chatgpt-terminal-relay`, production workflow on its `main`.
  Verified October 10: `workspace_write_file`, `workspace_exec`, and
  `git_push_current` exist; requests run only for Issues authored by `Aedwon`
  titled `[relay]`; results return as an Issue comment with the exit code. No
  relay change is needed. `workspace_visual_review` is not used.

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
4. **Hand-in command.** One script run through `workspace_exec`. It validates the
   form, refuses on any unexpected change in the audit folder, stores the result,
   and prints accept or the exact rejection reasons. Results wait in a local
   state directory outside the pushed folder until both reads for that lesson
   are in. Then both, the comparison, and any ruling are written to the audit
   folder.
5. **Comparer.** Per rule: both pass, both fail with overlapping evidence, or
   disputed. Builds the third prompt for disputed rules with the two positions
   labeled A and B in random order.
6. **Local page and tracker.** Shows the queue, the next prompt with a copy
   button, the model reminder, each lesson's state (pending, first read in,
   second read in, disputed, ruled, finished, held), and any stop. It reads local
   state only. It follows the existing studio pattern (local server, prompt
   template, validators).
7. **Planted lessons and key.** Ten copies, each with two or three known defects
   that together cover the major chat-judged rules. The key lives in the local
   state directory until the run ends, then is saved to the audit folder with
   the miss-rate result.
8. **Report builder.** Per-lesson findings, the illustration list, the counting
   check, the hold list, and the summary.

### Run control

- The first line of `status.md` must never be `STATE: RUNNING` during this run.
  The existing watcher resumes the Codex orchestrator in that state. Use a
  `BLOCKED` line that names the web chat run, and record why.
- Saving to GitHub reuses the watcher's existing save step for the audit folder.
  If the watcher is off, the lead pushes, or a chat uses `git_push_current`.
- The lead for this run is the agent session Aedwon assigns. The lead builds the
  system, authors the planted lessons, writes the pilot report, resolves held
  lessons with Aedwon, and accepts the level. Chats never accept their own work.
- The blind second read is the independent review for each lesson. The lead's
  final acceptance uses the counting check and a fresh run of the validators over
  all saved results.
- Order: topic by topic, prerequisite lessons first where Level 3 found a link.
- One lesson and one worktree at a time. The relay lock already serializes
  requests for one worktree.

### Stop conditions

- Unexpected changes in the audit folder or the corpus worktree.
- A packet whose lesson hash or standards commit no longer matches.
- Main's lesson standards change during the run. Stop, report, and ask whether
  finished lessons need a recheck.
- Relay or runner unavailable. Do not fall back to direct GitHub edits without
  Aedwon's decision.

### Boundaries

Findings and recommendations only. No lesson, question, illustration, importer,
schema, roadmap, app, or Google Doc change. No computer control. The original
Level 4 definition, the five-level gates, and the Level 5 model plan are
unchanged.
