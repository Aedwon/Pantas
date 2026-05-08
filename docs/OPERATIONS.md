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

### Sanity

- Project ID: TBD
- Datasets: `production` (dev plan also uses this for v0; isolated `staging` ds added in Plan 4)
- 2FA enforced at org level: [ ] confirm
- API token (read-only, dev): stored in 1Password under "CSE/CET Reviewer — Sanity Dev"

### RevenueCat

- Project: CSE/CET Reviewer
- Entitlement: `pro`
- Products: `cse_cet_pro_monthly`, `cse_cet_pro_yearly`, `cse_cet_pro_lifetime`
- Webhook secret: stored in 1Password under "CSE/CET Reviewer — RevenueCat Webhook"

### Apple Developer

- Team ID: TBD
- Bundle IDs:
  - Dev: `com.aedwon.csecetreviewer.dev`
  - Staging: `com.aedwon.csecetreviewer.staging`
  - Prod: `com.aedwon.csecetreviewer`

### Google Play

- Developer account: TBD

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
