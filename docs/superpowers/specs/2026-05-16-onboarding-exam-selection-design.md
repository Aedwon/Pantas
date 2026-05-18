# Onboarding (Exam Selection + Age Gate) Design Spec

**Date:** 2026-05-16
**Status:** Approved for planning
**Sub-project:** Onboarding sub-project 1 — first-launch exam selection with age gate
**Supersedes (partial):** `docs/superpowers/specs/2026-05-07-cse-cet-reviewer-app-design.md` (the `features/onboarding/` section). See `Supersession` below.

---

## Goal

Replace the `/onboarding` stub with a real first-launch flow that (a) satisfies the privacy-policy age gate commitment and (b) makes the user's exam selection explicit before they reach Home. This closes the Phase 1 selected-exam-dashboard gap where the choose-exam fallback button routed to a placeholder.

The flow has three screens, all required before `/home` becomes reachable on a true first launch:

1. Welcome (brand voice + outcome framing)
2. Age gate (birth-year question with under-13 block)
3. Exam picker (emblem cards for active exams)

After the picker, the user lands on the selected-exam Home dashboard from Phase 1.

## In Scope

- Welcome screen.
- Birth-year age gate with under-13 hard block in-screen.
- Exam picker using existing `examListProvider` filtered to `isActive`.
- Persistence of `passed_age_gate` and `selected_exam_id` through `AppPreferencesRepository`.
- A router-level redirect that drives users to `/onboarding` whenever either gate is unsatisfied and away from `/onboarding` once both are.
- Tests for repository helpers, each step widget, and the four-quadrant `(passedAgeGate × needsExamSelection)` redirect matrix.

## Out of Scope

- Account sign-in (Apple/Google). Lives in `features/auth_flow/`, separate sub-project.
- Pro pitch / paywall screens. Lives in `features/paywall/`.
- Notifications permission ask. Lives in `features/notifications/`.
- Language picker.
- Goals selection. Mentioned in foundation spec but deferred — no current product surface needs it.
- Adaptive diagnostic / FSRS seed inside onboarding — that capability lives in `/assessment/:examId` post-onboarding.
- Exam recommendation (auto-suggesting which exam to study). Deliberately dropped: PH-market users come knowing which exam they're taking.
- Exam switching after onboarding. Locked to More/Settings per Phase 1 spec; out of scope here.

## Supersession

The foundation spec at `docs/superpowers/specs/2026-05-07-cse-cet-reviewer-app-design.md:369` defined `features/onboarding/` as a five-part bundle. This spec narrates how those parts have evolved and where they live now. The foundation spec is preserved as a point-in-time record; this spec is the current source of truth for onboarding.

| Foundation spec piece | Current state |
|---|---|
| 10-question adaptive diagnostic with 3-bucket difficulty | Built as `/assessment/:examId` — exam-scoped, ~35-question cap, produces topic mastery. Launched from Home's `Start assessment` CTA *after* onboarding. |
| Recommended exam focus (diagnostic auto-suggests an exam) | **Deliberately dropped.** Onboarding asks the user to pick. |
| Goals selection | Deferred. No product surface needs goals yet. |
| FSRS seed from diagnostic | Deferred. `/assessment` produces mastery; FSRS seeding is separate future work. |
| Birth-year age gate at onboarding | **In scope here.** Implemented as screen 2 of this flow. |
| Skip button after Q3 | Not applicable — no diagnostic in onboarding anymore. |

## Locked UX Decisions

