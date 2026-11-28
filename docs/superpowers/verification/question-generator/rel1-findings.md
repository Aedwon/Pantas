# Release R1 findings, November 17

- Startup policy origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885 satisfies 1295c1866 floor. Fetch denied external FETCH_HEAD; git ls-remote confirms cached origin/main equals live main. Initial worktree clean.

## Needs the lead

- Requested plain git mv inherently stages, conflicting with "stage nothing". External worktree Git metadata is also read-only in this session. Release moves require a lead ruling or execution; continuing independent checker, source and analyzer work.
- The assigned spec still says "Start size: 100 versions per type" (line 86), and contains no Revision 1. Task says Revision 1 permits 20 to 99. Per explicit stop rule, release activation waits for the lead's recorded revision; independent floor enforcement and source-default work can proceed because the existing spec already requires 20 for counting a type.

- Capacity qt-spatial-abstract-reasoning-series-corner-edge-count: distinct ruleKeys: 8; distinct signatures: 40; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-dots-size: distinct ruleKeys: 18; distinct signatures: 90; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-interleaved-count: distinct ruleKeys: 161; distinct signatures: 161; 100 reachable: yes

- Capacity qt-spatial-abstract-reasoning-series-outline-triple: distinct ruleKeys: 12; distinct signatures: 12; 100 reachable: no
- RED: floor tests reject current behavior at 0 and 19 variants; 20 passes the floor assertion. Existing CLI test concurrently hit a missing objective_c.dylib during Dart native hooks. Serialize further Dart/Flutter checks after capacity enumeration.
- Enforced floor at the active file boundary, leaving individual-variant solver tests and held schema checks unaffected. Updated CLI and shared checkTypeFiles default to 646326517, which run_checks wiring uses through GeneratedTypesCheck.

- Capacity qt-spatial-abstract-reasoning-series-size-corner-ray: distinct ruleKeys: 48; distinct signatures: 48; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-size-fill: distinct ruleKeys: 2; distinct signatures: 10; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-transfer-count: distinct ruleKeys: 9; distinct signatures: 45; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-binary-fill: distinct ruleKeys: 6; distinct signatures: 24; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-double-fill: distinct ruleKeys: 5; distinct signatures: 5; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-two-fill-steps: distinct ruleKeys: 3; distinct signatures: 12; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-arrow-alternation: distinct ruleKeys: 4; distinct signatures: 14; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-two-arrow-turns: distinct ruleKeys: 4; distinct signatures: 14; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-net-adjacent-relation: distinct ruleKeys: 25; distinct signatures: 25; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-net-all-opposites: distinct ruleKeys: 7; distinct signatures: 7; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-net-nonadjacent: distinct ruleKeys: 52; distinct signatures: 52; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-net-opposite-easy: distinct ruleKeys: 52; distinct signatures: 52; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-net-opposite-hard: distinct ruleKeys: 5; distinct signatures: 5; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-net-opposite-medium: distinct ruleKeys: 52; distinct signatures: 52; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-net-overlap-medium: distinct ruleKeys: 4; distinct signatures: 4; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-net-strip-first-overlap: distinct ruleKeys: 1; distinct signatures: 1; 100 reachable: no
- Source re-sync remains dependent on release decisions: fixed series 0017 replaces circle/four with circle/two, requiring a new named mistake for reserved index 0; literal source and old copy-even-count would disagree. Fixed matrices 0009 changes the top row rays; matrices 0019 changes a wrong-choice note only. No source literal or solver changed yet.

