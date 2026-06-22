# Foundations 01: the error boundary, crash reporting and analytics

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


**Goal:** Make the app able to tell you when it breaks and whether anyone is using it, and
make the consent switch that governs both actually govern them.

**Architecture:** Three collectors installed in `bootstrap` before `runApp`, behind one
consent gate read from settings. A thin `Telemetry` facade in `lib/core/telemetry/` so no
feature imports a Firebase package directly, which is what keeps the layering check passing
and makes the whole thing testable with a fake.

**Tech Stack:** Flutter, Riverpod, `firebase_crashlytics`, `firebase_analytics`,
`flutter_test`. **No new packages:** both are already in `pubspec.yaml` and imported by
nothing.

**Source spec:** `docs/superpowers/specs/2026-08-03-platform-foundations-design.md`
Sections 2, 3 and 9.

**Decision log:** `docs/superpowers/decisions/2026-08-03-plan-audit-log.md`.

**Required reading before task 1:** `AGENTS.md` in full. It carries the build commands, the
identity bans, the voice rules, the never-invent-a-figure rule and the landmines, and all of
it applies.

## Global Constraints

- **Work only inside your worktree.** Never write to the main checkout. A previous background
  run left a half-applied `app_database.dart` in the main tree and it compiled, which is how
  it went unnoticed.
- **Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand and never
  committed.** This repo gitignores them.
- **No new dependencies.**
- **No feature imports `package:firebase_crashlytics` or `package:firebase_analytics`.**
  Everything goes through `lib/core/telemetry/`. `tool/check_layering.dart` must not gain a
  violation. **The baseline is 7.**
- **No user-facing string in this plan except the error screen's one line.** Grade-5-simple,
  no em dashes, American spelling.
- **Nothing collected before consent.** Off is the default and the pre-answer state.
- **A crash report carries no answer, no score, no name and no email.** Stack, build, device
  and route only.
- **Analyzer baseline is 27 issues, every one in `tools/` or `test/tool/`. `lib/` is clean
  and must stay clean.** If `flutter analyze` shows an issue under `lib/` or `test/`, you
  caused it.
- `dart format --output=none --set-exit-if-changed lib test` must pass before any commit.
- **Commit messages carry no AI attribution and no co-author trailers.**

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| `2026-08-03-settings-02-storage.md` | Nothing. The consent key `settings.help_improve_app` already exists on `UserSettings` as `helpImproveApp`. | No |
| `2026-08-03-settings-06-about-and-the-pushed-pages.md` | It builds the switch's row and its crash-report lede. This plan makes the switch real. They are independent and either order works. | No |

## File structure

| File | Responsibility |
|---|---|
| `lib/core/telemetry/telemetry.dart` (create) | The `Telemetry` interface and `TelemetryEvent`. No Firebase import. |
| `lib/core/telemetry/firebase_telemetry.dart` (create) | The one file that imports Crashlytics and Analytics. |
| `lib/core/telemetry/telemetry_providers.dart` (create) | `telemetryProvider`, and the consent gate. |
| `lib/core/telemetry/error_boundary.dart` (create) | The three collectors and the guarded zone. |
| `lib/core/ui/components/app_error_view.dart` (create) | Replaces the framework's red screen. |
| `lib/app/bootstrap.dart` (modify) | Install the boundary, wire the gate. |

---

## Task 1: The error boundary

**Files:**
- Create: `lib/core/telemetry/error_boundary.dart`
- Create: `lib/core/ui/components/app_error_view.dart`
- Modify: `lib/app/bootstrap.dart`
- Test: `test/core/telemetry/error_boundary_test.dart`

**Interfaces:**
- Produces:

```dart
/// Installs the three collectors and runs [body] inside a guarded zone.
///
/// Flutter throws in three places and catching only one is the usual
/// mistake: inside the widget framework, outside it, and asynchronously.
Future<void> runGuarded(
  Future<void> Function() body, {
  required void Function(Object error, StackTrace stack) onError,
});
```

`AppErrorView` is a stateless widget replacing `ErrorWidget.builder` in release builds. One
line in the app's voice, on paper, with no stack trace and no error code.

**Copy:** "Something went wrong here." Nothing else. No "sorry", no "please try again", no
code.

**Do not change `ErrorWidget.builder` in debug builds.** The red screen is useful to a
developer and useless to a student, so the swap is release-only.

- [ ] **Step 1: Write the failing test**

Create `test/core/telemetry/error_boundary_test.dart` asserting four things:

1. An error thrown inside a widget `build` reaches `onError`.
2. An error thrown from `PlatformDispatcher.instance.onError` reaches `onError`.
3. An asynchronous error escaping both reaches `onError`.
4. `onError` receives the stack, not just the error.

Use a recording callback, not a mock framework. The repo has none.

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/core/telemetry/error_boundary_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Build the boundary**

`runGuarded` sets `FlutterError.onError`, sets `PlatformDispatcher.instance.onError`, and
wraps `body` in `runZonedGuarded`. All three funnel into the single `onError` argument, so
the caller decides what happens and this file knows nothing about Crashlytics.

- [ ] **Step 4: Build the error view and install it**

`AppErrorView` on paper, using `context.colors` and `context.textStyles`. **No icon, no
illustration, no button.** Set `ErrorWidget.builder` only when `kReleaseMode`.

- [ ] **Step 5: Wire bootstrap**

In `lib/app/bootstrap.dart`, wrap the existing body of `bootstrap` in `runGuarded`. `onError`
forwards to the telemetry gate built in Task 3. Until Task 3 lands, forward to
`debugPrint` and leave a `// TODO(task-3)` naming this plan, so the boundary is live before
the reporter is.

