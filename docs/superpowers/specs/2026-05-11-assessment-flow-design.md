# Assessment Flow — Design Spec

**Date:** 2026-05-11
**Status:** Implemented
**Sub-project:** 1 of 2 (Assessment Flow; Home Tab / Study Plan is sub-project 2)

---

## Goal

Give new users a one-time placement test that establishes their per-topic knowledge baseline for an exam. Use the results to surface a prioritized study plan immediately after completion, and seed the FSRS spaced-repetition system from day one.

---

## Scope

- One-time assessment per exam (no free-tier retakes)
- ~30 questions drawn from all topics in the exam, interleaved
- Per-topic mastery scores stored locally in Drift
- Results screen: topic breakdown bars + "Study →" / "Quiz →" CTAs per weak topic
- Progressive nudge on the quiz results screen after the first, third, and fifth quiz attempts
- FSRS `ReviewStateLocal` seeded for every assessed question on completion
- No server sync in this iteration (`syncState` column reserved)

**Out of scope (sub-project 2):** Home tab study plan surface, ongoing dynamic performance profile (Pro), reassessment.

---

## Free vs. Pro distinction

| | Free | Pro |
|---|---|---|
| Assessment | One-time placement test (this spec) | — |
| Performance profile | Static snapshot from assessment | Dynamic, auto-updating from all activity |
| "What to study next" | Top 2–3 weakest topics from assessment | Continuously recalculated, trend-aware |

The free assessment is a test the user takes once. The Pro profile is intelligence that runs in the background automatically.

---

## Data Layer

### New table: `AssessmentResultsLocal` (schemaVersion → 3)

| Column | Type | Notes |
|---|---|---|
| `examId` | text, PK | One result per exam |
| `completedAt` | datetime | When the assessment was finished |
| `topicScoresJson` | text | JSON array of per-topic results |
| `syncState` | text | Default `'pending'`; reserved for future sync |

**`topicScoresJson` shape:**
```json
[
  { "topicId": "t1", "correct": 2, "total": 3 },
  { "topicId": "t2", "correct": 0, "total": 3 }
]
```

**Mastery level** is derived at read time, never stored:
- 0–40% → `weak`
- 41–70% → `moderate`
- 71–100% → `strong`

### Migration

Bump `schemaVersion` to 3. In `onUpgrade`, create the new table when upgrading from version 2:

```dart
if (from < 3) {
  await m.createTable(assessmentResultsLocal);
}
```

---

## Domain Models

```dart
// lib/features/assessment/domain/models/assessment_session.dart
class AssessmentSession {
  final String examId;
  final List<AssessmentQuestion> questions; // interleaved across topics
  final Map<String, String?> answers;       // questionId → chosenChoiceId (null = unanswered)
}

// lib/features/assessment/domain/models/assessment_question.dart
class AssessmentQuestion {
  final Question question;
  final String topicId;
}

// lib/features/assessment/domain/models/assessment_result.dart
class AssessmentResult {
  final String examId;
  final DateTime completedAt;
  final List<TopicMastery> topicMasteries; // sorted weakest-first
}

// lib/features/assessment/domain/models/topic_mastery.dart
class TopicMastery {
  final Topic topic;
  final int correct;
  final int total;
  MasteryLevel get level => /* derived */;
}

enum MasteryLevel { weak, moderate, strong }
```

---

## Repository

### `AssessmentRepository`

File: `lib/core/storage/data/repos/assessment_repository.dart`

| Method | Signature | Behavior |
|---|---|---|
| `saveResult` | `Future<void> saveResult(String examId, DateTime completedAt, List<TopicScore> scores)` | Upserts a single row keyed by `examId` |
| `resultForExam` | `Future<AssessmentResultRow?> resultForExam(String examId)` | Returns the stored row, or null if not yet taken |
| `hasCompletedForExam` | `Future<bool> hasCompletedForExam(String examId)` | True if a result row exists for this exam |

Provider added to `storage.dart`:
```dart
final assessmentRepositoryProvider = Provider<AssessmentRepository>(...);
```

`assessmentResultProvider` lives in
`lib/features/assessment/presentation/assessment_results_page.dart` so
`core/storage` does not import feature-layer assessment models.

