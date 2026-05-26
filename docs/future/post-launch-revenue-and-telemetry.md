# Post-launch revenue streams + telemetry foundation

**Status:** Forward-looking. Not in v1 MVP scope.
**Captured:** 2026-05-18 during Spec 7 (Paywall) brainstorm.
**Revisit when:** planning v1.1+ roadmap, or when partner outreach starts.

## Why this doc exists

Spec 7 raised the question of whether the app collects enough data to support future B2B / sponsorship / partnership revenue. Answer: today, no. The MVP has Firebase Analytics defaults, RevenueCat purchase data, and Firestore study state — sufficient for an individual-freemium product, **insufficient to pitch partners on impact**.

This is parked for later, but the *telemetry foundation* is the kind of thing that's expensive to add retroactively. Strongly consider slotting a telemetry/event-taxonomy spec before public launch.

## Current data sources at MVP

| Source | What we get | What's missing |
|---|---|---|
| Firebase Analytics (default) | Screen views, session length, DAU/MAU, install attribution | Custom events, cohorts, funnels |
| RevenueCat dashboard | Purchase funnel, trial conversion, churn, LTV | Disconnected from study behavior |
| Firestore writes (Spec 3) | Live study state (mastery, streaks, mocks) | Not an event stream; bad for cohort/funnel queries |
| Cloud Function logs (Spec 7 Q5) | Specific edge events | Narrow scope |

## Gap: event taxonomy

For B2B viability we need to be able to answer questions like:

- What % of users prep for 6+ months?
- What's first-time-pass rate for users who complete the daily plan vs not?
- Where do paywall viewers drop off?
- Which topics correlate with mock-exam improvement?

None of these are answerable without a defined event taxonomy fired across the app.

### Cheap version (no new vendor)

Firebase Analytics custom events + a `pro_status` user property. ~20 well-named events covers the whole MVP:

- `onboarding_started`, `onboarding_completed`, `exam_date_set`
- `mock_started`, `mock_completed` (with score)
- `daily_plan_opened`, `daily_plan_item_completed`
- `paywall_viewed` (with trigger source), `paywall_dismissed`, `pro_depth_tapped`
- `subscription_started`, `trial_started`, `trial_converted`, `subscription_cancelled`
- `sign_in_completed`, `restore_purchases_tapped`

Plus user properties: `pro_status`, `exam_track`, `months_until_exam`, `cohort_week`.

### Richer version (one new vendor)

Add Posthog or Amplitude (free tier handles MVP scale) for cohort + funnel views queryable without SQL. Mirrors the same events.

## Revenue stream menu (ordered by fit)

| # | Stream | What it is | Prereqs |
|---|---|---|---|
| 1 | **B2B seat licenses** | Bulk Pro accounts for review centers, schools, govt offices | Multi-seat account model, org admin, per-learner usage reports |
| 2 | **University partnerships (UPCAT)** | Universities pay for upper-funnel candidate acquisition | Anonymized aggregate impact data, attribution flow |
| 3 | **Sponsored content sections** | Review centers / publishers fund topic packs (clearly labeled) | Sponsored-content tagging in Sanity, editorial firewall doc |
| 4 | **Affiliate referrals** | Books, live reviewers, exam-fee logistics | Curation discipline, disclosure UX |
| 5 | **Government tie-ups (CSC, DepEd, LGUs)** | Bulk procurement / public-program licensing | Procurement-ready security & data posture; slow sales cycle |
| 6 | **Anonymized data product** | Aggregate insights sold to ed-publishers | Formal consent flow, PH Data Privacy Act compliance, anonymization pipeline |
| 7 | **Tutor matchmaking / live cohorts** | Tier above Pro: live reviewer access, cohort study | Reviewer onboarding, scheduling, additional billing path |

## Constraints that always apply

- **PH Data Privacy Act compliance.** Anything touching aggregate user data needs a clean consent flow, declared purposes, and an anonymization pipeline before partner contracts can be signed.
- **Coach positioning.** Sponsorships must not compromise content quality or learner trust. Editorial firewall must be visible.
- **No dark-pattern adjacency.** Monetization-without-churn principle applies to every new stream — no scarcity manufacturing, no hidden auto-renew, no upsell during failure moments.

## Suggested next actions when this is revisited

1. **Before public launch (v1.0):** add a "Telemetry & Product Analytics" spec (likely Spec 8 candidate). Define event taxonomy. Wire Firebase custom events. Decide cheap vs richer version.
2. **First 90 days post-launch:** collect baseline metrics. Identify which revenue streams have the best fit signals (e.g., are users clustering in groups that look like review-center cohorts?).
3. **v1.x planning:** pick *one* secondary stream to prototype based on signals. Don't fan out across all seven.
4. **v2:** if a B2B stream gains traction, design the multi-seat account model as its own substantial spec.
