# Foundations 02: App Check, and the lever that reaches an installed build

> **Typography, amended 11 August 2026.** Any "serif" below is superseded: the
> app uses one family, Source Sans 3, everywhere. See
> `decisions/2026-08-10-typeface-log.md`.



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


**Goal:** Stop Firestore and Functions accepting any client that holds the config, and give
the project one way to block a build that is actively wrong.

**Architecture:** App Check activates in `bootstrap` immediately after `Firebase.initializeApp`
and before any Firestore or Functions call. Remote Config is read once at bootstrap into a
small typed value, with a bundled default so the app runs when it cannot be reached. Both sit
behind `lib/core/platform/`, so no feature imports either package.

**Tech Stack:** Flutter, Riverpod, `firebase_app_check`, `firebase_remote_config`,
`flutter_test`. **No new packages:** both are in `pubspec.yaml` and imported by nothing.

**Source spec:** `docs/superpowers/specs/2026-08-03-platform-foundations-design.md`
Sections 4 and 5.

**Required reading before task 1:** `AGENTS.md` in full.

## Global Constraints

- **Work only inside your worktree.**
- **Generated files are never edited by hand and never committed.**
- **No new dependencies.**
- **Fail open on Remote Config.** If it cannot be reached, the app runs normally. A version
  gate that blocks the app when the network is down is a self-inflicted outage and it
  contradicts `2026-08-03-offline-and-network-posture-design.md` Section 1.
- **Fail closed on nothing.** Neither of these may ever be the reason a student cannot study.
- **No feature imports `package:firebase_app_check` or `package:firebase_remote_config`.**
  Layering baseline is 7 violations and must not grow.
- **Voice:** grade-5-simple, no em dashes, American spelling. No version numbers in any
  student-facing string, no changelog, no error codes.
- **Analyzer baseline is ~25 issues, all under `tools/` or `test/tool/`. `lib/` is clean and that is the invariant, not the count.**
- **No AI attribution in commits.**

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| `2026-08-03-foundations-01-observability.md` | Nothing. Independent, can run in parallel. | No |

## File structure

| File | Responsibility |
|---|---|
| `lib/core/platform/app_check.dart` (create) | Activation, per flavor. |
| `lib/core/platform/remote_flags.dart` (create) | `RemoteFlags`, its defaults, its parse. |
| `lib/core/platform/remote_flags_providers.dart` (create) | `remoteFlagsProvider`, read once. |
| `lib/features/shell/presentation/update_required_page.dart` (create) | The full-screen stop. |
| `lib/app/bootstrap.dart` (modify) | Activate App Check, prefetch the flags. |
| `lib/app/router.dart` (modify) | The redirect. |

---

## Task 1: App Check

**Files:**
- Create: `lib/core/platform/app_check.dart`
- Modify: `lib/app/bootstrap.dart`
- Test: `test/core/platform/app_check_test.dart`

**Interfaces:**
- Consumes: `Flavor` from `lib/app/flavor.dart`.
- Produces: `Future<void> activateAppCheck(Flavor flavor)`.

**Provider per flavor:** the debug provider on `dev`, Play Integrity on `staging` and `prod`.

**It activates after `Firebase.initializeApp` and before anything else touches Firestore or
Functions.** Activating late means the first calls of the session go unattested, which is
exactly the window an attacker uses.

**Activation failure is swallowed.** If attestation cannot be obtained, the app still opens
and studying still works. Enforcement is a server-side setting and it is an operations item,
listed in the launch checklist, deliberately rolled out in monitor mode first. **Enforcing it
against clients that are not yet attesting locks out the whole user base**, so the code
landing before the enforcement is the correct order and not an oversight.

- [ ] **Step 1: Write the failing test**

Assert `activateAppCheck` picks the debug provider for `Flavor.dev` and Play Integrity
otherwise, and that a throwing activation does not propagate.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Build it and call it from `bootstrap`, directly after `bootstrapFirebase`**
- [ ] **Step 4: Run the gates and commit**

