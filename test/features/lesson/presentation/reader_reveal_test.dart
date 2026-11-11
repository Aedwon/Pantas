import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/pull_to_advance.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_rail.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

Map<String, Object?> _block(
  String text, {
  String style = 'normal',
  String? list,
  bool strong = false,
}) =>
    {
      '_type': 'block',
      'style': style,
      'children': [
        {
          '_type': 'span',
          'text': text,
          'marks': [if (strong) 'strong'],
        },
      ],
      if (list != null) 'listItem': list,
    };

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  // A lesson long enough to scroll, ending in an example whose solution is
  // tall, so opening it moves the end of the page a long way.
  final body = <Map<String, Object?>>[
    _block('Core Concept', style: 'h2'),
    for (var i = 0; i < 30; i++) _block('Paragraph $i of the lesson text.'),
    _block('Examples', style: 'h2'),
    _block('#1: The last example', style: 'h3'),
    _block('What is the answer?'),
    _block('Solution:', strong: true),
    for (var i = 1; i <= 12; i++)
      _block('Step number $i of the answer.', list: 'number'),
  ];

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Verbal',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l1',
      topicId: 't1',
      title: 'Vocabulary Basics',
      summary: 'Core vocab',
      bodyJson: jsonEncode(body),
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'question_l1',
      topicId: 't1',
      examId: 'e1',
      lessonId: 'l1',
    );
  });

  tearDown(() => db.close());

  testWidgets(
      'opening a solution at the end of a lesson moves the progress bar and '
      'the pull-to-advance end check with the page', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    // The page settles its own length once it has drawn, so go to the end
    // twice.
    for (var i = 0; i < 2; i++) {
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pumpAndSettle();
    }
    final extentBefore = scrollable.position.maxScrollExtent;

    double progress() =>
        tester.widget<ReaderRail>(find.byType(ReaderRail)).progress;
    bool atEnd() =>
        tester.widget<PullToAdvance>(find.byType(PullToAdvance)).isAtEnd.value;
    expect(progress(), 1);
    expect(atEnd(), isTrue);

    await tester.tap(find.text('Show solution'));
    await tester.pumpAndSettle();

    expect(find.text('Step number 12 of the answer.'), findsOneWidget);
    expect(scrollable.position.maxScrollExtent, greaterThan(extentBefore));
    // The student is no longer at the end, and the bar says so.
    expect(progress(), lessThan(1));
    expect(atEnd(), isFalse);
    // The scroll position itself did not move.
    expect(scrollable.position.pixels, extentBefore);

    // Scrolling to the new end brings both back.
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(progress(), 1);
    expect(atEnd(), isTrue);
  });
}
