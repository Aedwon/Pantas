# User-Facing Metrics & Personality Fingerprint — Design

**Status:** Spec draft (ready for implementation plan)
**Date:** 2026-06-10
**Companion amendments:** Spec 11 (Progress), Spec 9 (Notifications)

---

## 1. Intent

Pantas tracks user behavior in raw form (attempts, sessions, mock attempts, FSRS state, lesson progress, streaks). This spec defines the **user-facing metrics taxonomy** that turns that raw data into two distinct experiences:

1. **Daily Home atoms** — single-signal chips that answer "how am I doing right now?" ("Sharpest at 9pm.")
2. **Wrapped-style artifacts** — multi-signal identity-coded shareable cards triggered at prep-journey moments ("The Night-Owl Sprinter — 12 weeks of focused review.")

The personality fingerprint is also the app's marketing engine: shareable 9:16 cards that drive viral spread, anchored to user-relative prep moments (post-mock, post-exam, streak milestones, mastery crossings) rather than calendar dates.

**Out of scope:** the Progress dashboard (Spec 11), B2B telemetry / event taxonomy (sibling spec), the `pantas.app/wrapped/<shareId>` landing page (sibling spec).

---

## 2. Locked Decisions

These are the brainstorm outputs the rest of the spec follows from. Each was a deliberate choice over named alternatives.

| # | Decision | Why |
|---|---|---|
| 1 | Scope = taxonomy + display contract per surface | Visual design deferred to implementation; this spec defines *what* and *where*, not pixel layout |
| 2 | Personality = hybrid (daily atoms + Wrapped synthesis) | Atoms keep Home alive; archetype labels reserved for shareable moments |
| 3 | 4 Wrapped artifacts: post-mock (gated), post-exam, streak milestone, mastery crossing | Each anchors to a prep-journey event, not a calendar date |
| 4 | 13 measured dimensions (T1 T2 T3 P1 P2 P4 S1 U1 X1 X2 D1 D2 D3) | All derivable from existing tables; no new instrumentation |
| 5 | Hybrid persistence: live for atoms, cached for archetypes + artifacts | Home stays fresh; expensive synthesis caches at compute time |
| 6 | Free vs Pro: identity content Free-full / Pro-depth; Progress dashboard Pro-gated | Marketing engine requires unblocked sharing; analytics utility is legitimate Pro upsell |
| 7 | Time windows: rolling-30d (Home), prep-window (Wrapped), all-time (achievements) | Surface intent determines window; Spotify-style precedent |
| 8 | Sharing: single 9:16 PNG, watermarked, deep link to personalized landing | 9:16 covers all platforms (IG/TikTok/FB/Twitter native or letterboxed) |
| 9 | Privacy: archetype + signals default; exam name and prep-week opt-in toggles; share-event analytics gated by Spec 10 consent | RA10173-clean by construction |
| 10 | Landing page is a sibling spec; this spec stubs the URL contract | Decouples web work from in-app metrics engine |

---

## 3. Architecture

### 3.1 Four-layer pipeline

```
┌─────────────────────────────────────────────────────────┐
│ Layer 4 — Artifacts                                     │
│ Wrapped renderers (4): post-mock, post-exam, streak,    │
│ mastery crossing. Compose 9:16 PNG → share sheet.       │
└────────────────────────▲────────────────────────────────┘
                         │ reads
┌────────────────────────┴────────────────────────────────┐
│ Layer 3 — Archetypes                                    │
│ Multi-signal synthesizers (~14). Returns label + line. │
└────────────────────────▲────────────────────────────────┘
                         │ reads
┌────────────────────────┴────────────────────────────────┐
│ Layer 2 — Atoms                                         │
│ Single-signal Home chips. Returns chip text + value.    │
└────────────────────────▲────────────────────────────────┘
                         │ reads
┌────────────────────────┴────────────────────────────────┐
│ Layer 1 — Signals                                       │
│ 13 pure aggregators over raw tables.                    │
└────────────────────────▲────────────────────────────────┘
                         │ reads
┌────────────────────────┴────────────────────────────────┐
│ Raw tables (already in repo)                            │
│ attempts • quiz_sessions • mock_attempts • review_state │
│ lesson_progress • daily_new_card_intro • streak         │
└─────────────────────────────────────────────────────────┘
```

### 3.2 Atoms vs Artifacts — same signal, different surface

**Atoms and artifacts may share an underlying signal, but they are separate surfaces with different UX intent.** The clearest example is the streak:

