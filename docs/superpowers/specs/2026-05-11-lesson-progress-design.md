# Lesson Progress Tracking — Design Spec

**Date:** 2026-05-11
**Status:** Approved

---

## Goal

Track which lessons a user has read, surface that state cosmetically throughout the Learn tab, and show a one-time bottom sheet nudge on the Quiz tab when a user attempts a quiz without having read any lessons for that exam.

---

## Scope

- Per-lesson read/unread state stored locally in Drift
- "Mark as read" button on `LessonPage`; checkmarks on `LessonListPage` lesson cards
- One-time quiz nudge on `QuizTabHome` — shown once per exam when zero lessons have been read
- No hard gates — all progress is cosmetic and advisory
- No server sync in this iteration (syncState column reserved for future use)

---

## Data Layer

### New tables (schemaVersion → 2)

**`LessonProgressLocal`**

| Column | Type | Notes |
|---|---|---|
| `lessonId` | text, PK | References `Lessons.id` |
| `readAt` | datetime | Set on first mark-as-read |
| `syncState` | text | Default `'pending'`; reserved for future sync |

**`QuizNudgeDismissedLocal`**

Singleton table — at most one row ever.

| Column | Type | Notes |
|---|---|---|
| `id` | int, PK | Always `1`; enforces singleton |
| `dismissedAt` | datetime | Set when user dismisses the nudge |

### Migration

Bump `schemaVersion` to 2. In `onUpgrade`, create both new tables when upgrading from version 1:

```dart
if (from < 2) {
  await m.createTable(lessonProgressLocal);
  await m.createTable(quizNudgeDismissedLocal);
}
```

---

## Repositories

### `LessonProgressRepository`

File: `lib/core/storage/data/repos/lesson_progress_repository.dart`

| Method | Signature | Behavior |
|---|---|---|
| `markRead` | `Future<void> markRead(LessonId)` | Upserts row with `readAt = DateTime.now()`, `syncState = 'pending'` |
| `isRead` | `Future<bool> isRead(LessonId)` | True if a row exists for this lesson |
| `readLessonIds` | `Future<Set<LessonId>> readLessonIds()` | All read lesson IDs |
| `readCountForTopic` | `Future<int> readCountForTopic(TopicId)` | Count of read lessons for the topic via SQL subquery join |
| `hasAnyRead` | `Future<bool> hasAnyRead()` | True if any lesson has ever been marked read |

### `QuizNudgeRepository`

File: `lib/core/storage/data/repos/quiz_nudge_repository.dart`

| Method | Signature | Behavior |
|---|---|---|
| `hasDismissed` | `Future<bool> hasDismissed()` | True if the singleton dismissal row exists |
| `markDismissed` | `Future<void> markDismissed()` | Inserts/updates the singleton row with `dismissedAt = DateTime.now()` |

Both repos get providers added to `storage.dart`:

```dart
final lessonProgressRepositoryProvider = Provider<LessonProgressRepository>(...);
final quizNudgeRepositoryProvider = Provider<QuizNudgeRepository>(...);
```

---

## Providers

Added to `storage.dart`:

```dart
// True if the given lesson has been read
final isLessonReadProvider =
    FutureProvider.family<bool, LessonId>((ref, id) async {
  return ref.watch(lessonProgressRepositoryProvider).isRead(id);
});

// Count of read lessons for a topic (SQL subquery join — no List param)
final readCountForTopicProvider =
    FutureProvider.family<int, TopicId>((ref, topicId) async {
  return ref.watch(lessonProgressRepositoryProvider).readCountForTopic(topicId);
});

// True if any lesson has ever been marked read
final anyLessonReadProvider = FutureProvider<bool>((ref) async {
  return ref.watch(lessonProgressRepositoryProvider).hasAnyRead();
});

// True if the one-time quiz nudge has been dismissed
final quizNudgeDismissedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(quizNudgeRepositoryProvider).hasDismissed();
});
```

---

## Use Cases

Located under `lib/features/lesson/domain/use_cases/`:

**`MarkLessonRead`** — calls `LessonProgressRepository.markRead(id)`. Thin wrapper; no business logic beyond the call.

**`DismissQuizNudge`** — calls `QuizNudgeRepository.markDismissed()` (no argument; global singleton).

Both exported from the `lesson.dart` barrel.

---

## UI Changes

### `LessonPage`

- Watches `isLessonReadProvider(lessonId)`
- Button states:
  - **Unread:** `AppButton` labelled "Mark as read" (primary variant)
  - **Read:** `AppButton` labelled "Lesson complete ✓" (secondary variant, disabled)
