# Figure-series Task 1.3 findings

- Startup policy: origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f. Remote main verified with git ls-remote; local origin/main matches and contains 1295c1866. Fetch failed because FETCH_HEAD is outside writable roots. No stage or commit performed.
- Assignment scope: 15 exact figured singleton candidates: 0001, 0003, 0004, 0006, 0009, 0010, 0011, 0012, 0013, 0014, 0015, 0016, 0017, 0018, 0020. Each remains its own type with source index 0. Sources 0002, 0005, 0007, 0008 stay singles because answer figures are unsupported. Source 0019 waits for the lead's source-note correction.
- Higher-capacity candidates are four-tracks (0013), interleaved-count (0017), and size-corner-ray (0020). Other candidates require measured capacity before any list is written. No ranges widened, no source content changed.

## Needs the lead

- BLOCKER: Part 3b and this dispatch require keeping every below-100 type file but writing no variant list. The existing Task 1.2 checker cannot represent this state. In tool/generator/lib/src/check/files.dart, checkTypeFiles unconditionally opens `<type>.variants.yaml` for every type YAML and reports a missing list as an `input` failure. It does so even when `enabled` is false. tool/checks/generated_types_check.dart forwards every such failure into run_checks. There is no HELD field or exclusion in the model/loader. Creating the required HELD types therefore makes the required repository gate fail. An empty list also fails merged-source checks and contradicts the instruction to write no list.
- Stopped before implementation under the dispatch's explicit plan/spec/code disagreement rule. The lead must settle how HELD type files are represented and checked, and authorize the corresponding Task 1.2 loader change or provide that dependency. I did not invent a status field, move files outside their required paths, emit undersized lists, or change the checker.
- Baseline verification: `flutter test test/tool/generator --no-test-assets` exited 0: `00:05 +81: All tests passed!`. No tests or production files were changed. Capacity and per-type checker results are unavailable because no type was authored before the stop.
- Remaining verification commands not run after this stop: analyzer, format, build_runner, run_checks, attribution. No completion claim. Only FINDINGS.md was authored; no stage, commit, UI, source-content, or dependency change.

## Review follow-up, 2026-11-17

- Current remote main still matches origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f, verified with git ls-remote. Fetch remains blocked by the external FETCH_HEAD write restriction.
- The supplied review reports no code findings and confirms the HELD/list conflict. Re-reading checkTypeFiles confirms it still opens a variants file unconditionally, including disabled types. No lead ruling or dependency resolving this conflict was supplied. Task 1.3 remains stopped under the explicit disagreement rule; no review finding was rejected.
- Retrying every requested verification command in this session, including build_runner before run_checks. Results follow below.
- Verification results so far: asset-free generator tests PASS, `00:08 +81: All tests passed!`; exact requested test command FAIL, `No file or variants found for asset: assets/seed/content.db. Error: Failed to build asset bundle`; analyzer PASS, `No issues found! (ran in 6.8s)`; format PASS, `Formatted 24 files (0 changed) in 0.05 seconds.`; attribution PASS, `check_no_ai_attribution: OK`.
- Initial run_checks attempt failed during native hook bundling with a missing libsqlite3mc.dylib codesign input while build_runner was still running. This attempt overlapped codegen, so it is not final verification evidence. Run_checks will be rerun sequentially after codegen completes.
- Codegen PASS, exit 0: `Built with build_runner/aot in 33s; wrote 4763 outputs.` Warnings: removed delete-conflicting-outputs flag, package language version below json_serializable recommendation, obsolete drift generate_connect_constructor option. No dependency or SDK change made.
- Final sequential repository checks PASS, exit 0. Summary lines: `no content/types/ directory; generated types skipped`, `OK generated-types`, `OK content-approval`, through `OK legal-text-drafting`. This is baseline evidence only, not evidence for unimplemented Task 1.3 types.
- Final git status: only `?? FINDINGS.md`. Generated outputs are ignored and no tracked source files changed. Nothing staged or committed. Per-type IDs, capacity counts, LIST/HELD status, and checker results remain unavailable because implementation is blocked pending the lead's HELD representation ruling.

## Resumption with lead rulings, Nov 17

