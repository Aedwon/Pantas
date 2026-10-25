# W4f run 2 payments evidence, October 25, 2026

Candidate: `web/paymongo-r1` at `b0946994073bd136121d0274e93f7386d544fd03` plus the uncommitted diff. Policy: client cached `origin/main` at `0176ea1e4f8a35f00cbe9f4f491cc2dcc665bd0e`. No fetch, commit, push, deploy, dependencies, or schema change.

## Assigned work

Item 6: `listWebPlans` returns `trialEligible` from the same purchase-history predicate that `startWebTrial` enforces. It reads the trial marker, all grants and passes, and the stored subscription/purchase facts. Anonymous accounts are ineligible. Creation rechecks in its transaction.

The gateway enables the Monthly trial only for literal `trialEligible: true`. Other plans and missing, false, or malformed values stay ineligible.

Item 7 gateway: `grantHistory()` reads the owner-readable ledger without an active-only filter. It returns recognized active or revoked products and valid trial entries, with real integer end timestamps, newest first. Expired rows remain history without granting access. Signed-out reads and reads completed after identity changes return no rows. Native sources are unchanged. The client lead owns screen wiring and final acceptance.

## Failing-first observations

- Lead ran gateway tests before implementation: `grantHistory` did not exist. The inherited test also had `Plan.free`; corrected to `EntitlementPlan.free`.
- Lead isolated the offering test before its implementation: expected `[monthly]`, actual `[]` (`/tmp/w4f-eligible-red.log`).
- Server emulator with the inherited eligibility output temporarily disabled: 10 tests, 9 pass, 1 fail. The new eligibility test failed for `fresh`: `false !== true`. Restored the exact inherited implementation before further checks (`/tmp/w4f-payments-server-red.log`).

## Verification

`npx tsc --noEmit`: exit 0, no output.

`PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test`: plain tests completed:

```text
ℹ tests 118
ℹ pass 118
ℹ fail 0
```

The default emulator startup then failed because port 8080 was occupied. Retried with isolated Firestore 18080, Auth 19099, Storage 19199, hub 14400, logging 14500.

The first isolated run identified the existing plans limiter test's synthetic auth missing `token`. Updated it to the real named-account shape. The next parallel run had 143 pass and 1 fail in the unrelated global pass-recompute test at `paymongo-webhook.emulator.mjs:299` (`changed >= 1`). Its ledger sweep shares emulator data with concurrent tests. No production or assertion change was made for that failure.

Serial isolated emulator command:

```sh
NO_UPDATE_NOTIFIER=1 XDG_CONFIG_HOME=/tmp/w4f-payments-firebase-config PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npx firebase emulators:exec --config ../firebase.w4f-test.json --only auth,firestore,storage --project demo-pantas-test 'node --test --test-concurrency=1 test/*.rules.mjs test/*.emulator.mjs'
```

A serial run completed 144 pass / 0 fail. Its wrapper then reported the read-only global update-config error. The final command above uses a task-local config and disables update notices; final wrapper result is recorded below.

`dart format --output=none --set-exit-if-changed` for the changed gateway and its test: `Formatted 2 files (0 changed)`. `git diff --check`: exit 0. Flutter tests and analyzer are serialized by the client lead and remain their verification responsibility.

No open product decision in this assignment. Real PayMongo checkout, deployed App Check, and browser acceptance remain outside this local task.

Final isolated serial emulator wrapper: exit 0.

```text
ℹ tests 144
ℹ pass 144
ℹ fail 0
✔  Script exited successfully (code 0)
```

Final production/test dirty diff SHA-256 (git diff restricted to functions/src, functions/test, gateway and gateway test): `a67f407415cb08cecf5347a7815de04f158dc637e284b8b73944e4faaf61b955`.

Temporary emulator config was removed after verification. Logs: `/tmp/w4f-payments-server-red.log`, `/tmp/w4f-payments-server-green.log`, `/tmp/w4f-payments-emulator-green.log`, `/tmp/w4f-payments-emulator-serial.log`, `/tmp/w4f-payments-emulator-final.log`.

## Item 5 renewal discovery limitation

The authoritative stored `RevenueCatAccessSource` includes `productId`, `entitlementIds`, `appId`, `environment`, `store`, `endsAt`, and `active`. It has no renewal or cancellation field. `readRevenueCatCustomer` maps only those fields from RevenueCat subscription responses. A current `play_store` row establishes current access, but cannot distinguish a renewing subscription from a canceled subscription that retains access through its paid end date. No `googlePlayPlanRenews` value was invented or added. A truthful web warning contract needs a separately authorized ingestion change that retains a verified RevenueCat renewal field and its tests, including treatment of existing records without that field. Native entitlement behavior remains unchanged.

