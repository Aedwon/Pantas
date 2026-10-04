# Spec 7 — Paywall + RevenueCat + entitlement gate (design)

> **Pricing superseded (4 October 2026).** Prices, plans, and products in this file are historical. The only current prices are in `docs/pricing.md`. Do not quote or implement a price from this file.

**Status:** Brainstormed (2026-05-21).
**Depends on:** Spec 1 (Firebase Auth, Cloud Functions, Firestore), Spec 2 (Sanity content fetcher — needs server-gated paths for Pro content), Spec 3 (`SyncCoordinator` for `welcomedAt` flag; Firestore security rules), Spec 5 (Onboarding — amended to gather notification permission), Spec 6 (Study Plan — Pro depth surfaces are the primary paywall trigger source).
**Soft dependency:** Spec 9 (Notifications) — Spec 7 schedules a local trial-end notification through the permission already granted in onboarding.
**Marketing pillar:** This is monetization without churn. The paywall is a coach's offer, not a sales funnel. Pricing transparency, contextual recommendation, and quiet competence at every failure mode are the design constants.

## 1. Overview

Spec 7 adds the paywall, the RevenueCat purchase pipeline, and the entitlement gate that controls Pro-tier access across the app. Four SKUs (Weekly ₱29 / Monthly ₱99 / Yearly ₱499 with a 7-day free trial / Lifetime ₱1,499) are sold through Google Play with RevenueCat as the entitlement infrastructure. A Cloud Function webhook receives RevenueCat events and writes a Firebase custom claim (`pro=true`). A Riverpod `entitlementProvider` reads RevenueCat's locally-cached `CustomerInfo` (optimistic, network-tolerant) and exposes `proIsActive` to the rest of the app. Pro-gated content paths in Sanity are fetched through a Cloud Function proxy that verifies the custom claim server-side. Anonymous purchases are allowed; sign-in nudges live on study-progress milestones, not on the purchase moment. The paywall recommends a SKU contextually based on the user's exam date, not a flat "Yearly is best" pitch — Weekly is recommended for exam ≤21 days out, Monthly up to 5 months, Yearly for 5–24 months or no date set, Lifetime is never auto-recommended.

## 2. In scope / non-goals

**In scope:**

- RevenueCat SDK integration (Android API key via `--dart-define`).
- Four SKUs configured in Google Play: Weekly, Monthly, Yearly (with 7-day free trial), Lifetime.
- Cloud Function webhook (`asia-southeast1`) with RevenueCat shared-secret signature verification.
- Firebase custom claim management: `pro=true` set/cleared on RevenueCat events.
- `entitlementProvider` (Riverpod) reading RevenueCat `CustomerInfo` cache.
- Server-side verification of Pro custom claim on every Pro-gated read.
- Pro-only Sanity content fetched via Cloud Function proxy (server-gated GROQ).
- Firestore security rules enforcing `request.auth.token.pro == true` on Pro-gated paths. Rule tests in CI.
- Pro-route redirect in `router.dart` (Pro-only route hit by Free user → paywall, not 404).
- Single-screen paywall: 4 SKU cards vertical stack, stable order Weekly → Monthly → Yearly → Lifetime, dynamic emphasis on recommended card based on exam date.
- "See all of Pro" expand affordance for full feature list.
- Restore Purchases button on paywall + in Settings.
- Anonymous purchase flow (no sign-in interruption).
- Sign-in nudges on study-progress milestones (first mock completion, 3-day streak, new-device open).
- Transfer-loser notification on Pro entitlement transfer.
- Trial reminder: in-app banner from day 5 of trial + local push notification 24h before charge.
- Network failure handling: optimistic cache + post-recovery welcome banner + paywall sheet-error fallback.
- Settings subscription status panel + Play deep-link for management.
- QA: Play Internal Testing track + license testers; `FAKE_PRO` debug flag with CI build-time defense.
- Delight: one-time "Welcome to Pro" banner on Free→Pro transition.

**Non-goals (deferred or explicitly not building):**

