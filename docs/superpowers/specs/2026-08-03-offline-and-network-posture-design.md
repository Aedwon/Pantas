# Offline, and what the app does when the network is not there

**Date:** 3 August 2026
**Status:** Written to Aedwon's instruction of 3 August. Recommendation accepted in
principle, see `decisions/2026-08-03-plan-audit-log.md`.
**Why it exists:** there are zero references to connectivity anywhere in `lib/`, and no spec
says what a student sees when a call fails. The app is local-first by construction and has
never been told what to do at its edges.

This spec describes the destination. It assumes nothing in the tree survives.

---

## Section 1: The one rule

**Studying is never blocked by the network. Only account and money are.**

Every other rule in this document is a consequence of that one. A student on mobile data in a
province with one bar must be able to open the app, read a lesson, take a session, sit a
mock, and see their own numbers, with no banner, no spinner and no explanation, because none
of it needs a network and telling them otherwise would be a lie about the product.

## Section 2: What actually needs a network, exhaustively

Measured from the tree on 3 August.

| Surface | Needs network | What it is |
|---|---|---|
| Sign in, sign up, sign out | Yes | Firebase Auth |
| Sync push and pull | Yes | Firestore |
| Purchase, restore, entitlement refresh | Yes | RevenueCat |
| Pro content fetch | Yes | `getProContent` |
| Wrapped page | Yes | `renderWrappedPage`, it is a web page |
| Account deletion, data export, cloud reset | Yes | Cloud Functions |
| **Everything else** | **No** | Lessons, questions, sessions, mocks, progress, settings, notifications, bookmarks, flags |

Six things need a network. The app is otherwise complete without one.

## Section 3: The entitlement rule, which is the one that matters

**Last known entitlement stands until it is positively contradicted.**

> Amended October 6, 2026 (Aedwon, abuse review 1, CX-2): the rule holds until the paid period
> ends (subscription period, pass end or grant end). After that, if the app has had no successful
> check, Pro keeps working for 3 more days, then Pro features pause until one successful check.
> Nothing the student made is locked. The paused line is the only new message. Owner: W3
> (`plans/new-design/L2-W3-payments-and-identity.md` §10).

A network failure is not a contradiction. Only a successful response saying the entitlement
has ended ends it.

**Why this is the highest-stakes rule in the document.** The naive implementation of any
entitlement check fails closed: the call throws, the catch returns Free, and a student who
paid ₱999 loses Pro on a plane, in a jeepney, or in a barangay with no signal. They would be
right to ask for their money back, and they would be right to say so publicly.

**The shape already exists and must be kept.** `RevenueCatGateway` exposes
`cachedEntitlement`, and `entitlementProvider` already does
`customerInfoUpdates.distinct().startWith(cached)`. That is the correct architecture. What is
missing is the live gateway behind it, and the rule written down so whoever builds it does
not fail closed inside it.

**Three things follow:**

1. **The cached entitlement survives a cold start.** It is read before the first frame, from
   storage, not from the network. A Pro student who opens the app offline is Pro immediately,
   not Free-then-Pro after a round trip, because the flicker would gate a screen for a second
   and that is worse than not checking.
2. **A failed refresh is silent.** No banner, no retry toast, no "could not verify your
   subscription". The student is told nothing because nothing has happened to them.
3. **Only a successful response downgrades.** Expiry, cancellation and refund all arrive as
   real responses. A timeout is not one of them.

**The grace window.** RevenueCat's own grace period on `pro_weekly` is a store setting and is
listed in the launch checklist. This rule is separate and sits above it: it governs what the
app believes when it cannot ask.

## Section 4: Where a message is allowed, and what it says

Four places, and nowhere else. Each is one line at the point of failure, never a banner and
never a persistent indicator.

| Surface | When | The line |
|---|---|---|
| Paywall, in place of the CTA | Purchase or restore attempted with no network | "You need a connection to subscribe. Try again when you're back online." |
| Sign in | Any auth call fails on the network | "You need a connection to sign in." |
| Wrapped, where the share is offered | The page cannot be reached | "Your Wrapped needs a connection. It'll be here when you're back." |
| Backup, in Settings | Always, as a value | "Last backed up" with a date, or "Not backed up yet" |

**Copy is grade-5-simple, no em dashes, American spelling.** No error codes. No "please".
Never the words network, offline, sync, connectivity, server or retry in a student-facing
string, except "connection" as used above.

## Section 5: What must never be built

Recorded as bans because each is the obvious thing to reach for and each is wrong here.

- **No connectivity banner.** Not at the top of the app, not on a tab, not anywhere. Ink and
  Rule has no place to put one and the student does not need it.
- **No offline indicator, dot, or icon.**
- **No blocking spinner on a surface that reads local data.** If a provider is reading drift,
  it resolves in milliseconds and a spinner is a flash of anxiety for nothing.
- **No queue counter.** "3 changes waiting to sync" teaches a student a word they should
  never learn and invites them to worry about a thing they cannot act on.
- **No forced sign-in.** The app works signed out. That is already true and this spec locks
  it.

## Section 6: Sync, which is silent

**Sync is queued, retried and never spoken of.** It runs when it can. It does not block a
screen, it does not toast, it does not prompt.

**One honest surface, and only one:** the Backup page in Settings carries a
"Last backed up" value in the ledger grammar Settings uses everywhere else. A date, or
"Not backed up yet". That is the whole disclosure and it is enough: a student who wants to
know can look, and a student who does not is never told.

**A sync failure is not an error the student caused**, so it is never presented as one.

## Section 7: How to detect it, which is by not detecting it

**React to the call failing. Do not poll a connectivity plugin.**

A connectivity API tells you there is a wifi association or a mobile data radio. It does not
tell you there is internet, and it is wrong in exactly the case that matters: a captive
portal, a paid hotspot, a data balance at zero. The app would say online and every call would
fail.

**So:** attempt the call, catch the failure, apply the rule for that surface. No new
dependency, no polling, no listener, and no state that can disagree with reality.

## Section 8: Evidentiary tier

Nothing in this spec prints a figure to a student except the "Last backed up" date, which is
**measured** from the app's own last successful push. It is not inferred and not estimated.

## Deferred, with reasons

- **A manual "Back up now" button.** Sync is automatic and a button implies it might not be.
  Revisit only if a real student asks for it.
- **Offline queueing of purchases.** Stores do not support it and pretending otherwise would
  take money the app cannot deliver against.
- **Partial content download.** Content ships in the build. See
  `2026-08-03-content-delivery-and-seed-upgrade-design.md`.
