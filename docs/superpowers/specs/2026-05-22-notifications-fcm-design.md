# Spec 9 — Notifications (design)

**Status:** Brainstormed (2026-05-22).
**Depends on:** Spec 1 (Firebase init, `currentUserProvider`, `LocalStateWiper.wipeAll()` seam, sign-out flow), Spec 4 (`streakStateProvider`, Today's Session completion event, streak freeze accounting), Spec 6 (`studyPlanService.computePlanView()` Today headline + plan-state classification), Spec 8 (Settings — `user_settings.daily_reminder_time` row, reminder-time picker callback, "Notifications are off — tap to enable" recovery subtitle).
**Cross-spec amendments this spec asks for:**
- **Spec 1** sign-out flow gains a single call to `notificationService.cancelAll()` inside the existing `LocalStateWiper.wipeAll()` path.
- **Spec 4** Today's-Session completion path (the same code that fires the streak event) calls `notificationService.onSessionCompleted()` to cancel any pending streak-save for the day.
- **Spec 6** `computePlanView()` must be safe to call from non-UI code (the reschedule use case runs from an app-lifecycle observer, possibly before any UI mounts). Already aligned with Spec 6's compute-on-read design — confirmation, not change.
- **Spec 8** reminder-time picker save callback calls `notificationService.scheduleDailyReminder(time)` — already in Spec 8 §5.8.
- **Spec 10** account-deletion flow calls `notificationService.cancelAll()` client-side before the Cloud Function fires.
**Marketing pillar:** This is the coach reaching out. Spec 9 is the off-app extension of the coach voice — calm, friendly, plain — that the rest of the app already established. It is the first thing a 14-year-old sees in their notification shade from this app, so the bar for warmth is high.

## 1. Overview

Spec 9 adds two **local notifications** to the app — a daily reminder at the user's chosen time and a streak-save warning that fires before bedtime when an active streak is at risk. Both are scheduled via `flutter_local_notifications` on the device; **no FCM token registration and no server-driven push ship in v1** — those defer to v1.1 because nothing on the server sends pushes yet, so storing tokens is dead weight that also adds work to Spec 10's RA 10173 deletion path.

The daily reminder body is **templated from Spec 6's `computePlanView()` Today headline** so the notification voice matches the in-app coach voice exactly: same words, same plan state, same warmth register. Streak-save uses its own small template family tiered by streak length, with a distinct variant when a streak freeze is available (visible-state principle — never silently consume a freeze).

Permission is asked **once**, at the end of onboarding, behind an in-app rationale page. There is no auto-re-prompt anywhere — recovery is via Spec 8's existing "Notifications are off — tap to enable" subtitle that deep-links to OS settings. Both notifications tap-route to the **Today's Session intro screen** (the same destination Spec 6's home plan card uses). Stale-tap (>4h after scheduled fire time) falls back to Home.

The whole feature is designed for additive iOS work later: scheduling is hidden behind a `NotificationsGateway` interface, `flutter_local_notifications` already supports both platforms, and the v1.x iOS surface is APNs auth key + `Info.plist` entitlements — no Dart-side refactor.

## 2. In scope / non-goals

**In scope:**

- Two local notifications: **daily reminder** + **streak-save warning**. Both via `flutter_local_notifications` with `setExactAndAllowWhileIdle` / `AndroidScheduleMode.exactAllowWhileIdle`.
- Daily-reminder body composed at schedule time from Spec 6's `computePlanView().today`, with state-specific titles and bodies (standard / mock / behind / calm / first-post-diagnostic).
- Streak-save fires at `min(20:00, daily_reminder_time − 1h)` when the streak is alive and today's session is incomplete. Tiered copy by streak length (1 / 2–6 / 7–29 / 30+). Streak length `{N}` is interpolated into both title and body where present.
- Streak-save freeze variant — when `freezesRemaining > 0`, body explicitly surfaces the freeze ("If you skip, your streak's freeze will save it — 1 left this month").
- Reschedule on four triggers: app foreground (idempotent), reminder-time picker save (Spec 8), Today's Session completion (Spec 4), day-boundary cross while foregrounded.
- Permission rationale page shown once per install at end of onboarding (gated by `notification_rationale_shown` SharedPreferences flag).
- `permissionStatusProvider` streaming `notYetAsked | granted | denied`, refreshed on app foreground.
- `notificationServiceProvider` public surface: `scheduleDailyReminder(time)`, `onSessionCompleted()`, `rescheduleForForeground()`, `requestPermission()`, `cancelAll()`.
- Notification tap deep-link to `/quiz/today` (Today's Session intro). Stale-tap (>4h late) fallback to Home. Plan-not-ready fallback to Home.
- `flutter_local_notifications`, `timezone`, and `app_settings` package additions to `pubspec.yaml`.
- Anonymous + named users both get the full local-notification flow (no auth gating).
- Cancel-all on sign-out (Spec 1 amendment) and on account deletion (Spec 10 amendment).
- iOS structure additive — gateway interface ready, current impl already supports iOS, but no APNs key, `Info.plist` entitlements, or iOS-side QA in v1.

**Non-goals (deferred or explicitly not building):**

- FCM token registration, storage, rotation, or sender Cloud Function. Defers to v1.1 (no v1 server pushes anything).
- Server-driven re-engagement pushes ("haven't studied in 3 days", "your plan changed"). v1.1.
- Mock-week reminder ("tomorrow is a mock day"). Revisit after user-test feedback on the streak-save validates the second-notification register.
- Multi-variant copy rotation (anti-notification-blindness). Spec 6 plan-state variation already produces day-to-day variance for free; revisit if post-launch shows habituation.
- User-configurable quiet hours (custom "no notifications between X and Y"). v1 has fixed `min(20:00, ...)` math for streak-save; daily reminder time is the only user-visible knob.
- Per-user-timezone-change handling. Device timezone via `tz` package; rare in PH market.
- In-app catch-up banner ("you haven't studied today") on Home. Spec 6's home plan card already does this — Spec 9 doesn't duplicate.
- Notification telemetry events (open / dismiss / time-to-action). Parked at `docs/future/post-launch-revenue-and-telemetry.md` per `post_launch_revenue_telemetry` memory.
- iOS APNs auth key, `Info.plist` entitlements, iOS-side notification UX QA. v1.x additive when Apple enrollment lands.
- Rich notifications (images, action buttons, inline replies). Plain text + tap-to-open only.
- Quiet hours observability dashboard / kill switch. Solo-founder ops risk-accepted; can be cancel-all'd via Spec 8's Settings UI on a per-device basis.

## 3. Locked decisions

| # | Question | Decision |
|---|---|---|
| D1 | Notification surface scope | **Daily reminder + streak-save**, both local. No mock-week reminder in v1. |
| D2 | FCM token + server push timing | **Deferred to v1.1.** Nothing on the server sends pushes in v1, so token storage is YAGNI and adds Spec 10 deletion work. |
| D3 | Daily-reminder body strategy | **Templated from Spec 6's Today headline.** Same coach voice as the in-app plan card. State-specific titles + bodies. Streak-save has its own small template family. |
| D4 | Streak-save fire time | **`min(20:00, daily_reminder_time − 1h)`.** Daily reminder time itself is unconstrained — user can pick 22:30 if they want — but the streak-save extra notification is capped before bedtime. |
| D5 | Permission ask timing + re-request | **Once at end of onboarding** via in-app rationale page → OS prompt. **No auto-re-prompt** anywhere. Recovery via Spec 8's existing "Notifications are off — tap to enable" subtitle that deep-links to OS settings. |
| D6 | Notification tap destination | **Today's Session intro screen** (`/quiz/today`) for both notifications. Stale-tap (>4h late) → Home. Plan-not-ready → Home. |
| D7 | Anonymous users | Same flow. No auth gating. Local notifications work regardless of auth state. |
| D8 | Body freshness mechanism | **Reschedule on every app foreground.** Cheap, idempotent, keeps the coach voice live. Stale data only if user doesn't open the app — self-corrects next foreground. |
| D9 | Streak freeze visibility | When `freezesRemaining > 0`, streak-save fires anyway with a distinct body that surfaces the freeze. **Never silently consume a freeze** — user gets to decide. |
| D10 | Tone register | Friendly, junior-high reading level, warm coach voice. Never scoldy. Never salesy ("no spam, no ads" language explicitly rejected — too markety for a coach). |
| D11 | iOS deferral structure | Additive: `NotificationsGateway` interface + `flutter_local_notifications` impl already supports both platforms. v1.x = APNs key + `Info.plist`, no Dart refactor. |

### 3.x Notes on rationale

- **D1** rejects the minimal (daily-only) and maximal (daily + streak-save + mock-week) options. Daily-only is too thin for the coach positioning; mock-week adds copy-QA surface that hasn't earned its place yet without real user feedback on the streak-save first.
- **D2** is the same defer-when-no-sender logic this repo already applies to Apple Sign In, iOS App Check, and APNs key. Tokens without a sender are dead weight and also create RA 10173 deletion-path work for Spec 10.
- **D3** keeps the coach voice coherent. The notification body matching the in-app Today headline word-for-word makes the app feel like one coach, not "the app" plus "a notification system".
- **D4** rejects hard-capping the daily reminder time as paternalistic — some users genuinely study late and Spec 8's picker shouldn't impose a max. But the streak-save is an *extra* notification stacked on top of the daily reminder, and stacking it at 22:00 on top of a 22:30 reminder is the actual annoying pattern. The `min(20:00, ...)` math anchors streak-save earlier without restricting the user's primary choice.
- **D5** picks the diagnostic-completion moment as the value anchor. The user has just seen their Study Plan kick in — the ask is contextual ("your plan is set, want a daily check-in?") and the rationale screen primes the OS prompt to reduce reflex-denies. No re-prompts means we never feel like we're nagging.
- **D6** matches `ui_ux_simplicity_intentionality` (one primary CTA) and the notification's promise — the body says "14 questions to review", the destination confirms "14 reviews + 1 lesson queued, ready to begin". Stale-tap fallback to Home avoids surprising the user with a session they may not remember opting into hours ago.
- **D9** is `monetization_no_churn` extended to non-monetization state: any limited resource the user owns (freezes are 2/month) should be visible at the decision moment. Silently consuming a freeze because we didn't fire the streak-save is bad UX even though it "saved" the streak.
- **D10** the explicitly-rejected line was "That's it — no spam, no ads, no nighttime buzzing" in the rationale page draft. User feedback: that sounds like the app is still selling something. A coach doesn't disclaim — it shows up.

## 4. Architecture

### 4.1 Module layout

```
lib/features/notifications/
├── domain/
│   ├── reminder_schedule.dart            (entity: planned fire times + composed bodies for today)
│   ├── streak_save_policy.dart           (quiet-hour math, eligibility check)
│   ├── notification_body_composer.dart   (Study Plan headline → daily body; streak length → streak-save body)
│   ├── notification_permission.dart      (enum: notYetAsked | granted | denied)
│   └── use_cases/
│       ├── schedule_today_reminders.dart (cancel + reschedule pair on every foreground)
│       ├── handle_session_completed.dart (cancel today's streak-save)
│       └── handle_reminder_time_changed.dart (called by Spec 8 picker save)
├── data/
│   ├── notifications_gateway.dart                (interface)
│   └── flutter_local_notifications_gateway.dart  (impl using flutter_local_notifications + timezone)
└── presentation/
    ├── permission_rationale_page.dart    (in-app rationale before OS prompt)
    ├── tap_handler.dart                  (deep-link router: notification payload → /quiz/today | /home)
    ├── lifecycle_observer.dart           (calls rescheduleForForeground() on AppLifecycleState.resumed)
    └── providers/
        └── notifications_providers.dart  (notificationServiceProvider, permissionStatusProvider, gateway, schedule)
```

### 4.2 Packages added to `pubspec.yaml`

- `flutter_local_notifications: ^17.x` — scheduling, OS permission API, payload delivery on tap.
- `timezone: ^0.9.x` — required by flutter_local_notifications for `tz.TZDateTime` zoned scheduling.
- `app_settings: ^5.x` — confirms the dependency that Spec 8 §5.8 already calls out for the OS settings deep-link.

`firebase_messaging: ^15.1.3` stays in `pubspec.yaml` but Spec 9 does **not** initialize a token, subscribe to topics, or register message handlers. The package is kept so the v1.1 server-push work is additive (no new dep, just new code paths).

### 4.3 Boundary rule

The notifications feature **consumes** these providers from other features and never reaches into their internals:

- `studyPlanService.computePlanView()` (Spec 6)
- `streakStateProvider` (Spec 4)
- `userSettingsProvider.daily_reminder_time` (Spec 8)
- `currentUserProvider` (Spec 1 — only to know if onboarding is complete enough to schedule)

The single public surface other features call is `notificationServiceProvider`. Settings reaches in via `scheduleDailyReminder(time)`; Quiz session-complete reaches in via `onSessionCompleted()`; the app lifecycle reaches in via `rescheduleForForeground()`; Auth sign-out / Account delete reach in via `cancelAll()`. No other surface is exposed.

### 4.4 `NotificationService` interface

```dart
abstract class NotificationService {
  Future<void> scheduleDailyReminder(TimeOfDay time);
  Future<void> onSessionCompleted();
  Future<void> rescheduleForForeground();
  Future<NotificationPermission> requestPermission();
  Future<void> cancelAll();
}
```

All methods are idempotent; calling `rescheduleForForeground()` ten times in a row is safe (cancel-all then schedule-two). All methods are safe to call before the user has granted permission — they no-op gracefully if the OS will not allow scheduling.

### 4.5 iOS additive structure

`NotificationsGateway` is the platform seam. The v1 impl is `flutter_local_notifications`-based and already supports iOS — meaning the dormant iOS paths in the package work today; they just have no permission entitlements or APNs key to authenticate against.

v1.x iOS launch work (after Apple enrollment funded):
1. APNs auth key in Firebase Console → uploaded to RevenueCat (Spec 7 also touches this; coordinated).
2. `ios/Runner/Info.plist` entitlements: notification background mode if v1.1 server push has shipped, otherwise just the basic foreground notification entitlement.
3. `flutter_local_notifications` iOS init in `main.dart`: confirm `requestSoundPermission` / `requestAlertPermission` / `requestBadgePermission` flags.
4. Real-device QA on a TestFlight build for fire-time-when-screen-locked behavior.

Zero Dart-side refactor needed. The gateway interface, body composer, schedule policy, and providers are platform-agnostic.

## 5. Scheduling logic

### 5.1 Daily reminder

- **Fire time:** `user_settings.daily_reminder_time` (string `"HH:mm"`, default `"19:00"` per Spec 8 §5.1). Parsed into a `TimeOfDay`.
- **Scheduling mechanism:** zoned `tz.TZDateTime` for today's next occurrence; one-shot per fire; rescheduled on every app foreground.
- **Channel (Android):** `daily_reminder` channel, importance `IMPORTANCE_DEFAULT`, sound on, vibration on, no LED.
- **Body composition:** `notificationBodyComposer.dailyReminder(planView.today)`. `planView.today` carries Spec 6's already-computed state classification (standard / mock / behind / calm / first-post-diagnostic) plus the queue size and any subtopic specificity for Pro.

#### Copy table — daily reminder

| Plan state | Title | Body |
|---|---|---|
| Standard day | `Today's session is ready` | `{N} questions to review. You've got this.` |
| Mock day | `Mock exam day` | `Take your time and treat it like the real thing. You've prepped for this.` |
| Behind ≥2 days | `Welcome back` | `Let's ease in. {N} reviews today, no rush.` |
| Calm / on-pace | `Quick check-in` | `Short session today keeps you sharp.` |
| First post-diagnostic day | `Your plan is set` | `Let's start with {N} questions. Easy first session.` |
| Fallback (planView.today unavailable) | `Time for today's session` | `You've got this.` |

`{N}` is the queue size from `planView.today.queueSize`. Subtopic specificity for Pro users (e.g., "Reading Comprehension still wobbly") is appended to the body when `entitlementProvider.proIsActive` per `pro_depth_on_demand` — same one-line cap as the in-app headline, not a second paragraph.

### 5.2 Streak-save

- **Fire time:** `streakSaveTime = min(TimeOfDay(20, 0), daily_reminder_time − const Duration(hours: 1))`. Worked examples: reminder=19:00 → save=18:00; reminder=20:30 → save=19:30; reminder=22:30 → save=20:00 (cap); reminder=06:00 → save=05:00.
- **Known v1 limitation — early-reminder edge case.** The formula assumes most users pick evening reminder times (19:00–22:00), where it produces sensible streak-saves between 18:00 and 20:00. For early-morning or midday reminder times, `streakSaveTime` can land in the morning or even pre-dawn — by the time the user foregrounds the app in the afternoon, `now > streakSaveTime` and the schedule-time eligibility check (`now() < streakSaveTime`) skips. Net effect: users with daily reminders before ~19:00 effectively get no streak-save on most days. Risk-accepted for v1; v1.x can move streak-save to a fixed evening time independent of daily reminder if telemetry shows the formula failing in practice. (Documented in §11.)
- **Eligibility at schedule time** (all must be true):
  - `streakStateProvider.value.length >= 1`
  - User has **not** completed today's Today's Session (`streakStateProvider.value.lastStreakEventDay != deviceLocalToday`)
  - `now() < streakSaveTime` (don't schedule a past time)
- **Eligibility at fire time:** the schedule itself is the eligibility — if the user completes a session between schedule time and fire time, `onSessionCompleted()` cancels it (see §5.4 trigger #3). No fire-time check needed.
- **Channel (Android):** separate `streak_save` channel, importance `IMPORTANCE_DEFAULT`, sound on, vibration on. Separate channel so users can mute streak-save independently via OS settings if they find it noisy — `monetization_no_churn` respect for control.
- **Body composition:** `notificationBodyComposer.streakSave(streakLength, freezesRemaining)`.

#### Copy table — streak-save (no freeze available)

| Streak `{N}` | Title | Body |
|---|---|---|
| 1 day | `Don't lose your streak` | `Your 1-day streak is on the line. One more quick session and you'll have 2.` |
| 2–6 days | `Five more minutes?` | `Your {N}-day streak is still going. Quick session, then you're done.` |
| 7–29 days | `Your {N}-day streak's still alive` | `One quick session before midnight keeps it going.` |
| 30+ days | `{N} days strong` | `Don't let tonight be the one that breaks your {N}-day streak — a few minutes is all it takes.` |

`{N}` is `streakStateProvider.value.length` resolved at schedule time. If a foreground after a session-completion mutates `{N}`, the cancel-and-reschedule loop picks up the new value next foreground; in the interim, the cancellation in §5.4 prevents a stale `{N}` from firing.

#### Copy table — streak-save (freeze available)

When `freezesRemaining > 0` the streak-save still fires (visibility principle), but with a different body:

| Streak `{N}` | Title | Body |
|---|---|---|
| Any (1+) with `freezesRemaining` ≥ 1 | `Your {N}-day streak's safe tonight` | `If you skip, your streak's freeze will save it ({freezesRemaining} left this month). Want to keep the freeze and study anyway?` |

### 5.3 Reschedule triggers

The schedule is rewritten in full (cancel-all → schedule 0–2 notifications) on:

1. **App foreground** (`AppLifecycleState.resumed`). The `NotificationsLifecycleObserver` (§4.1) calls `rescheduleForForeground()`. Idempotent; runs even if it just ran 200ms ago.
2. **Spec 8 reminder-time picker save** → calls `notificationService.scheduleDailyReminder(time)`, which internally also reschedules the streak-save since its fire time depends on the new daily reminder time.
3. **Today's Session completion event** (Spec 4 streak evaluator fires). Spec 4 calls `notificationService.onSessionCompleted()`, which cancels today's streak-save (the daily reminder for tomorrow stays scheduled). If the streak event hasn't fired yet on this completion (e.g. drill-only completion), `onSessionCompleted()` no-ops — the eligibility check at next foreground will catch it.
4. **Day-boundary cross while app foregrounded** (rare). A `Timer.periodic` running 5-minute checks on the foregrounded notifications observer notices the date roll over and triggers a reschedule. (Pure foreground; no background task.)

Backgrounded day-boundary crosses are **not** handled — flutter_local_notifications' previously-scheduled fires survive the cross, and the next foreground reschedule corrects the picture.

### 5.4 Late-fire / missed-window behavior

Android's `setExactAndAllowWhileIdle` fires the alarm on device boot if the device was off at the scheduled time. Result: a reminder scheduled for 19:00 on a device that was off until 23:00 will fire at 23:00. If the device was off across midnight, the alarm fires on the next boot — could be the following day at an unusual hour.

**v1 stance: accept the OS behavior as-is.** No software cap on fire times. The cross-midnight late-fire is rare enough (device fully off >5 hours across the user's reminder time) that coding around it would add complexity for no measurable benefit. If post-launch reports of "I got a 4 AM notification" surface, v1.x adds a cap.

flutter_local_notifications honors the originally scheduled `tz.TZDateTime`, so the alarm payload still references "today" (the scheduling day). A user who sees a late-fired notification mid-morning the next day will tap into a `/quiz/today` route that reflects the *new* day — that's correct, because the next foreground reschedule will refresh the body. The user just gets one slightly weird-feeling late notification.

### 5.5 Timezone

Device timezone via the `timezone` package (`tz.local`). Reads on every schedule call — flutter_local_notifications requires `tz.TZDateTime` instances, so each `scheduleZonedNotification()` already uses fresh tz data. No special tz-change observer; rare in PH market, and the next app foreground after travel will reschedule correctly.

## 6. Permission flow

### 6.1 First-time ask (end of onboarding)

**Trigger:** onboarding completes (diagnostic done; if Spec 6's exam-date step is non-deferrable per its final D3, that's done too; Study Plan generated). The router's onboarding-completion redirect routes to `/notifications/rationale` instead of going straight to Home.

**Rationale page** — single screen, no app bar, large illustration + minimal copy:

```
        📚

   I'll be your coach.

   I'll check in once a day at your chosen
   time with what to study.

   You can change the time or turn this off
   anytime in Settings.

   [ Sounds good ]      ← primary CTA, fires OS prompt
   [ Not right now ]    ← secondary, skips
```

- Single screen, single primary CTA (`ui_ux_simplicity_intentionality`).
- "Sounds good" → calls `Permission.notification.request()` via `flutter_local_notifications`' OS bridge. Whatever the user picks in the OS dialog, route forward to Home.
- "Not right now" → set `notification_rationale_shown = true`, route forward to Home **without** prompting. The OS dialog is not shown.
- The screen shows **once per install**. Persisted via `SharedPreferences` key `notification_rationale_shown: bool`. Re-shown on reinstall — that's fine; it's not annoying because reinstalls are rare and the user reset their state.

### 6.2 Re-request UX

- **No auto-re-prompt anywhere.** Not on Home, not after N days, not after first session, not on second app launch. Quiet by design.
- **Recovery path** (specced in Spec 8 §5.1): Settings home → Daily reminder row subtitle reads `Notifications are off — tap to enable` when permission is denied. Tap deep-links to OS settings via `app_settings.AppSettingsType.notification`.
- **One additional surface this spec adds:** the post-save snackbar in Spec 8's reminder picker. When the user changes the reminder time and permission is still denied, the snackbar gains an action button:

  ```
  Daily reminder set for 7:00 PM  [ Enable notifications ]
  ```

  Tapping the action deep-links to OS settings — same target as the row subtitle. Spec 8 §5.8 already specced this hook; Spec 9 supplies the action callback.

### 6.3 Anonymous users

Same flow. Anon users complete onboarding the same way named users do; the rationale page fires after onboarding regardless of auth state. Local notifications work without a Firebase identity.

### 6.4 Permission state provider

```dart
final permissionStatusProvider = StreamProvider<NotificationPermission>((ref) async* {
  yield* notificationsGateway.watchPermissionStatus();
});
```

Three values: `notYetAsked`, `granted`, `denied`. Refreshed on app foreground (user might have toggled in OS settings between sessions). Spec 8's reminder-row subtitle subscribes to this provider for its conditional text.

## 7. Tap behavior + deep-link routing

### 7.1 Routing

Both notification kinds tap to the same destination: **Today's Session intro screen** (`/quiz/today` — the screen Spec 6's home plan card and Spec 4's Quiz tab already route to).

### 7.2 Payload

Each scheduled notification carries a JSON payload:

```json
{ "kind": "daily_reminder" | "streak_save", "scheduled_for": "2026-05-22T19:00:00+08:00" }
```

- `kind` — telemetry seam (no events fired in v1; the field is for the v1.x telemetry taxonomy to consume).
- `scheduled_for` — ISO 8601 with offset. Used by stale-tap detection.

### 7.3 Stale-tap detection

If `now - scheduled_for > 4 hours`, tap routes to `/home` instead of `/quiz/today`. By 4 hours past the scheduled time, the "today" framing in the body is stale and Home's plan card is the more honest landing.

### 7.4 Warm vs cold tap

- **Warm tap** (app in memory): `tapHandler` calls `GoRouter.go('/quiz/today')` (or `/home` if stale).
- **Cold tap** (app launched from notification tile): `main.dart` calls `flutter_local_notifications.getNotificationAppLaunchDetails()` after `runApp` settles. If a launch payload exists **and** onboarding is complete, the initial route is `/quiz/today` (or `/home` if stale) instead of the default. If onboarding is incomplete, the payload is dropped silently and `/onboarding` wins — onboarding always takes priority.

### 7.5 Plan-not-ready fallback

If `computePlanView()` returns a Today with no queue (legitimate when content sync hasn't completed on offline cold start), the tap routes to `/home`. The notification body that fired would have used the fallback copy from §5.1 ("Time for today's session. You've got this."), so the user wasn't promised a specific queue size that we then can't deliver.

### 7.6 Dismissal

`autoCancel: true` on both notifications. Tapping or swiping removes them from the shade. No persistent / ongoing notifications in v1.

## 8. Data & state

### 8.1 What this spec persists

- `SharedPreferences` key `notification_rationale_shown: bool` — device-local, gates the onboarding rationale screen.

That's it. Everything else is read from existing providers:

- `user_settings.daily_reminder_time` (Drift, Spec 8 owner)
- `streakStateProvider` (Spec 4)
- `studyPlanService.computePlanView()` (Spec 6)
- `permissionStatusProvider` (Spec 9, computed from OS, not persisted)

The OS-side pending-notifications list maintained by flutter_local_notifications is the source of truth for "what's currently scheduled" — we never mirror that into Drift or SharedPreferences.

### 8.2 No FCM token storage

Per D2 (v1.1 deferral): no `/users/{uid}/devices/{deviceId}` document, no `fcmToken` field anywhere. v1.1 adds these as net-new code; Spec 10's RA 10173 deletion path then needs to scrub them, but that work belongs to whatever spec ships server push.

### 8.3 Sign-out + account-delete coordination

- **Sign-out (Spec 1 amendment):** `LocalStateWiper.wipeAll()` gains one line — `await notificationService.cancelAll()`. Cancels all pending notifications before re-anonymizing. The new anonymous user has zero scheduled notifications until the next foreground reschedule.
- **Account delete (Spec 10 amendment):** the client-side delete flow in Spec 8's `account_delete_confirmation_page.dart` calls `notificationService.cancelAll()` immediately before the Cloud Function fires. Same rationale.

### 8.4 Provider graph

```dart
final notificationsGatewayProvider = Provider<NotificationsGateway>((ref) {
  return FlutterLocalNotificationsGateway()..init();
});

final notificationBodyComposerProvider = Provider<NotificationBodyComposer>(...);
final streakSavePolicyProvider = Provider<StreakSavePolicy>(...);

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl(
    gateway: ref.read(notificationsGatewayProvider),
    composer: ref.read(notificationBodyComposerProvider),
    policy: ref.read(streakSavePolicyProvider),
    planService: ref.read(studyPlanServiceProvider),
    streak: ref.read(streakStateProvider),
    settings: ref.read(userSettingsProvider),
    entitlement: ref.read(entitlementProvider),
  );
});

final permissionStatusProvider = StreamProvider<NotificationPermission>(
  (ref) => ref.read(notificationsGatewayProvider).watchPermissionStatus(),
);
```

### 8.5 App lifecycle integration

A single `NotificationsLifecycleObserver` registered in `main.dart` after `runApp`:

```dart
WidgetsBinding.instance.addObserver(NotificationsLifecycleObserver(ref));
```

`didChangeAppLifecycleState(AppLifecycleState.resumed)` calls `ref.read(notificationServiceProvider).rescheduleForForeground()`.

The same observer maintains a 5-minute `Timer.periodic` on `paused → resumed → paused` lifecycle bouncing to detect day-boundary crosses while foregrounded (Spec §5.3 trigger #4). The timer is started on resume and canceled on pause.

## 9. Cross-spec amendments

| Spec | Amendment |
|---|---|
| **Spec 1 (Auth)** | `LocalStateWiper.wipeAll()` gains a call to `notificationService.cancelAll()` before re-anonymizing. One line. |
| **Spec 4 (Quiz engine)** | The Today's Session completion code path that fires the streak event also calls `notificationService.onSessionCompleted()`. One line, same code path. |
| **Spec 6 (Study Plan)** | Confirmation: `computePlanView()` must be safe to call from non-UI code. Spec 6's compute-on-read design already meets this — no change needed; cross-spec amendment is informational. |
| **Spec 8 (Settings)** | Reminder-picker save snackbar gains an action button "Enable notifications" when permission is denied (Spec 8 §5.8 already specced the hook; Spec 9 supplies the callback). |
| **Spec 10 (Legal)** | Account-deletion client flow calls `notificationService.cancelAll()` before the Cloud Function fires. One line, added to Spec 8's `account_delete_confirmation_page.dart` per Spec 10's hand-off boundary. |

## 10. Testing

### 10.1 Unit tests (`domain/`)

- **`notification_body_composer_test.dart`** — every plan-state branch from §5.1 + every streak-length tier from §5.2 + freeze-available variant. ~25 cases. Snapshot-style assertions on title + body strings. `{N}` interpolation verified at 1, 2, 6, 7, 29, 30, 100.
- **`streak_save_policy_test.dart`** — quiet-hour math via a table:
  - reminder=19:00 → save=18:00
  - reminder=20:30 → save=19:30
  - reminder=21:00 → save=20:00 (boundary)
  - reminder=22:00 → save=20:00 (capped)
  - reminder=06:00 → save=05:00 (early-reminder edge case, see §5.2 limitation)
  - Eligibility-skip cases: `now > streakSaveTime` (past fire time) → no schedule call emitted.
- **`reminder_schedule_test.dart`** — each of the 4 reschedule triggers in §5.3 produces the expected sequence of cancel + schedule calls against a `FakeNotificationsGateway` that records its call log. Eligibility table:
  - streak=0, studied=false → no streak-save
  - streak=3, studied=true → no streak-save (already studied)
  - streak=3, studied=false, freezes=0 → streak-save scheduled with "Five more minutes?" copy
  - streak=3, studied=false, freezes=1 → streak-save scheduled with freeze-available copy
  - streak=0, daily_reminder=19:00, studied=false → only daily reminder scheduled

### 10.2 Widget test

- `permission_rationale_page_test.dart` — "Sounds good" calls `requestPermission()` on the gateway; "Not right now" sets the prefs flag and routes home. Pump the page with `FakeNotificationsGateway`.

### 10.3 Integration / fake gateway

- `FakeNotificationsGateway` records `schedule(id, time, title, body, payload)` and `cancel(id)` and `cancelAll()` calls into a log. All reschedule-trigger tests assert against this log.
- Real `flutter_local_notifications` is not driven in CI — too platform-specific. Real-device QA on the target Galaxy A15 in Week 5 covers OS-dialog rendering, fire-time-when-screen-locked, fire-time-when-DND, and late-fire-on-boot behavior.

### 10.4 No tests for FCM

Nothing FCM-side ships in v1, so no tests. The `firebase_messaging` import in `pubspec.yaml` is exercised only by import-resolution; no token retrieval, no message listener.

### 10.5 Coverage target

`domain/` 95% line coverage (matches the project bar for domain code). `data/` excluded from coverage targets (impl-detail surface). `presentation/` covered by widget tests where the logic warrants — the lifecycle observer is small enough that the existing reschedule-trigger test suite is sufficient.

## 11. Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Late-fire on device-boot fires "Today's session is ready" at an unusual hour the next day (device was off across midnight) | Very Low | Low | Accepted v1 risk; the user sees one mildly weird late notification, tap routes correctly via the next-foreground reschedule. v1.x adds a fire-time cap if post-launch reports surface. |
| Users with early daily-reminder times (before ~19:00) never see streak-save | Low | Low | Documented v1 limitation in §5.2. Most users in PH market choose evening times. v1.x can decouple streak-save from daily reminder time. |
| User OS-disables notifications via OS settings between sessions; in-app subtitle is stale until next foreground | Low | Low | `permissionStatusProvider` refreshes on every foreground. Worst case is a few seconds of stale subtitle on app launch. |
| Streak-save freeze body confuses users ("what's a freeze?") | Medium | Low | Spec 4's streak primer already introduces freezes via the "🛡️ Streak saved (1 freeze used)" toast on freeze consumption. Body copy in §5.2 freeze variant uses the same plain-language register. |
| `computePlanView()` is slow on cold start; reschedule on foreground stalls the lifecycle observer | Low | Low | The observer reschedules off the main isolate's microtask queue; even a 200ms compute doesn't block UI. If sustained, profile and move to a background isolate (out of scope for v1). |
| flutter_local_notifications package surface changes between v17 → v18 mid-development | Low | Low | Pin to `^17.x` in pubspec for v1. v1.x can upgrade as part of the iOS launch work. |
| User reinstalls the app, OS-side notifications were previously scheduled by the old install, fire stale "Today's session is ready" with no app behind it | Very Low | Low | OS clears pending notifications on uninstall on both Android and iOS. Reinstall path is clean. |
| FCM dormant import causes a v1 surprise (e.g., FCM background message handler accidentally registers and crashes on Android) | Low | Medium | Spec 9's `main.dart` deliberately does **not** call `FirebaseMessaging.instance.getToken()` or `onMessage.listen(...)`. The package's mere presence in pubspec is inert. |

## 12. Out of scope / parking lot

- Server-driven push (FCM token + sender Cloud Function + "haven't studied in 3 days" copy) — v1.1.
- Multi-variant copy rotation (anti-notification-blindness) — revisit if post-launch shows habituation.
- Mock-week reminder ("tomorrow's a mock day") — revisit after streak-save validates the second-notification register with real users.
- Notification telemetry events (open / dismiss / time-to-action) — parked in `docs/future/post-launch-revenue-and-telemetry.md`.
- User-configurable quiet hours (custom no-notification window) — v1 has fixed `min(20:00, ...)` math for streak-save; daily reminder time is the only user-visible knob.
- Per-user-timezone-change observer — device-tz via `tz` package handles the common case; rare in PH market.
- Notification action buttons ("Snooze 1h", "Skip today") — adds reschedule complexity and a parallel state machine; v1.x candidate.
- Per-channel granular muting UX inside the app — Android channel separation (daily_reminder vs streak_save channels) gives users OS-side muting today; an in-app per-channel toggle is v1.x if user-test shows demand.
- iOS APNs auth key, `Info.plist` entitlements, iOS-side UX QA — v1.x additive when Apple enrollment is funded.

## 13. Open questions resolved (from roadmap §4 Spec 9)

| Roadmap open question | Resolution |
|---|---|
| Server-driven push for re-engagement — v1 or v1.1? | **v1.1.** Defer all FCM (token storage + sender Cloud Function + re-engagement copy) since nothing v1-side sends pushes. Reduces Spec 10 deletion-path work. (D2) |
| Notification copy strategy — fixed templates or generated from Study Plan state? | **Generated from Study Plan state** for daily reminder; fixed templated family for streak-save. Both produce day-to-day variation without rotation logic. (D3) |
| Quiet hours (no notifications 10pm–7am)? | **Hybrid.** Daily reminder time unconstrained (user's choice). Streak-save fires at `min(20:00, daily_reminder − 1h)`. No hard scheduling cap; OS late-fire behavior accepted as-is (§5.4). (D4) |

## 14. Implementation hand-off note

This spec is ready for the `superpowers:writing-plans` skill to produce an implementation plan, or for Codex to consume directly (consistent with the Spec 8 hand-off pattern). Cross-spec amendments above are minimal — five single-line touches across Specs 1, 4, 8, 10 — and one informational confirmation for Spec 6. None of those amendments require their owning specs to re-brainstorm.

The implementation order suggested:

1. **Packages + gateway:** add `flutter_local_notifications`, `timezone`, `app_settings` to pubspec. Implement `NotificationsGateway` + `FlutterLocalNotificationsGateway`. Wire `FakeNotificationsGateway` for tests.
2. **Domain:** `NotificationBodyComposer`, `StreakSavePolicy`, `ReminderSchedule` with full unit tests.
3. **Service + providers:** `NotificationServiceImpl` + Riverpod providers. Use-cases (schedule_today_reminders, handle_session_completed, handle_reminder_time_changed).
4. **Lifecycle observer:** wire into `main.dart`. Reschedule-on-foreground.
5. **Permission rationale page:** route + page widget + post-onboarding redirect.
6. **Tap handler:** deep-link router for warm + cold tap, stale-tap fallback.
7. **Cross-spec wiring:** the 5 cross-spec amendment lines (Spec 1, 4, 8, 10).
8. **Real-device QA on Galaxy A15** in Week 5 alongside Spec 11 (Progress) finalization.

End of design.