- [ ] **Step 6: Run the gates**

```bash
flutter test test/core/telemetry/
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "add an error boundary so uncaught exceptions stop disappearing

Flutter throws in three places and lib/ caught none of them. An uncaught
exception showed a student the framework error screen and nobody was told."
```

---

## Task 2: The telemetry facade

**Files:**
- Create: `lib/core/telemetry/telemetry.dart`
- Create: `lib/core/telemetry/firebase_telemetry.dart`
- Test: `test/core/telemetry/telemetry_test.dart`

**Interfaces:**
- Produces:

```dart
/// The six questions this app needs answered at launch, and nothing else.
/// Spec Section 3. An event that answers no question on that list is not
/// added here.
enum TelemetryEvent {
  onboardingStepReached,
  onboardingCompleted,
  sessionStarted,
  paywallShown,
  purchaseStarted,
  purchaseCompleted,
  purchaseFailed,
  tabOpened,
  mockStarted,
  mockCompleted,
  mockAbandoned,
}

abstract interface class Telemetry {
  Future<void> log(TelemetryEvent event, {Map<String, Object>? properties});
  Future<void> recordError(Object error, StackTrace stack);
  Future<void> setEnabled({required bool enabled});
}

/// Collects nothing. The default until consent is on.
class DisabledTelemetry implements Telemetry { ... }

/// The only file in lib/ importing a Firebase telemetry package.
class FirebaseTelemetry implements Telemetry { ... }
```

**The property whitelist is enforced in code, not by convention.** `log` rejects any property
value that is not an `int`, a `bool`, or a `String` drawn from a closed set of identifiers.
**Free text, question stems, answers, scores, names and emails are rejected**, and the
rejection is an assertion in debug and a silent drop in release.

- [ ] **Step 1: Write the failing test**

Assert: `DisabledTelemetry` records nothing; `log` with a free-text property throws in debug;
every `TelemetryEvent` maps to a snake_case name under Firebase's 40-character limit; a name
never collides with a Firebase reserved event name.

- [ ] **Step 2: Run it and confirm it fails**

- [ ] **Step 3: Build the interface and both implementations**

- [ ] **Step 4: Run the gates and commit**

---

## Task 3: The consent gate

**Files:**
- Create: `lib/core/telemetry/telemetry_providers.dart`
- Modify: `lib/app/bootstrap.dart`
- Test: `test/core/telemetry/telemetry_providers_test.dart`

**Interfaces:**
- Consumes: `userSettingsProvider.helpImproveApp`.
- Produces: `telemetryProvider`, returning `FirebaseTelemetry` when consent is on and
  `DisabledTelemetry` otherwise, and calling `setEnabled` on both Firebase SDKs when the
  value changes.

**The gate is the whole privacy promise.** Test it harder than it looks like it needs.

- [ ] **Step 1: Write the failing test**

Assert:

1. Before the student has answered, `telemetryProvider` is `DisabledTelemetry`.
2. With consent off, it is `DisabledTelemetry`.
3. With consent on, it is `FirebaseTelemetry`.
4. **Turning consent off calls `setEnabled(enabled: false)` on the Firebase side**, so
   collection stops rather than merely being ignored.
5. The error boundary's `onError` reaches `recordError` only when consent is on.

- [ ] **Step 2: Run it and confirm it fails**

- [ ] **Step 3: Build the gate, and replace the Task 1 TODO**

Point `runGuarded`'s `onError` at `container.read(telemetryProvider).recordError`. Delete the
`// TODO(task-3)`.

- [ ] **Step 4: Run the gates and commit**

---

## Task 4: Emit the eleven events

**Files:**
- Modify: the onboarding controller, the session start use case, the paywall controller, the
  tab shell, and the mock controller. **Find them, do not guess the paths**, with
  `grep -rn` for the relevant class names.
- Test: one test per emitting site, asserting the event fires once with the right properties.

**Interfaces:**
- Consumes: `telemetryProvider`.
- Produces: nothing new.

**One event per question in the spec's table. Add nothing else.** If a site seems to want a
twelfth event, that is a spec change and it is a decision, so **stop and say so** rather than
adding it.

**Property rules:** `tabOpened` carries the tab's identifier. `sessionStarted` carries its
`SessionOrigin`. `paywallShown` carries what triggered it. `purchaseFailed` carries a reason
code from a closed set, never the store's raw message.

- [ ] **Step 1: Write the failing tests**
- [ ] **Step 2: Run them and confirm they fail**
- [ ] **Step 3: Emit at each site**
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

- `grep -rn "package:firebase_crashlytics\|package:firebase_analytics" lib/` returns
  **exactly one file**, `lib/core/telemetry/firebase_telemetry.dart`.
- `grep -rn "FlutterError.onError\|PlatformDispatcher.instance.onError\|runZonedGuarded" lib/`
  returns the boundary and nothing else.
- `flutter analyze` shows 27 issues, all under `tools/` or `test/tool/`. Any issue under
  `lib/` or `test/` is new and yours.
- `dart run tool/check_layering.dart` shows **7** violations, unchanged.
- `flutter test` passes across the whole suite.
- With consent off, no Firebase telemetry call is reachable. Prove it from the provider test,
  not by inspection.

## Done when

- An exception thrown anywhere in the app reaches one collector and one report.
- A student sees one plain line instead of a stack trace, in release builds only.
- The "Help improve the app" switch starts off, and turning it on and off starts and stops
  collection rather than filtering it afterward.
- Eleven events exist, each traceable to one of the spec's six questions, and no event
  carries free text.
