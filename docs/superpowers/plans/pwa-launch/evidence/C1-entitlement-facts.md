# Pro entitlement facts (read-only)

Repo: /Users/aedwon/Documents/Projects/Pantas
Ref: origin/integration/new-design-r1 (read with git show and git grep only)
Paths below are relative to the repo root. Line numbers come from the ref.
Read scope: AGENTS.md preamble from GitHub main (full WORKFLOW.md not read; this task is read-only).

UNCONFIRMED items are collected in section 4.

---

## 1. Server

### 1.1 Entry points (functions/src/index.ts:1-16)

Exports: exportData, deleteAccount, renderWrappedPage, activateSyncGeneration, cleanupSyncData, revenuecatWebhook, repairEntitlementClaims, checkRecentEntitlementClaims, recomputePassEnds, recordSignInEvent, onUserCreated, cleanupOrphanAnons, purgeOldAuditLogs, cleanupWrappedOrphans.

Entitlement-related exports:
- revenuecatWebhook (HTTP, revenuecatWebhook.ts:93-105, region asia-southeast1, secrets REVENUECAT_SECRET_API_KEY and REVENUECAT_WEBHOOK_SECRET)
- repairEntitlementClaims (scheduled "every 60 minutes", revenuecatWebhook.ts:107-108)
- checkRecentEntitlementClaims (scheduled "every 24 hours", revenuecatWebhook.ts:110-111)
- recomputePassEnds (callable, revenuecatPasses.ts:161-177; App Check enforced; requires custom claim admin === true)

### 1.2 Webhook flow (functions/src/revenuecatWebhook.ts:22-91)

1. Reject with 401 unless raw body is a Buffer and HMAC check passes (line 25-26). Signature check is in revenuecatPolicy.ts:29-73: header `t=<unix seconds>,v1=<hex sha256>`, HMAC over `"<t>." + rawBody`, tolerance 300 s (line 62).
2. 400 if the event has no id, type, or uid (line 28; revenuecatPolicy.ts:75-110).
3. If `event.app_id` differs from the configured app id, return 200 and ignore (line 31). Promotional events with null app_id pass.
4. Uids: TRANSFER events use transferred_from and transferred_to; other events use app_user_id, or original_app_user_id as fallback (revenuecatPolicy.ts:86-109).
5. Per uid: skip `$RCAnonymousID:` ids (line 37). Skip uids whose Firebase Auth lookup fails with auth/user-not-found or auth/invalid-uid (lines 39-40).
6. Duplicate check: read `webhookEvents/{eventId}/users/{uid}` (line 42). If it exists, skip the commit.
7. Rate limit (lines 44-53): transaction on `webhookRateLimits/{uid}_{floor(now/60000)}`. Max 30 per minute per uid. Over the limit returns 429. Record field expireAt = now + 1 h.
8. Read sandbox tester flag from `config/testers` field `uids` (line 54-55).
9. Read RevenueCat REST state: readCustomer (line 58) and readPurchases (line 59). The event body does not grant anything; the server re-reads RevenueCat.
10. Purchases are kept only if appId matches and environment is production, or sandbox when project is `pantas-staging` or the uid is a sandbox tester (lines 60-62).
11. Commit via commitRevenueCatAnswer (line 74-79). Facts stored: eventType, appId, environment, productId, entitlementIds, expiry, sources, purchases, coverageContext.
12. If the entitlement record shows claimsPending true, or claimsVersion differs from version, run copyEntitlementClaims (lines 81-84).
13. Return 200 on success, 500 on any thrown error (lines 86-90).

Event types: no per-type branch except TRANSFER (uid list, line 32-34). Every other type runs the same full re-read.

### 1.3 Commit transaction (functions/src/revenuecatClaims.ts:9-31)

Firestore transaction reads `users/{uid}/server/entitlement` and `webhookEvents/{eventId}/users/{uid}`.
- If the dedupe doc exists, return false (line 16).
- If previous.answerAt > answerAt (stale answer), write only the dedupe doc and return false (lines 17-20).
- Otherwise write the dedupe doc and the entitlement record in the same transaction (lines 23-28).

