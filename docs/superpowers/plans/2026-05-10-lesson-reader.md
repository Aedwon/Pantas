# Lesson Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the end-to-end lesson-reading experience: topic browser on the Learn tab, lesson list per topic, and a full lesson detail page that renders Sanity Portable Text (inline/block LaTeX, images, headings) from local Drift data.

**Architecture:** Three-layer clean architecture under `features/lesson/` mirroring the existing quiz feature. `PortableTextRenderer` is a pure stateless widget in `core/ui/components/`. Riverpod `FutureProvider.family` providers live in `core/storage/storage.dart` so both tabs share `examListProvider`.

**Tech Stack:** Flutter, Riverpod, Drift (in-memory for tests), GoRouter, `flutter_math_fork`, `cached_network_image`, mocktail

---

## File Map

**New files:**
```
lib/core/ui/components/portable_text_renderer.dart
lib/features/lesson/domain/use_cases/get_lesson.dart
lib/features/lesson/domain/use_cases/get_topic_lessons.dart
lib/features/lesson/presentation/learn_tab_home.dart
lib/features/lesson/presentation/lesson_list_page.dart
lib/features/lesson/presentation/lesson_page.dart
lib/features/lesson/lesson.dart                          (barrel)

test/core/ui/components/portable_text_renderer_test.dart
test/features/lesson/domain/use_cases/get_lesson_test.dart
test/features/lesson/domain/use_cases/get_topic_lessons_test.dart
test/features/lesson/presentation/lesson_page_test.dart
test/features/lesson/presentation/lesson_list_page_test.dart
test/features/lesson/presentation/learn_tab_home_test.dart
```

**Modified files:**
```
pubspec.yaml                                              Add cached_network_image: ^3.3.1
lib/core/storage/data/repos/content_repository.dart      Add lessonById(), topicById()
lib/core/storage/storage.dart                            Move examListProvider here; add 4 new providers
lib/app/router.dart                                      Wire /learn sub-routes + /lesson/:lessonId
lib/features/quiz/presentation/quiz_tab_home.dart        Remove local examListProvider; add "Browse Lessons" CTA
```

---

## Task 1: Add `cached_network_image` dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependency**

In `pubspec.yaml`, under `dependencies:`, after the existing `firebase_*` block, add:
```yaml
    cached_network_image: ^3.3.1
```

- [ ] **Step 2: Fetch packages**

Run: `flutter pub get`
Expected: exits 0, no version conflicts

- [ ] **Step 3: Verify flutter_math_fork is present**

Run: `grep flutter_math_fork pubspec.yaml`
Expected: finds a line like `flutter_math_fork: ^0.x.x`

If the line is missing, add it under dependencies:
```yaml
    flutter_math_fork: ^0.7.2
```
Then run `flutter pub get` again.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add cached_network_image dependency"
```

---

## Task 2: Extend `ContentRepository` — `lessonById()` and `topicById()`

**Files:**
- Modify: `lib/core/storage/data/repos/content_repository.dart`
- Test: `test/core/storage/data/repos/content_repository_test.dart`

- [ ] **Step 1: Write failing tests**

Open `test/core/storage/data/repos/content_repository_test.dart`. Add these tests inside the existing `main()`, after the existing `setUp` block (keep the existing seeds — exam `exam_cse_pro`, subject `s1`, topic `t1`). Add a lesson seed to `setUp` and add new tests:

In `setUp`, after the topics insert, add:
```dart
    await db.into(db.lessons).insert(
      LessonsCompanion.insert(
        id: 'l1',
        topicId: 't1',
        title: 'Vocabulary Basics',
        summary: 'Core vocabulary concepts',
        bodyJson: jsonEncode([
          {
            '_type': 'block',
            'style': 'normal',
            'children': [
              {'_type': 'span', 'text': 'Hello world', 'marks': []}
            ]
          }
        ]),
        estimatedMinutes: 5,
      ),
    );