- Capacity qt-spatial-abstract-reasoning-net-three-at-corner: distinct ruleKeys: 64; distinct signatures: 64; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-net-top-and-shadow: distinct ruleKeys: 52; distinct signatures: 52; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-net-validity-test: distinct ruleKeys: 24; distinct signatures: 24; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-group-boundary: distinct ruleKeys: 42; distinct signatures: 42; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-group-outline-symmetry: distinct ruleKeys: 5; distinct signatures: 5; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-group-side-count-easy: distinct ruleKeys: 12; distinct signatures: 12; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-group-side-count-medium: distinct ruleKeys: 13; distinct signatures: 13; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-group-side-parity: distinct ruleKeys: 12; distinct signatures: 12; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-group-center-cuts: distinct ruleKeys: 21; distinct signatures: 21; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-group-line-count: distinct ruleKeys: 20; distinct signatures: 20; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-group-region-parity: distinct ruleKeys: 1; distinct signatures: 1; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-group-side-double-dots: distinct ruleKeys: 68; distinct signatures: 68; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-matrix-dot-sum: distinct ruleKeys: 151; distinct signatures: 751; 100 reachable: yes

- Capacity qt-spatial-abstract-reasoning-matrix-fill-union: distinct ruleKeys: 12; distinct signatures: 24; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-matrix-ray-intersection: distinct ruleKeys: 9978; distinct signatures: 9978; 100 reachable: yes

- Capacity qt-spatial-abstract-reasoning-matrix-binary-fill-row: distinct ruleKeys: 32; distinct signatures: 32; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-matrix-corner-grid: distinct ruleKeys: 6; distinct signatures: 28; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-matrix-size-columns: distinct ruleKeys: 10; distinct signatures: 10; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-matrix-size-fill: distinct ruleKeys: 12; distinct signatures: 40; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-matrix-size-latin: distinct ruleKeys: 72; distinct signatures: 72; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-matrix-arrow-column: distinct ruleKeys: 6; distinct signatures: 30; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-matrix-corner-step: distinct ruleKeys: 9; distinct signatures: 9; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-matrix-growing-turn: distinct ruleKeys: 16; distinct signatures: 80; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-matrix-ray-turn: distinct ruleKeys: 1725; distinct signatures: 1725; 100 reachable: yes

- Capacity qt-spatial-abstract-reasoning-group-specific-rule: distinct ruleKeys: 45; distinct signatures: 45; 100 reachable: no

## Per-type capacity and pending release status

| Type id | Enumerated task signatures | Rule-parameter sets after dedupe | Active list size | Checker | Status |
|---|---:|---:|---:|---|---|
| qt-spatial-abstract-reasoning-series-corner-edge-count | 40 | 8 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-dots-size | 90 | 18 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-interleaved-count | 161 | 161 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-outline-triple | 12 | 12 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-size-corner-ray | 48 | 48 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-size-fill | 10 | 2 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-transfer-count | 45 | 9 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-binary-fill | 24 | 6 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-double-fill | 5 | 5 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-two-fill-steps | 12 | 3 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-arrow-alternation | 14 | 4 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-series-two-arrow-turns | 14 | 4 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-adjacent-relation | 25 | 25 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-all-opposites | 7 | 7 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-nonadjacent | 52 | 52 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-opposite-easy | 52 | 52 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-opposite-hard | 5 | 5 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-opposite-medium | 52 | 52 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-overlap-medium | 4 | 4 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-strip-first-overlap | 1 | 1 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-three-at-corner | 64 | 64 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-top-and-shadow | 52 | 52 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-net-validity-test | 24 | 24 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-group-boundary | 42 | 42 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-group-outline-symmetry | 5 | 5 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-group-side-count-easy | 12 | 12 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-group-side-count-medium | 13 | 13 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-group-side-parity | 12 | 12 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-group-center-cuts | 21 | 21 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-group-line-count | 20 | 20 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-group-region-parity | 1 | 1 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-group-side-double-dots | 68 | 68 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-dot-sum | 751 | 151 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-fill-union | 24 | 12 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-ray-intersection | 9978 | 9978 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-binary-fill-row | 32 | 32 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-corner-grid | 28 | 6 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-size-columns | 10 | 10 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-size-fill | 40 | 12 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-size-latin | 72 | 72 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-arrow-column | 30 | 6 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-corner-step | 9 | 9 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-growing-turn | 80 | 16 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-matrix-ray-turn | 1725 | 1725 | 0 | Held schema only, pending | Held; release moves blocked |
| qt-spatial-abstract-reasoning-group-specific-rule | 45 | 45 | 0 | Held schema only, pending | Held; release moves blocked |

