# Spec 5 — Mock Exam (design)

**Status:** Brainstormed (2026-05-17).
**Depends on:** Spec 1 (auth), Spec 2 (`mockBlueprintRepoProvider`, `questionRepoProvider`), Spec 3 (`SyncCoordinator`), Spec 4 (Drill mode deep-link, `RatingHeuristic` if shared, `subTopicId` field).
**Soft dependency:** Spec 7 (paywall + entitlement) — Spec 5 ships its free-tier rules independently and reads `entitlementProvider.proIsActive` once Spec 7 lands.

## 1. Overview

Spec 5 adds a blueprint-driven, timed mock-exam flow to the CSE/CET Reviewer App. Each attempt samples a fresh question set from a `MockBlueprint` (Sanity-authored, cached in `content.db`), runs a countdown-headered session with free navigation + flag-for-review, persists state to Drift on every change + a 30 s heartbeat, and produces an action-oriented results screen that deep-links into Spec 4's Drill mode for follow-up practice. Free tier gets 1 mock per 14 days per exam track; Pro is unlimited.

## 2. In scope / non-goals

**In scope:**

- Blueprint-sampled mock generation from `mockBlueprintRepoProvider`.
- Timed session with warnings at 5:00 and 1:00, hard auto-submit at 0:00.
- Free navigation across questions + flag-for-review + bottom-sheet question grid.
- Pause (clock stops, first-time warning dialog).
- Strict-mode Settings toggle: hides pause + auto-forfeits on background >5 s.
- Crash-safe attempt state (per-change flush + 30 s heartbeat).
- Resume sheet on launch when an in-progress attempt exists; Discard refunds the slot.
- Free tier: 1 active mock per 14 days per `examId`; Pro: unlimited. Cooldown begins on submit/auto-submit/strict-forfeit.
- Post-mock results: score band, per-section accuracy + time, top-3 weak topics with deep-link into Drill; ~~Pro unlock for full per-question review~~ (amended 2026-07-28: the review is on both tiers, Pro adds the per-choice note. See D11).
- History list paginated (last 10 + "See all"); attempts persist forever locally + via Spec 3 sync (terminal state only).
- Delight micro-interactions consistent with the shared design-system primitives (see §8).

**Non-goals (deferred or explicitly not building):**

- `mockExam` doctype (pre-curated papers). Ingested by Spec 2 but not surfaced in v1. Flip on later by adding a "Practice Papers" tab to the chooser.
- Feeding mock answers into FSRS. Spec 5 is summative-only; the connection from "weak topics in mock" to "future review pressure" goes through the Drill CTA, not through FSRS state.
- AI/LLM features (personalized narrative feedback). Roadmap-locked.
- Score-impact-narrative simulator ("if you got X more right…"). Possible Pro flourish post-launch.
- Multi-device live sync of an in-progress attempt. The attempt is device-local until terminal.
- Proctoring features (camera, eye tracking, screen-lock detection beyond strict-mode background detection).
- Tablet / rotation layouts. Android phone, portrait only (locked by roadmap).

## 3. Locked decisions

These were resolved during brainstorm; rationale in §3.x.

| # | Question | Decision |
|---|---|---|
| D1 | Mock question source | Blueprint-sampled only. `mockExam` doctype ingested but not surfaced. |
| D2 | Multiple blueprints per exam | Smart chooser: bottom-sheet picker if >1 blueprint; direct entry if 1. |
| D3 | IA entry point | Quiz tab is canonical; Home dashboard shows a state-aware status card that deep-links. |
| D4 | FSRS coupling | Summative-only. Separate `mock_attempts` table. Post-mock weakness → Drill is the bridge. |
| D5 | Time at 0:00 | Hard auto-submit, with snackbar at 5:00 and banner at 1:00. In-flight answer counts. |
| D6 | Pause + strict mode | Pause stops the clock; first-time-per-attempt warning dialog. Strict mode is a Settings-only toggle. |
| D7 | Background handling | Default: clock keeps running on background (no penalty). Strict: forfeit after >5 s away. |
| D8 | Section navigation | Full free nav + flag-for-review + bottom-sheet navigator with jump shortcuts. |
| D9 | Resume prompt | Always offer a resume sheet with elapsed + remaining. Discard refunds slot. Stale rows (remaining ≤ 0) auto-finalize as timeUp. |
| D10 | Cooldown semantics | Cooldown begins on submit / auto-submit / strict-forfeit. In-progress holds the slot. Discard refunds. |
| D11 | Results screen depth | **Amended 2026-07-28, see `2026-07-28-mock-exam-ui-design.md` §5.** Free now gets the full per-question review, the correct answer and the authored explanation; Pro adds the note on the choice made. ~~Free: score + section + top-3 weak topics + Drill CTA. Pro: full per-question review with explanations.~~ |
| D12 | History lifecycle | Keep forever locally + Firestore. UI paginates: last 10 + "See all". |

