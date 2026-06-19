# Notifications: the two that are missing, and the ceiling that governs all of them

**Date:** 3 August 2026
**Status:** Written to Aedwon's question of 3 August about proven engagement patterns.
**Amends:** `2026-05-22-notifications-fcm-design.md`. That spec's architecture, permission
flow, tap routing, timezone handling and scheduling machinery all stand. This adds two kinds
and one governing constraint, and it does not restate the machinery.

---

## Section 1: What already exists, so nobody rebuilds it

Verified in the tree on 3 August. `NotificationKind` carries three values and the
infrastructure behind them is real: a permission rationale route, a lifecycle observer, a
body composer, a reminder schedule, a streak-save policy, and Android channels.

| Kind | Status | The pattern it implements |
|---|---|---|
| `dailyReminder` | Built | A single daily nudge at a time the student chose |
| `streakSave` | Built | Streak protection, the most-copied mechanic in the category |
| `wrapped` | Built | A one-off, event-driven |

**Notifications are one of the more finished parts of this app.** The two additions below are
additions, not repairs.

## Section 2: The exam countdown, which only this app can send

**New kind: `examCountdown`.**

The app asks for the exam date during onboarding and then never uses it to speak to the
student. No other study app in the category can send this, because no other one is built
around a single dated exam.

**When it fires.** At day-precision only, on a fixed ladder, at the student's chosen reminder
time:

| Days out | Sent |
|---|---|
| 30, 14, 7 | Yes |
| 3, 2, 1 | Yes |
| Day of | Yes, once, in the morning |
| Anything else | No |

Seven notifications across the whole run-up, and never two in one day.

**At month precision it does not fire at all.** `ExamDate.exactDay` returns null and the
never-invent-a-figure rule forbids deriving a day from a month. A student who told us
"October" is not told "12 days left".

**What it says.** The count, and one real thing to do:

> **7 days to UPCAT**
> You've got 42 questions flagged. Want to clear them?

**The count is measured** from the date the student entered. **The second line names a real
thing that exists in the app right now**, or it is omitted. It never says "you're falling
behind", never estimates readiness, and never quotes a score.

**Day of is different and it is not a nudge.** It carries no task, no count and no call to
action:

> **Today's the day.**
> Good luck.

## Section 3: Lapse re-engagement

**New kind: `comeBack`.**

**After three consecutive days with no session**, once, at the student's chosen reminder
time. Then silence until they return. **It is not repeated**: a second unanswered nudge is
how an app gets muted, and a muted app cannot send the countdown either.

**It is local, not push.** A local notification scheduled on the device does this without
FCM, so it does not wait on the parked server work.

**It names something concrete**, drawn from what the student actually did:

> **Your Chemistry is waiting**
> You got 12 of 20 last time. One session picks it back up.

**Both figures are measured** from their own attempts. If there is nothing concrete to name,
because the student lapsed before doing anything, **it is not sent at all.** A generic "we
miss you" is the exact thing this spec exists to prevent.

## Section 4: The ceiling, which governs every kind including the built ones

**One notification per day. Never two.**

When two are eligible on the same day, the priority is fixed and is not a judgment call:

1. `examCountdown`, because it is dated and cannot be moved
2. `streakSave`, because it is time-critical
3. `dailyReminder`
4. `comeBack`

The loser is dropped, not delayed. A queue that fires yesterday's nudge tomorrow says
something untrue.

**A notification must name a real thing the student can do in one tap.** If it cannot, it is
not sent. That single rule is what separates this from the pattern Aedwon asked about.

## Section 5: What is banned, and why

Aedwon asked about Duolingo. Its notification craft is genuinely good and its **voice** is
the part that must not be copied here.

**Banned by name:**

- **Guilt.** No disappointed mascot, no "we haven't seen you", no passive aggression. This
  app's voice is grade-5-simple and plain, and a guilt line is neither.
- **Manufactured urgency.** "Your progress will be lost", "last chance", a countdown to
  nothing. Every one of these quotes a consequence that is not real, which makes it a figure
  this project inferred, which Section 1 of the Progress spec bans.
- **Any figure that is not measured.** No predicted score, no readiness percentage, no
  "you're 60% ready". The app does not know that and saying so would be the most damaging
  possible breach of the rule, because it arrives on a lock screen with no context.
- **Streak pressure beyond the streak-save that already exists.** One save notice is a
  service. Three are a slot machine.
- **Anything on a surface the student is paying to avoid.** No notification sells Pro. Ever.

**Why the ceiling is a business rule and not a courtesy.** On Android 13+ the permission is
asked once. A student who mutes the app or revokes it is unreachable for the countdown, which
is the highest-value notification the app has. **Spending the permission on volume costs the
one message that actually matters.**

## Section 6: The switch, and what a student controls

Settings already owns a daily reminder time. **The four kinds are not individually
switchable.** Four toggles for four kinds is a settings screen pretending to be a preference
center, and the Settings spec's whole posture is against that.

**One control, three states**, on the existing reminder row:

| State | What arrives |
|---|---|
| A time is set | All four kinds, under the Section 4 ceiling |
| Off | **Only `examCountdown` at 3, 2, 1 and day of** |
| Permission denied | Nothing |

**Turning reminders off does not turn off the last week before the exam.** A student who
asked us to remember their exam date and then turned off daily nudges has not asked to be
surprised by the exam. If that reads as too strong, it is the one line in this spec most
worth arguing about.

## Section 7: Evidentiary tier

| Figure | Tier |
|---|---|
| Days to the exam | **Measured**, from the date the student entered, at day precision only |
| Flagged count, score in a past session, topic name | **Measured**, from their own attempts |
| Readiness, predicted score, "on track" | **Inference. Never sent.** |

## Deferred, with reasons

- **Server-driven re-engagement over FCM.** Parked by the 05-22 spec and still parked. Every
  kind here is local and needs no server.
- **Mock-week reminders.** Already parked. Revisit once mocks actually run, since a reminder
  to sit a paper that cannot be assembled is worse than none.
- **Quiet hours.** The student picks the time. That is the quiet-hours control.
- **Notification telemetry.** Depends on the analytics work in
  `2026-08-03-platform-foundations-design.md`.
