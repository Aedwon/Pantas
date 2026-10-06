# Abuse review 1

Reviewer: GPT-6 Astra (medium reasoning) through Codex CLI, read-only, October 6, 2026, at
Aedwon's request. Scope: integration branch code at 1f79d880 and the payment, sharing, account
and release plans. Prompt: kept in the lead's session notes. The reviewer's report is reproduced
unchanged below the lead's verdict.

## Lead's verdict (Opus, checked against the code)

Confirmed by reading the cited code: CX-1 (share record `storagePath` is unchecked: `firestore.rules`
create rule and `renderWrappedPage.ts`), CX-2 (cached entitlement ignores `expiresAt`;
`entitlementProvider` starts from the cache and swallows errors), CX-5 and CX-6 (`normalizeRevenueCatEvent`
keeps only id, type and user; grants follow arrival order), CX-7 (`storage.rules` has no size or type
limit), CX-13 (`functions/package.json` has no dependencies or build; `firebase.json` deploys the
source folder), CX-15 (user record create allows any extra field).

| Finding | Verdict | Owner (strategy B2, amended Oct 6) |
|---|---|---|
| CX-1, CX-7 | agree, before beta | W4g |
| CX-2, CX-8, CX-9 | agree, before beta | W3 |
| CX-3, CX-4 | agree, before pass sales | W3 |
| CX-5, CX-6 | agree, before beta | W3 |
| CX-10 | agree, before any tiered server content | W3 |
| CX-11 | agree, before giveaways | W3 |
| CX-19 | agree the promise must be settled; product decision for Aedwon | W3 |
| CX-13 | agree, before any deploy; first W6 task | W6 |
| CX-15 | agree, before beta | W6 |
| CX-16 | agree, before beta (with CX-5) | W3 |
| CX-12 | partly: basic per-account limits only before beta | W6 |
| CX-14 | partly: disable the placeholder export and make cleanup jobs work; full exporter later | W6 |
| CX-17 | agree; remove the unused function rather than harden it (no caller in `lib/`) | W6 |
| CX-18 | agree, before external beta | W5 |
| Accepted-risk candidates (section 4) | agree; Aedwon accepts them at E14 with the bootstrap-key risk | W5 |

---

# Pantas security and abuse review

Reviewed code at `1f79d880264e9c80c7507c95a365126d251c3837` and the requested plans in the main checkout.

This is a source review, not confirmation of deployed behavior. No files were changed, credentials accessed, production endpoints tested, or deployments performed.

## 1. Summary

1. **CX-1:** Wrapped sharing can publicly serve another user’s storage object when its path is known.
2. **CX-2:** One purchase or trial can provide indefinite local Pro by blocking RevenueCat refreshes.
3. **CX-3/CX-4:** Season Pass plans lack explicit product-to-exam binding and complete refund, transfer, and transaction ownership rules.
4. **CX-5/CX-6:** Webhook processing can restore expired Pro and grants without checking the purchased product or environment.
5. **CX-7:** Anonymous accounts can upload unrestricted files and use Pantas sharing links to generate hosting costs.

The current code should not pass a security release gate. The approved plans address some payment defects, but leave the sharing defects and several purchase boundaries unresolved.

## 2. Findings

Rows are ordered approximately by likelihood multiplied by financial or reputational impact. Effort estimates include targeted tests, but exclude store approval and deployment coordination.

Evidence paths refer to the reviewed worktree. Plan filenames refer to `docs/superpowers/plans/new-design/` in the main checkout.

