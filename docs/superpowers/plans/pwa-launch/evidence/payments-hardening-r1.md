# Payments hardening r1 evidence

## Assignment and source identity

- Original assignment: findings 3 through 7. October 27 follow-up: finding 8, won-dispute restoration, authorized by the lead brief and Aedwon’s stated decision.
- Repository: Aedwon/Pantas. Assigned worktree: `/Users/aedwon/Documents/Projects/Pantas-wt-payments-hardening-r1`.
- Branch: `web/payments-hardening-r1`. Starting HEAD: `417078bf8015e50b6b78b0e5026204d680534aaf`.
- Policy read with `git show origin/main:<path>`: AGENTS.md, WORKFLOW.md, SUBAGENTS.md at `64e5757674ccca9eb42e1b63d22df84f788de470`.
- Controlling records read from the same origin/main: C1-C10-ruling.md, docs/pricing.md, and the full 2026-10-19-pwa-launch-log.md.
- The original run recorded a clean initial worktree. On resumption, the uncommitted implementation and this evidence file were present and preserved. Branch, HEAD, remote URL, and policy revision matched the assignment. No fetch or pull was performed, per the explicit brief.
- No commit, push, merge, deployment, dependency change, or other-worktree edit. The lead owns review, acceptance, and commits.

## Result by finding

### 3: trial reuse after deletion

- Trial eligibility and creation use the same external `trialUsedIdentities` collection.
- Keys are HMAC-SHA256 of structured provider-id/provider-uid or lowercased verified email. Inputs come only from Firebase-verified Auth token claims, never callable data.
- Each record contains exactly `{used: true}`. No raw provider id, provider uid, email, account uid, timestamp, or account link is retained in the marker.
- Creation checks and writes these markers in the grant transaction. Deletion preserves them and removes account-linked payment bindings and follow-ups.
- Missing signing identity or secret fails closed. Anonymous accounts remain ineligible.
- New Functions secret param: `TRIAL_IDENTITY_HMAC_KEY`, using the existing `defineSecret` pattern. Trial creation, the plan-list callable, and account deletion bind it.
- Before deployment, the lead must provision a strong, stable secret in each target project. No production secret was read or created here. Rotating or deleting this key without a marker migration would reset the protection.
- Deleting an account with an older account-local web trial first saves its identity markers. Accounts already deleted before rollout cannot be reconstructed. No raw identifiers are added to recover deleted history.
- Product follow-up: the privacy policy needs one line explaining this minimal marker and its survival after account deletion. Aedwon decides the wording. No public legal copy was changed.

### 4: purchased sitting, paid time, and recovery

- An order with account, product, creation time, and purchased sitting is committed before contacting PayMongo. The order reference is sent in server-controlled checkout metadata.
- The response records the session binding. If the provider response is lost, the verified session metadata can still recover the prewritten order.
- Webhook granting re-reads PayMongo and checks the saved account/product/session binding and authoritative `paid_at`. It never derives a pass sitting from webhook processing time.
- Grants persist the purchased sitting, exam id, and authoritative payment time. Prepaid time is based on the payment time and existing coverage, not delivery delay.
- Unfulfilled paid events create pending follow-up records and return 500 without writing a handled-event record. Missing sitting/binding/time remains repairable by a retry after the binding is corrected.
- Retry success resolves applicable follow-up records.
- PayMongo's Checkout Session Resource shows `paid_at` on the payment in Unix seconds: https://docs.paymongo.com/reference/checkout-session-resource . The HTTP client converts it to milliseconds.

### 5: duplicate purchases

- A transactional reservation prevents concurrent creation of more than one checkout for an account/product/sitting. An open, unpaid provider checkout is reused, including its original return reference.
- The provider is re-read before reuse. Paid or expired sessions can be replaced with a compare-and-swap reservation.
- Monthly and Yearly payments queue prepaid periods. They do not create refund flags.
- A second pass that adds no coverage creates a revoked, zero-coverage grant linked to the first pass and a pending `unusedDuplicatePass` follow-up with `refundRequired: true`. The first pass remains active.
- No refund API call was added. The lead/merchant handles the unused payment.
- If checkout creation has an uncertain outcome, its reservation stays blocked for reconciliation. It is not automatically timed out into a second charge. A lost-response payment can still grant from its saved order; clearing an unresolved reservation remains an operator step.

### 6: combined coverage