- On tap: calls `MarkLessonRead`, then invalidates `isLessonReadProvider(lessonId)` so the button re-renders immediately (optimistic — no await on button state flip)
- Button sits below the lesson body, above the "Quiz this topic" CTA (if present)

### `LessonListPage`

- Each `_LessonCard` watches `isLessonReadProvider(lesson.id)`
- When read: trailing `Icon(Icons.check_circle, color: colors.success)` visible
- When unread: no trailing icon
- No layout reflow — icon slot reserved but empty when unread

### `QuizTabHome`

- `_ExamCard` "Start Quick Quiz" button tap checks two conditions before navigating:
  1. `quizNudgeDismissedProvider` is false (nudge not yet dismissed globally)
  2. `anyLessonReadProvider` is false (no lessons read anywhere)
- If both true: show `showModalBottomSheet` with:
  - Title: "Study first for better results"
  - Body: "You haven't read any lessons for this exam yet. Reading the material before quizzing helps you retain it longer."
  - Button 1 (primary): "Read lessons" → navigates to `/learn`, dismisses sheet
  - Button 2 (text/secondary): "Start quiz anyway" → calls `DismissQuizNudge` (no arg), then navigates to quiz
- If either condition is false: navigate directly to quiz (normal flow)

---

## Error Handling

`markRead` and `markDismissed` are fire-and-forget from the UI layer. The button flips state optimistically on tap; if the DB write fails silently, the lesson shows unread on next launch — acceptable for a cosmetic local feature. No user-facing error state for progress writes.

Read queries (`isRead`, `hasDismissed`) return `false` on failure via provider error state — unread is the safe default.

---

## Security

Progress data lives in the existing encrypted SQLite database. Since progress is cosmetic-only with no content gates, the attack surface for data tampering is nil — a user who modifies their own read state only deceives themselves. IAP entitlements are validated server-side via RevenueCat and are unaffected.

---

## Testing

### Unit tests (mocktail mocks of repos)

- `MarkLessonRead` — calls `markRead` with the correct ID
- `DismissQuizNudge` — calls `markDismissed` with the correct exam ID

### Repository tests (in-memory Drift DB)

- `LessonProgressRepository`: `markRead` creates a row; `isRead` returns true after mark, false before; `readCountForTopic` returns correct count via subquery; `hasAnyRead` returns false on empty, true after any mark
- `QuizNudgeRepository`: `hasDismissed` false before dismissal, true after; `markDismissed` is idempotent (upserts singleton)

### Widget tests (`pumpAppWithProviders` + `appDatabaseProvider.overrideWithValue(db)`)

- `LessonPage`: button starts as "Mark as read"; after tap shows "Lesson complete ✓"; on re-open of a read lesson, button starts in complete state
- `LessonListPage`: checkmark absent before read, present after `markRead` called in DB setup
- `QuizTabHome`: bottom sheet appears on first quiz tap with zero lessons read anywhere; does not appear after "Start quiz anyway" is tapped (global dismissal); does not appear once any lesson has been marked read

---

## File Map

**New files:**
```
lib/core/storage/data/tables/lesson_progress_local_table.dart
lib/core/storage/data/tables/quiz_nudge_dismissed_local_table.dart
lib/core/storage/data/repos/lesson_progress_repository.dart
lib/core/storage/data/repos/quiz_nudge_repository.dart
lib/features/lesson/domain/use_cases/mark_lesson_read.dart
lib/features/lesson/domain/use_cases/dismiss_quiz_nudge.dart

test/core/storage/data/repos/lesson_progress_repository_test.dart
test/core/storage/data/repos/quiz_nudge_repository_test.dart
test/features/lesson/domain/use_cases/mark_lesson_read_test.dart
test/features/lesson/domain/use_cases/dismiss_quiz_nudge_test.dart
test/features/lesson/presentation/lesson_page_progress_test.dart
test/features/lesson/presentation/lesson_list_progress_test.dart
test/features/quiz/presentation/quiz_tab_nudge_test.dart
```

**Modified files:**
```
lib/core/storage/data/app_database.dart        Add 2 tables, bump schemaVersion to 2
lib/core/storage/storage.dart                  Add 2 repo providers + 3 FutureProviders
lib/features/lesson/presentation/lesson_page.dart        Mark-as-read button
lib/features/lesson/presentation/lesson_list_page.dart   Checkmark on cards
lib/features/quiz/presentation/quiz_tab_home.dart        One-time nudge bottom sheet
lib/features/lesson/lesson.dart                          Export 2 new use cases
```
