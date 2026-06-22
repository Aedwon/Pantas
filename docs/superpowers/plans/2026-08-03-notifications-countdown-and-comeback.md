# Notifications: the exam countdown, the lapse nudge, and the ceiling

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


**Goal:** Add the two notification kinds the app is uniquely able to send, and put a hard
ceiling over all four so the permission is never spent on volume.

**Architecture:** Two new `NotificationKind` values scheduled locally through the existing
`NotificationService`. No FCM, no server. A single scheduler gate applies the ceiling and the
priority order before anything is handed to the platform.

**Tech Stack:** Flutter, Riverpod, `flutter_local_notifications`, `timezone`, `flutter_test`.
No new packages.

**Source spec:**
`docs/superpowers/specs/2026-08-03-notification-engagement-amendment-design.md`, which amends
`2026-05-22-notifications-fcm-design.md`. **That spec's architecture, permission flow, tap
routing and timezone handling all stand and are not restated here.**

**Required reading before task 1:** `AGENTS.md` in full, Section 5 of the source spec, which
is a list of bans, and Sections 5.1 to 5.5 of the 05-22 spec, which is the scheduling
machinery you are extending rather than replacing.

## Global Constraints

- **Work only inside your worktree.**
- **Generated files are never edited by hand and never committed.**
- **No new dependencies. No FCM.** Everything here is a local notification.
- **One notification per day. Never two.** Task 3 is the gate and every kind goes through it.
- **A notification must name a real thing the student can do in one tap.** If it cannot, it is
  not sent.
- **Never invent a figure.** Days-to-exam is measured from the date the student entered, at
  **day precision only**. Counts and past scores are measured from their own attempts. No
  predicted score, no readiness percentage, no "on track".
- **Banned outright, by name:** guilt, a mascot, manufactured urgency, "your progress will be
  lost", "last chance", streak pressure beyond the one save that exists, and any notification
  that sells Pro.
- **Voice:** grade-5-simple, short sentences, no em dashes, American spelling. Scores are
  **points**, never marks.
- **Analyzer baseline is ~25 issues, all under `tools/` or `test/tool/`. `lib/` is clean and that is the invariant, not the count.**
- **No AI attribution in commits.**

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| `2026-08-02-onboarding-flow-and-new-steps.md` **or** `2026-08-03-settings-02-storage.md` | `ExamDate` with precision. Task 1 cannot compile without it. **Per the 3 August ruling the two are being merged into one type on onboarding's names**: `ExamDate.onDay`, `ExamDate.inMonth`, nullable getter `day`, plus `monthStart`. | **Yes** |
| `2026-08-03-settings-04-the-sheets.md` | The reminder time and its off state, which Task 4 reads. | Yes, for Task 4 only |

## File structure

| File | Responsibility |
|---|---|
| `lib/features/notifications/domain/notification_payload.dart` (modify) | Two new kinds. |
| `lib/features/notifications/domain/exam_countdown_schedule.dart` (create) | The ladder, and the month-precision refusal. |
| `lib/features/notifications/domain/lapse_policy.dart` (create) | Three quiet days, once. |
| `lib/features/notifications/domain/notification_ceiling.dart` (create) | One a day, and the priority order. |
| `lib/features/notifications/domain/notification_body_composer.dart` (modify) | The bodies for both kinds. |

---

## Task 1: The exam countdown ladder

**Files:**
- Modify: `lib/features/notifications/domain/notification_payload.dart`
- Create: `lib/features/notifications/domain/exam_countdown_schedule.dart`
- Test: `test/features/notifications/domain/exam_countdown_schedule_test.dart`

**Interfaces:**
- Consumes: `ExamDate`.
- Produces:

```dart
/// The fixed ladder. Seven notifications across the whole run-up and
/// never two in one day.
const countdownDays = [30, 14, 7, 3, 2, 1, 0];

abstract final class ExamCountdownSchedule {
  /// Empty at month precision. `ExamDate.day` returns null there and
  /// deriving a day from a month is a figure this project inferred.
  static List<DateTime> fireDates(ExamDate date, {required DateTime from});
}
```

`NotificationKind` gains `examCountdown('exam_countdown')`.

**At month precision it returns an empty list.** A student who told us "October" is never told
"12 days left". This is the never-invent-a-figure rule reaching the lock screen, which is the
worst place for it to be broken because there is no context there to correct it.

- [ ] **Step 1: Write the failing test**

Assert: a day-precision date 45 days out yields all seven dates; a date 5 days out yields
only 3, 2, 1 and 0; a **month-precision date yields an empty list**; a past date yields an
empty list; two ladder entries never land on the same day.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Build the ladder and add the kind**
- [ ] **Step 4: Run the gates and commit**

---

## Task 2: The bodies

**Files:**
- Modify: `lib/features/notifications/domain/notification_body_composer.dart`
- Test: `test/features/notifications/domain/notification_body_composer_test.dart`