## Item 5 authorized renewal contract extension

The lead authorized the necessary backward-compatible ingestion extension after the limitation above. Checked RevenueCat's primary [v2 subscription data model](https://www.revenuecat.com/docs/api-v2/subscription-data-model) on October 25. Its `auto_renewal_status` identifies explicit automatic renewal and explicit cancellation. The server retains optional `willRenew`: true for `will_renew`, false for `will_not_renew`, absent for other or missing statuses. Unknown historical facts remain unknown. Existing webhook/customer refresh paths populate the field on their next authoritative read. No backfill or deploy was performed.

`listWebPlans.googlePlayPlanRenews` is true only for an active, unexpired production `play_store` source with explicit `willRenew: true`, the configured app ID, a product ID, and the Pro entitlement. Canceled, expired, inactive, sandbox, other-store, other-app, and unknown rows return false. This discovery flag does not alter entitlement or coverage computation.

The gateway exposes `googlePlayPlanRenews`, accepts only literal true, and clears it on identity changes. Offering replies and history reads are guarded by an identity revision, so logout followed by login to the same account cannot publish a stale reply.

Failing-first:

- Ingestion test failed `will_renew`: expected true, actual undefined (`/tmp/w4f-renewal-ingest-red.log`).
- Listing emulator test failed `renewing`: expected true, actual undefined (`/tmp/w4f-renewal-list-red.log`).
- Lead ran gateway test before getter implementation; compilation identified the absent getter (`/tmp/w4f-renewal-red.log`).

Final server checks after this extension:

```text
npx tsc --noEmit: exit 0
Plain tests: 119 pass, 0 fail
Isolated serial emulator: 145 pass, 0 fail
Script exited successfully (code 0)
```

Commands: `npx tsc --noEmit`, `npm run build`, `node --test test/*.test.mjs`, and the isolated serial emulator command above. Logs: `/tmp/w4f-payments-renewal-plain.log`, `/tmp/w4f-payments-renewal-emulator.log`. Temporary emulator config removed after checks. Flutter checks and final gateway lint synchronization belong to the lead.

Production/test diff SHA-256 before lead lint synchronization: `53b92620714bb1557512cdca870f70c6d55a59a1d27f5d9623e0955be9a29ad2`.

## Final literal npm runner and synchronized gateway

The client lead copied the final lint-clean gateway and gateway tests back into this tree. Production/test diff SHA-256 after synchronization: `88b1e078315fe9b9121240f35ed2df60060de1d1bafcc4def1872210153215ea`.

For the final literal `npm test`, the emulator port settings and only the emulator Node runner's `--test-concurrency=1` were applied temporarily to the existing configs. The original package and Firebase config bytes were saved before running and restored afterward. This is execution-only serialization for the known shared-ledger sweep contention. No persistent package/dependency change is part of the candidate.

Command: `NO_UPDATE_NOTIFIER=1 XDG_CONFIG_HOME=/tmp/w4f-payments-firebase-config PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test` from `functions`. Log: `/tmp/w4f-payments-final-npmtest.log`.

The client cached origin/main later moved to `40b35bc4c6640aeec9234b3ed72cc37f8c510b1f` during this run. A read-only comparison of AGENTS.md, WORKFLOW.md, and SUBAGENTS.md against the original policy revision `0176ea1e4f8a35f00cbe9f4f491cc2dcc665bd0e` produced no diff. This worker did not fetch or pull.

Final literal npm result: exit 0.

```text
ℹ tests 119
ℹ pass 119
ℹ fail 0
ℹ tests 145
ℹ pass 145
ℹ fail 0
✔  Script exited successfully (code 0)
```

Byte comparisons confirmed the original package.json and firebase.json were restored exactly. Final `git diff --check`: exit 0.

### Lead Flutter and parity verification

Client full suite on the identical gateway source:
```text
flutter test --reporter expanded
08:58 +4921: All tests passed!
flutter analyze lib test tool
No issues found! (ran in 10.2s)
```
Gateway files compare byte-identical. Final client source/test manifest SHA-256:
`f7880c9b8424420daf5ab6e9f34ead7470732c1129a109feb2ba8e59c0b0573d`.
No source changed during the full run. All work remains uncommitted.

