# Task 1.3: mental rotation cube-net patterns

- Policy read: origin/main `1b87305dcf54e5edb4952fc35b66b4e64d68f00f`, descendant of `1295c1866`. Normal fetch could not write shared FETCH_HEAD; `git fetch --no-write-fetch-head origin main` succeeded. Initial working tree was clean.
- Source read directly from origin/content/bite-sized-cse-algebra-r1, mental-rotation-3d-visualization.yaml. Grouping: opposite easy 0001/0015; invalid overlap medium 0002/0016; opposite hard 0017/0018. Additional exact cube-net candidates: strip first overlap 0007; adjacent relation 0008; validity test 0009; opposite medium 0011; all opposites 0013; top and shadow 0014 (text relation under Part 3b ruling 4); corner triples 0019; nonadjacent 0020. Eight unfigured sources 0003/0004/0005/0006/0010/0012/0021/0022 remain singles. Series 0019 exclusion does not refer to mental-rotation 0019. No capacity numbers measured and no list created.

## Needs the lead

- Checker API cannot independently solve the required queried-face variants while preserving literal source figure data. `FigureSolver.fits` in tool/generator/lib/src/check/solvers/solver.dart accepts only shown figure data and candidate. check/check.dart passes variant.figureSpec and rendered choice text, without type, stem or variant slots. Cube-net source figureSpec contains only kind/cells/labels, with no queried face or question operation. Required rules vary the queried face across the 11 valid nets, so geometry alone does not identify the requested answer. For example, source 0001 asks opposite C and source 0011 asks opposite F using identical figureSpec, yielding F and C respectively. Separate rule names for difficulty do not supply the varying queried face within either rule.
- Adding query/operation fields to source figureSpec would violate the merged exactness comparison in check/check.dart and Part 3b ruling 5. Inferring query from the marked key, mistake metadata or candidate would not be independent solving. A documented checker interface revision is needed, such as passing rendered stem/query slots to fits and all alternative solvers, while retaining the original figureSpec. Worker instructions require stopping for plan/spec/code disagreements, so no tests or implementation were written.
- All requested verification commands remain NOT RUN because implementation stopped at this interface blocker. No generated files, content/questions files, staging or commits touched.

## Review follow-up, November 17

