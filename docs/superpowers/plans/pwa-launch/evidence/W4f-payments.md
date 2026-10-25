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


## W4f second fix round, October 25, 2026

Policy: cached origin/main `73572280cf4d9478d56e42247be04dad8ad1acd9`, read with
`git show` in CLIENT. PAYMENTS base `22c25edf`. No fetch/pull, commit, staging,
push, deployment, hosting change, or dependency addition.

Item 7: separate renewal and trial eligibility catches. Each failure records its
own error and preserves the other read's successful value. RED: 10 tests,
7 pass, 3 fail. Actual mismatches: renewal `undefined` versus `true`, trial
eligibility `false` versus `true`, error count `1` versus `2`. GREEN: 10 pass,
0 fail. Logs `/tmp/w4f-r2-plans-{red,green}.log`.

The shared web gateway now permits a callback before opening checkout, so CLIENT
can save the returned session ID before navigation. Gateway identity is checked
across creation and the callback. Both assigned gateway copies are byte-identical.
Actual server returns contain no session correlation. CLIENT refuses an exam
switch without matching session ID and explicit target. A proposed return-token
contract remains a question to the lead. No checkout-server contract was invented.

Verification, actual output:
```text
npx tsc --noEmit: exit 0
PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test
ℹ tests 122
ℹ pass 122
ℹ fail 0
ℹ tests 145
ℹ pass 145
ℹ fail 0
✔  Script exited successfully (code 0)
```

For this literal npm test, temporary execution settings used Auth 49099,
Firestore 48080, Storage 49199, hub 44400, logging 44500, websocket 49152,
and disabled UI. The emulator Node runner used `--test-concurrency=1` because
existing global ledger sweeps share data. TMPDIR was
`/tmp/w4f-r2-payments-emulator`; XDG_CONFIG_HOME was
`/tmp/w4f-r2-firebase-config`; NO_UPDATE_NOTIFIER=1. Original Firebase and npm
configuration bytes were restored in `finally`. No assertions or production
behavior were changed for execution. Default Node v26.10.0 and OpenJDK 21.
Full log `/tmp/w4f-r2-payments-npmtest.log`. No live payment or deployment tested.

Final functions/gateway diff SHA-256: `a5a2cac38ae0847aa2765ae306c7a81eb4d314739f8d3dfba3bf3634a2628737`.
Gateway byte comparison and `git diff --check`: exit 0.
Final `git status --short`:
```text
 M docs/superpowers/plans/pwa-launch/evidence/W4f-payments.md
 M functions/src/webPlans.ts
 M functions/test/web-plans.test.mjs
 M lib/features/paywall/data/web_payment_gateway.dart
```


## W4f third fix round, October 25, 2026

Policy read with `git show origin/main:<file>`: AGENTS.md, WORKFLOW.md,
SUBAGENTS.md, revision `73572280cf4d9478d56e42247be04dad8ad1acd9`.
CLIENT base `b866082572c4ae12737680b04fc6d5e5b1d5a1a4`.
PAYMENTS base `3ae9c61ef2a2a9ec837d8c82219739249326386e`.
Both assigned worktrees were clean at preflight. No fetch, pull, staging,
commit, push, deployment, dependency addition, or other worktree access.
The lead brief resolves the two prior-round contract questions. Exact rulings:

1. Session-bound return: createPaymongoCheckout (PAYMENTS paymongoCheckout.ts) already generates a
   referenceNumber before creating the session. Put it in both return URLs as `&ref=<referenceNumber>`
   (`/pro?checkout=success&ref=...`, `/pro?checkout=cancelled&ref=...`) and return it to the client as
   `reference` alongside checkoutUrl and sessionId. The webhook and grant logic stay unchanged. The client
   stores the reference in the pending switch and applies the switch only when the return's `ref` matches
   (plus the existing account, expiry and coverage checks). A return without a matching ref clears nothing
   but applies nothing. Emulator/unit tests first on the server; client tests for match, mismatch, missing.
   Keep the /pro redirect preserving every query parameter.
2. No trial on the upgrade (target-exam) path: the approved rule says the upgrade screen offers no trial.
   Hide the trial on the target-exam path, remove the trial-with-target code path, and make sure no
   pending switch is written for trials. The plain Pro page keeps the trial per trialEligible.

### Implementation and failing-first evidence

1. Done. Checkout generates one reference and uses it in both return URLs,
   the PayMongo referenceNumber, and the callable response. The gateway supplies
   session ID and reference to the callback before opening checkout. Pending
   switches retain both. Only a nonempty matching return ref consumes the switch.
   Missing/mismatched refs leave the pending value and selected exam unchanged,
   including cancellation. Matching returns still require resolved same-account
   identity, valid stored target/tier, unchanged source exam, age 0–24 hours,
   successful confirmed entitlement and matching coverage. Ordinary /pro returns
   recover the target from the stored exam ID and actual catalog. Unknown targets
   do not apply. The redirect retains every query parameter, including duplicate
   parameters. The return tests use the actual ref-only contract for success;
   mismatch/missing cases also supply the old session_id to prove it cannot bypass
   the new reference check. No webhook or grant logic changed.
2. Done. Upgrade already hid the trial. Its handler now explicitly excludes
   target-exam trials. Pending-switch preparation lives only in the paid checkout
   branch. An eligible target-exam package opens paid checkout without trial copy
   or a trial call. Plain Pro still honors trialEligible. Its trial regression
   records every nonempty pending-switch write and observes none.

Observed RED, before reference implementation:
- Server unit: 1 test, 0 pass, 1 fail. Expected the generated reference; actual
  response.reference was undefined. `/tmp/w4f-r3-server-red.log`.
- Server emulator focused checkout: 1 test, 0 pass, 1 fail. Response lacked
  reference. `/tmp/w4f-r3-emulator-red.log`.