- Capacity enumeration completed at ceiling 10000, seed 20261117. Counts use current literal sources, before the three required source rebuilds. No type activation, list regeneration or ledger approval occurred.
- Floor fixtures initially omitted required model fields; corrected them, then demonstrated RED at 0 and 19 with floor disabled and GREEN at 0/19/20 with enforcement restored.
- Fixed-source-default regression demonstrated RED on the former default and GREEN on 646326517. Golden test edits change types, commas and line breaks only; no rendering values changed.
- Required flutter test fails before tests: missing assets/seed/content.db. No placeholder or protected content package will be created. Supplemental generator run will use --no-test-assets.
- Analyzer PASS: No issues found! (ran in 3.3s). Format PASS: Formatted 59 files (0 changed) in 0.07 seconds.
- Repository checker initially cannot compile absent Question/Choice generated model parts. Running scoped build_runner filters for those two models only; no hand-edited generated files or app source changes.
- Removed the source-string default assertion after review because it mirrored implementation. The requested default is configuration; full merged-source runtime checking validates its effect. Permanent planted boundary tests cover the new floor behavior.

## Existing active types checked against 646326517

| Type id | List size | Rule-parameter sets in list after dedupe | Checker | Status |
|---|---:|---:|---|---|
| qt-spatial-abstract-reasoning-series-fill-ray-dots | 100 | 85 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-series-four-tracks | 100 | 100 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-series-ray-step | 100 | 51 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-group-polygon-replacement | 100 | 100 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-group-dot-count | 100 | 100 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-group-dot-parity | 100 | 100 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-matrix-ray-union | 100 | 100 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-matrix-sized-ray-union | 100 | 72 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-matrix-form-ray | 100 | 100 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-matrix-outline-latin | 100 | 100 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-matrix-size-dots | 100 | 24 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-matrix-size-transfer | 100 | 81 | PASS | Existing active, unchanged |
| qt-spatial-abstract-reasoning-matrix-corner-reflection | 100 | 100 | PASS | Existing active, unchanged |

## Verification and handoff

- flutter test test/tool/generator: FAIL before tests, missing assets/seed/content.db.
- flutter test --no-pub --no-test-assets test/tool/generator: PASS, 00:43 +242 ~6: All tests passed! Six golden sheets skipped; no rendering acceptance claimed. Removed implementation-mirroring configuration test afterward; final CLI tests rerun separately.
- flutter analyze tool/generator test/tool/generator: PASS, No issues found! (ran in 3.3s).
- dart format --output=none --set-exit-if-changed tool/generator test/tool/generator: PASS, Formatted 59 files (0 changed) in 0.07 seconds.
- dart run tool/checks/run_checks.dart: PASS after scoped Question/Choice codegen, OK generated-types and all 15 other checks. All 13 current active types reproduce their sources against 646326517; held types receive schema/solver checks only.
- dart run tool/check_no_ai_attribution.dart: PASS, check_no_ai_attribution: OK.
- git diff --check: PASS. Index empty. No commits, ledger changes, content/questions edits, dependency additions or rendering changes.
- Files changed: tool/generator/bin/check.dart; tool/generator/lib/src/check/files.dart; test/tool/generator/held_test.dart; test/tool/generator/figure_sheets_test.dart; FINDINGS.md. Ignored generated Question/Choice outputs regenerated by build_runner, not hand-edited.
- Unfinished: release moves; generated release lists; source literal/index-0 rebuilds for the three fixed types; their competing-rule validation; renewed per-list audit checks. Remaining held capacities and current active list results are above. No release or approval is claimed. Lead must resolve the Revision 1/spec discrepancy and plain-git-mv/stage-nothing conflict before dependent release work.

