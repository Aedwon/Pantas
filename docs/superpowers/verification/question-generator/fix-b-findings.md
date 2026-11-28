# Audit B fixes

- Policy: origin/main 2bd4a95172704b228c5cc6e00a67a5597d2536a4, verified against git ls-remote. Fetch cannot write external Git metadata; remote and local main match.
- Confirmed matrix freeze mistakes wrap across rows at left-column blanks; dot-sum uses a fixed +2 instead of the input difference; ray-turn lacks the competing reflection solver.
- Confirmed net adjacent queries need corner-only flat contact. Hard-net named directional mistakes currently fall back to unrelated side faces.

## Needs the lead

- R5 net-all-opposites: 7 ruleKeys, 7 signatures in 2000 draws, seed 20261117.
- R5 net-nonadjacent: 67 ruleKeys, 52 signatures in 2000 draws, seed 20261117.
- R5 net-opposite-easy: 67 ruleKeys, 52 signatures in 2000 draws, seed 20261117.
- R5 net-opposite-medium: 66 ruleKeys, 52 signatures in 2000 draws, seed 20261117.
- R5 net-overlap-medium: 8 ruleKeys, 4 signatures in 2000 draws, seed 20261117.
- R5 net-strip-first-overlap: 1 ruleKeys, 1 signatures in 2000 draws, seed 20261117.
- R5 net-three-at-corner: 89 ruleKeys, 64 signatures in 2000 draws, seed 20261117.
- R5 net-top-and-shadow: 67 ruleKeys, 52 signatures in 2000 draws, seed 20261117.
- R5 net-validity-test: 25 ruleKeys, 24 signatures in 2000 draws, seed 20261117.
- R5 matrix-fill-union: 12 ruleKeys, 24 signatures in 2000 draws, seed 20261117.
- R5 matrix-binary-fill-row: 60 ruleKeys, 32 signatures in 2000 draws, seed 20261117.
- R5 matrix-corner-grid: 6 ruleKeys, 28 signatures in 2000 draws, seed 20261117.
- R5 matrix-size-columns: 20 ruleKeys, 10 signatures in 2000 draws, seed 20261117.
- R5 matrix-size-fill: 12 ruleKeys, 40 signatures in 2000 draws, seed 20261117.
- R5 matrix-size-latin: 90 ruleKeys, 72 signatures in 2000 draws, seed 20261117.
- R5 matrix-arrow-column: 6 ruleKeys, 30 signatures in 2000 draws, seed 20261117.
## Fix evidence

- Seven planted regressions failed before fixes, then passed: same-row freeze references, input-difference continuation, reflection library coverage, safe ray draws, corner-only flat queries.
- Hard-net geometry regression failed before fixes, then passed. Profile 0 now uses a six-square path with opposite at distance 3 and mistakes at distances 2, 4, 5. Profile 1 requires actual lower, left, and right neighbors and excludes the up face. Each generated note names its own mistake and face.
- Removed matrix extraForm from generator and solver rule parameters because it only changes a distractor.
- Standard flutter test fails before tests because assets/seed/content.db is absent. Focused generator tests run with --no-test-assets; no seed or protected package was built.

- R5 matrix-growing-turn: 16 ruleKeys, 80 signatures in 2000 draws, seed 20261117.
- R5 net-adjacent-relation: 34 ruleKeys, 25 signatures in 2000 draws, seed 20261117.
- R5 net-opposite-hard: 6 ruleKeys, 5 signatures in 2000 draws, seed 20261117.
- R5 matrix-dot-sum: 200 ruleKeys, 862 signatures in 2000 draws, seed 20261117.
- R5 matrix-ray-union: 1964 ruleKeys, 1964 signatures in 2000 draws, seed 20261117.
- R5 matrix-sized-ray-union: 112 ruleKeys, 549 signatures in 2000 draws, seed 20261117.
- R5 matrix-ray-intersection: 2000 ruleKeys, 2000 signatures in 2000 draws, seed 20261117.
- R5 matrix-form-ray: 1603 ruleKeys, 1312 signatures in 2000 draws, seed 20261117.
- R5 matrix-outline-latin: 356 ruleKeys, 356 signatures in 2000 draws, seed 20261117.
- R5 matrix-size-dots: 24 ruleKeys, 120 signatures in 2000 draws, seed 20261117.
- R5 matrix-size-transfer: 192 ruleKeys, 839 signatures in 2000 draws, seed 20261117.
- R5 matrix-corner-reflection: 144 ruleKeys, 144 signatures in 2000 draws, seed 20261117.
- R5 matrix-corner-step: 120 ruleKeys, 120 signatures in 2000 draws, seed 20261117.
- R5 matrix-ray-turn: 1375 ruleKeys, 1375 signatures in 2000 draws, seed 20261117.
- R5: net-adjacent-relation and net-opposite-hard moved from active types to types-held. Both retain regenerated merged-source profiles. Existing held types stay held; capacity figures above are measured observations, not inferred totals.
- No additional audit-b minor wording finding was left open. The three duplicate-task findings use R1 signatures; binary-fill-row (32) and size-latin (72) remain held, outline-latin reaches 356 measured signatures.
- Environment blocker: run_checks.dart initially cannot compile because ignored question/choice Freezed and JSON parts are absent. Regenerating only these four outputs with build_runner; no hand edits or protected-content build.