- Refreshed origin/main with `git fetch --no-write-fetch-head origin main`; policy remains `1b87305dcf54e5edb4952fc35b66b4e64d68f00f`, after required `1295c1866`. Normal fetch is blocked by shared git metadata permissions.
- Review reports no findings to fix. Re-read the plan interface and actual correctness calls: `FigureSolver.fits(shown, candidate)` still receives no query or operation. The existing Needs the lead blocker remains valid. No interface revision was authorized, so implementation remains stopped under the brief's disagreement rule. Verification proceeds independently as explicitly requested.
- Verification: `flutter test test/tool/generator --no-test-assets` PASS (exit 0), `00:06 +81: All tests passed!`.
- Verification: `flutter analyze tool/generator test/tool/generator` PASS (exit 0), `No issues found! (ran in 4.6s)`.
- Verification: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator` PASS (exit 0), `Formatted 24 files (0 changed) in 0.03 seconds.`
- Verification: `dart run build_runner build --delete-conflicting-outputs` PASS (exit 0), completed `source_gen:combining_builder on 9712 inputs: 7274 skipped, 11 output, 2427 no-op`. Only ignored generated outputs were produced; git status still shows only FINDINGS.md.
- Verification: `dart run tool/check_no_ai_attribution.dart` PASS (exit 0), `check_no_ai_attribution: OK`.
- Verification: `dart run tool/checks/run_checks.dart` PASS (exit 0), final summary line `OK    legal-text-drafting`. This validates the existing tree, not the blocked Task 1.3 implementation.
- Final disposition: no review findings rejected. Task 1.3 remains incomplete: no rules, solvers, cube-net canonicalizer, type files, capacity measurements or lists authored. Per-type ruleKey/signature counts and checker results are NOT MEASURED/NOT RUN, not HELD capacity outcomes. Only FINDINGS.md was edited; nothing staged or committed.

## Resumption with lead rulings, November 17

- Refreshed policy using `git fetch --no-write-fetch-head origin main`: origin/main is `1b87305dcf54e5edb4952fc35b66b4e64d68f00f`, descendant of `1295c1866`. Initial status remains only the pre-existing untracked FINDINGS.md. Normal fetch cannot write shared FETCH_HEAD.
- Lead ruling 2 is implemented: `FigureSolver.fits(shown, candidate, query)` receives slots. The prior queried-face interface blocker is resolved.

### Needs the lead

- Lead ruling 1 is not implemented on this worktree's current HEAD `e9479cf27`: `tool/checks/generated_types_check.dart` scans only `content/types/` and returns early if that directory does not exist. `tool/generator/lib/src/check/files.dart` unconditionally reads a `.variants.yaml` for every type, and has no held schema/solver-registration path. `rg -n 'types-held|held' tool/generator tool/checks test/tool/generator` returns no matches. Thus required HELD types would either be ignored by the repository gate or fail the file checker for having no list. The brief requires that the checker parse HELD types and verify schema and solver registration without requiring a list. This is a new missing checker dependency, separate from the now-resolved slot interface.
- Per the explicit stop rule for plan/spec/code disagreements, dependent cube-net implementation is stopped pending the held-type checker revision or a lead assignment authorizing this worker to implement it. No capacity has been measured, so no candidate is labeled HELD and no capacity is inferred from the grouping estimates. No tests, rules, solvers, canonicalizer, type files or lists have been authored. Baseline verification below does not certify Task 1.3 implementation.
- Baseline verification on resumed HEAD: `flutter test test/tool/generator --no-test-assets` PASS, exit 0, `00:04 +81: All tests passed!`.
- Baseline verification: `flutter analyze tool/generator test/tool/generator` PASS, exit 0, `No issues found! (ran in 4.5s)`.
- Baseline verification: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator` PASS, exit 0, `Formatted 24 files (0 changed) in 0.03 seconds.`
- Required regeneration before run_checks: `dart run build_runner build --delete-conflicting-outputs` PASS, exit 0, `Built with build_runner/aot in 7s; wrote 26 outputs.` No generated files were hand-edited.
- Baseline verification: `dart run tool/check_no_ai_attribution.dart` PASS, exit 0, `check_no_ai_attribution: OK`.
- Baseline verification: `dart run tool/checks/run_checks.dart` PASS, exit 0, final line `OK    legal-text-drafting`. This does not verify HELD types: generated-types currently ignores that directory.
- Final status: all 11 cube-net candidates remain unimplemented: qt-net-opposite-easy (0001/0015), qt-net-overlap-medium (0002/0016), qt-net-strip-first-overlap (0007), qt-net-adjacent-relation (0008), qt-net-validity-test (0009), qt-net-opposite-medium (0011), qt-net-all-opposites (0013), qt-net-top-and-shadow (0014), qt-net-opposite-hard (0017/0018), qt-net-three-at-corner (0019), qt-net-nonadjacent (0020). IDs use full prefix qt-spatial-abstract-reasoning-. Each has ruleKeys/signatures NOT MEASURED, status BLOCKED (neither LIST 100 nor HELD), per-type checker NOT RUN. Only FINDINGS.md touched; nothing staged or committed.

## Requested fix follow-up, November 17