- **ConsistencyAtom** (Layer 2) reads signal T3 and shows `"Day 18 streak"` on Home **every day**. It's the live counter. It's informational and never "fires."
- **StreakMilestoneArtifact** (Layer 4) also reads T3 but **only triggers at thresholds 7 / 30 / 100 / 365**. At those moments, a full Wrapped reveal + shareable 9:16 card. The artifact is the badge-like celebration.

The signal layer is shared. The surfaces are not interchangeable. This same pattern applies elsewhere (T1 powers a daily Home chip *and* contributes to the Night-Owl Sprinter archetype).

### 3.3 Module layout

```
lib/features/metrics/         (new — shared engine)
  signals/                    13 aggregator files
  signals/models/             value-object outputs
  atoms/                      Home-chip selectors
  archetypes/                 synthesizers + label catalog
  data/                       2 Drift cache tables
  providers/                  Riverpod surface per layer

lib/features/wrapped/         (new — Layer 4 surfaces)
  artifacts/                  4 trigger + composition files
  presentation/               4 reveal pages + share flow
  rendering/                  9:16 PNG composer + watermark
  providers/

lib/features/progress/        (Spec 11 — see amendment)
  Consumes metrics/signals

lib/features/assessment/presentation/assessment_home_tab.dart
  Consumes metrics/atoms — atoms render into the existing Home tab.
  (Home migration to lib/features/home/ is a separate concern.)
```

### 3.4 Riverpod contract

Every layer exposes typed providers. Each surface consumes only one layer up — never two layers down.

- `metricsSignalProvider(SignalKey, MetricsWindow, ExamId)` → `AsyncValue<SignalResult?>`
- `homeAtomProvider(ExamId)` → `AsyncValue<AtomChip?>` (rotation built in)
- `currentArchetypeProvider(ExamId, MetricsWindow)` → `AsyncValue<ArchetypeResult?>`
- `wrappedTriggerStream` → `Stream<WrappedTriggerEvent>` (Spec 9 consumes this)

---

## 4. Layer 1 — Signals

### 4.1 Contract

```dart
abstract class Signal<T> {
  Future<T?> compute(MetricsWindow window, ExamId examId);
  Set<MetricsWindow> get supportedWindows;
  int get minDataPoints;
}

enum MetricsWindow { rolling30d, prepWindow, allTime }
```

`null` return = "not enough data" — never display empty/zero. Atoms and archetypes treat null as "skip."

### 4.2 The 13 signals

| # | Signal | Source tables | Output type | Status |
|---|---|---|---|---|
| T1 | TimeOfDay | `quiz_sessions`, `mock_attempts` | `DayHourHistogram` | uses captured data |
| T2 | SessionShape | `quiz_sessions` (startedAt→completedAt) | `DurationDistribution` | uses captured data |
| T3 | Consistency | `streak`, daily session histogram | `StreakPattern` | uses captured data |
| P1 | PerQuestionSpeed | `attempts.itemsJson.responseMs` | `LatencyDistribution` | uses captured data |
| P2 | MockPacing | `mock_attempts.elapsedSeconds`, section | `PacingProfile` | uses captured data |
| P4 | MockStamina | `mock_attempts` (first-half vs last-half acc) | `StaminaDelta` | needs aggregator |
| S1 | FlagRevisit | `mock_attempts.flagsJson` | `FlagRevisitRatio` | uses captured data |
| U1 | SubjectAffinity | `attempts × question.topic → subject` | `SubjectAccuracySpeed` | uses captured data |
| X1 | TestModeDelta | mock vs practice accuracy (matched topics) | `PressureDelta` | needs aggregator |
| X2 | DifficultyCalibration | `responseMs × correctness × FSRS difficulty` | `CalibrationCurve` | needs aggregator |
| D1 | ReadThenQuiz | `lesson_progress.readAt` vs first attempt on topic | `WorkflowRatio` | needs aggregator |
| D2 | RetentionShape | `review_state.stability`, lapses | `RetentionCurve` | uses captured data |
| D3 | CoverageBreadth | `lesson_progress` + topic catalog | `CoveragePct` | uses captured data |

### 4.3 Implementation rules

- Each signal is pure: input is `(window, examId)`, output is a typed value. No UI awareness, no providers held internally.
- Return types are immutable value objects in `signals/models/`.
- One Drift query per signal where possible. Multi-step aggregations (P4, X1, X2, D1) document their algorithm in a top-of-file docstring.
- Each signal has a unit test with synthetic fixture data (Section 11).

