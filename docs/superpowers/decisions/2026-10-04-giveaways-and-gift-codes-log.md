# Giveaways, gift codes, and the account ID: decision log

**Date:** 4 October 2026
**Decided by:** Aedwon
**Prices:** `docs/pricing.md`. That file wins over this log if they differ.

## Decision

- **At launch:** Settings shows a copyable account ID. Facebook giveaway winners
  send their ID, and Aedwon grants Pro for a set time in the RevenueCat dashboard
  (a promotional entitlement). No spec and no backend change.
- **After launch:** in-app redemption codes and paid gift codes are deferred. Design
  them together with the tier entitlement design, using launch data to judge
  whether paid gifting is worth building.

## Idea as Aedwon stated it

> "i'm thinking of adding Redemption Codes and a UID system for marketing purpose.
> basically I would use this to
> 1. let others buy a month of subscription through redemption codes others can redeem
> 2. for the facebook page, to increase engagement and organic marketing, give away a
> certain number of 1 month or certain weeks of Pro (specified of course if for
> students or for cse level they have different pricing now please ground yourself in
> docs/pricing)."

Clarification after the agent raised the risk of selling codes outside Google Play:

> "no no, i will not sell the codes outside. basically the idea is:
> 1. other users buy codes through in-app purchase
> 2. they distribute those codes as they please"

So paid codes are gifts bought through Play billing, not sales outside the store.

## Options offered and costs

Asked: "is this significant engineering work you'd recommend we defer to future
versions? or can we ship at first release"

- **Paid gift codes:** about 1 to 2 weeks. New permanent one-time Play products per
  tier and length, a code system, refund handling, a Google policy check, a redeem
  screen. Depends on the tier entitlement design, not yet written. Adds a purchase
  path to the release purchase checks. Recommended: defer.
- **Free giveaway codes in-app:** about 2 to 3 days. Recommended: defer.
- **Launch stopgap (recommended, chosen):** copyable account ID in Settings, plus
  manual grants in the RevenueCat dashboard. Under a day of app work. Fine for tens
  of winners; tedious at hundreds, which is when in-app codes become worth building.

Aedwon's choice:

> "okay then let's do the UID system, I'll have that added by Claude Design, should
> be simple enough. as for Claude Code (backend) can you add this as a spec? and
> update the SSOT as well"

> "or perhaps a spec isn't needed"

The lead agreed no spec is needed: the backend already handles the grants (below).
The account ID screen is UI, so it follows the visual direction from Claude Design.

## Why the backend needs no change

- The app logs in to RevenueCat with the Firebase UID, so the ID shown in Settings
  is the RevenueCat customer ID that the dashboard grant needs.
- RevenueCat sends webhooks for promotional entitlements: `INITIAL_PURCHASE` on the
  grant and `EXPIRATION` at the end, with store `PROMOTIONAL` (RevenueCat webhook
  event docs, checked 4 October 2026). The existing webhook sets the `pro` claim on
  `INITIAL_PURCHASE` and clears it on `EXPIRATION`, so server-gated Pro content
  follows the grant.

## Rules for running giveaways

- The account ID shown must be the Firebase UID.
- Grant only to an account signed in with Google or Apple. An anonymous account is
  lost on reinstall or a new phone, and the grant goes with it. (The scheduled orphan
  cleanup is an empty stub today, but may delete anonymous accounts later.)
  The account ID screen should make this clear; how is a Claude Design decision.
- A grant gives the single current `pro` entitlement, which unlocks every exam. Tier
  limits apply only after the tier entitlement design ships.
- Do not grant to a current subscriber (see known limits).

## Known limits found while checking

- **Overlap:** the claim is one flag. If a user has both a grant and a subscription,
  whichever expires first clears Pro while the other is still active.
- **Cancellation clears Pro early (existing behavior, not caused by this decision):**
  the webhook clears the claim on `CANCELLATION`. RevenueCat says access should end
  only at `EXPIRATION`; a cancellation means auto-renew is off or a refund. A paying
  subscriber who turns off auto-renew may lose server-gated Pro content before the
  paid period ends. Needs its own fix.

## Deferred design questions (for the tier entitlement design)

- Gift products per tier and length; product IDs are permanent.
- Civil Service has no weekly plan, so a Civil Service week gift needs a pricing
  decision.
- Refunds: proposed to cancel unused codes and keep used codes valid.
- Stacking a code on an active subscription.
- Bulk buying, which overlaps with the unsettled government partner access.
- Google Play rules on gift codes bought through Play billing: not yet confirmed.
  Apple explicitly allows gifting through in-app purchase.
