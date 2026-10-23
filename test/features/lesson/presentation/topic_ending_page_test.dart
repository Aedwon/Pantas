import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/bookmark_ribbon.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/domain/use_cases/decide_ending.dart';
import 'package:pantas/features/lesson/presentation/pages/topic_ending_page.dart';
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
    bool terminal = false,
  }) async {
    final topic = topicWith(read: read, total: total);
    final ending = decideEnding(
      topic: topic,
      subject: mathematics,
      examShortName: 'UPCAT',
      studentName: 'Aedwon',
      today: DateTime(2026, 7, 27),
      nextTopic: terminal ? null : geometry,
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

  testWidgets('a finished topic shows the nameless plate and actual totals',
      (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.byKey(const ValueKey('ending-plate')), findsOneWidget);
    expect(find.text('9 lessons, all read'), findsOneWidget);
    expect(find.text('Aedwon'), findsNothing);
  });

  testWidgets('a topic stopped short lists what is unread', (tester) async {
    await pumpEnding(tester, read: 6, total: 9);

    expect(find.text('STILL UNREAD'), findsOneWidget);
    expect(find.byType(ListRow), findsNWidgets(3));
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('the terminal topic plate has no onward pull', (tester) async {
    await pumpEnding(tester, read: 9, total: 9, terminal: true);

    expect(find.byType(PullToAdvance), findsNothing);
  });

  testWidgets('the bar carries a back control and nothing else',
      (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.byType(BookmarkRibbon), findsNothing);
    expect(find.byType(ContentsGlyph), findsNothing);
  });

  testWidgets('topic exit uses only the drawn toolbar back control',
      (tester) async {
    await pumpEnding(tester, read: 9, total: 9);

    expect(find.text('Study'), findsOneWidget);
    expect(find.text('Back to Study'), findsNothing);
    expect(find.byKey(const ValueKey('ending-exit')), findsNothing);
  });

  testWidgets('the day exit meets the tap target', (tester) async {
    await pumpDayEnding(tester);

    expect(
      tester.getSize(find.byKey(const ValueKey('ending-exit'))).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('a finished day is one line and nothing else', (tester) async {
    await pumpDayEnding(tester);

    expect(find.text("That's enough for today."), findsOneWidget);
    expect(find.byKey(const ValueKey('ending-plate')), findsNothing);
    expect(find.textContaining('lesson'), findsNothing);
    expect(find.textContaining('min'), findsNothing);
  });

  testWidgets('the day line keeps its contraction', (tester) async {
    await pumpDayEnding(tester);

    expect(find.text('That is enough for today.'), findsNothing);
  });
}