### 1.4 Firestore writes (server)

| Path | Written by | Fields and types |
|---|---|---|
| users/{uid}/server/entitlement | revenuecatClaims.ts:25-28; revenuecatPasses.ts:130 | pro (bool), proUntil (number ms), answerAt (number ms), facts (map: eventType, appId, environment, productId, entitlementIds, expiry, sources, purchases, coverageContext), version (number), claimsVersion (number), claimsPending (bool), updatedAt (serverTimestamp). Lease fields during copy: claimsLeaseHolder (string uuid), claimsLeaseUntil (Timestamp), both deleted on success. |
| webhookEvents/{eventId}/users/{uid} | revenuecatClaims.ts:18, 23 | eventId (string), answerAt (number), version (number), expireAt (Timestamp, +30 days) |
| webhookRateLimits/{uid}_{minute} | revenuecatWebhook.ts:49-50 | uid (string), count (number), expireAt (Timestamp, +1 h) |
| users/{uid} (merge) | revenuecatClaims.ts:68-70 | claimsVersion (number), claimsChangedAt (serverTimestamp) |
| users/{uid}/passes/{encodeURIComponent(transactionId)} | revenuecatPasses.ts:74-85 | transactionId, product, examId, purchasedAt (number ms), sitting {firstDay, lastDay, sourceUrl}, endsAt (number ms), state ('active' or 'revoked') |
| passOwners/{sha256hex(transactionId)} | revenuecatPasses.ts:77, 86 | product, examId, sitting, endsAt, uid (string), answerAt (number). Cleared by clearPassOwnership (revenuecatPasses.ts:147-159) which deletes uid and answerAt. |
| audit_logs/{auto} | revenuecatPasses.ts:88-90 (event passNoPublishedSitting); 131-134 (passEndMoved); _admin.ts:25 (adminAuthorized) | uid, event, timestamp, metadata |
| users/{uid}/passes moved path | revenuecatPasses.ts:87 | deletes prior owner's pass doc when a receipt moves uid |

Firebase Auth custom claims written by copyEntitlementClaims (revenuecatClaims.ts:60-61): `pro` (boolean) and `proUntil` (number ms). Existing custom claims are preserved by spreading `user.customClaims`. No `tier` claim is set. No `trial` claim is set.

Reads used by the server (not written): config/testers (uids array), users/{uid}/server/entitlement facts (recomputePassRecords), users/{uid}/passes, passOwners where uid == X (clearPassOwnership).

### 1.5 Claims computation (functions/src/revenuecatPolicy.ts:146-165)

Input sources (from RevenueCat REST, revenuecatSubscriber.ts:44-78):
- Live if active is true and endsAt > answer time.
- Environment must be production, or sandbox when project is `pantas-staging` or sandboxTester.
- store === 'promotional': all entitlementIds become promotions (no check for 'pro').
- Otherwise: subscription counts only if appId matches, entitlementIds includes 'pro', and productId exists. productId is the part before ':' (base plan).

Passes: livePasses (revenuecatPasses.ts:32-34) keeps rows where the product maps to the same exam and state is 'active'.

coverageAt (functions/src/revenuecatCoverage.ts:14-59) computes tier, passes, and endsAt. Only endsAt is used for claims.

Claims output (line 164):
- latest = max live endsAt (coverage.endsAt)
- pro = latest > 0
- proUntil = latest + 86,400,000 ms (1-day grace), or 0 when not pro.

Pass endsAt (revenuecatPasses.ts:24-31, 72):
- sittingFor: purchase day in Philippines time (UTC+8), then the earliest published sitting with firstDay >= that day and a non-empty sourceUrl.
- endsAt = end of sitting lastDay at 23:59:59.999 +08:00 (line 31).
- Existing prior endsAt or owner endsAt is kept if present.
- If no sitting exists, write an audit log and no pass row (lines 71, 88-90).

recomputePassRecords (revenuecatPasses.ts:95-145) only extends endsAt (line 118). Admin moves use key `exam_x:YYYY-MM-DD`.

