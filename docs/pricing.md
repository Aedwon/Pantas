# Pantas pricing: the current record

**Status:** Current. Approved by Aedwon on 4 October 2026.
**Authority:** This file is the only current statement of Pantas prices. Any price
anywhere else in this repository or in the Pantas Master SSOT Google Doc is
historical unless it matches this file. Do not quote, implement, or "restore" a
price from an older spec, plan, checkpoint, research tab, or decision log.
**Decision record:** `docs/superpowers/decisions/2026-10-04-tiered-pricing-log.md`.

## Superseded prices, never to be used

- Yearly ₱499, ₱599, or ₱999 for the Student tier. Yearly is ₱799.
- Any lifetime product (₱1,499 or other). Removed 3 August 2026. A Play product ID
  cannot be deleted once used, so never create one.
- One blanket Pro price for every exam. Replaced by exam tiers on 4 October 2026.
- A free trial on Yearly. The trial moved to Monthly on 4 October 2026. Yearly has
  no trial.
- ₱499 "NCE Season Pass", ₱999 to ₱1,499 yearly, and ₱1,999 yearly parent tier.
  These came from research and projection documents and were never adopted.

## Price by exam tier

Prices follow the exam the user has selected. Each tier has its own paywall.

| Tier | Exams | Plans | Status |
|---|---|---|---|
| Student | CETs (UPCAT and other college entrance tests), DOST and SM scholarship exams | ₱29 weekly, ₱99 monthly, ₱799 yearly | Products live as `pantas_pro_weekly`, `pantas_pro_monthly`, `pantas_pro_yearly` |
| Student, academy exams | PMA, PNPA, PMMA, MAAP | Student plans above, plus a ₱299 season pass | Content is a future update. Release requires the abstract reasoning generator |
| Civil Service | CSE Professional and Subprofessional, NAPOLCOM, AFPSAT | ₱149 monthly, or a ₱499 pass valid to the next exam date. No weekly plan | New products needed. NAPOLCOM and AFPSAT content is a future update |
| Licensure | LET, PNLE, and later PRC exams | ₱249 monthly, or a ₱1,499 pass valid to the board exam date | Content is a future update |
| PSHS-NCE | PSHS National Competitive Examination | ₱1,499 season pass only. No subscription | Content is a future update. Release requires the abstract reasoning generator |

A season pass is a one-time purchase that expires after the exam date. It never
renews.

## Free trial

**The 7-day free trial is on Monthly, and only Monthly** (Aedwon, 4 October 2026).
It applies to every tier's Monthly plan: Student ₱99, Civil Service ₱149, and
Licensure ₱249. Weekly, Yearly, and season passes have no trial. Older specs,
plans, the Terms, and the app's Pro page say the trial is on Yearly. That is
superseded.

## Release requirement: abstract reasoning generator

The academy exams and PSHS-NCE do not go on sale until the procedural generation
engine for abstract reasoning questions ships. Abstract reasoning is a scored part
of PSHS-NCE, PMA, and PMMA. MAAP tests IQ and aptitude, which usually includes
pattern items. PNPA coverage is not yet confirmed from an official source. If
NAPOLCOM or AFPSAT coverage is confirmed to include abstract reasoning, the same
requirement applies to them.

## Rules that go with the prices

- **Higher subscription tiers include lower ones.** Licensure includes Civil
  Service and Student. Civil Service includes Student.
- **A season pass covers only its own exam.** A PSHS-NCE pass does not unlock CSE.
- **Switching exams (direction, not yet a design spec):**
  - Within the same tier: Pro stays.
  - To a lower tier: Pro stays.
  - To a higher tier: show that tier's paywall as an upgrade.
  - Progress carry-over follows `docs/superpowers/specs/2026-08-02-exam-switching-design.md`,
    whatever the user pays.

## Not yet settled

- **Gift and redemption codes.** Deferred until after launch and designed with the
  entitlement design below. At launch, giveaway winners get Pro through a manual
  RevenueCat grant, found through their short public ID. Record:
  `docs/superpowers/decisions/2026-10-04-giveaways-and-gift-codes-log.md`.

- **Store price points.** Google Play and the App Store use fixed price points per
  country. ₱149, ₱249, ₱299, ₱499 and ₱1,499 must be confirmed as available in the
  Philippines before products are created.
- **Entitlement and product design.** The app currently has one `pro` entitlement.
  Tiers need a design spec covering entitlements, new product IDs, upgrade
  handling, and pass expiry before any product is created. Product IDs are
  permanent.
- **Prices are competitor-based starting points**, not measured willingness to
  pay. Revisit with launch data.
- **Government partner access** (sponsored or bulk access for academy applicants)
  is not designed. Store rules on access codes must be checked first.
- **Under-13 users.** Most PSHS-NCE takers are about 11 or 12. Serving them needs
  the parent and child account linking in
  `docs/future/2026-08-02-parent-child-pairing-and-consent.md`. Launch stays 13+.
