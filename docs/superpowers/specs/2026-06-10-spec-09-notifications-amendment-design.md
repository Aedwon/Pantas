# Spec 9 (Notifications) — Amendment Design

**Status:** Amendment draft
**Date:** 2026-06-10
**Amends:** `docs/superpowers/specs/2026-05-22-notifications-fcm-design.md`
**Companion spec:** `docs/superpowers/specs/2026-06-10-user-facing-metrics-design.md`

---

## 1. Why this amendment exists

The user-facing-metrics spec introduces 4 Wrapped artifact triggers (post-mock recap, post-exam debrief, streak milestone, mastery crossing). These triggers are notification-worthy: the user should get a push when their Wrapped is ready, so they don't miss the moment.

Rather than reimplement trigger logic in the notifications module — and risk the in-app reveal and the push notification disagreeing about *when* an artifact fires — this amendment adds a notification routing layer that subscribes to the same trigger stream the in-app artifact reveal listens to.

**Single source of truth:** `wrappedTriggerStream` from the metrics module. Notifications never compute "should this fire?" independently.

---

## 2. Amendments to Spec 9

### Amendment A — Add Wrapped trigger events as notification sources

Spec 9's notification source catalog adds 4 new entries:

| Notification source | Trigger event | Routing |
|---|---|---|
| `wrapped.post_mock_recap` | `WrappedTriggerEvent` with `artifactId = post_mock_recap` | Foreground: in-app reveal; Background: push with deep link |
| `wrapped.streak_milestone` | `WrappedTriggerEvent` with `artifactId = streak_milestone_{N}` | Same |
| `wrapped.mastery_crossing` | `WrappedTriggerEvent` with `artifactId = mastery_crossing_{topicId}` | Same |
| `wrapped.post_exam_debrief` | `WrappedTriggerEvent` with `artifactId = post_exam_debrief` | Same (typically background-only; scheduled day-after-exam) |

### Amendment B — Subscribe, don't reimplement

Spec 9's implementation must:
1. Subscribe to `wrappedTriggerStream` (exposed by the metrics module).
2. For each event, route to either in-app reveal (if app foregrounded) or push notification (if backgrounded), per Spec 9's existing foreground/background dispatch model.
3. **Never** check trigger conditions independently — the metrics module owns "should this fire?" logic.

**Rationale:** Trigger conditions for Wrapped artifacts are non-trivial (first-mock OR new PB; streak at exact thresholds 7/30/100/365; FSRS weak→strong stability threshold; once-per-prep-cycle post-exam). Duplicating this logic in notifications guarantees drift bugs. Subscribing to the stream is the only safe pattern.

### Amendment C — Notification copy reads from `WrappedPayload`

The push notification title and body strings come from `WrappedPayload.title` and the first slide's content, not from notification-specific copy.

**Example:**
- In-app reveal title: "Mock 3 — Personal Best"
- Push notification: title `"Mock 3 — Personal Best"` / body `"Tap to see your Wrapped."`

This guarantees notification text and in-app text never diverge. If a Wrapped artifact's title changes, both surfaces update.

### Amendment D — Deep link payload

When dispatched as a push notification, the payload includes:
- `route`: `/wrapped/<artifactId>` (in-app route to the reveal page).
- `shareId`: matching `user_metrics_artifacts_local.shareId`.

Tap handling: app routes to `WrappedRevealPage` for that artifact, loaded from `user_metrics_artifacts_local`. The reveal page does NOT re-trigger — the artifact has already been persisted at trigger time.

### Amendment E — Quiet hours and frequency caps

Spec 9's existing quiet-hours / frequency-cap rules apply to Wrapped triggers with one exception: **`wrapped.post_exam_debrief` ignores quiet hours.** It fires once per prep cycle on a deliberately-scheduled day. If quiet hours suppress it, the user might miss the most important reveal entirely.

All other Wrapped triggers respect quiet hours and contribute to the per-day notification cap.

### Amendment F — Consent (RA10173 / Spec 10)

Notification delivery uses Spec 9's existing push consent gate. No new gate. The `wrapped_shared` analytics event (emitted when the user actually shares) uses Spec 10's analytics consent gate — also no new gate.

---

## 3. What does NOT change

- Spec 9's FCM transport, registration, foreground/background dispatch, and channel definitions remain unchanged.
- Existing notification sources (streak nudge, lapsed-review reminder, etc.) are unaffected.
- Spec 9's quiet-hours and frequency-cap defaults apply to Wrapped triggers (with the one exception in Amendment E).

---

## 4. Implementation guidance

When this amendment enters implementation, the plan should:
1. Add a `WrappedTriggerNotificationRouter` listener inside Spec 9's notification module that consumes `wrappedTriggerStream`.
2. Define notification source identifiers in the existing source catalog.
3. Route via existing foreground/background dispatch logic — no new transport.
4. Add a tap handler that opens `WrappedRevealPage` from `user_metrics_artifacts_local`.

---

## 5. Open questions

- Should `wrapped.streak_milestone` and `wrapped.mastery_crossing` be batched if multiple fire on the same day (e.g., a user crosses two topics to mastery in the same session)? Default proposal: yes, batch into a single notification with combined copy ("2 new milestones today — tap to see your Wrapped").
- Quiet hours for time-zoned users: Wrapped triggers compute against the user's local time (same rule as Spec 9 baseline). Confirm during implementation.
