# CET content finish under the bite-sized rule

Date: November 19, 2026. Lead: CET finish lead (Opus 5.5), reporting to the operations manager.
Policy read: `origin/main` be5da7afa (AGENTS.md, WORKFLOW.md, SUBAGENTS.md, orchestrator.md,
process-improvement.md, operations-manager.md). Velocity row: E-125.

Aedwon, Nov 19, verbatim: "can you please have a sub thread continue the CET corpus. have it follow
the bite-sized rule to make things consistent".

Controlling documents: bite-sized spec `docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md`
(B3 rules, B6 gates, B8 agent layers); backlog A11 with C6, C7, D3, D9 and gate C5
(`docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`); CET run report
`docs/content/rewrite/cet/final-run-report.md` on `content/cet-finish-r1`; math lane report
`docs/content/math-for-generator/report.md` on `content/math-for-generator-r1`.

Complexity: balanced, the level Aedwon chose for the bite-sized spec. CET follows the same
pipeline as the CSE subjects so the two corpora match.

## What was found (Nov 19)

1. **The CET line moved after the pause.** `content/math-for-generator-r1` (Nov 17) is built on
   `content/cet-finish-r1` 63a4643cc. It brought the 49 live Algebra parts onto the CET line,
   ran Astra on all 18 rewritten CET math lessons (32 findings fixed and checked), and checked 311
   math questions (no wrong key). `content/pshs-nce-r1` 68968b3e0 is built on top of that and adds
   PSHS-NCE lessons. So the CET work to finish is on `pshs-nce-r1`, not on `cet-finish-r1`.
2. **Prod content** is `content/fix-figure-series-0019` 646326517 (Nov 17). Its merge base with
   the CET line is 7032eec5b (Nov 2). Shared CSE topics are split there; the math lane took only
   math paths. About 25 science, reading and reasoning files still conflict (mostly em dash and
   ordering edits on the prod side), plus `lesson-prerequisites.json`, `question-gap-tags.json`,
   the question ledger and mocks.
3. **Scope of the split.** 85 CET-only lessons are still unsplit (Algebra is done):

   | Topic | Lessons | Median words | Parts, rough | ILLUSTRATION markers |
   |---|---|---|---|---|
   | Geometry | 8 | 1,975 | 38 | 50 |
   | Precalculus and basic calculus | 4 | 867 | 8 | 0 |
   | Statistics and probability | 5 | 1,299 | 19 | 4 |
   | Trigonometry | 7 | 2,201 | 35 | 13 |
   | Mechanical-technical reasoning | 2 | 1,272 | 6 | 6 |
   | Biology | 13 | 1,943 | 62 | 21 |
   | Chemistry | 17 | 2,417 | 100 | 32 |
   | Earth science and astronomy | 12 | 1,899 | 63 | 31 |
   | Physics | 17 | 2,227 | 95 | 39 |
   | Total | 85 | 2,030 | about 425 | 196 |

   Words are a rough token count from `cet-finish-r1`; step 1 re-measures with main's size check.
   Questions in these 85 lessons: about 1,700, none on the approval ledger.
4. **Astra stage 2 shrinks.** The math lane already audited every CET math lesson. What is left of
   the 61 is the science and reasoning lessons.
5. **Figures:** 44 of 194 drawn (Nov 10); batch 3's accuracy check is pending; batches 4 to 12 and
   14 to 19 remain (`figures-plan.md` on `cet-finish-r1`).
6. **35 CET-level Algebra skills** that the retired CET Algebra rewrites taught are in no live part
   (math lane open item 2).
7. **Gate C5:** every CET exam shows "Coming soon" on staging and prod, so the CET-account proof
   needs a CET exam selectable on staging first.

## Lead rulings (routine, logged here)

- R1. Content branch `content/cet-bite-r1` from `content/pshs-nce-r1` 68968b3e0 (it holds every
  CET change plus the math audit), then merge the prod root 646326517. Conflicts: shared CSE files
  take the prod side; CET-only files keep the CET text; P4 exam tags are re-applied on top.
  Pending the manager's answer on PSHS lane ownership (question 1 below).
- R2. A shared, already approved question whose only change is its `meta.exams` (P4 tags) is
  re-approved on its existing re-solve evidence, after a script shows that stem, choices,
  rationales, explanation and figure are byte-identical. Anything else needs a new re-solve.
- R3. Astra stage 2 is replaced by the spec's per-subject audit (B8 step 8) run after each split,
  widened to read every science and reasoning part for false general statements, the CET run's
  most common finding. This audits the text once, in its final form, instead of twice.