- The server derives native subscription rows with the same app, environment, product, and entitlement checks used by RevenueCat claim coverage. It also includes native passes and web grants.
- Web prepaid periods extend after coverage at the same or a higher tier. Refund replanning preserves native coverage instead of pulling a queued grant over it.
- A new owner-bound `getWebEntitlement` callable exposes only normalized coverage rows, not RevenueCat facts or provider identifiers. The requested account must match the verified caller.
- The real web grant reader uses that combined server reply. Native subscribers and pass owners are therefore represented alongside web grants.
- Dart excludes future isolated grants and gaps. A connected prepaid chain can extend current coverage. Coverage uses actual end dates without the Auth claim's repair allowance.
- The previous pure test asserting that a pass must not delay a later subscription was updated to the current brief's explicit combined-coverage requirement. Pass purchases themselves still do not stack on subscriptions.

### 7: postponement

- The existing admin recomputation scans both native passes and web grants.
- Web passes keep their saved exam and sitting. A first-day change still requires the existing explicit admin move mapping.
- Recalculation only extends the matched sitting, recomputes entitlement, and copies claims. It does not select the next future sitting or revive revoked duplicate grants.
- A partially refunded web pass keeps its refunded proportion when the full sitting end changes.

## Test-first evidence

Actual red runs were captured before the corresponding fixes:

- `/private/tmp/payments-red3.log`: deletion/recreation eligibility returned true instead of false.
- `/private/tmp/payments-red45.log`: delayed pass chose the August sitting, unbound pass returned granted instead of noSitting, duplicate pass returned granted, and a second checkout returned another session/reference. The Monthly/Yearly stacking check already passed.
- `/private/tmp/payments-red67.log`: web Monthly started at payment time instead of the Play end; postponement kept the old sitting.
- `/private/tmp/payments-dart-red.log`: future grant reported active; a gap extended the displayed end. Both failed with actual behavior assertions after generating missing local code.
- `/private/tmp/payments-refund-red.log`: refund replanning moved a queued grant before native coverage ended.
- `/private/tmp/payments-extra-red.log`: the lost-response order was absent. A partial-refund test also failed; its first version reused the paid event id for the refund, so that initial failure was a test-fixture error, not valid red evidence. The corrected test uses a separate refund event and passes.
- `/private/tmp/payments-final-red.log`: real deletion retained the new payment bindings; metadata/amount/product refusals acknowledged unfulfilled paid events with 200.
- `/private/tmp/payments-edges-red.log`: a delayed duplicate after postponement was granted; a successful retry left a session-level follow-up pending.
- `/private/tmp/payments-owner-red.log`: the combined callable accepted a stale requested account.
- `/private/tmp/payments-time-red.log`: second-precision paid_at in the checkout creation second incorrectly returned 500.

## Verification environment and setup

- `functions/node_modules` was absent. Ran `cd functions && npm ci` before server checks. No manifest or lockfile change.
- npm reported Node v26.10.0 against the repository's Node 22 engine, and 19 installed-tree audit advisories (6 moderate, 13 high). No dependency upgrades were made.
- Java 21: `/opt/homebrew/opt/openjdk@21/bin`.
- Isolated emulator ports: Auth 29096, Firestore 28086, Storage 29196, hub 24406, logging 24506; UI disabled. Temporary firebase.json port edits are restored before handoff.
- Tests use a local dummy `TRIAL_IDENTITY_HMAC_KEY`. No live PayMongo or production Firebase API was called.
- `CI=true` and `XDG_CONFIG_HOME=/private/tmp/payments-firebase-config` avoid the CLI update check writing outside allowed paths. An earlier run's 195 plain and 256 emulator tests passed, but its CLI wrapper exited nonzero on an update-config permission error. It is not the final passing command.
- The fresh worktree lacked ignored database/generated model files and translations. Generated them with `dart run build_runner build --delete-conflicting-outputs` and `flutter gen-l10n`. No generated file is included in the patch. No pinned content package was rebuilt.
- Intermediate focused reruns initially encountered stale event/payment records in this isolated emulator. Clearing only this emulator database removed that test setup interference; full emulator invocations start empty.
- Full Flutter verification was restarted after generating translations and after the final account-binding adjustment. Interrupted runs are not counted as final passes.

## Resumption corrections and additional red evidence

