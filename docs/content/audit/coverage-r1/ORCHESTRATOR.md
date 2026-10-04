# Coverage audit orchestrator handoff

You are the **lead and orchestrator** of the Pantas exam content coverage audit,
running as Codex 6.1 Sol High. You dispatch Codex subagents, check their work,
write the shared outputs, and report to Aedwon. Claude is not part of this run.

## Read first, in this order

1. From main (`git fetch origin` then `git show origin/main:<path>`):
   `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`, `docs/content/source-policy.md`,
   `docs/content/exam-format-profiles.md`, `docs/content/content-checklist.md`,
   and both style guides in `docs/content/`.
2. In this worktree (branch `docs/content-coverage-audit-r1`):
   - Spec: `docs/superpowers/specs/2026-10-03-exam-content-coverage-audit-design.md` (approved).
   - Plan: `docs/superpowers/plans/2026-10-04-exam-content-coverage-audit.md`.
   - Decision log, October 4 entries:
     `docs/superpowers/decisions/2026-10-01-question-explanations-log.md`.
   - Current state: `docs/content/audit/coverage-r1/status.md`.

The spec and Aedwon's recorded decisions govern. If this file and the plan
disagree, follow the plan and report the conflict.

## Non-negotiable rules

- **Strictly top-down.** Every one of the 9 exams must have its requirements
  written, source-checked, and independently rebuilt, and the outline
  comparison and counting check must be saved for all exams, before any subject
  or lesson work starts anywhere. Aedwon stopped the previous run twice for
  breaking this. Do not start a subject-level task early for any reason.
- **No computer control or browser automation.** Web search and page reading
  only, for you and every subagent.
- **Read only on content.** No edits to lessons, questions, importer, schema, or
  app code. The corpus input is `content/question-qa-r2` at
  `765c5dc0fa5586281047bf4f7b30d09ab3707887`, worktree
  `/Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2`.
- **Concurrency:** at most 3 Sol High subagents and 5 Luna subagents at once.
  When the Plus 5-hour usage window runs low, stop dispatching, save state in
  `status.md`, and tell Aedwon. Do not buy credits.
- **Separation:** research and reading subagents write only their own output
  file. Only you write shared outputs (`outline-comparison.md`, tags, the
  Google Doc tab, `report.md`, `status.md`, profiles). The independent reviewer
  for a phase is a fresh subagent that authored nothing in that phase.
- **Evidence:** every claim cites a source or is marked unknown. No invented
  topic weights, proportions, minimum counts, or percentages. Teaching and
  practice findings cite checklist rule ids.

## Run state and automatic resume

You run unattended. A watcher on Aedwon's Mac (`autorun/run.sh` in a Terminal window, every 10
minutes) resumes you after usage-limit stops with a message that says it is an
automatic resume. That message is never Aedwon and never an approval.

Keep the **first line of `status.md`** exactly one of:

- `STATE: RUNNING`: you are working on the current level.
- `STATE: AWAITING_APPROVAL level <n> done; asking to start level <n+1>`:
  set this when a level is finished, before you stop.
- `STATE: BLOCKED <short reason>`: set this when a stop condition needs Aedwon.
- `STATE: COMPLETE`: after the final report.

The watcher only resumes you while the state is `RUNNING`; otherwise it
notifies Aedwon. When Aedwon approves the next level in conversation, set the
state back to `RUNNING`, record his exact words, and continue.

Update `status.md` after every subagent result, so a resume can continue
without repeating finished work.

## Approval gates: never go down a level without Aedwon's approval

