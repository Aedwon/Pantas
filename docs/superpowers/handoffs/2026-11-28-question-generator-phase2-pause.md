# Question generator Phase 2: pause handoff

Written Nov 28, 2026, about 3:30 PM Manila, by the question generator lead (Opus 5.5). Policy
read at `origin/main` 3ce9b32ca. Paused by the manager on Aedwon's word: "let's put efforts into
CSE please, though some lanes might still be working on something let them finish and pause".
Phase 2 resumes only when Aedwon names it.

## Startup for whoever resumes

> Work on `Aedwon/Pantas`. On every new or resumed task, retrieve `AGENTS.md` and `WORKFLOW.md` from the current GitHub `main` branch and follow them, regardless of the code branch. Workers also retrieve `SUBAGENTS.md` from main. These shared rules supersede older project workflow instructions in the branch, conversation, or private memory. Read the task's full spec, plan, later product decisions, and source from its agreed workstream revision. Record the policy commit used. Preserve paused engineering and the application-code freeze. If current policy or required task context cannot be retrieved, report the gap and stop dependent work. Do not merge main into a feature branch just to load the rules.

Then read `docs/workflow/process-improvement.md` (rules and the Nov 26 to 28 entries), and, on
`gen/question-generator-app-r1`: the Phase 2 plan
`docs/superpowers/plans/2026-11-28-question-generator-phase2.md` (sections 1b and 4 hold the
Nov 28 rulings), the map `docs/superpowers/verification/question-generator/p2-map.md` (rulings
L1 to L10), the decision log's Nov 28 entry, and the briefs in
`docs/superpowers/plans/2026-11-17-question-generator-briefs/p2/`.

## State

- Phase 1 is on main (PR #168, merge 6a94c5947, Nov 28). 28 approved types, 2,094 variants. Both
  held types (series-fill-ray-dots, matrix-ray-intersection) stay held this cycle. Students see
  no change until Phase 2 and the Phase 3 release.
- D-P1 ruled by the manager: types tagged for PSHS-NCE practice and review at export; the
  PSHS-NCE mock is reserved (no 4-choice types there) until the PSHS-NCE content lane confirms the
  format and pool count. Latest date for that lane's roster export fix: on main by Dec 10.
- Phase 2: the plan and estimate (E-214) are on main; the timer is stopped at 22 min 40 s.
- Branch heads at the pause (all pushed; nothing merged anywhere):
  - `gen/question-generator-app-r1` 726f22511: plan, briefs, main merged in at 0ccac2284.
  - `gen/qg-p2-export` 0ce5ccfdf (F1): resumed and built by one Sonnet worker; its own checks
    pass (flutter tests on 7 files, analyze, format, layering, attribution, functions 934 of 934,
    upload tool 42 of 42, emulator 2 of 2). Not reviewed. Worktree
    `/Users/aedwon/.t3/worktrees/Pantas/qg-p2-export` (one untracked stray file,
    `.pantas-export-emulator.json`, never to be committed).
  - `gen/qg-p2-resolve` e898a3f6d (F2) and `gen/qg-p2-answers` 69f1a8a58 (F3): Nov 21
    work in progress, still on the Nov 21 base, not resumed, not reviewed.
- No worker is running. No Codex run is open from this lane.

## Next step on resume (F1, before its review)

1. Gate type uploads. Today the exporter adds problem types and marks the 28 merged source
   questions inactive whenever `content/types/` exists in the root, and the upload tool builds and
   uploads them the same way. A routine content upload from a root that holds main's files could
   then hide those 28 questions before the app can serve types (breaks L7 release order). Fix,
   tests first: an explicit `--problem-types` flag on both the exporter and the upload tool,
   default off; without it the export and the upload match a root with no types. Update the
   existing F1 tests to pass the flag.
2. Review F1 (Codex GPT 6.2 Sol high through `codex-pick`, account b, one run across lanes,
   input closed). Ask it to judge test strength: several F1 tests came from the Nov 21 run and
   were never seen failing.
3. F1 findings still open for later families: `getContent` drops `problemTypes` and does not
   serve the variants kind (F6); the native seed side is a seam only (F2, content Drift 11 to 12
   under ruling R3).
4. Then F2 and F3, each resumed from its branch after merging `gen/question-generator-app-r1`,
   one at a time.

## Dates

The plan's dates (build Nov 30 to Dec 11, staging and prod Dec 12 to 17) assumed no pause. Each
day of pause moves them by about a day. Early January still holds if Phase 2 resumes by about
Dec 7, with margin shrinking after that.