- Policy remains origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f, verified against remote main with ls-remote. Fetch cannot write external FETCH_HEAD; the local policy matches remote. Lead rulings resolve the prior HELD blocker. The slots-aware solver dependency is present on this worktree.
- Implementing HELD schema/solver-only checking and CLI support first, with planted no-list and unknown-solver tests. No UI, source content, stage, or commit change authorized.
- HELD planted tests failed on the old missing-list behavior, then passed after schema/solver-only support. Both the CLI and repository check now include content/types-held even when content/types is absent.
- Series canonicalizer planted tests failed without registration, then passed with D4 normalization. It includes outline orientation, fractional-fill orientation, corner dots, dot-row orientation, rays, arrows, and bottom edge marks, preserving relative geometry. Candidate ordering and descriptions add no capacity.
- Independent series solvers were written from the rule documentation and figure contract before any generator implementation. Source 0012's named increase-sides mistake only supports a triangle-to-square or square-to-pentagon continuation; unsupported extra polygons must be rejected rather than replaced by arbitrary shapes.

- Capacity qt-spatial-abstract-reasoning-series-corner-edge-count, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 8; distinct signatures: 40; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-dots-size, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 18; distinct signatures: 90; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-fill-ray-dots, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 288; distinct signatures: 1079; 100 reachable: yes

- Capacity qt-spatial-abstract-reasoning-series-four-tracks, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 1424; distinct signatures: 1424; 100 reachable: yes

- Capacity qt-spatial-abstract-reasoning-series-interleaved-count, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 240; distinct signatures: 240; 100 reachable: yes

- Capacity qt-spatial-abstract-reasoning-series-outline-triple, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 12; distinct signatures: 12; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-size-corner-ray, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 192; distinct signatures: 599; 100 reachable: yes

- Capacity qt-spatial-abstract-reasoning-series-size-fill, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 2; distinct signatures: 10; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-transfer-count, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 9; distinct signatures: 45; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-binary-fill, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 6; distinct signatures: 30; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-double-fill, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 20; distinct signatures: 20; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-two-fill-steps, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 3; distinct signatures: 15; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-arrow-alternation, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 4; distinct signatures: 14; 100 reachable: no

- Capacity qt-spatial-abstract-reasoning-series-ray-step, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 56; distinct signatures: 196; 100 reachable: yes

