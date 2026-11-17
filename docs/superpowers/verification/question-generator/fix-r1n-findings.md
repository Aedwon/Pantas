# Cube-net audit fixes, Nov 17

- Policy: origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, descendant of 1295c1866. Fetch cannot write shared FETCH_HEAD, but git ls-remote confirms remote main equals this revision.
- R3 root cause confirmed: generator and independent solver use nearest-face fallback when named directional premises are absent.
- Scope: six assigned types only. Current task's under-20 hold cutoff supersedes R5's earlier under-100 cutoff.
- Exact baseline command `flutter test test/tool/generator` cannot build assets because assets/seed/content.db is absent. Generator-only fallback: --no-test-assets.
- R6 permits holding each repetitive-answer type. Hold adjacent-relation and validity-test, preserving their exact source wording, rather than invent a replacement general-test question.
- RED: six new regression tests fail as intended: three directional-premise tests, column-end test, and two R6 hold tests.
- Repair decision: redraw absent geometric premises instead of renaming nearest-face picks. Easy profile 1 requires a genuine four-square strip with two end caps and distinct support/next-side/other-cap-support choices. Medium requires column endpoints and an actual edge neighbor.

## Needs the lead

- Baseline asset-free suite already fails two unrelated matrix tests: `constant matrix outline is recorded separately from ruleKey` and `fill union uses every permitted pair of distinct sizes`, both `Bad state: No element` in matrix_rules_test.dart. Leave these outside this worker's scope.

## Results as found

- GREEN: new premise tests plus existing mental-rotation tests: `00:17 +23: All tests passed!` with --no-test-assets.
- R5 capacity command, ceiling 2000 and seed 20261117: nonadjacent 5 ruleKeys / 5 signatures; opposite-easy 4 / 4; opposite-medium 9 / 9; top-and-shadow 5 / 5. All four fall below 20 and must move to types-held. Source reproduction still passes, including easy's reserved index 1.
- Independent solver regression RED: all five archived audited variants were accepted by the old solver. Restoring the strict solver makes all five tests pass.
- All six regenerated held lists pass direct checkVariants against prod root 646326517: nonadjacent 5, easy 4, medium 9, top-and-shadow 5, adjacent-relation 25, validity-test 24. Held lists are checked directly because the repository CLI skips held variant validation.
- One parallel Dart invocation failed during native-hook dylib rewriting (`not a Mach-O file`). The next verification runs serialize Dart commands to avoid shared native-output contention.

- Final command: `flutter analyze tool/generator test/tool/generator`, exit 1. Log: /tmp/qg-net-gate-analyze.log.

- Final command: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`, exit 1. Log: /tmp/qg-net-gate-format.log.

- Final command: `dart run tool/checks/run_checks.dart`, exit 254. Log: /tmp/qg-net-gate-checks.log.

- Final command: `dart run tool/check_no_ai_attribution.dart`, exit 0. Log: /tmp/qg-net-gate-attribution.log.

- Final command: `flutter test test/tool/generator`, exit 1. Log: /tmp/qg-net-gate-test.log.
- R6 capacity measurement, ceiling 2000 and seed 20261117: adjacent-relation 25 ruleKeys / 25 signatures; validity-test 24 / 24. Both regenerated at full measured capacity, then held because their correct text repeats throughout.
- All six type files moved unchanged into content/types-held; only their generated variant lists were rebuilt. Four R3 lists use strict redraws and distinct mistake notes. No approvals, content/questions, UI, or other type files changed.
- Focused combined verification: `01:05 +30: All tests passed!` (new tests plus existing mental-rotation rules, --no-test-assets). Exact source checks include all reserved indexes on 646326517, not only index 0.
- Final checks runner is blocked by missing generated model parts (Question/Choice Freezed and JSON targets). This is distinct from the cube-net code. Regenerating ignored code with build_runner before repeating the check, as startup policy directs for fresh worktrees.
- Final analysis retry after lint fixes: `No issues found! (ran in 34.2s)`; final format retry: `Formatted 60 files (0 changed) in 0.33 seconds.`
- Source and approval scope verified: no diff under content/questions/, lib/, assets/, or content/question-ledger/; staged diff is empty.

- Final command: `flutter test --no-test-assets --no-pub test/tool/generator`, exit 1. Log: /tmp/qg-net-gate-asset-free.log.
- Full asset-free generator suite finished: `03:43 +252 ~6 -2: Some tests failed.` Only the two already-recorded baseline matrix tests fail; all cube-net tests pass. Six figure-sheet tests are skipped by their existing configuration.

- Retry: `dart run tool/checks/run_checks.dart`, exit 1. Log: /tmp/qg-net-checks-retry.log.

- Retry: `flutter analyze tool/generator test/tool/generator`, exit 0. Log: /tmp/qg-net-analyze-retry.log.

- Retry: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`, exit 0. Log: /tmp/qg-net-format-retry.log.