- R4. Figures are drawn before the split, so each marker moves into its part with its SVG.
- R5. Writers are Sonnet 5.5 (spec B8 step 3), so splitting can start before the Codex reset.
  Re-solves and audits run on Codex after Nov 22 13:51 PHT, as the CSE subjects did. Codex Sol
  work in this lane uses GPT 6.2 Sol (`codex-pick exec -m gpt-6.2-sol`), Aedwon, Nov 19: "have it
  use 6.2 Sol btw". This overrides the 6.1 Sol default for CET only.
- R7. When an audited fix changed a worked example inside a live part, the retired original gets
  the same text, so a rollback restores the fixed version and the nothing-dropped check passes.
  Nothing else in a retired original changes. Five retired Algebra originals that held CET-rewrite
  text were set back to prod's text; that rewrite text is the source for the restored skills.
- R8. Four new PSHS-NCE lessons sit in topics that are already split (two in arithmetic, two in
  spatial reasoning) and fail the size or part check. The uploader refuses the whole root on that,
  so they are split in this lane. They have no student reads, so they are replaced by their parts
  with no retired original.
- R6. C7 (8 backslash display problems in `light-and-optics.yaml`) is fixed in the physics batch.

## Steps

Phase A, now (Claude only, no Codex):

1. Branch and merge (R1). Run main's tools on the content root: export, lesson check, approval
   gate, validator. Record the baseline failures. Haiku runs the checks; the lead resolves conflicts.
2. Measure the 85 lessons with main's size check (Haiku): words, examples, traps, markers.
3. Figures: Opus accuracy check of batch 3, then batches 4 to 19 in style D (Sonnet brief writer
   and drawer, offscreen render, Opus checker, lead review), the pipeline in `figures-plan.md`.
   Update the illustration inventory at the end. Runs alongside steps 4 and 5.
4. Split plans per topic (Sonnet): parts, one idea each, key points, which examples, traps and
   markers go where, question-to-part map, pool gaps. The lead reviews every plan.
5. Rewrite one topic at a time (Sonnet): part files, originals retired with `replacedBy`,
   `ordering`, outline rows, prerequisite links. Gates after each topic: size, nothing-dropped,
   lesson audit, validator, em dash 0. Order: Physics (with C7), Chemistry, Biology, Earth science,
   Geometry, Trigonometry, Statistics, Precalculus, Mechanical reasoning.

Phase B, after Nov 22 13:51 PHT (Codex through `codex-pick`, one job at a time, each sized to one
account's 5-hour window, writing results as it goes):

6. Re-tag questions to parts from the approved maps (script, Haiku). Write pool-gap questions
   (Sonnet; Math items by two separate authors).
7. Independent re-solve of every question in the split topics (Codex GPT 6.2 Sol, about 7 jobs of 250).
   The lead rules on each disagreement and approves through `approve.dart`. Evidence in
   `docs/content/verification/<topic>.md`.
8. Astra audit per subject (R3). Sonnet fixes, an independent check, the lead accepts.

Phase C, release:

9. P9 review package for Aedwon, with the final-list items: B10 on the structural-stability title,
   distribution functions and normal-curve areas, ACET verbal logic (20 questions for 45 slots),
   no DCAT or USTET blueprint, roadmap links pointing outside ACET, DCAT and USTET.
10. Hand the content root to the integrator: export with main's tools, staging upload, C5 proof
    on a CET-exam account (credit carry-over, catalog refresh, retired-id redirect). Prod content
    after Aedwon's "ship it". Opening any CET exam to students is his separate decision.

## Estimate (E-125)

Active about 14 h; wall about 6 days (Nov 19 to Nov 25), most of it the wait for the Codex reset
and serial Codex jobs. Phase A about 6 h active over Nov 19 to 22; Phase B about 6 h over Nov 22
to 24; Phase C about 2 h plus the integrator. Waits for Aedwon excluded. Uncertain: CET is about
8 times the Algebra split (E-091, actual 1 h wall), and the figure phase has no logged actual.

## Questions for the manager

1. Is the PSHS-NCE lane still writing on `content/pshs-nce-r1`? Default: the CET branch starts from
   its head and that lane rebases onto `content/cet-bite-r1` before its next content commit. Its 5
   new lessons stay its own and need the bite-sized treatment in that lane.
2. The 35 lost CET Algebra skills: default is to restore them as new Algebra parts, moved from the
   retired rewrites' text, in Phase A (about 8 to 10 parts and their questions). The alternative is
   to leave them as a listed gap.

## Progress

- Nov 19: manager answers: branch from `content/pshs-nce-r1` 68968b3e0 (lane idle), restore the 35
  Algebra skills. `content/cet-bite-r1` created and merged with prod root 646326517 (c653e45b4):
  474 shared questions re-approved under R2 (`docs/content/verification/cet-exam-tags.md` on the
  branch). Gate after merge: 116 Algebra questions edited after approval (math lane fixes, re-solve
  in Phase B), 1,193 CET questions changed since the frozen list, 240 not approved.