### 3.x Notes on rationale

- **D1** preserves replayability (the core value of "1 mock per 14 days"). Pre-curated stock burns out fast under unlimited Pro use and undermines the "no two mocks identical" pitch.
- **D4** prevents a single mock from dumping 80–120 wrong answers into the FSRS queue, which would corrupt pacing and create a "punishment for taking the mock" feel.
- **D5** preserves score comparability and trains the real time-management skill the exam tests.
- **D6 + D7** make strict mode a *meaningful commitment device* (not just pause-disabled) — Settings copy must read: *"Strict mode auto-submits if you leave the app or lock the screen. Use only when you really want to simulate the real exam."*
- **D10** rewards completion without trapping users. Strict-forfeit consumes the slot (otherwise strict becomes a free retry button).

## 4. Architecture

### 4.1 Module layout

```
lib/features/mock_exam/
├── data/
│   ├── mock_attempt_table.dart       Drift table (app.db)
│   ├── mock_attempt_repo.dart        CRUD + queries
│   ├── mock_sampler.dart             Blueprint → sampled question list
│   └── blueprint_section.dart        Parsed sectionsJson
├── domain/
│   ├── mock_attempt.dart             Entity (snapshot)
│   ├── mock_session_state.dart       Sealed in-flight state
│   ├── mock_results.dart             Computed analysis
│   └── use_cases/
│       ├── start_mock.dart
│       ├── apply_answer_change.dart
│       ├── flush_session.dart
│       ├── submit_mock.dart
│       ├── discard_mock.dart
│       └── compute_results.dart
├── application/
│   ├── mock_session_controller.dart   Riverpod state + timer
│   ├── mock_availability_provider.dart
│   ├── mock_persistence_scheduler.dart
│   └── strict_mode_lifecycle.dart
└── presentation/
    ├── pages/
    │   ├── mock_setup_page.dart
    │   ├── mock_session_page.dart
    │   ├── mock_results_page.dart
    │   └── mock_history_page.dart
    └── widgets/
        ├── mock_status_card.dart
        ├── mock_quiz_tab_tile.dart
        ├── blueprint_picker_sheet.dart
        ├── question_navigator_sheet.dart
        └── mock_resume_sheet.dart
```

### 4.2 Riverpod provider graph

```
// existing (from earlier specs)
mockBlueprintRepoProvider        (Spec 2)
questionRepoProvider             (Spec 2)
selectedExamFocusProvider        (existing)
entitlementProvider              (Spec 7, soft dep)

// new in Spec 5
mockAttemptRepoProvider          Provider — wraps app.db
mockSamplerProvider              Provider — pure function-style
mockAvailabilityProvider         Provider — reads entitlement + last completed
mockSessionControllerProvider    NotifierProvider — holds the in-flight session
mockPersistenceSchedulerProvider Provider — listens to controller, debounces writes
```

### 4.3 Why this shape

- `mock_session_state.dart` as a sealed class makes the timer + persistence scheduler defensive. Every transition is exhaustive.
- The sampler is pure data-in/data-out. Randomness is parameterized via a seeded `Random` for reproducible tests.
- The persistence scheduler is split from the controller so the controller can be tested without a real Drift instance.
- The strict-mode lifecycle observer attaches only when the in-progress attempt has `strictMode=true`, so non-strict attempts pay zero cost for background watching.

### 4.4 Cross-spec contact points

