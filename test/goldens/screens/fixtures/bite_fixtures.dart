// Sample data for the bite-sized label sheets: the board's Philippine
// Constitution topic, with a split lesson ("Part 2 of 9") and an unsplit one.
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';
import 'package:pantas/features/quiz/application/quiz_starts.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../../../helpers/in_memory_database.dart';
import '../screen_harness.dart';

/// One lesson of the sample topic: title, part (null when not split) and the
/// number of questions its quiz serves.
typedef BiteLesson = ({
  String id,
  String title,
  int? part,
  int questions,
});

const int biteParts = 9;

const List<BiteLesson> biteLessons = [
  (id: 'l1', title: 'The 1987 Constitution', part: null, questions: 5),
  (id: 'l2', title: 'Bill of Rights: overview', part: 1, questions: 3),
  (id: 'l3', title: 'Bill of Rights: searches', part: 2, questions: 3),
  (
    id: 'l4',
    title: 'Bill of Rights: privacy of communication',
    part: 3,
    questions: 4,
  ),
  (
    id: 'l5',
    title: 'Bill of Rights: freedom of religion',
    part: 4,
    questions: 2
  ),
  (
    id: 'l6',
    title: 'Bill of Rights: rights of the accused',
    part: 5,
    questions: 6,
  ),
];

/// Search results for "bill of rights", with the split lessons' part and a
/// topic line.
List<LessonSearchHit> get biteSearchHits => [
      for (final l in biteLessons.where((l) => l.title.startsWith('Bill')))
        LessonSearchHit(
          lessonId: l.id,
          title: l.title,
          topicName: 'Philippine Constitution',
          part: l.part,
          partCount: biteParts,
          titleMatch: SearchSnippet(
            text: l.title,
            matchStart: 0,
            matchLength: 'Bill of Rights'.length,
          ),
        ),
    ];

/// The count the quiz serves, for each lesson, without a database.
List<Override> biteCountOverrides() => [
      lessonQuizCountProvider.overrideWith(
        (ref, id) async =>
            biteLessons.where((l) => l.id == id).firstOrNull?.questions ?? 0,
      ),
    ];

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
        'seizures. A judge must issue a warrant, and the warrant must name '
        'the place and the things to be taken.',
      ),
      _text(
        'A police officer may search without a warrant in a few cases only. '
        'Each one is an exception, and the state must prove it.',
      ),
      _text('Key Points', style: 'h2'),
      _text(
        'A warrant needs probable cause. The judge decides it, after '
        'questioning the people who swear to it.',
      ),
    ]);

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
    topicId: 't1',
    subjectId: 's1',
    name: 'Philippine Constitution',
  );
  var order = 1;
  for (final lesson in biteLessons) {
    await seedContentLesson(
      contentDb,
      lessonId: lesson.id,
      topicId: 't1',
      title: lesson.title,
      summary: 'The Bill of Rights',
      bodyJson: _body(),
      ordering: order++,
      part: lesson.part,
      partCount: lesson.part == null ? null : biteParts,
      quizSize: lesson.questions,
    );
    for (var i = 0; i < lesson.questions; i++) {
      await seedContentQuestion(
        contentDb,
        questionId: 'q_${lesson.id}_$i',
        topicId: 't1',
        examId: 'e1',
        lessonId: lesson.id,
      );
    }
  }
  await AppPreferencesRepository(db).setSelectedExamId('e1');
}

/// Pumps a seeded screen in the real theme, light or dark.
Future<Finder> pumpBiteScreen(
  WidgetTester tester,
  double width,
  Widget page, {
  bool dark = false,
  bool shell = false,
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
  return target;
}
