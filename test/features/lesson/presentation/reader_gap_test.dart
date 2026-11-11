import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_gap.dart';
import 'package:pantas/features/quiz/application/quiz_starts.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final wide in [false, true]) {
    testWidgets('no questions hides the quiz action wide=$wide',
        (tester) async {
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final content = openTestContentDatabase();
      await seedContentLesson(content, lessonId: 'l', topicId: 't');
      await tester.pumpAppWithProviders(
        const Scaffold(
          body: ReaderGap(isRead: true, examId: 'e', lessonId: 'l'),
        ),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Quiz yourself'), findsNothing);
      expect(find.text('Read'), findsOneWidget);
    });
  }

  for (final scope in ['eligible', 'other exam', 'other lesson', 'inactive']) {
    testWidgets('quiz action checks question scope: $scope', (tester) async {
      final content = openTestContentDatabase();
      await seedContentLesson(content, lessonId: 'l', topicId: 't');
      await seedContentQuestion(
        content,
        questionId: 'q',
        topicId: 't',
        examId: scope == 'other exam' ? 'other' : 'e',
        lessonId: scope == 'other lesson' ? 'other' : 'l',
        isActive: scope != 'inactive',
      );
      await tester.pumpAppWithProviders(
        const Scaffold(
          body: ReaderGap(isRead: true, examId: 'e', lessonId: 'l'),
        ),
        overrides: [contentDatabaseProvider.overrideWithValue(content)],
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Quiz yourself'),
        scope == 'eligible' ? findsOneWidget : findsNothing,
      );
    });
  }

  Future<void> pumpGap(
    WidgetTester tester, {
    bool isRead = false,
    ExamId? examId = 'e1',
    LessonId lessonId = 'l1',
  }) async {
    await tester.pumpAppWithProviders(
      Scaffold(
        body: ReaderGap(
          isRead: isRead,
          examId: examId,
          lessonId: lessonId,
        ),
      ),
      overrides: [
        lessonQuizAvailableProvider.overrideWith((_, __) async => true),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an unread lesson shows no read line', (tester) async {
    await pumpGap(tester);

    expect(find.text('Read'), findsNothing);
    expect(find.text('marked automatically'), findsNothing);
  });

  testWidgets('a read lesson uses only the drawn Read line', (tester) async {
    await pumpGap(tester, isRead: true);

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('marked automatically'), findsNothing);
    final label = tester.widget<Text>(find.text('Read'));
    expect(label.style!.fontSize, 15);
    expect(label.style!.fontWeight, FontWeight.w500);
  });

  testWidgets('there is no mark as read button anywhere', (tester) async {
    await pumpGap(tester);

    expect(find.text('Mark as read'), findsNothing);
  });

  testWidgets('the coda names its length', (tester) async {
    await pumpGap(tester);

    expect(find.text('Quiz yourself, 5 questions'), findsOneWidget);
    expect(find.byType(PantasButton), findsOneWidget);
    final button = find.descendant(
      of: find.byType(PantasButton),
      matching: find.byType(TextButton),
    );
    expect(tester.getSize(button).height, 52);
    final style = tester.widget<TextButton>(button).style!;
    expect(style.backgroundColor!.resolve({}), PantasColors.light.fill);
    expect(style.foregroundColor!.resolve({}), PantasColors.light.label);
  });

  testWidgets('no exam means no coda rather than a broken route',
      (tester) async {
    await pumpGap(tester, examId: null);

    expect(find.text('Quiz yourself, 5 questions'), findsNothing);
  });

  testWidgets('the gap never prints the estimated minutes', (tester) async {
    await pumpGap(tester, isRead: true);

    expect(find.textContaining('min'), findsNothing);
  });
}