---

## 5. Layer 2 — Atoms

### 5.1 Contract

```dart
abstract class Atom {
  Future<AtomChip?> select({required ExamId examId});
}

class AtomChip {
  final String text;           // "Sharpest at 9pm"
  final String? metric;        // "9 PM" (highlight token)
  final ProDepth? proDepth;    // Pro-only inline depth widget
}
```

### 5.2 Atom catalog

| Atom | Signal | Window | Chip example | Pro depth |
|---|---|---|---|---|
| TimeOfDayAtom | T1 | rolling-30d | "Sharpest at 9pm" | hourly accuracy sparkline |
| SessionShapeAtom | T2 | rolling-30d | "Avg 8-min sits" | session-length trend |
| ConsistencyAtom | T3 | all-time (current) | "Day 18 streak" | weekday heatmap |
| PerQuestionSpeedAtom | P1 | rolling-30d | "12s avg, fast and accurate" | speed × accuracy scatter |
| SubjectAffinityAtom | U1 | rolling-30d | "Grammar 30% faster" | per-subject delta bars |
| CoverageBreadthAtom | D3 | all-time | "Touched 78% of syllabus" | per-subject coverage bars |
| RetentionShapeAtom | D2 | rolling-30d | "Strong cards lapse 3%" | FSRS stability trend |

Signals **P2, P4, S1, X1, X2, D1** are archetype/Wrapped only (synthesis-class signals) — no atom file.

### 5.3 Rules

- **Rotation:** Home shows one atom at a time. Selection is deterministic by `(localDate, userId)` hash — predictable across cold starts, doesn't repeat day-to-day.
- **Freshness:** atoms compute live on Home open. Riverpod re-evaluates on raw-table writes from quiz/mock completion.
- **Pro depth:** rendered inline below chip for Pro users. Free users see just the chip — no paywall, no teaser. Identity content is Free-full.
- **Empty state:** if today's atom returns null, fall back to the next atom in rotation. If all atoms return null (true day 1), Home shows existing assessment/study-plan card with no chip.

---

## 6. Layer 3 — Archetypes

### 6.1 Contract

```dart
abstract class Archetype {
  String get id;
  String get label;
  Set<SignalKey> get requiredSignals;
  Future<double> match({required ExamId examId, required MetricsWindow window});
  Future<String> synthesize({required ExamId examId, required MetricsWindow window});
}
```

### 6.2 Starter catalog — 14 archetypes

| Archetype | Signals | Wins on |
|---|---|---|
| Night-Owl Sprinter | T1 + T2 + P1 | late + short sits + fast |
| Early Bird Marathoner | T1 + T2 | early + long sits |
| Weekday Warrior | T1 + T3 | weekday-heavy + consistent |
| Game-Day Player | X1 | mock ≥ practice |
| Pressure Tightener | X1 | mock < practice (gentle framing) |
| Bookmark Strategist | S1 + P2 | high flag-revisit + paces well |
| Time Master | P2 | finishes mocks with spare time |
| Closer | P4 | accuracy steady/rises in last quartile |
| Wordsmith | U1 | verbal subjects fastest + most accurate |
| Numbers Person | U1 | quantitative subjects fastest + most accurate |
| Generalist | U1 | flat subject distribution |
| Scholar | D1 + D3 | reads-first + high coverage |
| Long Memory | D2 | low lapse on mature cards |
| Self-Aware | X2 | slows on hard, gets them right |

### 6.3 Resolution — picking ONE archetype to surface

1. Compute `match()` for every archetype whose `requiredSignals` are all non-null.
2. Apply **category priority**: Pressure-Mode (X1, X2) > Pace (T1, T2, P1) > Subject (U1) > Study Habit (D1, D2, D3) > Strategy (S1, P2, P4).
3. Within the top category, take highest `match` score.
4. Tie-break: deterministic by archetype id (alphabetical) — stable across cold starts.

Pressure-Mode wins on priority because X1/X2 are the most exam-actionable signals (most directly tied to exam-day performance).

### 6.4 Synthesis copy

Each archetype owns a deterministic copy template with the user's actual numbers filled in:

```
"You're sharpest at {peakHour} ({peakAccuracy}%), and you settle in for {avgSessionMin}-min sits."
```

No LLM, no runtime model. Templates live alongside the archetype file. Same evidence → same line.

### 6.5 Caching

