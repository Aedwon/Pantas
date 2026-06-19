# Spec 7 amendment — Weekly SKU + pricing rationale (design)

**Status:** **Superseded on pricing and recommendation, 3 August 2026**, by
`2026-08-03-paywall-pricing-and-flow-design.md`. Read that first.

What changed: **`pro_lifetime` is removed** entirely, **Yearly rises to ₱999**, the
Monthly-to-Yearly crossover moves from 5 months to **10.1 months**, and the no-date
default moves from Yearly to **Monthly**. The buckets in Section 4 below are therefore
wrong as written and are kept only as the record of what they were.

What still stands: the rationale for Weekly's existence, the effective-monthly line as an
honesty guardrail, the grace-period mitigation, and the deferred "you'd save with Monthly"
nudge.

Original status: Brainstormed (2026-07-18). Amends Spec 7 (`2026-05-21-paywall-entitlement-design.md`).
**Context:** Pre-launch. No SKUs exist yet in Play Console or RevenueCat (see `2026-05-21-paywall-live-validation.md`), so this change costs config and UI work only — nothing ships twice.

## 1. Decision summary

Add a fourth SKU, `pro_weekly` at **₱29/week**, to the existing ladder. Motivation: affordability (much of the audience budgets weekly — allowance, prepaid-load rhythms) and honest crammer service (a user two weeks from the exam pays ₱58, not ₱99). Weekly is an access play, not an ARPU play; the price keeps it that way.

All other SKUs, the single `pro` entitlement, the entitlement architecture, the webhook, and the security model are unchanged.

## 2. SKU ladder

| SKU ID | Type | Price (PHP) | Effective /mo | Trial |
|---|---|---|---|---|
| `pro_weekly` | Subscription (P1W) | ₱29 / week | ≈₱126 | None |
| `pro_monthly` | Subscription | ₱99 / month | ₱99 | None |
| `pro_yearly` | Subscription | ₱499 / year | ≈₱42 | 7 days |
| `pro_lifetime` | One-time | ₱1,499 | — | None |

The trial stays on Yearly only. At ₱29, Weekly is its own low-risk trial.

Each step up the ladder buys a better per-month rate, so the ladder itself nudges committed users toward longer terms without any sales pressure.

## 3. Paywall changes

- Four cards, stable order **Weekly → Monthly → Yearly → Lifetime**. Same dynamic-emphasis treatment as Spec 7 §5.
- Weekly card copy: **"Weekly — ₱29/wk · ≈₱126/mo · Renews every week · Cancel anytime."**
  The effective-monthly line is the honesty guardrail: nobody mistakes Weekly for the cheap long-term option, and it makes Monthly and Yearly self-evidently better for longer holds.
- CTA when Weekly is selected: **"Get Pro — ₱29/week."**
- Fine print unchanged ("Paid through Google Play.").

## 4. Recommendation logic

One new days-based bucket ahead of the existing month buckets:

| Time until exam | Recommended | Badge copy |
|---|---|---|
| ≤ 21 days | Weekly | "Best for your exam date" |
| 22 days – 5 months | Monthly | "Best for your exam date" |
| 5 – 24+ months | Yearly | "Best for your exam date" |
| No date set / past date | Yearly | "Best value for most" |

**Why 21 days:** three weekly renewals cost ₱87; four cost ₱116. Past three weeks, Monthly is the cheaper honest pick, so recommending Weekly there would violate coach honesty.

## 5. Settings → Subscription panel

One new state: **"Pro · Weekly · renews [date] · ₱29"** with the standard Manage-in-Google-Play link and Restore Purchases.

## 6. Known costs, accepted

- **More renewal events.** The webhook handler is already idempotent with per-UID rate limits (Spec 7 S5); higher volume is safe.
- **More billing failures.** Weekly charges against GCash and prepaid balances will fail more often than monthly ones. Mitigation: enable Play's grace period on `pro_weekly`. Beyond that, accept the involuntary-churn noise in RevenueCat metrics.

## 7. Deferred to v1.1

A "you'd save with Monthly" in-app nudge after ~4 consecutive weekly renewals. Coach-aligned, but it needs renewal-count telemetry that does not exist yet — same dependency as the other deferred pricing experiments.

## 8. Ripple edits to Spec 7

- §4 SKU table: add `pro_weekly`.
- §5 paywall layout: four cards; Weekly card copy above.
- §6 recommendation table: add the ≤21-days bucket.
- §12 Settings panel: add the Weekly state.
- §14.3 QA scenarios: add (a) weekly purchase end-to-end → claim set → Pro unlocks; (b) weekly rapid-renewal license-tester cycle (Play renews weekly test subs every 5 minutes); (c) weekly billing failure → grace period → recovery.
- Live-validation checklist: create `pro_weekly` in Play Console, map it to the `pro` entitlement in RevenueCat, enable grace period.