**The copy, settled by the spec:**

Countdown, at 30 through 1:

> **7 days to UPCAT**
> You've got 42 questions flagged. Want to clear them?

Day of, which is not a nudge and carries no task:

> **Today's the day.**
> Good luck.

Lapse:

> **Your Chemistry is waiting**
> You got 12 of 20 last time. One session picks it back up.

**The second line names a real thing that exists right now, or it is omitted.** A countdown
with nothing concrete to offer sends the title alone. **A lapse nudge with nothing concrete to
name is not sent at all**, because a generic "we miss you" is the exact thing the spec exists
to prevent.

**Every figure is measured**: the day count from the entered date, the flagged count and the
past score from the student's own attempts.

- [ ] **Step 1: Write the failing test**

Assert: the count matches the date arithmetic; the day-of body contains no count and no call
to action; a countdown with no flagged questions and no due work sends the title with **no
second line**; a lapse composer with no attempts returns null rather than a generic string;
no body contains an em dash, "marks", or any banned word from the spec's Section 5.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Compose the bodies**
- [ ] **Step 4: Run the gates and commit**

---

## Task 3: The ceiling

**Files:**
- Create: `lib/features/notifications/domain/notification_ceiling.dart`
- Test: `test/features/notifications/domain/notification_ceiling_test.dart`

**Interfaces:**
- Produces:

```dart
/// One notification per day. When two are eligible the order is fixed
/// and is not a judgment call.
const kindPriority = [
  NotificationKind.examCountdown,
  NotificationKind.streakSave,
  NotificationKind.dailyReminder,
  NotificationKind.comeBack,
];

abstract final class NotificationCeiling {
  /// Returns at most one payload for [day]. The losers are dropped,
  /// never deferred: a queue that fires yesterday's nudge tomorrow says
  /// something untrue.
  static NotificationPayload? pick(List<NotificationPayload> eligible);
}
```

**Every kind goes through this, including the two that already exist.** A gate that only the
new kinds respect is not a ceiling.

- [ ] **Step 1: Write the failing test**

Assert: four eligible payloads yield exactly one; the winner is the highest priority present;
a dropped payload is **not** rescheduled to the following day; an empty list yields null.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Build the gate, and route the two existing kinds through it**
- [ ] **Step 4: Run the gates and commit**

---

## Task 4: The lapse nudge, and the switch

**Files:**
- Create: `lib/features/notifications/domain/lapse_policy.dart`
- Modify: the reminder scheduler. **Find it with `grep -rn`, do not guess.**
- Test: `test/features/notifications/domain/lapse_policy_test.dart`

**Interfaces:**
- Consumes: the student's last session date, and the reminder time from settings.
- Produces: `NotificationKind.comeBack('come_back')`, fired **after three consecutive days
  with no session, once, then silence until they return.**

**It is not repeated.** A second unanswered nudge is how an app gets muted, and a muted app
cannot send the countdown either, which is the message that actually matters.

**The switch, from spec Section 6.** Four kinds are **not** individually switchable. One
control, three states:

| Reminder row | What arrives |
|---|---|
| A time is set | All four kinds, under the Task 3 ceiling |
| Off | **Only `examCountdown` at 3, 2, 1 and day of** |
| Permission denied | Nothing |

**Turning reminders off does not turn off the last week before the exam.** A student who asked
us to remember their exam date has not asked to be surprised by it. The spec flags this as the
one line most worth arguing about; **build it as written and do not soften it**, because
changing it is a decision and decisions are recorded before code.

- [ ] **Step 1: Write the failing test**

Assert: two quiet days send nothing; three send one; four send nothing more; returning and
lapsing again sends one more; with reminders off, only the last four countdown rungs fire and
`comeBack` never does; with permission denied nothing is scheduled at all.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Build the policy and wire the switch states**
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

- `grep -rniE "don't lose|last chance|we miss you|falling behind|you'll lose" lib/` returns
  **nothing**.
- No notification body contains a figure that is not measured. Read every string in the
  composer and check each against the spec's Section 7 table.
- A month-precision exam date schedules **zero** countdown notifications.
- Every kind, including `dailyReminder` and `streakSave`, passes through
  `NotificationCeiling.pick`.
- `flutter analyze` shows 27 issues, all under `tools/` or `test/tool/`.
- `flutter test` passes across the whole suite.
- **Device verification is Aedwon's**, not a model's. Report text signals and ask him to look.

## Done when

- A student with a dated exam gets seven notifications across the run-up and never two in a
  day.
- A student who gave only a month gets none of them, and is never told a day count.
- A student who goes quiet for three days gets one concrete nudge naming their own work, or
  nothing at all.
- Turning reminders off still leaves the last four days before the exam.
- No notification in the app carries guilt, urgency, or a number the app did not measure.
