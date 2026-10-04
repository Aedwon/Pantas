# Exam Content Coverage Audit Implementation Plan

> **For agentic workers:** the lead is a Codex 6.1 Sol High orchestrator
> (Aedwon, October 4, 2026), started by Aedwon in the Codex CLI. It reads
> `docs/content/audit/coverage-r1/ORCHESTRATOR.md` first and dispatches Codex
> subagents per phase. Workers read `AGENTS.md`, `WORKFLOW.md`, and `SUBAGENTS.md` from
> main first. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce the approved coverage audit: per-exam requirements and format
profiles, a tagged audited corpus tab, teaching and practice findings, and
recommendations, with every claim backed by evidence.

**Architecture:** Strict top-down phases with gates. Sol High agents research or
read within one exam or one topic. Luna agents run narrow checks. Only the lead
writes shared outputs. An independent reviewer checks each phase's output
before the next phase starts. A pilot (UPCAT and Science) runs end to end
before the full run.

**Spec:** `docs/superpowers/specs/2026-10-03-exam-content-coverage-audit-design.md`
(approved October 4, 2026). Agent structure, top-down gate, checks, and
concurrency approved by Aedwon on October 4, 2026 ("proceed").

## Levels (supersede the task order below)

Aedwon redefined the audit into five approval-gated levels on October 4, 2026;
see the spec and `docs/content/audit/coverage-r1/ORCHESTRATOR.md`. Mapping:
level 1 = Tasks 0, 2, 3, 4 (each exam's map); level 2 = a new overlap analysis
across exam maps; level 3 = Task 5 with lesson structure (sharing, splits,
prerequisites) as its focus, and Task 7 sampling; level 4 = lesson checklist
checks; level 5 = question checklist checks and Task 6. Tasks 8 and 9 follow
level 5. The pilot of Task 1 is replaced by these gates. Where a task below
conflicts with the levels, the levels win.

## Global Constraints

- Policy and standards: main `743adb84f44577a796d202100ff8df1228951a51`.
- Corpus input: `content/question-qa-r2` at `765c5dc0fa5586281047bf4f7b30d09ab3707887`
  (worktree `Pantas-wt-content-qa-r2`), read only. Confirm the commit before
  each phase; record any change.
- Outputs on branch `docs/content-coverage-audit-r1` under
  `docs/content/audit/coverage-r1/`. Format profiles are filled in that
  branch's copy of `docs/content/exam-format-profiles.md` and merged to main
  after review.
- No content, app, importer, or schema edits. No change to the original Google
  Doc corpus tab.
- Exams: UPCAT, DCAT, ACET, USTET, PUPCET, DOST undergraduate scholarship
  exam, SM Foundation scholarship exam, CSE Professional, CSE Subprofessional.
- Approval gates (Aedwon, October 4, 2026): five levels (requirements;
  outline and tags; lesson depth; practice; report). The orchestrator stops at
  the end of each level and starts the next only after Aedwon's explicit
  approval. See `ORCHESTRATOR.md`.
- Top-down gate: no lesson check starts until all requirement files, their
  source checks, the reviewer's requirement rebuild, the outline comparison,
  and the counting check are saved. Per topic, lesson depth is saved before
  its practice check.
- Concurrency: at most 3 Sol High and 5 Luna agents at once. When the Plus
  5-hour window runs low, pause and resume after the reset. Do not buy credits.
- No invented topic weights, proportions, minimum counts, or percentages.
- Every finding names its evidence; teaching and practice findings cite
  checklist rule ids.

## Agent commands

```bash
# Sol High (research, reading). Web search is live per ~/.codex/config.toml.
codex exec -m gpt-6.1-sol -c model_reasoning_effort=high \
  -c 'notify=[]' --disable computer_use --disable browser_use \
  --disable browser_use_external --disable in_app_browser -s workspace-write \
  -C <assigned worktree> -o <brief-dir>/<task>-result.md "$(cat <brief-dir>/<task>.md)" < /dev/null

# Luna (narrow checks)
codex exec -m gpt-6-luna -c model_reasoning_effort=low \
  -c 'notify=[]' --disable computer_use --disable browser_use \
  --disable browser_use_external --disable in_app_browser -s read-only \
  -C <assigned worktree> -o <brief-dir>/<task>-result.md "$(cat <brief-dir>/<task>.md)" < /dev/null
```

Close stdin (`< /dev/null`): a backgrounded `codex exec` otherwise waits for
input and stalls until the time limit. The notify override and disabled features stop Codex's computer-use client
from starting; the workflow bans computer control. Do not change the global
Codex config.

Each brief contains: the startup instruction, the policy commit, the objective,
the exact scope, input paths, output path and format, the rules to apply, and
stop conditions (missing source access, conflicting instructions, scope
needing a decision). Briefs and results live in
`docs/content/audit/coverage-r1/briefs/`. Research agents write only their own
output file. The independent reviewer is a fresh Codex Sol High subagent that authored
nothing in the phase.

## Output files

| File | Writer |
|---|---|
| `requirements/<exam>.md` | Exam agent |
| `source-checks/<exam>.md` | Luna source checker |
| `review/requirements-rebuild.md` | Reviewer |
| `outline-comparison.md` | Lead |
| `counting-check.md` | Luna |
| `topics/<subject>-<topic>-lessons.md` | Topic agent |
| `topics/<subject>-<topic>-practice.md` | Practice agent |
| `checks/<subject>-<topic>-<rule-group>.md` | Luna rule checker |
| `review/topic-samples.md` | Reviewer |
| `source-ledger.md` | Lead, from agents' entries |
| `report.md` | Lead |
| `status.md` | Lead, after every phase |

---

### Task 0: Setup

- [ ] Fetch; confirm main and the corpus commit; confirm the audit branch matches
  its remote. Record in `status.md`.
- [ ] Confirm the Sol and Luna model names with the installed Codex CLI using a
  one-line test call each; record them.
- [ ] Inventory the corpus at the input commit: subjects, topics, lessons, and
  question sets, with counts and paths. Save as `inventory.md`. This is the
  accounting base for every later check.
- [ ] Read the original Google Doc corpus tab through the Drive connector and
  save a capture (title, content, formatting summary) for the unchanged check.

### Task 1: Pilot (Science, after all exam requirements)

Revised October 4, 2026 at Aedwon's direction: the pilot no longer starts with
one exam. Tasks 2 to 4 run for all 9 exams first, so every exam's subject
inclusions are defined before any subject is examined. The pilot then runs
Tasks 5 to 7 for the Science topics against every exam that includes Science.
Then:

- [ ] The reviewer compares the pilot results with its own manual check of two
  Science topics: missed requirements, wrong "covered" verdicts, wrong tags.
- [ ] Record agent usage against the 5-hour window and any rule the agents
  misapplied.
- [ ] Fix briefs. If the pilot finds a structural problem, stop and report to
  Aedwon before the full run. Otherwise continue with all exams and subjects.

### Task 2: Exam requirements (Sol High, one per exam)

- [ ] Brief per exam: find the organizer's current published coverage, subtests,
  and format; list required topics and skills; fill the format profile entries,
  subtest mix, and topic weights only from published or verified sources;
  label confidence; save each source URL with its access date; mark unknowns.
- [ ] Run in rounds of 3.

### Task 3: Requirement checks

- [ ] Luna source checker per exam: open every cited source; confirm it says
  what the entry claims; downgrade or flag otherwise.
- [ ] Reviewer rebuilds each exam's topic list from the organizer's top source
  alone, compares with the agent's list, and records misses and extras.
- [ ] Lead resolves every flag with the source, updates requirement files, and
  writes the profiles into `exam-format-profiles.md` on the branch.
- [ ] Gate: all 9 exams pass before Task 4.

### Task 4: Outline comparison (lead only)

- [ ] Compare the original corpus tab with the inventory; record differences.
- [ ] Map each requirement to lessons; add provisional lesson tags; list gaps,
  unclear names, and relevance questions.
- [ ] Luna counting check: every inventory lesson appears once; every
  requirement is matched or listed as a gap; no tag points to a missing lesson.
- [ ] Write the separate audited tab through the Drive connector, read it back,
  and confirm the original tab is unchanged against the Task 0 capture.
- [ ] Save `outline-comparison.md`. Gate: counting check passes.

### Task 5: Lesson depth (Sol High, one per topic)

- [ ] Brief per topic: the topic's lessons, its requirement packet, the
  checklist, and the source policy. For each required skill record teaching,
  worked example, prior knowledge, and exam availability, with evidence. Check
  hard facts met during reading against sources and write ledger entries.
  Read only.
- [ ] Luna rule checkers per topic, one rule group each: lesson formatting and
  voice (L13 to L22a), source ledger presence (B04), language rules (L08 to L12)
  where Filipino lessons exist.
- [ ] Save per topic before Task 6 starts for that topic.

### Task 6: Practice against teaching (Sol High, one per topic)

- [ ] Brief per topic: questions, lesson findings, the exam profiles. Map each
  question to a skill; find skills without practice and questions testing
  untaught content; classify each mismatch with the spec's causes; investigate
  the previous audit's unresolved findings for the topic.
- [ ] Luna rule checkers: Q06 and Q06a, Q17 structure, Q19 counts.

### Task 7: Topic review

- [ ] Reviewer samples every topic: re-derive a sample of "covered" and "gap"
  verdicts and fact checks from the lessons and sources.
- [ ] Any error in a topic's sample sends that topic back to Tasks 5 and 6.

### Task 8: Recommendations and report (lead)

- [ ] Confirm or revise tags in the audited tab; read back.
- [ ] Mock composition finding against published or verified proportions only.
- [ ] Per-exam conclusions, coverage comparison, prioritized gaps, proposed
  outline, and quality improvements with costs, in `report.md`.

### Task 9: Final verification and handoff

- [ ] Independent review of the report against the spec's "What counts as a
  finished audit".
- [ ] Mechanical checks: em dashes, spelling, attribution check.
- [ ] Record results in `status.md` and the decision log; commit and push the
  branch; merge the filled format profiles to main after review.
- [ ] Report to Aedwon. Content changes need his separate approval.