- Up to three screens in fixed order: Welcome → Age gate → Picker. No skip, no back, no `Continue later`. Each screen the user reaches is required to advance.
- On a true first launch (no age gate passed yet), all three screens are shown. An existing user who lost only their selection enters at the picker — Welcome and Age gate are skipped because their work is already done and persisted.
- Auto-redirect on app boot whenever either gate is unsatisfied. Per-tab fallback cards from Phase 1 remain as defensive backstops but should not be the normal path.
- Single-exam shortcut from Phase 1 remains: if exactly one active exam exists with no saved selection, the focus provider auto-selects it, the picker step doesn't trigger, and a fresh user goes Welcome → Age gate → Home. (The picker only meaningfully appears with 2+ active exams.)
- Welcome copy: headline `Build your study plan`, subtitle `Pick your exam — we'll guide what to study first.`, single CTA `Get started`. This echoes Phase 1's no-assessment Home hero so users feel one continuous narrative.
- Age gate copy: title `Quick check`, prompt `When were you born?`, input is an iOS-style year wheel (`CupertinoPicker`), CTA `Continue` disabled until a year is selected.
- Under-13 block: in-screen replacement, headline `Sorry, this app isn't available for users under 13.`, single text link `Try a different year` that returns to the wheel. No data persisted on block — user can retry on next launch.
- Picker copy: title `Choose your exam`, subtitle `You can switch later in More.`, emblem cards where the emblem is `Exam.code` (e.g., `CSE`, `UPCAT`) and the row title is `Exam.name`. No description text in row (keeps `Exam` schema unchanged).
- Picker `Continue` button is disabled until a card is tapped.
- Onboarding is full-screen and outside the bottom-nav shell, matching `/quiz/quick/:examId` and `/assessment/:examId`.

## Navigation

**Route:**

```text
/onboarding
```

`/onboarding` is a top-level `GoRoute`, not part of any `StatefulShellBranch`. The single route handles all three screens via internal step state. No `/onboarding/welcome` or `/onboarding/age` sub-routes — the flow is once-per-user and doesn't need URL granularity.

**Step state inside `OnboardingPage`:**

```text
enum _OnboardingStep { welcome, ageGate, picker }
```

Initial step is computed when the page mounts, from the current values of `passedAgeGateProvider` and `activeExamFocusProvider`:

| `passedAgeGate` | `needsExamSelection` | Initial step |
|---|---|---|
| false | (any) | `welcome` |
| true | true | `picker` |
| true | false | *should not be on this route — router redirect handles it* |

## Trigger Conditions (Router Redirect)

The `appRouterProvider`'s `redirect:` callback evaluates two providers and routes accordingly:

1. If either `passedAgeGateProvider.valueOrNull` or `activeExamFocusProvider.valueOrNull` is null (still loading), return `null` and let the current route render its loading state.
2. If `!passedAgeGate` and `state.matchedLocation != '/onboarding'`, return `'/onboarding'`.
3. If `passedAgeGate && needsExamSelection && state.matchedLocation != '/onboarding'`, return `'/onboarding'`.
4. If `passedAgeGate && !needsExamSelection && state.matchedLocation == '/onboarding'`, return `'/home'`.
5. Otherwise, return `null`.

The router gets a `refreshListenable` adapter that emits whenever either provider's value changes, so completing the age gate or saving an exam selection automatically re-runs the redirect logic.

## Welcome Screen

**Content:**

```text
Build your study plan
Pick your exam — we'll guide what to study first.

[Get started]
```

**Visual:**

