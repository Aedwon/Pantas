## Blocker

**`terms.md`, §12.** “If you created your account before the version date at the top, the earlier Terms keep applying to you until 14 days after we first show you a notice of these Terms in the app. These Terms apply to you sooner if you accept them, for example when you buy.”

The 14-day promise is met when Pantas actually shows the notice and gives existing users the full period. The draft makes elapsed time sound like acceptance and can override §12’s express acceptance rule for adverse material changes. The version date can also miss accounts created before publication. PR #90’s versioned checkout tick supports assent to the new purchase. Applying it to the existing account agreement risks overstating what the buyer agreed to. [Civil Code Arts. 1159, 1308, 1319](https://lawphil.net/statutes/repacts/ra1949/ra_386_1949.html), [Consumer Act Arts. 50 and 52](https://lawphil.net/statutes/repacts/ra1992/ra_7394_1992.html), [RA 8792 §16](https://lawphil.net/statutes/repacts/ra2000/ra_8792_2000.html), [PR #90](https://github.com/Aedwon/Pantas/pull/90)

**Replace with** “If you already had an account when we published these Terms, your earlier Terms apply until you accept these Terms. Where this section allows acceptance by continued use, you accept by using Pantas after 14 days have passed since we first showed you the notice in the app. A new web purchase uses the Terms the buyer expressly accepts at checkout.”

A Free user who never receives notice or accepts stays on the earlier Terms. Close the gap by showing the linked notice when they return, including outside Home, and logging its first display per account. Put the timing in that notice. The privacy notices need no matching contract clause. Separately, verify whether affected users received advance notice of the November 24 storage change. [RA 10173 §16(b)(7)](https://privacy.gov.ph/data-privacy-act/)

## Major

**`privacy-policy.md` and `teen-notice.md`.** “The code remains after account deletion. We delete it 730 days after the trial started. For a trial that started before November 24, 2026, the 730 days count from that date.”

Firestore usually deletes within 24 hours after expiry. It guarantees neither that timing nor “within a few days.” Eligibility still checks for the row until removal. The November 24 rule covered codes backfilled at rollout, and the production launch log reports zero rows. Omit it unless affected codes are confirmed. The deletion path preserves any later expiry and skips recreating a code if its calculated expiry has passed. [Firestore TTL](https://docs.cloud.google.com/firestore/native/docs/ttl), [PR #92](https://github.com/Aedwon/Pantas/pull/92)

**Replace with** “The code can stay after account deletion. We schedule it for deletion 730 days after your trial starts. If we have no trial start date, we count from our first attempt to delete your account. We keep any later deletion date already set. Automatic cleanup can take longer.”

730 days can be defensible across exam cycles. Document why a shorter period would fall short, including for teens and records with missing start dates. Keyed codes help limit privacy impact. Matching unrelated storage periods adds little. [RA 10173 §§11(e), 12(f)](https://privacy.gov.ph/data-privacy-act/), [NPC Circular 2023-07 §§5–8](https://privacy.gov.ph/wp-content/uploads/2024/01/NPC-Circular-No.-2023-07_Guidelines-on-Legitimate-Interest_13-December-2023.pdf)

## Minor

**`terms.md`, §4.** “Deleting your account does not give you another trial.” This can read as a permanent bar after both records disappear. **Replace with** “Any future trial is subject to the eligibility checks above, including after account deletion.” [PR #92](https://github.com/Aedwon/Pantas/pull/92)

**Change 1 verdict.** Correct the deletion schedule and document why 730 days is necessary.  
**Change 2 verdict.** Keep the 14-day transition, tie it to actual notice and assent, and limit early checkout acceptance to the new purchase.
tokens used
## Blocker
124,876

**`terms.md`, §12.** “If you created your account before the version date at the top, the earlier Terms keep applying to you until 14 days after we first show you a notice of these Terms in the app. These Terms apply to you sooner if you accept them, for example when you buy.”

The 14-day promise is met when Pantas actually shows the notice and gives existing users the full period. The draft makes elapsed time sound like acceptance and can override §12’s express acceptance rule for adverse material changes. The version date can also miss accounts created before publication. PR #90’s versioned checkout tick supports assent to the new purchase. Applying it to the existing account agreement risks overstating what the buyer agreed to. [Civil Code Arts. 1159, 1308, 1319](https://lawphil.net/statutes/repacts/ra1949/ra_386_1949.html), [Consumer Act Arts. 50 and 52](https://lawphil.net/statutes/repacts/ra1992/ra_7394_1992.html), [RA 8792 §16](https://lawphil.net/statutes/repacts/ra2000/ra_8792_2000.html), [PR #90](https://github.com/Aedwon/Pantas/pull/90)

**Replace with** “If you already had an account when we published these Terms, your earlier Terms apply until you accept these Terms. Where this section allows acceptance by continued use, you accept by using Pantas after 14 days have passed since we first showed you the notice in the app. A new web purchase uses the Terms the buyer expressly accepts at checkout.”