| Other spec | Spec 5 reads | Spec 5 writes |
|---|---|---|
| Spec 1 (Auth) | `userIdProvider` for row ownership | — |
| Spec 2 (Content) | `mockBlueprintRepoProvider`, `questionRepoProvider` | — |
| Spec 3 (Sync) | — | `mock_attempts` rows on terminal-state transitions only. Requires SyncCoordinator `syncPredicate` extension (see §11). |
| Spec 4 (Quiz) | Results screen constructs Drill deep-links with `subTopicIds` | — |
| Spec 7 (Paywall) | `entitlementProvider.proIsActive` for unlimited-vs-1-per-14d gate; Pro-only "see every answer" CTA | — |

## 5. Data model

### 5.1 New Drift table: `mock_attempts` (in `app.db`)

```dart
class MockAttempts extends Table {
  TextColumn  get id                   => text()();             // uuid
  TextColumn  get userId               => text()();             // Spec 1
  TextColumn  get examId               => text()();             // per-track cooldown key
  TextColumn  get blueprintId          => text()();
  TextColumn  get blueprintName        => text()();             // denormalized — survives blueprint retirement
  IntColumn   get durationMinutes      => integer()();          // frozen at start
  TextColumn  get status               => text()();             // in_progress | completed | discarded | forfeited
  BoolColumn  get strictMode           => boolean()();          // snapshot of Settings toggle at start

  TextColumn  get sampledQuestionsJson => text()();             // [{sectionId, name, questionIds: [...]}]

  IntColumn   get elapsedSeconds              => integer().withDefault(const Constant(0))();
  IntColumn   get accumulatedPausedSeconds    => integer().withDefault(const Constant(0))();  // for resume-after-kill fallback math (§6.3)
  BoolColumn  get pausedAtLastFlush            => boolean().withDefault(const Constant(false))();  // true if user was paused when flush happened — disables wall-clock catch-up on resume
  TextColumn  get answersJson                 => text().withDefault(const Constant('{}'))();  // {qid: {idx, atSec}}
  TextColumn  get flagsJson            => text().withDefault(const Constant('[]'))();   // [qid, ...]
  IntColumn   get currentIndex         => integer().withDefault(const Constant(0))();

  IntColumn   get scoreRaw             => integer().nullable()();
  IntColumn   get scoreTotal           => integer().nullable()();
  TextColumn  get sectionResultsJson   => text().nullable()();
  IntColumn   get totalTimeSeconds     => integer().nullable()();

  IntColumn   get startedAt            => integer()();          // unix ms
  IntColumn   get lastFlushedAt        => integer()();          // 30 s heartbeat
  IntColumn   get submittedAt          => integer().nullable()();
  IntColumn   get updatedAt            => integer()();          // Spec 3 LWW key

  @override Set<Column> get primaryKey => {id};
}
```

**Indexes:** `(userId, examId, status)` for active-attempt + cooldown queries; `(userId, submittedAt DESC)` for history.

**Answer record shape inside `answersJson`:**

```json
{"<questionId>": {"idx": 1, "atSec": 423}}
```

`atSec` is `elapsedSeconds` at the moment the answer was last set. Lets the results screen compute approximate section-time even under free navigation (section time = max `atSec` of section's question IDs minus the prior section's max).

### 5.2 Domain shapes

```dart
class BlueprintSection {
  final String id, name;
  final int questionCount;
  final int suggestedMinutes;
  final List<String> topicIds;
  final Map<String, double>? topicWeights;
}

sealed class MockSessionState { const MockSessionState(); }
class Idle        extends MockSessionState {}
class InProgress  extends MockSessionState { /* attemptId, elapsed, answers, flags, currentIndex, remaining */ }
class Paused      extends MockSessionState { /* same fields as InProgress */ }
class Submitting  extends MockSessionState {}
class Submitted   extends MockSessionState { final MockResults results; }
class Discarded   extends MockSessionState {}
class Forfeited   extends MockSessionState { final ForfeitReason reason; }

enum ForfeitReason { timeUp, strictBackground }

class MockResults {
  final int scoreRaw, scoreTotal;
  final double percent;
  final ScoreBand band;
  final List<SectionResult> sections;
  final List<WeakTopic> topWeak;     // up to 3, min 2 sampled per topic
  final Duration totalTime;
  final bool wasStrict;
  final ForfeitReason? forfeitReason; // null unless Forfeited
}
```

### 5.3 Sampling algorithm (`mock_sampler.dart`)