- Diagnostic/study-plan illustration placeholder (native Flutter, matching Phase 1's hero placeholder approach — no `flutter_svg` for this temporary asset).
- Headline uses the dashboard header style.
- Single primary CTA — no `Skip`, no `Maybe later`.

**Behavior:** `Get started` advances internal step to `ageGate`. No data persisted at this screen.

## Age Gate Screen

**Content (input state):**

```text
Quick check
When were you born?

[year wheel — defaults to current year − 18, range current_year − 100 .. current_year]

[Continue]
```

**Content (block state, when entered year > current_year − 13):**

```text
Sorry, this app isn't available for users under 13.

Try a different year
```

**Behavior:**

- `Continue` disabled until a year is selected from the wheel.
- On `Continue` with valid year (≤ current_year − 13): `AppPreferencesRepository.setPassedAgeGate(true)` → step advances. If `needsExamSelection`, advance to `picker`; otherwise the router redirect will pull the user to `/home`.
- On `Continue` with under-13 year: screen replaces with block state. No persistence.
- `Try a different year` returns the screen to input state with the wheel showing the previously selected year.
- Closing the app from the block state and reopening it puts the user back at Welcome (block state isn't persisted — by design).

**Defaults:** the wheel defaults to current_year − 18 to nudge users away from accidental under-13 entries while not encoding an opinion about the actual user.

## Exam Picker Screen

**Content:**

```text
Choose your exam
You can switch later in More.

[Emblem card]  CSE      Civil Service Exam
[Emblem card]  UPCAT    UPCAT

[Continue]
```

**Behavior:**

- Cards source from `examListProvider`, filtered to `isActive`, sorted by `name` ascending (stable order across runs).
- Tapping a card selects it; only one selectable at a time. Selected card uses Phase 1's primary-soft fill + 1px primary border treatment.
- `Continue` disabled until a card is selected.
- On `Continue`: `AppPreferencesRepository.setSelectedExamId(selectedId)` → router redirect re-evaluates → user lands on `/home`.
- On save error: catch, show `SnackBar` with retry, keep user on picker with selection preserved.

**Empty active-exam list (defensive):** picker shows `No exams available right now.` with no `Continue` affordance. The router still redirects here in this state; this is not a real user flow at launch but is the correct fallback if a future content-pack scenario produces zero active exams.

## Storage

`AppPreferencesRepository` gains two helpers alongside the existing `selectedExamId` / `setSelectedExamId`:

```dart
Future<bool> hasPassedAgeGate();
Future<void> setPassedAgeGate(bool value);
```

Both serialize to the existing `app_preferences_local` key/value table from Phase 1. New key: `passed_age_gate` (stored as `'true'` / `'false'` strings). No schema change; no migration.

A new `passedAgeGateProvider` (FutureProvider<bool>) is added to `lib/core/storage/storage.dart`, parallel to `activeExamFocusProvider`. It depends on `appPreferencesRepositoryProvider`.

Birth year itself is **not persisted**. The age gate captures the year as a one-shot question; only the boolean result is stored. This matches the privacy-minimal posture and the PRIVACY.md contract (which describes the mechanism, not the storage).

## Data Flow

```
Boot
  └─ Router runs redirect callback
      ├─ passedAgeGate=false, anywhere except /onboarding → /onboarding
      ├─ passedAgeGate=true, needsExamSelection=true, anywhere except /onboarding → /onboarding
      └─ passedAgeGate=true, needsExamSelection=false, at /onboarding → /home

Welcome step
  └─ Continue → step provider = ageGate

Age gate step
  ├─ valid year → setPassedAgeGate(true) → invalidate passedAgeGateProvider
  │              → refreshListenable fires → redirect re-runs
  │              → if needsExamSelection, step provider = picker
  │              → else router pulls user to /home
  └─ under-13 year → step provider = ageGateBlocked (internal sub-state)

Picker step
  └─ Continue → setSelectedExamId(id) → invalidate activeExamFocusProvider
             → refreshListenable fires → redirect re-runs
             → user lands on /home
```

## Edge Cases

| Case | Behavior |
|---|---|
| Save fails (Drift error) on age gate or picker | Catch, inline `SnackBar` with `Retry`, keep current step state. |
| Persisted exam id points to a removed exam | `activeExamFocusProvider` already returns `needsSelection`; user enters picker step only (age gate already passed). |
| Zero active exams | Picker renders empty state; no Continue. Defensive only. |
| User backgrounds the app mid-flow | State is in providers + persistence; on resume, internal step is recomputed from current pref values. No partial-progress restoration beyond what's persisted. |
| User completes age gate, then app crashes before picker | On relaunch, `passedAgeGate=true`, `needsExamSelection=true` → redirect sends to `/onboarding`, internal step starts at `picker` (skip welcome and age gate). |
| User is under 13, tries again with a different year | Allowed. The contract is "we ask, we block on the given answer," not "we permanently remember a failed attempt." Unenforceable to do otherwise. |

## Visual Design

- Token usage matches Phase 1: `colors.primary`, `colors.primaryContainer`, rounded 14–18px radii, system font stack. Welcome and age-gate illustrations are native Flutter shapes/Stacks, not SVG assets. Final illustration delivery is future visual-content work.
- Full-screen layout (no bottom nav, no app bar from the tab shell).
- Each step has the same top padding and header style so transitions feel like steps inside one flow, not three different screens.
- Step transitions: `AnimatedSwitcher` with a slide+fade. No progress dots — three steps with a forced order is simple enough that dots add noise.

## Testing Strategy

**Repository:**

- Extend `test/core/storage/data/repos/app_preferences_repository_test.dart`:
  - `hasPassedAgeGate` returns `false` when unset.
  - `setPassedAgeGate(true)` persists and is reflected by subsequent `hasPassedAgeGate`.
  - `setPassedAgeGate(false)` overwrites a `true` value.

**Provider:**

- New `test/core/storage/age_gate_provider_test.dart`:
  - returns `false` when preference is unset.
  - returns `true` after `setPassedAgeGate(true)`.

**Widgets:**

- `test/features/onboarding/presentation/onboarding_welcome_step_test.dart`: shows headline and subtitle; `Get started` triggers step callback.
- `test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`: valid year persists and triggers next-step callback; under-13 shows block headline without persisting; `Try a different year` returns to input.
- `test/features/onboarding/presentation/onboarding_picker_step_test.dart`: lists active exams as emblem cards; Continue disabled until selection; tapping a card enables Continue; Continue persists and triggers completion callback; save error shows SnackBar with selection preserved.

**Routing / redirect matrix:**

- New `test/app/router_redirect_test.dart` (or extension of `app_boot_test.dart`):
  - `passedAgeGate=false` + any selection state → boot lands on `/onboarding`.
  - `passedAgeGate=true` + `needsExamSelection=true` → boot lands on `/onboarding`.
  - `passedAgeGate=true` + valid selection → boot lands on `/home`.
  - Persisted invalid exam id → boot lands on `/onboarding`.

**Existing test updates:**

- `test/app/app_boot_test.dart` and `test/features/shell/app_shell_test.dart` (which currently pump `App` without setting prefs) must seed `passed_age_gate=true` *and* `selected_exam_id='cse'` to continue asserting `/home` rendering. Tests that want to assert onboarding redirect can leave the preferences unset.

## Acceptance Criteria

- `/onboarding` is a real flow, not a stub.
- A fresh-install user with two active exams sees Welcome → Age gate → Picker → Home on first launch.
- A returning user with a valid selection skips onboarding entirely.
- A returning user who lost their selection (e.g., content pack uninstall) sees only the picker.
- Under-13 birth year blocks in-screen with no persistence; user can retry without app uninstall.
- Both `passed_age_gate` and `selected_exam_id` are persisted in `AppPreferencesLocal`.
- Phase 1's per-tab choose-exam fallback cards remain reachable as a defensive backstop but are not the normal path.
- Birth year itself is not persisted.
- No new dependencies added (no `flutter_svg`, no extra packages).

## Self-Review

- **Placeholder scan:** none. Every requirement has a defined behavior.
- **Internal consistency:** the redirect matrix, the initial-step table, and the data-flow diagram all describe the same `(passedAgeGate × needsExamSelection)` state space without contradiction.
- **Scope check:** single implementation plan should cover this — repository helpers, one new provider, one route with three step widgets, redirect logic, tests. No decomposition needed.
- **Ambiguity check:** "year wheel" specifies `CupertinoPicker` to avoid a vague widget choice. "Sorted by `name` ascending" specifies picker order. The under-13 retry behavior is explicit. Storage of birth year is explicitly omitted.
- **Risk:** the router `refreshListenable` adapter is the one piece without existing precedent in this codebase. The plan should specify the exact bridge implementation (e.g., a `ChangeNotifier` that listens to provider invalidations) to remove ambiguity.