Final payments status:
```text
git status --short
 M functions/src/revenuecatPolicy.ts
 M functions/src/revenuecatSubscriber.ts
 M functions/src/webPlans.ts
 M functions/src/webTrial.ts
 M functions/test/revenuecat-subscriber.test.mjs
 M functions/test/web-plans.emulator.mjs
 M functions/test/web-plans.test.mjs
 M functions/test/web-trial.emulator.mjs
 M lib/features/paywall/data/web_payment_gateway.dart
 M test/features/paywall/data/web_payment_gateway_test.dart
?? docs/superpowers/plans/pwa-launch/evidence/
```


## October 25 audit fixes, items 16 and 17

Candidate: `web/paymongo-r1`, HEAD `8e5fac5d17ac0eb99a6ddbd5f919ce0035c8cc2e`, plus this uncommitted audit patch. Worktree was clean before edits. Policy retrieved from local `origin/main` with `git show`: `73572280cf4d9478d56e42247be04dad8ad1acd9`. No fetch, pull, commit, push, deploy, dependency change, or history rewrite.

Item 16: if either the renewal read or eligibility read fails, `listPlans` keeps all available plans, returns `trialEligible: false`, omits `googlePlayPlanRenews`, and records the error with the existing server `console.error` pattern. Authentication and rate-limit failures retain their existing refusal behavior.

Failing-first evidence: both new behavior cases failed on the original implementation with the injected eligibility/renewal errors (7 pass, 2 fail). The absence assertions also failed against an intermediate false-valued renewal flag (7 pass, 2 fail). Final focused runner: 9 pass, 0 fail. Logs: `/tmp/w4f-payments-audit-red.log`, `/tmp/w4f-payments-audit-flag-red.log`, `/tmp/w4f-payments-audit-green.log`.

Item 17: commit `8e5fac5d` already includes the optional authoritative renewal ingestion and `googlePlayPlanRenews` discovery contract described above. This audit leaves those changes and commit history intact. No ingestion or gateway source was changed by this assignment.

`npx tsc --noEmit`: exit 0, no output (`/tmp/w4f-payments-audit-tsc.log`).

The first full npm run passed 121 plain tests, then its storage emulator crashed with ENOENT under the shared temporary storage directory. The next attempt found the crashed run's Firestore listener on 28080. The sandbox rejected stopping that listener. Retried using isolated temporary storage and different ports; no production/test assertion was changed for these execution failures.

Final command from `functions`:

```sh
TMPDIR=/tmp/w4f-payments-audit-emulator NO_UPDATE_NOTIFIER=1 XDG_CONFIG_HOME=/tmp/w4f-payments-audit-firebase-config PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test
```

The final run temporarily uses Auth 39099, Firestore 38080, Storage 39199, hub 34400, logging 34500, websocket 39152, disabled emulator UI, and a serial emulator test runner. Original Firebase and npm config bytes are preserved and restored afterward. No package change is part of the candidate. Log: `/tmp/w4f-payments-audit-npmtest-final.log`.


Final literal npm wrapper: exit 0. Actual summaries:

```text
ℹ tests 121
ℹ pass 121
ℹ fail 0
ℹ tests 145
ℹ pass 145
ℹ fail 0
✔  Script exited successfully (code 0)
```

The original `firebase.json` and `functions/package.json` bytes were restored and compared exactly. `git diff --check`: exit 0. Final production/test dirty diff SHA-256 (`git diff -- functions/src functions/test | shasum -a 256`): `e6c8dc36c5f4bad7a77cefe53bba7fd83fab85f89c0509b2d7ba71ba2bbbe69d`.

```text
git status --short
 M docs/superpowers/plans/pwa-launch/evidence/W4f-payments.md
 M functions/src/webPlans.ts
 M functions/test/web-plans.test.mjs
```

No open product decisions in items 16 or 17. Real PayMongo checkout/deployed behavior and visual acceptance remain unverified. The client lead owns gateway parity and combined review. All changes remain uncommitted.


### Audit lead review

The lead inspected the final plans fallback and both injected-read regression cases.
Independent read-only review found no issue in the final fallback. Original HEAD and cached
matching remote branch SHA remain `8e5fac5d17ac0eb99a6ddbd5f919ce0035c8cc2e`.
Gateway source remains byte-identical to CLIENT. All changes remain uncommitted.
