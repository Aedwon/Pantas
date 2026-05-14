# Plan 06: Lesson Reader — Design Spec

**Date:** 2026-05-10
**Status:** Approved, ready for implementation planning
**Follows:** Plan 05 (Quiz Feature)

---

## 1. Goal

Deliver the lesson-reading experience end-to-end: a topic browser on the Learn tab, a lesson list per topic, and a full lesson detail page that renders Sanity Portable Text — including inline and block LaTeX, images, and headings — using local Drift data.

---

## 2. Scope

### In scope

- `PortableTextRenderer` — pure widget in `core/ui/components/`; renders Sanity Portable Text blocks
- `LearnTabHome` — replaces `/learn` stub; exam → topic browser
- `LessonListPage` — `/learn/topic/:topicId`; lists lessons for a topic
- `LessonPage` — `/lesson/:lessonId`; full lesson reader (push route, outside shell branches)
- "Lessons" CTA added to existing `QuizTabHome` exam cards alongside "Start Quick Quiz"
- `GetLesson` and `GetTopicLessons` use cases in `features/lesson/domain/`
- One new pubspec dependency: `cached_network_image`

### Out of scope

- Lesson-completion tracking / read-state persistence
- FSRS "review this lesson" trigger (Plan 07)
- Progress badges or mastery indicators (Plan 09)
- In-app search across lessons (post-launch)
- Glossary popover on term tap (post-launch)

---

## 3. Navigation

`/learn` is an existing `StatefulShellBranch` (tab index 1, the centre Learn button). It gains sub-routes:

```
/learn                              → LearnTabHome (exam list → tap → topic list)
/learn/topic/:topicId?examId=       → LessonListPage (examId optional query param)
/lesson/:lessonId?examId=           → LessonPage (examId optional query param)
```

`examId` is threaded as an optional query parameter through the navigation chain so `LessonListPage` and `LessonPage` can offer a "Quiz this topic" CTA. When `examId` is absent (e.g., deep link without context), the CTA is hidden — not an error.

`/lesson/:lessonId` stays outside the shell so it can be reached from quiz results, onboarding, and future deep links without disrupting tab state.

---

## 4. Architecture

Standard three-layer layout under `features/lesson/` per the project's lint-enforced rule.

### 4.1 Domain

**`GetLesson`** use case:
- `call(LessonId id) → Future<Lesson>`
- Delegates to `ContentRepository.lessonById(id)` (new single-item query, trivial to add alongside existing `lessonsByTopic`)
- Throws `StateError` if not found

**`GetTopicLessons`** use case:
- `call(TopicId topicId) → Future<List<Lesson>>`
- Delegates to `ContentRepository.lessonsByTopic(topicId)`
- Returns empty list (not an error) if topic has no lessons

No `LessonSession` domain model — lesson reading is stateless.

### 4.2 Data

`ContentRepository` gets one new method:

```dart
Future<Lesson?> lessonById(LessonId id)
```

Backed by a `SELECT … WHERE id = ?` query on `lessons` table (already in Drift schema from Plan 03).

### 4.3 Presentation (Riverpod providers)

| Provider | Type | Used by |
|---|---|---|
| `lessonByIdProvider(id)` | `FutureProvider.family<Lesson?, LessonId>` | `LessonPage` |
| `topicLessonsProvider(topicId)` | `FutureProvider.family<List<Lesson>, TopicId>` | `LessonListPage` |
| `topicByIdProvider(topicId)` | `FutureProvider.family<Topic?, TopicId>` | `LessonListPage` (breadcrumb title) |
| `topicsBySubjectProvider(subjectId)` | `FutureProvider.family<List<Topic>, SubjectId>` | `LearnTabHome` |
| `examListProvider` | already exists in `quiz_tab_home.dart` — move to `core/storage/storage.dart` barrel so both `LearnTabHome` and `QuizTabHome` share it | both tabs |

---

## 5. PortableTextRenderer

Lives at `core/ui/components/portable_text_renderer.dart`. Pure `StatelessWidget` — no Riverpod, no side effects.

**Signature:**
```dart
class PortableTextRenderer extends StatelessWidget {
  const PortableTextRenderer({required this.blocks, super.key});
  final List<Map<String, dynamic>> blocks;
}
```

**Block dispatch table:**

| `_type` value | Rendering |
|---|---|
| `block` | `_BlockRenderer` — maps `style` (`normal`, `h1`–`h6`, `blockquote`) to `AppTextStyles` tokens; handles inline spans including `latex`-marked spans |
| `latex` | `_LatexBlockRenderer` — `flutter_math_fork` display mode (`MathStyle.display`) |
| `image` | `_ImageBlockRenderer` — `CachedNetworkImage` from Sanity CDN URL; respects aspect ratio |
| anything else | `_UnknownBlockPlaceholder` — grey rounded card: "Content unavailable — update the app"; logs Crashlytics non-fatal with `{blockType, lessonId}` |

