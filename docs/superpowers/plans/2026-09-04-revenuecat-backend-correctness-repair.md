# RevenueCat Backend Correctness Repair Implementation Plan

> **For agentic workers:** Execute this plan inline in the assigned isolated worktree. Internal subagents are forbidden by the governing worker assignment. Every production behavior change follows RED -> GREEN TDD.

**Goal:** Correct the approved RevenueCat backend and identity-association defects RC-BE-01 through RC-BE-05 without changing the deferred dedupe/rate sequencing or global token-refresh architecture.

**Architecture:** Extract a narrow dependency-free RevenueCat policy/core module so signature, lifecycle, transfer, and claim-merge behavior can be executed directly in Node tests. Keep Firebase Functions adapters thin: the webhook preserves existing dedupe/rate ordering, while the claims adapter supplies Firebase Auth/Firestore dependencies and treats unresolved transfer identities as no-ops. On Flutter, add a process-lifetime RevenueCat/Auth binding around the existing `RevenueCatBootstrapper.associateUid` seam after anonymous Auth bootstrap.

**Tech Stack:** TypeScript/Node 20, Node `crypto` and `node:test`, Firebase Admin/Functions, Flutter/Dart, Riverpod.

**Spec:** Approved RC-BE-01..05 design and reconciliation recorded in `Aedwon/Pantas#21` and worker registry `Aedwon/chatgpt-terminal-relay#3505`.

## Global Constraints

- Base, `main`, and `beta/integration-r1` are frozen at `b642e2d169e0a03120d4f71cc6e10a6148cc5ef0` during this implementation.
- Only branch `web/pantas-rc-be-repair-r1` and worktree `Pantas-wt-rc-be-repair-r1` may be modified.
- Implement RC-BE-01 through RC-BE-05 only. RC-BE-F01 non-transactional dedupe/rate sequencing and RC-BE-F02 global token-refresh architecture remain untouched.
- Preserve payment authority, fail-soft startup, entitlement hydration/persistence retry, the five-minute stale-inactive rule, typed payment errors, SKU/pricing/paywall behavior, App Check, content/sync architecture, and unauthenticated purchase behavior.
- Never log or inspect secrets. No Google Play upload, PR, merge, main/beta ref movement, rebase, reset, or force-push.
- Do not use source-text regex assertions as the primary new regression proof.

---

### Task 1: Executable RevenueCat backend policy regressions

**Files:**
- Create: `functions/test/revenuecat-webhook.behavior.test.ts`
- Create after RED: `functions/src/revenuecatPolicy.ts`
- Modify after RED: `functions/src/revenuecatWebhook.ts`
- Modify after RED: `functions/src/revenuecatClaims.ts`
- Modify mechanically if needed: `functions/test/revenuecat-webhook.test.mjs`

**Interfaces:**
- `verifyRevenueCatSignature(rawBody, signatureHeader, secret): boolean` parses `t=<unix>,v1=<hex>` and verifies HMAC-SHA256 over `<t>.<exact raw bytes>` with constant-time comparison.
- `proTransitionForEvent(eventType): boolean | null` grants only INITIAL_PURCHASE/RENEWAL/TRANSFER_INCOMING, revokes only EXPIRATION/TRANSFER_OUTGOING, and returns null for CANCELLATION/UNCANCELLATION/BILLING_ISSUE/PRODUCT_CHANGE/unknown.
- `normalizeRevenueCatEvent(body)` preserves ordinary Firebase-associated identity and parses TRANSFER `transferred_from[]` / `transferred_to[]` with deterministic de-duplication.
- `isRevenueCatAnonymousId(uid): boolean` prevents `$RCAnonymousID:*` from reaching Firebase Admin.
- `mergeProClaim(existingClaims, pro)` preserves unrelated custom claims.
- `executeRevenueCatClaimTransition(input, dependencies)` makes no-op transitions side-effect free; unresolved transfer identities produce no claim write/transfer-loser marker; resolved outgoing identities revoke then mark the transfer loser; resolved incoming identities grant.

- [ ] Write executable Node behavior tests for valid/wrong-secret/altered-body/missing-malformed signature vectors and timestamp/signature parsing.
- [ ] Write lifecycle tests proving purchase -> cancellation remains Pro, billing/cancellation/product-change are no-ops, expiration revokes, renewal grants, and unknown/uncancellation do not independently change Pro.
- [ ] Write transfer tests for one-to-one arrays, repeated-ID de-duplication, mixed `$RCAnonymousID:*` and Firebase-like IDs, resolved outgoing loser marking only, unresolved outgoing safe no-op, and resolved incoming grant.
- [ ] Write custom-claim tests proving unrelated claims survive both grant and revoke.
- [ ] Run the focused behavior test through the repository-compatible ephemeral TypeScript runner and record the expected RED failure before creating/changing production source.
- [ ] Implement the minimum policy/helper and thin Firebase adapters to make the behavior tests GREEN while preserving the existing webhook event-id dedupe and rate-limit sequence.
- [ ] Re-run the focused behavior tests and record GREEN.

### Task 2: RevenueCat/Firebase Auth UID lifecycle binding

**Files:**
- Modify tests first: `test/features/paywall/application/revenuecat_bootstrap_test.dart`
- Modify after RED: `lib/features/paywall/application/revenuecat_bootstrap.dart`
- Modify only if required by existing exports: `lib/features/paywall/paywall.dart`

**Interfaces:**
- `RevenueCatAuthBinding` owns a process-lifetime `StreamSubscription<AuthState>`.
- `start(initialState, changes)` awaits association of the already-established initial Firebase UID, then listens for future auth-state UIDs.
- `RevenueCatBootstrapper.associateUid` remains the fail-soft/deduplicating primitive; failed association leaves the UID retryable.
- `bootstrapRevenueCat(container)` configures RevenueCat, obtains the post-Auth-bootstrap initial Auth state, associates it before app interaction, then keeps future UID changes bound for the container/process lifetime.

- [ ] Add tests for initial anonymous UID association, same UID not re-login, later UID change, and initial association failure followed by retry.
- [ ] Run the focused Dart test and record the expected RED before production edits.
- [ ] Implement the smallest binding around existing Auth and RevenueCat providers; do not require sign-in or redesign Auth.
- [ ] Re-run focused RevenueCat bootstrap/identity tests and directly affected app bootstrap tests to GREEN.

### Task 3: Verification, hygiene, and handback

**Files:**
- Modify documentation/checkpoint only if needed to keep the signed-webhook setup contract accurate.

- [ ] Run focused new backend behavior tests.
- [ ] Run full `functions` `npm test`.
- [ ] Run TypeScript compile/noEmit using the repository-established ephemeral dependency pattern if dependencies are not installed.
- [ ] Run focused Dart RevenueCat bootstrap/identity-binding tests and directly affected app bootstrap tests.
- [ ] Run formatter checks on changed Dart/TS/JS and analyzer on the changed Dart surface.
- [ ] Run `git diff --check`.
- [ ] Run `dart run tool/check_no_ai_attribution.dart`.
- [ ] Confirm RC-BE-F01 and RC-BE-F02 remain untouched by diff review.
- [ ] Commit only scoped files, normal-push `web/pantas-rc-be-repair-r1`, and re-read the remote branch SHA.
- [ ] Re-read frozen `main` and `beta/integration-r1`; both must still equal the base SHA.
- [ ] Publish one canonical `completed` registry event containing exact commit/head/files, RED and GREEN evidence, all verification commands/results, deferred-debt confirmation, frozen-ref readback, and remaining release/configuration caveats.