```

Add these tests after the existing ones:
```dart
  test('lessonById returns Lesson when found', () async {
    final lesson = await repo.lessonById('l1');
    expect(lesson, isNotNull);
    expect(lesson!.id, equals('l1'));
    expect(lesson.title, equals('Vocabulary Basics'));
    expect(lesson.bodyJson, hasLength(1));
  });

  test('lessonById returns null when not found', () async {
    expect(await repo.lessonById('missing'), isNull);
  });

  test('topicById returns Topic when found', () async {
    final topic = await repo.topicById('t1');
    expect(topic, isNotNull);
    expect(topic!.id, equals('t1'));
    expect(topic.name, equals('Vocabulary'));
  });

  test('topicById returns null when not found', () async {
    expect(await repo.topicById('nope'), isNull);
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/storage/data/repos/content_repository_test.dart -v`
Expected: FAIL — `lessonById` and `topicById` not defined on `ContentRepository`

- [ ] **Step 3: Implement `lessonById()` and `topicById()`**

In `lib/core/storage/data/repos/content_repository.dart`, add these two methods after `lessonsByTopic()`:

```dart
  Future<Lesson?> lessonById(LessonId id) async {
    final row = await (_db.select(_db.lessons)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return Lesson(
      id: row.id,
      topicId: row.topicId,
      title: row.title,
      summary: row.summary,
      bodyJson: List<Map<String, dynamic>>.from(
        jsonDecode(row.bodyJson) as List,
      ),
      estimatedMinutes: row.estimatedMinutes,
    );
  }

  Future<Topic?> topicById(TopicId id) async {
    final row = await (_db.select(_db.topics)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return Topic(
      id: row.id,
      subjectId: row.subjectId,
      name: row.name,
      ordering: row.ordering,
    );
  }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/storage/data/repos/content_repository_test.dart -v`
Expected: all tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/data/repos/content_repository.dart \
        test/core/storage/data/repos/content_repository_test.dart
git commit -m "feat(lesson): add lessonById and topicById to ContentRepository"
```

---

## Task 3: Move `examListProvider` to `storage.dart` and add lesson/topic providers

**Files:**
- Modify: `lib/core/storage/storage.dart`
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`

- [ ] **Step 1: Add providers to `storage.dart`**

Add the following imports at the top of `lib/core/storage/storage.dart`:
```dart
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
```

Then add these providers at the bottom of `lib/core/storage/storage.dart`, before the closing:

```dart
final examListProvider = FutureProvider<List<Exam>>((ref) async {
  return ref.watch(contentRepositoryProvider).listExams();
});

final topicsBySubjectProvider =
    FutureProvider.family<List<Topic>, SubjectId>((ref, subjectId) async {
  return ref.watch(contentRepositoryProvider).topicsBySubject(subjectId);
});

final topicByIdProvider =
    FutureProvider.family<Topic?, TopicId>((ref, topicId) async {
  return ref.watch(contentRepositoryProvider).topicById(topicId);
});

final lessonByIdProvider =
    FutureProvider.family<Lesson?, LessonId>((ref, id) async {
  return ref.watch(contentRepositoryProvider).lessonById(id);
});

final topicLessonsProvider =
    FutureProvider.family<List<Lesson>, TopicId>((ref, topicId) async {
  return ref.watch(contentRepositoryProvider).lessonsByTopic(topicId);
});
```

- [ ] **Step 2: Remove `examListProvider` from `quiz_tab_home.dart`**

In `lib/features/quiz/presentation/quiz_tab_home.dart`, delete the lines:
```dart
final examListProvider = FutureProvider<List<Exam>>((ref) async {
  return ref.watch(contentRepositoryProvider).listExams();
});
```

Add this import instead (it's now in storage.dart which is already imported):
```dart
// examListProvider is now in storage.dart — no change needed to imports
// since storage.dart is already imported in this file
```

Verify `import 'package:cse_cet_reviewer/core/storage/storage.dart';` is present in quiz_tab_home.dart — it already is.

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze lib/`
Expected: no errors mentioning `examListProvider`

- [ ] **Step 4: Commit**

```bash
git add lib/core/storage/storage.dart \
        lib/features/quiz/presentation/quiz_tab_home.dart
git commit -m "refactor(storage): move examListProvider to storage barrel, add lesson/topic providers"
```

---

## Task 4: `GetLesson` use case (TDD)

**Files:**
- Create: `lib/features/lesson/domain/use_cases/get_lesson.dart`
- Create: `test/features/lesson/domain/use_cases/get_lesson_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/features/lesson/domain/use_cases/get_lesson_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/get_lesson.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockContent extends Mock implements ContentRepository {}

void main() {
  late _MockContent content;
  late GetLesson useCase;

  final lesson = Lesson(
    id: 'l1',
    topicId: 't1',
    title: 'Test Lesson',
    summary: 'Summary',
    bodyJson: const [],
    estimatedMinutes: 3,
  );

  setUp(() {
    content = _MockContent();
    useCase = GetLesson(content);
  });

  test('returns Lesson when found', () async {
    when(() => content.lessonById('l1')).thenAnswer((_) async => lesson);
    final result = await useCase('l1');
    expect(result.id, equals('l1'));
    expect(result.title, equals('Test Lesson'));
  });

  test('throws StateError when lesson is not found', () async {
    when(() => content.lessonById('missing')).thenAnswer((_) async => null);
    expect(() => useCase('missing'), throwsStateError);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/lesson/domain/use_cases/get_lesson_test.dart -v`
Expected: FAIL — `GetLesson` not found

- [ ] **Step 3: Implement `GetLesson`**

Create `lib/features/lesson/domain/use_cases/get_lesson.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';

class GetLesson {
  GetLesson(this._content);

  final ContentRepository _content;

  Future<Lesson> call(LessonId id) async {
    final lesson = await _content.lessonById(id);
    if (lesson == null) throw StateError('Lesson not found: $id');
    return lesson;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/lesson/domain/use_cases/get_lesson_test.dart -v`
Expected: all PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/lesson/domain/use_cases/get_lesson.dart \
        test/features/lesson/domain/use_cases/get_lesson_test.dart
git commit -m "feat(lesson): add GetLesson use case"
```

---

## Task 5: `GetTopicLessons` use case (TDD)

**Files:**
- Create: `lib/features/lesson/domain/use_cases/get_topic_lessons.dart`
- Create: `test/features/lesson/domain/use_cases/get_topic_lessons_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/features/lesson/domain/use_cases/get_topic_lessons_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/get_topic_lessons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockContent extends Mock implements ContentRepository {}

void main() {
  late _MockContent content;
  late GetTopicLessons useCase;

  Lesson makeLesson(String id) => Lesson(
        id: id,
        topicId: 't1',
        title: 'Lesson $id',
        summary: '',
        bodyJson: const [],
        estimatedMinutes: 5,
      );

  setUp(() {
    content = _MockContent();
    useCase = GetTopicLessons(content);
  });

  test('returns list of lessons for topic', () async {
    final lessons = [makeLesson('l1'), makeLesson('l2')];
    when(() => content.lessonsByTopic('t1')).thenAnswer((_) async => lessons);

    final result = await useCase('t1');
    expect(result, hasLength(2));
    expect(result.first.id, equals('l1'));
  });

  test('returns empty list when topic has no lessons', () async {
    when(() => content.lessonsByTopic('empty')).thenAnswer((_) async => []);

    final result = await useCase('empty');
    expect(result, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/lesson/domain/use_cases/get_topic_lessons_test.dart -v`
Expected: FAIL — `GetTopicLessons` not found

- [ ] **Step 3: Implement `GetTopicLessons`**

Create `lib/features/lesson/domain/use_cases/get_topic_lessons.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';

class GetTopicLessons {
  GetTopicLessons(this._content);

  final ContentRepository _content;

  Future<List<Lesson>> call(TopicId topicId) async {
    return _content.lessonsByTopic(topicId);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/lesson/domain/use_cases/get_topic_lessons_test.dart -v`
Expected: all PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/lesson/domain/use_cases/get_topic_lessons.dart \
        test/features/lesson/domain/use_cases/get_topic_lessons_test.dart
git commit -m "feat(lesson): add GetTopicLessons use case"
```

---

## Task 6: `PortableTextRenderer` — `block` type, headings, and unknown block (TDD)

**Files:**
- Create: `lib/core/ui/components/portable_text_renderer.dart`
- Create: `test/core/ui/components/portable_text_renderer_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/portable_text_renderer_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('block type', () {
    testWidgets('normal block renders its text content', (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {'_type': 'span', 'text': 'Hello world', 'marks': []}
              ]
            }
          ],
        ),
      );

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('h2 block uses a larger text style than normal', (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {
              '_type': 'block',
              'style': 'h2',
              'children': [
                {'_type': 'span', 'text': 'A Heading', 'marks': []}
              ]
            }
          ],
        ),
      );

      final textWidget = tester.widget<Text>(find.text('A Heading'));
      expect(textWidget.style?.fontSize, greaterThanOrEqualTo(18));
    });
  });

  group('unknown block type', () {
    testWidgets('renders placeholder widget for unrecognised block type',
        (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {'_type': 'someNewType', 'data': 'x'}
          ],
        ),
      );

      expect(find.text('Content unavailable — update the app'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/ui/components/portable_text_renderer_test.dart -v`
Expected: FAIL — `PortableTextRenderer` not found

- [ ] **Step 3: Create `portable_text_renderer.dart` with block + unknown support**

Create `lib/core/ui/components/portable_text_renderer.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PortableTextRenderer extends StatelessWidget {
  const PortableTextRenderer({required this.blocks, super.key});

  final List<Map<String, dynamic>> blocks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks) _dispatch(context, block),
      ],
    );
  }

  Widget _dispatch(BuildContext context, Map<String, dynamic> block) {
    final type = block['_type'] as String? ?? '';
    return switch (type) {
      'block' => _BlockRenderer(block: block),
      'latex' => _LatexBlockRenderer(block: block),
      'image' => _ImageBlockRenderer(block: block),
      _ => _UnknownBlockPlaceholder(blockType: type),
    };
  }
}

class _BlockRenderer extends StatelessWidget {
  const _BlockRenderer({required this.block});

  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final style = block['style'] as String? ?? 'normal';
    final children = (block['children'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    final textStyles = context.textStyles;

    final TextStyle baseStyle = switch (style) {
      'h1' => textStyles.displayLarge,
      'h2' => textStyles.displaySmall,
      'h3' => textStyles.headlineMedium,
      'h4' || 'h5' || 'h6' => textStyles.headlineSmall,
      'blockquote' => textStyles.bodyLarge
          .copyWith(fontStyle: FontStyle.italic),
      _ => textStyles.bodyMedium,
    };

    final hasLatex = children.any((child) {
      final marks = (child['marks'] as List? ?? []);
      return marks.contains('latex');
    });

    if (hasLatex) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text.rich(
          TextSpan(
            children: [
              for (final child in children)
                _buildInlineSpan(child, baseStyle),
            ],
          ),
        ),
      );
    }

    final text = children
        .map((c) => c['text'] as String? ?? '')
        .join();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: baseStyle),
    );
  }

  InlineSpan _buildInlineSpan(
    Map<String, dynamic> child,
    TextStyle base,
  ) {
    final text = child['text'] as String? ?? '';
    final marks = (child['marks'] as List? ?? []).cast<String>();

    if (marks.contains('latex')) {
      return _LatexInlineSpan(text: text);
    }

    return TextSpan(text: text, style: base);
  }
}

// Placeholder — replaced in Task 7 with real Math.tex call
class _LatexInlineSpan extends WidgetSpan {
  _LatexInlineSpan({required String text})
      : super(child: _LatexInlinePlaceholder(text: text));
}

class _LatexInlinePlaceholder extends StatelessWidget {
  const _LatexInlinePlaceholder({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    // Replaced by Math.tex in Task 7
    return Text(text, style: context.textStyles.mathBody);
  }
}

class _LatexBlockRenderer extends StatelessWidget {
  const _LatexBlockRenderer({required this.block});
  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    // Replaced by flutter_math_fork in Task 8
    final text = block['body'] as String? ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(text, style: context.textStyles.mathBody),
      ),
    );
  }
}

class _ImageBlockRenderer extends StatelessWidget {
  const _ImageBlockRenderer({required this.block});
  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    // Replaced by CachedNetworkImage in Task 9
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(height: 200, child: Placeholder()),
    );
  }
}

class _UnknownBlockPlaceholder extends StatelessWidget {
  const _UnknownBlockPlaceholder({required this.blockType});
  final String blockType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    debugPrint('[PortableTextRenderer] unknown block type: $blockType');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Text(
        'Content unavailable — update the app',
        style: context.textStyles.bodySmall
            .copyWith(color: colors.onSurfaceMuted),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/ui/components/portable_text_renderer_test.dart -v`
Expected: all PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/portable_text_renderer.dart \
        test/core/ui/components/portable_text_renderer_test.dart
git commit -m "feat(lesson): add PortableTextRenderer with block and unknown-block support"
```

---

## Task 7: `PortableTextRenderer` — inline LaTeX spans (TDD)

**Files:**
- Modify: `lib/core/ui/components/portable_text_renderer.dart`
- Modify: `test/core/ui/components/portable_text_renderer_test.dart`

- [ ] **Step 1: Add failing tests for inline LaTeX**

In `test/core/ui/components/portable_text_renderer_test.dart`, add at the top:
```dart
import 'package:flutter_math_fork/flutter_math.dart';
```

Add a new group after the existing ones:
```dart
  group('inline latex span', () {
    testWidgets('renders Math widget inline for span with latex mark',
        (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {'_type': 'span', 'text': 'See ', 'marks': []},
                {'_type': 'span', 'text': 'E=mc^2', 'marks': ['latex']},
              ]
            }
          ],
        ),
      );

      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('malformed inline latex renders placeholder, does not throw',
        (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {
                  '_type': 'span',
                  'text': r'\badcommand{{{',
                  'marks': ['latex']
                },
              ]
            }
          ],
        ),
      );

      // Should not throw — renders placeholder instead
      expect(find.text('Content unavailable — update the app'), findsOneWidget);
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/ui/components/portable_text_renderer_test.dart -v`
Expected: inline LaTeX tests FAIL — `Math` widget not rendered

- [ ] **Step 3: Replace `_LatexInlineSpan` and `_LatexInlinePlaceholder` with real Math.tex**

In `lib/core/ui/components/portable_text_renderer.dart`, add the import at the top:
```dart
import 'package:flutter_math_fork/flutter_math.dart';
```

Replace the `_LatexInlineSpan` and `_LatexInlinePlaceholder` classes:

```dart
class _LatexInlineSpan extends WidgetSpan {
  _LatexInlineSpan({required String text})
      : super(child: _InlineLatexWidget(text: text));
}

class _InlineLatexWidget extends StatelessWidget {
  const _InlineLatexWidget({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    try {
      return Math.tex(text, mathStyle: MathStyle.text);
    } catch (_) {
      return _UnknownBlockPlaceholder(blockType: 'latex-inline');
    }
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/ui/components/portable_text_renderer_test.dart -v`
Expected: all PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/portable_text_renderer.dart \
        test/core/ui/components/portable_text_renderer_test.dart
git commit -m "feat(lesson): add inline LaTeX rendering to PortableTextRenderer"
```

---

## Task 8: `PortableTextRenderer` — `latex` block type (TDD)

**Files:**
- Modify: `lib/core/ui/components/portable_text_renderer.dart`
- Modify: `test/core/ui/components/portable_text_renderer_test.dart`

- [ ] **Step 1: Add failing test for `latex` block**

In `test/core/ui/components/portable_text_renderer_test.dart`, add a new group:

```dart
  group('latex block type', () {
    testWidgets('renders display-mode Math widget', (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {'_type': 'latex', 'body': r'\sum_{i=1}^{n} x_i'}
          ],
        ),
      );

      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('malformed latex block renders placeholder, does not throw',
        (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {'_type': 'latex', 'body': r'\bad{{{'}
          ],
        ),
      );

      expect(find.text('Content unavailable — update the app'), findsOneWidget);
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/ui/components/portable_text_renderer_test.dart -v`
Expected: latex block tests FAIL

- [ ] **Step 3: Replace `_LatexBlockRenderer` stub with real implementation**

In `lib/core/ui/components/portable_text_renderer.dart`, replace the existing `_LatexBlockRenderer` class:

```dart
class _LatexBlockRenderer extends StatelessWidget {
  const _LatexBlockRenderer({required this.block});
  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final text = block['body'] as String? ?? '';
    try {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Math.tex(text, mathStyle: MathStyle.display),
        ),
      );
    } catch (_) {
      return _UnknownBlockPlaceholder(blockType: 'latex');
    }
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/ui/components/portable_text_renderer_test.dart -v`
Expected: all PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/portable_text_renderer.dart \
        test/core/ui/components/portable_text_renderer_test.dart
git commit -m "feat(lesson): add display-mode LaTeX block rendering to PortableTextRenderer"
```

---

## Task 9: `PortableTextRenderer` — `image` block type (TDD)

**Files:**
- Modify: `lib/core/ui/components/portable_text_renderer.dart`
- Modify: `test/core/ui/components/portable_text_renderer_test.dart`

- [ ] **Step 1: Add failing test for `image` block**

In `test/core/ui/components/portable_text_renderer_test.dart`, add at the top:
```dart
import 'package:cached_network_image/cached_network_image.dart';
```

Add a new group:
```dart
  group('image block type', () {
    testWidgets('renders CachedNetworkImage for image block', (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {
              '_type': 'image',
              'asset': {'url': 'https://cdn.sanity.io/images/test/image.jpg'}
            }
          ],
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/ui/components/portable_text_renderer_test.dart -v`
Expected: image block test FAIL — `CachedNetworkImage` not rendered

- [ ] **Step 3: Replace `_ImageBlockRenderer` stub with real implementation**

Add the import at the top of `lib/core/ui/components/portable_text_renderer.dart`:
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
```

Replace the existing `_ImageBlockRenderer` class:

```dart
class _ImageBlockRenderer extends StatelessWidget {
  const _ImageBlockRenderer({required this.block});
  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final asset = block['asset'] as Map<String, dynamic>? ?? {};
    final url = asset['url'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(AppDimensions.radiusMD),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => const SkeletonBox(height: 200),
          errorWidget: (_, __, ___) =>
              _UnknownBlockPlaceholder(blockType: 'image'),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run all PortableTextRenderer tests**

Run: `flutter test test/core/ui/components/portable_text_renderer_test.dart -v`
Expected: all PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/portable_text_renderer.dart \
        test/core/ui/components/portable_text_renderer_test.dart
git commit -m "feat(lesson): add image block rendering to PortableTextRenderer"
```

---

## Task 10: `LessonPage` (TDD widget test)

**Files:**
- Create: `lib/features/lesson/presentation/lesson_page.dart`
- Create: `test/features/lesson/presentation/lesson_page_test.dart`

- [ ] **Step 1: Write failing widget test**

Create `test/features/lesson/presentation/lesson_page_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();

    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l1',
            topicId: 't1',
            title: 'Vocabulary Basics',
            summary: 'Core vocab',
            bodyJson: jsonEncode([
              {
                '_type': 'block',
                'style': 'normal',
                'children': [
                  {
                    '_type': 'span',
                    'text': 'Synonyms share meaning.',
                    'marks': []
                  }
                ]
              }
            ]),
            estimatedMinutes: 5,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('shows lesson title and body content', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Vocabulary Basics'), findsOneWidget);
    expect(find.text('Synonyms share meaning.'), findsOneWidget);
  });

  testWidgets('shows estimated read time', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('5 min'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/lesson/presentation/lesson_page_test.dart -v`
Expected: FAIL — `LessonPage` not found

- [ ] **Step 3: Implement `LessonPage`**

Create `lib/features/lesson/presentation/lesson_page.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LessonPage extends ConsumerWidget {
  const LessonPage({required this.lessonId, this.examId, super.key});

  final LessonId lessonId;
  final String? examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLesson = ref.watch(lessonByIdProvider(lessonId));

    return Scaffold(
      appBar: AppBar(),
      body: asyncLesson.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.refresh(lessonByIdProvider(lessonId)),
          ),
        ),
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Lesson not found.'));
          }
          return _LessonBody(lesson: lesson, examId: examId);
        },
      ),
    );
  }
}

class _LessonBody extends StatelessWidget {
  const _LessonBody({required this.lesson, this.examId});

  final Lesson lesson;
  final String? examId;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lesson.title, style: textStyles.displaySmall),
          const SizedBox(height: 8),
          PortableTextRenderer(blocks: lesson.bodyJson),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: colors.onSurfaceMuted),
              const SizedBox(width: 4),
              Text(
                '${lesson.estimatedMinutes} min read',
                style: textStyles.bodySmall
                    .copyWith(color: colors.onSurfaceMuted),
              ),
            ],
          ),
          if (examId != null) ...[
            const SizedBox(height: 16),
            AppButton(
              label: 'Quiz this topic',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/quiz/quick/$examId'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 28, width: 240),
          SizedBox(height: 16),
          SkeletonBox(height: 14, width: double.infinity),
          SizedBox(height: 8),
          SkeletonBox(height: 14, width: double.infinity),
          SizedBox(height: 8),
          SkeletonBox(height: 14, width: 180),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/lesson/presentation/lesson_page_test.dart -v`
Expected: all PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/lesson/presentation/lesson_page.dart \
        test/features/lesson/presentation/lesson_page_test.dart
git commit -m "feat(lesson): add LessonPage"
```

---

## Task 11: `LessonListPage` (TDD widget test)

**Files:**
- Create: `lib/features/lesson/presentation/lesson_list_page.dart`
- Create: `test/features/lesson/presentation/lesson_list_page_test.dart`

- [ ] **Step 1: Write failing widget test**

Create `test/features/lesson/presentation/lesson_list_page_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_list_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  Future<void> seedLesson(AppDatabase db, String id, String title) async {
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: id,
            topicId: 't1',
            title: title,
            summary: 'Summary for $title',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 3,
          ),
        );
  }

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('shows lesson titles for the topic', (tester) async {
    await seedLesson(db, 'l1', 'Synonyms');
    await seedLesson(db, 'l2', 'Antonyms');

    await tester.pumpAppWithProviders(
      const LessonListPage(topicId: 't1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Synonyms'), findsOneWidget);
    expect(find.text('Antonyms'), findsOneWidget);
  });

  testWidgets('shows empty state when topic has no lessons', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonListPage(topicId: 't1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('No lessons yet for this topic'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/lesson/presentation/lesson_list_page_test.dart -v`
Expected: FAIL — `LessonListPage` not found

- [ ] **Step 3: Implement `LessonListPage`**

Create `lib/features/lesson/presentation/lesson_list_page.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LessonListPage extends ConsumerWidget {
  const LessonListPage({required this.topicId, this.examId, super.key});

  final TopicId topicId;
  final String? examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTopic = ref.watch(topicByIdProvider(topicId));
    final asyncLessons = ref.watch(topicLessonsProvider(topicId));

    final title = asyncTopic.maybeWhen(
      data: (t) => t?.name ?? 'Lessons',
      orElse: () => 'Lessons',
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: asyncLessons.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
          ),
        ),
        data: (lessons) {
          if (lessons.isEmpty) {
            return _EmptyState(examId: examId);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _LessonCard(lesson: lessons[i], examId: examId),
          );
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, this.examId});

  final Lesson lesson;
  final String? examId;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final examParam = examId != null ? '?examId=$examId' : '';

    return GestureDetector(
      onTap: () =>
          context.push('/lesson/${lesson.id}$examParam'),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.title, style: textStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(
              lesson.summary,
              style:
                  textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${lesson.estimatedMinutes} min read',
              style:
                  textStyles.labelSmall.copyWith(color: colors.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.examId});
  final String? examId;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No lessons yet for this topic',
            style:
                textStyles.bodyLarge.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
          if (examId != null) ...[
            const SizedBox(height: 16),
            AppButton(
              label: 'Try a quick quiz instead',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/quiz/quick/$examId'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonCard(),
          SizedBox(height: 12),
          SkeletonCard(),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/lesson/presentation/lesson_list_page_test.dart -v`
Expected: all PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/lesson/presentation/lesson_list_page.dart \
        test/features/lesson/presentation/lesson_list_page_test.dart
git commit -m "feat(lesson): add LessonListPage"
```

---

## Task 12: `LearnTabHome` (TDD widget test)

**Files:**
- Create: `lib/features/lesson/presentation/learn_tab_home.dart`
- Create: `test/features/lesson/presentation/learn_tab_home_test.dart`

- [ ] **Step 1: Write failing widget test**

Create `test/features/lesson/presentation/learn_tab_home_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/learn_tab_home.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e2',
            code: 'UPCAT',
            name: 'UPCAT',
            shortName: 'UPCAT',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('shows exam names from seeded database', (tester) async {
    await tester.pumpAppWithProviders(
      const LearnTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Civil Service Exam'), findsOneWidget);
    expect(find.text('UPCAT'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/lesson/presentation/learn_tab_home_test.dart -v`
Expected: FAIL — `LearnTabHome` not found

- [ ] **Step 3: Implement `LearnTabHome`**

Create `lib/features/lesson/presentation/learn_tab_home.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LearnTabHome extends ConsumerWidget {
  const LearnTabHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExams = ref.watch(examListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: asyncExams.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child:
              ErrorBanner(variant: ErrorBannerVariant.error, message: e.toString()),
        ),
        data: (exams) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: exams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _ExamAccordion(exam: exams[i]),
        ),
      ),
    );
  }
}

class _ExamAccordion extends ConsumerWidget {
  const _ExamAccordion({required this.exam});
  final Exam exam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(exam.name, style: textStyles.headlineSmall),
        subtitle: Text(
          exam.shortName,
          style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
        ),
        children: [
          for (final subject in exam.subjects)
            _SubjectExpansion(subject: subject, examId: exam.id),
        ],
      ),
    );
  }
}

class _SubjectExpansion extends ConsumerWidget {
  const _SubjectExpansion({required this.subject, required this.examId});
  final Subject subject;
  final ExamId examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTopics = ref.watch(topicsBySubjectProvider(subject.id));
    final textStyles = context.textStyles;

    return ExpansionTile(
      title: Text(subject.name, style: textStyles.bodyLarge),
      children: [
        asyncTopics.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
          ),
          data: (topics) => Column(
            children: [
              for (final topic in topics)
                ListTile(
                  title: Text(topic.name, style: textStyles.bodyMedium),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    '/learn/topic/${topic.id}?examId=$examId',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonCard(),
          SizedBox(height: 8),
          SkeletonCard(),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/lesson/presentation/learn_tab_home_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/lesson/presentation/learn_tab_home.dart \
        test/features/lesson/presentation/learn_tab_home_test.dart
git commit -m "feat(lesson): add LearnTabHome with two-level accordion"
```

---

## Task 13: Wire router, update `QuizTabHome`, create barrel file

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Create: `lib/features/lesson/lesson.dart`

- [ ] **Step 1: Update `router.dart`**

In `lib/app/router.dart`, add these imports:
```dart
import 'package:cse_cet_reviewer/features/lesson/presentation/learn_tab_home.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_list_page.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
```

Replace the `/learn` branch:
```dart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (_, __) => const LearnTabHome(),
                routes: [
                  GoRoute(
                    path: 'topic/:topicId',
                    builder: (_, state) => LessonListPage(
                      topicId: state.pathParameters['topicId']!,
                      examId: state.uri.queryParameters['examId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
```

Replace the existing `/lesson` top-level route (currently a stub):
```dart
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (_, state) => LessonPage(
          lessonId: state.pathParameters['lessonId']!,
          examId: state.uri.queryParameters['examId'],
        ),
      ),
```

- [ ] **Step 2: Add "Browse Lessons" CTA to `QuizTabHome`**

In `lib/features/quiz/presentation/quiz_tab_home.dart`, update the `_ExamCard.build` method to add an `AppButton` for "Browse Lessons" below "Start Quick Quiz":

```dart
  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exam.name,
            style: textStyles.headlineSmall.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            exam.shortName,
            style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Start Quick Quiz',
            onPressed: () => context.go('/quiz/quick/${exam.id}'),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Browse Lessons',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/learn'),
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 3: Create `lesson.dart` barrel**

Create `lib/features/lesson/lesson.dart`:

```dart
export 'domain/use_cases/get_lesson.dart';
export 'domain/use_cases/get_topic_lessons.dart';
export 'presentation/learn_tab_home.dart';
export 'presentation/lesson_list_page.dart';
export 'presentation/lesson_page.dart';
```

- [ ] **Step 4: Run analysis and full test suite**

Run: `flutter analyze lib/`
Expected: no errors

Run: `flutter test`
Expected: all tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/router.dart \
        lib/features/quiz/presentation/quiz_tab_home.dart \
        lib/features/lesson/lesson.dart
git commit -m "feat(lesson): wire lesson routes, add Browse Lessons CTA, create lesson barrel"
```

---

## Self-Review

**Spec coverage check:**

| Spec requirement | Task |
|---|---|
| `PortableTextRenderer` — block, h1–h6, blockquote | Task 6 |
| `PortableTextRenderer` — inline LaTeX span | Task 7 |
| `PortableTextRenderer` — `latex` block (display mode) | Task 8 |
| `PortableTextRenderer` — `image` block (CachedNetworkImage) | Task 9 |
| `PortableTextRenderer` — unknown block → placeholder | Task 6 |
| Malformed LaTeX → placeholder, no throw | Tasks 7 & 8 |
| `GetLesson` use case | Task 4 |
| `GetTopicLessons` use case | Task 5 |
| `ContentRepository.lessonById()` | Task 2 |
| `ContentRepository.topicById()` | Task 2 |
| `LearnTabHome` — exam → subject → topic accordion | Task 12 |
| `LessonListPage` — list + empty state | Task 11 |
| `LessonPage` — title, body, read time, quiz CTA | Task 10 |
| `/learn/topic/:topicId` route | Task 13 |
| `/lesson/:lessonId` route | Task 13 |
| `examId` threaded as query param | Tasks 10, 11, 12, 13 |
| `examListProvider` moved to `storage.dart` | Task 3 |
| `QuizTabHome` "Browse Lessons" CTA | Task 13 |
| `cached_network_image` dependency | Task 1 |
| Unit tests for use cases | Tasks 4 & 5 |
| Widget tests with seeded in-memory DB | Tasks 10, 11, 12 |

**Placeholder scan:** No TBD/TODO/similar steps found. All code blocks are complete.

**Type consistency:** `LessonId`, `TopicId`, `SubjectId` are all `typedef String` from `ids.dart`. `lessonByIdProvider` returns `Lesson?` (matching `ContentRepository.lessonById()` return type). `topicLessonsProvider` returns `List<Lesson>`. Provider names match usage in all pages.
