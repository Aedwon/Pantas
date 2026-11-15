import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/quiz/application/quiz_starts.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  Future<int> countFor({
    required int poolSize,
    required int quizSize,
    String lessonId = 'lesson',
    bool noExam = false,
  }) async {
    final contentDb = ContentDatabase(NativeDatabase.memory());
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'exam',
      topicId: 'topic',
      topicName: 'Topic',
      questionIds: [
        for (var i = 0; i < poolSize; i++) 'own$i',
        for (var i = 0; i < 20; i++) 'other$i',
      ],
      lessonIds: const ['lesson', 'sibling'],
      questionLessonMap: {
        for (var i = 0; i < poolSize; i++) 'own$i': 'lesson',
        for (var i = 0; i < 20; i++) 'other$i': 'sibling',
      },
      lessonQuizSizes: {'lesson': quizSize},
    );
    final container = ProviderContainer(
      overrides: [
        contentDatabaseProvider.overrideWithValue(contentDb),
        activeExamFocusProvider.overrideWith(
          (_) async => noExam
              ? const ActiveExamFocus.needsSelection()
              : const ActiveExamFocus.selected(
                  Exam(
                    id: 'exam',
                    code: 'exam',
                    name: 'Exam',
                    shortName: 'Exam',
                    language: 'en',
                    isActive: true,
                    subjects: [],
                  ),
                ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container.read(lessonQuizCountProvider(lessonId).future);
  }

  test('shows the lesson quiz size when the pool is large enough', () async {
    expect(await countFor(poolSize: 12, quizSize: 4), 4);
    expect(await countFor(poolSize: 12, quizSize: 6), 6);
  });

  test('unsplit lesson shows 5', () async {
    expect(await countFor(poolSize: 12, quizSize: 5), 5);
  });

  test('short pool shows the pool size', () async {
    expect(await countFor(poolSize: 3, quizSize: 5), 3);
  });

  test('no questions or unknown lesson shows 0', () async {
    expect(await countFor(poolSize: 0, quizSize: 4), 0);
    expect(await countFor(poolSize: 8, quizSize: 4, lessonId: 'nope'), 0);
  });

  test('no active exam shows 0', () async {
    expect(await countFor(poolSize: 8, quizSize: 4, noExam: true), 0);
  });
}