- Capacity qt-spatial-abstract-reasoning-series-two-arrow-turns, ceiling 2000, seed 20261117, exit 0: distinct ruleKeys: 4; distinct signatures: 14; 100 reachable: no
- qt-spatial-abstract-reasoning-series-corner-edge-count: HELD (8 ruleKeys, 40 signatures), no variant list.
- qt-spatial-abstract-reasoning-series-dots-size: HELD (18 ruleKeys, 90 signatures), no variant list.
- qt-spatial-abstract-reasoning-series-fill-ray-dots: LIST 100 generation exit 0, capacity 288 ruleKeys / 1079 signatures. 
- qt-spatial-abstract-reasoning-series-four-tracks: LIST 100 generation exit 0, capacity 1424 ruleKeys / 1424 signatures. 
- qt-spatial-abstract-reasoning-series-interleaved-count: LIST 100 generation exit 0, capacity 240 ruleKeys / 240 signatures. 
- qt-spatial-abstract-reasoning-series-outline-triple: HELD (12 ruleKeys, 12 signatures), no variant list.
- qt-spatial-abstract-reasoning-series-size-corner-ray: LIST 100 generation exit 0, capacity 192 ruleKeys / 599 signatures. 
- qt-spatial-abstract-reasoning-series-size-fill: HELD (2 ruleKeys, 10 signatures), no variant list.
- qt-spatial-abstract-reasoning-series-transfer-count: HELD (9 ruleKeys, 45 signatures), no variant list.
- qt-spatial-abstract-reasoning-series-binary-fill: HELD (6 ruleKeys, 30 signatures), no variant list.
- qt-spatial-abstract-reasoning-series-double-fill: HELD (20 ruleKeys, 20 signatures), no variant list.
- qt-spatial-abstract-reasoning-series-two-fill-steps: HELD (3 ruleKeys, 15 signatures), no variant list.
- qt-spatial-abstract-reasoning-series-arrow-alternation: HELD (4 ruleKeys, 14 signatures), no variant list.
- qt-spatial-abstract-reasoning-series-ray-step: LIST 100 generation exit 0, capacity 56 ruleKeys / 196 signatures. 
- qt-spatial-abstract-reasoning-series-two-arrow-turns: HELD (4 ruleKeys, 14 signatures), no variant list.
- The full source-reproduction tests passed for all 15 patterns. A library-search false positive exposed the double-fill solver accepting only three shown items; its five-item contract is now enforced in fits. A planted extra-track candidate also failed all 15 solvers before exact candidate-key validation, and passes after the fix.
- First combined suite exposed the old CLI absent-types test using the now-present default HELD root. The test now supplies absent active and HELD roots, preserving its intended missing-directory case. This is an affected test, not an unrelated baseline failure.
- Checker CLI passed (exit 0) for all five LIST 100 types and all ten HELD types. Full source and 20 seeded solver continuations per pattern passed. HELD files are parsed and solver-checked without reading a list; active lists receive the full independent checker.
- Final generator tests PASS: `00:25 +101: All tests passed!` (`flutter test test/tool/generator --no-test-assets`). Analyzer PASS: `No issues found! (ran in 4.2s)`. Format PASS: `Formatted 31 files (0 changed) in 0.04 seconds.` Attribution PASS: `check_no_ai_attribution: OK`.
- Required codegen PASS, exit 0: `Built with build_runner/aot in 6s; wrote 61 outputs.` Existing warnings include removed delete-conflicting-outputs, json_serializable language recommendation and obsolete drift option. Generated source was not hand-edited. Running repository checks sequentially after completion.
- Wording audit found unique-longest keys in 38 generated variants across ray-step, fill-ray-dots, and size-corner-ray. Source wording remains exact. Adding a planted description-length test before tightening the generated descriptions, rather than padding wrong choices.
- Description-length test is now green for 100 seeded draws of every type. Generated ray and arrow directions use standard compass abbreviations; fractional fill descriptions use percentages; outline-only polygon descriptions use side counts. These changes tighten descriptions consistently. Index 0 keeps literal source text. All five owned, unpublished lists were regenerated after the wording change; capacity signatures are unchanged because wording adds no capacity.
- All 15 types preserve their source at merged index 0. Sources 0002, 0005, 0007, 0008 remain singles for unsupported answer figures; 0019 remains skipped as directed. No source questions or UI were edited. Independent approval and visual acceptance remain lead-owned later tasks.
- Final format review moved shared stem and explanation prose into each type YAML, with answerText and answerDotCount slots. Rules now emit only wording values, preserving the plan's ownership of shared wording. Existing exact-source tests cover this refactor. Lists are being regenerated to remove redundant full-text slots.

## Final type handoff

Capacity ceiling 2000, seed 20261117. Counts are observed enumerated draws, never an estimate of unseen variants. LIST checker is full; HELD checker is schema/solver only. All 15 reserved source variants also passed full independent canary checking in tests.

