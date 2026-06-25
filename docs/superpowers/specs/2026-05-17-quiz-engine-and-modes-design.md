# Spec 4 — Quiz engine + Today's Session, Drill, Retake, Inline modes

**Date:** 2026-05-17
**Status:** Draft, pending user review
**Critical-path position:** 4 of 11 (depends on Specs 1 + 2 + 3; informs Specs 5 + 6 + 9 + 11; lightly touches Sanity schema)
**Owner:** Aerol Balayon
**Target soft launch:** 2026-06-28 (Android-only)

---

## 1. Purpose

Replace the placeholder `start_quick_quiz.dart` (random across all topics) with a unified personalized practice engine that powers four quiz surfaces:

1. **Today's Session** — the daily personalized practice surface in the Quiz tab. Default mode is per-topic blocked sessions (one topic at a time, substantial question count); an opt-in setting switches to interleaved mixed-session mode.
2. **Drill a topic** — user-initiated sub-topic-scoped practice.
3. **Retake Mistakes** — user-initiated practice over recent incorrect answers.
4. **Quiz yourself** (inline at lesson end) — optional sub-topic-scoped reinforcement after reading a lesson.

The engine reconciles three signals — **FSRS due cards**, **weakness-targeted cards** (from diagnostic + ongoing mastery state), and **new cards** — into picker outputs tuned per surface. Today's Session is the streak primitive; Drill / Retake / Inline are bonus practice that don't trigger the streak on their own.

This is also the spec where Today's Session model (per-topic blocked vs interleaved) gets locked. That choice is a product-level call about how high-stakes exam prep should *feel*, not just a question of question selection — both modes are supported, but per-topic is the default because the felt productivity of "I studied Numerical Reasoning for 20 minutes" is what matches user expectation for CSE/UPCAT preparation.

---

## 2. Scope

**In scope:**

- A new module `lib/features/quiz/domain/picker/` holding the strategy-pattern `QuestionPicker` interface and its five concrete implementations.
- Shared selector primitives under `lib/features/quiz/domain/selectors/` — `FsrsDueSelector`, `WeaknessSelector`, `NewCardSelector`, `RecencyFilter`, `SubtopicFilter`.
- A new `QuizSession` domain model (active session state, persisted to Drift for crash recovery).
- A new `quiz_sessions_table` and `attempt_log_table` augmentation (origin context: which surface produced the attempt).
- Replacement of `start_quick_quiz.dart` with the engine-driven `start_today_session.dart`, `start_drill.dart`, `start_retake.dart`, `start_inline_lesson_quiz.dart`.
- Today's Session Home hero card + Quiz tab default view.
- Quiz tab secondary CTAs: Retake Mistakes, Drill a topic (sub-topic browser).
- Learn tab end-of-lesson inline "Quiz yourself" CTA.
- FSRS rating heuristic (MCQ interaction → Again/Hard/Good/Easy) — replaces any current ad hoc rating logic and pulls from the existing `lib/core/fsrs/rating_heuristic.dart`.
- A brief post-answer toast surfacing the derived rating + next review interval.
- Settings → Study preferences:
  - Today's Session length (5 / 10 / 20 / all-due-in-topic; default 10).
  - Interleaved practice toggle (off by default, with an inline explainer).
  - New-cards-per-day cap (default 10; auto-adjusted by Spec 6 Study Plan).
- Streak update on Today's Session completion (per-topic mode = ≥1 topic-session; interleaved = mixed session). Device-local-midnight rollover. 2 auto-freezes/month.
- Session pause/resume, explicit Quit-with-confirmation, crash recovery via auto-save-per-answer.
- "Quiz nudge" (study-lessons-first prompt) scope confined to Today's Session.

**Out of scope:**

- The full Mock Exam flow (Spec 5). Mock attempts do not feed the FSRS engine here; that decision is finalized in Spec 5.
- Study Plan generation and exam-date-driven cap auto-adjustment (Spec 6). This spec exposes the new-cards-per-day cap as a configurable setting and a public extension point; Spec 6 supplies the auto-formula.
- Progress dashboard surfaces (Spec 11). This spec produces the attempt rows; Spec 11 visualizes them.
- Monetization / paywall logic (Spec 7 + dedicated Monetization spec). This spec commits to direction-only (depth/frequency gates, no Quiz-tab caps on free, no ads in any tier) and surfaces nothing paywalled inside Today's Session / Drill / Retake / Inline.
- AI / LLM-generated explanations, study plans, or recommendations. Explicitly excluded from v1; all "smart" behavior is algorithmic.
- New-card introduction across exams. Strict single-exam pool — a CSE-prep user only sees CSE questions until they switch tracks in Settings.
- Streak persistence to Firestore — streak is derived locally from `quiz_attempts` (per Spec 3).
- Per-question difficulty calibration / IRT modeling. The picker uses FSRS state and topic mastery only.

---

## 3. Key decisions (with rationale)

### D1 — Today's Session model: per-topic blocked by default; interleaved as opt-in

The Quiz tab default view is a topic queue: each topic with due/weakness/new cards is shown as a row; the user taps a topic to start a focused session (default 10 questions) within that topic alone. A Settings toggle ("Interleaved practice") swaps the queue for a single mixed-session card (default 10 questions across topics, no two consecutive from the same topic).

**Why:** Spaced-repetition orthodoxy (Anki/Duolingo) favors interleaved mixed sessions because they replicate the cognitive-science finding that interleaving improves long-term retention on discrimination tasks. But that research is strongest for *problem-solving* topics (math, physics) and weaker for *memorization* topics (vocabulary, general info), which form the bulk of CSE/UPCAT material. The dominant successful pattern in the *exam prep* category (UWorld, Magoosh, Khan Academy MCAT/SAT) is substantial topic-focused sessions. For high-stakes one-shot exams where users expect to feel like they're "studying [topic]" for a meaningful chunk of time, blocked beats interleaved on perceived productivity and engagement. We don't want to lose the interleaving-curious user, so we expose the toggle with a one-paragraph in-app explainer; default is the model that matches user effort expectations.

