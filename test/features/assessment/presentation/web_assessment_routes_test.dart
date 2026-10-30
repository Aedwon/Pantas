import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_debrief_loading.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_result.dart';
import 'package:pantas/features/assessment/presentation/assessment_page.dart';
import 'package:pantas/features/assessment/presentation/assessment_results_page.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase content;
  setUp(() async {
    debugWebPlatformOverride = true;
    db = inMemoryDatabase();
    content = inMemoryContentDatabase();
    await seedContentExam(content, examId: 'e', code: 'CSE', name: 'CSE');
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
    await seedContentQuestion(
      content,
      questionId: 'q',
      topicId: 't',
      examId: 'e',
      stem: 'A question?',
      correctText: 'First choice',
      wrongText: 'Second choice',
    );
  });
  tearDown(() async {
    debugWebPlatformOverride = null;
    await db.close();
    await content.close();
  });
  Future<GoRouter> pump(
    WidgetTester tester, {
    bool dark = false,
    double width = 1440,
    String path = '/assessment/e',
  }) async {
    tester.view
      ..physicalSize = Size(width, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: path,
      routes: [
        GoRoute(
          path: '/assessment/:examId',
          builder: (_, state) =>
              AssessmentPage(examId: state.pathParameters['examId']!),
        ),
        GoRoute(
          path: '/assessment/:examId/results',
          builder: (_, state) =>
              AssessmentResultsPage(examId: state.pathParameters['examId']!),
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
          theme: dark
              ? buildDarkTheme(web: width >= 1024)
              : buildLightTheme(web: width >= 1024),
          routerConfig: router,
        ),
      ),
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    return router;
  }

  for (final dark in [false, true]) {
    testWidgets(
        'wide assessment route keeps leave and completion behavior dark=$dark',
        (tester) async {
      await pump(tester, dark: dark);
      expect(find.byType(WebAssessmentLayout), findsOneWidget);
      expect(find.byTooltip('Report'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(WebAssessmentLeaveDialog), findsOneWidget);
      final leave = tester.getRect(find.text('Leave'));
      final keep = tester.getRect(find.text('Keep Going'));
      expect(leave.left, lessThan(keep.left));
      expect(leave.center.dy, closeTo(keep.center.dy, 1));
      final color = tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Leave'))
          .style!
          .foregroundColor!
          .resolve({});
      expect(color, dark ? const Color(0xFFE0706B) : const Color(0xFFD70015));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(WebAssessmentLeaveDialog), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(WebAssessmentResults), findsOneWidget);
      expect(find.text('CSE · 1 questions'), findsOneWidget);
      expect(await AssessmentRepository(db).hasCompletedForExam('e'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide assessment unavailable state dark=$dark', (tester) async {
      await seedContentExam(
        content,
        examId: 'empty',
        code: 'EMPTY',
        name: 'Empty',
      );
      await pump(tester, dark: dark, path: '/assessment/empty');
      expect(find.text("Assessment isn't ready yet"), findsOneWidget);
      expect(find.text('Back to Quiz'), findsOneWidget);
      expect(find.byType(WebAssessmentLayout), findsNothing);
    });
    testWidgets('wide results slow loading dark=$dark', (tester) async {
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final pending = Completer<AssessmentResult?>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assessmentResultProvider('e').overrideWith((ref) => pending.future),
          ],
          child: MaterialApp(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: const AssessmentResultsPage(examId: 'e'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(WebDebriefLoading), findsOneWidget);
      expect(
        find.byKey(const ValueKey('loading-shapes-opacity')),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 301));
      expect(find.byType(SkeletonPulse), findsWidgets);
      expect(
        find.byKey(const ValueKey('loading-shapes-opacity')),
        findsWidgets,
      );
      pending.complete(null);
      await tester.pumpAndSettle();
      expect(find.text('No results yet.'), findsOneWidget);
    });
    testWidgets('wide assessment no results state dark=$dark', (tester) async {
      await pump(tester, dark: dark, path: '/assessment/e/results');
      expect(find.text('No results yet.'), findsOneWidget);
      expect(find.byType(WebAssessmentResults), findsNothing);
    });
  }
  testWidgets('narrow web retains phone questions', (tester) async {
    await pump(tester, width: 1023);
    expect(find.byType(WebAssessmentLayout), findsNothing);
    expect(find.byType(ChoiceRow), findsNWidgets(2));
    expect(find.byType(WebBottomBar), findsNothing);
  });
}