## 9. Tests to add

- Recommendation unit tests for the ≤21-days bucket, the 21/22-day boundary, and the existing buckets unchanged.
- CTA copy test: Weekly selected → "Get Pro — ₱29/week".
- Paywall widget test: four cards render in stable order; Weekly recommended state shows badge + default selection.
- Settings panel test: Weekly subscription state renders "renews [date] · ₱29".

## 10. Pricing rationale (market evaluation, 2026-07)

Recorded so future pricing decisions start from evidence, not memory. Verdict: **the scheme is not overpriced — Yearly is meaningfully underpriced, and that is the correct launch posture.**

### 10.1 The three substitute tiers

Pantas competes against three price anchors, not against other apps' list prices:

1. **Free substitutes, abundant.** Topnotcher.ph, CivilServiceReviewer.ph, CSEExamReviewer.com, printed-PDF reviewers, and ad-supported Play Store test banks all serve "just give me questions" for ₱0. This is the real competition at the low end.
2. **Structured CSE review: ₱3,500–6,500.** CEVAS charges ₱3,500 (promo) to ₱6,500 (regular) for an online CSE course.
3. **UPCAT review centers: ₱12,000–45,000.** Mid-tier centers run ₱12–20k; premium (AHEAD, small-group tutoring) ₱22–45k.

Consumer-subscription context: Netflix Mobile and Spotify Premium both sit near ₱149/mo in the PH. Monthly Pro at ₱99 is priced below entertainment money. The CSE filing fee alone is ₱500.

### 10.2 Per-SKU evaluation

- **Monthly ₱99 — correctly priced.** For a self-funding jobseeker on ₱13–18k/mo this is the ceiling of impulse-affordable. Lower would not convert free-reviewer users (they are blocked by unproven differentiation, not by ₱99); higher enters entertainment-sub territory where the comparison stops flattering us.
- **Yearly ₱499 — underpriced on value, correct on strategy.** ₱499 is one-seventh of the cheapest structured CSE course and ~3% of a mid-tier UPCAT center, for review-center-adjacent function (adaptive plan, unlimited mocks, post-mock dossier). A value-based price would be ₱800–1,200/yr. But an unknown brand launching against free needs penetration pricing: convert cheaply, build ratings and word-of-mouth. Treat ₱499 as a launch price with a planned post-traction walk-up to ₱599–699, grandfathering existing subscribers (the grandfathering itself is a loyalty story). Never cut it — in this market a price cut reads as a quality signal.
- **Lifetime ₱1,499 — fine.** Rarely sells for a pass-once exam; earns its keep making Yearly look modest. Never auto-recommended (Spec 7 D6).
- **Weekly ₱29 — access play.** Priced at a 1.27× per-week premium over Monthly: enough to keep Monthly meaningful, small enough to stay an affordability tool rather than a trap.

### 10.3 The structural finding: one price, two wallets

The CSE user is a **self-funding adult** anchored to free reviewers and a ₱500 filing fee. The UPCAT/CET user's payer is usually a **parent** anchored to ₱12,000–45,000 review centers. Same entitlement, same ₱499 — but the second segment's willingness to pay is plausibly 10–40× the first's. D8 (single track-agnostic Pro) was the right v1 simplicity call, but this gap is the largest revenue item in the scheme — larger than any SKU-level tweak.

**Disposition:** park under Spec 7 §17's open "Premium tier" question for v2. The move there is not a higher price on Pro but a parent-facing CET offering (progress reports to parents, guaranteed-coverage framing) at ₱1,500–3,000/yr while base Pro stays a mass product.

### 10.4 Where the conversion risk actually lives

The threat is not price level; it is differentiation from free. Users default to free test banks until the coach value is demonstrated, so the post-mock dossier moment (Spec 7 §7, B-pattern) carries the funnel. Peso adjustments cannot fix conversion; the demo moment can.

### 10.5 Sources

- CEVAS CSE review pricing: https://www.cevasphilippines.com/cevas-civil-service-review-center
- Free CSE reviewers: https://topnotcher.ph/csc-civil-service-exam-reviewer/ · https://civilservicereviewer.ph/ · https://cseexamreviewer.com/
- UPCAT review-center price ranges: https://supertutor.ph/resources/blog/entrance-exams/upcat-review-centers-comparison/
- UPCAT centers: https://www.review.ahead.edu.ph/ · https://www.upcatreview.com/upcat-review-centers-and-schedules/ · https://acad1.ph/programs/upcat-review-program/
- Example free/ad-supported competitor app: https://play.google.com/store/apps/details?id=com.dodocorp.civilservicereviewer
