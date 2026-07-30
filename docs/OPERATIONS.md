# Operations status tracker

Tracks long-pole external dependencies and one-time manual configuration. Owner: Aerol Balayon.

Last updated: 2026-05-07

## Day-1 procedural items (Phase A of Plan 1)

| # | Item | Status | Started | Expected complete | Notes |
|---|---|---|---|---|---|
| 1 | NPC registration filed | [ ] | 2026-05-07 | 2026-06-25 (latest) | Reference number: TBD; follow-ups 2026-05-21, 2026-06-04, 2026-06-18 |
| 2 | Apple Developer Program | [ ] | 2026-05-07 | 2026-05-09 | Team ID: TBD |
| 3 | Google Play Console | [ ] | 2026-05-07 | 2026-05-10 | Account ID: TBD |
| 4 | Pentester engaged for week 6 | [ ] | 2026-05-07 | 2026-05-12 (signed) | Vendor: TBD; window: 2026-06-11 to 2026-06-17 |

## Vendor reference info

### Firebase

- Dev project: `cse-cet-reviewer-dev` (number: TBD)
- Prod project: `cse-cet-reviewer-prod` (number: TBD)
- Region: `asia-southeast1` (Singapore)
- Blaze plan enabled on both, $10/mo budget alert configured
- Hosting placeholder URLs:
  - Dev:  https://cse-cet-reviewer-dev.web.app
  - Prod: https://cse-cet-reviewer-prod.web.app

#### User-data sync setup

- [ ] Deploy Firestore owner rules: `firebase deploy --only firestore:rules`
  and confirm the deployed ruleset matches `firestore.rules`.
- [ ] Deploy the reset callable:
  `firebase deploy --only functions:resetCloudUserData`.
- [ ] Validate App Check enforcement for Firestore and Functions in dev and
  prod after debug tokens and Play Integrity are registered.
- [ ] Run one real-device sync verification before release: create local
  progress, sign in, choose "keep this device", reinstall, sign in again,
  choose "keep my account", and confirm progress restores.
- [ ] Confirm `content.db` remains out of user-data sync scope. It is
  regenerable Sanity content; only `app.db` user-data rows sync to Firestore.

### Sanity

- Project ID: TBD
- Datasets: `production` (dev plan also uses this for v0; isolated `staging` ds added in Plan 4)
- 2FA enforced at org level: [ ] confirm
- API token (read-only, dev): stored in 1Password under "CSE/CET Reviewer — Sanity Dev"

### RevenueCat

**Corrected 11 August 2026.** This section listed a lifetime product and the old
app name. **Do not create products from the old list.** Full setup, in order, is
`docs/revenuecat-setup.md`.

- Project: Pantas
- Entitlement: `pro`
- Products: `pantas_pro_weekly`, `pantas_pro_monthly`, `pantas_pro_yearly`
- **No lifetime product**, removed by decision on 3 August 2026. A Play product ID
  cannot be deleted once used, so creating one would be permanent.
- Prices: ₱29 weekly, ₱99 monthly, **₱799 yearly**, lowered from ₱999 on 11 August 2026
- Android only. There is no Apple developer account, so no App Store side exists.
- Webhook secret: stored in 1Password under "Pantas, RevenueCat Webhook"

### Apple Developer

**None held as of 11 August 2026**, so nothing iOS is set up and nothing needs to
be. The bundle IDs previously listed here were three guesses that did not match the
one actually in the Xcode project, `com.aedwon.cseCetReviewer`. Left here only so
nobody treats the old list as configured.

Blocked on an Apple account, and only when iOS matters: Apple sign-in, App Attest,
the APNs key, and per-flavor bundle IDs so a dev and a prod build can coexist on
one iPhone.

### Google Play

- Developer account: held.
- **Application ID: `com.aedwon.pantas`**, with `.dev` and `.dev.staging` for the
  other flavors. Set 11 August 2026 and **permanent from the first submission.**
- **A Google Cloud service account must be invited into Play Console** before
  RevenueCat can read subscriptions. This is the step that fails quietly. See
  `docs/revenuecat-setup.md` Section 3.

## Manual configuration steps

These cannot be scripted in this repo and must be redone if the relevant config is regenerated.

- [ ] iOS Xcode schemes created (`Runner-Dev`, `Runner-Staging`, `Runner-Prod`) with xcconfigs from `ios/Flutter/{Dev,Staging,Prod}.xcconfig` — Plan 1 Task 6 step 8
- [ ] iOS "Copy GoogleService-Info.plist" run-script phase added to Runner target — Plan 1 Task 16 step 4
- [ ] Sanity 2FA enforcement at org level enabled — Plan 1 Task 19 step 4
- [ ] GitHub branch protection on `main` — Plan 1 Task 28 step 2

## Codemagic / signing (activated in Plan 8)

- [ ] iOS App Store Connect API key uploaded
- [ ] iOS distribution certificate uploaded
- [ ] Android upload keystore generated and uploaded
- [ ] Google Play service account credentials uploaded

## Compliance checklist

- [ ] NPC registration confirmation received and recorded
- [ ] Privacy Policy reviewed by PH data privacy lawyer
- [ ] Terms of Service reviewed by PH lawyer
- [ ] App Store privacy nutrition labels filled (Plan 8)
- [ ] Google Play data safety form filled (Plan 8)
- [ ] DTI Business Name Registration confirmed (if operating under business name)

## Pentest

- [ ] Engagement signed
- [ ] NDA signed
- [ ] Scope finalized
- [ ] Engagement window: 2026-06-11 to 2026-06-17
- [ ] Findings report delivered
- [ ] Critical / High remediations done
