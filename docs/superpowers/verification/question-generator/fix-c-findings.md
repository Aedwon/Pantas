# Re-audit fixes C

- Startup policy: origin/main 2bd4a95172704b228c5cc6e00a67a5597d2536a4, descendant of 1295c1866. Fetch cannot write external FETCH_HEAD; git ls-remote confirmed main matches this exact readable revision. Initial worktree clean. No staging or commits authorized. Estimate: 45 minutes; lead owns velocity/SSOT updates.
- Root causes confirmed: ray reflection competitor supports only left-right; dot-sum lacks arithmetic continuation competitor; intersection lacks highest-ray competitor. Regression fixtures will preserve the audited indexes before regeneration.
- Accepted open Minors: group-polygon-replacement and matrix-corner-reflection remain unchanged per assignment.

## Needs the lead

- Corner-step's merged source itself uses a circle example while its wording counts corners. Matrix figures draw square, circle, triangle, pentagon, star, not rectangle. Thus four-corner-only draws cannot reproduce the source as an eligible type. Preserve index 0 exactly, restrict new draws to square, measure and hold; source wording/figure correction belongs to the content lane.

- Test-first evidence: reaudit_regression_test.dart ran before implementation, 0 passed / 7 failed. Both exact audit fixtures were incorrectly accepted by the checker, highest-ray source was accepted, draw constraints were absent, and the corner solver accepted the source circle.
- Required plain Flutter test command fails before assertions because assets/seed/content.db is absent. Existing checker brief explicitly prescribes --no-test-assets for fresh worktrees; focused tests execute successfully with that flag. No seed/content package is created.

- Solver-library proof before generator constraints: both preserved audit fixtures now fail correctness with `wrong choice completes a library rule`; focused checker tests report `+2: All tests passed!`. This isolates the checker change from later draw constraints.
- Content lane: matrix-ray-intersection source q-spatial-abstract-reasoning-figure-matrices-0009 admits the unique highest-ray alternative. Hold its type and list; the source question remains untouched and needs content-lane correction before eligibility.

- R5 capacity, ray-turn, seed 20261117, 10,000 draws, exit 0:
```text
distinct ruleKeys: 2185
distinct signatures: 2185
100 reachable: yes
Running build hooks...Running build hooks...
```

- R5 capacity, dot-sum, seed 20261117, 10,000 draws, exit 0:
```text
distinct ruleKeys: 163
distinct signatures: 811
100 reachable: yes
Running build hooks...Running build hooks...
```

- R5 capacity, ray-intersection, seed 20261117, 10,000 draws, exit 0:
```text
distinct ruleKeys: 9978
distinct signatures: 9978
100 reachable: yes
Running build hooks...Running build hooks...
```

- R5 capacity, corner-step, seed 20261117, 10,000 draws, exit 0:
```text
distinct ruleKeys: 9
distinct signatures: 9
100 reachable: no
Running build hooks...Running build hooks...
```

- R5 result: corner-step reaches only 9 task signatures (8 square-only generated tasks plus the unchanged, ineligible source) and 9 ruleKeys at 10,000 draws, confirmed again after narrowing params.forms to square. Moved type to types-held and regenerated a 9-entry held list. No rectangle support exists in the matrix figure kind. Ray-intersection remains held despite ample nominal capacity because its merged source fails uniqueness.
- Verification setup: run_checks.dart initially cannot compile because this fresh worktree lacks question/choice Freezed and JSON generated parts. Regenerate only those required parts using build_runner; never hand-edit them.

- ray-turn: stored 100 signatures 100, ruleKeys 100; index 0 byte-equivalent data preserved

- dot-sum: stored 100 signatures 100, ruleKeys 79; index 0 byte-equivalent data preserved

- ray-intersection: stored 100 signatures 100, ruleKeys 100; index 0 byte-equivalent data preserved

- corner-step: stored 9 signatures 9, ruleKeys 9; index 0 byte-equivalent data preserved