| ID | Severity | Area | Present today or planned | Finding | Concrete exploit scenario | Evidence | Recommended fix and rough effort | Before beta? |
|---|---|---|---|---|---|---|---|---|
| CX-1 | high | Storage authorization | Today | **Public sharing trusts an arbitrary client-supplied storage path.** The renderer downloads that path with administrative privileges. Storage read rules do not protect this access. | An anonymous user creates their own share document but points `storagePath` at another user’s known object. Their public `/card.png` endpoint returns its bytes. This can also expose future private exports in the same bucket. Object paths must be known or obtained separately; bucket listing is not exposed. | `firestore.rules:212`, `functions/src/renderWrappedPage.ts:32`, `functions/src/renderWrappedPage.ts:42`, `storage.rules:4` | Derive the object path from validated owner and share IDs on the server. Reject inconsistent records. Test cross-owner objects, export paths, and malformed records. **4–8 hours.** | **Yes** |
| CX-2 | high | Offline entitlement | Today, preserved by plans | **Cached Pro never expires locally.** `expiresAt` is stored but ignored when deciding access. Device clock skew can also prevent a fresh inactive response from revoking Pro. | Buy Weekly or start a trial, then block RevenueCat traffic. Local Pro remains indefinitely. Moving the clock sufficiently ahead or behind makes the five-minute inactive-response check reject revocation. No APK modification is required. | `lib/features/paywall/domain/entitlement.dart:48`; `data/entitlement_snapshot_store.dart:65`; `data/live_revenuecat_gateway.dart:106`; `application/paywall_providers.dart:59`; L2 W3 §4 | Define bounded offline access, enforce subscription and pass expiry, and use a server-time anchor with rollback detection. Preserve offline study and user-created work. **12–24 hours.** | **Yes**, unless indefinite access is explicitly accepted |
| CX-3 | high | Season Pass scope | Plan gap | **The server trusts the exam selected through purchase metadata without an explicit product-to-exam authorization check.** A published sitting is insufficient authorization. | A modified client buys the ₱499 CSE product while submitting a different exam ID. If that exam has a published sitting, the described handler could grant the wrong pass. Future ₱1,499 tiers increase the financial impact. | Tier pricing spec §B3; L3 W3 Tasks 4–5 | Maintain a server product allowlist with permitted exams, sale status, and environment. Bind a purchase intent to the authenticated account and verified transaction. Reject mismatches. **8–16 hours.** | **Yes**, before pass sales |
| CX-4 | high | Pass lifecycle | Plan gap | **Pass records lack a complete transaction lifecycle.** Refund removal, transfer ownership, repeated purchases, and atomic transaction deduplication are not specified. The plan also writes `endsAt: null` where the spec requires rejection. | A buyer refunds a consumable after its pass is recorded. Unless the pass ledger explicitly processes that reversal, access persists. Transfers or duplicate delivery can produce inconsistent ownership or pass dates. These are plausible consequences of missing requirements, not reproduced implementation defects. | Tier pricing spec §§B1–B3; L3 W3 Tasks 2, 3, 5; L3 W5 Task 5 | Keep a server-owned ledger keyed by store transaction, with account, product, exam, sitting, and revocation state. Define repeat-purchase behavior. Treat missing dates as non-entitling. Test refunds, transfers, duplicates, and reordered events. **16–32 hours.** | **Yes**, before pass sales |
| CX-5 | high | Webhook ordering and revocation | Today; partly addressed in plans | **Entitlement follows event arrival order, not current subscription state.** Claims have no expiry. Deduplication and rate counting are nontransactional. | An expiration clears Pro, then a delayed initial-purchase or renewal event sets it back to true. The claim can remain true without another correcting event. Concurrent deliveries can race. A grant expiring can also revoke a still-active subscription. | `functions/src/revenuecatPolicy.ts:19`, `:103`; `revenuecatWebhook.ts:39`, `:46`, `:58`; L3 W3 Task 2 | Reconcile current RevenueCat state for every entitlement-changing event. Serialize updates per customer, make event handling idempotent, and give server access a bounded validity period. Preserve retryable failures. **12–24 hours.** | **Yes** |
| CX-6 | high | Webhook purchase validation | Today | **A valid signature authenticates the sender, but the handler does not validate what was purchased.** Normalization discards product, entitlement, environment, application, and expiry fields. | A signed sandbox or unrelated-product `INITIAL_PURCHASE` for a valid Firebase UID grants production `pro: true` if routed to this endpoint. Actual exposure depends on RevenueCat dashboard filters, which were not checked. | `functions/src/revenuecatPolicy.ts:126`, `:157`; `:90`; `revenuecatWebhook.ts:32` | Validate application, environment, recognized product, and entitlement membership server-side. Explicitly authorize promotional grants. Test wrong-product and sandbox events. **4–8 hours.** | **Yes** |
| CX-7 | high | Public hosting and cost abuse | Today; not addressed by sharing plan | **Uploads have no application size, type, count, or publication quota.** Anonymous users qualify. The public renderer loads entire objects into memory without application rate limits. | A genuine install uploads large files or abusive images under its own UID, publishes share records, and distributes links. Repeated public image requests consume storage bandwidth and function resources. App Check does not make a genuine user trustworthy. | `storage.rules:11`; `firestore.rules:214`; `functions/src/renderWrappedPage.ts:21`, `:44`; L3 W4g Tasks 3, 6 | Enforce upload size/type rules, per-account publication quotas, and server validation or image re-encoding. Limit public request rates and configure resource ceilings. Add orphan cleanup and an abuse-removal path. **12–24 hours.** | **Yes** |
| CX-8 | medium | Account separation | Today | **Payment state is device-wide and survives account sign-out.** RevenueCat identity changes can fail silently while the previous entitlement remains active. | A paid user signs out on a shared phone. A different account uses the retained local Pro snapshot while payment identity association is unavailable. Firebase-protected data still requires that account’s own authorization. | `application/revenuecat_bootstrap.dart:33`; `data/entitlement_snapshot_store.dart:26`; `application/paywall_providers.dart:20`; `lib/core/sync/local_state_wiper.dart:56`; `lib/core/auth/auth_repository.dart:86` | Scope cached entitlement to a verified purchase identity. Reset in-memory payment state during account transitions and block purchases until identity association completes. Test offline account switching and delayed callbacks. **8–16 hours.** | **Yes** |
| CX-9 | medium | RevenueCat SDK trust | Today | **The app discards entitlement verification results.** It accepts active entitlements without checking whether RevenueCat’s signature verification failed. | A rooted-device attacker intercepts or tampers with SDK responses. A failed verification result provides no defense because the adapter copies only product and expiry information. This is an avoidable weakness, although a fully patched client remains unbeatable locally. | `lib/features/paywall/data/revenuecat_sdk.dart:137`, `:158`; snapshot fields at `:27` | Preserve verification results and reject failed verification for new grants. Define safe handling of unverifiable cached data. **4–8 hours.** | **Yes** |
| CX-10 | medium | Server tier enforcement | Today; migration gap | **Server content gates check only a global Pro boolean.** The plan inventories client gates but does not explicitly replace exam-specific server authorization. | A Student subscriber requests Civil Service server content directly. Current rules allow any named Pro account to read any exam’s `proContent`. Actual data exposure depends on those collections containing content. | `firestore.rules:17`, `:197`; `functions/src/getProContent.ts:12`; L3 W3 Task 8 | Apply server-side tier inclusion and pass scope to exam content. Keep account-wide sync separate if that is intentional. Test Student-to-CSE denial and pass isolation. **6–12 hours.** | **Yes**, before tiered server content |
| CX-11 | medium | Giveaways | Plan gap | **Tier-specific promotional grants are not fully defined.** A single `pro` promotional entitlement does not identify Student versus Civil Service coverage. | An administrator awards Student Pro through RevenueCat. The app receives a promotional or unknown product without a defined tier mapping. A fallback can either overgrant expensive access or deny the winner. | Giveaways decision log, “Rules for running giveaways”; tier pricing spec §B3; L3 W3 Tasks 3–4 | Define a server-owned grant tier and expiry, or distinct promotional entitlements. Record the giveaway, recipient public ID, tier, and grant identifier. Test overlaps with paid subscriptions. **6–12 hours.** | **Yes**, before giveaways |
| CX-12 | medium | Backend quotas | Today | **Several authenticated operations and sync writes have no application quotas.** Audit generation is unlimited, and sync validation permits arbitrary extra payload fields and staging generations. | One named account repeatedly calls sign-in logging. One Pro account creates many staging generations and large sync rows. Pantas pays for writes, audit storage, cleanup, and reads. | `functions/src/recordSignInEvent.ts:10`; `_audit.ts:18`; `activateSyncGeneration.ts:182`; `firestore.rules:47`, `:100`; `cleanupSyncData.ts:141` | Add per-account limits, bounded schemas, staging-generation caps, and idempotent audit events. Paginate cleanup queries and configure alerts/resource ceilings. **12–24 hours.** | **Yes** for basic limits |
| CX-13 | high | Deployability and verification | Today; partially addressed in plans | **The checked-in Functions package is not a complete deployable backend.** It declares no dependencies, build script, or compiled entrypoint. Source contains no Admin SDK initialization. The default test command excludes behavior and rules tests. | A release relies on green tests, but deployment fails or relies on undocumented external packaging. Existing deployed code can remain stale while the app assumes security changes shipped. This is a release failure, not a direct attacker exploit. | `functions/package.json:1`; `functions/tsconfig.json:6`; `functions/src/index.ts:1`; `firebase.json:1`; L3 W3 Task 1 | Complete the dependency/build/entrypoint contract and Admin initialization. Run behavior and emulator rules tests against compiled handlers. Verify deployed revision separately. **8–16 hours.** | **Yes** |
| CX-14 | medium | Privacy endpoints and retention | Today | **Export is a placeholder, and three cleanup jobs are empty.** Export returns a constructed URL and a share list, not an account export. | A direct caller receives a success-shaped export response with no generated export. Anonymous accounts and audit records accumulate because scheduled cleanup does nothing. Settings intentionally hides export, which reduces accidental exposure but does not complete the endpoint. | `functions/src/exportData.ts:13`, `:34`; `cleanupOrphanAnons.ts:9`; `purgeOldExports.ts:9`; `purgeOldAuditLogs.ts:9`; `test/tool/settings_release_guard_test.dart:35` | Remove or explicitly disable unfinished endpoints. Implement required retention jobs with pagination and evidence. Keep the documented manual export process until an automated export exists. **8–20 hours**, excluding a complete exporter | **Yes** to disabling placeholders and establishing retention |
| CX-15 | medium | Future privileged fields | Today; conditional future impact | **User-root creation permits arbitrary extra fields.** Updates use an allowlist, but creation only requires `createdAt`. | A newly authenticated user creates their root document first with fabricated `publicId`, `tier`, or other future server-owned fields. Current authorization uses token claims, so this does **not** presently forge Firebase Pro. Future code trusting those document fields could introduce escalation. | `firestore.rules:77`; `functions/src/recordSignInEvent.ts:15`; L3 W3 Task 10 | Restrict create fields with an allowlist or make root creation server-only. Keep public IDs and entitlement records explicitly client-unwritable. **2–4 hours.** | **Yes**, before identity changes |
| CX-16 | low | Webhook replay | Today | **Signed request timestamps are never checked for freshness.** Event-ID deduplication reduces ordinary replay impact but is not atomic. | Someone possessing a captured valid webhook can replay it indefinitely. A processed event normally returns “duplicate,” so this alone is not an unlimited-Pro exploit. Concurrent delivery or missing dedupe history increases the risk. | `functions/src/revenuecatPolicy.ts:47`; `revenuecatWebhook.ts:39` | Enforce a short signature-age tolerance and atomic idempotency. Keep event ordering separate from signature freshness. **2–4 hours.** | **Yes**, with CX-5 |
| CX-17 | low | Query construction | Today; latent injection | **The content query interpolates an unrestricted document type.** The current handler only returns the query, so no database injection or data theft is demonstrated. | If future code executes this generated query with a privileged Sanity token, crafted input can change its filter. Today it merely returns attacker-influenced text. | `functions/src/getProContent.ts:16`, `:28` | Allowlist document types and use query parameters before adding execution. Bound input length. **1–2 hours.** | Before enabling real content retrieval |
| CX-18 | low | APK hardening | Today | **The canonical Android release command omits Dart obfuscation.** This makes local Pro gates easier to locate. | A mod author identifies the entitlement getter or SDK adapter in the release binary and patches local access. Obfuscation raises effort but cannot prevent this. | `tools/release/android/release.sh:219`; `lib/features/paywall/domain/entitlement.dart:48`; `codemagic.yaml:63` | Add `--obfuscate` and managed `--split-debug-info`, preserve symbols securely, and verify crash symbolication. **2–4 hours.** | Recommended before external beta |
| CX-19 | medium | Trial policy | Plan gap | **“One trial per student who ever had Pro” exceeds the specified store eligibility rule.** Prior passes and promotional grants are not prior subscriptions. Separate store accounts also remain separate identities. | A pass holder or giveaway recipient with no subscription history takes a Monthly trial. One person may also use multiple store accounts. The first case contradicts the approved product rule; the second cannot be solved reliably through client flags. | Tier pricing spec Part A item 4 and §B4; L3 W3 Task 7 | Decide whether eligibility means prior subscription or any prior Pro. For the latter, add server history and a store-compatible enforcement design. Accept residual multi-account abuse explicitly. **4–8 hours** for the policy/history design; implementation depends on the chosen offer mechanism | **Yes**, settle the promise |

