# Part 3b adviser rulings

- Policy: origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f, confirmed against GitHub main via `gh api`. It descends from 1295c1866. `git fetch origin main` cannot write FETCH_HEAD under sandbox restrictions; read-only remote verification confirms the cached policy is current.
- Startup tree was clean. Tasks 1.1 and 1.2 are present. Production rule and solver registries are empty; existing rules and figure kind are test-only.
- Interface update: introduce a rule result holding a Variant, its rule parameters, and cosmetics. Generation owns the ruleKey hash; checker solvers independently derive parameters and validate cosmetics. No UI or content question edits.
- Red tests observed: adviser tests failed to compile because choiceKind, ruleKey, cosmetics, solver methods, and the ignore hook were absent. Capacity tests separately failed because the capacity library and CLI were absent.
- Existing fixtures need the newly required metadata. Their original planted defects are retained while migrating the fixture schema.
- First integrated run: 76 tests passed after migrating fixture metadata. The inconsistent-cosmetics fixture and choice-kind fixtures fail their named checks.
- Capacity enumerates exactly the requested draw ceiling, keeps unique signatures, and counts ruleKeys among retained versions. It uses a fixed default seed and accepts --seed for reproducibility. It does not write variant lists.

## Verification and handoff

- Candidate: bb280043dec4fa30950224e0d10d56254e022fb5 plus this unstaged patch. No files were staged or committed. No UI, question content, dependencies, or tracked generated files changed.
- `flutter test test/tool/generator --no-test-assets`: PASS, `00:03 +79: All tests passed!`.
- `flutter analyze tool/generator test/tool/generator`: PASS, `No issues found! (ran in 3.5s)`.
- `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: PASS, `Formatted 24 files (0 changed) in 0.02 seconds.`
- `dart run build_runner build --delete-conflicting-outputs`: PASS, `Built with build_runner/aot in 30s; wrote 4763 outputs.` No tracked generated-file diff resulted.
- `dart run tool/checks/run_checks.dart`: PASS, all named checks OK. `no content/types/ directory; generated types skipped`, then `OK    generated-types`. Existing accepted exceptions remain reported by the check runner.
- `dart run tool/check_no_ai_attribution.dart`: PASS, `check_no_ai_attribution: OK`.
- `git diff --check`: PASS.
- Lead review and integration remain with the lead. This is implementation evidence, not independent acceptance. Real production rules, solvers, and cube-net registration remain the separately assigned Task 1.3 work.

## Review corrections, 2026-11-17

- Current policy remains origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f, confirmed by git ls-remote. Fetch cannot write FETCH_HEAD outside this worktree.
- Confirmed both review findings: correctness and mistake validation incorrectly require choice figures whenever the stem has a figure; capacity deduplicates only supplied signatures.
- Use the existing figure solver map contract for text answers: candidate maps contain rendered text and optional value. Figure candidates keep their existing shape. This preserves independent solver and alternative-library checks without a new interface.
- Capacity will use the checker's canonicalSignature, including registered per-kind ignored attributes, before retaining a draw.
- Regression red run reproduced both reported defects: the valid text-answer figure produced correctness/missing-figure failures; 100 equivalent rotated/labeled draws counted as 100 signatures instead of 1. Flutter startup succeeds in this session.
- Focused regressions pass, then all 81 generator tests pass. Analyzer initially found two import-order lint issues in the new test; corrected them and reran clean. Formatter passes.
- Code generation completed: Built with build_runner/aot in 5s; wrote 44 outputs. Existing drift deprecation warning remains.
- Concurrent check launches exposed a native-asset bundling race: attribution startup saw objective_c.dylib while it was not a complete Mach-O file. Serialize subsequent Dart checks and rerun attribution after the check runner finishes.

## Correction verification

- Both findings accepted and fixed; none rejected. TDD evidence: both regressions failed on the old implementation and passed after the fixes.
- `flutter test test/tool/generator --no-test-assets`: PASS, `00:05 +81: All tests passed!`.
- `flutter analyze tool/generator test/tool/generator`: PASS, `No issues found! (ran in 3.4s)`.
- `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: PASS, `Formatted 24 files (0 changed) in 0.02 seconds.`
- `dart run build_runner build --delete-conflicting-outputs`: PASS, `Built with build_runner/aot in 5s; wrote 44 outputs.`
- `dart run tool/checks/run_checks.dart`: PASS, exit 0; `OK    generated-types` through `OK    legal-text-drafting`. Existing accepted exceptions remain reported.
- `git diff --check`: PASS. No new tracked generated-file changes, UI edits, content edits, staging, or commits.
- Files changed during this correction: FINDINGS.md; tool/generator/lib/src/check/check.dart; tool/generator/lib/src/check/solvers/solver.dart; tool/generator/lib/src/capacity.dart; test/tool/generator/adviser_test.dart; test/tool/generator/capacity_test.dart. Preserved the preexisting Part 3b patch.
- `dart run tool/check_no_ai_attribution.dart`: PASS on serialized rerun, exit 0, `check_no_ai_attribution: OK`.
- Remaining: lead review, commit, and integration. No implementation work remains for these two findings.