1. For each `BlueprintSection`, allocate `questionCount` across `topicIds` proportional to `topicWeights` (uniform if absent). Use Hamilton apportionment to absorb rounding remainders.
2. For each bucket, pull from `questionRepoProvider.byTopic(topicId, activeOnly: true)`.
3. **Recency filter:** exclude `questionId`s present in the user's last 2 completed `mock_attempts.sampledQuestionsJson`. If filtering drops a bucket below its target size, fall back to the unfiltered pool — never fail-to-start.
4. Shuffle with a seeded `Random` (seed = `userId.hashCode ^ startedAt`) so test runs are reproducible.
5. Concatenate sections in blueprint order. Freeze into `sampledQuestionsJson`.
6. If a section can't fulfill its full count even after fallback, mark the attempt `partiallyFulfilled` and surface a one-time setup-page toast: *"This mock has N questions instead of M — content is being added."*

### 5.4 Score bands

Per-exam thresholds live on the `exam` doctype in Sanity. Fallback defaults if a doc lacks `scoreBands`: **≥75 % pass / 60–74 % borderline / <60 % fail.** A content-side task tracks populating real thresholds before launch.

### 5.5 Sync coupling (Spec 3)

`mock_attempts` rows enter the sync set **only when `status` is terminal** (completed / discarded / forfeited). In-progress rows are device-local — they churn frequently and a multi-device live attempt is a non-goal. This requires a per-table `syncPredicate` capability on `SyncCoordinator`; if Spec 3's implementation doesn't already support it, that delta must land before Spec 5 ships (tracked in §11).

Terminal rows then follow the normal LWW pattern keyed on `updatedAt`.

## 6. Attempt lifecycle

### 6.1 State machine

```
                            ┌──────────────────────────────┐
                            ▼                              │
   Idle ──Start──▶ InProgress ──Pause──▶ Paused ──Resume──┘
                       │                    │
                       │                    └──Discard──▶ Discarded
                       │
                       ├──Tick(remaining=0)─▶ Submitting ──▶ Submitted (timeUp)
                       ├──Submit (manual)──▶ Submitting ──▶ Submitted
                       ├──Background>5 s (strict only)──▶ Submitting ──▶ Forfeited (strictBackground)
                       └──Discard (from resume sheet)──▶ Discarded
```

### 6.2 Start

1. `mockAvailabilityProvider.isAvailable` check (Pro short-circuits cooldown).
2. Resolve blueprint (auto-pick if 1, else the chooser sheet returns the selection).
3. `MockSampler.sample(blueprint, userId)` → `sampledQuestionsJson`.
4. Insert `mock_attempts` row with `status='in_progress'`, `strictMode = settings.strictMockMode`, `durationMinutes` frozen from blueprint.
5. Controller enters `InProgress`. Navigate to `MockSessionPage`. Timer starts.

### 6.3 Timer & elapsed-time computation

The clock must keep running while the app is backgrounded or briefly killed in default mode (per D7) — so we **do not** accumulate by ticks. Instead:

- **While app is alive:** `MockSessionController` holds a `Stopwatch` (monotonic) started at attempt start and paused/resumed alongside the session. `elapsedSeconds = stopwatch.elapsed.inSeconds`. A `Timer.periodic(1 s)` only drives UI refresh + warning emissions; it does not advance the counter.
- **On resume after process kill:** the Stopwatch is gone. Recompute based on `pausedAtLastFlush`:
  - If `pausedAtLastFlush == true`: the user was paused when the app died, so wall-clock time during the kill window shouldn't count. `elapsedSeconds = persistedElapsedSeconds`. The user is restored un-paused (kill-while-paused simplification — see §6.6).
  - If `pausedAtLastFlush == false`: the user was actively in the mock when it died, so backgrounded/killed time *should* count (default-mode D7 guarantee). `elapsedSeconds = max(persistedElapsedSeconds, (now − startedAt − accumulatedPausedSeconds))`. The `max` also prevents a manual device-clock rollback from reducing elapsed.

The persistence scheduler (§6.5) writes `elapsedSeconds`, `accumulatedPausedSeconds`, and `pausedAtLastFlush` on every flush, so the fallback math always has the data it needs. `startedAt` is unix-ms (UTC), so timezone changes don't affect the wall-clock diff.

Strict mode never relies on the fallback path: backgrounding > 5 s triggers forfeit (§6.7) before resume can happen.

