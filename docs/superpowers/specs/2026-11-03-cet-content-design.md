# CET content pass: design

Date: November 3, 2026. Status: Part A awaiting Aedwon's approval.
Policy revision read: origin/main 875d78dd, rechecked at 625ad2ca.
Decision record: `docs/superpowers/decisions/2026-11-03-post-beta-priorities-log.md`.
Evidence: `docs/future/2026-11-03-next-exam-brief.md`.

---

## Part A. Plain-language summary for approval

### What this does

It brings the content for UPCAT, DCAT, USTET and ACET up to the standards CSE now meets. Lessons come first, then questions are fixed to match them. Aedwon approves this page once and next sees the work at a final review.

### What changes from the CSE process

CSE ran as read, triage, rewrite, read again. This pass drops the separate audit and triage. Each writer works directly from the content standards and the audit's Level 3 findings for that lesson. A different model then reads the result, and the two repeat until the lesson is clean. Aedwon pastes nothing.

Why: the CSE rewrite got its own full read anyway. Of 866 audit findings, 233 were judgment calls that needed triage. The risk is that writers miss what a separate audit would catch, so the pilot tests this first.

### Scope

| Work | Size | When |
|---|---|---|
| Lessons not yet rewritten | 69 lessons with 1,389 questions: science 46, mathematics 18, reasoning 3, reading 2 | Pilot on approval, the rest after the pilot passes |
| Lessons shared with CSE | 63 lessons | Only after CSE is signed off and uploaded |
| Questions | About 2,695 questions across the 132 lessons, less those already blind-solved for CSE | After their lessons |
| Figures and exam tags | Figures the lessons need; exam tags corrected to the audit's | With their lessons |

Not included: PUPCET, DOST-SEI and SM Foundation; web prices, the exam picker and end-of-mock screens, which get their own spec; uploading anything; animated figures.

### Rules that protect CSE

- This work does not change the text of a CSE lesson. CET-only depth goes in new lessons that only the CETs see.
- If a reader finds a wrong fact in a CSE lesson, it goes on the final list. If that lesson is already live for students, Aedwon hears right away.
- Beta and launch work comes first. If that work needs Codex or the machine, this pass pauses.
- Nothing reaches students without Aedwon's final approval.

### Keeping you out until the end

- **Pilot:** the lead runs 15 lessons, then applies the criteria below. It does not ask.
- **Standards questions:** the lead rules and logs each one for your review.
- **Stuck lessons:** a lesson still failing after 5 rounds is parked for your final list.
- **Usage limits:** the run waits for the reset and continues.
- **You are interrupted only for:** a wrong fact in a live lesson, or a change to what this page approves.

**Risk:** a bad ruling can spread across many lessons before you see it. That costs rework at the end, not a bad release. Pilot checks and the Astra audit reduce it but do not remove it.

### Pilot criteria

The pilot passes if all of these hold:

- At the first read, the share of lessons with a Blocker or Major is no worse than CSE's first pass (54 of 86, or 63%).
- All 15 finish clean or minor-only within 5 rounds, with at most one parked.
- The lead's own read of 3 lessons finds no wrong fact the reader missed.
- Lessons stay under the 1,700-word ceiling.

If it fails, the rest of the 69 get a separate audit read first, using the packets already built. That adds the triage step back.

### Models

Recommended: Sonnet 5.5 writes, Codex GPT 6.1 Sol reads.

- **Why not wait for Sol to write:** writing can start now. All three Codex accounts are nearly full until tomorrow afternoon (about 19 hours), and the Nov 3 app build also needs them.
- **Why Sol reads:** no model checks its own work, and a different vendor catches blind spots that Claude models share.
- **Pilot test:** Sol writes 5 of the 15 lessons and Sonnet reads those. The lead keeps whichever writer gets better first reads for the rest. A tie goes to Sonnet, because Codex is the scarcer resource.
- **Others:** Haiku runs counts and checks. Astra audits once at the end. The lead rules and reviews.

### Complexity

| Level | What it includes | Tradeoff |
|---|---|---|
| Minimal | The 69 lessons and their questions only | Least work, but the bundle cannot ship: shared lessons keep unchecked CET gaps |
| **Balanced (recommended)** | Everything in the scope table, one read loop per lesson, one Astra audit | Same assurance as CSE, minus triage |
| Hardened | Balanced plus two independent reads per lesson and Astra on every lesson | Roughly doubles reading and uses much more scarce Codex quota |

### Effort and uncertainty

