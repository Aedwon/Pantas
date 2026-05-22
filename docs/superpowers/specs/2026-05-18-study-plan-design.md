# Spec 6 — Study Plan (design)

**Status:** Brainstormed (2026-05-18).
**Depends on:** Spec 1 (auth, Firestore), Spec 2 (`examRepoProvider` for `targetMastery`, topic/subtopic metadata), Spec 3 (`SyncCoordinator` for non-plan user data only — plan prefs bypass it), Spec 4 (`quizPickerCalibrationProvider` for mastery state, Today's Session composer).
**Soft dependency:** Spec 7 (paywall + entitlement) — Spec 6 ships its free-tier rules independently and reads `entitlementProvider.proIsActive` once Spec 7 lands.
**Marketing pillar:** This is the coach. Spec 6 is the user-visible spine of the "constantly assesses weakness, addresses it urgently" positioning.

## 1. Overview

Spec 6 adds the Study Plan — the coach-facing surface that turns the user's diagnostic state, target exam date, and intensity preference into a daily session size + a calendar of upcoming focus areas. The plan is **compute-on-read**: no persisted plan rows, only user preferences (`examDate`, `examDateIsProvisional`, `intensityPreset`) and live mastery state from Spec 4's picker calibration. Sizing recomputes on weekly Monday rebalance, mock-exam completion, exam-date change, and intensity change. Targeting (what subtopics to drill) reweights continuously via Spec 4's picker reading fresh mastery on every compose. The `/plan` route is a full-screen, non-shell page reached from the Home plan card; default view is deliberately calm (Today + 3 upcoming days + nearest mock + collapsed history/future), with depth one tap away.

## 2. In scope / non-goals

**In scope:**

- Pace engine: mastery-based linear curve from `start_mastery` (diagnostic) → `exam.targetMastery` (Sanity, default 0.75, ±5% tolerance band).
- Pace-driven daily sizing with per-day cap (1.5× baseline), per-day floor, and week-level smoothing.
- Sizing recompute triggers: weekly Monday rebalance, mock completion, exam-date change, intensity-preset change.
- Targeting reweight: continuous via Spec 4's `quizPickerCalibrationProvider` (no separate plan-side targeting code).
- User preferences: `examDate`, `examDateIsProvisional`, `intensityPreset` (Light / Standard / Intense), synced via Firestore native partial-field updates.
- Exam-date editing: settings entry-point + downstream plan rebalance + "Plan updated" delight chip on next /plan visit.
- Home plan card: state-aware coaching surface following the depth-on-demand principle (Free = topic-level event-driven; Pro = subtopic-level + daily proactive briefing).
- `/plan` full-screen route: Today inset (single CTA) + 3 upcoming days + nearest mock-week card + collapsed Past 2 weeks + collapsed Show full plan.
- Coaching copy register: warm, never scoldy; calm copy on uneventful days.
- Delight moments (§8).

**Non-goals (deferred or explicitly not building):**

- AI/LLM-generated coaching copy. Coach voice is templated.
- Persisted per-day plan rows. The plan is computed on read; only prefs persist.
- Per-device live sync of mid-day plan state. Daily session composition is device-local.
- Multi-exam plans in parallel. Spec 6 operates against the user's single selected exam track. Switching tracks recomputes from the new exam's `targetMastery`.
- Tablet / rotation layouts. Android phone, portrait only.
- Plan-state CRDT or operational-transform sync. Firestore native partial-update semantics are sufficient (see D12).
- Score-impact forecasting on the default `/plan` surface. Lives behind expand affordance on Pro only.

## 3. Locked decisions

| # | Question | Decision |
|---|---|---|
| D1 | Free vs Pro split shape | Depth/granularity, not features. Both tiers see the same surfaces; Free = topic-level event-driven, Pro = subtopic-level + proactive daily briefing. |
| D2 | Pacing curve shape | Mastery-based linear: `start_mastery` (from diagnostic) → `exam.targetMastery` (Sanity, default 0.75). ±5% tolerance band defines "on track". |
| D3 | Exam-window framing | Band picker: user chooses from weeks or months (e.g., 4 / 8 / 12 / 16 weeks; 1 / 2 / 3 / 4 months) or sets a specific date. No hardcoded "12 weeks default". |
| D4 | Exam-date editing | Allowed. Edit from Settings. Triggers full plan rebalance + "Plan updated for the week" chip on next /plan visit. |
| D5 | Sizing model | Pace-driven daily sizing. Weekly Monday rebalance smooths the curve. Per-day cap = 1.5× baseline, per-day floor enforced, week-level smoothing prevents whiplash. |
| D6 | Sizing recompute triggers | Weekly Monday rebalance + mock-exam completion + exam-date change + intensity-preset change. No daily recompute. |
| D7 | Plan persistence | Compute-on-read. No `plan_days` table. Only `examDate`, `examDateIsProvisional`, `intensityPreset` persist. |
| D8 | Coaching surface layout | `/plan` is full-screen non-shell route. Default density: Today inset + 3 upcoming days + nearest mock + collapsed history + collapsed full plan. |
| D9 | Pro depth pattern | Pro is sharper, not denser. Same default density as Free. Subtopic specificity in headline + day chips. Forecasts/dossier behind expand affordances. |
| D10 | Coach reactivity | Targeting continuous (Spec 4 picker reads fresh mastery on every compose). Sizing smoothed (weekly + signal-driven). Visible coaching moments: post-session toast, post-mock chip, plan-card note, Spec 9 notifications. |
| D11 | Calendar UI shape | Single primary CTA per screen ("Start today's session →"). Coach message folds into Today headline. Sub-items are previews not buttons. Plain language over stats. |
| D12 | Plan-state sync | Firestore native partial-field updates. Each pref is updated independently via `update({field: value})`. Bypass SyncCoordinator merge logic. |
| D13 | Delight moments | All five: plan-set celebration, pace-rebalance acknowledgment, exam-date countdown crossings, rest-day framing, coach card on calm days. |

### 3.x Notes on rationale

- **D1** preserves the marketing-pillar framing. Free users get a coherent coach experience; Pro users get sharper synthesis. Frequency-only gating leaves Free starved.
- **D2** uses mastery as the curve variable because session counts and time-on-app are gameable signals; mastery is the outcome variable the user actually cares about. The ±5% tolerance band prevents the "on track" indicator from flickering day-to-day.
- **D3** removes the hardcoded "12 weeks" framing. Users in the PH market prep over wildly different windows (4 weeks cramming → 16+ weeks methodical). Letting the user own the window prevents the "why 12?" question.
- **D5** + **D6** balance coach reactivity against daily-whiplash. Weekly rebalance is the smoothing primitive; mock completion is the strong-signal exception that gets immediate recompute because users *expect* the plan to react to their mock score.
- **D7** keeps the plan as a *view over user state*, not a stored artifact. Avoids stale-plan bugs (what if mastery shifted but the persisted plan disagrees?), simplifies sync, and makes the plan inherently "live" — which composes with the coach positioning.
- **D9 + D11** are validated UI patterns from the v3 calendar mockup. See `.superpowers/brainstorm/12588-1779089138/content/calendar-option-b-v3.html`.
- **D12** uses Firestore's built-in field-level partial-update semantics. Custom SyncCoordinator merge for three preference fields is over-engineering; cross-field offline edits resolve naturally because writes target different fields.

## 4. Architecture

### 4.1 Module layout

```
lib/features/study_plan/
├── data/
│   ├── plan_prefs_repo.dart          Firestore read/write for examDate, examDateIsProvisional, intensityPreset
│   └── plan_prefs_cache.dart         Drift mirror for offline reads
├── domain/
│   ├── plan_prefs.dart               Entity (immutable snapshot of user prefs)
│   ├── pace_curve.dart               start_mastery → targetMastery linear curve + tolerance band
│   ├── daily_sizer.dart              Pace + intensity → daily session size (with cap, floor, smoothing)
│   ├── plan_view.dart                Computed view: today + upcoming + past + mock weeks + full plan
│   └── use_cases/
│       ├── compute_plan_view.dart    Reads prefs + mastery + calendar → PlanView
│       ├── update_exam_date.dart     Validates, writes, triggers rebalance signal
│       ├── update_intensity.dart     Writes, triggers rebalance signal
│       └── on_mock_completed.dart    Strong-signal recompute hook
└── presentation/
    ├── plan_route.dart               Full-screen /plan
    ├── home_plan_card.dart           Embedded on Home tab
    ├── today_inset.dart              Single-CTA Today card (shared with Home)
    ├── upcoming_chip.dart            Read-only day chip
    ├── mock_week_card.dart           Preview-only nearest-mock card
    ├── collapsed_section.dart        "Past 2 weeks ▸", "Show full plan ▸"
    ├── coach_briefing_pro.dart       Pro-only proactive daily inset
    └── plan_updated_chip.dart        Delight chip after rebalance
```

### 4.2 Data flow

```
User opens /plan
        │
        ▼
ComputePlanView (use case)
        │
        ├── reads PlanPrefs (cached in Drift, written-through to Firestore)
        ├── reads quizPickerCalibrationProvider (Spec 4 — live mastery snapshot)
        ├── reads examRepoProvider (Spec 2 — exam.targetMastery, topic catalog)
        └── reads mock-attempt history (Spec 5 — for nearest mock week)
        │
        ▼
PaceCurve + DailySizer compute today's size + upcoming days + projected curve
        │
        ▼
PlanView (today, upcoming[3], nearestMock?, past2Weeks (collapsed), fullPlan (collapsed))
        │
        ▼
plan_route.dart renders single-CTA surface
```

### 4.3 Pace curve

`PaceCurve` is a pure function:

```
linearMasteryAt(day) =
  start_mastery + (targetMastery - start_mastery) * (day - planStartDay) / (examDay - planStartDay)
```

`start_mastery` comes from the diagnostic completed during onboarding (Spec 2/onboarding spec). `targetMastery` comes from the exam doc in Sanity (default `0.75`, overridable per exam). The user is "on track" if `actualMastery` is within ±5% of `linearMasteryAt(today)`.

### 4.4 Daily sizer

```
baseline = totalQuestionsToCover / daysRemaining
intensityMultiplier = {Light: 0.7, Standard: 1.0, Intense: 1.4}
weeklyBudget = baseline * 7 * intensityMultiplier
perDay = smoothedDistribution(weeklyBudget, daysThisWeek)
  // smoothing: distribute across active days, respect per-day floor (e.g., 10 min) and cap (1.5× baseline)
```

Rest days are explicitly modeled (1/week default for Standard, 2/week for Light, 0/week for Intense). Rest-day cells on the calendar render with the "Rest day · recharge" framing.

### 4.5 Targeting reweight

Targeting (which subtopics to drill on a given day) is *not* computed by Spec 6. It is delegated to Spec 4's `quizPickerCalibrationProvider` which reads fresh mastery state on every compose of Today's Session. This is the "continuous coach" mechanic: the plan's sizing is smoothed (weekly), but the *content* of any given session reflects the user's latest weakness signal. Spec 6 only asks Spec 4: "given today's size, what subtopics should this session cover?"

### 4.6 Sync model

Plan prefs sync via Firestore native partial-field updates. Each field is written independently:

```dart
firestore
  .collection('users').doc(uid)
  .collection('settings').doc('plan')
  .set({'examDate': newDate}, SetOptions(merge: true));
```

- Offline writes queue in Firestore SDK and replay on reconnect.
- Cross-field offline edits (different fields on different devices) both apply cleanly.
- Same-field offline edits resolve to last-server-arrival, which is acceptable for a 3-field preference doc.
- No custom timestamps, no SyncCoordinator merge logic for plan prefs.
- Drift mirror is read-only cache: writes go to Firestore first, snapshot listener updates the cache.

## 5. UI / surfaces

### 5.1 Home plan card (embedded)

Free, default case (calm day): one headline + one supporting line + one CTA. Same vertical height as other Home cards.

```
[ Today's focus ]
Probability needs a refresher today.
[Start today's session →]
```

Free, signal case (3+ clustered errors on a topic): coaching note replaces the supporting line.

```
[ Today's focus ]
Probability has tripped you up three sessions in a row.
[Start today's session →]
```

Pro, default case (calm day):

```
[ Today's focus · daily briefing ]
Conditional probability is your sharpest gap today.
[Start today's session →]   [See more →]
```

Pro, signal case: as above but with the recovery framing if pace is behind tolerance band.

### 5.2 `/plan` route

Full-screen, non-shell. Default density (validated in v3 mockup):

1. **Top bar:** "Your study plan" + pace meta line ("Week 3 of 12 · 9 weeks to exam" or Pro: "… · On track").
2. **Today inset** (only CTA): tag + headline + one-line *why* + breakdown box (read-only) + single button.
3. **This week:** 3 upcoming day chips (date + focus topic/subtopic + ~minutes). No CTAs.
4. **Nearest mock card** (if within ~2 weeks): tag + title + plain-language description. No CTA until the mock-week arrives.
5. **Collapsed: Past 2 weeks ▸** — qualitative achievements only ("Strong gains in Probability"), no numeric stats.
6. **Collapsed: Show full plan (N weeks) ▸** — full timeline out to exam.

Pro variant: identical layout and height. Differences live in content — subtopic specificity in headline + chip focus lines, expand affordances reveal forecasting/dossier.

### 5.3 Settings → exam date

Settings entry ("Exam date · May 15, 2026") opens a date picker. On confirm, writes `examDate` + sets `examDateIsProvisional = false`, triggers a rebalance, surfaces the "Plan updated" chip next time `/plan` opens.

### 5.4 Settings → intensity

Settings entry ("Intensity · Standard") opens a three-option sheet (Light / Standard / Intense) with one-line descriptions. On confirm, writes `intensityPreset`, triggers rebalance, chip on next /plan visit.

### 5.5 Coach copy register

Warm, never scoldy. Calm copy on uneventful days ("On track — keep the rhythm"). Recovery framing for pace-behind cases ("You've drifted a bit — let's get back on rhythm this week") — never shaming. Coach surfaces reference *the user's actual behavior*, never generic. No raw percentages on default surfaces.

## 6. External setup

None new for Spec 6. Relies on existing Firestore project (Spec 1), Sanity schema (Spec 2 — needs `exam.targetMastery` field, default 0.75), and Drift schema (Spec 3 — needs `plan_prefs_cache` table).

Sanity schema addition required:

```js
// exam.js
defineField({ name: 'targetMastery', type: 'number', initialValue: 0.75 })
```

Drift schema addition required:

```dart
class PlanPrefsCache extends Table {
  TextColumn get uid => text()();
  DateTimeColumn get examDate => dateTime()();
  BoolColumn get examDateIsProvisional => boolean()();
  TextColumn get intensityPreset => text()();  // Light | Standard | Intense
  DateTimeColumn get cachedAt => dateTime()();
  @override Set<Column> get primaryKey => {uid};
}
```

## 7. Free vs Pro

Per the principle saved in memory, both tiers see the same surfaces. Differences:

| Surface | Free | Pro |
|---|---|---|
| Home plan card | Event-driven coach note (signal-only, 3+ clustered errors) | Daily proactive briefing (every day, calm copy on calm days) |
| Today headline | Topic-level ("Focus on Probability today") | Subtopic-level + reason ("Focus on Probability — conditional probability needs the most work today") |
| Today breakdown | Topic names | Subtopic-level drill names |
| Day chips (this week) | "Probability" | "Probability · independence" |
| `/plan` default layout | Identical to Pro | Identical to Free |
| Expand affordances | None on default surface | "See more →" reveals dossier: multi-weakness ranking, pace projection, recovery plan, score-impact narratives |
| Past 2 weeks | Qualitative achievements only | Same default; expand reveals subtopic-level mastery deltas |
| Full plan | Topic-level weekly themes | Subtopic-level weekly themes |

Marketable line: *"Free coaches you when it matters. Pro coaches you every day."*

## 8. Delight moments

| Moment | Treatment |
|---|---|
| Plan-set celebration | First time the plan generates post-onboarding: brief "Your plan is ready — let's go" inset with soft fade-in animation. One beat, then dismisses to Home. No modal. |
| Pace-rebalance acknowledgment | After Monday rebalance, next `/plan` visit shows a "Plan updated for the week" chip that fades after ~4 s. Same chip after exam-date edit and intensity change so rebalances feel intentional, not silent. |
| Exam-date countdown crossings | At 8w / 4w / 2w / 1w thresholds, pace meta line briefly highlights the change ("8 weeks to exam — you're on track"). Warm, not anxious. Auto-fades to normal state after ~3 s. |
| Rest-day framing | Rest days render "Rest day · recharge" with a soft icon, not an em-dash. The coach endorses rest rather than rendering it as absence. |
| Coach card on calm days | When there's nothing urgent: "On track — keep the rhythm" (Free) / "On track — no urgent focus today. Keep the rhythm. [See more →]" (Pro). Quiet is a feature. |

## 9. Error handling & edge cases

- **Missing diagnostic:** if `start_mastery` is unavailable (user skipped diagnostic), default to `0.3` and surface a one-line note on the plan card: *"Take a quick diagnostic so we can tune your plan."* Deep-links to the diagnostic flow.
- **Exam date in the past:** Settings refuses the edit + inline error.
- **Exam date too close** (<7 days): allow but show a confirmation sheet warning that the plan will be compressed.
- **Provisional exam date:** rendered as "exam date · ~May 15" with a tap affordance to lock it; on lock, the chip surfaces.
- **All topics at target mastery:** plan card surfaces "You've hit your target across all topics — review mode active" and Today's Session shifts to FSRS-only reviews.
- **Firestore offline at first load:** Drift cache backs the read; if cache is empty (fresh install offline), `/plan` shows a polite empty state ("Connect to load your plan").
- **Mock completion mid-week:** strong-signal recompute happens but the visible chip waits until next `/plan` visit (avoids interrupting the post-mock results flow).

## 10. Testing

- **Pace curve unit tests:** boundary conditions (exam day, plan start day, mastery already at target, mastery above target).
- **Daily sizer property tests:** per-day cap respected, floor respected, weekly budget conserved across smoothing.
- **Compute-on-read consistency:** PlanView regenerated after mastery state change reflects new state (no stale cache).
- **Sync tests:** offline writes to different fields on different simulated devices both land. Same-field offline writes resolve to last server arrival.
- **Widget tests for Today inset:** single CTA renders, no competing buttons under any state (Free / Pro / signal / calm / pace-behind).
- **Golden tests:** Home plan card and `/plan` default surface match the v3 mockup baseline.
- **Coach copy register tests:** snapshot tests asserting no scoldy phrasing across all generated copy variants.

## 11. Open questions for future specs

- Spec 9 notifications: should the daily Pro briefing also push as a notification, or only surface in-app?
- Spec 7 paywall: where does the "Upgrade to Pro" affordance live on `/plan`? Candidates: a soft footer below the full-plan section, or contextually under the expand affordance.
- Design system primitives: countdown-crossing highlight animation, chip-fade timing — to be standardized in the shared design-system doc post-Spec 5.

---

**Cross-spec links:**
- Spec 2 — adds `exam.targetMastery` field, ensures topic/subtopic catalog covers the plan's targeting needs.
- Spec 3 — explicitly *not* used for plan prefs (Firestore native partial-update is sufficient).
- Spec 4 — `quizPickerCalibrationProvider` is the targeting source of truth; Today's Session composer is the consumer of Spec 6's daily size.
- Spec 5 — mock completion is a strong-signal sizing recompute trigger; nearest mock card sources from `mock_attempts`.