- iOS paywall / StoreKit / App Store Connect. Android-only at launch.
- Promotional offers / discount campaigns. Defer to v1.1 pending launch-week data.
- Per-track Pro pricing (CSE-only vs UPCAT-only). Single Pro unlocks all tracks.
- In-app plan change / upgrade flows. All plan changes deep-link to Google Play.
- Server-driven push for re-engagement (e.g., "trial ending in 3 days" before day 6). Defer to Spec 9.
- Family-sharing, gifting, or referral mechanics.
- Sandbox RevenueCat project separate from production. Tagging within one project is sufficient.
- App Check enforcement (deferred to v1.1).
- Certificate pinning (HTTPS defaults sufficient for v1).
- Content scraping defenses, screenshot/OCR blocks.
- Anti-cheat for leaderboards (no leaderboards in v1).
- Email-channel trial reminders. Google Play already sends its automatic trial-ending email.

## 3. Locked decisions

| # | Question | Decision |
|---|---|---|
| D1 | Paywall trigger surfaces | Lightweight inline nudges (C-pattern) as default. Preview-then-paywall (B-pattern) reserved for post-mock-exam result. No modal-on-every-Pro-tap. |
| D2 | Free-trial offer timing | Contextual only (Pro depth taps). Single soft mention at end of onboarding plan-set celebration. No unsolicited trial offers. |
| D3 | Anonymous purchase | Allowed. No sign-in interruption. Post-purchase = warm welcome only. Sign-in nudges live on study-progress milestones, not the purchase moment. |
| D4 | Entitlement-check-fails UX | Optimistic. Trust RevenueCat cache. Background refresh corrects on next successful network. |
| D5 | Pro sharing abuse | Surface-transfer notification + telemetry. No friction defenses in v1. |
| D6 | Paywall screen UI | Single-screen modal. Vertical stack, stable order Weekly → Monthly → Yearly → Lifetime. Dynamic emphasis on recommended card (badge + accent border + default selection). "7 days free" pill always lives on Yearly. CTA copy reflects selected card. |
| D7 | Promo offers | None in v1. Defer to v1.1 pending data. |
| D8 | Pro entitlement scope | Single Pro = all tracks unlocked. One custom claim, track-agnostic. |
| D9 | Settings → Subscription surface | In-app status panel + Play deep-link for management. Restore Purchases visible. |
| D10 | Trial reminder mechanics | In-app banner from day 5 + local push notification 24h before charge. Permission granted via onboarding daily-reminder setup. Google Play's automatic trial-end email is the third channel (free). |
| D11 | Network failure recovery | Trust Play + RevenueCat platform recovery. Post-recovery welcome banner on next app open. Paywall sheet-error fallback for offline-before-purchase. |
| D12 | QA / test purchases | Play license testers (Internal Testing track) + `FAKE_PRO` debug flag with CI build-time defense ensuring flag cannot exist in release builds. |
| D13 | Delight moment | One-time "Welcome to Pro" banner on Free→Pro transition. Coach-aligned, not transaction-aligned. |
| S1 | Webhook signature verification | Required. RevenueCat shared secret. Reject unsigned/invalid events. |
| S2 | Server-side Pro claim verification | Required on every Pro-gated read. No client-side-only checks. |
| S3 | Pro-only Sanity content gating | Required via Cloud Function proxy or server-gated GROQ (forces Spec 2 amendment). |
| S4 | Firestore security rules | `request.auth.token.pro == true` for Pro-gated paths. Rule tests in CI. |
| S5 | Webhook rate limiting | Cloud Function per-UID rate limit on webhook acks. Idempotent handler via event ID dedup. |

### 3.x Notes on rationale

