# Series/grouping release fixes and R6

- Startup: clean worktree; policy origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885 includes 1295c1866. `git fetch origin main` cannot write shared FETCH_HEAD; `git ls-remote origin refs/heads/main` independently confirms the identical current main hash. Read policy, plan, spec Part B, rulings R1-R6 and audit-r1a.
- Using test-driven development, systematic debugging and executing-plans for this bounded worker assignment. No staging, commits, UI, source content or approvals.
- Corner-edge-count has eight rule sets expanded by five outlines. Restricting the corner walk to squares removes invalid cosmetics; measure and hold if below 20.
- Center-cuts source 0003 has counts 1,2,3,2(off), with unique extrema. Generated ties come from allocating extrema by row order. Require unique full-row extrema in generator and independent solver, then remeasure.

## Needs the lead

- Group-line-count source 0009 repeats the same two-line circle three times. Three distinct wrong figure choices cannot be diagnosed by three meaningful feature mistakes while reproducing that source. Audit explicitly identifies this source conflict. Hold the type pending a source/content-lane ruling rather than invent new diagnoses or change the reserved question. Continue all other items.
- Group-specific-rule has 30 identical `4 sides` keys among 45 tasks. R6 explicitly permits holding instead of redesigning. Hold this type and preserve its measured list for review.

- Verification environment: exact `flutter test test/tool/generator/...` cannot build its bundle because ignored assets/seed/content.db is absent. No protected seed is built or copied. Use Flutter's supported `--no-test-assets` for these tool-only tests and report the exact-command limitation separately.

- RED evidence: `flutter test --no-test-assets test/tool/generator/answer_variety_test.dart test/tool/generator/release_series_grouping_test.dart`: 1 passed, 8 failed. Failures demonstrate missing R6 checks for text/math/canonical figures, nonsquare corner draws, tied center extrema, false held line-count notes, and unresolved types still active.
- Implemented full stored active-list R6 validation at the file-checker boundary. Individual solver tests remain partial draws, not distribution evidence. Answer figures canonicalize without shown figures; math uses reduced exact rational values; text uses filled key text. Disabled and held lists are exempt.
- Held all four assigned type definitions with enabled=false. Corner and center restrictions are now implemented on both generation and independent solving paths. Held line-count retains its source-blocked positional mistakes, but its count descriptions now use actual per-choice slots. No source question changed.

- R5 measurement: series-corner-edge-count: 8 ruleKeys, 8 task signatures at 10000 draws; regenerated 8; checker 0 failures; active R6 0 failures. Source comparisons use prod root 646326517.


- R5 measurement: group-center-cuts: 3 ruleKeys, 3 task signatures at 10000 draws; regenerated 3; checker 0 failures; active R6 0 failures. Source comparisons use prod root 646326517.


- R5 measurement: group-line-count: 20 ruleKeys, 20 task signatures at 10000 draws; regenerated 20; checker 0 failures; active R6 0 failures. Source comparisons use prod root 646326517.


- R5 measurement: group-specific-rule: 45 ruleKeys, 45 task signatures at 10000 draws; regenerated 45; checker 0 failures; active R6 1 failures. Source comparisons use prod root 646326517.
  - qt-spatial-abstract-reasoning-group-specific-rule #7 answer-variety: one correct answer appears in 30 of 45 versions; maximum is half
- Capacity outcome: square-only corner-edge-count has 8 tasks; unique-extrema center-cuts has 3. Both are below the approved 20 floor and remain held. Line-count has 20 tasks but remains held for its unresolved source diagnoses. Specific-rule has 45 tasks and fails active R6 (30/45 identical keys), so remains held. All four regenerated lists reproduce their index 0 on 646326517 and pass per-variant checking.
- Environment blocker for repository checks: `dart run tool/checks/run_checks.dart` cannot compile because ignored Question/Choice generated parts are absent in this worktree. No application source or generated part was edited. Continue scoped verification; report repository gate as failed unless safely resolved.
- Full tool suite (supported no-assets mode) exposed unrelated existing matrix tests that search only content/types-held for matrix-size-fill and matrix-fill-union, while this candidate keeps those types active. Both fail `Bad state: No element`. These types/tests are outside the assignment and were left unchanged. Remaining suite is still running.

