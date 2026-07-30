import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/lesson_contents_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpSheet(
    WidgetTester tester, {
    void Function(String lessonId)? onSelectLesson,
  }) async {
    const dummyLesson = Lesson(
      id: 'l1',
      topicId: 't1',
      title: 'Lesson 1',
      summary: 'Summary',
      bodyJson: [],
      estimatedMinutes: 10,
    );

    const readerContext = ReaderContext(
      lesson: dummyLesson,
      topicId: 't1',
      topicName: 'Chemistry',
      next: StudyLesson(
        id: 'l2',
        title: 'Lesson 2',
        estimatedMinutes: 10,
        isRead: false,
        isBookmarked: false,
      ),
      positionInTopic: 1,
      lessonsInTopic: 3,
      topicLessons: [
        StudyLesson(
          id: 'l1',
          title: 'Lesson 1',
          estimatedMinutes: 10,
          isRead: false,
          isBookmarked: false,
        ),
        StudyLesson(
          id: 'l2',
          title: 'Lesson 2',
          estimatedMinutes: 10,
          isRead: true,
          isBookmarked: false,
        ),
        StudyLesson(
          id: 'l3',
          title: 'Lesson 3',
          estimatedMinutes: 10,
          isRead: false,
          isBookmarked: false,
        ),
      ],
      isRead: false,
      isBookmarked: false,
      examId: 'e1',
    );

    await tester.pumpApp(
      Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              showLessonContentsSheet(
                context,
                reader: readerContext,
                onSelectLesson: onSelectLesson,
              );
            },
            child: const Text('Open Sheet'),
          );
        },
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();
  }

  testWidgets('the sheet ticks what is read and marks what is open',
      (tester) async {
    await pumpSheet(tester);

    expect(find.text('✓'), findsOneWidget);
    expect(find.text('reading'), findsOneWidget);
  });

  testWidgets('tapping a lesson in the sheet opens it', (tester) async {
    String? selectedId;
    await pumpSheet(tester, onSelectLesson: (id) => selectedId = id);

    await tester.tap(find.text('Lesson 3'));
    await tester.pumpAndSettle();

    expect(selectedId, 'l3');
  });
}