## Review-fix resumption, November 17

- Refreshed AGENTS.md, WORKFLOW.md, SUBAGENTS.md and process-improvement policy from origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885. git fetch remains denied at external FETCH_HEAD; git ls-remote confirms origin/main equals live main. Preserved all four existing modified files.
- Review findings are confirmed, not rejected: release activation and fixed-source rebuilds remain incomplete. Current user repeats both "Stage nothing" and "Use plain git mv"; git mv stages changes and requires external Git metadata writes unavailable here. No authorization to bypass sandbox or change the requested move operation exists.
- Needs the lead: controlling plan Part 3b.2 explicitly holds lists below 100 pending Aedwon, and fix-rulings R5 still requires 100. The brief explicitly claims Revision 1 but also instructs stopping on plan/spec disagreement. No revision was supplied in this resumption. Release activation remains blocked under that explicit stop condition; no spec/plan edited.
- Required next step before any completion claim: run all five requested commands and record fresh results. Do not treat historical PASS entries or held schema checks as release verification. This required step addresses the review's incomplete-verification finding without weakening any gate.
- Independent progress: generated matrix-ray-turn's 100-variant list in its existing held directory with the required CLI, seed 20261117. No activation or staging occurred. Full active-list validation will use a disposable worktree-local input directory, since held-mode schema validation is insufficient.
- Offline list preparation qt-spatial-abstract-reasoning-series-corner-edge-count: requested 40, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-series-dots-size: requested 90, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-series-size-corner-ray: requested 48, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-series-transfer-count: requested 45, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-series-binary-fill: requested 24, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-net-adjacent-relation: requested 25, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-net-nonadjacent: requested 52, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-net-opposite-easy: requested 52, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-net-opposite-medium: requested 52, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-net-three-at-corner: requested 64, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-net-top-and-shadow: requested 52, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-net-validity-test: requested 24, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-group-boundary: requested 42, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-group-center-cuts: requested 21, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-group-line-count: requested 20, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-group-side-double-dots: requested 68, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-matrix-fill-union: requested 24, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-matrix-binary-fill-row: requested 32, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-matrix-size-fill: requested 40, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-matrix-size-latin: requested 72, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-matrix-arrow-column: requested 30, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-matrix-growing-turn: requested 80, generator exit 0; remains held pending activation ruling.
- Offline list preparation qt-spatial-abstract-reasoning-group-specific-rule: requested 45, generator exit 0; remains held pending activation ruling.
- Prepared all other eligible step-1 lists offline in their existing held directories, using the previously measured ceiling-10000 capacities and seed 20261117. Every generation command exited 0. This preserves the stop on activation while leaving concrete reviewable lists for the lead's move operation. No question source, rule, solver, spec, plan, ledger or existing modified source file changed in this resumption.
- Both explicit step-6 lists passed the full checker against 646326517 using worktree-local disposable active inputs (exit 0, no failures), not held schema mode. matrix-ray-turn: 100 variants, 100 distinct retained ruleKeys. matrix-dot-sum: 100 variants, 77 distinct retained ruleKeys. Both remain held pending the authorized Git move; their re-audit and approval remain the lead's work.
- Fresh requested verification: flutter test test/tool/generator FAIL, exit 1, "No file or variants found for asset: assets/seed/content.db." and "Error: Failed to build asset bundle". Flutter cache writes no longer block. Supplemental flutter test --no-pub --no-test-assets test/tool/generator PASS, exit 0, "00:42 +241 ~6: All tests passed!" Six figure sheets skipped; no visual acceptance claimed.
- Fresh requested verification: flutter analyze tool/generator test/tool/generator PASS, exit 0, "No issues found! (ran in 3.4s)". dart format --output=none --set-exit-if-changed tool/generator test/tool/generator PASS, exit 0, "Formatted 59 files (0 changed) in 0.07 seconds." dart run tool/checks/run_checks.dart PASS, exit 0, "OK    generated-types", "OK    content-approval", all 16 checks OK through "OK    legal-text-drafting". dart run tool/check_no_ai_attribution.dart PASS, exit 0, "check_no_ai_attribution: OK".
- Full validation of the disposable directory found three pre-existing held lists that the broad copy also included: matrix-corner-step has 9 variants plus unsupported-form/key failures; net-opposite-hard has 2 variants; matrix-ray-intersection has index-0 source mismatch and 16 competing-rule failures. These lists were not generated or modified by this resumption. They remain held and are excluded from this run's newly prepared list results, not silently counted as passes. Ray-intersection findings reinforce the outstanding source rebuild and draw-constraint work under Needs the lead.

