import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_telemetry.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  Future<void> seedLesson(AppDatabase db) async {
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
      bodyJson: jsonEncode(<Map<String, Object?>>[
        {
          '_type': 'block',
          'style': 'normal',
          'children': <Map<String, Object?>>[
            {'_type': 'span', 'text': 'Study hard.', 'marks': <String>[]},
          ],
        },
      ]),
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'question_l1',
      topicId: 't1',
      examId: 'e1',
      lessonId: 'l1',
    );
  }

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedLesson(db);
  });

  tearDown(() => db.close());

  // There is no mark-as-read button any more, deliberately. With one, every
  // coverage figure in the app counted button presses rather than lessons
  // whose end was actually reached. Read marking is driven by scroll position
  // now, and `read_marking_test.dart` covers the rule itself.
  testWidgets('an unread lesson offers no way to declare itself read',
      (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark as read'), findsNothing);
    expect(find.text('Read'), findsNothing);
  });

  testWidgets('a read lesson shows only the drawn Read line', (tester) async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'l1',
            readAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('marked automatically'), findsNothing);
    expect(find.text('Mark as read'), findsNothing);
  });

  group('study-loop events', () {
    Future<RecordingTelemetry> openLesson(
      WidgetTester tester, {
      required bool consent,
    }) async {
      final sink = RecordingTelemetry();
      await tester.pumpAppWithProviders(
        const LessonPage(lessonId: 'l1'),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          telemetrySinkProvider.overrideWithValue(sink),
          effectiveTelemetryConsentProvider.overrideWithValue(consent),
        ],
      );
      await tester.pumpAndSettle();
      return sink;
    }

    testWidgets('opening a lesson logs lesson_open once, with no lesson id',
        (tester) async {
      final sink = await openLesson(tester, consent: true);

      expect(sink.events, [TelemetryEvent.lessonOpen]);
      expect(sink.logged.single.$2, {'exam_id': 'e1', 'kind': 'study'});
    });

    testWidgets('reaching the end after the dwell time logs lesson_finish once',
        (tester) async {
      final sink = await openLesson(tester, consent: true);

      await tester.pump(readDwellFloor + const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(
        sink.events,
        [TelemetryEvent.lessonOpen, TelemetryEvent.lessonFinish],
      );
      expect(sink.logged.last.$2, {'exam_id': 'e1', 'kind': 'study'});
    });

    testWidgets('nothing is sent while usage sharing is off', (tester) async {
      final sink = await openLesson(tester, consent: false);
      await tester.pump(readDwellFloor + const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(sink.logged, isEmpty);
    });
  });
}
