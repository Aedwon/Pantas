# Spec 9 Notifications Live Validation

**Date:** 2026-05-22
**Status:** External/device validation pending

## Manual Android checks

- Android 13+ permission prompt: open `/notifications/rationale`, tap the primary CTA, and confirm the OS prompt appears once.
- Daily reminder delivery: grant notifications, save a reminder time in Settings, lock the device, and verify the `daily_reminder` channel fires at the scheduled time.
- Streak-save delivery: create an active streak with today's session incomplete, schedule before the computed streak-save time, and verify the `streak_save` channel fires.
- Permission recovery: deny notifications, open Settings, tap `Notifications are off - tap to enable`, and confirm the app notification settings page opens.
- Notification tap: tap a delivered notification within four hours and confirm it opens Today's Session; tap or simulate a stale payload older than four hours and confirm it opens Home.

## Parked work

- FCM token registration, token storage/rotation, sender Cloud Functions, and server-driven re-engagement pushes remain parked for v1.1.
- iOS APNs key setup, iOS entitlements, and TestFlight notification QA remain parked for the funded iOS v1.x launch.
- Notification telemetry, mock-week reminders, quiet-hours customization, and notification action buttons remain parked for post-launch specs.
