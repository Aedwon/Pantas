// Fake data for the Study list and the reader, lifted from
// test/features/lesson/presentation/study_reader_ds_matrix_test.dart.
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../../../helpers/in_memory_database.dart';
import '../screen_harness.dart';

Map<String, Object?> _text(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text, 'marks': <String>[]},
      ],
    };

String _body() => jsonEncode([
      _text('Core Concept', style: 'h2'),
      _text('A fraction names a part of a whole. ' * 6),
      {'_type': 'latex', 'body': r'\dfrac{1}{2}+\dfrac{1}{3}=\dfrac{5}{6}'},
      _text('Mnemonics', style: 'h2'),
      {
        ..._text('Bottoms must match before you add.'),
        'style': 'blockquote',
      },
      _text('Traps to Watch For', style: 'h2'),
      {
        ..._text('Do not add the bottoms together.'),
        'style': 'blockquote',
      },
    ]);

/// Seeds one exam, one subject, one topic and two lessons, and selects the
/// exam.
Future<void> seedStudy(AppDatabase db, ContentDatabase contentDb) async {
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
    name: 'Mathematics',
  );
  await seedContentTopic(
    contentDb,
    topicId: 't1',
    subjectId: 's1',
    name: 'Fractions',
  );
  for (final (id, title, order) in [
    ('l1', 'Adding Fractions with Unlike Denominators', 1),
    ('l2', 'Subtracting Fractions', 2),
  ]) {
    await seedContentLesson(
      contentDb,
      lessonId: id,
      topicId: 't1',
      title: title,
      summary: 'Fractions',
      bodyJson: _body(),
      estimatedMinutes: 8,
      ordering: order,
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'question_$id',
      topicId: 't1',
      examId: 'e1',
      lessonId: id,
    );
  }
  await AppPreferencesRepository(db).setSelectedExamId('e1');
}

/// Pumps a seeded study screen. The stores answer on real time, so the
/// providers get a moment before the fixed frames run.
Future<Finder> pumpStudyScreen(
  WidgetTester tester,
  double width,
  Widget page, {
  bool shell = false,
  List<Override> overrides = const [],
}) async {
  final db = inMemoryDatabase();
  final contentDb = openTestContentDatabase();
  await tester.runAsync(() => seedStudy(db, contentDb));
  afterCapture(() async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    await tester.runAsync(() async {
      await db.close();
      await contentDb.close();
    });
  });
  final target = await pumpScreen(
    tester,
    width,
    scaffolded(
      shell && width >= 1024
          ? WebShellFrame(
              activeIndex: 1,
              person: 'Student',
              exam: 'CSE',
              plan: 'Free',
              web: true,
              onNavigate: (_) {},
              onSearch: () {},
              child: page,
            )
          : page,
    ),
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      contentDatabaseProvider.overrideWithValue(contentDb),
      ...overrides,
    ],
    router: true,
    appTextScale: true,
    frames: 1,
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await settleFrames(tester, 8);
  return target;
}
