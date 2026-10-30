# Payment re-check fixes r1

## Assignment and identity

- User's three-item re-check brief is the bounded implementation plan and approved behavior: stored postponements follow the pass, promotions count as coverage, and web purchases queue behind existing coverage. Refunds remain manual through refundRequired.
- Worktree: /Users/aedwon/Documents/Projects/Pantas-wt-pay-reaudit-r1.
- Branch: web/payments-reaudit-fixes-r1. Starting HEAD: 44313ce2cbeb71f68edc2a2ec349d54e2f0a5e10. Initial working tree clean.
- Read AGENTS.md, WORKFLOW.md, SUBAGENTS.md using git show origin/main at d588f68f8be94016724ff0837be284cd4ea5c561. No fetch, branch switch, commit, push, deployment, or live application service calls.
- Read the existing C3 gateway plan, payment hardening evidence, integration notes, and actual server/client coverage code. Historical C3 references to C1-C10-ruling.md and the October 19 PWA spec/plan are absent from this candidate. This assignment follows the explicit current brief.
- Ran flutter pub get, then dart run build_runner build --delete-conflicting-outputs. Generated output remains ignored. Copied no assets and rebuilt no content package.

## Results and test-first evidence

1. `reaudit 4: postponement chains survive a removed intermediate sitting`: creates A to B and B to C through recomputePassRecords, retains only C, delivers payment bound to A, asserts C's sitting and expiry. Failed before the change in the full emulator suite. Passed after the change. Traversal now follows stored move destinations independently of intermediate catalog entries, with a visited set and the existing eight-hop limit.
2. `an active promotion-only account shows Pro on web`: failed with actual false, expected true. Passed after mapping known promotional products to Entitlement.promotions. Promotions keep their real end and never renew.
3. `refresh keeps Pro through Monthly queued behind $anchor`: promotion and pass cases failed with null expiry, expected queued end. The existing subscription case already passed. All three cases pass after recognizing connected current coverage from promotions, subscriptions, and passes. Asserted Pro now, expiry at queued end, access at the coverage boundary, and no access at the queued end. Isolated future and gap tests still pass.

The queue tests exercise logIn and restorePurchases with injected local ledger/callable seams. Server rows normalize productId-null RevenueCat promotions to the entitlement ID, such as promo_civil_service. No server protocol, entitlement model, approved rule, or database migration changed.

An existing unknown-row test treated promo_civil_service as unknown. Its fixture now uses promo_unknown. Its assertion remains unchanged.

## Verification

Ports 8080, 9099, 9199 were checked with lsof before each npm test launch. No listeners were present. No existing service was killed. Firebase used demo-pantas-test, local Auth/Firestore/Storage emulators, Java 21, CI=true, FIREBASE_CLI_DISABLE_TELEMETRY=1, and XDG_CONFIG_HOME=/private/tmp/reaudit-firebase.

`cd functions && npm test`, exit 0. Actual final output:

```text
ℹ tests 225
ℹ pass 225
ℹ fail 0
ℹ tests 321
ℹ pass 321
ℹ fail 0
✔  Script exited successfully (code 0)
```

The first run had exactly one emulator failure: the new postponement-chain regression (321 tests, 320 passed, 1 failed). Logs: /private/tmp/reaudit-server-red.log and /private/tmp/reaudit-server-green.log.

`flutter test --no-pub --no-test-assets test/features/paywall/data/web_combined_coverage_test.dart test/features/paywall/data/web_payment_gateway_test.dart`, exit 0:

```text
00:00 +72: All tests passed!
```

Client red/green logs: /private/tmp/reaudit-promo-red.log, /private/tmp/reaudit-promo-green.log, /private/tmp/reaudit-queue-red.log, /private/tmp/reaudit-queue-green.log. Final focused log: /private/tmp/reaudit-targeted-final.log.

`flutter analyze`, exit 1:

```text
warning • The asset file 'assets/seed/content.db' doesn't exist. Try creating the file or fixing the path to the file • pubspec.yaml:112:13 • asset_does_not_exist
warning • The asset file 'assets/seed/content.manifest.json' doesn't exist. Try creating the file or fixing the path to the file • pubspec.yaml:114:13 • asset_does_not_exist
warning • The asset file 'assets/seed/content.manifest.sig' doesn't exist. Try creating the file or fixing the path to the file • pubspec.yaml:116:13 • asset_does_not_exist
warning • The asset file 'assets/seed/lesson_links.json' doesn't exist. Try creating the file or fixing the path to the file • pubspec.yaml:118:13 • asset_does_not_exist
4 issues found. (ran in 10.9s)
```

`flutter test test/features/paywall test/app`, exit 1 before tests:

```text
Error detected in pubspec.yaml:
No file or variants found for asset: assets/seed/content.db.
Error: Failed to build asset bundle
```

An additional asset-free attempt of both directories was stopped after asset-dependent tests failed and two route tests did not complete. This attempt is not a passing focused suite. Output reached `+383 -13`, then reported two tests did not complete. Missing catalog and shader assets caused failures. It also caught the obsolete unknown-promotion fixture, corrected above. Full output: /private/tmp/reaudit-focused-noassets.log. Failures observed:

- test/features/paywall/application/active_exam_coverage_test.dart: active exam switch applies coverage for pantas_pro_monthly [E]
- test/features/paywall/application/active_exam_coverage_test.dart: active exam switch applies coverage for pantas_cs_monthly [E]
- test/features/paywall/data/web_payment_gateway_test.dart: grant ledger mapping rows that are not recognized grants are ignored [E]
- test/features/paywall/domain/price_tier_test.dart: every bundled catalog entry resolves to its declared tier [E]
- test/app/mock_entitlement_override_test.dart: mock cooldown follows the active exam for pantas_pro_monthly [E]
- test/app/mock_entitlement_override_test.dart: mock cooldown follows the active exam for pantas_cs_monthly [E]
- test/app/study_search_reopen_test.dart: cancel clears the search request so it can focus again [E]
- test/app/router_onboarding_completion_test.dart: fresh exam selection stays incomplete and advances to exam date [E]
- test/app/bootstrap_recovery_test.dart: bootstrap storage failure shows recovery and retries in the same zone [E]
- test/app/deferred_route_test.dart: failed load retries and then opens the page [E]
- test/app/study_route_test.dart: bookmark reader returns to the still-open bookmark sheet [E]
- test/app/router_redirect_test.dart: age gate not passed → boot lands on onboarding welcome [E]
- test/app/router_mock_panel_test.dart: Resume opens the active mock attempt route [E]
- test/app/router_onboarding_completion_test.dart: passedAgeGate = true, exam selected, onboardingComplete = false -> stay on onboarding - did not complete [E]
- test/app/router_redirect_test.dart: age gate passed, needs selection → boot lands on onboarding picker - did not complete [E]

Required static checks, exit 0:

```text
Formatted 1683 files (0 changed) in 1.78 seconds.
check_layering: OK
check_no_ai_attribution: OK
```

`git diff --check`: exit 0, no output.

## Files touched

- functions/src/paymongoGrants.ts
- functions/test/payments-reaudit.emulator.mjs
- lib/features/paywall/data/web_payment_gateway.dart
- test/features/paywall/data/web_combined_coverage_test.dart
- test/features/paywall/data/web_payment_gateway_test.dart: update obsolete unknown-promotion fixture.
- This evidence record: task handoff and verification limitations.

## Remaining acceptance

All three requested behavior regressions have red/green evidence. Exact Flutter analysis and the requested full focused Flutter command remain blocked by missing pinned assets. No assets were copied or regenerated. No real checkout, live webhook, or production claim propagation was verified. Independent review, final acceptance, and commits remain with the lead.