### Verification notes

- **Webhook behavior was tested locally.** All 11 existing policy tests passed.
- A separate in-memory check confirmed that an expiration followed by a late sandbox, unrelated-product purchase ends with `pro: true`.
- A separate in-memory check confirmed that a correctly signed request with timestamp `1` is accepted.
- All 31 default `.test.mjs` tests passed. These tests mostly inspect source text. Their success does not validate deployed handlers or Firestore/Storage authorization.
- Sharing exploits were established by tracing write rules into the administrative renderer. They were not executed against any service.

RevenueCat currently documents the exact HMAC format implemented here. The authentication scheme is therefore valid; the defect is missing freshness and purchase-state validation. RevenueCat also recommends reconciling subscriber state after webhooks. [RevenueCat webhook documentation](https://www.revenuecat.com/docs/integrations/webhooks)

RevenueCat’s trusted-entitlement results are informational by default in newer SDKs. Applications must handle verification failures themselves. [Trusted Entitlements](https://www.revenuecat.com/docs/customers/trusted-entitlements)

Google Play distinguishes prior subscription eligibility from broader application entitlement history. [Google Play subscription offer eligibility](https://support.google.com/googleplay/android-developer/answer/140504?hl=en-EN)

## 3. Things already done well

- **No demonstrated client-to-server Pro escalation through local flags.** Sync requires a refreshed Firebase claim, and Firestore checks the authenticated owner. Patching local Pro does not forge that claim.
- **Webhook authentication fails closed.** It requires exact raw bytes and uses constant-time HMAC comparison.
- **Cancellation does not currently revoke Pro immediately.** The reviewed policy revokes on expiration and outgoing transfer. The older giveaway log’s contrary statement is stale.
- **Account deletion checks recent authentication server-side.** It derives the UID from authentication and deletes the Auth identity after data cleanup.
- **Google linking uses Firebase credentials.** Existing-account fallback requires Google authentication. I found no UID-only or public-ID account takeover path.
- **Debug Pro overrides are guarded by `kDebugMode`.** Both provider overrides and the development service extension have guards.
- **Content protection has meaningful integrity controls.** The verifier authenticates the manifest, checks payload hashes, enforces key sequence windows, and rejects downgrade or same-sequence substitution.
- **Content installation avoids plaintext staging on the device.** It rekeys the encrypted package to a per-install key and includes interrupted-install recovery.
- **Android backup controls are explicit.** Cloud backup and device transfer exclude private data. Notification receivers are not exported.
- **Production signing cannot silently fall back to the debug key through the reviewed production build path.**
- **Public share IDs use 128 random bits.** Enumeration of honestly generated links is not a practical first attack.
- **The planned public-ID boundary is sound.** Owner-only reads, server-only creation, private mapping, audited administrator lookup, and retirement are the right controls.

The absence of an explicit R8 setting is **not evidence that R8 is disabled**. Flutter documents release shrinking as enabled by default. The actual release artifact still needs inspection. [Flutter Android release guidance](https://docs.flutter.dev/deployment/android)

## 4. Accepted-risk candidates

### A patched app can unlock local features

The app’s local Pro value ultimately controls local code and locally available information. A determined attacker can patch that decision.

Accept this after fixing indefinite unmodified-app access, verification-result handling, identity separation, and inexpensive obfuscation. Do not spend the beta budget on extensive root detection or anti-Frida checks.

### The bundled content can eventually be extracted

The release embeds the bootstrap decryption material through a compile-time define. Startup installs the content before payment initialization.

Evidence: `lib/app/bootstrap.dart:36`, `:140`; `tools/release/android/release.sh:226`; `lib/core/content/bundle/protected_content_installer.dart:119`.

Encryption prevents casual asset extraction. Signing prevents unauthorized package substitution in an intact app. Neither prevents a hooked client from obtaining the decrypted lesson and question bank.

Accept this if first-install offline access remains a requirement. The signing private key must remain outside the app.

### Free mock limits are locally bypassable

The 14-day limit uses the device clock and local attempt history.

Evidence: `lib/features/mock_exam/application/mock_availability_provider.dart:15`, `:33`.

Advancing the clock, clearing local data, or patching the check can reopen mocks. A server-time anchor can reduce casual clock abuse, but reinstall resistance requires an account or online dependency. Treat this as a monetization limit, not a strong security boundary.

### Public IDs are identifiers, not proof of ownership

Nine digits with a check digit are guessable in principle. That is acceptable because the plan provides no public resolver and grants no authority to possession.

Giveaway administration should use the recorded winning comment and its ID. Never resolve disputes, transfer accounts, or change an award based solely on someone quoting a public ID.

### Subscription sharing and multiple store accounts

Perfect “one human, one trial” enforcement would require intrusive identity controls. Accept some sharing and multiple-account trial abuse.

However, restore behavior must be explicitly selected and tested. RevenueCat can transfer purchases according to dashboard settings. Offline access remaining on the old device makes CX-2 especially important. [RevenueCat restore behavior](https://www.revenuecat.com/docs/projects/restore-behavior)

### Public shares remain copyable

Revocation cannot recall screenshots, downloaded images, or third-party social previews. The renderer also permits five minutes of public image caching.

Accept this with accurate disclosure. It does not justify the cross-object access or unrestricted hosting findings.

## 5. What I could not check

- **Deployment state:** No production calls were made. I did not verify deployed function revisions, rules, IAM, bucket permissions, quotas, or App Check enforcement.
- **Repository freshness:** The review used the supplied local snapshot. No fetch was performed because the task required read-only work.
- **RevenueCat configuration:** HMAC enablement, secret binding, environment filters, product-entitlement mappings, restore behavior, aliases, promotional grants, and webhook delivery health remain unverified.
- **Store behavior:** No purchases, refunds, chargebacks, upgrades, transfers, consumable restorations, or trial eligibility flows were exercised.
- **Pass metadata transport:** The plan does not establish the exact transaction-bound metadata mechanism. Its availability and semantics require verification before implementation.
- **Release binaries:** No APK or AAB was built or inspected. Final debuggability, merged components, R8 output, packaged assets, signing identity, and runtime logging remain unverified.
- **Secrets:** Environment variables, credential files, and key files were not accessed. This was not a complete repository-history secret scan.
- **Key-access documentation:** The requested main-checkout document was absent. I read the worktree copy only. Its stated key permissions were not checked.
- **Runtime authorization tests:** Firestore/Storage emulator tests, Flutter tests, and physical-device attack tests were not run. Local Node tests used Node 26.7.0, while the Functions package declares Node 20.
- **Deletion replay behavior:** The server requests consumed App Check tokens, but the client does not explicitly request limited-use tokens at `lib/core/auth/firebase_auth_functions_gateway.dart:16`. Verify retries and repeated deletion attempts against the selected SDK versions. [Firebase replay-protection setup](https://firebase.google.com/docs/app-check/cloud-functions)
- **Question reports:** L3 W4d Task 7 explicitly leaves the sender unimplemented. There is no report backend to assess. Before enabling it, enforce the stated limits server-side and bound report text.
- **iOS:** Purchase behavior and final platform hardening remain outside the verified Android-first scope.