---

## Services

### `AssessmentQuestionSelector`

File: `lib/features/assessment/domain/services/assessment_question_selector.dart`

**Algorithm:**
1. Load all topics for the exam via `ContentRepository.topicsByExam` (new method — fetches all subjects for the exam, then all topics per subject, returns flat `List<Topic>`)
2. For each topic, compute `questionsPerTopic = max(1, min(3, floor(35 / topicCount)))`
3. For each topic, load candidate questions; prefer `ReviewState.stage == newCard` (never seen), fall back to lowest `stability`
4. Interleave the selected questions across topics (round-robin by topic index, shuffled within each slot)
5. Return a flat `List<AssessmentQuestion>`

---

## Use Cases

### `StartAssessment`

File: `lib/features/assessment/domain/use_cases/start_assessment.dart`

- Takes `ExamId`
- Calls `AssessmentQuestionSelector` to build the question list
- Returns an `AssessmentSession` (in-memory only, never persisted)

### `CompleteAssessment`

File: `lib/features/assessment/domain/use_cases/complete_assessment.dart`

- Takes a completed `AssessmentSession`
- Computes per-topic `correct` / `total` counts from `session.answers`
- Calls `AssessmentRepository.saveResult`
- For each answered question: updates `ReviewStateLocal` via FSRS scheduler
  - Correct answer → `Rating.good`
  - Incorrect answer → `Rating.again`
- Returns `AssessmentResult` with `topicMasteries` sorted weakest-first

No partial saves — if the user backgrounds the app mid-assessment, the session is lost and they start over. This avoids stale partial-assessment states.

---

## Providers

Added to `storage.dart`:

```dart
final assessmentRepositoryProvider = Provider<AssessmentRepository>(
  (ref) => AssessmentRepository(ref.watch(appDatabaseProvider)),
);

final assessmentCompletedProvider =
    FutureProvider.family<bool, ExamId>((ref, examId) async {
  return ref.watch(assessmentRepositoryProvider).hasCompletedForExam(examId);
});
```

Added to `assessment_results_page.dart`:

```dart
final assessmentResultProvider =
    FutureProvider.family<AssessmentResult?, ExamId>((ref, examId) async {
  final row = await ref.watch(assessmentRepositoryProvider).resultForExam(examId);
  if (row == null) return null;
  final topics = await ref.watch(contentRepositoryProvider).topicsByExam(examId);
  return AssessmentResult.fromRow(row, topics);
});
```

---

## UI

### `AssessmentPage`

Route: `/assessment/:examId`

- Calls `StartAssessment` on mount to build the session
- Renders one question at a time (reuses existing quiz answer tile components)
- Progress bar at top: "Question N of total"
- No back navigation mid-assessment (confirm dialog if user tries to leave)
- On last answer: calls `CompleteAssessment`, then navigates to `/assessment/:examId/results`

### `AssessmentResultsPage`

Route: `/assessment/:examId/results`

**Zone 1 — Score breakdown:**
- Header: exam name + "Your [ExamName] Profile"
- One horizontal bar per topic, sorted weakest-first
- Bar color: red (`weak`), amber (`moderate`), green (`strong`)
- Accuracy percentage label on each bar

**Zone 2 — Study plan CTAs:**
- Shows the top 2–3 weakest topics (those with `MasteryLevel.weak`, or lowest accuracy if none are weak)
- Each topic rendered as a card:
  ```
  [Topic Name]
  [Study →]  [Quiz →]
  ```
  - "Study →" → navigates to `/learn/topic/:topicId?examId=:examId` (lesson list)
  - "Quiz →" → navigates to `/quiz/quick/:examId?topicId=:topicId` (quick quiz filtered to the topic)
- Weakest topic gets a "Start here" badge
- Below CTAs: small muted text — *"Your recommendations update as you study"*

This screen is also accessible later from the home tab; it is not a one-time view.

---

## Assessment Nudge

**Where:** Injected into the quiz results screen (`QuizResultsPage`) after a quiz attempt completes.