- Client pending returns: `00:01 +8 -7: Some tests failed.` Missing/mismatched
  references consumed the pending value. Matching reference returns did not apply
  the switch. Ordinary /pro did not recover the target. Malformed data was cleared
  without a matching reference. `build/w4f-r3/pending-red.log`.
- Client upgrade persistence: three scenarios failed because the stored reference
  was null. `build/w4f-r3/client-red.log`. That invocation also had an undefined
  test-provider import. The import error is not counted as behavioral RED; the
  later pending-red invocation compiled and observed the failures above.
- Trial assertions were already green before the handler cleanup. No failing
  trial reproduction is claimed. The pre-cleanup focused run passed 34 tests.
  `build/w4f-r3/trial-before-cleanup.log`.

### Final verification

```text
CLIENT
flutter test test/features/settings test/features/paywall test/app --reporter expanded
00:32 +687: All tests passed!
flutter analyze lib test tool
No issues found! (ran in 3.2s)
dart format --output=none --set-exit-if-changed lib test tool
Formatted 1595 files (0 changed) in 3.13 seconds.
dart run tool/check_layering.dart
check_layering: OK
dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
PAYMENTS (from functions)
npx tsc --noEmit
exit 0, no output
PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test
ℹ tests 123
ℹ pass 123
ℹ fail 0
ℹ tests 145
ℹ pass 145
ℹ fail 0
✔  Script exited successfully (code 0)
```

The npm runner used isolated Auth 59099, Firestore 58080, Storage 59199,
hub 54400, logging 54500, websocket 59152, and disabled UI. Its emulator
Node runner used --test-concurrency=1 for existing shared global ledger sweeps.
TMPDIR=/tmp/w4f-r3-emulator, XDG_CONFIG_HOME=/tmp/w4f-r3-firebase-config,
NO_UPDATE_NOTIFIER=1. The exact firebase.json and functions/package.json
bytes were saved and restored in finally. No persistent execution config changes.
Full npm log: /tmp/w4f-r3-payments-npmtest.log. TypeScript log:
/tmp/w4f-r3-tsc.log. Client logs: build/w4f-r3/. Initial analyzer found five
style/import issues; corrected before the clean result. Final source tests reran
after the corrections. Gateway byte comparison and both diff whitespace checks
exited zero.

Source identity (SHA-256 by file, including the untracked unit test):
```text
4825924a8dc398cbcddb1864ebfe921593560e2dd6231364acf51a2851fcf0c2  lib/features/paywall/data/web_payment_gateway.dart
0b4c7c7236fdd2b13a4974b48373176cbbaae29643186c31c07f91796dc7a362  lib/features/settings/presentation/pages/pro_page.dart
b0882dcb149f2d911dd0cf0d677dc2f1244f295bd5338e48ef6b17af5746b8b7  test/features/settings/presentation/w4f_checkout_return_test.dart
e81e9a5fdfd5aab9a9d388076a09a988313249a29942c0ebb6d74d8bd5ce1a8c  test/features/settings/presentation/w4f_pending_exam_test.dart
8ec5a764d709a3e765ec8ba3ecfd355785cf6e294db05c2a3628e7d0d8698b44  test/features/settings/presentation/w4f_pro_states_test.dart
a33deedf24de72b93c888578ce7dfa7f1bf963818488a2d2058d7663ab26c266  test/features/settings/presentation/w4f_upgrade_checkout_test.dart
fbc1a3805476d9f9e44d06aeeee39342e8aac9c0f4183ac87fa8db29792a0d15  functions/src/paymongoCheckout.ts
7ea310be1ed8a58f340f375f77cf551537a6e3031e0fbd0f8fc6b18299d23a2d  functions/test/paymongo-checkout.test.mjs
2b1aa5dd8a1869c388071110757b9e1e4ce08f5ce421bfe1f9113322ee2f735d  functions/test/web-trial.emulator.mjs
4825924a8dc398cbcddb1864ebfe921593560e2dd6231364acf51a2851fcf0c2  lib/features/paywall/data/web_payment_gateway.dart
```

Files outside the W4f presentation table are the shared gateway in both trees
and PAYMENTS checkout source/unit/emulator tests. The lead brief explicitly
requires them. No other payment behavior or native purchase contract changed.
Independent read-only source review found no functional issues. It made no edits
and reused the recorded suite output. Final evidence review is recorded below.
Live PayMongo checkout, deployed App Check/hosting return URLs, phone visuals,
integration and deployment were not verified or performed. These two bounded
items are implemented and locally tested. Overall W4f acceptance remains with
the lead. All unrelated prior-round open items remain unchanged.

CLIENT git status --short:
```text
 M docs/superpowers/plans/new-design/evidence/W4f.md
 M lib/features/paywall/data/web_payment_gateway.dart
 M lib/features/settings/presentation/pages/pro_page.dart
 M test/features/settings/presentation/w4f_checkout_return_test.dart
 M test/features/settings/presentation/w4f_pending_exam_test.dart
 M test/features/settings/presentation/w4f_pro_states_test.dart
 M test/features/settings/presentation/w4f_upgrade_checkout_test.dart
```
PAYMENTS git status --short:
```text
 M docs/superpowers/plans/pwa-launch/evidence/W4f-payments.md
 M functions/src/paymongoCheckout.ts
 M functions/test/web-trial.emulator.mjs
 M lib/features/paywall/data/web_payment_gateway.dart
?? functions/test/paymongo-checkout.test.mjs
```

Final independent evidence review: no findings. Reviewer checked both addenda,
final logs, source manifests and whitespace checks. Every listed SHA-256 matched.
No review edits or repeated suites. Local implementation and verification complete;
no live checkout, visual acceptance, integration or publication claimed.