## Final verification

Source HEAD: ddbb15e3a8ce88aaec39df92b5c2f7b3bf2fcbdb. Source patch SHA256 (changed and untracked source paths, including deletion markers, excluding this findings file): 8630cc456d2c4d1e2557641a445a45a4f74357051ea6e25ed4b9d3177065658f.

- `flutter test test/tool/generator`: FAIL before execution: `No file or variants found for asset: assets/seed/content.db.` / `Error: Failed to build asset bundle`.
- `flutter test --no-pub --no-test-assets test/tool/generator`: PASS, `02:48 +209: All tests passed!` This includes source reproduction from the production content ref. The added checker-level fixture was subsequently verified with the audit regression file: `00:02 +9: All tests passed!`.
- `flutter analyze tool/generator test/tool/generator`: PASS, `No issues found! (ran in 7.5s)`.
- `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: PASS, `Formatted 54 files (0 changed) in 0.14 seconds.`
- `dart run tool/checks/run_checks.dart`: PASS, exit 0, every check reports OK, including `OK    generated-types` and `OK    content-approval`. The missing model parts were generated using build_runner, which wrote only ignored outputs; no tracked application file changed.
- `dart run tool/check_no_ai_attribution.dart`: PASS, `check_no_ai_attribution: OK`.
- `dart run tool/generator/bin/check.dart`: PASS, exit 0, no failures.
- `git diff --check`: PASS. Index remains empty. No stage, commit, UI edit, content/questions edit, dependency addition, or protected package build.

## Needs the lead, final

- The asset-bundled test command needs the existing seed assets. The complete generator suite passed without assets; no placeholder asset was created.
- Adjacent-relation (25 measured signatures) and opposite-hard (5) remain held under R5. All 30 type counts are recorded above. Existing held types remain held. No audit-b wording finding remains deferred.
- Lead review and approval remain outstanding. No release acceptance is claimed.

## Verification retry, November 17

- New review reports no findings; no implementation change requested beyond completing verification. Existing fix-b changes preserved.
- Policy origin/main is 2bd4a95172704b228c5cc6e00a67a5597d2536a4, descendant of 1295c1866. `git ls-remote origin refs/heads/main` confirms the same remote revision. Fetch cannot write external FETCH_HEAD; policy is current despite that metadata restriction.
- Retry: standard generator tests exit 1: `No file or variants found for asset: assets/seed/content.db.` / `Error: Failed to build asset bundle`. SDK cache permissions no longer block execution. No asset placeholder or protected package built.
- Retry analyzer PASS: `No issues found! (ran in 8.5s)`, exit 0.
- Retry format PASS: `Formatted 54 files (0 changed) in 0.15 seconds.`, exit 0.
- Retry attribution PASS: `check_no_ai_attribution: OK`, exit 0.
- Retry repository checks PASS, exit 0. Summary includes `OK    generated-types`, `OK    content-approval`, and `OK    legal-text-drafting`; every check reports OK.
- Retry `git diff --check` PASS; index remains empty.
- Retry asset-free generator suite PASS: `flutter test --no-pub --no-test-assets test/tool/generator`, `01:29 +210: All tests passed!`, exit 0. Includes production source reproduction and audit-b regressions.
- Files touched by this retry: FINDINGS.md only. No new review findings to fix or reject. Existing uncommitted implementation and generated lists preserved; nothing staged or committed.
- Outstanding: exact standard test command still requires the missing seed asset. Lead acceptance remains outstanding.