- Refreshed the three policy files and controlling records from the same cached origin/main. No fetch or pull. Reviewed the dirty source and test diff before changing it.
- The old Firestore emulator still occupied port 18086. Left it untouched and selected the new isolated ports above. Process listing is sandbox-restricted; `lsof` confirmed the port owner.
- `/private/tmp/payments-resume-server2.log` reproduced the remaining web-pass refund regression: expected the queued grant to start at `1817740799999`, actual `1805040060000`. Replanning now includes an existing web pass when finding the coverage end. Passes themselves remain immovable.
- That run also exposed a missing local test secret. The test helper now sets an explicit dummy HMAC key. Production has no fallback key and still fails closed.
- `/private/tmp/payments-resume-provider-red.log` reproduced a paid event whose provider reread throws: response 500 and no handled marker were correct, but follow-up status was `undefined`, expected `pending`. The catch path now writes a pending session follow-up, resolved through the existing successful-retry path.
- `/private/tmp/payments-resume-rate-red.log` reproduced a rate-limited paid event with no follow-up: status was `undefined`, expected `pending`. The handler now records `rateLimited` while keeping response 429 and leaving the event unhandled.
- `/private/tmp/payments-resume-server-final2.log` reproduced deletion/recreation of an older account-local trial: eligibility returned true, expected false. Deletion now saves the keyed identity markers before removing that local record. This also requires the trial secret on the deletion callable.
- Historical red logs listed above were inspected on resumption. They are preserved test-first evidence from the original run, not newly repeated baseline executions.


### Preserved failing output

`/private/tmp/payments-red3.log`:

```text
✖ trial identity marker survives deletion and blocks provider or verified email reuse (3654.264333ms)
```

`/private/tmp/payments-red45.log`:

```text
✖ delayed pass delivery keeps the checkout sitting and PayMongo payment time (83.08075ms)
✖ unbound paid passes stay unhandled and recoverable (11.47375ms)
✖ duplicate pass adds no coverage and flags only the unused payment for refund (23.887209ms)
✖ checkout binds a sitting and reuses an open checkout for that account product and sitting (13.168292ms)
```

`/private/tmp/payments-red67.log`:

```text
✖ web prepaid starts after authoritative Play coverage (3103.886959ms)
✖ postponement recomputation extends the saved web sitting without reviving duplicates (26.432875ms)
```

`/private/tmp/payments-dart-red.log`:

```text
  Expected: false
    Actual: <true>
  Expected: DateTime:<2026-10-30 00:00:00.000Z>
    Actual: DateTime:<2026-11-30 00:00:00.000Z>
```

`/private/tmp/payments-resume-server2.log`:

```text
✖ trial identity marker survives deletion and blocks provider or verified email reuse (1.705333ms)
✖ real account deletion removes payment bindings but keeps only hashed trial markers (13.798209ms)
✖ refund replanning also preserves an existing web pass (37.756708ms)
```

`/private/tmp/payments-resume-provider-red.log`:

```text
✖ a failed provider reread leaves an unhandled paid event and a follow-up (317.42425ms)
```

## Final gate output

This record is not a release or independent-review acceptance. The lead must review, accept, commit, and update the locked project STATUS record. No live PayMongo purchase, deployed App Check, or real provider retry was verified.

`cd functions && npx tsc --noEmit && PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test`

The npm process also used `CI=true XDG_CONFIG_HOME=/private/tmp/payments-firebase-config` for sandbox-safe Firebase CLI configuration. The checked-in test fixture supplies the local dummy trial key. Temporary isolated ports were restored after the command.

TypeScript exited 0 with no diagnostics. Full npm command exit: 0. Actual summaries from `/private/tmp/payments-resume-server-final3.log`:

```text
ℹ tests 195
ℹ suites 0
ℹ pass 195
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0

ℹ tests 267
ℹ suites 0
ℹ pass 267
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
✔  Script exited successfully (code 0)
```

`flutter test test/features/paywall`, exit 0:

```text
00:48 +290: All tests passed!
```

`flutter analyze lib test tool`, exit 0:

```text
No issues found! (ran in 44.7s)
```

`dart format --output=none --set-exit-if-changed lib test tool`, exit 0:

```text
Formatted 1562 files (0 changed) in 7.62 seconds.
```

`dart run tool/check_layering.dart`, exit 0:

```text
check_layering: OK
```

`server_dart/build.sh --check`, exit 0:

```text
generated JS is current
```

`dart run tool/check_no_ai_attribution.dart`, exit 0:

```text
check_no_ai_attribution: OK
```

`flutter test`, exit 0, actual final summary from `/private/tmp/payments-resume-flutter.log`:

```text
11:23 +4880: All tests passed!
```

The roadmap property test was the last test to finish. No test was skipped or changed for runtime. The full run completed on the final source. Static gates above and final `git diff --check` all exited 0.