The CSE rewrite loop took about three days for 86 lessons, with blind solves overnight and figures later. Expect about 1 to 2 weeks elapsed for the 69 lessons and their questions, depending on usage resets and engineering's needs. This is a rough estimate, and the pilot will refine it. The shared lessons follow after CSE sign-off. Your final review time is unknown until the pilot, and it is the largest cost: 132 lessons and their figures.

Claude and Codex subscription usage is the only spend. No new subscription is needed.

### How completion is judged

- Every lesson in scope is clean or minor-only, or is on the parked list with a reason.
- Every question in scope has an independently confirmed answer key.
- Every lesson teaches what its questions test.
- The Astra audit's findings are resolved, and its error rate on the random sample is reported.
- The content builds and passes the existing import and export checks.
- CSE lesson text is unchanged, shown by a file comparison.
- You receive one review package and approve or return it.

### Facts to know

- **Exam dates:** no school has announced dates for the next cycle, so this targets a March 2027 start by past pattern.
- **Tags:** the older tags showed 128 lessons for DCAT and the audit shows 84. Correcting them changes what each exam's students see, so some lessons will disappear from a CET.
- **Depth:** most CETs publish no syllabus, so depth rests on the audit's curriculum evidence. No lesson claims that a specific exam tests something without a source.
- **Public repository:** this content, including Pro content, stays readable by anyone, as you accepted on October 25. Consider making the repository private before launch.

### Approval

Approve this Part A, and choose a complexity level.

---

## Part B. Agent section

### B1. Verified state (November 3, 2026)

| Item | State |
|---|---|
| Base | `origin/content/cse-rewrite-r1` at 7032eec5. Corpus at audit: 765c5dc0 (158 lessons). Now 170 lessons. |
| Audit | `docs/content/audit/coverage-r1` on `origin/docs/content-coverage-audit-r1` at ecbfa88b. Levels 1 to 3 cover nine exams. Level 4 packets exist for all 158 lessons plus 10 planted; only CSE lessons were read. |
| CSE rewrite scope | 90 lesson files changed between 765c5dc0 and the base. |
| CET tags | Audit tags in the SSOT tab Pantas Audited Corpus r1 and the audit's Level 1 maps. Lesson files carry no exam tag; `meta.exams` in question files decides membership (`build_content_export.dart`, `functions/src/_examContent.ts`). |
| Tag differences, four CETs, audit lessons | Audit has and file lacks: ACET 13, USTET 4, UPCAT 9, DCAT 11. File has and audit lacks: ACET 12, USTET 28, DCAT 44, UPCAT 5. Three files with CET tags are not audit lessons: `quantum-numbers-electron-configuration`, `angles-and-radian-measure`, `filipino-verb-aspect-and-focus`. |
| Question counts | 69 lessons: 1,389 entries, none under 20. All 132: 2,695. Rough parse; the plan recounts with the importer. |
| Tools on base | `tools/content_rewrite/` (`build_briefs.py`, `mechanical_fix.py`, `check_question_typing.py`, `relay/` with `checks.py`, `readfindings.py`, `readpacket.py`, `planner.py`). `docs/content/rewrite/` (batches, briefs, figure-briefs, reads, figure-style). `docs/content/audit/cse-rewrite-ledger.md`. |
| Blueprints | `content/mock/` on the base holds `cse-pro`, `cse-sub`, `upcat`. Staging also holds `acet`; ACET time began as a placeholder (restart log, item 7). |
| Codex capacity at writing | a 100%, b 95%, c 96% weekly. Resets November 4 at 14:45, 18:20 and 14:51. The Nov 3 hardened app build also uses Sol. |
| Claude capacity | This session's usage tool reports plan "Pro", 31% weekly. Aedwon states this is the Max account; unresolved. Recheck before dispatching. |

### B2. Branch and isolation

Work on a new branch `content/cet-rewrite-r1` from the base, in its own worktree. Merge the base's later commits in when CSE changes. Publish nothing to main except status and decision records. Do not merge into staging; a later release decision takes the branch. Follow `docs/workflow/orchestrator.md` where it fits; run few parallel jobs, because Aedwon has flagged storage and CPU throttling.

### B3. Phases

**P0. Inputs.** Saved lesson list: 69 lessons from the audit tags, excluding the 90 rewritten. Per-lesson brief built from `requirement-teaching-findings.md`, `lesson-structure.md` and the topic artifacts. Brief states each requirement's evidence class: official, curriculum, weak or unknown. Teach official and curriculum items. Weak-only items are taught only where they add little length. Unknown items are not taught and not claimed. Reuse `build_briefs.py`; extend it rather than copying it. Current standards: `docs/content/lesson-style-guide.md`, `docs/content/question-style-guide.md` and the checklist at the branch revision, including `AGENTS.md` voice and Filipino rules.