### 6.4 Warnings

- `remaining == 300` → soft snackbar: *"Heads up — 5 minutes left."*
- `remaining == 60` → top banner (accent color): *"Almost there — 1 minute left!"*
- `remaining == 0` → controller flips to `Submitting`, cancels timer, calls `SubmitMock(reason: timeUp)`. In-flight answer counts.

### 6.5 Persistence scheduler

`mock_persistence_scheduler.dart` listens to `MockSessionController` and flushes under two triggers:

1. **Change-debounced flush** — 500 ms after the last mutation to `answers`, `flags`, or `currentIndex`. Coalesces rapid-fire navigation into one write.
2. **Heartbeat flush** — every 30 s while `InProgress`, even with no changes, capping crash loss to ≤30 s of `elapsedSeconds`.

Pause / resume transitions force an immediate flush. The flush payload always includes `lastFlushedAt = now` and `updatedAt = now`.

### 6.6 Pause UX (default mode)

- Tap Pause → `Paused`, timer cancels, flush.
- First time per attempt: warning dialog *"Real exams don't pause. Use this only when you have to."* — Continue / Cancel. Cancel restores `InProgress`.
- Subsequent pauses skip the dialog.
- Paused screen shows elapsed time, a big Resume button, and a subtle Discard option.
- **If the app is killed while paused**, the next launch's resume sheet (§6.8) shows the attempt as in-progress (not paused) — the user is restored un-paused with `elapsedSeconds` preserved from flush time (no wall-clock catch-up; see §6.3). If they meant to stay paused, they can tap Pause again.

### 6.7 Strict-mode lifecycle

Attached only when `strictMode=true`. Uses `WidgetsBindingObserver`:

- `AppLifecycleState.paused` → start a 5 s guard timer.
- App resumes within 5 s → cancel guard (benign).
- Guard fires → controller flips to `Submitting`, calls `SubmitMock(reason: strictBackground)`. Cooldown consumes per D10.
- On relaunch, the resume sheet is bypassed for a forfeited attempt; the user lands on the results screen tagged "Forfeited — you left the app during strict mode" with the partial score.

### 6.8 Launch-time resume intercept

In `app.dart`, on the first frame after auth resolves, query `mockAttemptRepoProvider.findInProgress(userId)`. If non-null:

- Show `MockResumeSheet` before any other navigation.
- Sheet: blueprint name, elapsed time, **remaining time**. Resume / Discard.
- **Auto-clean stale (non-strict):** if computed `remaining ≤ 0`, the sheet does not render — the attempt is auto-finalized as `Submitted (timeUp)` from the persisted answers, and the user routes to results.

### 6.9 Submit flow

1. Controller in `Submitting`.
2. `ComputeResults` runs:
   - Per question: lookup correct answer in `content.db`; missing user answer → incorrect; retired question (`!isActive` or deleted) → excluded from `scoreTotal`.
   - Section breakdown: accuracy + derived section time (max `atSec` of section's questions minus prior section's max).
   - Top-3 weak topics: filter to topics with ≥2 sampled, sort by accuracy ASC, take 3.
   - Score band: `exam.scoreBands` with default fallback.
3. Persist: `status='completed'` (or `'forfeited'`), `submittedAt = now`, score fields, `sectionResultsJson`, `totalTimeSeconds`, `updatedAt = now`.
4. Controller flips to `Submitted(results)` → router replaces stack with `MockResultsPage`.

### 6.10 Discard

Available from the launch resume sheet and from the pause screen. Confirm dialog: *"Discard this mock? Your slot will be refunded, but the attempt won't be saved."* Confirm → `status='discarded'`, `updatedAt = now`. Controller resets to `Idle`. Slot becomes available.

## 7. UI surfaces

### 7.1 Routes (added to `router.dart`)

```
/quiz/mock/setup           push
/quiz/mock/session         push (replaces stack on Submit)
/quiz/mock/results/:id     replace
/quiz/mock/history         push
```

All mock screens live under the Quiz route prefix to reinforce Spec 4's IA (Quiz tab = assessment hub). Drill deep-links use the existing `/quiz/drill?topic=…` route.

### 7.2 Surfaces