All requested findings (3 through 7) are implemented and verified locally. Finding 8 is covered by the October 27 follow-up below. No product question blocks this implementation. The privacy-policy sentence still needs Aedwon's wording. The lead owns independent review, acceptance, commits, integration, STATUS updates, secret provisioning, and later live test-mode verification.

## Candidate identity and files

HEAD remains `417078bf8015e50b6b78b0e5026204d680534aaf`. Dirty patch SHA-256: `87202d600f2352c1bf61edfce523d52bd87fe1c126ad26e3983331a9347a1915`. Digest input: `git diff --binary HEAD -- . :!docs/superpowers/plans/pwa-launch/evidence/payments-hardening-r1.md`, then sorted untracked files excluding this evidence, each as filename, NUL, bytes, NUL. No staged changes.

The assignment brief is the file-scope authority for this hardening pass. The checkout test moved from a plain test to the emulator because checkout now stores transactional bindings. The shared grant helper avoids a circular import during postponement. The new combined-coverage callable and its export serve the web gateway. No rules change or generated file is included.

```text
functions/src/_audit.ts
functions/src/deleteAccount.ts
functions/src/entitlementInputs.ts
functions/src/grants.ts
functions/src/index.ts
functions/src/paymongoCheckout.ts
functions/src/paymongoClient.ts
functions/src/paymongoGrants.ts
functions/src/paymongoWebhook.ts
functions/src/revenuecatPasses.ts
functions/src/webEntitlement.ts
functions/src/webPlans.ts
functions/src/webTrial.ts
functions/test/_paymongo-helpers.mjs
functions/test/payments-hardening.emulator.mjs
functions/test/paymongo-checkout.emulator.mjs
functions/test/paymongo-checkout.test.mjs
functions/test/paymongo-client.test.mjs
functions/test/paymongo-policy.test.mjs
functions/test/paymongo-webhook.emulator.mjs
functions/test/web-plans.emulator.mjs
functions/test/web-trial.emulator.mjs
lib/features/paywall/data/web_payment_gateway.dart
test/features/paywall/data/web_combined_coverage_test.dart
```

## Final working tree

`git status --short`:

```text
 M functions/src/_audit.ts
 M functions/src/deleteAccount.ts
 M functions/src/entitlementInputs.ts
 M functions/src/grants.ts
 M functions/src/index.ts
 M functions/src/paymongoCheckout.ts
 M functions/src/paymongoClient.ts
 M functions/src/paymongoGrants.ts
 M functions/src/paymongoWebhook.ts
 M functions/src/revenuecatPasses.ts
 M functions/src/webPlans.ts
 M functions/src/webTrial.ts
 M functions/test/_paymongo-helpers.mjs
 D functions/test/paymongo-checkout.test.mjs
 M functions/test/paymongo-client.test.mjs
 M functions/test/paymongo-policy.test.mjs
 M functions/test/paymongo-webhook.emulator.mjs
 M functions/test/web-plans.emulator.mjs
 M functions/test/web-trial.emulator.mjs
 M lib/features/paywall/data/web_payment_gateway.dart
?? docs/superpowers/plans/pwa-launch/evidence/payments-hardening-r1.md
?? functions/src/webEntitlement.ts
?? functions/test/payments-hardening.emulator.mjs
?? functions/test/paymongo-checkout.emulator.mjs
?? test/features/paywall/data/web_combined_coverage_test.dart
```


## October 27 follow-up: dispute wins (finding 8)

The lead brief supplies the bounded follow-up plan and Aedwon's decision: restore a won dispute unless the payment was refunded or the grant was revoked for another reason. Preserve the saved expiry. Keep retries idempotent. No new dependencies, deployment, commit, fetch, or pull. Previous uncommitted findings 3 through 7 remain in the tree.

Policy was reread through `git show origin/main:<file>` at `64e5757674ccca9eb42e1b63d22df84f788de470`. The PWA launch spec, implementation plan, C1/C10 ruling, payment integration notes, existing evidence, and supplied finding 8 were inspected. The explicit October 27 decision supersedes the integration notes' former decision gap.