### 1.6 Products and tiers

functions/src/products.json (read in full): 10 entries.
- Subscriptions: pantas_pro_weekly, pantas_pro_monthly, pantas_pro_yearly (tier student); pantas_cs_weekly, pantas_cs_monthly, pantas_cs_yearly (tier civilService). kind subscription.
- Passes: pantas_pass_cse_pro (civilService, examId exam_cse_pro); pantas_pass_cse_sub (civilService, examId exam_cse_sub). kind pass.
- Promotional: promo_student (student), promo_civil_service (civilService). kind promotional.

Tier order: student < civilService < licensure < nce (revenuecatCoverage.ts:4, 10). Tier is used only inside coverageAt, not in claims.

### 1.7 Idempotency and rate limit

- Idempotency key: webhookEvents/{eventId}/users/{uid}, checked twice (revenuecatWebhook.ts:42 outside transaction; revenuecatClaims.ts:16 inside).
- Stale-answer guard: answerAt compared to previous answerAt (revenuecatClaims.ts:17).
- Rate limit: 30 events per uid per minute (revenuecatWebhook.ts:15, 44-53). Checked after duplicate check.

### 1.8 Claim copy (functions/src/revenuecatClaims.ts:33-87)

- Lease holder uuid, 60 s lease (lines 36, 45-46).
- Up to 3 attempts. Each attempt: getUser, re-read entitlement under lease, setCustomUserClaims, then Firestore transaction that sets claimsVersion and clears pending (lines 54-72).
- On failure, the lease holder releases the lease and sets claimsPending true (lines 76-86).

### 1.9 Scheduled jobs

- repairEntitlementClaims (every 60 min): repairClaims (revenuecatClaims.ts:89-106). Collection group `server`, where claimsPending == true, pages of 500, copies claims for doc id `entitlement`.
- checkRecentEntitlementClaims (every 24 h): checkRecentClaims (revenuecatClaims.ts:109-139). Collection group `server` where updatedAt >= now - 48 h. Compares Auth claims with stored pro and proUntil. Mismatch sets claimsPending true and copies claims.

Neither job cleans up webhookEvents or webhookRateLimits. Those rely on expireAt (see section 4).

### 1.10 Trial eligibility

- Server: no trial record and no trial field in functions/src (grep found none).
- Client: trialEligible comes from RevenueCat SDK StoreProduct subscriptionOptions with freePhase, for monthly SKUs only (lib/features/paywall/data/revenuecat_sdk.dart:105-115).
- Purchase uses allowTrial = package.trialEligible unless upgrading (live_revenuecat_gateway.dart:484, 529-530). Pass purchases use allowTrial false (line 496).

### 1.11 Secrets and env vars

- Secret REVENUECAT_SECRET_API_KEY (revenuecatWebhook.ts:13)
- Secret REVENUECAT_WEBHOOK_SECRET (revenuecatWebhook.ts:14)
- Env REVENUECAT_PROJECT_ID, REVENUECAT_APP_ID (revenuecatWebhook.ts:94-96)
- Env GCLOUD_PROJECT as firebaseProjectId (revenuecatWebhook.ts:100)
- Build step copies examCatalog.json (functions/package.json:8)

### 1.12 Firestore rules (firestore.rules)

- hasLivePro (lines 17-21): request.auth.token.pro == true, proUntil is number, and proUntil > request.time in ms.
- isProUser / isProOwner (lines 23-29): add isNamedUser (not anonymous) and owner match.
- users/{uid}/server/{doc=**} (lines 135-137): read and write false.
- users/{uid}/passes/{transactionId} (lines 139-142): read if signed in and uid matches (anonymous included); write false.
- users/{uid}/sync_state/current and sync_generations, limits/syncGeneration, proDossiers: gated by isProOwner (lines 144-297).
- webhookEvents, webhookRateLimits, passOwners, config/testers: no rule; default deny (line 336-338).
- audit_logs (306-308): read and write false.

---

## 2. Client

### 2.1 Entitlement type (lib/features/paywall/domain/entitlement.dart)