The audit has five levels, defined by Aedwon on October 4, 2026 (spec, "The
order of the audit"). Finish a level completely, including its checks, then
stop, report to Aedwon, and wait. **Do not start any task in the next level
until Aedwon explicitly approves moving to it in this conversation.** A
question, a comment, or silence is not approval. If unsure, ask.

The whole audit is findings and recommendations only. No lesson, question, or
app content changes at any level.

1. **Exam maps.** Every exam's requirements, subjects, topics, format profile,
   and its own map to the app's lessons; source checks, independent rebuilds,
   and resolved flags; the all-exam counting check; the audited Google Doc tab
   with lesson-level exam tags.
2. **Overlap.** Which exams share which subjects, topics, and lessons, in full
   or in part, with the differences in depth or scope stated.
3. **Lesson structure.** The most important level. Read every lesson. Find
   shareable lessons; lessons carrying more than an exam needs, where the extra
   should be its own lesson; crammed lessons that should be split; and
   prerequisites, including content inside one lesson that is really a
   prerequisite for another. Confirm level 1's apparent coverage. Recommend a
   split only when it improves focus or learning.
4. **Lesson standards.** Every lesson against the content standards and
   checklist, each finding with its rule id and evidence.
5. **Quiz standards.** Every question set against the question standards and
   checklist, plus practice against teaching.
   Model use (Aedwon, October 4, 2026): Luna runs the mechanical rules and a
   blind solve of every question; any blind answer that differs from the key
   goes to a Sol subagent to confirm. Before the full run, test Luna on a
   sample of about 50 questions across subjects, including hard Mathematics,
   Science, and Filipino items, and compare its verdicts with a Sol subagent's.
   Report the agreement to Aedwon at the level 5 gate. If Luna agrees on the
   judgment rules (plausible wrong choices, answer clues, explanation
   quality), it runs them too; otherwise those rules go to Sol or to Luna at a
   higher effort.

After level 5, write the report and recommendations (plan Tasks 8 and 9), then
stop for Aedwon's review.

At each stop, report in short plain sentences: what was done, what the checks
found, what remains uncertain, and the exact next level you are asking to
start. Record Aedwon's answer in the decision log with his exact words.

## Subagents

Use Codex's built-in subagents. Give each one its brief file's full text plus
the startup rule above. Use 6.1 Sol High for research and reading, and 6 Luna
(low effort) for narrow checks. A test on October 4, 2026 confirmed that
Codex subagents can be spawned, can use live web search, and can be given a
model.

Ready briefs in `docs/content/audit/coverage-r1/briefs/`:

- `t2-requirements-<exam>.md` for dcat, acet, ustet, pupcet, dost-sei,
  sm-foundation, cse-professional, cse-subprofessional. UPCAT is done.
- `t3-source-check-upcat.md`: template for each exam's source check (replace
  the exam name and paths).
- `t4-counting-check-pilot.md`: template for the all-exam counting check.
- `t5-lessons-science-<topic>.md`: superseded drafts from before the level
  structure. Do not use them; write level 3 briefs from the spec when level 3
  is approved.

Write new briefs in the same folder for any task without one. Briefs and their
results are part of the audit record.

## Where things stand

- Done: setup (inventory, original Google Doc tab capture), UPCAT requirements
  with source check, independent rebuild, and revision. UPCAT gate passed.
- Draft, partial: `outline-comparison.md` covers UPCAT Science only. Extend it to
  all exams and subjects in Task 4. Keep its findings but rebuild tags from all
  exams.
- Not started: requirements for the other 8 exams. Three were started and
  stopped with no output.

## Lessons from the run so far

- Requirement agents must use the DepEd curriculum (tier 2) as well as
  organizer and reviewer sources, and must record delivery and scoring. The
  briefs now say so.
- DepEd's Science curriculum guide returned HTTP 403 to page fetching. A direct
  download worked:
  `https://www.deped.gov.ph/wp-content/uploads/2019/01/Science-CG_with-tagged-sci-equipment_revised.pdf`.
- Check a claim of absence against the full source text before writing it. An
  earlier draft wrongly said the curriculum lacked gas laws.

## Next steps

Level 1 is in progress. UPCAT is done; the partial UPCAT Science outline draft
becomes part of UPCAT's map.

1. Requirements for the 8 remaining exams, 3 Sol subagents at a time.
2. Per exam: Luna source check, independent rebuild by a fresh Sol subagent,
   then you resolve flags with sources.
3. Each exam's own map to the app's lessons (by name and keyword, marked
   provisional), the all-exam counting check, and the audited Google Doc tab.
   If you cannot write Google Docs, stop before the tab and report it.
4. Stop and report. Level 2 starts only with Aedwon's approval.

## Records and saving

- Update `status.md` after every task: what changed, checks and their results,
  what is unverified, and the next step.
- Append each Aedwon decision to the decision log with his exact words.
- Do not commit or push. Codex's sandbox keeps git metadata read-only; the
  watcher commits and pushes your saved files to `docs/content-coverage-audit-r1`
  while you are idle. Read main's policy with `git show origin/main:<path>`;
  the watcher fetches before each resume. Do not push to main, open pull
  requests, or delete branches.
- Report to Aedwon in short, plain sentences, following `WORKFLOW.md`'s writing
  rules.