- qt-spatial-abstract-reasoning-series-fill-ray-dots; source q-spatial-abstract-reasoning-figure-series-0018 at index 0; ruleKeys 288; signatures 1079; LIST 100; checker PASS.
- qt-spatial-abstract-reasoning-series-four-tracks; source q-spatial-abstract-reasoning-figure-series-0013 at index 0; ruleKeys 1424; signatures 1424; LIST 100; checker PASS.
- qt-spatial-abstract-reasoning-series-interleaved-count; source q-spatial-abstract-reasoning-figure-series-0017 at index 0; ruleKeys 240; signatures 240; LIST 100; checker PASS.
- qt-spatial-abstract-reasoning-series-size-corner-ray; source q-spatial-abstract-reasoning-figure-series-0020 at index 0; ruleKeys 192; signatures 599; LIST 100; checker PASS.
- qt-spatial-abstract-reasoning-series-ray-step; source q-spatial-abstract-reasoning-figure-series-0001 at index 0; ruleKeys 56; signatures 196; LIST 100; checker PASS.
- qt-spatial-abstract-reasoning-series-corner-edge-count; source q-spatial-abstract-reasoning-figure-series-0014 at index 0; ruleKeys 8; signatures 40; HELD; checker PASS.
- qt-spatial-abstract-reasoning-series-dots-size; source q-spatial-abstract-reasoning-figure-series-0009 at index 0; ruleKeys 18; signatures 90; HELD; checker PASS.
- qt-spatial-abstract-reasoning-series-outline-triple; source q-spatial-abstract-reasoning-figure-series-0012 at index 0; ruleKeys 12; signatures 12; HELD; checker PASS.
- qt-spatial-abstract-reasoning-series-size-fill; source q-spatial-abstract-reasoning-figure-series-0004 at index 0; ruleKeys 2; signatures 10; HELD; checker PASS.
- qt-spatial-abstract-reasoning-series-transfer-count; source q-spatial-abstract-reasoning-figure-series-0016 at index 0; ruleKeys 9; signatures 45; HELD; checker PASS.
- qt-spatial-abstract-reasoning-series-binary-fill; source q-spatial-abstract-reasoning-figure-series-0003 at index 0; ruleKeys 6; signatures 30; HELD; checker PASS.
- qt-spatial-abstract-reasoning-series-double-fill; source q-spatial-abstract-reasoning-figure-series-0015 at index 0; ruleKeys 20; signatures 20; HELD; checker PASS.
- qt-spatial-abstract-reasoning-series-two-fill-steps; source q-spatial-abstract-reasoning-figure-series-0011 at index 0; ruleKeys 3; signatures 15; HELD; checker PASS.
- qt-spatial-abstract-reasoning-series-arrow-alternation; source q-spatial-abstract-reasoning-figure-series-0010 at index 0; ruleKeys 4; signatures 14; HELD; checker PASS.
- qt-spatial-abstract-reasoning-series-two-arrow-turns; source q-spatial-abstract-reasoning-figure-series-0006 at index 0; ruleKeys 4; signatures 14; HELD; checker PASS.

## Files touched

```text
 M test/tool/generator/check_cli_test.dart
 M tool/checks/generated_types_check.dart
 M tool/generator/bin/check.dart
 M tool/generator/lib/src/check/files.dart
 M tool/generator/lib/src/check/signature.dart
 M tool/generator/lib/src/check/solvers/solver.dart
 M tool/generator/lib/src/rules/rule.dart
?? FINDINGS.md
?? content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-corner-edge-count.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-dots-size.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-outline-triple.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-size-fill.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-transfer-count.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/figure-counts-and-fills/qt-spatial-abstract-reasoning-series-binary-fill.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/figure-counts-and-fills/qt-spatial-abstract-reasoning-series-double-fill.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/figure-counts-and-fills/qt-spatial-abstract-reasoning-series-two-fill-steps.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/figure-turns-and-positions/qt-spatial-abstract-reasoning-series-arrow-alternation.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/figure-turns-and-positions/qt-spatial-abstract-reasoning-series-two-arrow-turns.yaml
?? content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-fill-ray-dots.variants.yaml
?? content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-fill-ray-dots.yaml
?? content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-four-tracks.variants.yaml
?? content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-four-tracks.yaml
?? content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.variants.yaml
?? content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.yaml
?? content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-size-corner-ray.variants.yaml
?? content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-size-corner-ray.yaml
?? content/types/reasoning/spatial-abstract-reasoning/figure-turns-and-positions/qt-spatial-abstract-reasoning-series-ray-step.variants.yaml
?? content/types/reasoning/spatial-abstract-reasoning/figure-turns-and-positions/qt-spatial-abstract-reasoning-series-ray-step.yaml
?? test/tool/generator/held_test.dart
?? test/tool/generator/series_rules_test.dart
?? test/tool/generator/series_signature_test.dart
?? test/tool/generator/series_wording_test.dart
?? tool/generator/lib/src/check/series_signature.dart
?? tool/generator/lib/src/check/solvers/figure_series/series_solver.dart
?? tool/generator/lib/src/rules/figure_series/series.dart
?? tool/generator/lib/src/rules/figure_series/sources.dart
```

## Final verification