- **D1** prevents the paywall from becoming a hostile interruption. Inline nudges in-context (e.g., on a "See more →" expand affordance) preserve flow; only the post-mock-exam moment justifies a preview-then-paywall because the user is at peak motivation.
- **D2** keeps the trial off the user's face. The only proactive surface is the onboarding plan-set celebration, where the user has just experienced their plan and a soft "Pro shows it at subtopic depth — free for 7 days" is informational, not pushy.
- **D3** + **D9** + **D11** together implement the "monetization without churn" principle: no sign-in friction at purchase, durable restoration, quiet competence at recovery, and an honest in-app status panel.
- **D6** + **D8** keep the paywall mental model simple: one Pro, three durations, recommended duration adapts to your exam date. No track-selector, no promo-stacking complexity.
- **D10** is the highest-stakes UX in the spec. The trial-end charge must never be a surprise. Three independent channels (in-app banner + local push + Play's automatic email) cover every reachable user without our needing to engineer email infrastructure.
- **D11** trusts the platform because the platform is good at this. A custom "Confirming your purchase..." screen would add a timeout we have to tune and a screen the user must wait through to solve a problem RevenueCat + Play already solve.
- **D13** restraint: the paywall does its job and gets out of the way. The welcome banner is the *one* moment Spec 7 is allowed to be visually richer than the surrounding UI.
- **S1–S5** are non-negotiable. Client-side-only entitlement enforcement is the single largest abuse vector for any freemium app. Server-side verification on every Pro-gated read is the foundation that lets `FAKE_PRO` exist as a debug-only flag without introducing a real abuse vector (S3 means even a tampered client can't fetch Pro content).

## 4. SKU configuration

Four Google Play Billing SKUs, configured in the Play Console (Weekly added by the 2026-07-18 amendment, `2026-07-18-weekly-sku-pricing-amendment-design.md`):

| SKU ID | Type | Price (PHP) | Trial | Notes |
|---|---|---|---|---|
| `pro_weekly` | Subscription (P1W) | ₱29 / week | None | Auto-renewing; enable Play grace period |
| `pro_monthly` | Subscription | ₱99 / month | None | Auto-renewing |
| `pro_yearly` | Subscription | ₱499 / year | 7 days free | Auto-renewing post-trial |
| `pro_lifetime` | One-time | ₱1,499 | None | Non-consumable |

RevenueCat product mapping: all four map to a single entitlement, `pro`. Locale-aware prices read via `priceString` from RevenueCat `Offerings.current.availablePackages`.

The 7-day trial is configured as a Google Play introductory price on `pro_yearly`. Eligibility is per-Play-account (Google enforces single-trial-per-account).

## 5. Paywall screen (UI)

**Layout:** single-screen modal / full-sheet. Closes on backdrop tap or close button. No multi-step flow.

**Structure (top to bottom):**

1. Top bar: close button (left), "Restore" link (right).
2. Title: "Try Pro".
3. Pitch line (one sentence, contextual — see §6).
4. Three-bullet feature teaser (plain language, see copy register §10).
5. "See all of Pro →" expand link.
6. Four SKU cards, stable order Weekly → Monthly → Yearly → Lifetime.
7. Primary CTA (full-width, reflects selected card).
8. Fine print (one line).

**SKU card contents:**

| Card | Always shows | When recommended |
|---|---|---|
| Weekly | "Weekly — ₱29/wk · ≈₱126/mo · Renews every week · Cancel anytime" | "Best for your exam date" badge + accent border + default selection |
| Monthly | "Monthly — ₱99/mo · Cancel anytime" | "Best for your exam date" badge + accent border + default selection |
| Yearly | "Yearly · 7 DAYS FREE pill · ₱499/yr · ₱42/mo · *contextual sub*" | Same badge treatment |
| Lifetime | "Lifetime — ₱1,499 · Pay once · yours forever" | Never auto-recommended |

**Recommended card visual treatment:** accent green border (2px), `#f0fdf4` background tint, "Best for your exam date" badge top-left positioned over the border, default-selected state.

**CTA copy by selected card:**
- Weekly selected → "Get Pro — ₱29/week"
- Monthly selected → "Get Pro — ₱99/month"
- Yearly selected → "Start 7-day free trial"
- Lifetime selected → "Get Pro — ₱1,499 one-time"

**Fine print:** "Paid through Google Play." When Yearly trial is selected: "Then ₱499/year. Paid through Google Play."

Reference mockup: `.superpowers/brainstorm/58970-1779115547/content/paywall-mockup-v3.html` (three side-by-side scenarios — crammer, long-haul, no-date-set).

## 6. Contextual SKU recommendation

The paywall reads the time until the user's onboarding-provided exam date (Spec 5) — days for the Weekly bucket, whole months beyond that — and applies emphasis to the matching SKU card:

| Time until exam | Recommended | Badge copy |
|---|---|---|
| ≤ 21 days | Weekly | "Best for your exam date" |
| 22 days – 5 months | Monthly | "Best for your exam date" |
| 5 – 24 | Yearly | "Best for your exam date" |
| > 24 | Yearly | "Best for your exam date" |
| No date set | Yearly | "Best value for most" |
| Date in the past | Treat as no-date until user updates | "Best value for most" |

**Pitch line by state:**
- Date set: "Built around your [exam track] on [Month Day]."
- No date set: "Add your exam date in Settings for a plan tuned to your timeline."

**Default selection** always matches the recommended card. User can tap any card to switch — CTA copy updates accordingly.

**Why the Weekly window ends at 21 days:** three weekly renewals cost ₱87; four cost ₱116. Past three weeks, Monthly is the cheaper honest pick.

**Why never auto-recommend Lifetime:** lifetime is rarely the cheapest-by-math option (only justifies itself for multi-year, multi-exam users). Auto-recommending it would prioritize revenue-per-purchase over coach honesty.

## 7. Paywall trigger surfaces

**Default trigger (C-pattern, inline nudge):**

When a Free user taps a Pro-depth affordance (e.g., "See more →" on a topic breakdown), the affordance transforms in place into an upgrade chip:

> *"Pro shows you the full breakdown — Try Pro free →"*

Tapping the chip opens the paywall sheet. No modal interruption mid-action.

**Strong-signal trigger (B-pattern, preview-then-paywall):**

Reserved for **post-mock-exam result**. After completing a mock exam, the user sees a brief preview of the dossier (Pro depth) before the upgrade prompt slides up:

> *"This is what Pro shows after every mock. Try Pro free →"*

This is the only place a stronger nudge fires unsolicited. Justification: the user is at peak motivation; the dossier preview is the artifact they care about; the prompt is contextual to what they just did.

**Soft mention (one-time, onboarding):**

End of onboarding plan-set celebration shows once:

> *"Your plan is ready. Pro shows it at subtopic depth — free for 7 days [Learn more →] [Got it]"*

Dismissible. Never re-appears.

**Never-paywall:**
- No always-route-to-paywall.
- No paywall on launch / cold start.
- No paywall on streak loss / failure moments (regression-paywalling forbidden).
- No paywall on a tap-out from a Pro feature the user previously had via lapsed trial.

## 8. Entitlement architecture

### 8.1 Data flow

```
User → Paywall → Play Billing → RevenueCat (receipt verification)
                                       ↓
                                  RevenueCat dashboard
                                       ↓
                          Webhook (signed, async)
                                       ↓
                  Cloud Function (asia-southeast1)
                                       ↓
                          Firebase Auth custom claim: pro=true
                                       ↓
                  Client refreshes ID token on next request
                                       ↓
                  Pro-gated content/queries succeed server-side
```

### 8.2 `entitlementProvider` (client side)

```dart
final entitlementProvider = StreamProvider<Entitlement>((ref) {
  // Listens to RevenueCat's customerInfoUpdated stream.
  // Reads CustomerInfo from local cache for optimistic state.
  // Exposes proIsActive: bool, activeSku: ProductId?, expirationDate: DateTime?
});
```

**Optimistic-cache rule (D4):** if RevenueCat's local `CustomerInfo` cache says Pro, treat as Pro. If cache says Free or no cache, treat as Free. Background refresh corrects on next successful network.

**Welcome-banner trigger:** when entitlement transitions Free → Pro between session, fire the one-time welcome banner (§11). Tracked via `welcomedAt` Firestore flag set on first welcome shown.

### 8.3 Cloud Function webhook

**Endpoint:** `https://asia-southeast1-<project>.cloudfunctions.net/revenuecatWebhook`

**Verification:** RevenueCat shared-secret HMAC signature on the `Authorization` header. Reject any unsigned or invalid-signature request with 401. Secret stored in Cloud Function environment config (`firebase functions:config:set`).

**Handler behavior:**
- Idempotent: dedup by RevenueCat event ID stored in `/webhookEvents/{eventId}` Firestore. Duplicate event → return 200 without re-processing.
- Per-UID rate limit: max 30 webhook acks per minute per UID (using a Firestore counter window). Excess → 429, RevenueCat retries.
- On `INITIAL_PURCHASE`, `RENEWAL`, `PRODUCT_CHANGE`, `TRANSFER` (incoming) → set `pro=true` custom claim.
- On `CANCELLATION`, `EXPIRATION`, `TRANSFER` (outgoing) → clear `pro` claim, increment ID-token revocation timestamp.
- On `TRANSFER` (outgoing) → write `/transferLoser/{uid}` flag, queue in-app notification to display on next session.
- Log every event to `/webhookLog/{eventId}` with timestamps for v1.1 analysis.

### 8.4 Server-side enforcement

**Firestore rules** (excerpt):
```javascript
// Pro-gated paths
match /users/{uid}/proDossiers/{dossierId} {
  allow read: if request.auth.uid == uid && request.auth.token.pro == true;
}
match /examTracks/{trackId}/proContent/{contentId} {
  allow read: if request.auth.token.pro == true;
}
```

Rule tests in CI: rules-unit-testing suite verifies free-user reads to Pro paths are denied; Pro-user reads succeed. Failing rule tests block merge.

**Cloud Function content proxy** (Sanity Pro paths):
- Pro-tagged Sanity content fetched only via `getProContent` Cloud Function.
- Function verifies `request.auth.token.pro == true` before issuing the GROQ query.
- Forces Spec 2 amendment: see §13.

### 8.5 Router gating

`router.dart` Pro-only routes (e.g., `/plan/dossier/<mockId>`) check `entitlementProvider.proIsActive` in a redirect guard. Free user hitting a Pro route → redirected to paywall with the source route stashed as the post-purchase return target.

## 9. Anonymous purchase + sign-in nudges

### 9.1 Purchase flow

1. User taps a paywall CTA.
2. Play Billing sheet opens directly. No sign-in interruption.
3. RevenueCat associates the entitlement with the current Firebase UID (anonymous or signed-in — both work).
4. On successful purchase: warm welcome banner (§11). No sign-in pitch.

### 9.2 Sign-in nudges (decoupled from purchase)

Sign-in is pitched only when the user has tangible artifacts to lose, with the value prop framed as **study data portability** (not Pro durability — Pro lives on the Play account):

| Trigger | Nudge copy |
|---|---|
| After first mock-exam completion | "Sign in to save your study progress across devices." |
| After 3-day streak | "Sign in to keep your streak safe across devices." |
| App opened on a new device (anon UID differs) | "Sign in to find your study progress on this device." |

All nudges are dismissible. None gate functionality. Pro access is independent of sign-in.

### 9.3 Restore Purchases

Required visible affordances:
- Paywall top-right "Restore" link.
- Settings → Subscription row.
- New-device sign-in nudge surface ("Already a Pro? Restore →").

`Purchases.restoreTransactions()` triggers a RevenueCat refresh; the webhook re-asserts the custom claim if entitlement is found.

## 10. Trial reminder mechanics

### 10.1 Channels

| Channel | Source | Reachable users |
|---|---|---|
| In-app banner | App-side, scheduled by trial start date | Users who open the app |
| Local push notification | App-side, scheduled when trial starts | Users who granted notification permission |
| Google Play automatic email | Play, no work from us | Users with verified Play account email |

### 10.2 Banner

Shown on Home + Settings from day 5 of the trial onward, until conversion or cancellation.

> *Pro trial ends in [N] days — ₱499 will be charged on [Month Day].*
> *No action needed to keep Pro · Cancel in Settings →*

Dismissible per session. Reappears next session until trial state resolves.

### 10.3 Local push

Scheduled at trial-start for `trialEndDate - 24h`. Body:

> Title: *Pro trial ends tomorrow*
> Body: *₱499 will be charged on [Month Day]. Tap to manage.*

If the trial is cancelled or converts before day 6, the scheduled notification is cancelled on the next `customerInfoUpdated` event.

### 10.4 Permission acquisition

Notification permission is acquired during **onboarding's daily-reminder setup step** (cross-spec amendment, §13). The trial-end push piggybacks on the already-granted permission. If the user skipped the onboarding reminder step or denied permission, the trial-end push silently no-ops; the in-app banner remains the safety net.

## 11. Network failure + recovery

### 11.1 Failure modes and behavior

| Failure | Behavior |
|---|---|
| Paywall sheet can't open (offline) | Inline error: "Couldn't reach Google Play. Check your connection and try again." Paywall stays open. |
| User taps Buy, network drops before Play takes payment | Play handles error; user can retry. No app-side state change. |
| Purchase completes, network drops before RevenueCat acks | On next session, RevenueCat refresh sees the entitlement, app flips to Pro, welcome banner fires. |
| RevenueCat acks, webhook fails (e.g., 5xx) | RevenueCat retries automatically. Idempotent handler dedups. Custom claim eventually consistent. |
| App killed mid-purchase | Same as above — next session resolves. |
| User on a different device after purchase | Restore Purchases triggers RevenueCat re-association. |

### 11.2 Welcome banner

Fires on next app open after entitlement transitions Free → Pro. Suppressed permanently after first dismiss via Firestore `welcomedAt` flag.

> **You're in.**
> *Pro adjusts your plan based on what you actually struggle with. Let's get to it.*
> [Take me to today's plan →]

CTA routes to Today's Session. Banner auto-dismisses on first plan interaction.

## 12. Settings → Subscription panel

In-app status panel. Operations deep-link to Google Play.

| State | Panel content | Actions visible |
|---|---|---|
| Free | "You're on Free." | Try Pro · Restore Purchases |
| Pro Weekly | "Pro · Weekly · renews [date] · ₱29" | Manage in Google Play · Restore Purchases |
| Pro Monthly | "Pro · Monthly · renews [date] · ₱99" | Manage in Google Play · Restore Purchases |
| Pro in 7-day trial | "Pro trial · [N] days left · then ₱499/year on [date]" | Manage in Google Play · Restore Purchases |
| Pro Yearly (post-trial) | "Pro · Yearly · renews [date] · ₱499" | Manage in Google Play · Restore Purchases |
| Pro Lifetime | "Pro · Lifetime · yours forever." | Restore Purchases |
| Pro cancelled but not yet expired | "Pro · Monthly · ends [date] (won't renew)" | Re-enable in Google Play · Restore Purchases |

Plain copy ("renews," "ends," "yours forever") — no "auto-renews," "expires," "non-consumable."

## 13. Security defenses

### Tier 1 (must address in Spec 7)

1. **Webhook signature verification** (S1): HMAC-shared-secret on every RevenueCat → Cloud Function call. Reject unsigned/invalid.
2. **Server-side custom-claim verification** (S2): every Pro-gated read goes through Firestore rules or Cloud Function gates that check `request.auth.token.pro == true`. No client-side-only enforcement.
3. **Pro-only Sanity content via Cloud Function proxy** (S3): forces **Spec 2 amendment** — see §13.

### Tier 2 (simple measures)

4. **Firestore security rules** (S4): `request.auth.token.pro == true` on Pro-gated paths. Rule tests in CI.
5. **Per-UID rate limiting** (S5): Cloud Function caps webhook acks per UID per minute. Idempotent handler via event-ID dedup.
6. **Firebase built-in anti-abuse** for anonymous auth. App Check deferred to v1.1.

### Tier 3+ (out of scope or deferred)

- Content scraping defenses (OCR/screenshot blocks): none, industry-tolerated.
- Mastery-state self-tampering: not defended; user only hurts themselves.
- Certificate pinning: deferred. HTTPS defaults sufficient.
- Anti-cheat for leaderboards: N/A in v1.
- App Check: deferred to v1.1.

### `FAKE_PRO` debug flag — abuse-vector analysis

The debug flag (§14) is safe **only because** Tier 1 server-side enforcement (S2 + S3) is in place. A tampered or debug-built client with `FAKE_PRO=true` can only flip local UI chrome — the actual Pro content (Sanity Pro paths, Firestore Pro paths) requires the real custom claim. Without it, the user sees unlocked-looking UI with empty/error states everywhere content actually lives.

Defense in depth: a CI build-time check that ensures `FAKE_PRO` cannot exist in a release build. Implementation: the `FAKE_PRO` codepath is compile-conditional (e.g., `if (kDebugMode && const bool.fromEnvironment('FAKE_PRO'))`), and a CI step greps the assembled release APK for the `FAKE_PRO` symbol; presence fails the build.

## 14. Testing / QA

### 14.1 Play license testers

- Internal Testing track configured in Play Console.
- License tester list (capped at ~5 internal addresses, audited quarterly): `aerol.balayon@gmail.com`, plus selected internal QA accounts.
- License-tester purchases run the full pipeline (Play → RevenueCat → webhook → custom claim) at ₱0 cost with rapid renewal cycles (monthly = 5 min, yearly = 1 day).

### 14.2 `FAKE_PRO` debug flag

- Invocation: `flutter run --dart-define=FAKE_PRO=true`.
- Effect: `entitlementProvider` returns Pro state in debug builds only.
- Guard: compile-conditional on `kDebugMode` + `const bool.fromEnvironment('FAKE_PRO')`. Release builds compile the codepath out entirely.
- CI defense: release-APK symbol scan fails the build if `FAKE_PRO` is reachable.

### 14.3 Pre-release QA scenarios (must pass)

1. Monthly purchase end-to-end → custom claim set within 10s → Pro UI unlocks. Repeat for Weekly (rapid renewal cycle: weekly = 5 min); verify grace period on a failed weekly renewal.
2. Yearly purchase with trial → no charge → custom claim set → trial countdown banner appears day 5.
3. Trial converts (rapid cycle) → ₱499 charged → custom claim persists.
4. Trial cancelled mid-trial → access remains until trial ends → claim clears at expiration.
5. Lifetime purchase → custom claim set → Settings shows "yours forever."
6. Restore Purchases on fresh install → claim re-set.
7. Cross-device: purchase on device A → install on device B → restore → claim set on B.
8. Entitlement transfer (license-tester scenario): purchase on account A → Restore Purchases on account B → transfer notification fires for A on next open.
9. Network drop mid-purchase → recovery on next session → welcome banner fires once only.
10. Firestore rule test: free-user read to Pro path returns permission denied.
11. Cloud Function test: invalid webhook signature → 401, no claim change.

### 14.4 Analytics filter

Production RevenueCat dashboard analytics filter excludes license-tester user IDs to keep conversion metrics clean.

## 15. Delight moment

**Welcome to Pro banner** (D13). One-time, fires on Free→Pro transition.

**Visual:** card with subtle accent-green gradient, matching the paywall's "Best for your exam date" badge color. Slightly richer than ordinary banners — one moment that's allowed to be a little nicer.

**Copy:**
> **You're in.**
> *Pro adjusts your plan based on what you actually struggle with. Let's get to it.*
> [Take me to today's plan →]

**Behavior:**
- Triggered by `entitlementProvider` Free→Pro transition observed at session start.
- Suppressed permanently after first dismiss (Firestore `welcomedAt` flag, written via SyncCoordinator per Spec 3).
- Auto-dismisses on first interaction with the Today's Session card.
- Coach voice: warm, grounded, no exuberance. No confetti, no fanfare animation.

**Anti-delight (not built):**
- No celebration of *the act of paying*.
- No celebration of trial conversion (the charge).
- No fanfare in Settings.

## 16. Cross-spec amendments

### Spec 5 — Onboarding (amendment)

- **Add a "Pick your daily study reminder time" step** to onboarding. Time picker + days-of-week chips. Single CTA: "Set my reminder."
- **Notification permission ask** fires when the user confirms the reminder. Currently the onboarding doc states this lives in `features/notifications/` (line 35); revise to: onboarding gathers it through the reminder step; `features/notifications/` owns scheduling and re-request flows.
- **Skippable.** If user skips, Spec 7 trial-end push silently no-ops; in-app banner remains the safety net.
- **Spec 9 implication**: the open roadmap question ("Notification reminder time picker lives in Settings or Notifications spec?") resolves as: **onboarding for initial setup, Settings for later editing**. Both surfaces persist to the same Firestore prefs.

### Spec 2 — Sanity content fetcher (amendment)

- **Pro-tagged Sanity content paths must be fetched via a Cloud Function proxy** (or server-gated GROQ), never directly from a Free client.
- Add a `pro` boolean tag to Sanity schemas for content gated to Pro. Free-tagged content remains client-fetched.
- Cloud Function `getProContent` verifies `request.auth.token.pro == true` before issuing the GROQ query.

### Spec 3 — User data sync (confirmation)

- Firestore security rules scaffolding accommodates the `pro` custom claim. The `welcomedAt` flag is written via the SyncCoordinator under `/users/{uid}/profile/welcomedAt`.

### Spec 9 — Notifications (forward dependency)

- Permission acquisition moves to onboarding (above).
- Local notification scheduling, FCM token registration, daily review reminders remain in Spec 9.
- Trial-end push is scheduled by Spec 7 code paths, using the permission Spec 5 onboarding obtained.

## 17. Open questions for future specs

- **v1.1 promotional offers:** which trigger conditions warrant a discount (post-fail re-engagement, board-exam-week promo, abandoned-paywall remarketing)?
- **Family-sharing equivalent:** if Google Play Family Sharing for subscriptions is requested by users, how do we handle multi-UID-per-Play-account?
- **Premium tier:** when high-value specialty exams (Bar, NMAT-Med) are added in v2, do we introduce a separate "Premium" tier above Pro, or stretch Pro pricing?
- **Anonymized purchase analytics → partner pitches:** see `docs/future/post-launch-revenue-and-telemetry.md` for the broader telemetry foundation needed before B2B / sponsorship outreach.

## 18. Risks

| Risk | Mitigation |
|---|---|
| RevenueCat outage breaks paywall purchases | Optimistic-cache + Restore Purchases lets existing Pro users keep access. New purchases fail visibly with clear error copy. |
| Webhook never lands (loss in transit) | RevenueCat client SDK refreshes `CustomerInfo` on every app open, surfacing the entitlement even without webhook. Custom claim catches up on next user request (Firestore rules read the refreshed claim within ~1 hour token lifetime). |
| User charged but claim never set | Manual recovery via Restore Purchases + support escalation (`OPERATIONS.md` runbook to be added in Spec 10). |
| Play account shared, friend gets free Pro | Surface-transfer notification + telemetry per D5. Friction defenses deferred to v1.1 data review. |
| Currency exchange shows wrong price (non-PH user) | RevenueCat `priceString` shows Play-localized price. Acceptable; PH targeting still primary. |
| Notification permission denied → trial-end push fails | In-app banner from day 5 + Play's automatic email = safety net. Trial-end charge is never a surprise even without push. |
| Webhook signature secret leaks | Rotate via Firebase Functions config + RevenueCat dashboard. Old secret rejected within minutes. |
| `FAKE_PRO` flag accidentally shipped | CI release-APK symbol scan blocks the build. Server-side enforcement (S2 + S3) means even if shipped, it can only flip local UI chrome. |

## 19. Tests

- **Webhook signature verification** unit tests: valid signature → process; invalid → 401; missing → 401.
- **Webhook idempotency** test: same event ID delivered twice → claim set once, second delivery is a no-op.
- **Custom claim transitions** integration test: purchase event → claim true; cancellation event → claim false within the same test run.
- **Firestore rules tests** (CI-required): free user denied on Pro paths; Pro user allowed; failing rule fails the merge.
- **Optimistic-cache widget test:** Pro user offline → Pro UI renders; Free user offline → Free UI renders.
- **Paywall recommendation logic:** unit tests for each `monthsUntilExam` bucket (<5, 5-24, >24, null, past date).
- **CTA copy tests:** Monthly selected → CTA reads "Get Pro — ₱99/month"; Yearly → "Start 7-day free trial"; Lifetime → "Get Pro — ₱1,499 one-time".
- **Welcome banner tests:** Free→Pro transition fires banner once; second session does not re-fire; `welcomedAt` flag persisted.
- **Restore flow integration test:** fresh install + license-tester account → restore → Pro UI active.
- **Trial reminder scheduling tests:** local notification scheduled at trial-start; cancelled when trial-end event fires early; no-ops without permission.
- **Router redirect test:** Free user navigating to Pro-only route → redirected to paywall; post-purchase returns to the original route.
- **CI release-APK scan:** assembled release APK contains no `FAKE_PRO` symbol.

---

**Cross-spec links:**
- Spec 1 — Cloud Functions runtime, Firebase Auth custom claims, Firestore rules baseline.
- Spec 2 — must add Pro content gating via Cloud Function proxy (§16).
- Spec 3 — `welcomedAt` flag synced; security rules accommodate `pro` claim.
- Spec 5 — Onboarding adds reminder-time step (§16). Mock-exam result drives the strongest paywall trigger (§7).
- Spec 6 — Pro depth surfaces are the primary inline-nudge source. `entitlementProvider.proIsActive` controls Pro depth rendering throughout the plan.
- Spec 9 — owns notification permission flow infrastructure (re-request, settings toggle); Spec 7 schedules a local notification through the permission Spec 5 onboarding acquired.
