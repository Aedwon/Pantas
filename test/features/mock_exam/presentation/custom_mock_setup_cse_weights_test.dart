import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  Subject part(String name) =>
      Subject(id: name, examId: 'x', name: name, ordering: 0);

  Future<void> show(
    WidgetTester tester,
    String examId, {
    required bool web,
  }) async {
    addTearDown(tester.view.reset);
    tester.view
      ..physicalSize = Size(web ? 1440 : 390, 2400)
      ..devicePixelRatio = 1;
    debugWebPlatformOverride = web;
    final subjects = [
      part('Verbal Ability'),
      part('Analytical Ability'),
      part('Numerical Ability'),
      part('General Information'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: web),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: CustomMockSetupPage(
            data: CustomMockSetupData(
              examId: examId,
              subjects: subjects,
              topicsBySubject: const {},
              availableQuestions: 400,
              availableBySubject: {for (final s in subjects) s.id: 100},
            ),
            onSave: (_) async {},
            onTickMoreSubjects: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('I know the section breakdown').first);
    await tester.pumpAndSettle();
  }

  for (final web in [false, true]) {
    testWidgets(
        'CSE Professional custom setup shows each part weight, '
        'web=$web', (tester) async {
      await show(tester, 'exam_cse_pro', web: web);
      expect(find.text('Verbal Ability (30%)'), findsOneWidget);
      expect(find.text('Analytical Ability (35%)'), findsOneWidget);
      expect(find.text('Numerical Ability (30%)'), findsOneWidget);
      expect(find.text('General Information (5%)'), findsOneWidget);
    });

    testWidgets('Subprofessional custom setup shows no weight, web=$web',
        (tester) async {
      await show(tester, 'exam_cse_sub', web: web);
      expect(find.text('Verbal Ability'), findsOneWidget);
      expect(find.textContaining('%)'), findsNothing);
    });
  }
}