- Refreshed origin/main with `git fetch --no-write-fetch-head origin main`; policy remains `1b87305dcf54e5edb4952fc35b66b4e64d68f00f`. Remote main matches this revision. HEAD remains `e9479cf27628ae94531955445f36437c0bc82360`, with only FINDINGS.md uncommitted.
- Needs the lead: the recorded missing HELD checker dependency remains unchanged. `generated_types_check.dart` scans only content/types; `check/files.dart` unconditionally reads a variant list. No types-held implementation exists in generator, checks, or generator tests. The brief authorizes cube-net work, not the missing shared checker revision, and explicitly requires stopping on disagreement. No review findings were supplied to fix or reject. Task 1.3 remains blocked, with all counts unmeasured and no per-type checker result. Required baseline verification will run again as requested.
- Fresh verification: `flutter test test/tool/generator --no-test-assets` PASS, `00:04 +81: All tests passed!`.
- Fresh verification: `flutter analyze tool/generator test/tool/generator` PASS, exit 0, `No issues found! (ran in 3.8s)`.
- Fresh verification: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator` PASS, exit 0, `Formatted 24 files (0 changed) in 0.03 seconds.`
- Required regeneration before run_checks: `dart run build_runner build --delete-conflicting-outputs` PASS, `Built with build_runner/aot in 2s; wrote 0 outputs.`
- Fresh verification: `dart run tool/checks/run_checks.dart` PASS, exit 0, final summary `OK    legal-text-drafting`.
- Fresh verification: `dart run tool/check_no_ai_attribution.dart` PASS, exit 0, `check_no_ai_attribution: OK`.
- These are baseline checks only. No implementation, type capacity, variant list, or per-type checker result exists. All 11 candidates retain the prior BLOCKED status and unmeasured ruleKey/signature counts. Only FINDINGS.md changed; nothing staged or committed.

## Resumption after held-type merge

- Policy refreshed with `git fetch --no-write-fetch-head origin main`; remote main and origin/main both equal `1b87305dcf54e5edb4952fc35b66b4e64d68f00f`. Normal fetch remains unable to write shared FETCH_HEAD.
- Current HEAD `2432119b6` contains HELD parsing and solver-registration checks in `check/files.dart` and the content/types-held scan in generated-types. Both prior dependency blockers are resolved. Existing FINDINGS.md is preserved; no other initial changes.
- Continuing Task 1.3 under the same approved scope and estimate, beginning with cube-net canonicalizer tests.

- Cube-net canonicalizer tests first failed because cube-net had no registered canonicalizer. Added D4 and translation normalization, consistent label renaming, cell/choice ordering invariance, query-face preservation, and complete text-choice references. Focused verification: `00:00 +5: All tests passed!`. No rule, solver or type is yet claimed complete.

### Needs the lead: capacity contract mismatch

- Part 3b ruling 2 requires two enumerated counts: distinct rule-parameter sets, and total versions deduplicated by signature. `measureCapacity` adds a ruleKey only inside `if (signatures.add(...))`. Consequently its ruleKeys count is only a count among the first representatives of distinct signatures, not the count of distinct parameter sets across draws.
- A test-first reproduction now exists at `test/tool/generator/cube_net_capacity_contract_test.dart`: two draws produce the same cube-net signature and two distinct documented parameter sets (`profile: 0` and `profile: 1`). Observed signatures=1, ruleKeys=1; independently enumerated ruleKeys=2. Focused test fails `Expected: <2> Actual: <1>`. This is not a per-type capacity result.
- This matters for cube-net source-specific profiles and geometry equivalences: distinct rule parameters can collapse to one label-insensitive spatial signature. Both requested numbers must remain accurate. No capacity numbers for product types have been claimed.
- Under the brief's explicit plan/spec/code disagreement stop rule, cube-net rule/type implementation and capacity reporting stop here. The lead needs to authorize a shared capacity fix (count keys across every draw independently), or record that only signature-representative ruleKeys are intended. No plan/spec edits or shared capacity implementation edits were made. The regression test intentionally preserves this failing contract for review.

- Verification: `flutter test test/tool/generator --no-test-assets` FAIL, exit 1, `00:25 +109 -1: Some tests failed.` The only failing test is the new capacity contract reproduction; the five cube-net canonicalizer tests pass.
- Initial concurrent analyzer startup failed deleting an ephemeral iOS `.packages` path; sequential retry ran analysis and found trailing-comma/directive-order lints in the new files. Those mechanical lints were corrected before the final analyzer retry. No unrelated source was edited.
- Required regeneration: `dart run build_runner build --delete-conflicting-outputs` PASS, exit 0, `Built with build_runner/aot in 6s; wrote 69 outputs.` These are ignored generated outputs; none were hand-edited.
- `dart run tool/checks/run_checks.dart` PASS, exit 0, including `OK    generated-types`, ending `OK    legal-text-drafting`. No cube-net type exists to validate.
- `dart run tool/check_no_ai_attribution.dart` PASS, exit 0, `check_no_ai_attribution: OK`.

- Final analyzer: `flutter analyze tool/generator test/tool/generator` PASS, exit 0, `No issues found! (ran in 3.4s)`.
- Final format: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator` PASS, exit 0, `Formatted 35 files (0 changed) in 0.03 seconds.`
- Files touched: FINDINGS.md; check/cube_net_signature.dart (new); check/signature.dart (registration); cube_net_signature_test.dart (new); cube_net_capacity_contract_test.dart (new, intentionally failing). All code is under the assigned generator/check/test paths. No UI, hand-written question content, dependency, staging or commit changes.