## Prepared lists, resumption

Full checker against 646326517: PASS, exit 0, no failures for all 25 lists. Includes source reproduction, grown-library ambiguity, named mistakes, ranges, signatures and the 20-variant floor. All remain held; no ledger approval.

| Type id | List size | Retained rule-parameter sets | Checker | Status |
|---|---:|---:|---|---|
| qt-spatial-abstract-reasoning-group-boundary | 42 | 42 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-group-center-cuts | 21 | 21 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-group-line-count | 20 | 20 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-group-side-double-dots | 68 | 68 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-group-specific-rule | 45 | 45 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-matrix-arrow-column | 30 | 6 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-matrix-binary-fill-row | 32 | 32 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-matrix-dot-sum | 100 | 77 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-matrix-fill-union | 24 | 12 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-matrix-growing-turn | 80 | 16 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-matrix-ray-turn | 100 | 100 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-matrix-size-fill | 40 | 12 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-matrix-size-latin | 72 | 72 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-net-adjacent-relation | 25 | 25 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-net-nonadjacent | 52 | 52 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-net-opposite-easy | 52 | 52 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-net-opposite-medium | 52 | 52 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-net-three-at-corner | 64 | 64 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-net-top-and-shadow | 52 | 52 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-net-validity-test | 24 | 24 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-series-binary-fill | 24 | 6 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-series-corner-edge-count | 40 | 8 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-series-dots-size | 90 | 18 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-series-size-corner-ray | 48 | 48 | PASS | Prepared, held |
| qt-spatial-abstract-reasoning-series-transfer-count | 45 | 9 | PASS | Prepared, held |

Files touched by this resumption: FINDINGS.md and the following generated variant lists (the four pre-existing modified code/test files were preserved):

- `content/types-held/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-boundary.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-center-cuts.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-line-count.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-side-double-dots.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/testing-a-figure-group-rule/qt-spatial-abstract-reasoning-group-specific-rule.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-arrow-column.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-binary-fill-row.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-fill-union.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-growing-turn.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-ray-turn.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-fill.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-latin.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-adjacent-relation.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-nonadjacent.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-opposite-easy.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-opposite-medium.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-three-at-corner.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-top-and-shadow.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-validity-test.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/figure-counts-and-fills/qt-spatial-abstract-reasoning-series-binary-fill.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-corner-edge-count.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-dots-size.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-size-corner-ray.variants.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-transfer-count.variants.yaml`
- Supplemental post-generation floor/held tests PASS: "00:01 +6: All tests passed!". Post-generation attribution PASS: "check_no_ai_attribution: OK". git diff --check PASS. Index remains empty; no stage or commit.
- Needs the lead, still unfinished: perform permitted type activation/moves after resolving plain git mv versus stage-nothing and external metadata permissions; record the controlling Revision 1 in the plan/spec; rebuild the three fixed-source types and validate their competing rules. No finding is rejected, and no full rel1 completion, source rebuild or approval is claimed. The 25 prepared passing lists are concrete independent progress, not completion of activation or step 5.
- Final repository check after all list preparation: dart run tool/checks/run_checks.dart PASS, exit 0; all 16 checks OK, including generated-types, content-approval and legal-text-drafting. This checks unchanged active types plus held schemas; the separate full checker above validates the 25 prepared lists as active inputs. Final index is empty.