**Fallback:** none. The two modes share the same selection primitives — only ordering / chunking differs — so flipping defaults later is a config change.

### D2 — Composition mix per session: 60/30/10 with due, 70/30 without

For each session (whether per-topic-session or interleaved), the picker allocates the requested N questions across three buckets:

| Bucket | Default share when due > 0 | Default share when due == 0 |
|---|---|---|
| FSRS due cards | 60% | — |
| Weakness-targeted cards | 30% | 70% |
| New cards (first-time seen) | 10% | 30% |

Allocations are integer-floored; remainder is absorbed by the largest bucket. If a bucket can't be filled (e.g. user has fewer than 1 new card available within the new-card-per-day cap), the next-largest bucket backfills.

**Why:** Due cards represent the algorithm's confident "you're about to forget this" signal — they earn the largest share when present. Weakness cards keep the diagnostic and ongoing mastery signal active (without them, a user could spend weeks doing only "due" reviews and never patch their actual gaps). New cards are deliberately the smallest bucket to avoid FSRS debt (see D7). When there are no due cards (early-in-prep state), the share rebalances to weakness + new because there's nothing else to surface — this is what makes the engine feel sensible to a brand-new user with an empty FSRS state.

**Fallback:** weights become Settings sliders in v1.x if the defaults under- or over-serve specific user segments. Not exposed in v1 to keep onboarding cognitively cheap.

### D3 — Strategy-pattern `QuestionPicker` with five concrete pickers

The engine is structured as one interface and five implementations:

```
QuestionPicker  (abstract)
  ├── TodayTopicPicker        — per-topic blocked Today's Session
  ├── TodayInterleavedPicker  — mixed-session Today's Session
  ├── DrillPicker             — user-chosen sub-topic, open count
  ├── RetakePicker            — last 30 days of incorrect answers
  └── InlineLessonPicker      — sub-topic-scoped 5-question lesson coda
```

Each picker implements `Future<List<Question>> pick(PickContext ctx)`. The `PickContext` carries the selected exam, current user FSRS state, current user topic mastery, recency window, and any picker-specific args (target sub-topic, target topic, requested length). All five pickers compose the shared selector primitives (`FsrsDueSelector`, `WeaknessSelector`, `NewCardSelector`, `RecencyFilter`, `SubtopicFilter`).

**Why:** Each surface has slightly different rules and constraints — bundling them into one switch-on-mode service collapses the differences and makes each rule set harder to test in isolation. Strategy-pattern keeps the five surfaces self-contained, each becoming a Riverpod provider with a clear blast radius. The shared primitives keep duplication low without resorting to pipeline / functional composition, which is harder to read at 2am. Adding a sixth picker later (e.g. a "weakness-only practice" surface or a future event-specific mode) is plug-in work, not refactor work.

**Fallback:** none. The interface is small enough that swapping to a different architecture later is a re-wire, not a rewrite.

### D4 — FSRS rating: heuristic from MCQ interaction, never an extra tap

The 4-button FSRS rating (Again / Hard / Good / Easy) is derived from the MCQ answer event:

| Outcome | Time | Card maturity | Derived rating |
|---|---|---|---|
| Wrong | any | any | **Again** |
| Correct | > 25s OR > 2× question median | any | **Hard** |
| Correct | normal pace | any | **Good** |
| Correct | < 8s | mature (interval ≥ 21d) | **Easy** |
| Correct | < 8s | not yet mature | **Good** (capped) |

Times are measured from question-render to answer-tap. The medians come from the existing `lib/core/fsrs/` telemetry (will fall back to a fixed 12s threshold per question if median is unavailable for a question type).

**Why:** Asking users for an explicit self-rating after every MCQ would double the taps per question and conflict with the Quiz tab's fast-personalized-practice rhythm — a fight the rhythm wins on UX. The heuristic is well-supported in MCQ-SRS literature and is what the codebase already shapes (`rating_heuristic.dart` exists as scaffolding). The Easy capping (won't trigger on immature cards) protects the FSRS scheduler from over-promoting cards a user got right by lucky guess on first exposure.

