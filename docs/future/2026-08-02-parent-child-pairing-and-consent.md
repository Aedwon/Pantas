# Parent and child device pairing, for under-13 consent

**Date:** 2 August 2026
**Status:** Idea, captured. Not designed, not scheduled.
**Prompted by:** Aedwon, while deciding whether the onboarding age gate is necessary
at all, given PSHS-NCE is on the roadmap.

## Why this exists

PSHS-NCE is taken by Grade 6 students, who are 11 and 12. Pantas currently publishes
"The App is not directed to children under 13" in `docs/PRIVACY.md` Section 8 and
enforces it with a birth-year gate at onboarding. Those two positions cannot both
survive a PSHS-NCE launch.

Serving under-13 students is a compliance project, not a setting. This note records the
mechanism Aedwon proposed for it so it is not lost.

## His idea, verbatim

> "how about implementing a connection to two devices, one is for parent, one is for the
> child. perhaps a qr code will do. the scanned is the child's, the scanner is the
> parent. is that system feasible? although I have to say, it can be a future spec.
> right now I don't have the content for the pSHS-NCE but it is in my roadmap for this
> app"

## Feasibility

**The pairing itself: yes, and it is the right tool.** The child's device shows a QR
holding a short-lived pairing token, the parent's device scans it, and the backend links
the two accounts. Nothing about this is hard with the Firebase stack already in
`pubspec.yaml`.

**The consent: no, not on its own.** A scan proves the two devices were in the same
room. It does not prove the scanner is an adult, and it does not prove they are the
guardian. An older sibling satisfies it. A child with a tablet and a phone satisfies it.
COPPA requires consent that is *verifiable*, and proximity is not one of the recognised
methods.

## The shape that closes the gap

Three parts, and Pantas already owns the third:

1. **QR pairing** links the accounts. Fast, and genuinely the right mechanism for
   linking.
2. **A real parent account** on the parent's device, with a verified email, holding the
   consent record.
3. **The subscription purchase as the verification.** A payment transaction is one of
   the recognised verification routes, Pantas is subscription-only, and the parent is
   the one paying. RevenueCat (`purchases_flutter`) is already a dependency, so the
   payment does double duty.

**The real cost is not the QR.** It is the parent surface: a linked-children list, a
data review screen, and a delete control, all of which RA 10173 and COPPA expect a
guardian to be able to reach.

## What lowers the bar

Staying **Philippines-only at launch**. RA 10173 requires consent from a parent or
guardian but is far less prescriptive about the mechanism than COPPA is. Store
availability is the lever, and it is worth a great deal here.

## What this changes today, at no cost

Recorded in the onboarding decision log and adopted:

- **Build the age gate as a fork with a named destination**, so the under-13 branch is a
  stub to fill in later rather than a wall to tear down.
- **Keep 13+ and Philippines-only for launch.**

## Before any of this ships

A lawyer reviews the privacy policy rewrite. Section 8 changes from an exclusion into a
children's section: what is collected from a child, the legal basis, and how a guardian
reviews and deletes it. Terms gain a clause that a guardian accepts on the minor's
behalf, because a child cannot form a contract.

Also unresolved, and cheaper to decide than to discover:

- `firebase_analytics` must be off for a child account and not switchable on without the
  guardian. `helpImproveApp` defaults to true today.
- `google_sign_in` is a problem for under-13s, whose Google accounts are Family Link
  managed. Children likely use anonymous local mode, or the parent's sign-in.
- `firebase_messaging` tokens are persistent identifiers.
- The name field becomes a nickname for under-13s, or is skipped.

## Update, 2 November 2026: what to resolve before PSHS-NCE

**Status:** Not needed for the CSE launch, which stays 13+. Aedwon asked to keep this for when PSHS-NCE content is
ready. Most takers are 11 or 12, and some may be younger. Nothing here is designed or scheduled.

The guardian flow on branch `web/guardian-consent` covers ages 13 to 17 with a one-use emailed link. It is a starting
point for younger students, not a finished answer.

### Corrections to the notes above

- **"Pantas is subscription-only" is out of date.** PSHS-NCE is a ₱1,499 season pass only (`docs/pricing.md`).
- **A purchase cannot be the only verification.** Consent is needed before a free student's data is processed, and
  that student may never pay.

### Known code and text gaps

- **The age check ignores the exam.** The age gate calls `AgePolicy.forExam(null)`, so it always applies the default
  of 13. It needs the chosen exam, or the steps need a new order.
- **The under-minimum block stays on the device.** A student blocked under an older rule stays locked out unless
  the release clears or re-evaluates stored blocks.
- **Exam switching has no age check.** An 11 year old on PSHS-NCE could switch to CSE, whose minimum is 13.
- **The stored age group is too coarse.** Only `minor` or adult is kept, and the birth year is dropped. The app cannot
  tell whether a student has reached 13 or 18. Decide what to store and when the group updates.
- **Terms and privacy text assume 13+.** Terms 4.1 says at least 13 and only mentions a later minimum that is higher.
  `docs/PRIVACY.md` Section 8 excludes under-13s. Both drafts need a children's section.
- **The teen notice does not fit younger readers.** Write a version for Grade 6 reading level.

### Decide or explore

- **How strong guardian consent must be.** A child can enter a second email address of their own and tick the box.
  Compare the emailed link, a parent account, and payment as a check. Consider whether a higher risk needs a stronger
  method for this age group.
- **Guardian controls after consent.** The link works once, so a guardian has no way back. Design how they review
  data, delete it and withdraw consent.
- **Who holds the account.** Decide between a child account, a parent account used by the child, or linked accounts
  (the QR idea above). Parents may simply enter their own birth year, so decide whether that is allowed.
- **Sign-in.** Google's default minimum age for managing an account is 13, and younger children use Family Link. Test
  whether a supervised account can sign in. Otherwise use anonymous mode or the parent's sign-in.
- **Google Play.** Any app that includes children in its target audience must follow the Families Policy, so this
  affects the whole Android app, CSE included. Check the current policy and its Designed for Families rules, then
  review the Firebase Analytics, Crashlytics, Messaging and RevenueCat SDKs against them. The web app has no store
  review, but the privacy duties still apply.
- **Analytics and messaging.** Beyond the notes above, check Firebase's current settings for child users. This was
  not confirmed in the November search.
- **Engagement features.** Decide whether streaks, lapse reminders, notifications and Wrapped suit an 11 year old, and
  what a guardian can turn off.
- **Reading level.** Review app and lesson wording for Grade 6, not only the legal text.
- **NPC duties.** `build/legal/compliance-notes.md` (local) cites NPC Advisory 2024-03 for a Child Privacy Impact
  Assessment before launch. Check this against the official text and update it for the younger age group. The advisory
  sets no fixed age of digital consent, and parental consent under the Data Privacy Act covers those below 18. A
  commentary describes age bands such as 6 to 12, but this was not confirmed in the official text.
- **Legal review.** The onboarding log treats professional review as a cost attached to under-13 support. Budget for
  it, or find a low-cost route.

### Other release conditions

PSHS-NCE also needs its content and the abstract reasoning generator (`docs/pricing.md`).

### Sources

- [Google Play: target audience and app content](https://support.google.com/googleplay/android-developer/answer/9867159)
- [Google: age requirements on Google Accounts](https://support.google.com/accounts/answer/1350409?hl=en)
- [NPC Advisory 2024-03](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf)
- [NPC FAQs on the advisory](https://privacy.gov.ph/wp-content/uploads/2024/12/FAQs-Advisory-on-Guidelines-on-Child-Oriented-Transparency.pdf)
