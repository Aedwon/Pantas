# Spec 8 — Settings + Account (design)

**Status:** Brainstormed (2026-05-22).
**Depends on:** Spec 1 (Firebase Auth — `currentUserProvider`, Google Sign In, anon→named merge, sign-out flow), Spec 3 (`SyncCoordinator` — `user_settings` table participates in sync; `Stream<SyncStatus>` powers Backup detail), Spec 6 (Study Plan — exam date edit triggers rebalance + chip-on-next-/plan-visit per D4), Spec 7 (Paywall — Subscription detail screen defers entirely to §12; RevenueCat `restoreTransactions()`; `entitlementProvider`), Spec 9 (Notifications — local scheduling on reminder time save; permission status), Spec 10 (Legal — Privacy Policy / ToS / DPO email / Delete account Cloud Function).
**Cross-spec amendments this spec asks for:**
- **Spec 1** must resolve its open question: "Should sign-out wipe local Drift data?" Spec 8 writes conditional sign-out confirmation copy until that decision lands.
- **Spec 3** must include a `user_settings` table in its synced-tables list with `updated_at` for LWW conflict resolution.
- **Spec 5 (Onboarding)** gathers initial reminder time + exam date; Settings owns *later* editing of both (already resolved during Spec 7).
- **Spec 10 scope-cut flag**: in-app data export Cloud Function downgrades to "respond manually via DPO email" at v1; reconsider for v1.x if request volume warrants.
**Marketing pillar:** This is the trust surface. Settings is where the coach explains itself — backup status, account control, deletion paths, plain-language consequences. It is built for legibility, not density.

## 1. Overview

Spec 8 builds the **Settings tab** (fourth bottom-nav tab, locked in `ia_decisions`). It consists of a single entry screen (Settings home) with three section groups, plus four drill-down detail screens (Account, Subscription, Backup, About) and two modal pickers (exam date, daily reminder). Lightweight controls (theme, switches) live inline on the home screen; dense or destructive surfaces drill into their own screens. Preferences split into **synced** (exam date, reminder time, strict mock mode, analytics opt-out) and **device-local** (theme) buckets — synced prefs ride Spec 3's SyncCoordinator and conflict-resolve last-writer-wins by `updated_at`; theme is intentionally device-local because many users want different theme settings per device.

Account state is contextual: anonymous users see an explainer + "Sign in with Google" CTA + a quiet "Delete my data" row; named users see avatar + email header + Sign out + Delete account rows. Account deletion is a **dedicated confirmation screen** (not a dialog) with plain-language consequences written for a junior-high reading level — "you'll lose everything you've done in the app", "if you pay for Pro, you'll still be charged", "you can't undo this".

Backup is the user-facing destination for Spec 7's "save study progress across devices" sign-in nudges. Its detail screen shows plain-language status ("Your progress is saved", "Backing up your progress…", "You're offline", "Couldn't back up") with raw diagnostics (last-sync ISO, pending queue, network) collapsed behind a "Show details ▾" expand. Subscription detail defers entirely to Spec 7 §12 — Spec 8 owns the route wiring but not the copy.

About is minimal: app version + build, Privacy Policy + ToS (in-app web view, Sanity-sourced), Contact our DPO (mailto). **No in-app "Export my data"** — RA 10173 §18(d) portability is satisfied via the DPO contact; Spec 10's in-app export Cloud Function is downgraded to a v1.x candidate.

A single "Help improve the app" toggle (default ON) gates Firebase Analytics. The full custom-event taxonomy (the parking-lot doc) remains deferred to a post-launch telemetry spec; Spec 8 ships the consent surface only so we don't need to retrofit consent when the taxonomy lands.

## 2. In scope / non-goals

**In scope:**