**Inline LaTeX** (span with `latex` mark inside a `block`):
- Detected when a `span` child has `"marks": ["latex"]`
- Rendered as `Math.tex(text, mathStyle: MathStyle.text)` inline within a `Text.rich` widget
- Parse error → same `_UnknownBlockPlaceholder` + Crashlytics non-fatal

**LaTeX error boundary:** `flutter_math_fork` throws on malformed input. Each `_LatexBlockRenderer` and inline span catches parse errors and falls back to `_UnknownBlockPlaceholder`.

---

## 6. Pages

### LearnTabHome

- Watches `examListProvider`
- Shows exams as `AppCard` list items
- Tap on exam → expands to show subjects inline, tap subject row → shows topic list inline (accordion style) or pushes `LessonListPage` — accordion preferred to keep navigation shallow
- Loading: `SkeletonLoader`; error: `ErrorBanner`

### LessonListPage (`/learn/topic/:topicId`)

- Watches `topicLessonsProvider(topicId)` and `topicsBySubjectProvider` (for breadcrumb/title)
- Shows lessons as `AppCard` list items with title, estimated read time, and summary snippet
- Empty state: "No lessons yet for this topic" with a "Try a quick quiz instead" CTA → `/quiz/quick/:examId` (only shown if `examId` query param is present)
- Tap → `context.push('/lesson/$lessonId?examId=$examId')` (threads `examId` forward if present)

### LessonPage (`/lesson/:lessonId`)

- Watches `lessonByIdProvider(lessonId)`
- `AppBar` title: `lesson.title`
- Body: `SingleChildScrollView` → `PortableTextRenderer(blocks: lesson.bodyJson)`
- Footer: estimated read time chip + "Quiz this topic" `AppButton` → `/quiz/quick/$examId` (only rendered when `examId` query param is present; hidden otherwise)
- Loading: `SkeletonLoader`; error: `ErrorBanner` with retry

### QuizTabHome update

Add a "Browse Lessons" `AppButton` (secondary style) to each exam card, below the existing "Start Quick Quiz" button. Navigates to `/learn` (the Learn tab home) — the user selects their subject and topic from there. No topic resolution needed at this callsite.

---

## 7. New dependency

```yaml
cached_network_image: ^3.3.1
```

Used only in `_ImageBlockRenderer`. Images are fetched from Sanity CDN; `CachedNetworkImage` uses `flutter_cache_manager` internally (200MB cap per spec §3.3 storage budget). No other dependency changes.

---

## 8. File map

**New files:**
```
lib/core/ui/components/portable_text_renderer.dart
lib/features/lesson/domain/use_cases/get_lesson.dart
lib/features/lesson/domain/use_cases/get_topic_lessons.dart
lib/features/lesson/presentation/learn_tab_home.dart
lib/features/lesson/presentation/lesson_list_page.dart
lib/features/lesson/presentation/lesson_page.dart
lib/features/lesson/lesson.dart                              (barrel)

test/core/ui/components/portable_text_renderer_test.dart
test/features/lesson/domain/use_cases/get_lesson_test.dart
test/features/lesson/domain/use_cases/get_topic_lessons_test.dart
test/features/lesson/presentation/lesson_page_test.dart
test/features/lesson/presentation/lesson_list_page_test.dart
test/features/lesson/presentation/learn_tab_home_test.dart
```

**Modified files:**
```
lib/core/storage/data/repos/content_repository.dart         Add lessonById(), topicById()
lib/core/storage/storage.dart                               Export examListProvider
lib/app/router.dart                                         Wire /learn sub-routes + /lesson/:lessonId
lib/features/quiz/presentation/quiz_tab_home.dart           Add "Browse Lessons" CTA
pubspec.yaml                                                Add cached_network_image
```

---

## 9. Testing strategy

**Unit tests (`portable_text_renderer_test.dart`):**
- `block` normal → renders text content
- `block` h2 → uses headline style
- `block` with inline latex span → renders `Math.tex` inline
- `latex` block → renders display-mode math
- `image` block → renders `CachedNetworkImage`
- Unknown block type → renders placeholder widget
- Malformed LaTeX → renders placeholder widget (no throw)

**Use case unit tests:**
- `GetLesson`: found → returns `Lesson`; not found → throws `StateError`
- `GetTopicLessons`: returns list; empty topic → returns `[]`

**Widget tests:**
- `LessonPage`: seeded in-memory DB → lesson title and content visible
- `LessonListPage`: shows lesson titles; empty state shown when no lessons
- `LearnTabHome`: shows exam names from seeded DB

**Coverage targets:** `features/lesson/domain/` ≥ 80%; overall ≥ 70% per spec §7.2.

---

## 10. Layering compliance

- `domain/` imports only `core/storage/domain/` interfaces and `dart:core` — no Flutter, no Drift
- `presentation/` reaches `data/` only through use cases and Riverpod providers
- `core/ui/components/portable_text_renderer.dart` imports `flutter_math_fork` and `cached_network_image` — these are UI-layer dependencies, correct placement
- `features/lesson/` imports nothing from `features/quiz/` — the "Browse Lessons" link in `QuizTabHome` is a `context.push` string, not a widget import

---

**End of spec.**