- Archetype match scores + synthesized copy cached in `user_metrics_archetypes_local` (see §8).
- Recompute triggers: after each completed mock, after every 10 quiz sessions, on first-load-of-day, on `validUntil` expiry.

### 6.6 Free vs Pro

- Archetype label + one-line synthesis: **Free full**.
- Pro depth: "evidence breakdown" (which signals drove it, by how much), and *deferred* — cross-user exam-day benchmark (sibling spec when we have population data).

---

## 7. Layer 4 — Artifacts (Wrapped)

### 7.1 Contract

```dart
abstract class WrappedArtifact {
  String get id;
  ArtifactTrigger get trigger;
  Future<WrappedPayload> compose({required ExamId examId});
}

class WrappedPayload {
  final String title;
  final List<WrappedSlide> slides;     // 3–5 slides
  final String archetypeId;            // from Layer 3
  final ShareCard shareCard;           // 9:16 composition
}
```

### 7.2 The 4 artifacts

| Artifact | Trigger | Slide arc |
|---|---|---|
| **Post-mock recap** | mock completed AND (first-mock OR new PB) | Score → Pacing (P2) → Stamina (P4) → Subject standouts (U1) → Archetype line |
| **Streak milestone** | streak hits 7 / 30 / 100 / 365 | Streak count → Consistency shape (T3) → Day-of-week heat → Archetype |
| **Mastery crossing** | topic state weak → strong (FSRS stability threshold) | Topic name → Before/after % → Days to mastery → Coverage progress (D3) |
| **Post-exam debrief** | day after exam date | Total stats → Strongest week → Personality (full archetype reveal w/ 3+ signals) → "Your prep, in one line" |

### 7.2.1 Null-signal handling within a slide arc

When a slide depends on a signal that returns null (insufficient data), the slide is **silently skipped** and the arc continues without it. Each artifact must produce a coherent reveal with as few as 2 slides. Example: a user's very first mock triggers post-mock recap but has no P4 stamina history yet — the Stamina slide is omitted and the arc shrinks from 5 slides to 4.

The archetype line (final slide) requires the resolved archetype's `match()` to succeed; if no archetype resolves, the artifact does **not** fire even if the trigger condition is met. (Edge case: a true day-1 mock with no other signal data — falls back to a celebratory toast, not a Wrapped reveal.)

### 7.3 Gating

- **Post-mock recap:** only on first-mock or new PB. Otherwise a small celebratory toast (no Wrapped).
- **Streak milestone:** only at 7 / 30 / 100 / 365. Diminishing-return cadence avoids fatigue.
- **Mastery crossing:** only weak → strong (not weak → moderate). FSRS stability threshold defined in implementation plan.
- **Post-exam debrief:** exactly once per prep cycle.

### 7.4 Trigger plumbing

Each artifact has a `shouldFire(event)` method. Plumbing hooks into:

- `complete_mock.dart` → post-mock recap + post-exam check
- `streak_evaluator.dart` → streak milestone
- FSRS `review_state` update → mastery crossing
- Daily cold-start tick → catches post-exam (in case app wasn't open at trigger time)

Triggers emit `WrappedTriggerEvent` on `wrappedTriggerStream`. **Single source of truth** — Spec 9 (notifications) consumes the same stream for push routing, never duplicates trigger logic.

### 7.5 9:16 image composer

- Flutter `RepaintBoundary` + `Image.fromBytes` → off-screen canvas → PNG.
- Each artifact owns its template (`Widget buildShareCard(WrappedPayload)`), rendered at **1080 × 1920** logical pixels.
- **Watermark:** `pantas.app` text + small mark in bottom corner. Non-removable from the rendered PNG.
- **Deep link:** encoded as QR (small, bottom-right) AND as text. Format: `https://pantas.app/wrapped/<shareId>`. Stub contract; landing page lives in sibling spec.

### 7.6 Share flow

1. User taps Share on the Wrapped reveal.
2. App generates the 9:16 PNG (cached after first generation).
3. **Pre-share toggle sheet:** user sees "What's on this card?" preview with opt-in toggles for exam name and "Week X of Y." Both default off.
4. Native share sheet opens with the PNG attached.
5. If analytics consent (Spec 10) is granted, emit `wrapped_shared` event with `(artifactId, shareId, platform if OS hands it back)`.

### 7.7 Reveal pages

Each artifact has a `WrappedRevealPage` — full-screen sequence of slides (swipe or auto-advance), ending on the share CTA. The same composition the user sees in-app is what gets shared. WYSIWYG.

### 7.8 Free vs Pro

- All 4 artifacts: **Free full**. Marketing engine — no gates.
- Pro adds: "history" view to revisit past artifacts. Free sees each artifact only at its moment of trigger.

---

## 8. Persistence

### 8.1 `user_metrics_archetypes_local`

```dart
TextColumn userId
TextColumn examId
TextColumn window           // 'rolling30d' | 'prepWindow' | 'allTime'
TextColumn archetypeId
RealColumn matchScore       // 0.0–1.0
TextColumn synthesizedCopy
DateTimeColumn computedAt
DateTimeColumn validUntil   // soft TTL (24h from compute)

PK: (userId, examId, window, archetypeId)
```

### 8.2 `user_metrics_artifacts_local`

```dart
TextColumn userId
TextColumn examId
TextColumn artifactId       // 'post_mock_recap', 'streak_milestone_30', etc.
TextColumn shareId          // deep-link URL stub
TextColumn payloadJson      // full WrappedPayload as JSON
DateTimeColumn firedAt
DateTimeColumn? sharedAt    // set on share-sheet completion
TextColumn? sharePlatform   // only if OS hands it back

PK: (userId, examId, artifactId)
```

### 8.3 Recompute rules

- After each mock completion → recompute all archetypes.
- After every 10 quiz sessions → recompute.
- On first-load-of-day (new local-date) → recompute.
- Any read past `validUntil` → recompute.

### 8.4 Sync

**Both cache tables are derived-only and NOT synced via Spec 3.** On reinstall:
- Archetypes recompute on next load from synced raw tables.
- Artifact history is lost.

**Tradeoff acknowledged:** Pro users lose Wrapped history on reinstall. Acceptable for v1; additive sync path can be added later without schema breakage.

### 8.5 Migrations

- New archetype → no migration (orthogonal rows).
- New artifact → no migration.
- Signal output schema change → bump `signalsVersion` constant; mismatched rows recompute on next read.

### 8.6 Storage estimate

- Archetypes: 14 × 3 windows × ~200 B ≈ **8 KB / user**.
- Artifacts: ~30 events × ~2 KB ≈ **60 KB / user**.
- Total: **< 100 KB / user**. Negligible.

---

## 9. Time Windows

Per-signal, per-surface mapping:

| Signal | Home atom | Wrapped synthesis | Achievement framing |
|---|---|---|---|
| T1 Time-of-day | rolling-30d | prep-window | — |
| T2 Session shape | rolling-30d | prep-window | — |
| T3 Consistency | all-time (current streak) | prep-window | all-time (longest streak) |
| P1 Per-question speed | rolling-30d | prep-window | — |
| P2 Mock pacing | rolling-30d | prep-window | — |
| P4 Mock stamina | — | prep-window | — |
| S1 Flag-and-revisit | — | prep-window | — |
| U1 Subject affinity | rolling-30d | prep-window | — |
| X1 Test-mode delta | — | prep-window | — |
| X2 Difficulty calibration | — | prep-window | — |
| D1 Read-then-quiz | — | prep-window | — |
| D2 Retention shape | rolling-30d | prep-window | — |
| D3 Coverage breadth | all-time | all-time | all-time |

### 9.1 Rules

- **Home atoms = rolling-30d** for behavior signals (answer "lately"). Exceptions: T3 (current streak is by definition live), D3 (you don't un-cover a topic).
- **Wrapped synthesis = prep-window** uniformly. Wrapped is the retrospective.
- **Achievement framing = all-time** for records (longest streak, longest sit, best mock).

### 9.2 Prep-window definition

- **Start:** timestamp when the user first set their exam date during onboarding.
- **End:** now (in-flight artifacts) or exam date (post-exam debrief, which freezes the window).
- **Reschedules preserve the original start** — protects identity continuity if user changes exam date.

### 9.3 Data thresholds per window

- rolling-30d: ≥ 7 sessions in last 30 days.
- prep-window: ≥ 14 sessions total.
- all-time: ≥ 1 session.
- Below threshold → signal returns null → atom falls back per rotation rule.

### 9.4 Window visibility to user

- Home atoms: no label ("now" is implicit).
- Wrapped artifacts: visible anchor in title ("12 weeks of focused review").
- Achievement framing: labeled ("Longest streak: 31 days").

---

## 10. Privacy & Cross-Spec Contracts

### 10.1 Share card content defaults

- **Always included:** archetype label, signal stats, watermark, deep link.
- **Opt-in toggles (off by default):** exam name, prep-window framing ("Week 6 of 12"), user's display handle.
- "What's on this card?" preview shows toggles before share sheet opens.

### 10.2 RA10173 (Spec 10) contract

| Action | Consent? | Why |
|---|---|---|
| Generate Wrapped card on-device | No | User-initiated, on-device, no third-party processing |
| Hand PNG to OS share sheet | No | OS-mediated user action |
| Log `wrapped_shared` analytics event (emitted on share-sheet completion) | **Yes** | Existing analytics consent gate (Spec 10) |
| Log `wrapped_revealed` analytics event (emitted when user opens a reveal page) | **Yes** | Same gate |
| `sharedAt` written to local cache | No | Local-only |

Pattern: local state writes never need consent; events that travel off-device do. Mirrors Spec 10's existing model.

### 10.3 Dependencies

**Consumes:**
- Spec 3 (sync) — raw tables are source of truth; our cache tables are derived-only, not synced.
- Spec 6 (Study Plan) — exam date from onboarding is the prep-window start anchor.
- Spec 10 (Legal/RA10173) — analytics consent gate.

**Produces:**
- `metricsSignalProvider(signal, window, examId)` — Spec 11 dashboard reads here.
- `wrappedTriggerStream` — Spec 9 notifications reads here.
- `currentArchetypeProvider(examId)` — any future surface.

### 10.4 Amendment specs published alongside

- `2026-06-10-spec-11-progress-amendment-design.md`
- `2026-06-10-spec-09-notifications-amendment-design.md`

(No amendment for Spec 10 — share-event consent flows through existing gate.)

---

## 11. Testing

### Layer 1 — Signals (unit)
- One test file per signal. In-memory Drift db + synthetic fixtures.
- Edge cases: empty data, single-data-point, just-below-threshold, just-above-threshold.

### Layer 2 — Atoms (selector + widget)
- Mock signal provider, assert chip text.
- Render `HomeAtomChip` with various atom outputs (including null fallback).
- Rotation test: hash-of-date returns expected atom on known dates.

### Layer 3 — Archetypes (synthesis)
- Per archetype: fixture matching (high score) + fixture not matching (low score).
- Resolution test: multi-match fixture → correct category priority winner.
- Synthesis copy: same input → same string (deterministic).

### Layer 4 — Artifacts (trigger + composition)
- Trigger test: `WrappedTriggerEvent` in, `shouldFire` correct per gating rules.
- Composition test: `WrappedPayload` slide order and content per artifact.
- Image render test: PNG dimensions 1080×1920, watermark present. **No visual diff** — too brittle.

### Cache tests
- `validUntil` honored.
- Reinstall simulation: empty tables → archetype recompute on next load.

### Privacy integration tests
- Sharing with consent off: `sharedAt` set locally, no analytics event.
- Sharing with consent on: both happen.

### Out of scope for tests
- Visual regression on Wrapped cards (designer-iteration churn).
- Cross-platform share sheet behavior (OS-mediated).
- Notification delivery for Wrapped triggers (Spec 9 owns).

---

## 12. Deferred / Sibling Specs

| Deferred | Why | Lives in |
|---|---|---|
| `pantas.app/wrapped/<shareId>` landing page | Web work, conversion-funnel concerns | New landing-page spec |
| Cross-user benchmarks ("how this archetype scores on exam day") | Needs population data we don't have at launch | Post-launch analytics spec |
| Per-mock archetype evolution view (Pro) | Per-mock signal snapshots; nice-to-have | Spec 11 amendment Phase 2 |
| Notification copy and routing for Wrapped triggers | Spec 9 ownership | Spec 9 amendment |
| Sync of Wrapped artifact history | Acknowledged tradeoff; additive later | Future sync amendment |
| In-app "history" of past Wrapped artifacts (Pro) | Display surface, not engine | Spec 11 amendment Phase 2 |
| LLM-generated synthesis copy | Deterministic templates ship v1 | Future polish spec |
| 4:5 / 1:1 share format variants | 9:16 covers all platforms; only revisit on data signal | Future polish spec |
| Lesson reading depth + lesson revisit rate signals | Need new instrumentation | Future signals expansion |

### Stub contracts other specs must honor

- Deep link URL: `https://pantas.app/wrapped/<shareId>`
- `WrappedTriggerEvent` stream shape (Spec 9 reads)
- `metricsSignalProvider(signal, window, examId)` (Spec 11 reads)
- `currentArchetypeProvider(examId)` (future surfaces read)