| Type suffix (prefix qt-spatial-abstract-reasoning-) | Source suffixes | RuleKeys | Signatures | Status | Checker |
|---|---|---|---|---|---|
| net-opposite-easy | 0001/0015 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |
| net-overlap-medium | 0002/0016 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |
| net-strip-first-overlap | 0007 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |
| net-adjacent-relation | 0008 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |
| net-validity-test | 0009 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |
| net-opposite-medium | 0011 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |
| net-all-opposites | 0013 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |
| net-top-and-shadow | 0014 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |
| net-opposite-hard | 0017/0018 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |
| net-three-at-corner | 0019 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |
| net-nonadjacent | 0020 | NOT MEASURED | NOT MEASURED | BLOCKED | NOT RUN |

No candidate has LIST 100 or HELD status. Rules, independent folding/mistake solvers, type files, actual capacity CLI runs and per-type checks remain undone. The standalone canonicalizer is a partial deliverable, not completion of Task 1.3.

## Review repair resumption

- Policy refreshed with `git fetch --no-write-fetch-head origin main`: `1b87305dcf54e5edb4952fc35b66b4e64d68f00f`. Normal fetch cannot write shared FETCH_HEAD. Existing uncommitted files preserved.
- The current request explicitly authorizes repairing the shared capacity defect. Root cause confirmed: rule keys are counted only after a new signature. Keys must instead be counted for every draw, independently.
- Relation signature root cause confirmed: label replacement retains unordered relation word order. Regression tests will cover overlap endpoint order and opposite-pair ordering before the fix.
- Focused RED reproduced all three failures: capacity expected 2 keys but got 1; reversed overlap endpoints and reordered opposite pairs produced unequal signatures. After independent key counting and unordered pair normalization, the same focused run passed: `00:00 +9: All tests passed!`. No review findings rejected.
- Full generator test run PASS (exit 0): `00:30 +115: All tests passed!`. Initial analysis found one required trailing comma in the new test helper; corrected before rerunning analysis.
- Final verification: `flutter test test/tool/generator --no-test-assets` PASS (exit 0), `00:30 +115: All tests passed!`.
- Final verification: `flutter analyze tool/generator test/tool/generator` PASS (exit 0), `No issues found! (ran in 3.4s)`.
- Final verification: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator` PASS (exit 0), `Formatted 35 files (0 changed) in 0.04 seconds.`
- Required regeneration before repository checks: `dart run build_runner build --delete-conflicting-outputs` PASS (exit 0), `Built with build_runner/aot in 6s; wrote 66 outputs.` Ignored generated files only, none hand-edited.
- Final verification: `dart run tool/checks/run_checks.dart` PASS (exit 0), final summary `OK    legal-text-drafting`.
- Final verification: `dart run tool/check_no_ai_attribution.dart` PASS (exit 0), `check_no_ai_attribution: OK`.
- Review repairs completed: P1 independent capacity counts and P2 unordered relation canonicalization. The prior shared capacity blocker is resolved. No findings rejected. Task 1.3 itself is still incomplete, with no new blocker asserted: all 11 candidates in the preceding table still have no rules, solvers, type files, capacity CLI measurements, lists or per-type checker results. Their counts remain NOT MEASURED and status remains UNIMPLEMENTED, not HELD or LIST 100. Passing checks certify the current generator changes only.
- Files modified this repair: FINDINGS.md, tool/generator/lib/src/capacity.dart, tool/generator/lib/src/check/cube_net_signature.dart, test/tool/generator/cube_net_signature_test.dart. Preserved pre-existing signature.dart registration and cube_net_capacity_contract_test.dart. No UI, content/questions, dependency, staged or committed changes.

## Cube-net implementation resumption, 03:15 UTC ruling

- Refreshed policy with `git fetch --no-write-fetch-head origin main`; origin/main remains 1b87305dcf54e5edb4952fc35b66b4e64d68f00f. Shared capacity and relation-signature fixes are present. Initial status only FINDINGS.md. No existing changes removed.
- Test-first RED: all 11 new integration cases fail because net-* rules are absent. These cases require exact merged sources, independent checking of fresh draws, rejection of duplicate cells, and rejection of wrong answers.
- Implementation choice: six cells only, coordinate range 0..5, A..F labels. Enumerate the 35 free hexominoes and independently validate the 11 foldable nets. Query and source profile stay in slots. Deterministic geometric distractor selectors exclude the opposite face; no choice-order permutations or label permutations add capacity. Source-specific profiles retain literal source wording and notes at fixed indexes. Fresh wording uses the same named spatial mistakes with queried labels filled in.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-adjacent-relation; distinct ruleKeys: 132; distinct signatures: 126; 100 reachable: yes; exit 0.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-all-opposites; distinct ruleKeys: 7; distinct signatures: 7; 100 reachable: no; exit 0.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-nonadjacent; distinct ruleKeys: 67; distinct signatures: 54; 100 reachable: no; exit 0.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-opposite-easy; distinct ruleKeys: 133; distinct signatures: 55; 100 reachable: no; exit 0.
- First GREEN attempt: 10/11 integration cases passed. Fresh overlap draw exposed a 2x2-cycle configuration among adjacent same-side flaps. The independent orientation-cycle check rejected it. The generator now rejects inconsistent folds before constructing any candidate. Source 0002 and 0016 both reproduced exactly.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-opposite-hard; distinct ruleKeys: 325; distinct signatures: 256; 100 reachable: yes; exit 0.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-opposite-medium; distinct ruleKeys: 66; distinct signatures: 56; 100 reachable: no; exit 0.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-overlap-medium; distinct ruleKeys: 8; distinct signatures: 4; 100 reachable: no; exit 0.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-strip-first-overlap; distinct ruleKeys: 1; distinct signatures: 1; 100 reachable: no; exit 0.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-three-at-corner; distinct ruleKeys: 89; distinct signatures: 84; 100 reachable: no; exit 0.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-top-and-shadow; distinct ruleKeys: 67; distinct signatures: 59; 100 reachable: no; exit 0.

- Capacity CLI, ceiling 2000, seed 20261117: qt-spatial-abstract-reasoning-net-validity-test; distinct ruleKeys: 25; distinct signatures: 24; 100 reachable: no; exit 0.
- Canonicalizer regression RED: swapping the queried adjacent pair A/B to B/A changes the signature. A relation pair is unordered, just as its answer relation is unordered. Normalizing query `faces` sets is part of this worker's cube-net canonicalizer scope. Initial capacity numbers above are preliminary and will be rerun after the fix.
- Stronger independent-solving regression RED: a valid cube has eight corner triples, but the first solver accepted only the rule's selected triple. Correctness must derive each candidate's three normals, without treating the selected generation parameter as the answer. The test enumerates all 20 triples and requires eight accepted sets.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-adjacent-relation; distinct ruleKeys: 132; distinct signatures: 104; 100 reachable: yes; exit 0.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-all-opposites; distinct ruleKeys: 7; distinct signatures: 7; 100 reachable: no; exit 0.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-nonadjacent; distinct ruleKeys: 67; distinct signatures: 54; 100 reachable: no; exit 0.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-opposite-easy; distinct ruleKeys: 133; distinct signatures: 55; 100 reachable: no; exit 0.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-opposite-hard; distinct ruleKeys: 330; distinct signatures: 259; 100 reachable: yes; exit 0.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-opposite-medium; distinct ruleKeys: 66; distinct signatures: 56; 100 reachable: no; exit 0.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-overlap-medium; distinct ruleKeys: 8; distinct signatures: 4; 100 reachable: no; exit 0.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-strip-first-overlap; distinct ruleKeys: 1; distinct signatures: 1; 100 reachable: no; exit 0.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-three-at-corner; distinct ruleKeys: 89; distinct signatures: 84; 100 reachable: no; exit 0.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-top-and-shadow; distinct ruleKeys: 67; distinct signatures: 59; 100 reachable: no; exit 0.

- Revised capacity CLI, ceiling 10000, seed 20261117: qt-spatial-abstract-reasoning-net-validity-test; distinct ruleKeys: 25; distinct signatures: 24; 100 reachable: no; exit 0.
- Focused GREEN: `flutter test test/tool/generator/mental_rotation_rules_test.dart test/tool/generator/cube_net_signature_test.dart --no-test-assets` passed, `00:19 +22: All tests passed!`. The independent solver now accepts all eight geometric corner triples, and unordered queried face sets canonicalize identically. All 14 source questions across 11 types reproduced their literal figure maps, stems, explanations, correct text and wrong-text sets in the integration tests.
- Capacity disposition at ceiling 10000: adjacent-relation (132 ruleKeys / 104 signatures) and opposite-hard (330 / 259) moved to content/types; generated exactly 100 variants each. The other nine remain content/types-held with no variant list. All-opposites has seven admissible shapes after rejecting draws where a named wrong pairing is actually correct; no arbitrary replacement pairing was invented to widen that range.
- Per-type checker CLI for the two lists and nine held schemas/solver registrations exited 0 with no failure output. Held source reproduction and fresh-draw correctness are additionally exercised in integration tests; held files themselves require no list. No UI, source questions, dependencies, staging, or commits changed.
- Wording regression RED during final review: generated adjacent-face notes claimed flat separation and flat corner contact even for queries that share a flat edge. Source notes remain literal at fixed indexes; fresh notes must describe the mistaken folded relationship without asserting an untrue flat arrangement. Added assertions for these source-only claims before correcting the wording and rebuilding the newly authored adjacent list.

## Final Task 1.3 disposition

Counts below are measured CLI results at ceiling 10000 and seed 20261117. IDs have prefix `qt-spatial-abstract-reasoning-net-`; all sources have prefix `q-spatial-abstract-reasoning-mental-rotation-3d-visualization-`. Merged pairs occupy indexes 0 and 1 in listed order; each singleton occupies index 0.

| Type suffix | Sources | RuleKeys | Signatures | Status | Checker |
|---|---|---|---|---|---|
| opposite-easy | 0001/0015 | 133 | 55 | HELD | PASS (schema/registration) |
| overlap-medium | 0002/0016 | 8 | 4 | HELD | PASS (schema/registration) |
| strip-first-overlap | 0007 | 1 | 1 | HELD | PASS (schema/registration) |
| adjacent-relation | 0008 | 132 | 104 | LIST 100 | PASS |
| validity-test | 0009 | 25 | 24 | HELD | PASS (schema/registration) |
| opposite-medium | 0011 | 66 | 56 | HELD | PASS (schema/registration) |
| all-opposites | 0013 | 7 | 7 | HELD | PASS (schema/registration) |
| top-and-shadow | 0014 | 67 | 59 | HELD | PASS (schema/registration) |
| opposite-hard | 0017/0018 | 330 | 259 | LIST 100 | PASS |
| three-at-corner | 0019 | 89 | 84 | HELD | PASS (schema/registration) |
| nonadjacent | 0020 | 67 | 54 | HELD | PASS (schema/registration) |

- All earlier Needs the lead dependencies in this file are resolved by the merged lead fixes. No new unresolved blocker. Eight unfigured sources remain singles, and no series question was changed. No figure-sheet, blind-solve, approval, app/device, release or deployment work was attempted; those are outside this assignment. The lead retains integration and independent acceptance.

### Final verification on the completed patch

- PASS, exit 0: `flutter test test/tool/generator --no-test-assets`: `00:33 +149: All tests passed!`.
- PASS, exit 0: `flutter analyze tool/generator test/tool/generator`: `No issues found! (ran in 5.0s)`.
- PASS, exit 0: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: `Formatted 44 files (0 changed) in 0.09 seconds.`
- PASS, exit 0, run before run_checks: `dart run build_runner build --delete-conflicting-outputs`: `Built with build_runner/aot in 8s; wrote 82 outputs.` Only ignored generated outputs changed; none hand-edited.
- PASS, exit 0: `dart run tool/checks/run_checks.dart`: `OK    generated-types`, final line `OK    legal-text-drafting`.
- PASS, exit 0: `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`.
- PASS, exit 0: `git diff --check`. Staged file list is empty. No commits made.
- Files touched: FINDINGS.md; rules/mental_rotation/nets.dart and sources.dart; check/solvers/mental_rotation/net_solver.dart; rule.dart and solver.dart registry entries; check/cube_net_signature.dart; mental_rotation_rules_test.dart and cube_net_signature_test.dart; 11 type YAML files under folding-and-checking-cube-nets across types/types-held; two generated variant YAML lists under types. All assigned implementation work is present. Lead blind solve, independent audit, approval and release remain outside this worker stage.

## Review repair: impossible front/top orientation and adjacent-edge explanation

- Policy refreshed from origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f, confirmed equal to remote main by git ls-remote. git fetch could not write external Git metadata (Operation not permitted); no policy gap remains because the remote hash matches the available revision.
- Accepted both P2 findings. Root causes: admissible checks only the front face for opposite-hard profile 1; fresh adjacent-relation explanations assume every shared cube edge joins previously free edges. Add regressions for invalid/missing upFace in fits and validateRanges, and fresh explanation wording for both flat-adjacent and flat-separated faces. Preserve literal merged source content and all pre-existing changes.
- Test-first RED reproduced six failures: missing, unknown, same-front, opposite-front and non-string upFace were accepted by fits; fresh adjacent explanations contained the incorrect free-edge claim. The perpendicular-up positive control passed. Fix centralizes profile 1 orientation validation in admissible, shared by fits and validateRanges; fresh explanations now say the faces share an edge on the cube.
- Focused GREEN: `flutter test test/tool/generator/mental_rotation_rules_test.dart --no-test-assets` exited 0: `00:19 +17: All tests passed!`. Valid perpendicular top faces remain accepted; invalid queries are rejected through both public solver entry points.
- Regenerated adjacent-relation LIST 100 with the generator CLI, seed 20261117. Structured before/after comparison proves only 99 fresh explanationText slots changed; index 0 and all figures, choices, signatures, ruleKeys, ordering and metadata stayed identical. A comparison script initially hit unsupported Python zip(strict=...) and restored the original list; rerunning with a compatible comparison completed successfully.
- Exact requested `flutter test test/tool/generator` exited 1 before test execution: `No file or variants found for asset: assets/seed/content.db.` / `Error: Failed to build asset bundle`. No protected package regeneration authorized or attempted. Continue with the brief's explicit `--no-test-assets` test command; report the exact command as failed, not passed.
- Analyzer first run found two infos in new tests (prefer_const_declarations, require_trailing_commas); corrected both before final rerun.
- Final PASS (exit 0): `flutter test test/tool/generator --no-test-assets`: `00:34 +155: All tests passed!`.
- Final PASS (exit 0): `flutter analyze tool/generator test/tool/generator`: `No issues found! (ran in 5.2s)`.
- Final PASS (exit 0): `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: `Formatted 44 files (0 changed) in 0.10 seconds.`
- PASS (exit 0), before run_checks: `dart run build_runner build --delete-conflicting-outputs`: `Built with build_runner/aot in 6s; wrote 68 outputs.` Ignored generated outputs only; no generated source hand-edited.
- Final PASS (exit 0): `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`.
- Final PASS (exit 0): `dart run tool/checks/run_checks.dart`: `OK    generated-types`; final summary `OK    legal-text-drafting`. Both LIST 100 files and all nine HELD type schemas/registrations pass. Previous capacity counts and dispositions remain unchanged; only explanation wording and rejection of impossible queries changed.
- Review repair files touched: FINDINGS.md; tool/generator/lib/src/check/solvers/mental_rotation/net_solver.dart; tool/generator/lib/src/rules/mental_rotation/nets.dart; test/tool/generator/mental_rotation_rules_test.dart; content/types/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-adjacent-relation.variants.yaml (regenerated). No findings rejected. No UI, dependencies, content/questions, staging or commits changed. Lead acceptance remains pending; exact asset-bundling test command remains blocked by the absent seed asset.
- Final `git diff --check` passed (exit 0); `git diff --cached --name-only` was empty. Existing uncommitted changes preserved.