- Retry: `dart run tool/check_no_ai_attribution.dart`, exit 0. Log: /tmp/qg-net-attribution-retry.log.

## Needs the lead, final gate result

- After successful code generation (`Built with build_runner/aot in 224s; wrote 4831 outputs`), the checks runner executes. Its generated-types check passes: `OK    generated-types`.
- `dart run tool/checks/run_checks.dart` exits 1 solely for `FAIL  content-approval (4)`: series-corner-edge-count, group-center-cuts, group-line-count, group-specific-rule are not approved. These four types are outside this assignment and were not edited. No approval was added.

- Retry: `flutter test --no-pub --no-test-assets test/tool/generator/net_audit_fix_test.dart`, exit 0. Log: /tmp/qg-net-focused-final.log.

## Final verification summary

- `flutter test test/tool/generator`: FAIL, exit 1, `No file or variants found for asset: assets/seed/content.db.`
- Full asset-free fallback: FAIL, exit 1, `03:43 +252 ~6 -2: Some tests failed.` Only the two baseline matrix failures named above.
- Final focused regression command: PASS, exit 0, `00:31 +13: All tests passed!`. All six rebuilt held lists report `checker failures: 0`; all reserved sources reproduce prod root 646326517.
- `flutter analyze tool/generator test/tool/generator`: PASS, exit 0, `No issues found! (ran in 6.0s)`.
- `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: PASS, exit 0, `Formatted 60 files (0 changed) in 0.09 seconds.`
- `dart run tool/checks/run_checks.dart`: FAIL, exit 1, `OK    generated-types`, `FAIL  content-approval (4)` for the four untouched types named above. All other checks pass.
- `dart run tool/check_no_ai_attribution.dart`: PASS, exit 0, `check_no_ai_attribution: OK`.
- No UI or content/questions changes, no dependencies, no approvals, no staging, no commits. Existing type templates moved byte-identically. Changes are the two shared cube-net implementation files, net_audit_fix_test.dart and its archived-bad-variant fixture, six regenerated type/list pairs moved to types-held, and this findings file.

## Needs the lead, remaining R6 infrastructure

- This bounded worker holds both assigned constant-answer types and tests their held placement. The general R6 answer-concentration checker rule is absent in this checkout; its global implementation and planted list test remain for the lead's checker lane. No active list among these six remains to violate it.
- Lead review and any later reactivation remain undone. No acceptance or release approval is claimed.

## Review-response verification, Nov 17

- Supplied review reports NO FINDINGS. No implementation change is requested or justified; preserve all existing work. No findings rejected.
- Startup reads local origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, verified descendant of 1295c1866. Fetch retry fails because shared FETCH_HEAD is outside writable roots.

- Review-response `flutter test test/tool/generator`: exit 1. Log: /tmp/qg-r1n-response-test.log.
- Remote main confirmed with git ls-remote: 17f514bfb6224fa4caeb51fcc5efc2ed32da7885.
- Needs the lead: exact test command now reaches asset loading but fails: `No file or variants found for asset: assets/seed/content.db.` No protected seed package was regenerated.

- Review-response analyzer: exit 0. Log: /tmp/qg-r1n-response-analyze.log.

- Review-response format: exit 0. Log: /tmp/qg-r1n-response-format.log.

- Review-response checks runner: exit 1. Log: /tmp/qg-r1n-response-checks.log.

- Review-response attribution: exit 0. Log: /tmp/qg-r1n-response-attribution.log.
- Analyzer PASS: `No issues found! (ran in 6.5s)`. Format PASS: `Formatted 60 files (0 changed) in 0.16 seconds.` Attribution PASS: `check_no_ai_attribution: OK`.
- Needs the lead: checks runner FAIL, exit 1, `FAIL  content-approval (4)` for untouched series-corner-edge-count, group-center-cuts, group-line-count, group-specific-rule. `OK    generated-types`; all remaining checks pass. No approvals changed.

- Review-response focused regression: exit 0. Log: /tmp/qg-r1n-response-focused.log.
- Fresh focused regression PASS: `00:18 +13: All tests passed!`. All six held lists have checker failures 0: nonadjacent 5, opposite-easy 4, opposite-medium 9, top-and-shadow 5, adjacent-relation 25, validity-test 24. Reserved-source reproduction passes against 646326517.
- This response changes only FINDINGS.md. Existing implementation, fixture, test and held-list changes preserved. No lib/content/questions/dependency changes, no staging or commits. Full requested test command remains blocked by missing seed asset; unrelated approvals and lead acceptance remain undone.