| Surface | Where | Behavior |
|---|---|---|
| `MockStatusCard` | Home dashboard | Reads `mockAvailabilityProvider`. States: **Mock ready** ("Ready to practice?" + Start button), **Cooldown** ("Next mock in N days"), **In progress** ("Resume →"). Tap routes into Quiz tab → Start CTA. |
| `MockQuizTabTile` | Quiz tab | Tile alongside Today's Session, Drill, Retake. Same three states; CTA is the primary tap target, not a deep-link. |
| `BlueprintPickerSheet` | Modal | Shown only when `blueprints.length > 1`. One tap returns the selection to setup. |
| `MockSetupPage` | Push | Pre-mock confirmation. Headline: *"Ready to practice?"* Shows blueprint name, total duration, question count, sections at a glance. Strict-mode badge if Settings toggle is on. Copy: *"Real exam rules apply — once you start, the clock keeps running even if you close the app."* Big Start button. |
| `MockSessionPage` | Push (no back) | Sticky header: section label + `<n> of <N>` + countdown + pause icon (hidden in strict). Body renders the question via `PortableTextRenderer`. Bottom action row: **Back / Flagged / Questions / Next**. System back is intercepted → confirm dialog: *"Leave mock? (clock keeps running)"* — does not pause or submit. |
| `QuestionNavigatorSheet` | Bottom sheet | Grid of question numbers grouped by section. Three pill states: answered (filled), flagged (outlined accent), blank (default). Current question is ringed. Footer: *"Next blank →"* and *"Next flagged ⚑"*. |
| Pause screen | State of `MockSessionPage` | Replaces body with elapsed time + big Resume button + subtle Discard. Reached only via Pause action (gated by first-time warning). Strict mode never reaches this state. |
| Warning overlays | On `MockSessionPage` | 5:00 → snackbar (3 s auto-dismiss). 1:00 → banner, accent color, dismiss-on-tap. 0:00 → no overlay; screen flips to Submitting → results. |
| `MockResumeSheet` | Launch intercept | Full-screen. Blueprint, elapsed, remaining, Resume / Discard. Stale rows auto-route to results without rendering. Strict-forfeit attempts bypass entirely. |
| `MockResultsPage` | Replace | **Free:** score band card with pass-gauge marker; *"How you did per part"* section table (accuracy + time vs suggested, over-time shown in red); *"Practice these next"* card with top-3 weak topics and `Practice →` links; single Pro upsell *"See every answer and why it's right · Try Pro"*; footer *"Saved · Next mock in 14 days"*. **Pro:** above + expandable per-question review with user answer, correct answer, full explanation. Strict-mode attempts show a Strict badge. Forfeited attempts show *"Forfeited — you left the app during strict mode"* header instead of pass/fail band. |
| `MockHistoryPage` | Push (entry: Quiz-tab footer link *"See past mocks →"*) | Reverse-chronological list. Paginated: last 10 + *"See all"*. Each row: blueprint name, date, score, badges (Strict / Forfeited). Tap → that row's results page. If last 3+ scores trend up, show *"📈 Your scores are climbing!"* pill above the list. |
| Settings entry | Settings tab | New section *"Mock exams"* → *"Strict mode"* toggle with subtext: *"Strict mode auto-submits if you leave the app or lock the screen. Use only when you really want to simulate the real exam."* |

### 7.3 Copy register

All user-facing strings target a junior-high reading level: short sentences, plain words, encouraging tone. Avoid jargon ("borderline", "remediation", "diagnostic"). Cooldown framing is anticipation, not punishment. Forfeit copy is empathetic, never shaming.

## 8. Delight moments

Spec 5 leans on a shared design-system primitives doc (to be authored after Spec 5 — see §11). Until that lands, the moments below describe behavior; the primitives doc will standardize the timing curves, haptic taxonomy, and lottie library that implement them.