- The existing wording test enforced the text-length rejection that this assignment explicitly removes for corner-step. Its initial full-suite failure was corner-step seed 2 (24-character correct label versus 23-character longest wrong label). Narrowed that test's exception to matrix-corner-step; all other types retain the test. The new regression separately requires bottom-right keys to occur.
- Scoped build_runner regeneration completed: `Built with build_runner/aot in 19s; wrote 13 outputs.` Generated parts are ignored and were not hand-edited. Repository checks now execute.
- Full generator suite with the documented fresh-worktree flags: `flutter test test/tool/generator --no-test-assets --no-pub`, exit 0, `00:46 +217: All tests passed!`. A concurrent pub refresh briefly failed to remove the iOS ephemeral package link; rerun with --no-pub succeeded. No dependency or tracked platform change.
- `dart run tool/checks/run_checks.dart`: exit 0, including `OK    generated-types`, `OK    content-approval`, and every remaining registered check. Existing accepted exceptions are printed by the runner; no new exception was added.
- `dart run tool/generator/bin/check.dart`: exit 0. Both shipped 100-entry lists pass with the added solver library and prod source checks. Held lists are not claimed to pass correctness.
- `dart run tool/check_no_ai_attribution.dart`: exit 0, `check_no_ai_attribution: OK`.
- Lead still owns independent review, blind solves, approvals, velocity/SSOT integration, and the two source content corrections. Nothing staged or committed; no UI, content/questions, dependency or hand-edited generated model change.

## Needs the lead: dot-sum reserved-source exception

- Exhaustive final stored-list inspection found index 0's first completed dot-sum row is 1,2,3, where sum and continuation coincide. Its second completed row rejects continuation, so the strengthened checker still proves the offered answer unique. All newly generated indexes 1..99 have no such completed row. The literal instruction to exclude equality in every completed row conflicts with preserving this source exactly. Preserved the source and completed all other fixes; lead must rule on this one reserved-source exception or route a source correction to the content lane. No source or spec was changed to resolve it.
- All 100 stored ray-turn examples exclude both reflection axes in their completed row, including the reserved source.

- Final verification: analyzer exit 0, `No issues found! (ran in 3.8s)`; formatter exit 0, `Formatted 55 files (0 changed) in 0.09 seconds.`
- Final focused matrix test after narrowing the held-source exemption: exit 0, `00:31 +22: All tests passed!`. All other competing solvers remain tested for intersection.
- Candidate HEAD: 011b056856565f10fbf6f4d9778382275c89fb56; changed-file identity (paths and contents, excluding this findings log): SHA-256 9559fb13746d9796710aed68b4ec11b83e8279a539b69ba19bf794cccc7d4f3b. git diff --check passes, staged diff empty.

## Follow-up on sole unresolved re-audit finding

- Policy refreshed from readable origin/main f417e5f6c438b6f0043386e1124af2a006f20318; git ls-remote confirms current remote main matches. Fetch cannot write external FETCH_HEAD in this sandbox.
- Needs the lead: the reported dot-sum row remains a valid finding, but changing reserved index 0 contradicts the explicit exact-source requirement. No authority in R1 to R5 resolves that conflict. No code or variant change made; existing work preserved. This is a deferred decision, not a rejected finding.
- Verification now executes through the installed SDK; the earlier SDK-cache permission failure does not recur. Formatter exit 0: `Formatted 55 files (0 changed) in 0.08 seconds.`
- Fresh required commands: plain generator test exits 1, `No file or variants found for asset: assets/seed/content.db.` / `Error: Failed to build asset bundle`. Analyzer exits 0, `No issues found! (ran in 3.8s)`. Checks runner exits 0, all registered checks OK, including generated-types and content-approval. Attribution exits 0, `check_no_ai_attribution: OK`. No new exceptions introduced.
- Recounted stored signatures/ruleKeys: ray-turn 100/100; dot-sum 100/79; held ray-intersection 100/100; held corner-step 9/9. Exhaustive completed-row equality scan finds only dot-sum index 0 row 0. git diff --check passes; staged diff is empty.
- Supplemental documented fresh-worktree run: `flutter test test/tool/generator --no-test-assets --no-pub`, exit 0, `00:40 +217: All tests passed!`. Required plain command remains reported FAIL because its asset bundle cannot build. This follow-up touches FINDINGS.md only; no staging or commits.
- Lead ruling (Nov 17 09:00 UTC): dot-sum index 0 keeps its source row 1,2,3. Its second completed row rules out the continuation rule, so the source has one answer and the checker passes; new draws exclude such rows.