Fields:
- plan: EntitlementPlan (free, weekly, monthly, yearly) (line 7, 29-54)
- productId: String? (line 73)
- expiresAt: DateTime? (line 74)
- isTrial: bool (line 75)
- willRenew: bool (line 76)
- isUnknownPlan: bool (line 219)
- tier: PriceTier? (getter line 151)
- state: EntitlementState (free, trial, active, canceledActive, billingIssue, grant, unknown, paused) (lines 9-18, 157-168)
- passes: Map<String, DateTime> (examId to endsAt) (line 146)
- subscriptions: List<CoveragePeriod> (line 147)
- promotions: List<CoveragePeriod> (line 148)
- examTiers: Map<String, PriceTier> (line 149)
- endsAt, renewsAt, chargesAt: DateTime? (lines 170-184)
- verifiedAt: DateTime? (line 82)
- effectiveAt, offlineGrace (lines 83-84)

Gates:
- coversExam (line 201-207) uses coverage passes and tier comparison.
- proIsActive (line 221-225): true if unknown plan, non-free plan, passes, or promotions.
- Offline grace: withOfflineWindow sets offlineGrace to 3 days (line 112-116).

### 2.2 Where Entitlement comes from

Provider: entitlementProvider (lib/features/paywall/application/paywall_providers.dart:101-125).
- Debug overrides first (lines 101-116, kDebugMode only: devProOverrideProvider, FAKE_PRO).
- Otherwise: gateway.cachedEntitlement (local snapshot) emitted first, then gateway.customerInfoUpdates, with distinct().

Gateway: LiveRevenueCatGateway (lib/features/paywall/data/live_revenuecat_gateway.dart):
- RevenueCat SDK customer info (sdk.getCustomerInfo, line 383; _acceptCustomerInfo line 245).
- Pass ledger read from Firestore users/{uid}/passes (pass_ledger_source.dart:40-42; live gateway _readPasses lines 356-369). Only rows with state 'active' and a matching pass product are used (pass_ledger_source.dart:11-20).
- Local snapshot store (entitlement_snapshot_store.dart, payment_entitlement_state.dart).

Disabled gateway (no Android key): DisabledRevenueCatGateway (revenuecat_gateway.dart:36-114). cachedEntitlement and updates come from local state only. currentOffering returns noCurrentOffering. purchase returns configurationFailure.

Custom claims are NOT used for entitlementProvider. Claims are used by:
- Firestore rules hasLivePro (firestore.rules:17-21).
- Sync eligibility: hasLiveProClaim (lib/core/sync/eligibility/sync_claim_gateway.dart:28-34) reads claims pro and proUntil from the ID token.
- Token refresh: refreshPaymentClaimToken calls getIdTokenResult(true) (sync_claim_gateway.dart:36-41). Called after purchase (live_revenuecat_gateway.dart:561) and after restore (line 625).

Config: RevenueCatConfig.fromEnvironment reads dart define REVENUECAT_ANDROID_API_KEY (revenuecat_config.dart:1-19). Enabled only when non-empty. No iOS key is referenced in these files.

### 2.3 Gateway interface (lib/features/paywall/data/revenuecat_gateway.dart:11-34)

```dart
abstract interface class RevenueCatGateway {
  Stream<Entitlement> get customerInfoUpdates;
  Entitlement? get cachedEntitlement;
  Future<void> initialize();
  Future<void> configure({required String androidApiKey});
  Future<void> logIn(String uid);
  Future<PaywallOfferingResult> currentOffering();
  Future<PaymentOperationResult> purchase(PaywallPackage package);
  Future<PaymentOperationResult> restorePurchases();
}

abstract interface class RevenueCatAccountGateway implements RevenueCatGateway {
  Future<void> clearIdentity();
  Future<void> logOut();
}

abstract interface class RevenueCatPassGateway implements RevenueCatAccountGateway {
  Future<PaymentOperationResult> purchasePass(
    PaywallPassPackage package, {
    required ExamCatalogEntry exam,
  });
}
```

