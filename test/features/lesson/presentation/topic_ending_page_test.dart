import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/bookmark_ribbon.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/core/ui/components/ink_table_row.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/domain/use_cases/decide_ending.dart';
import 'package:pantas/features/lesson/presentation/pages/topic_ending_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookplate.dart';
import 'package:pantas/features/lesson/presentation/widgets/pull_to_advance.dart';

import '../../../helpers/pump_app.dart';

void main() {
  StudyLesson makeLesson({
    required String id,
    required String title,
    int estimatedMinutes = 10,
    bool isRead = true,
  }) {
    return StudyLesson(
      id: id,
      title: title,
      estimatedMinutes: estimatedMinutes,
      isRead: isRead,
      isBookmarked: false,
    );
  }

  StudyTopic topicWith({
    required int read,
    required int total,
    String name = 'Arithmetic & Number Sense',
  }) {
    final lessons = List.generate(
      total,
      (i) => makeLesson(
        id: 'l${i + 1}',
        title: 'Lesson ${i + 1}',
        isRead: i < read,
      ),
    );
    return StudyTopic(
      id: 't1',
      name: name,
      lessons: lessons,
      readCount: read,
      hasBookmark: false,
    );
  }

  const mathematics = StudySubject(
    id: 'math',
    name: 'Mathematics',
    topics: [],
  );

  final geometry = StudyTopic(
    id: 't2',
    name: 'Geometry',
    lessons: List.generate(
      8,
      (i) => makeLesson(
        id: 'g${i + 1}',
        title: 'Geometry Lesson ${i + 1}',
        estimatedMinutes: 12,
        isRead: false,
      ),
    ),
    readCount: 0,
    hasBookmark: false,
  );

  Future<void> pumpEnding(
    WidgetTester tester, {
    required int read,
    required int total,
  }) async {
    final topic = topicWith(read: read, total: total);
    final ending = decideEnding(
      topic: topic,
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: 'Aedwon',
      today: DateTime(2026, 7, 27),
      nextTopic: geometry,
    );

    await tester.pumpAppWithProviders(
      TopicEndingPage(
        topicId: topic.id,
        ending: ending,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpDayEnding(WidgetTester tester) async {
    await tester.pumpAppWithProviders(
      const TopicEndingPage(
        topicId: 't1',
        ending: DayFinished(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a finished topic shows the plate and what is next',
      (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.byType(Bookplate), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Geometry'), findsOneWidget);
  });

  testWidgets('a topic stopped short lists what is unread', (tester) async {
    await pumpEnding(tester, read: 6, total: 9);

    expect(find.text('Still unread'), findsOneWidget);
    expect(find.byType(InkTableRow), findsNWidgets(3));
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('the closing page cannot be pulled onward', (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.byType(PullToAdvance), findsNothing);
  });

  testWidgets('the bar carries a back control and nothing else',
      (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.byType(BookmarkRibbon), findsNothing);
    expect(find.byType(ContentsGlyph), findsNothing);
  });

  testWidgets('the exit is a ruled row, not a filled button', (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.text('Back to Study'), findsOneWidget);
    expect(find.byType(BoardButton), findsNothing);
  });

  testWidgets('the exit row meets the tap target', (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(
      tester.getSize(find.byKey(const ValueKey('ending-exit'))).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('a finished day is one line and nothing else', (tester) async {
    await pumpDayEnding(tester);

    expect(find.text("That's enough for today."), findsOneWidget);
    expect(find.byType(Bookplate), findsNothing);
    expect(find.textContaining('lesson'), findsNothing);
    expect(find.textContaining('min'), findsNothing);
  });

  testWidgets('the day line keeps its contraction', (tester) async {
    await pumpDayEnding(tester);

    expect(find.text('That is enough for today.'), findsNothing);
  });
}