- Settings home (entry screen) with three section groups: Preferences, Account, About.
- Inline controls on home: Theme picker (Light / Dark / System), Daily reminder row, Exam date row, Strict mock mode switch, "Help improve the app" switch.
- **Account detail screen** with anonymous + named variants, sign-in/sign-out flows, anon→named CTA, delete account entry.
- **Sign-out confirmation dialog** (small, dialog-shaped). Conditional copy pending Spec 1 resolution.
- **Delete account confirmation screen** (dedicated screen, not dialog) with plain-language consequence copy and destructive final button. Triggers Spec 10's deletion Cloud Function. Includes subscription-aware variant for Lifetime / active sub / Free users.
- **Subscription detail screen** scaffolding — content defers to Spec 7 §12. Spec 8 owns route + nav-back behavior only.
- **Backup detail screen** with five states (anonymous, saved, syncing, offline, failed). Plain-language status as primary; "Show details ▾" collapse for raw diagnostics (last-sync ISO, pending queue count, network status). "Sync now" action button on saved + failed states.
- **About detail screen** with app header (icon, name, version + build), Legal group (Privacy Policy, ToS), Data & privacy group (Contact our DPO), section footer pointing data requests to DPO email.
- "Send feedback" row on Settings home — opens `mailto:` to support address with pre-filled subject + device info body stub.
- **Exam date picker modal** (`showDatePicker`). On save: persist to Drift `user_settings`, trigger Spec 6's `rebalance()`, surface snackbar "Your study plan is being rebalanced", set chip-on-next-/plan-visit flag.
- **Daily reminder picker modal** (`showTimePicker`). On save: schedule local notification via Spec 9. Inline subtitle warning + OS-settings deep-link if notification permission denied.
- **Synced preferences** store: Drift `user_settings` table (`daily_reminder_time`, `strict_mock_mode`, `exam_date`, `help_improve_app`, `updated_at`). Participates in Spec 3 SyncCoordinator.
- **Device-local preferences** store: SharedPreferences (`theme_mode`).
- Analytics consent gate: `FirebaseAnalytics.setAnalyticsCollectionEnabled(bool)` driven by `help_improve_app` toggle. Crashlytics stays ON regardless.
- iOS-style switch widget (oval, green when on) for boolean toggles. Other widgets follow existing Material 3 styling.
- Hidden Debug screen reachable via long-press on About screen's version row **only** when `--dart-define=DEBUG_SETTINGS=true` build flag is set. Contains: Wipe local data, current entitlement state (interacts with Spec 7 `FAKE_PRO`), force-resync button, view raw last-sync ISO. Build flag must default `false` and be reject-on-build in release builds.

**Non-goals (deferred or explicitly not building):**