**P1. Pilot.** 15 lessons chosen from the 69: chemistry 3, physics 3, earth science 2, biology 2, geometry 2, algebra 1, mechanical reasoning 1, text types 1. Assign 10 to Sonnet writers and Sol readers, and 5 to Sol writers and Sonnet readers, spread across subjects. Record per lesson: first-read findings by severity, rounds, words, tool failures, rejected hand-ins. The lead reads 3 lessons in full. Apply the Part A criteria and record the verdict.

**P2. Remaining lessons.** Topic by topic. Fresh reader per round, never the writer's model. Lesson parked after 5 rounds. Mechanical fixes through `mechanical_fix.py`. Figure markers follow `docs/content/rewrite/figure-style/`: briefs from the rewritten lesson, Sonnet draws static SVG, the render check runs, a different model checks each against its text. Mark animation candidates.

**P3. Shared lessons.** Starts only after Aedwon's CSE sign-off and upload. For each of the 63, compare CET findings with the current lesson. If the gap is taught, make no change. If not, plan a new CET-only lesson, using the audit's Level 3 split candidates. A CSE lesson's text is not changed. Corrections found in a CSE lesson are logged for the final list; if the lesson is live, tell Aedwon immediately.

**P4. Tags.** Apply the audit's tags to `meta.exams` for the four CETs only. Never change `cse-pro` or `cse-sub` tags in this pass. Resolve the three non-audit files by reading the exam maps. New lessons get CET tags only. Record every change. Check each exam's mock pools still fill their blueprints after the tags change.

**P5. Questions.** After a file's lesson passes. Blind solve every question not already solved for CSE; a second model settles disagreements; Sol solves what Sonnet wrote and the reverse. Check each file against its lesson for wording, clues, explanations, wrong-choice notes and untaught skills. Fix or deactivate; add questions when a file falls under 20 active. Run `check_question_typing.py` and the import check. Near-duplicates are allowed until the generator exists. Style rules: quiz language realistic for the exam; explanations at Grade 5; Filipino content per `AGENTS.md`.

**P6. Roadmap inputs.** Add required and helpful links to `content/lesson-prerequisites.json` and gap tags to `content/question-gap-tags.json` for CET lessons. This resolves the UPCAT link finding in `plans/pwa-launch/R1-R2-roadmap-plan.md`. Do not change existing CSE links.

**P7. Mock data.** Recheck UPCAT and ACET blueprints against the official sources in the brief. Replace placeholders only with sourced values; otherwise mark them placeholder. Write a DCAT or USTET blueprint only with a reliable published format. If none exists, put the choice on the final list. `AGENTS.md` "Never invent a figure" applies.

**P8. Astra audit, once.** Every Blocker fix, every changed answer key, every new lesson, every large rewrite, plus a random 10% of everything else. The lead verifies each finding against sources before applying it. Report the error rate on the random sample. Audit only; Astra does not fix.

**P9. Review package.** One document: counts, what passed, parked lessons, every lead ruling, tag changes, CSE corrections, blueprint choices, audit results, and any figures needing visual checks. Aedwon performs visual checking. Return items re-enter at P2, P3 or P5.

### B4. Stop conditions and yielding

Stop and tell Aedwon only for: a wrong fact in a live lesson; a required change to Part A; or a required change to approved CSE text that cannot wait. Yield to engineering when the Nov 3 build or beta work needs Codex or CPU, and resume after. On usage limits, follow `codex-pick` exit code 75: report it in the status record and resume after the reset. Do not move the same step to a tool the plan does not name. A model never reads its own work: if the other vendor is unavailable, the read waits.

### B5. Records

`STATUS.md` on the branch after each phase and batch. Lead rulings and exact Aedwon comments in the decision record above. SSOT readiness tab updated when each phase completes. Sources for exam claims go in the ledger. The separation of implemented, reviewed, integrated and accepted states follows `WORKFLOW.md`.

### B6. Open technical risks

- Tag correction removes lessons from DCAT and USTET. Check the roadmap and mock pools for those exams before accepting P4.
- Rule L18 (example coverage) caused 12 of 20 Majors in the CSE pilot. Reuse the CSE ruling that judges it by cases the exam tests. Most CETs have no such published cases, so the plan must define the substitute from curriculum evidence.
- The 1,700-word ceiling may force splits in dense science lessons. New splits change question file paths; keep question ids unchanged, as the CSE splits did.
- The ChatGPT relay is not used, so its connector refusals do not apply. The hand-in checks (`relay/checks.py`) should still gate commits; the plan confirms they run without a chat.
