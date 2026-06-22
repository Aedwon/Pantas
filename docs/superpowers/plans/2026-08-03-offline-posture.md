# Offline posture: never fail closed, and say almost nothing

> **How to work this plan.** Implement it task by task, in order. For each task: write the
> failing test first, run it and confirm it fails, then write the code that makes it pass. Do
> not skip a step and do not batch tasks. Steps use checkbox (`- [ ]`) syntax so progress can
> be tracked.
>
> **Required reading before Task 1:** `AGENTS.md` at the repository root, in full.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous, contradicts the spec, or looks
> wrong, **stop and say so** rather than inventing a solution. A plausible invention is more
> expensive than a question, because it looks finished.
>
> **Analyzer baseline:** `flutter analyze` reports **25 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. **The number drifts as those tools change; the
> invariant is that `lib/` and `test/` outside `test/tool/` are clean.** Any issue there is
> one you introduced.


**Goal:** Make the app behave correctly at its network edges, which mostly means making sure
a paying student never loses Pro because of a dead zone, and adding four lines of copy and
nothing else.

**Architecture:** No connectivity detection is added. Each of the six network-touching
surfaces catches its own failure and applies the rule for that surface. The entitlement
stream gains a cached-wins rule, which is the only substantial change in the plan.

**Tech Stack:** Flutter, Riverpod, `flutter_test`. **No new packages, and a connectivity
package specifically must not be added.**

**Source spec:** `docs/superpowers/specs/2026-08-03-offline-and-network-posture-design.md`.

**Required reading before task 1:** `AGENTS.md` in full, and Sections 3, 5 and 7 of the source
spec. Section 5 is a list of bans and it is the part most likely to be violated by good
intentions.

## Global Constraints

- **Work only inside your worktree.**
- **Generated files are never edited by hand and never committed.**
- **No new dependencies. `connectivity_plus` and its equivalents are banned by the spec**, not
  merely unnecessary: they report a radio, not the internet, and they are wrong in exactly the
  cases that matter.
- **Never fail closed on entitlement.** A network failure is not a contradiction. Only a
  successful response saying the entitlement ended may end it.
- **No connectivity banner, no offline indicator, no queue counter, no blocking spinner on a
  local read, no forced sign-in.** Spec Section 5. If a task seems to need one, **stop and say
  so.**
- **Voice:** grade-5-simple, no em dashes, American spelling. The words network, offline,
  sync, connectivity, server and retry never appear in a student-facing string. "Connection"
  is allowed and is the only one.
- **Analyzer baseline is ~25 issues, all under `tools/` or `test/tool/`. `lib/` is clean and that is the invariant, not the count.**
- **No AI attribution in commits.**

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| The paywall rebuild | Task 1 changes `entitlementProvider`, which the paywall rebuild also touches. **Whichever runs second must not undo the cached-wins rule.** | No, but read this first |
| `2026-08-03-foundations-01-observability.md` | Nothing. | No |

**A note whoever runs Task 1 must read.** `purchases_flutter` is in `pubspec.yaml` and
imported by **zero** files in `lib/`. The only implementation of `RevenueCatGateway` is
`DisabledRevenueCatGateway`, which returns `Entitlement.free()` from everything including
`purchase()`. **The app cannot take money today.** Task 1 writes the rule the live gateway
must obey; it does not build the live gateway, which belongs to the paywall rebuild.

## File structure

| File | Responsibility |
|---|---|
| `lib/features/paywall/application/paywall_providers.dart` (modify) | The cached-wins rule. |
| `lib/features/paywall/data/revenuecat_gateway.dart` (modify) | Persist the cached entitlement across launches. |
| `lib/features/settings/presentation/pages/backup_page.dart` (modify) | "Last backed up". |
| Sign-in, paywall CTA and Wrapped share sites (modify) | One line each. |

---

## Task 1: The entitlement never fails closed

**Files:**
- Modify: `lib/features/paywall/application/paywall_providers.dart`
- Modify: `lib/features/paywall/data/revenuecat_gateway.dart`
- Test: `test/features/paywall/application/entitlement_offline_test.dart` (create)

**Interfaces:**
- Consumes: `AppPreferencesRepository`, for persisting the last known entitlement.
- Produces: `RevenueCatGateway.cachedEntitlement` backed by device preferences rather than
  memory, and an `entitlementProvider` that treats a stream error as **no news**.

**The shape already exists and is correct.** `entitlementProvider` does
`customerInfoUpdates.distinct().startWith(cached)`. Two things are missing: the cache does not
survive a cold start, and a stream error is not handled at all.

