import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/presentation/assessment_page.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';

import '../../../helpers/in_memory_database.dart';

/// Fifth sweep, assessment question page: 5R-1 and 5R-4.
void main() {
  late AppDatabase db;
  late ContentDatabase content;
  setUp(() async {
    debugWebPlatformOverride = true;
    db = inMemoryDatabase();
    content = inMemoryContentDatabase();
    await seedContentExam(content, examId: 'e', code: 'CSE', name: 'CSE Pro');
    await seedContentSubject(
      content,
      subjectId: 's',
      examId: 'e',
      name: 'Verbal',
    );
    await seedContentTopic(
      content,
      topicId: 't',
      subjectId: 's',
      name: 'Vocabulary',
    );
    for (final id in ['q1', 'q2']) {
      await seedContentQuestion(
        content,
        questionId: id,
        topicId: 't',
        examId: 'e',
        stem: 'Question $id?',
        correctText: 'Right $id',
        wrongText: 'Wrong $id',
      );
    }
  });
  tearDown(() async {
    debugWebPlatformOverride = null;
    await db.close();
    await content.close();
  });

  Future<void> pump(WidgetTester tester, {bool dark = false}) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/assessment/e',
      routes: [
        GoRoute(
          path: '/assessment/:examId',
          builder: (_, state) =>
              AssessmentPage(examId: state.pathParameters['examId']!),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
        ],
        child: MaterialApp.router(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          routerConfig: router,
        ),
      ),
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    testWidgets('5R-1: the title is centered on the page, dark=$dark',
        (tester) async {
      await pump(tester, dark: dark);
      final title = tester.getRect(find.textContaining('Assessment ·'));
      expect(title.center.dx, closeTo(720, .5));
      // The ends sit where the quiz puts them.
      expect(tester.getCenter(find.byTooltip('Leave assessment')).dx, 42);
      expect(tester.getCenter(find.byTooltip('Report')).dx, 1440 - 42);
    });
  }

  testWidgets('5R-4: the next question opens with no choice focused',
      (tester) async {
    await pump(tester);
    bool onChoice() =>
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<WebAnswerOption>() !=
        null;
    final first = find.byType(WebAnswerOption).first;
    await tester.tap(first);
    Focus.of(
      tester.element(
        find.descendant(of: first, matching: find.byType(Text)).first,
      ),
    ).requestFocus();
    await tester.pump();
    expect(onChoice(), isTrue, reason: 'the picked choice holds focus');
    expect(find.text('1 of 2'), findsOneWidget);
    // Enter on a picked choice goes to the next question.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('2 of 2'), findsOneWidget);
    expect(onChoice(), isFalse);
    // The page's keys still answer.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.pump();
    expect(find.text('Finish'), findsOneWidget);
  });

  testWidgets('5S-3: letters A to E each pick their choice', (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const question = Question(
      id: 'q',
      version: 1,
      examIds: ['e'],
      language: 'en',
      topicId: 't',
      stem: 'Five choices?',
      explanation: 'x',
      choices: [
        Choice(id: 'a', label: 'A', text: 'One', isCorrect: true),
        Choice(id: 'b', label: 'B', text: 'Two', isCorrect: false),
        Choice(id: 'c', label: 'C', text: 'Three', isCorrect: false),
        Choice(id: 'd', label: 'D', text: 'Four', isCorrect: false),
        Choice(id: 'e', label: 'E', text: 'Five', isCorrect: false),
      ],
    );
    final picked = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(web: true),
        home: Scaffold(
          body: WebAssessmentLayout(
            question: question,
            subject: 'Science',
            examName: 'CSE',
            index: 25,
            total: 26,
            onPick: picked.add,
            onNext: () {},
            onLeave: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final key in [
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyB,
      LogicalKeyboardKey.keyC,
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.keyE,
    ]) {
      await tester.sendKeyEvent(key);
    }
    expect(picked, ['a', 'b', 'c', 'd', 'e']);
  });
}
