// PROTOTYPE fixtures for the bite-sized lessons visual companion. Not for merge.
//
// One topic, "Philippine Constitution" (the pilot topic). The Bill of Rights
// is nine lessons here; the "before" renders show them with today's typed-in
// minutes and the "after" renders show the proposed label.
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/bite_label.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../../../helpers/in_memory_database.dart';
import '../screen_harness.dart';

/// "before" renders today's label. "after" renders the proposal.
const String biteVariant =
    String.fromEnvironment('BITE', defaultValue: 'before');

/// The pilot lessons: nine parts of the Bill of Rights and one lesson that is
/// not yet split. Questions are the real quiz counts (2 to 6).
const List<(String, String, int)> biteLessons = [
  ('bor-1', 'Bill of Rights: overview', 4),
  ('bor-2', 'Bill of Rights: due process and equal protection', 3),
  ('bor-3', 'Bill of Rights: searches', 5),
  ('bor-4', 'Bill of Rights: privacy of communication', 4),
  ('bor-5', 'Bill of Rights: freedom of expression', 2),
  ('bor-6', 'Bill of Rights: freedom of religion', 6),
  ('bor-7', 'Bill of Rights: rights of the accused', 4),
  ('bor-8', 'Bill of Rights: rights in detention', 3),
  ('bor-9', 'Bill of Rights: writs and remedies', 5),
  ('outline', 'The Articles in Outline', 5),
];

/// The authored minutes every pilot lesson carries today.
const int biteTodayMinutes = 10;

/// Sets the label table for the variant under test.
void configureBite() {
  BiteLabels.enabled = biteVariant == 'after';
  BiteLabels.lessons = {
    for (var i = 0; i < 9; i++)
      biteLessons[i].$1: BitePart(
        part: i + 1,
        partCount: 9,
        questions: biteLessons[i].$3,
      ),
    // Not yet split: no part, keeps 5 questions.
    'outline': const BitePart(questions: 5),
  };
}

Map<String, Object?> _text(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text, 'marks': <String>[]},
      ],
    };

String _body() => jsonEncode([
      _text('Core Concept', style: 'h2'),
      _text(
        'Section 2 protects the people against unreasonable searches and '
                'seizures. A judge must personally find probable cause before a '
                'warrant issues. ' *
            3,
      ),
      _text('Key Points', style: 'h2'),
      _text(
        'The warrant must name the place to be searched and the things to be '
        'seized. Evidence taken in breach of this section cannot be used.',
      ),
    ]);

/// The lessons as the Study map models them, for widgets that take models.
List<StudyLesson> biteStudyLessons({int read = 1}) => [
      for (var i = 0; i < biteLessons.length; i++)
        StudyLesson(
          id: biteLessons[i].$1,
          title: biteLessons[i].$2,
          estimatedMinutes: biteTodayMinutes,
          isRead: i < read,
          isBookmarked: false,
        ),
    ];

Future<void> seedBite(AppDatabase db, ContentDatabase contentDb) async {
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
    name: 'General Information',
  );
  await seedContentTopic(
    contentDb,
    topicId: 'tpc',
    subjectId: 's1',
    name: 'Philippine Constitution',
  );
  for (var i = 0; i < biteLessons.length; i++) {
    final (id, title, _) = biteLessons[i];
    await seedContentLesson(
      contentDb,
      lessonId: id,
      topicId: 'tpc',
      title: title,
      summary: 'Philippine Constitution',
      bodyJson: _body(),
      estimatedMinutes: biteTodayMinutes,
      ordering: i + 1,
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'question_$id',
      topicId: 'tpc',
      examId: 'e1',
      lessonId: id,
    );
  }
  await AppPreferencesRepository(db).setSelectedExamId('e1');
  await LessonProgressRepository(db, contentDb).markRead('bor-1');
}

/// Pumps a seeded screen at [width] in the chosen theme.
Future<Finder> pumpBiteScreen(
  WidgetTester tester,
  double width,
  Widget page, {
  required bool dark,
  bool shell = false,
  Future<void> Function(WidgetTester)? after,
}) async {
  final db = inMemoryDatabase();
  final contentDb = openTestContentDatabase();
  await tester.runAsync(() => seedBite(db, contentDb));
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
    ],
    dark: dark,
    router: true,
    appTextScale: true,
    frames: 1,
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await settleFrames(tester, 8);
  if (after != null) {
    await after(tester);
    await settleFrames(tester, 8);
  }
  return target;
}