**Logic (no new DB table required):**
1. Check `assessmentCompletedProvider(examId)` — if true, show nothing
2. Count attempts for this exam via `AttemptsRepository.countForExam(examId)` (new method)
3. If attempt count == 1: show bottom sheet nudge
4. If attempt count == 3: show bottom sheet nudge
5. If attempt count >= 5: show persistent banner on results screen

**Bottom sheet copy:**
- Attempt 1: *"Get your personalized study plan — see exactly where to focus for [ExamName]."*
- Attempt 3: *"You've done 3 quizzes — find out which topics to prioritize."*
- Buttons: "Start assessment" (primary) → `/assessment/:examId` | "Maybe later" (secondary, dismisses)

**Banner copy (attempt 5+):** *"Your study plan is waiting. Take the assessment →"* (tappable, navigates to `/assessment/:examId`)

No dismissal state is stored — the nudge reappears each session until the assessment is taken.

---

## Routing

New routes added to `lib/app/router.dart`:
```
/assessment/:examId          → AssessmentPage
/assessment/:examId/results  → AssessmentResultsPage
```

---

## Error Handling

- If `StartAssessment` fails to load questions (empty topic/question data): show an error banner with retry
- If `CompleteAssessment` DB write fails: show an error banner; session answers are still in memory so the user can retry without re-answering
- Mid-assessment app backgrounding: session lost, user returns to the assessment entry point

---

## Testing

### Unit tests

- `AssessmentQuestionSelector`: correct count per topic; prefers unseen questions; interleaves topics; respects 35-question cap
- `StartAssessment`: returns session with correct question count and examId
- `CompleteAssessment`: correct per-topic scores; FSRS updated for each question; correct/incorrect maps to good/again ratings; `saveResult` called once

### Repository tests (in-memory Drift DB)

- `saveResult` writes a row; `resultForExam` returns it; `hasCompletedForExam` returns true after save
- Upsert: calling `saveResult` twice for same exam overwrites, not duplicates
- `resultForExam` returns null on empty DB

### Widget tests

- `AssessmentPage`: progress bar advances on each answer; navigates to results on last answer
- `AssessmentResultsPage`: bars sorted weakest-first; weak topics show "Start here" badge; "Study →" and "Quiz →" buttons present per weak topic
- Nudge on `QuizResultsPage`: bottom sheet appears after attempt 1 with no assessment; does not appear after assessment completed; banner appears after attempt 5

---

## File Map

**New files:**
```
lib/core/storage/data/tables/assessment_results_local_table.dart
lib/core/storage/data/repos/assessment_repository.dart
lib/features/assessment/domain/models/assessment_session.dart
lib/features/assessment/domain/models/assessment_question.dart
lib/features/assessment/domain/models/assessment_result.dart
lib/features/assessment/domain/models/topic_mastery.dart
lib/features/assessment/domain/services/assessment_question_selector.dart
lib/features/assessment/domain/use_cases/start_assessment.dart
lib/features/assessment/domain/use_cases/complete_assessment.dart
lib/features/assessment/presentation/assessment_page.dart
lib/features/assessment/presentation/assessment_results_page.dart
lib/features/assessment/assessment.dart

test/core/storage/data/repos/assessment_repository_test.dart
test/features/assessment/domain/services/assessment_question_selector_test.dart
test/features/assessment/domain/use_cases/start_assessment_test.dart
test/features/assessment/domain/use_cases/complete_assessment_test.dart
test/features/assessment/presentation/assessment_page_test.dart
test/features/assessment/presentation/assessment_results_page_test.dart
test/features/quiz/presentation/quiz_results_nudge_test.dart
```

**Modified files:**
```
lib/core/storage/data/app_database.dart       Add table, bump schemaVersion to 3
lib/core/storage/storage.dart                 Add repo + completion/count providers
lib/core/ui/components/question_card.dart     Shared question card used by quiz + assessment
lib/core/ui/components/quiz_progress_bar.dart Shared question progress bar used by quiz + assessment
lib/core/storage/data/repos/content_repository.dart   Add topicsByExam method
lib/core/storage/data/repos/attempts_repository.dart   Add countForExam method
lib/app/router.dart                           Add 2 assessment routes
lib/features/quiz/presentation/quiz_results_page.dart  Add assessment nudge
```
