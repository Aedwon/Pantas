# W4c engineering re-audit 2

Date: October20,2026. Independent reviewer: GPT-6 Astra. Explicit user request: "Finish and re-audit W4c"; later "continue" resumed the same interrupted reviewer. Policy mainf3825a05; AGENTS/WORKFLOW blobs unchanged on resumption. No replacement or duplicate reviewer.

Candidate: f93743f48282967c3365e17efae11bdd908a17bf. Whole-family base ffc8045bc7eb2d427c82931f7bc1c43263e5223f. Correction delta from f495a8dda858ff13305abb5715e3d667406b4277. Source frozen patch SHA25674b97562a6f6501ff2d9e475a51e2fc1b9eac61c2791ba1251acc3173cdc17fd; all12source/test hashes and tracked tree preserved throughout review. No tracked source/index/HEAD mutations. Only an explicitly authorized ignored scratch reproduction was written.

## Independent verdict

Not ready to integrate. One Important/P2 finding remains. No other established finding. The reviewer inspected the W4c plans/rulings, actual boundary repositories/providers, reader lifecycle/handoff, bookmarks compound retries, routes, family presentation and evidence. Audit1's seven accepted corrections are present; the new finding concerns queued position Retry ordering.

## Important/P2: queued old position Retry overwrites a newer save

Candidate lesson_page.dart789-798 validates activation in the queued write, while991-1001 checks the retained failed-position tuple only when Retry is tapped. A valid-looking old Retry may queue behind a newer in-flight save. When the newer save succeeds, the old queued Retry still writes its older offset, regressing persisted reading progress.

Independent real-path reproduction, relay11118:

```text
REPRO latest measured=360.0 saved=240.0 writes=[0.0, 360.0, 240.0]
Expected: <360>
Actual: <240.0>
00:01 +0 -1: Some tests failed.
TEST_EXIT 1
TRACKED_STATUS (empty)
```

The fixture first produces a failed offset240, holds the real360 preference write inside the existing guarded transaction, taps the still-visible Retry, then releases360. The saved240 result is an assertion failure, not a setup/import failure. Relay wrapper exits0 because it captures and prints the actual test exit1; no passing test is inferred from the wrapper.

Fixture: `.dart_tool/w4c-reaudit/position_retry_test.dart`, SHA256f60df32efc9c0c57c1f72329fca31951f6fcd8ab2b6a102096b1c3c217d1ffc6.
Log: `.dart_tool/w4c-reaudit/position_retry.log`, SHA256af49d920bf339c7d0103dfa87f047d2b229d07f62f82ad00babb050821ae0e4d.
Root opened source and actual failure, accepted Important/P2, and recorded the narrow correction in current-main L3 at2b1c7bb9 before implementation resumed.

## Existing verification inspected

Applicable to f93743f4 only, not any later source correction:

```text
flutter test --no-pub --reporter expanded --concurrency=1
08:28 +4221: All tests passed!
flutter analyze --no-pub
No issues found! (ran in 3.6s)
dart format --output=none --set-exit-if-changed lib test tool
Formatted 1462 files (0 changed) in 1.45 seconds.
check_layering: OK
check_no_ai_attribution: OK
git diff --check: empty
```

Root independently verified the committed source matches the frozen patch, all12source/test hashes and all6gate-log receipts. Full test log SHA25632a3ac29adda56e3f905485966928e5096fbfc2983f22baac07fc20b209fcc84. No unchanged full-suite rerun was requested simply because the reviewer changed.

## Declined to judge and lead dispositions

- Phone visual acceptance: remains Aedwon's separate required stage; no autonomous screenshots or visual acceptance.
- Live PWA/C7/server integration: not established by native engineering checks; remains the separate coordinated staging/integration stage.
- Release/deployment: no release or publication approval inferred.
- Unrelated families: outside this W4c review; their existing assignments and checkpoints remain.
- Accepted neighboring bookmark motion and exact Contents fade: explicit user exceptions remain binding; no broader visual waiver.

## Correction and closeout boundary

The same implementor resumes only after the reviewer stopped all operations. Ownership is the existing lesson page, its existing tests and W4c evidence. Retain original position intent through the queue and validate supersession inside the guarded transaction, preserving ordinary Retry, newer failure state, latest measured fraction, outgoing/disposal saves and reset/account/exam guards. No new queue/framework/schema/core/sync/wiper change. Port the independent regression into normal tests, prove RED-to-GREEN and affected cases, then run clean static gates and a full serial suite on the new frozen source. Root personally reviews the exact correction and evidence before closing the finding and uploading/integrating. No routine repeat whole-family audit is needed to confirm covering tests. Until that closure, source remains local and integration stays5e6cda45.