**The rule, stated so it cannot be misread:**

| What arrives | What the app believes |
|---|---|
| A successful response saying Pro | Pro |
| A successful response saying Free | **Free.** This is the only thing that downgrades. |
| An error, a timeout, a socket failure | **Whatever it believed before.** No change, no message. |
| Nothing at all, cold start, no network | The persisted cache, read **before the first frame** |

**Read the cache before the first frame, not after a round trip.** A Pro student opening the
app offline must be Pro immediately. A Free-then-Pro flicker gates a screen for a second, and
a gate that appears and vanishes is worse than one that never appeared.

- [ ] **Step 1: Write the failing test**

Assert, with a fake gateway:

1. A cached Pro entitlement plus a stream that immediately errors yields **Pro**, and stays
   Pro.
2. A cached Pro entitlement plus a successful Free response yields **Free**.
3. A cold start with no cache and no network yields Free, without throwing.
4. The cache survives a container rebuild, which stands in for a cold start.
5. **No error state is ever surfaced from this provider.** The student is never told the
   check failed.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Persist the cache and swallow stream errors**

Use `handleError` on the stream, not a `try` around the provider body, or the error kills the
subscription and the next successful response never arrives.

- [ ] **Step 4: Run the gates and commit**

```bash
git commit -m "keep a paid student Pro when the network is gone

A network failure is not a cancellation. Failing closed here would take
Pro away from someone on a plane or in a dead zone, and they would be
right to ask for their money back."
```

---

## Task 2: The four lines

**Files:**
- Modify: the paywall CTA, the sign-in call site, the Wrapped share site, and
  `backup_page.dart`. **Find them with `grep -rn`, do not guess the paths.**
- Test: one widget test per site.

**The copy, settled by the spec and not to be reworded:**

| Where | The line |
|---|---|
| Paywall, replacing the CTA | "You need a connection to subscribe. Try again when you're back online." |
| Sign in | "You need a connection to sign in." |
| Wrapped, where the share is offered | "Your Wrapped needs a connection. It'll be here when you're back." |
| Backup, as a value | "Last backed up" with a date, or "Not backed up yet" |

**Each is one line at the point of failure.** Not a banner, not a dialog, not a snackbar that
outlives the moment. The paywall's is a **replaced CTA**, not a line added beneath it.

**The Backup line is the only one that is always present**, because it is a value in Settings'
ledger grammar and not an error.

- [ ] **Step 1: Write the failing tests**

Assert each line appears only on its own failure, that none of them appears anywhere else, and
that **no test anywhere finds a persistent connectivity indicator.**

- [ ] **Step 2: Run them and confirm they fail**
- [ ] **Step 3: Add the four**
- [ ] **Step 4: Run the gates and commit**

---

## Task 3: Sync goes quiet

**Files:**
- Modify: the sync engine's surfacing, wherever it currently reaches the UI. **Find it with
  `grep -rn` across `lib/core/sync/`.**
- Test: `test/core/sync/silent_sync_test.dart` (create)

**Interfaces:**
- Produces: nothing new. This task **removes** rather than adds.

**Sync is queued, retried and never spoken of.** It does not block a screen, does not toast
and does not prompt. A sync failure is not an error the student caused, so it is never
presented as one.

**One honest surface, and only one:** the "Last backed up" value from Task 2.

**If sync currently surfaces nothing, this task is a test and a comment**, asserting the
property so a later plan cannot quietly add a toast. Say so in the commit rather than
inventing work.

- [ ] **Step 1: Find every place sync reaches the UI**
- [ ] **Step 2: Write the failing test asserting none of them do**
- [ ] **Step 3: Remove what is there**
- [ ] **Step 4: Run the full suite**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

- [ ] **Step 5: Commit**

---

## Verification, for the reviewer

- `grep -rn "connectivity" lib/` returns **nothing**. No package, no listener, no poller.
- `grep -rniE "offline|no internet|check your connection|network error" lib/` returns only the
  four settled lines, and none of them uses a banned word.
- The entitlement test proves a stream error leaves a Pro student Pro. This is the single
  assertion in the plan most worth reading twice.
- `flutter analyze` shows 27 issues, all under `tools/` or `test/tool/`.
- `flutter test` passes across the whole suite.

## Done when

- A student with no signal opens the app, reads, takes a session, sits a mock and sees their
  own numbers, with nothing on screen mentioning a network.
- A paying student stays Pro through a dead zone, a plane and a flat data balance.
- Exactly four strings in the app mention a connection, and each appears only at the moment
  its own call failed.
- Nothing anywhere counts pending changes at a student.