| Moment | Treatment |
|---|---|
| First answer selected per question | Light haptic + soft tick sound + bullet animates from outline to fill (~200 ms ease-out) |
| Flag toggle | Medium haptic + corner-fold animation on the flag glyph |
| Crossing into a new section | 1.5 s overlay: check icon + sparkles + *"&lt;Section&gt; done!"* + *"Up next · &lt;Next section&gt;"* pill, then auto-dismiss |
| 5:00 warning | Soft snackbar with subtle chime |
| 1:00 warning | Banner with a slightly firmer chime |
| Submit confirmation | Warm dialog: *"Ready to submit? You did the work."* — not *"Are you sure?"* |
| Results reveal | Score number counts up from 0 over ~800 ms. Confetti lottie for pass-band. Gentle wave animation for borderline. Warm-light pulse for fail (never red, never punitive) |
| Practice-these pills | Subtle hover-lift to suggest tappability |
| Cooldown state on Home | Subtle countdown ring around the icon. Copy reframes the wait as anticipation. |
| Discard / strict forfeit | Empathetic copy: *"The clock kept going. Here's where you got to. Your slot is refunded — try again."* (for discard) and *"You left during strict mode. Here's where you got to. Take another shot when you're ready."* (for forfeit). No red, no shame. |
| History trend pill | If last 3+ mocks trend up, show *"📈 Your scores are climbing!"* with a gentle bounce on first reveal |

## 9. Error handling & edge cases

| Scenario | Handling |
|---|---|
| Offline during mock | Fully supported. After `StartMock`, nothing in the in-mock path needs network. Sync happens on terminal state and `SyncCoordinator` buffers. |
| Question retired mid-attempt | Excluded from `scoreTotal`. `sectionResultsJson` notes `{retired: N}`. |
| Correct-answer edited mid-attempt | Score against current key. Accepted limitation (near-zero rate; snapshotting answer keys is a worse maintenance hazard). |
| Insufficient question pool at sampling | Try relaxing the recency filter; fall back to all `isActive` questions; on still-short, mark `partiallyFulfilled` and surface a setup-page toast. If a section returns zero: hard error with a clear retry-or-pick-other message. |
| Drift flush failure | Log + retry on next tick. After 30 s of failures: single banner *"Saving paused — try freeing some space."* Don't spam. |
| `StartMock` insert failure | Full-screen error with Retry. No user data lost. |
| Corrupt resume row | Treat as missing. Log to Crashlytics. Soft-delete row (`status='discarded'`). Slot becomes available. |
| App killed mid-attempt | 30 s + on-change persistence covers it. Resume sheet on launch handles recovery. Worst-case loss: <30 s of `elapsedSeconds` if no answer changes occurred. |
| Device clock past `startedAt + duration` on relaunch | Resume sheet auto-finalizes as timeUp; routes to results. Persisted answers used for scoring. |
| Strict-mode background <5 s | No forfeit, no warning. Logged in attempt metadata as `backgroundedSeconds` for debug telemetry. |
| Pro → Free transition mid-cooldown | Cooldown is *always* computed from the most recent terminal `submittedAt`, never stored separately. No migration code needed. |
| Two devices, in-progress | In-progress is device-local. Both devices may start their own attempt; LWW resolves on completion. Cosmetic-only quirk (rare for v1 audience). |
| Strict mode + screen lock | Screen-off triggers `AppLifecycleState.paused` → forfeit. Intentional; Settings copy makes this explicit. |
| Timezone change mid-attempt | `startedAt` is unix-ms (UTC). Timezone shifts don't affect the wall-clock fallback math. |
| Manual device-clock rollback | Stopwatch (monotonic) is unaffected while app is alive. On resume after kill, `elapsedSeconds = max(persisted, wallClockDiff)` prevents elapsed from decreasing. |
| Tablet rotation | Out of scope. Portrait-only. |

## 10. Testing strategy

### 10.1 Unit tests (`test/features/mock_exam/`)

| Target | Coverage |
|---|---|
| `MockSampler` | Stratified allocation matches `topicWeights`; Hamilton apportionment correctness; recency filter; fallback path; seeded `Random` determinism; pool-too-small returns `partiallyFulfilled` |
| `BlueprintSection` parser | Valid JSON round-trip; malformed JSON throws typed `BlueprintParseError`; safe defaults for missing optionals |
| `ComputeResults` | Scoring with missing answers; retired questions excluded; section breakdown sums; top-3 weak-topic min-2-sampled rule; deterministic tie-breaking; score-band fallback |
| `MockSessionState` transitions | Exhaustiveness; invalid transitions throw `StateError`; `Paused` flushes immediately on entry |
| `MockAvailability` | Free no-prior → available; free <14 d → cooldown; free ≥14 d → available; Pro → always available; in-progress overrides cooldown |