---

## Task 2: Remote flags, with bundled defaults

**Files:**
- Create: `lib/core/platform/remote_flags.dart`
- Create: `lib/core/platform/remote_flags_providers.dart`
- Modify: `lib/app/bootstrap.dart`
- Test: `test/core/platform/remote_flags_test.dart`

**Interfaces:**
- Produces:

```dart
@immutable
class RemoteFlags {
  const RemoteFlags({
    required this.minimumSupportedBuild,
    required this.serviceMessage,
  });

  /// Builds below this are blocked. Defaults to 0, which blocks nothing.
  final int minimumSupportedBuild;

  /// One line shown on Home when set. Null when there is nothing to say.
  final String? serviceMessage;

  static const fallback = RemoteFlags(
    minimumSupportedBuild: 0,
    serviceMessage: null,
  );

  static RemoteFlags parse(int? minimum, String? message);
}
```

**Two keys and nothing else at launch.** A third key is a spec change.

**`fallback` blocks nothing and says nothing.** That is what makes failing open the default
rather than a special case someone has to remember.

- [ ] **Step 1: Write the failing test**

Assert: a fetch that throws yields `fallback`; a fetch that times out yields `fallback`; a
missing key yields its default; an empty `service_message` string parses to null, not to an
empty line the UI would render as a blank row.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Build it**

Read once at bootstrap with a short timeout, into a `Provider<RemoteFlags>` overridden in the
container the way the storage overrides already are. **Do not watch it live.** A gate that
appears mid-session while a student is halfway through a mock is worse than one that appears
at the next launch.

- [ ] **Step 4: Run the gates and commit**

---

## Task 3: The stop

**Files:**
- Create: `lib/features/shell/presentation/update_required_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/shell/update_required_test.dart`

**Interfaces:**
- Consumes: `remoteFlagsProvider`, and the current build number from
  `pubspec.yaml`'s version.
- Produces: a `redirect` in `router.dart` sending every route to `/update-required` when the
  current build is below `minimumSupportedBuild`.

**The copy, settled:**

> **Pantas needs an update to keep working.**
>
> [ Update ]

No version numbers, no changelog, no "sorry", no dismiss. **This is the only modal in the app
a student cannot dismiss**, and that is justified only because the alternative is an app that
is actively wrong.

**Identity:** paper background, serif headline, one board button. No icon, no illustration.

**The button opens the store listing.** There is no `url_launcher` in `pubspec.yaml`, so this
needs a platform channel or the package. **Stop and ask** rather than adding a dependency:
the Global Constraints forbid it and this is the one place in the plan where the constraint
and the requirement meet.

- [ ] **Step 1: Write the failing test**

Assert: a build above the minimum reaches Home normally; a build below it is redirected from
every route including deep links; the page has no back affordance; the redirect does not fire
when `minimumSupportedBuild` is 0.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Build the page and the redirect**
- [ ] **Step 4: Run the full suite**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
dart run tool/check_layering.dart
```

- [ ] **Step 5: Commit**

---

## Verification, for the reviewer

- `grep -rn "package:firebase_app_check\|package:firebase_remote_config" lib/` returns
  **exactly two files**, both under `lib/core/platform/`.
- With the network unreachable, the app opens, reaches Home, and lets a student take a
  session. Prove it from the `fallback` tests.
- `dart run tool/check_layering.dart` shows **7** violations, unchanged.
- `flutter analyze` shows 27 issues, all under `tools/` or `test/tool/`.
- `flutter test` passes across the whole suite.

## Done when

- App Check activates before the first Firestore or Functions call, per flavor, and a failure
  to attest never blocks studying.
- Two remote keys exist, both with bundled defaults that block nothing.
- A build below the minimum is stopped everywhere, with one line and one button.
- Remote Config being unreachable is indistinguishable, to a student, from there being nothing
  to say.
