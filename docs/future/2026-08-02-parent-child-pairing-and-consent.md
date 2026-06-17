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