### 10.2 Drift integration (`test/features/mock_exam/data/`)

In-memory Drift pattern. Cover row insert/read, both query shapes, `lastFlushedAt`-only writes not triggering `updatedAt` LWW churn, and soft-delete-discard semantics.

### 10.3 Widget tests

| Widget | Scenarios |
|---|---|
| `MockSessionPage` | Question render by index; answer-select haptic stub; pause hidden in strict mode; countdown color states; system-back invokes confirm dialog |
| `QuestionNavigatorSheet` | 3-state pill rendering; current-question ring; tile-tap navigation; *"Next blank →"* finds lowest unanswered; *"Next flagged ⚑"* cycles in order |
| `MockResumeSheet` | Resume restores state; Discard calls use case; stale rows skip render and parent auto-finalizes |
| `MockResultsPage` | Free tier locks Pro card; Pro tier expands review; forfeited attempts show forfeit header; weak-topic deep-link URL correctness |
| `MockStatusCard` | All three states render distinctly; tap routes correctly |

### 10.4 End-to-end (Flutter `integration_test`)

Critical-path scenarios on a real emulator in CI:

1. **Happy path:** sign in → seed content → full mock → results visible → row in history.
2. **Crash recovery:** start mock, answer some, kill process, relaunch → resume sheet → state restored within ±30 s.
3. **Strict forfeit:** strict toggle on → start → simulate background >5 s → relaunch → forfeit results shown, cooldown consumed.

### 10.5 Cross-spec contract tests

- **Spec 2:** `mockBlueprintRepoProvider.byExam` returns parseable `sectionsJson`; questions include `subTopicId`.
- **Spec 3:** terminal-status `mock_attempts` rows are picked up by `SyncCoordinator` outbound; in-progress rows are not. (Requires §11 delta.)
- **Spec 4:** Drill deep-link URLs from results are accepted by the Drill router and pre-filter the picker.
- **Spec 7 (post-launch):** Pro → Free transition recomputes cooldown from the last completed attempt.

### 10.6 Coverage targets

Match project floor (~80 % line coverage on `lib/features/mock_exam/`), with sampler + state machine targeted at ~95 % (high-value pure logic).

### 10.7 Explicit non-coverage

Multi-device live in-progress sync; tablet / rotation; real Firestore writes (stubbed); Lottie visual regression; performance benchmarks.

## 11. Open items / follow-ups (must land before or alongside Spec 5)

| Item | Owner | Notes |
|---|---|---|
| `SyncCoordinator.syncPredicate` per-table support | Spec 3 amendment | Required so `mock_attempts` filters on terminal status. If not already designed in Spec 3, add the smallest viable extension. |
| `exam.scoreBands` populated in Sanity | Content team | Pass/borderline/fail thresholds per exam. Defaults exist in code but real thresholds should land before launch. |
| Shared design-system primitives doc | New tiny spec or amendment to `2026-05-08-frontend-ui-ux-design.md` | Motion curves, haptic taxonomy, sound-effect palette, lottie library, color-temperature mapping. Spec 5's §8 references this doc once it exists. |
| Spec 4 delight amendment | Separate session after Spec 5 commits | Each Quiz mode (Today's Session / Drill / Retake / Inline) needs its own delight moments listed; cleaner as a dedicated session than fitting into Spec 5's brainstorm. |
| Settings: Strict-mode toggle copy review | Design pass | Copy proposed in §7.2; verify against the design-system tone guide once primitives doc lands. |

## 12. Glossary

- **Mock blueprint:** Sanity-authored definition of a mock paper's structure (sections, topic pools, durations). Spec 2 ingests this; Spec 5 samples from it.
- **Section:** A blueprint subdivision (e.g. Verbal, Numerical). Has a question count, suggested time, and a topic pool.
- **Strict mode:** A Settings-level commitment toggle that disables pause and auto-forfeits the attempt if the user leaves the app for >5 s.
- **Slot:** A user's right to one mock attempt within the free-tier 14-day cooldown window. In-progress holds it; submit/auto-submit/strict-forfeit consume it; discard refunds it.
- **Terminal state:** Any `mock_attempts.status` value that isn't `in_progress` — namely `completed`, `discarded`, `forfeited`. Only terminal rows enter the sync set.