Package inputs: PaywallPackage (lib/features/paywall/domain/paywall_package.dart:15-35) has sku, productId, priceString, priceAmount, trialEligible. PaywallPassPackage (lines 3-13) has productId, priceString, priceAmount.

Result: PaymentOperationResult (lib/features/paywall/domain/payment_operation.dart:26-40) has status (PaymentOperationStatus enum, lines 3-15) and confirmedEntitlement (Entitlement?). Constructors: .authoritative and .failure.

### 2.4 How the Pro page starts a purchase

- pro_page.dart:101: a button (label not read) calls context.push('/paywall'). The Pro page does not call purchase.
- Purchase is started in paywall_page.dart:100-117. It calls paywallControllerProvider.purchase(package), or widget.onPurchase.
- paywall_controller.dart:36-78 calls _gateway.purchase(package). Single in-flight guard.
- Restore: pro_page.dart:171-178 calls paywallControllerProvider.restore(). paywall_controller.dart:80-94.
- Pass purchase: paywall_controller.dart:96-121 calls gateway.purchasePass only when the gateway is RevenueCatPassGateway.
- paywall_providers.dart:83-99: LiveRevenueCatGateway built when RevenueCat is configured. refreshClaims is refreshPaymentClaimToken.

Live purchase path (live_revenuecat_gateway.dart:499-564):
1. Reject if identity busy or a pending purchase exists for the uid (lines 503-515).
2. Upgrade check: student to civilService subscription uses oldProductId (lines 521-526).
3. sdk.purchase(productId, oldProductId, allowTrial) (lines 527-531).
4. _acceptCustomerInfo (line 532).
5. Success only if verification verified, requestDate equals verifiedAt, and product coverage exists (lines 533-539).
6. On pending failure, save PendingPurchase (lines 543-551).
7. finally: _refreshClaims (lines 560-562).

Pending purchase storage: pending_purchase_store.dart (not fully read).

Client Pro gates: proForActiveExamProvider (paywall_providers.dart:150-169) uses entitlement.coversExam with exam tier from catalog. Other reads of entitlementProvider are in settings, progress, quiz, home, and router files (grep, see section 3).

---

## 3. Client gate references (grep of ref, lib/)

- lib/app/bootstrap.dart:88 proIsActive: proForActiveExamProvider
- lib/app/routes/mock_routes.dart:63, quiz_routes.dart:40,151, mock_exam/.../mock_results_route.dart:25: proForActiveExamProvider
- lib/app/router.dart:32, lib/app/sync_runtime_bootstrap.dart:53: entitlementProvider
- lib/app/routes/settings_routes.dart:58, settings/application/settings_providers.dart:195, settings/presentation/pages/pro_page.dart:61: entitlementProvider
- progress, quiz debrief, home tendencies: entitlementProvider
- lib/core/sync/eligibility/sync_claim_gateway.dart:29-30: claims pro and proUntil
- functions/src/syncGenerationPolicy.ts:24-25: auth.token.proUntil check
- lib/core/dev/dev_pro_switch.dart: debug override only

---

## 4. UNCONFIRMED

1. examCatalog.json is not tracked in the ref. functions/src/revenuecatPasses.ts:15 reads it at module load. functions/package.json:8 copies it from content/exams/catalog.json at build. Whether the deployed build has it: UNCONFIRMED.
2. Whether webhookEvents, webhookRateLimits, or passOwners have a TTL policy on expireAt: no config found in the ref; UNCONFIRMED.
3. Whether a Firestore composite index exists for collectionGroup `server` ordered by updatedAt (revenuecatClaims.ts:115-116): not checked; UNCONFIRMED.
4. Whether deleteAccount.ts calls clearPassOwnership in the correct order with other deletes: call site at deleteAccount.ts:32 only; surrounding logic not read.
5. Whether RevenueCat retries a 429 or 500 response: not verifiable from the repo.
6. pending_purchase_store.dart, offline_window.dart full logic, trusted_clock.dart, and products.dart were not read in full.
7. Full WORKFLOW.md from GitHub main was not read; only the AGENTS.md preamble was.