- PASS `flutter test test/tool/generator --no-test-assets`: 00:28 +102: All tests passed!
- PASS `flutter analyze tool/generator test/tool/generator`: No issues found! (ran in 3.5s)
- PASS `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: Formatted 32 files (0 changed) in 0.03 seconds.
- PASS `dart run build_runner build --delete-conflicting-outputs`:   Built with build_runner/aot in 6s; wrote 61 outputs.
- PASS `dart run tool/checks/run_checks.dart`: Running build hooks...Running build hooks...OK    generated-types | OK    content-approval | OK    lesson-size | OK    lesson-split-coverage | OK    lesson-pool | OK    shell-route-push | OK    sync-mutations-typed-read | OK    mock-blueprint-topics | OK    bold-stem | OK    lesson-list-exam-scope | OK    lesson-minutes-on-screen | OK    design-token-literals | OK    custom-subject-tiers | OK    letter-shortcut-gate | OK    legal-text-drafting
- PASS `dart run tool/check_no_ai_attribution.dart`: Running build hooks...Running build hooks...check_no_ai_attribution: OK
- No staging or commits. No tracked generated-file, app/UI, dependency, or source-question changes. Source 0019 is deliberately undone; approval, blind solving and figure-sheet acceptance are later lead-owned tasks. No unresolved blocker in this assignment.

## Review correction run

- Policy origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f matches live main by ls-remote. Fetch cannot write external FETCH_HEAD; read policy through git show as instructed.
- Confirmed both findings. Triangle vertices end at center.y + r/2; quarter-fill clipping begins there, so no positive-area fill appears. Reject generated triangle/quarter-fill combinations across shown figures and choices without changing painter or reserved source maps. Count descriptions need singular dot/edge line for one. No finding rejected.
- Regression tests will catch any generated triangle with quarter fill and plural count labels for one. Existing source-reproduction tests protect index 0. Regenerate only unpublished owned lists affected by fill restriction or count wording.
- RED confirmed: quarter-filled triangle test failed at fill-ray-dots seed 5; count wording failed at interleaved-count seed 5 (`1 dots` instead of `1 dot`). Flutter SDK bootstrap works in this run, unlike the supplied review environment.
- GREEN: all three wording/renderability tests passed. Updated fill-ray-dots capacity, ceiling 2000 seed 20261117: distinct ruleKeys 288; distinct signatures 995; 100 reachable yes. Status remains LIST 100. Other patterns retain their ranges and capacity.
- First analyzer found seven style issues in the new regression code and long count-label interpolations. Fixing those before final verification.
- Regenerated fill-ray-dots, four-tracks, interleaved-count lists using their existing seeds. Each contains 100 variants; index 0 is unchanged by model equality. All other existing files preserved.
- Capacity correction: shared rejection also removes invisible quarter triangles from HELD binary-fill (6 ruleKeys / 24 signatures) and two-fill-steps (3 / 12), ceiling 2000 seed 20261117. Both remain HELD without lists. Other capacities remain as previously recorded.
- Final analyzer PASS: No issues found! (5.5s). Format PASS: Formatted 32 files (0 changed). Attribution PASS: check_no_ai_attribution: OK. Codegen PASS: Built with build_runner/aot in 7s; wrote 33 outputs. Repository checks PASS, including generated-types.
- Exact asset-enabled test command FAILS before tests: No file or variants found for asset: assets/seed/content.db; Failed to build asset bundle. No protected seed build authorized or needed for generator tests.
- Asset-free suite first attempt: 103 passed, CLI skips absent types returned exit 1 while codegen ran concurrently. Investigating through a sequential rerun after codegen, with no CLI edits.
- Final sequential asset-free suite PASS, exit 0: `00:27 +104: All tests passed!` No CLI change required. Initial CLI failure did not reproduce after codegen completed; do not overlap codegen with verification subprocesses.
- Direct checker PASS, exit 0, no diagnostics: all five LIST 100 types receive full checks and ten HELD types schema/registration checks. Source reproduction tests pass for all 15 source variants.
- Correction-run files touched only: FINDINGS.md; test/tool/generator/series_wording_test.dart; tool/generator/lib/src/rules/figure_series/series.dart; content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-{fill-ray-dots,four-tracks,interleaved-count}.variants.yaml. No stage, commit, dependency, source-question, painter, or UI change. git diff --check PASS. Both review findings fixed, none rejected. Exact asset-enabled test remains blocked by absent seed asset; later approval/blind solve/sheet acceptance remain lead-owned.