- Language toggle. No `flutter_localizations` infra; PH-market English-only at v1.
- Dark mode quality assurance on every screen. (Toggle ships because infra exists; visible-broken dark screens get fixed in implementation polish or the toggle gets hidden until they're fixed.)
- Reset progress (keep account, wipe study state). Different semantics from delete; no v1 user need; retention foot-gun. Revisit post-launch.
- Rate this app row. Google Play in-app review API requires careful triggering; surfacing from Settings drifts toward dark-pattern. Defer to post-launch from coached prompts.
- Profile editing (display name, photo). Duplicates Google account management; out-of-scope abuse moderation.
- Custom event taxonomy / firing custom analytics events from features. The toggle ships in Spec 8; the taxonomy remains parked at `docs/future/post-launch-revenue-and-telemetry.md`.
- In-app self-serve data export. RA 10173 portability satisfied via DPO email. Spec 10's Cloud Function is downgraded to v1.x.
- Visible "Wipe local data" row. Lives only behind `--dart-define=DEBUG_SETTINGS=true`.
- Quiet hours / Do Not Disturb logic for reminders. Defers to Spec 9.
- Subscription detail copy. Owned entirely by Spec 7 §12.
- Account deletion grace period ("delete in 30 days, cancel anytime"). Defers to Spec 10's open question.
- Theme cloud-sync. Theme is intentionally device-local.
- Visual polish pass (typography hierarchy, leading icons, status dots, spacing refinement). Captured as known follow-up; not blocking spec.

## 3. Locked decisions

| # | Question | Decision |
|---|---|---|
| D1 | Optional preferences scope (language toggle? dark mode toggle?) | Dark mode ships (Light / Dark / System chips, default System). Language toggle dropped — no localization infra; English-only at v1. |
| D2 | Settings information architecture | Hybrid: single scroll home page with section headers; lightweight controls inline (theme chips, switches); dense/destructive surfaces drill into detail screens (Account, Subscription, Backup, About). |
| D3 | Where does "Delete account" live? | Settings → Account hosts the destructive flow. Legal page (Spec 10) describes the right and deep-links to `/settings/account`. Single source of truth for the destructive flow. |
| D4 | Sync diagnostics visibility | "Backup" top-level row → detail screen with plain-language status as primary; raw diagnostics behind "Show details ▾" expand. Doubles as the destination for Spec 7's "save study progress across devices" sign-in nudges. |
| D5 | Dev/debug affordances + extras scope | Ship Send feedback (mailto). Hide debug surfaces behind `--dart-define=DEBUG_SETTINGS=true`. Skip Reset progress + Rate this app for v1. Crashlytics stays ON regardless of analytics toggle. |
| D6 | Account screen structure + delete confirmation flow | State-by-state Account screen (anon vs. named). Delete uses dedicated **confirmation screen**, not dialog. Plain-language consequence copy at junior-high reading level. Subscription-aware variant for Lifetime / active sub / Free. |
| D7 | Settings home section order | Preferences → Account → About (frequency-of-use ordering). |
| D8 | Synced vs. device-local preferences | Sync: exam date, daily reminder time, strict mock mode, `help_improve_app`. Local-only: theme. **Principle:** preferences about the user sync; preferences about the device don't. |
| D9 | Analytics scope in Spec 8 | Ship the opt-out toggle only ("Help improve the app", default ON). The full custom-event taxonomy stays parked for a post-launch telemetry spec. Foundation laid so consent doesn't retrofit later. |
| D10 | Toggle widget visual | iOS-style oval switch (green when on, gray when off) — Material defaults got pushback during brainstorm. Other widgets stay Material 3. |
| D11 | "Export my data" row | Not shipped in Spec 8 About screen. RA 10173 §18(d) portability satisfied via DPO email contact. Spec 10's in-app export Cloud Function downgraded to v1.x candidate. |

### 3.x Notes on rationale

- **D2 + D6** together prevent Settings from becoming a wall of rows. The home page stays scannable (≤4 rows per section); destructive and dense surfaces (Subscription has 6 state variants per Spec 7 §12; Backup has 5 states; Account has 2 + delete) get their own screens to breathe.
- **D3** picks Settings over Legal as the delete entry because that's where 95% of users will look. Burying it in "Legal" is technically compliant but UX-bankrupt. Privacy policy still describes the right and deep-links — so privacy-conscious users landing in Legal first reach the action in one tap.
- **D6** chooses a dedicated confirmation **screen** over a dialog because the consequences need paragraphs, friction is the feature (accidental delete is the failure mode), and Google/Apple guidelines both recommend dedicated screens for permanent destructive ops.
- **D8** separates user-intent prefs (sync) from device-shaped prefs (theme stays local) — many users want different themes per device, and a synced theme creates "why did my tablet flip to dark?" friction.
- **D9** ships consent ahead of the taxonomy. The user-facing concern is transparency; the taxonomy itself is a v1.x problem because we have no B2B prospects pre-launch. B creates the foundation; the taxonomy slot doesn't need to retrofit consent later.
- **D11** is a real scope-cut. RA 10173 doesn't mandate *self-serve in-app* export — handling portability via the DPO email is legally sufficient. We can revisit if request volume warrants the Cloud Function.

## 4. Information architecture

```
Settings (4th bottom-nav tab)
└── Settings home (entry — single scroll page)
    ├── Section: PREFERENCES (all inline)
    │   ├── Theme (chips: Light / Dark / System)
    │   ├── Daily reminder (row → time picker modal)
    │   ├── Exam date (row → date picker modal)
    │   ├── Strict mock mode (iOS-style switch)
    │   └── Help improve the app (iOS-style switch)
    ├── Section: ACCOUNT (drill-down rows)
    │   ├── Account (row → /settings/account)
    │   ├── Subscription (row → /settings/subscription)
    │   └── Backup (row → /settings/backup)
    └── Section: ABOUT (drill-down + action)
        ├── App info (row → /settings/about)
        └── Send feedback (row → mailto:)

Detail screens:
- /settings/account (state-by-state) → /settings/account/delete (confirmation screen)
- /settings/subscription (defers content to Spec 7 §12)
- /settings/backup (5 states, "Show details" expand)
- /settings/about

Modal overlays (not navigation):
- Exam date picker (showDatePicker)
- Reminder time picker (showTimePicker)

Debug-only (DEBUG_SETTINGS=true):
- About screen → long-press version → /settings/_debug
```

### 4.1 Module structure

```
lib/features/settings/
├── domain/
│   ├── pref_entities.dart         (SyncedPref vs DevicePref split, validation)
│   ├── user_settings.dart         (entity, freezed)
│   └── settings_repository.dart   (interface)
├── data/
│   ├── user_settings_table.dart   (Drift table definition — synced)
│   ├── device_prefs_store.dart    (SharedPreferences wrapper — local)
│   └── settings_repository_impl.dart
└── presentation/
    ├── settings_home_page.dart
    ├── pages/
    │   ├── account_page.dart
    │   ├── account_delete_confirmation_page.dart
    │   ├── subscription_page.dart        (refs Spec 7 §12 widgets)
    │   ├── backup_page.dart
    │   └── about_page.dart
    ├── pickers/
    │   ├── exam_date_picker.dart
    │   └── reminder_time_picker.dart
    ├── widgets/
    │   ├── ios_switch.dart
    │   ├── theme_chips.dart
    │   └── backup_status_card.dart
    └── providers/
        ├── settings_providers.dart       (userSettingsProvider, themeModeProvider)
        └── account_providers.dart        (accountStateProvider — wraps Spec 1)
```

**Boundary rule:** Settings code consumes providers from `auth/`, `sync/`, `paywall/`, `notifications/`, `legal/` — never reaches into their internals. Keeps Settings as a thin shell+controls feature.

## 5. Screen-by-screen design

### 5.1 Settings home (entry)

App bar: large title "Settings" (Material 3 large-app-bar style).

Sections (in order):

**PREFERENCES**

| Row | Control | Notes |
|---|---|---|
| Theme | Chips: `Light` `Dark` `System` (default System selected) | Inline. Writes to `themeModeProvider` (SharedPreferences). Wired into `MaterialApp.themeMode`. |
| Daily reminder | Row, subtitle = "7:00 PM" (or "Not set"), `›` chevron | Tap → reminder time picker modal. If notification permission denied, subtitle = "Notifications are off — tap to enable" + tap routes to OS settings via `app_settings` package. |
| Exam date | Row, subtitle = "Sep 14, 2026 · 16 weeks to go" (or "Not set — tap to add"), `›` chevron | Tap → date picker modal. On save, triggers Spec 6 rebalance + chip flag. |
| Strict mock mode | Row, subtitle = "Removes pause during mock exams", iOS-style switch | Default OFF. Read by Spec 5 mock exam to gate pause behavior. |
| Help improve the app | Row, subtitle = "Share anonymous usage data", iOS-style switch | Default ON. Gates `FirebaseAnalytics.setAnalyticsCollectionEnabled`. Crashlytics independent. |

**ACCOUNT**

| Row | Subtitle | Behavior |
|---|---|---|
| Account | Email if named ("aerol.balayon@gmail.com") OR "Signed in anonymously" | Tap → `/settings/account`. |
| Subscription | Tier + renewal ("Pro · Yearly · renews Apr 12, 2027") OR "Free · Try Pro" — driven by Spec 7's `entitlementProvider` + RevenueCat `priceString` | Tap → `/settings/subscription` (defers to Spec 7 §12). |
| Backup | Live status ("Your progress is saved · 2m ago" / "Backing up… 3 items" / "Sign in to back up your progress" for anon / "Couldn't back up" for failed) | Tap → `/settings/backup`. |

**ABOUT**

| Row | Subtitle | Behavior |
|---|---|---|
| App info | "Version 1.0.0 · Legal · Contact DPO" | Tap → `/settings/about`. |
| Send feedback | (none) | Tap → `mailto:support@<domain>?subject=Feedback&body=<pre-filled device+version stub>`. |

### 5.2 Account detail (`/settings/account`)

**Anonymous variant:**

```
[← Account]

  ┌────────────────────────────────────────┐
  │ Your progress is saved on this device. │
  │ Sign in to back it up and use it on    │
  │ other devices.                         │
  └────────────────────────────────────────┘

  [ 🟦 Sign in with Google ]

  ...

  Delete my data                      ›
```

- Sign in CTA → Spec 1's Google Sign In flow. Success triggers Spec 1's anon→named merge. Snackbar on return: "Welcome — your progress is now backed up."
- "Delete my data" row at bottom (quieter weight; not destructive-red because anonymous deletion is lower-stakes — only wipes anon UID's cloud copy + local data). Tap → `/settings/account/delete` with anonymous-variant copy.

**Named variant:**

```
[← Account]

  ┌──────────┐
  │  [A]     │  Aerol Balayon
  │          │  aerol.balayon@gmail.com
  └──────────┘

  Sign out                            ›
  Delete account                      ›   (destructive red)
```

- Profile is read-only (no edit). Avatar from Google account photo; falls back to initial letter.
- Sign out → small confirmation dialog (see §5.3).
- Delete account → `/settings/account/delete` with named-variant copy.

### 5.3 Sign-out confirmation (dialog)

Small Material dialog (not a full screen — sign-out is reversible). Copy depends on Spec 1's resolution of "Does sign-out wipe local Drift data?":

- **If Spec 1 says local data is preserved** (resumes-as-anon): "Sign out of your account? Your study progress will stay on this device."
- **If Spec 1 says local data is wiped:** "Sign out? Your study progress on this device will be cleared. You can sign back in to restore it."

**Edge case — pending sync queue:**
- If `pending_queue_size > 0`: dialog adds a third line — "You have N items not yet backed up. Sign out anyway?" with destructive-tinted confirm button.

Confirm button: "Sign out". Cancel button: "Cancel".

### 5.4 Delete account confirmation (`/settings/account/delete`)

**Dedicated screen**, not a dialog. Standard app bar (`[← Delete account]`).

```
Delete your account?

📚  You'll lose everything you've done in the app —
    your streaks, your study plan, your quiz history,
    your mock exam results, and everything we've
    learned about how you study.

💳  [subscription-aware line — see below]

⚠️  You can't undo this.

  [ Cancel ]
  [ Yes, delete my account ]    (destructive red)
```

**Subscription-aware middle line:**

| Tier | Line |
|---|---|
| Free | (line is omitted entirely) |
| Pro Monthly or Pro Yearly (active) | "If you pay for Pro, you'll still be charged. Cancel your subscription in Google Play first so the billing stops." |
| Pro Yearly in 7-day trial | "Your free trial will end if you delete now. If you've already been charged, cancel in Google Play first to stop future billing." |
| Pro Lifetime | "You bought Pro Lifetime on this account. If you delete, you'll lose Pro access. You can restore it on a new account with Restore Purchases." |
| Pro cancelled (won't renew) | "Your Pro access ends on [date]. Deleting your account ends it sooner." |

**Anonymous variant copy (shorter):**

```
Delete your data?

📚  Your progress on this device will be permanently
    deleted. Sign in first if you want to keep it.

⚠️  You can't undo this.

  [ Cancel ]
  [ Yes, delete my data ]   (destructive red)
```

**Anonymous + Lifetime edge case (rare but real):** if anonymous user has Lifetime purchase, prepend a warning: "You haven't signed in. If you delete now, you'll lose your Lifetime purchase on this device. Sign in first to keep it."

**On final tap:**
1. Show full-screen loading state ("Deleting your account…").
2. Call Spec 10's deletion Cloud Function via Firebase Functions client.
3. On success: sign user out, clear local Drift data, navigate to `/onboarding` welcome screen.
4. On failure: show error state with retry + "Contact our DPO" fallback link.

### 5.5 Subscription detail (`/settings/subscription`)

**Owned by Spec 7 §12.** Spec 8 only contains:
- Route wiring in `router.dart`.
- A `SubscriptionPage` widget that delegates body content to Spec 7's `SubscriptionStatusPanel` widget (per Spec 7 §12's six-state copy table).
- App bar with back navigation.

No copy or layout decisions duplicated here. If Spec 7 §12 amends, Spec 8 follows.

### 5.6 Backup detail (`/settings/backup`)

Status-card-driven layout. Five states from `backupStatusProvider` (which consumes Spec 3's `Stream<SyncStatus>`):

| State | Icon | Headline | Sub | Primary action | Secondary |
|---|---|---|---|---|---|
| Anonymous | ☁️ | "Your progress isn't backed up" | "Sign in to save your progress across devices." | "Sign in with Google" | (none) |
| Saved | ✓ (green) | "Your progress is saved" | "Last backed up 2 minutes ago" | "Sync now" (outline) | Show details ▾ |
| Syncing | spinner | "Backing up your progress…" | "3 items left" | (none) | Show details ▾ |
| Offline | 📡 | "You're offline" | "Your progress will back up when you reconnect." | (none — automatic on reconnect) | Show details ▾ |
| Failed | ⚠️ (red) | "Couldn't back up" | "Last successful backup: 3 hours ago. Tap to try again." | "Try again" (filled) | Show details ▾ |

**Show details ▾** expand reveals:
- Last sync ISO timestamp (e.g., `2026-05-22T14:32:08.412Z`).
- Pending queue size (`pending_queue_size`).
- Network status (Wi-Fi / cellular / offline + connection quality if available).

Power-user surface only. Default collapsed.

### 5.7 About detail (`/settings/about`)

```
[← About]

         📚
    CSE Reviewer
   Version 1.0.0 (build 142)

LEGAL
  Privacy Policy                      ›
  Terms of Service                    ›

DATA & PRIVACY
  Contact our DPO                     ›
  dpo@<domain>

  For data export, correction, or other privacy
  requests, email our Data Protection Officer.
```

- Privacy Policy / ToS rows open in-app web view (or Sanity-sourced markdown render via Spec 10).
- Contact our DPO → `mailto:dpo@<domain>?subject=Privacy%20Request`.
- Section footer is plain copy, not a button.
- Build number sourced from `package_info_plus`.
- **No Export my data row** — see D11.

### 5.8 Picker modals

**Exam date (`showDatePicker`):**
- Initial date: current `user_settings.exam_date` if set; else "today + 6 months".
- Validation: date must be ≥ tomorrow. Past dates disabled. (If Spec 6 later decides past dates are auto-extended, this validator updates accordingly.)
- On save:
  1. Write to Drift (`exam_date`, `updated_at = now`).
  2. Call `studyPlanService.rebalance()` (Spec 6).
  3. Set `planRebalancedFlag` for next `/plan` visit (Spec 6 D4 chip).
  4. Show snackbar in Settings: "Your study plan is being rebalanced."
- SyncCoordinator picks up the write within 5s debounce window.

**Daily reminder (`showTimePicker`):**
- Initial time: current `user_settings.daily_reminder_time` if set; else 19:00 (7:00 PM).
- No validation (all times valid).
- On save:
  1. Write to Drift.
  2. Call Spec 9's `notificationService.scheduleDailyReminder(time)`.
  3. Show snackbar: "Daily reminder set for 7:00 PM."
- If notification permission not granted: post-save flow checks permission and surfaces a follow-up snackbar with "Enable notifications" action that deep-links to OS settings.

### 5.9 Hidden Debug screen (`/settings/_debug`)

Visible **only** when `--dart-define=DEBUG_SETTINGS=true`. Reached via long-press on About screen's version row. CI build verification ensures the flag cannot exist in release builds (mirrors Spec 7's `FAKE_PRO` defense pattern).

Contents:
- **Wipe local data** button — clears Drift `user_settings`, `device_settings`, all user-data tables. Confirmation dialog.
- **Current entitlement state** — shows `entitlementProvider.value`, RevenueCat `CustomerInfo` JSON, current `FAKE_PRO` flag.
- **Force resync** — calls `SyncCoordinator.forceFlush()`.
- **Raw last-sync** — shows the ISO timestamp + queue size + network status.
- **Mock notification permission states** — toggle for QA to test the "permission denied" subtitle.

## 6. Data flow & storage

### 6.1 Two stores, one repository

```dart
abstract class SettingsRepository {
  Stream<UserSettings> watchUserSettings();
  Future<void> updateExamDate(DateTime date);
  Future<void> updateReminderTime(TimeOfDay time);
  Future<void> updateStrictMockMode(bool enabled);
  Future<void> updateHelpImproveApp(bool enabled);

  Stream<ThemeMode> watchThemeMode();
  Future<void> updateThemeMode(ThemeMode mode);
}
```

Implementation wires:
- Synced fields → Drift `user_settings` table (single row keyed by `uid`).
- Theme mode → SharedPreferences (`theme_mode` string).

### 6.2 Drift table

```dart
class UserSettingsTable extends Table {
  TextColumn get uid => text()();           // primary key (Firebase Auth UID)
  TextColumn get dailyReminderTime => text().nullable()();   // "HH:mm"
  BoolColumn get strictMockMode => boolean().withDefault(const Constant(false))();
  DateTimeColumn get examDate => dateTime().nullable()();
  BoolColumn get helpImproveApp => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();              // LWW conflict resolution
  @override
  Set<Column> get primaryKey => {uid};
}
```

**Spec 3 cross-spec note:** This table must be added to SyncCoordinator's synced-tables list. `updatedAt` drives last-writer-wins resolution.

### 6.3 Device-local prefs

`SharedPreferences` keys:
- `theme_mode` → `"light" | "dark" | "system"` (default `"system"`).

Never synced. No `updatedAt`. Per-device.

### 6.4 Riverpod providers

| Provider | Type | Source |
|---|---|---|
| `userSettingsProvider` | `StreamProvider<UserSettings>` | Drift stream via repo |
| `themeModeProvider` | `StateNotifierProvider<ThemeModeController, ThemeMode>` | SharedPreferences |
| `accountStateProvider` | `Provider<AccountState>` | Wraps Spec 1's `currentUserProvider` + emits anon/named/loading/error |
| `subscriptionStateProvider` | (re-exports Spec 7's `entitlementProvider`) | Spec 7 |
| `backupStatusProvider` | `StreamProvider<BackupStatus>` | Wraps Spec 3's `Stream<SyncStatus>` |

UI widgets only consume these aggregates.

### 6.5 Write flow (synced pref change)

1. User taps Save in picker / toggles switch.
2. Repository writes to Drift (sets `updated_at = now`).
3. UI updates immediately from Drift stream (offline-first).
4. SyncCoordinator's debounced push (5s window) flushes Drift `user_settings` row to Firestore `/users/{uid}/settings/prefs`.
5. On conflict: server's `updated_at` vs. local's `updated_at`; later wins.

### 6.6 Analytics gating

- Toggle ON: `await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);` — Firebase Analytics fires default events (`screen_view`, `session_start`, etc.).
- Toggle OFF: `setAnalyticsCollectionEnabled(false);` — events suppressed. Note SDK behavior: existing in-memory events may still flush on next session start; document this in privacy policy.
- Crashlytics: independent — `FirebaseCrashlytics.setCrashlyticsCollectionEnabled(true)` stays on regardless.
- Privacy policy (Spec 10) must declare Firebase Analytics + RevenueCat + Crashlytics as data processors with purposes.

## 7. Cross-spec dependencies

### 7.1 Spec 8 consumes (waits on)

| Spec | What Spec 8 needs | Hard? |
|---|---|---|
| Spec 1 | `currentUserProvider`, Google Sign In flow, anon→named merge, sign-out flow, decision on whether sign-out wipes local data | Hard |
| Spec 3 | `Stream<SyncStatus>`, `syncNow()` API, `pending_queue_size`, network status, addition of `user_settings` table to synced-tables list | Hard |
| Spec 6 | `studyPlanService.rebalance()` callable + chip-on-next-/plan-visit flag mechanism (D4) | Hard |
| Spec 7 | `SubscriptionStatusPanel` widget (or equivalent), `entitlementProvider`, RevenueCat `restoreTransactions()`, Manage in Google Play deep-link | Hard |
| Spec 9 | `notificationService.scheduleDailyReminder(time)`, permission status query, `app_settings` deep-link wiring | Hard |
| Spec 10 | Privacy Policy + ToS pages, DPO email address, Delete account Cloud Function endpoint, deep-link target from Legal → `/settings/account` | Hard |

### 7.2 Spec 8 surfaces (other specs consume)

| Spec | What they read from us |
|---|---|
| Spec 5 (Onboarding) | Onboarding's reminder time + exam date steps write to the same `user_settings` row; Settings reads on first open. |
| Spec 5 (Mock exam) | Reads `strict_mock_mode` to gate pause behavior. |
| Spec 6 (Study Plan) | Reads `exam_date`. |
| Spec 9 (Notifications) | Reads `daily_reminder_time` for local notification scheduling. |
| Spec 10 (Legal) | Deep-links to `/settings/account` from Privacy Policy's "right to deletion" description. |

### 7.3 Scope-cut flags raised by this brainstorm

- **Spec 10:** in-app data export Cloud Function downgrades to "respond manually via DPO email" at v1. Revisit for v1.x if request volume warrants.
- **Spec 1:** open question "Does sign-out wipe local Drift data?" — Spec 8 writes conditional sign-out confirmation copy until Spec 1 brainstorm resolves this.
- **Spec 6:** open question "exam date in past — auto-extend or warn?" — Spec 8's date picker disables past dates by default; behavior changes if Spec 6 chooses auto-extend.
- **Spec 3:** must add `user_settings` table to its synced-tables list with `updated_at` LWW.

## 8. Testing strategy

### 8.1 Unit tests (`test/features/settings/`)

| Layer | Coverage |
|---|---|
| Domain | `SyncedPref` vs `DevicePref` classification. Validation: exam date must be ≥ tomorrow; reminder time non-null. |
| Repository | Drift round-trip for `user_settings`. SharedPreferences round-trip for theme. `updated_at` bumped on every write. |
| Notifiers | `ThemeModeController` reads + writes SharedPreferences. `SettingsRepositoryImpl.updateExamDate()` calls Spec 6's rebalance hook (service mocked). |

### 8.2 Widget tests

- Settings home renders correctly for 4 state combos: (anon, named) × (Free, Pro Yearly).
- Edge: anonymous user with active purchase — Subscription row should show Pro subtitle even with anon Account row.
- Account screen renders anon vs. named variants from `accountStateProvider`.
- Delete confirmation screen renders correct subscription-aware line for each of 5 tier cases.
- Backup detail renders all 5 states from a faked `SyncStatus` stream.
- Picker modals: dismissal preserves value; save commits + fires side effects (verified with mocked Spec 6 + Spec 9 services).
- Analytics toggle OFF → `FirebaseAnalytics.setAnalyticsCollectionEnabled(false)` called.

### 8.3 Integration tests (`integration_test/`)

- Full edit-exam-date flow: tap row → modal → save → snackbar → navigate to `/plan` → chip visible.
- Full delete-account flow (mocked Cloud Function): tap row → confirmation screen → "Yes, delete" → loading state → success → onboarding redirect.

### 8.4 Edge cases with explicit coverage

| Case | Handling |
|---|---|
| User toggles off "Help improve the app" mid-session | Stop firing custom events immediately; Firebase Analytics disabled on next launch (SDK quirk). |
| Notification permission revoked from OS after reminder was set | Reminder row shows inline subtitle warning; tap routes to OS settings via `app_settings`. |
| Network drops while editing exam date | Save still completes (offline-first via Drift); SyncCoordinator queues the write. Snackbar still fires. Spec 6 rebalance runs locally. |
| User taps "Sign out" with pending sync queue | Confirmation dialog adds: "You have N items not yet backed up. Sign out anyway?" |
| Anonymous user has Lifetime purchase, taps "Delete my data" | Confirmation prepends warning: "You haven't signed in. If you delete now, you'll lose your Lifetime purchase on this device. Sign in first to keep it." |
| User edits exam date to be in the past | Picker validation disables past dates by default. (Behavior changes if Spec 6 chooses auto-extend.) |
| App update changes settings schema | Drift migration adds new columns with defaults. No data loss. |
| Pro entitlement transitions Free → Pro mid-app | `subscriptionStateProvider` recomputes; Settings → Subscription row subtitle updates live (StreamProvider). |
| User on Pro Lifetime taps Delete account | Confirmation shows "you'll lose Lifetime access on this account — restore on a new account via Restore Purchases" line. |
| Anonymous user with no internet taps "Delete my data" | Confirmation works; Cloud Function call queues until network returns; loading state shows "Will delete when online" + cancel option. |
| Theme mode changed on Device A, syncs blocked on Device B | Theme is device-local — no sync attempt. Each device independent. |

## 9. Known follow-ups (not blocking spec)

- **Visual polish pass** during implementation: section header color, divider treatment (hairlines vs. whitespace-only), leading icons per row, status dot on Backup row, "App info" subtitle is overloaded ("Version 1.0.0 · Legal · Contact DPO" — reads as tagline). Aim for Apple HIG-quality polish per `feedback_apple_ui_reference` memory.
- **Spec 10 amendment:** downgrade in-app export Cloud Function to v1.x candidate; replace with DPO-email manual workflow at v1.
- **Spec 3 amendment:** add `user_settings` to synced-tables list with `updated_at` LWW.
- **Spec 1 resolution:** "Does sign-out wipe local Drift data?" determines Spec 8 sign-out copy.
- **Spec 6 resolution:** "Exam date in past — auto-extend or warn?" determines Spec 8 picker validation.
- **Post-launch telemetry spec:** custom event taxonomy still parked at `docs/future/post-launch-revenue-and-telemetry.md`. Spec 8 ships the consent surface; the taxonomy lands separately.
- **Dark mode QA:** every screen in the app needs dark-theme review during implementation polish. If broken anywhere, either fix or hide the Dark/System chips until they're fixed.

## 10. Open questions deferred to v1.x

- In-app data export Cloud Function (Spec 10 scope-cut).
- Custom event taxonomy and product-analytics dashboards (parking-lot doc).
- Quiet hours / Do Not Disturb for daily reminder (defers to Spec 9).
- Reset progress affordance (different from delete — keeps account, wipes study state). Revisit if user demand surfaces post-launch.
- Profile editing (display name, photo). Out-of-scope per Spec 8 D6.
- Rate this app prompt — defer to a coached-prompt design post-launch.
- Multi-device theme sync — intentional v1 decision (D8); revisit only if user complaints surface.