Files changed for this follow-up:
- `functions/src/paymongoWebhook.ts`: dispatch resolved disputes after signature and mode checks; require payment identity, dispute identity, and a won/lost status; copy pending claims after the transaction.
- `functions/src/paymongoGrants.ts`: retain dispute identity on grants and early tombstones; transactionally restore only that dispute's revocation; preserve start/end dates; retain refunds received while revoked; preserve independent revocation reasons.
- `functions/src/grants.ts`: optional revocation/dispute metadata fields.
- `functions/test/paymongo-webhook.emulator.mjs`: won/lost, retries under the same and different event IDs, partial refund before/after dispute, full refund after dispute, independent revocation before/after dispute, wrong dispute identity, expired grant, and grant born revoked after an early dispute.
- `functions/PAYMONGO.md`: replace the obsolete ignored-win behavior and include resolved disputes in webhook subscriptions. This extra documentation file prevents the launch setup from omitting the newly handled event.
- This evidence file.

A won dispute restores only its original grant. Other grants already replanned after revocation keep their saved dates. Expired grants retain their original end and provide no current access. Any recorded refund, including a partial refund, prevents restoration. Partial refunds still shorten the saved period through the existing refund calculation. A lost resolution leaves the grant revoked.

Test-first output:

`/private/tmp/dispute-red.log` (fresh isolated emulators, before implementation):
```text
✖ dispute resolution: won
✖ dispute resolution: expired
actual: 'revoked'
expected: 'active'
```

`/private/tmp/dispute-early-red.log` (before retaining dispute identity on early tombstones):
```text
✖ a win restores a grant born revoked by an earlier dispute
actual: 'revoked'
expected: 'active'
```

Intermediate verification notes: a second emulator launch encountered occupied ports while the first run was active. It did not run tests. A later focused rerun against the same database hit retained payment/event indices after deleting user fixtures. Those fixture failures are not valid behavior regressions. The final full verification starts fresh emulators. No unrelated service was stopped. Final ports: Auth 29097, Firestore 28087, Storage 29197, hub 24407, logging 24507, UI disabled. The original firebase.json is restored afterward.

No live provider payload, deployment, or production claim propagation was verified. The lead retains independent review and acceptance. Records written before dispute identity tracking cannot be automatically matched for restoration; no historical grant migration is included.

### Follow-up final verification

`cd functions && npx tsc --noEmit && PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test`

Executed with `CI=true XDG_CONFIG_HOME=/private/tmp/payments-firebase-config` on npm for the local CLI configuration. TypeScript exited 0 with no diagnostics. Overall exit 0. Actual output from `/private/tmp/dispute-final.log`:

```text
ℹ tests 195
ℹ suites 0
ℹ pass 195
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0

ℹ tests 277
ℹ suites 0
ℹ pass 277
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
✔  Script exited successfully (code 0)
```

`dart run tool/check_no_ai_attribution.dart`, exit 0:
```text
check_no_ai_attribution: OK
```

`git diff --check`, exit 0, no output. Firebase emulator configuration restored byte-for-byte. No Flutter source changed in this follow-up; the earlier Flutter evidence above was not rerun. Independent review remains with the lead.

Follow-up dirty patch SHA-256: `b868cf69ec65ed8c170f6f5c1c46751056c3eef04d87d1b795c8f4a68b3c5581`. Same digest procedure as the original candidate section, excluding this evidence file. HEAD remains `417078bf8015e50b6b78b0e5026204d680534aaf`. This identity supersedes the original dirty-patch digest above.

Final `git status --short`:
```text
 M functions/PAYMONGO.md
 M functions/src/_audit.ts
 M functions/src/deleteAccount.ts
 M functions/src/entitlementInputs.ts
 M functions/src/grants.ts
 M functions/src/index.ts
 M functions/src/paymongoCheckout.ts
 M functions/src/paymongoClient.ts
 M functions/src/paymongoGrants.ts
 M functions/src/paymongoWebhook.ts
 M functions/src/revenuecatPasses.ts
 M functions/src/webPlans.ts
 M functions/src/webTrial.ts
 M functions/test/_paymongo-helpers.mjs
 D functions/test/paymongo-checkout.test.mjs
 M functions/test/paymongo-client.test.mjs
 M functions/test/paymongo-policy.test.mjs
 M functions/test/paymongo-webhook.emulator.mjs
 M functions/test/web-plans.emulator.mjs
 M functions/test/web-trial.emulator.mjs
 M lib/features/paywall/data/web_payment_gateway.dart
?? docs/superpowers/plans/pwa-launch/evidence/payments-hardening-r1.md
?? functions/src/webEntitlement.ts
?? functions/test/payments-hardening.emulator.mjs
?? functions/test/paymongo-checkout.emulator.mjs
?? test/features/paywall/data/web_combined_coverage_test.dart
```