- GREEN evidence: initial focused regressions passed 9/9 after fixes. Full no-assets tool run ended `02:24 +248 ~6 -2: Some tests failed.` The only failures are the two pre-existing held-only matrix lookups above. Six golden sheet tests skipped by the existing test policy; no visual artifacts or screenshots created.
- `flutter analyze tool/generator test/tool/generator`: `No issues found! (ran in 27.7s)`.
- `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: `Formatted 61 files (0 changed)`.
- `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`.
- Exact required `flutter test test/tool/generator`: exit 1, `No file or variants found for asset: assets/seed/content.db. Error: Failed to build asset bundle`. Supported no-assets mode provided actual tests without inventing or rebuilding content.
- A concurrent repeat of attribution failed inside Dart native-asset install_name_tool while another Dart command bundled the same ignored dylib. The earlier attribution run passed. Serialize remaining Dart commands and repeat attribution after running processes finish; this is tool-cache contention, not a product check result.
- Final focused run adds persistent verification of the regenerated lists against prod root 646326517: `flutter test --no-pub --no-test-assets test/tool/generator/answer_variety_test.dart test/tool/generator/release_series_grouping_test.dart` ended `00:13 +10: All tests passed!`.
- Confirmed repository-check exit 254: missing question.freezed.dart, question.g.dart, choice.freezed.dart and choice.g.dart prevent compilation. This is the final run_checks.dart blocker, not a passing gate.
- Final analyzer after the added source-fidelity test: `No issues found! (ran in 26.6s)`.
- Final format: `Formatted 61 files (0 changed) in 0.33 seconds.` Final attribution repeat: `check_no_ai_attribution: OK`, exit 0. Native-asset contention cleared on the repeat.
- Final diff review confirms only the assigned six generator/checker Dart files, two new tests, four type/list pairs moved to held, and this findings file. `git diff --check` passes; index remains empty. All application files, source questions, dependencies and approval ledger remain untouched.

## Supplemental whole-list checker outcome

- `dart run tool/generator/bin/check.dart` completed with exit 1. The only reported failures are the two out-of-scope R6 net types already named in the ruling:
  - `qt-spatial-abstract-reasoning-net-adjacent-relation #0 answer-variety: one correct answer appears in 25 of 25 versions; maximum is half`
  - `qt-spatial-abstract-reasoning-net-validity-test #0 answer-variety: one correct answer appears in 24 of 24 versions; maximum is half`
- Needs the lead: integrate the separately assigned net-type fixes before treating the active checker as green. This worker did not touch those types.
- Removed the temporary ignored remeasurement runner after its outputs were recorded. For reproduction: capacity uses measureCapacity ceiling=10000 and seed=20261117; fresh generateVariants counts are 8,3,20,45 in the order listed above. All list data was written by writeVariantList, never hand-edited.

## Review follow-up verification

- Supplied review reports NO FINDINGS; no code correction or rejection is required. Preserving the existing implementation and held lists.
- Policy origin/main remains 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, independently confirmed with git ls-remote. Fetch remains denied at shared FETCH_HEAD.
- Fresh exact `flutter test test/tool/generator`: exit 1, `No file or variants found for asset: assets/seed/content.db.` and `Error: Failed to build asset bundle`. SDK cache execution now works; the prior review's SDK permission error does not describe this run.
- Fresh `flutter analyze tool/generator test/tool/generator`: exit 0, `No issues found! (ran in 7.2s)`.
- Fresh `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: exit 0, `Formatted 61 files (0 changed) in 0.18 seconds.`
- Fresh `dart run tool/checks/run_checks.dart`: exit 254 before checks, missing Question/Choice generated parts (`question.freezed.dart`, `question.g.dart`, `choice.freezed.dart`, `choice.g.dart`). Existing worktree setup blocker persists. No generated files edited.
- Fresh `dart run tool/check_no_ai_attribution.dart`: exit 0, `check_no_ai_attribution: OK`.
- All five exact required commands have completed. No review findings were rejected because none were supplied. This follow-up changes only FINDINGS.md; prior code, tests and held type/list changes are preserved.
- Fresh supplemental focused regressions: `flutter test --no-pub --no-test-assets test/tool/generator/answer_variety_test.dart test/tool/generator/release_series_grouping_test.dart` exited 0, `+10: All tests passed!`. This does not replace the failed exact full-suite command.
- Final `git diff --check` exit 0; staged diff empty. Remaining lead decisions are unchanged: line-count source diagnosis conflict, specific-rule R6 majority, and environment prerequisites for exact full tests/repository checks.