**Fallback:** if production data shows the heuristic misfires (e.g. Easy never fires; intervals don't expand for power users), the time thresholds are tunable per-exam constants — no architecture change needed.

### D5 — Brief post-answer toast surfacing rating + next interval

After the user taps an answer and sees correct/incorrect feedback, a small toast appears for ~1.5s in the bottom safe area: "Good · next review in 4d" (or "Again · review tomorrow", etc.). The toast does not block question advancement.

**Why:** The toast reinforces the "this app is learning your level" narrative — central to the personalization value prop. Without it, the FSRS scheduler is invisible to the user, which weakens the differentiation against static-content quiz apps. The toast is intentionally minimal — no detail screen, no opt-in tap — because adding friction at the moment-of-flow would defeat the heuristic-rating design (D4).

**Fallback:** toggle in Settings to disable the toast if user-test feedback shows it's distracting (defer to v1.1).

### D6 — Single-exam pool, FSRS state partitioned per exam

A user has one active exam track at a time (CSE or UPCAT). All four picker surfaces source questions from that exam's pool only. FSRS state is stored per (`userId`, `exam`, `questionId`) — switching exams in Settings doesn't bleed FSRS state from CSE into UPCAT.

**Why:** The "I'm studying for CSE today" intent is laser-focused; cross-exam mixing dilutes both the personalization signal and the felt-sense of progress. Topic-mastery weighting (D2) only makes sense within a single exam's curriculum. Per-exam FSRS partitioning is the only correctness-preserving choice for a user who eventually preps for both (Pro tier — see §10).

**Fallback:** none. A future "blended cross-exam" mode would be additive (a sixth picker), not a redesign.

### D7 — New-card cap: soft default 10/day, configurable, auto-adjusted by Spec 6

> **SUPERSEDED IN PART, 4 August 2026**, by
> `2026-08-04-study-plan-forward-calendar-design.md` Sections 3 and 8.
>
> **The bucket heuristic below is struck.** "10 if more than 60 days out, 20 if 30 to 60, 40 if
> under 30" was a guess standing in for an arithmetic that now exists: the daily count is
> material remaining divided by the working days before a review-only stretch.
>
> **"The user-set override always wins over the auto-default" is reversed.** The setting can
> raise the daily count and can never lower it below what finishing the material in time
> requires. Lowering it breaks that promise silently, and the student would not find out until
> the exam.
>
> **The Settings selector below is also struck**, and replaced by a single Light, Standard or
> Intense preset. Two controls for one number is how they end up disagreeing.
>
> **Everything else in D7 stands**, including the reason for having a cap at all, the
> across-all-surfaces counting rule, and the fallback: the engine must never hard depend on the
> study plan.

The picker emits at most N new (first-time-seen) cards per local day across all surfaces combined. Default N = 10. Settings → Study preferences exposes a 5/10/20/30/50 selector with an inline explainer of the FSRS-debt tradeoff. Spec 6 (Study Plan) replaces the static default with an exam-date-aware formula (heuristic example: cap = 10 if >60d to exam, 20 if 30–60d, 40 if <30d); the user-set override always wins over the auto-default.

**Why:** Without a cap, a motivated early-week user can introduce 30–50 new cards in a single session, all of which compound into review load 1–14 days later. This is the single most common burnout pattern in serious SRS apps (Anki, Duolingo both impose caps for exactly this reason). The cap protects sustainable habit; the configurability protects the PH crammer with <4 weeks until exam day. Auto-adjustment via Spec 6 removes decision burden for the default user. Counting "across all surfaces combined" prevents the user from gaming the cap by alternating Today's Session with Drill — a new card is a new card regardless of where it surfaces.

**Fallback:** if Spec 6 ships late, the static default (10/day) is sufficient on its own — the engine never hard-depends on the Spec 6 formula.

### D8 — Streak primitive: Today's Session only

The daily-streak event fires exactly once per device-local day, on:

- **Per-topic mode (default):** completion of at least one topic-session (10 questions answered within a single topic-session, including via Resume).
- **Interleaved mode (toggle on):** completion of the day's mixed session.

Drill, Retake, and Inline quiz answers feed FSRS state but do not trigger the streak on their own. They earn streak credit only as side effects (e.g. if the user happens to complete Today's Session and a Drill in the same day, both still register).

**Why:** The streak's job is to reinforce showing up to the personalized daily practice — the value prop of the app. If Drill alone (a topic-of-your-choice surface) earned the streak, a user could grind only their strongest topic for 100 days and the streak would lose its signal. Centralizing the streak on Today's Session protects its meaning. The bar is intentionally lenient (≥1 topic-session, not "all due topics cleared") because life happens — punishing a user with 4 backlogged topics for finishing only 1 turns the streak into an anxiety driver rather than a habit driver.

**Fallback:** if user-test feedback shows the bar is too low (users feel the streak is "free"), raising to "≥2 topic-sessions/day" is a config change. Lowering further (e.g. "any 5 answers") is also possible; rules live in `streak_evaluator.dart`.

### D9 — Session UX: auto-save per answer, Quit-with-confirm, minimal celebration

Each answer is committed to the local DB (`quiz_attempts`, `fsrs_cards`, plus the active `quiz_sessions` row) immediately on submit, before the next question renders. This makes background / force-quit / crash mid-session non-events: the user resumes from question N+1 on next launch via the Quiz tab's "Resume Today's Session (X of Y)" CTA (which preempts the topic queue or mixed-session card for the day). A small × in the session header opens a "Quit session? Your progress is saved — you can resume anytime today." confirmation. Session completion shows a minimal celebration (confetti, per-session stats, streak update if applicable, "Done for today" copy) — no separate summary screen.

**Why:** Auto-save-per-answer is the only mobile-correct pattern; users expect backgrounding to be safe. Tying resume CTA to the Quiz tab (not Home) means the user lands at the surface where the action happens. The minimal celebration respects the "fast personalized practice" rhythm — a multi-screen summary at the moment of dopamine drains the satisfaction. Per-topic analytics (mistakes review, breakdown) live in Progress (Spec 11), not in the session ending.

**Fallback:** none. The pattern is forgiving — adding a richer summary screen later as a v1.1 polish is additive.

### D10 — Drill at sub-topic granularity, requires Sanity `subtopic` field

Drill surfaces let the user browse domain (e.g. Vocabulary) → sub-topic (e.g. Synonyms) and start a session within that sub-topic. The inline lesson quiz is also scoped to the lesson's sub-topic. This adds a requirement: Sanity question and lesson schemas need a `subtopic` field (added in §10 Dependencies → Spec 2 schema adjustment).

**Why:** Domain-level drilling is too coarse for the use case ("I want to practice synonyms specifically, not all of vocabulary"). Sub-topic granularity matches user mental models of focused practice and, downstream, unlocks the Pro Progress dashboard's sub-topic mastery heatmap (Spec 11). The cost is a Sanity schema field + tagging discipline during content authoring; this lands in Sanity's Week 1 authoring task per the roadmap.

**Fallback:** if sub-topic tagging is incomplete at launch (some questions untagged), the Drill UI shows tagged sub-topics + a "General [Domain]" bucket for untagged questions. Partial coverage degrades gracefully.

---

## 4. Architecture

### 4.1 Module layout

```
lib/features/quiz/
├── domain/
│   ├── picker/
│   │   ├── question_picker.dart                (abstract)
│   │   ├── pick_context.dart                   (input bundle)
│   │   ├── today_topic_picker.dart
│   │   ├── today_interleaved_picker.dart
│   │   ├── drill_picker.dart
│   │   ├── retake_picker.dart
│   │   └── inline_lesson_picker.dart
│   ├── selectors/
│   │   ├── fsrs_due_selector.dart
│   │   ├── weakness_selector.dart
│   │   ├── new_card_selector.dart
│   │   ├── recency_filter.dart
│   │   └── subtopic_filter.dart
│   ├── use_cases/
│   │   ├── start_today_session.dart
│   │   ├── start_drill.dart
│   │   ├── start_retake.dart
│   │   ├── start_inline_lesson_quiz.dart
│   │   ├── submit_answer.dart                  (also writes FSRS state + attempts)
│   │   ├── resume_session.dart
│   │   └── quit_session.dart
│   ├── models/
│   │   ├── quiz_session.dart
│   │   ├── quiz_mode.dart                      (enum)
│   │   ├── session_origin.dart                 (enum: today | drill | retake | inline)
│   │   └── derived_rating.dart                 (Again | Hard | Good | Easy + interval)
│   └── streak/
│       └── streak_evaluator.dart               (today's-session completion check)
├── data/
│   ├── repos/
│   │   ├── quiz_session_repository.dart        (Drift-backed active session)
│   │   └── attempt_repository.dart             (writes quiz_attempts; reads recent for Retake)
│   └── tables/
│       ├── quiz_sessions_table.dart            (NEW)
│       └── quiz_attempts_table.dart            (EXISTING — adds `origin` enum column)
└── presentation/
    ├── quiz_tab_home.dart                      (replaced — topic queue / mixed card / resume CTA)
    ├── session_screen.dart                     (replaces existing session widget; supports all 5 pickers)
    ├── post_answer_toast.dart                  (new)
    ├── drill_subtopic_browser.dart             (new)
    ├── retake_mistakes_card.dart               (new)
    └── done_for_today_celebration.dart         (new)
```

The home dashboard hero card (Today's Session summary) and Learn tab end-of-lesson CTA live in their respective tabs and call into `start_today_session.dart` / `start_inline_lesson_quiz.dart`. They are not duplicated here.

### 4.2 Riverpod surface

```dart
// One provider per picker (each pure, no side-effects):
final todayTopicPickerProvider     = Provider<QuestionPicker>(...);
final todayInterleavedPickerProvider = Provider<QuestionPicker>(...);
final drillPickerProvider          = Provider<QuestionPicker>(...);
final retakePickerProvider         = Provider<QuestionPicker>(...);
final inlineLessonPickerProvider   = Provider<QuestionPicker>(...);

// Active session state (StreamProvider over Drift quiz_sessions watch):
final activeSessionProvider        = StreamProvider<QuizSession?>(...);

// Today's topic queue (derived: which topics have due/weakness/new cards today):
final todayTopicQueueProvider      = StreamProvider<List<TopicQueueRow>>(...);

// New-cards-introduced-today counter (for cap enforcement):
final newCardsTodayProvider        = StreamProvider<int>(...);

// Streak state (derived from quiz_attempts):
final streakStateProvider          = StreamProvider<StreakState>(...);

// Settings:
final sessionLengthProvider        = StateProvider<int>(...);             // 5/10/20/-1 (all-due)
final interleavedModeProvider      = StateProvider<bool>(...);            // off by default
final newCardCapProvider           = StateProvider<int>(...);             // default 10
```

Pickers are pure (input: `PickContext`, output: `List<Question>`) so they're unit-testable without any database. Use-cases (`start_today_session.dart` etc.) own the side-effects: writing the `quiz_sessions` row, advancing through questions, writing attempts and FSRS state on each submit.

### 4.3 Picker control flow

```
User taps a topic on Quiz tab
  → start_today_session(topic, mode=perTopic)
    → buildPickContext(exam, topic, length, fsrsState, masteryState, recencyWindow, newCardCap)
    → todayTopicPicker.pick(ctx)
      → FsrsDueSelector.dueWithinTopic(...)                  // 60% × length
      → WeaknessSelector.weakestSubtopicsWithinTopic(...)    // 30% × length
      → NewCardSelector.unseenWithinTopic(capRemaining, ...) // 10% × length
      → backfill if any bucket under-fills
      → shuffle (within-session random order — user never sees "due" before "new")
    → persist quiz_sessions row (origin: today, topic, questionIds, currentIndex=0, startedAt)
  → navigate to session_screen

For each answer:
  → submit_answer(questionId, optionId, durationMs)
    → derive rating via RatingHeuristic (correct/wrong + duration + card maturity)
    → write quiz_attempts row (with origin)
    → update fsrs_cards row (interval, due, lapses…)
    → if new card: increment newCardsTodayProvider
    → write quiz_sessions.currentIndex
    → render post_answer_toast (rating + nextDue)
    → advance to next question
  → on last question complete:
    → streak_evaluator.evaluate() — if origin=today and session.questionsAnswered ≥ length, fire streak event
    → mark quiz_sessions.completedAt
    → navigate to done_for_today_celebration
```

`TodayInterleavedPicker` differs only in: (a) drawing from all topics (not one), (b) applying `RecencyFilter.noConsecutiveSameTopic()` after the merge.

`DrillPicker` differs in: (a) filtering to a single sub-topic via `SubtopicFilter`, (b) skipping FSRS-weighting (random within sub-topic, deduped against last 7 days of attempts on that sub-topic), (c) emitting attempts with `origin: drill` so streak evaluator ignores them as primary triggers.

`RetakePicker` differs in: (a) seeding from `attempt_repository.recentIncorrects(window: 30d, limit: 50)`, (b) using actual question IDs (not the algorithm), (c) `origin: retake`.

`InlineLessonPicker` differs in: (a) hard-coded 5 questions, (b) sub-topic filter from lesson metadata, (c) `origin: inline`.

---

## 5. Data model

### 5.1 New Drift table: `quiz_sessions_table`

```dart
class QuizSessions extends Table {
  TextColumn get id => text()();                            // UUID v4 client-generated
  TextColumn get userId => text()();                        // current user UID (anon or named)
  TextColumn get examId => text()();                        // selected exam at session start
  TextColumn get origin => text()();                        // SessionOrigin enum: today_topic | today_interleaved | drill | retake | inline
  TextColumn get topicId => text().nullable()();            // for today_topic and drill (domain-level)
  TextColumn get subtopicId => text().nullable()();         // for drill and inline
  TextColumn get lessonId => text().nullable()();           // for inline
  TextColumn get questionIdsJson => text()();               // ordered JSON array of question IDs
  IntColumn get currentIndex => integer().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get lastAnsweredAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get quitAt => dateTime().nullable()();     // distinct from completedAt
  @override Set<Column> get primaryKey => {id};
}
```

**Sync status (per Spec 3 catalog):** `quiz_sessions` is **local-only**, not synced. Rationale: session state is per-device-per-day ephemera; resuming an interrupted session on a different device is an edge case not worth the sync cost. The *attempts* it produces (in `quiz_attempts`) sync per Spec 3 and that's where the durable record lives.

### 5.2 `quiz_attempts_table` schema update

Add a new column `origin` (text, NOT NULL, default `'today_topic'`) recording which surface produced the attempt. Backfill on migration: all existing rows get `'today_topic'` (closest match to placeholder Quick Quiz semantics). Used by Retake (filter incorrects), Streak evaluator (filter to today-origin only), and Progress (Spec 11 analytics per surface).

**Sync status:** synced per Spec 3 (already in the catalog as `quiz_attempts`). New `origin` column is included in the per-row JSON.

### 5.3 New Drift table: `daily_new_card_intro_table`

```dart
class DailyNewCardIntro extends Table {
  TextColumn get userId => text()();
  TextColumn get examId => text()();
  DateTimeColumn get day => dateTime()();                   // local-midnight bucket
  IntColumn get newCardsIntroduced => integer().withDefault(const Constant(0))();
  @override Set<Column> get primaryKey => {userId, examId, day};
}
```

Tracks per-day new-card introductions for cap enforcement (D7). Reset at local midnight via a query, not deletion (preserved for Progress analytics later).

**Sync status:** **local-only** for v1. New-card-cap is a UX guardrail, not a correctness primitive; cross-device cap consistency is nice-to-have, not load-bearing. If a user introduces 10 new cards on Device A and switches to Device B mid-day, Device B may permit another 10 — acceptable for v1 given how rarely this happens in practice. Promote to synced in v1.1 if user data shows it matters.

### 5.4 Sanity schema additions (Spec 2 coordination)

The Sanity `question` document type needs a new field:

```javascript
{
  name: 'subtopic',
  title: 'Sub-topic',
  type: 'reference',
  to: [{type: 'subtopic'}],     // new subtopic document type with name + parent topic
  validation: Rule => Rule.required(),
}
```

And the Sanity `lesson` document type needs the same `subtopic` reference (for the inline quiz's sub-topic scoping in D10).

**Spec 2 (Sanity content fetcher) must be updated to parse and persist this field into Drift content tables.** This is the only schema-level cross-spec change in Spec 4. The change is additive (no migration of existing questions; the field starts NULL and is populated as questions are authored / re-tagged).

### 5.5 Updated `app_preferences` keys (Spec 3 coordination)

Add three keys to `account_prefs` (synced) per Spec 3 D8:

| Key | Type | Default | Notes |
|---|---|---|---|
| `quiz.sessionLength` | int | 10 | -1 = all-due-in-topic |
| `quiz.interleavedMode` | bool | false | Toggle for D1 |
| `quiz.newCardCap` | int | 10 | User override; null = use Spec 6 auto-formula |

These propagate cross-device per Spec 3's LWW model. A user changing their session length on the phone sees it apply on the tablet within seconds.

---

## 6. Algorithms

### 6.1 `FsrsDueSelector.dueWithin(topic?, limit)`

Reads from existing `review_state_local_table` and `lib/core/fsrs/`. Returns cards where:
- `nextDueAt <= now`
- (if topic provided) `question.topic == topic`
- Sorted by `nextDueAt ASC` (oldest-overdue first), then `lapses DESC` (cards with more failures get priority within same due group).

### 6.2 `WeaknessSelector.weakestSubtopicsWithin(topic?, examId, limit)`

Reads from `topic_mastery` (already exists per assessment) and `quiz_attempts`. Computes a weakness score per sub-topic = `1 - rollingAccuracy(last 30d, lower-bounded by N=5 attempts)`. Selects cards from sub-topics with weakness ≥ 0.4 (low-mastery threshold per existing `topic_mastery.dart`). Excludes cards already in the `FsrsDueSelector` output for this session (no duplicates). Sorted by weakness DESC, then random tiebreak.

### 6.3 `NewCardSelector.unseen(topic?, examId, capRemaining, limit)`

Reads from `question_table` LEFT JOIN `review_state_local_table` WHERE FSRS state is NULL (never seen). Constrained by `min(limit, capRemaining)` where `capRemaining = newCardCap - newCardsIntroducedToday`. Sorted by Sanity-authored `question.order` (lets content authors stage introduction sequence intentionally), with random tiebreak inside same order.

### 6.4 `RecencyFilter.noConsecutiveSameTopic(questions)`

For Interleaved mode (D1) only. Greedy reorder: given a list of questions tagged with their topics, swap adjacent same-topic pairs as long as a non-same-topic neighbor exists further in the list. Best-effort — if every question is the same topic (degenerate case), filter is a no-op.

### 6.5 `RatingHeuristic.derive(correct, durationMs, cardMaturity)`

Implements D4's table. Lives in `lib/core/fsrs/rating_heuristic.dart` (already scaffolded). Returns `(rating, nextIntervalDays)` for the post-answer toast.

### 6.6 `StreakEvaluator.evaluate(session)`

Called on `submit_answer` when the session reaches the last question. Fires the streak event when:

```dart
session.origin in {today_topic, today_interleaved}
  AND session.completedAt != null
  AND no streak event already fired for this device-local day
```

Implements the D8 lenient bar. Maintains streak counter, last-active day, and auto-applies freezes (2/month, from the existing `streakRepository.freezesRemaining` field). Freeze application is invisible — if a user misses Wednesday but had a freeze available, the Thursday session shows streak=N+1, not streak=N (skipped) or streak=1 (reset). A small "🛡️ Streak saved (1 freeze used)" toast surfaces on the Thursday return.

---

## 7. Quiz surfaces (UX detail)

### 7.1 Quiz tab

**Default state (per-topic mode, no active session):**

```
Today's Practice
─────────────────────────────────
▸ 📘 Vocabulary           18 cards
    12 due · 4 weakness · 2 new   ~12 min

▸ 🔢 Numerical Reasoning  22 cards
    15 due · 5 weakness · 2 new   ~15 min

▸ 🌐 General Information   8 cards
    5 due · 3 weakness            ~7 min

▸ 📜 Clerical Operations   0 cards
    Caught up ✓

──────────────────
Recommended: start with Numerical Reasoning (largest backlog)
──────────────────

Other practice
  ↻ Retake Mistakes  (28 questions, last 30 days)
  ✎ Drill a topic    (choose a sub-topic)
```

Tapping a topic row → `start_today_session(topic, mode: perTopic)` and into `session_screen`. Tapping Recommended → same, with the recommended topic preselected.

**Default state (interleaved mode, no active session):**

```
Today's Mixed Session
─────────────────────────────────
10 cards · 6 due · 3 weakness · 1 new
~10 min

[ Start session ]

──────────────────
Other practice
  ↻ Retake Mistakes
  ✎ Drill a topic
```

**With active session (auto-save preempts):**

```
Resume Today's Session
   Vocabulary, 6 of 10 complete
[ Resume ]   [ Restart ]
```

`Restart` is destructive (discards the active session) and shows a confirmation. `Resume` jumps to question 7.

### 7.2 Drill a topic

Sub-topic browser is a single screen — Domain accordion → Sub-topic rows with question counts. Tapping a sub-topic → `start_drill(subtopic, length: 10)`. Length picker (5/10/20/all) lives at the top of the browser.

### 7.3 Retake Mistakes

Single CTA on the Quiz tab. Tapping → `start_retake(window: 30d, limit: 50)`. If pool is empty, shows "No recent mistakes — keep at it! 🎉".

### 7.4 Inline lesson quiz

Appears as a card at the bottom of the lesson reader, after the last Portable Text block:

```
─────────────────────────────────
Quiz yourself on this lesson
5 questions · ~5 min
[ Start ]
─────────────────────────────────
```

Tapping → `start_inline_lesson_quiz(lesson, length: 5)`. The lesson's "read" status is set when the user scrolls past this card (independent of whether they tap Start).

### 7.5 Session screen (shared across all five pickers)

```
[ ← Quit ]   3 of 10                 [Vocabulary]
─────────────────────────────────
[Question stem rendered as Portable Text]

  ◯ Option A
  ◯ Option B
  ◯ Option C
  ◯ Option D

[ Submit ]
```

After submit:
- Inline correct/incorrect feedback (option highlighted green/red, brief explanation if free / full worked solution if Pro per §10 monetization direction).
- Post-answer toast: "Good · next review in 4d" bottom-aligned, ~1.5s.
- "Next" button appears at the bottom.

On completion → done_for_today_celebration (or a minimal "Drill complete · 8/10 correct · streak unchanged" sheet for Drill/Retake/Inline).

### 7.6 Quiz nudge scope

The existing "study lessons first" nudge (`quiz_nudge`) fires only when starting Today's Session AND zero lessons read for the selected exam's subjects. Drill, Retake, and Inline quiz never show this nudge — they're user-initiated reinforcement surfaces and the nudge would be paternalistic.

### 7.7 Empty / zero state handling

| Scenario | Behavior |
|---|---|
| Fresh user, no diagnostic done yet | Quiz tab shows "Take the diagnostic first" routing to assessment flow |
| Diagnostic done, no FSRS state yet (no quizzes taken) | Today's Session composition becomes 0/70/30 (D2 second column) — all weakness + new |
| All topics caught up (zero due across all) | Each topic row shows "Caught up ✓" instead of being hidden — user gets the satisfaction of seeing the green checks |
| No lessons read yet but trying to start Today's Session | Quiz nudge fires (existing behavior); user can override |
| New-card cap reached for the day | New-cards bucket drops to 0, weakness backfills; topic row counts show "0 new" not "2 new" |
| All-due-in-topic chosen but pool is 0 | Falls through to weakness + new composition |

---

## 8. Failure handling

| Failure | Behavior |
|---|---|
| `start_*` called but content not yet fetched (cold start, first launch) | Block on Spec 2's content-cache-ready signal; show shimmer for ≤5s, then a "Couldn't load questions" retry screen |
| `submit_answer` write fails mid-session (Drift error) | Retry once silently; on second failure, show "Couldn't save your answer — try again" toast; do not advance question |
| Picker produces fewer questions than requested length (insufficient pool) | Session starts with the smaller count; session_screen header shows "3 of 3" not "3 of 10". No error — degraded gracefully |
| Session crashes mid-question | Resume CTA reopens at the question the user was on; the in-flight answer (if not yet submitted) is lost — user re-answers |
| User changes session length setting mid-session | New setting applies on next session; current session continues at its original length |
| User changes interleaved-mode setting mid-session | New setting applies on next session; current session continues in its original mode |
| FSRS state divergent from question metadata (e.g. question deleted from Sanity but FSRS row exists) | `FsrsDueSelector` filters out orphaned FSRS rows. Periodic cleanup task (cron-style at app boot) deletes FSRS rows whose `questionId` no longer exists in `content.db` |
| User answers, then sync from another device echoes back a newer attempt for same question | Per Spec 3 LWW: the newer attempt wins. Practically rare (would require simultaneous quiz on two devices). Engine does not attempt to "merge" — last write wins |

---

## 9. Testing strategy

**Unit (picker logic, pure functions):**

- Each picker tested with mocked `PickContext`. Verifies: composition mix matches D2 within rounding; new-card cap respected; recency filter places no two same-topic adjacent; sub-topic filter respected for Drill/Inline; retake pool sources only from `quiz_attempts` last 30 days with `isCorrect=false`.
- `RatingHeuristic` truth table — each row of D4's table, plus edge cases (exactly-25s, exactly-8s, immature card boundary).
- `RecencyFilter` — degenerate cases (all same topic, all unique topics, two-topic perfect alternation).
- `StreakEvaluator` — freezes consumption, midnight rollover, multiple sessions in one day fires streak once.

**Widget (session_screen + presentation):**

- Submit answer → toast appears → next button appears → tap → question advances.
- Quit confirmation flow.
- Resume CTA appears after backgrounding mid-session.
- Done-for-today celebration on last question.
- Empty / zero state rendering for all rows of §7.7.

**Integration (Drift + use-cases):**

- Full session round-trip: start_today_session → 10x submit_answer → completion → quiz_attempts has 10 rows with correct `origin`; fsrs_cards updated; streak event fired exactly once.
- Crash recovery: simulate process kill mid-session; relaunch; resume_session restores at the right index; completion still fires streak.
- New-card cap: introduce 10 new cards via Today's Session; start Drill expecting to use new cards; verify Drill returns 0 new cards (cap hit) and backfills.
- Settings change propagation: set sessionLength=20; next start_today_session produces 20-card session.
- Migration: existing `quiz_attempts` rows get `origin='today_topic'` on schema upgrade.

**No new mock infrastructure beyond what `lib/core/fsrs/` already uses. Drift tests use the in-memory database pattern already established in the codebase.**

**No e2e / device tests in this spec.** Quiz UX e2e coverage lands in Week 5 closed-beta QA on Galaxy A15 per the roadmap.

---

## 10. Dependencies on other specs

| Spec | What this spec depends on | What this spec provides back |
|---|---|---|
| Spec 1 (Auth) | `currentUserProvider` to scope quiz_sessions / attempts to the right UID | Quiz tab content is gated by `currentUser != null` (anon counts) |
| Spec 2 (Sanity) | Question + lesson content, `topic` and `subtopic` reference fields, content cache | A schema addition: `subtopic` reference on `question` and `lesson` doc types (§5.4) |
| Spec 3 (Sync) | LWW sync for `quiz_attempts`, `review_state`, `account_prefs`. New `origin` column included in attempt-row JSON | The new `quiz.sessionLength`, `quiz.interleavedMode`, `quiz.newCardCap` preference keys land in `account_prefs` per Spec 3 D8 |
| Spec 5 (Mock) | None direct. Mock exam attempts do NOT flow through this engine; Spec 5 may decide to share `RatingHeuristic` for post-mock review surfacing | Engine never produces mock-exam questions; clean separation |
| Spec 6 (Study Plan) | Exam date and the auto-formula for new-card cap (D7) | A public `quizPickerCalibrationProvider` Spec 6 can read to compose its daily action plan (weakness signals, due counts) |
| Spec 7 (Paywall / RC) | `entitlementProvider` to swap short-answer-key for full-worked-solution rendering in session_screen | Nothing — engine is identical free vs Pro; only the *explanation* rendering varies |
| Spec 8 (Settings) | Settings UI hosts the session length picker, interleaved toggle, new-card cap selector | Setting controllers per §5.5 |
| Spec 9 (Notifications) | Daily-review notification deep-links to `/quiz/today` (Quiz tab default route) | Engine ensures the route surface is meaningful when the deep-link fires |
| Spec 11 (Progress) | Reads `quiz_attempts` with `origin` column for per-surface analytics (e.g. "Drill accuracy on Synonyms over time") | New `origin` column + sub-topic data on attempts → enables Pro sub-topic mastery heatmap |
| Monetization spec (separate) | Pricing tiers, paywall UX | Direction lock: no caps on free Quiz tab features; no ads in any tier; depth/frequency gates apply elsewhere (mocks, explanations, dual-track, advanced progress) |

---

## 11. Monetization direction (carry-forward to dedicated spec)

This spec **does not finalize pricing or paywall UX** — that lives in Spec 7 (RevenueCat + paywall) and a separate Monetization spec. It does, however, lock the following directional commitments that Spec 4 implementation must honor:

| Surface | Free | Pro |
|---|---|---|
| Today's Session + Drill + Retake + Inline quiz | **Unlimited, no caps** | Same |
| Lessons (Learn tab) | Unlimited | + bookmarks, notes |
| Question explanations | Short answer-key | Full worked solutions + "why the others are wrong" |
| Mock exam (Spec 5) | 1 per 14 days per track | Unlimited |
| Exam tracks | 1 (CSE *or* UPCAT) | Both |
| Progress (Spec 11) | Topic-level + streak | + sub-topic heatmap, mistake patterns, predicted score |
| Study plan (Spec 6) | Generic Today's Session composition | + Exam-date-aware daily targets, adaptive reshuffle, multi-week view |
| Ads | None | None |

**Rationale (carry-forward):** the PH market's price sensitivity demands a generous free tier; gating the *daily habit loop* (Quiz tab) hurts conversion more than it helps. The paywall lives at moments of *deeper investment* (more mocks, full explanations, dual-track, advanced analytics, AI-free algorithmic study plan), not at moments of *daily showing up*.

**Pricing tiers (still to be finalized in Spec 7 / Monetization spec):** ₱99 / ₱499 / ₱1499 — likely Monthly / 6-month / Lifetime, but commitment shape (one-time vs subscription) deferred.

---

## 12. Deliverables

**Code:**
- `lib/features/quiz/domain/picker/` — five concrete pickers + `QuestionPicker` abstract + `PickContext`.
- `lib/features/quiz/domain/selectors/` — five selectors + filters.
- `lib/features/quiz/domain/use_cases/` — start_today_session, start_drill, start_retake, start_inline_lesson_quiz, submit_answer, resume_session, quit_session.
- `lib/features/quiz/domain/streak/streak_evaluator.dart`.
- `lib/features/quiz/data/tables/quiz_sessions_table.dart` + `daily_new_card_intro_table.dart`.
- `lib/features/quiz/data/repos/quiz_session_repository.dart` + `attempt_repository.dart`.
- `lib/features/quiz/presentation/` — quiz_tab_home, session_screen, post_answer_toast, drill_subtopic_browser, retake_mistakes_card, done_for_today_celebration.
- Settings page additions for session length, interleaved toggle, new-card cap.
- Drift migration: `quiz_attempts` adds `origin` column with backfill; new tables created.

**Removed code:**
- `lib/features/quiz/domain/use_cases/start_quick_quiz.dart` (replaced by `start_today_session.dart`).
- Any router shim for `?topicId=` placeholder behavior.

**Sanity schema changes (coordinated with Spec 2):**
- New `subtopic` document type with name + parent topic reference.
- `question` and `lesson` doc types get a `subtopic` reference field.
- Spec 2's fetcher / Drift cache updated to parse and persist.

**Tests:**
- Unit tests for all five pickers + selectors + RatingHeuristic + StreakEvaluator (target: 95% coverage on `domain/`).
- Widget tests for session_screen flow + Quit confirmation + Resume CTA.
- Integration tests for Drift round-trip + crash recovery + new-card cap.

**Docs:**
- `docs/architecture/quiz-engine.md` — picker overview, when each picker fires, how composition mix flows.
- Inline DartDoc on each picker class explaining its surface and rules.

---

## 13. Risks

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| Sanity content doesn't have sub-topic tagging by Week 2 brainstorm/build window | Medium | Drill loses granularity; falls back to "General Vocabulary" buckets | D10 fallback — degraded gracefully; content authoring catches up in Week 3-4 |
| Rating heuristic time thresholds are off for PH-network-latency-affected interactions (user takes 30s because of bad network, not because question was hard) | Low-Medium | Cards over-promoted to Hard, FSRS scheduler skewed | Thresholds are tunable post-launch; flag for review on Week 5 closed-beta data |
| Per-topic mode underperforms vs interleaved on long-term retention, but we won't know until 30+ days of user data | Medium | Some users get slightly worse exam-day outcomes | Interleaved toggle exists for power users; in v1.1 we can A/B if needed |
| FSRS debt for users who set new-card cap to 50 and don't keep up | Medium | Burnout, streak loss, uninstall | D7 + Spec 6 auto-formula; Settings explainer makes the tradeoff visible |
| New-card cap counter divergence cross-device (D7's local-only choice) | Low | User introduces 20 new cards in a day instead of 10 if they switch devices | Acceptable for v1; promote to synced in v1.1 if data shows it matters |
| Strategy-pattern five pickers becomes unwieldy at sixth/seventh future mode | Low | Future-spec refactor work | The selector primitives keep duplication low; refactor cost in v2 if it materializes |
| Quiz tab Resume CTA conflicts with deep-link from notification (Spec 9) | Low | Confusing UX — notification opens to Resume not the topic queue | Deep-link unconditionally lands on Quiz tab; if active session exists, Resume preempts (correct behavior) |
| Today's Session per-topic-mode "Recommended: start with X" line gets ignored / users always pick the easy topic | Medium | Personalization signal weaker; mastery growth lopsided | Not a blocker for v1; Spec 6 Study Plan can promote stronger nudges later |

---

## 14. Open items (for resolution during implementation)

- Exact wording for the in-app interleaving explainer (D1) — pending UX copy pass.
- Exact wording for the new-card cap selector explainer (D7) — same.
- Question median-time telemetry storage — does the existing `lib/core/fsrs/` carry medians, or do we add a column to question_table? Decide during implementation. The fallback (fixed 12s) is sufficient if telemetry isn't ready.
- "Restart" destructive confirmation copy on the active-session-resume card (§7.1).
- Confetti library / particle config for the done-for-today celebration — pick during implementation, no design impact.
