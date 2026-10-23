import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/presentation/quiz_note_editor.dart';
import 'package:pantas/features/quiz/presentation/quiz_question_viewer.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

final questions = [
  for (var i = 1; i <= 2; i++)
    Question(
      id: 'q$i',
      version: 1,
      examIds: const ['e'],
      topicId: 't',
      language: 'en',
      stem: 'Original question $i',
      explanation: 'Correct because $i',
      choices: [
        Choice(id: 'a$i', label: 'A', text: 'Right $i', isCorrect: true),
        Choice(
          id: 'b$i',
          label: 'B',
          text: 'Wrong $i',
          isCorrect: false,
          rationale: 'Wrong-choice check $i',
        ),
      ],
    ),
];
final items = [
  const AttemptItem(
    questionId: 'q1',
    questionVersion: 1,
    chosenChoiceId: 'b1',
    correctChoiceId: 'a1',
    responseMs: 12,
  ),
  const AttemptItem(
    questionId: 'q2',
    questionVersion: 1,
    chosenChoiceId: 'a2',
    correctChoiceId: 'a2',
    responseMs: 12,
  ),
];

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool pro,
    Future<void> Function(String, MistakeTag?, String?)? onNote,
    double scale = 1,
    bool unanswered = false,
    bool reduced = true,
  }) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpAppWithProviders(
      MediaQuery(
        data: MediaQueryData(
          size: tester.view.physicalSize / tester.view.devicePixelRatio,
          disableAnimations: reduced,
          textScaler: TextScaler.linear(scale),
        ),
        child: QuizQuestionViewer(
          questions: questions,
          items: unanswered ? const [] : items,
          pro: pro,
          onBack: () {},
          onNote: onNote ?? (_, __, ___) async {},
          onReport: (_) async => true,
        ),
      ),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Free viewer navigates the original paper without a notes gate',
      (tester) async {
    await pump(tester, pro: false);
    expect(find.text('1 of 2'), findsOneWidget);
    expect(find.text('Original question 1'), findsOneWidget);
    expect(find.byTooltip('Add Note'), findsNothing);
    expect(find.text('Wrong-choice check 1'), findsNothing);
    await tester.tap(find.byTooltip('Next question'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 2'), findsOneWidget);
    expect(find.text('Original question 2'), findsOneWidget);
    expect(find.text('Why did you miss it?'), findsNothing);
    await tester.tap(find.byTooltip('Previous question'));
    await tester.pumpAndSettle();
    expect(find.text('Original question 1'), findsOneWidget);
  });
  testWidgets('Pro note writes only the viewed original wrong question',
      (tester) async {
    final saved = <(String, MistakeTag?, String?)>[];
    await pump(
      tester,
      pro: true,
      onNote: (id, tag, note) async => saved.add((id, tag, note)),
    );
    expect(find.text('Wrong-choice check 1'), findsOneWidget);
    await tester.tap(find.byTooltip('Add Note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I misread it'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Note'));
    await tester.pumpAndSettle();
    expect(saved, [('q1', MistakeTag.misread, null)]);
    expect(find.byTooltip('Edit Note'), findsOneWidget);
    await tester.tap(find.byTooltip('Next question'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Add Note'), findsNothing);
    expect(find.byTooltip('Edit Note'), findsNothing);
  });
  testWidgets('compact 200 percent viewer keeps navigation and notes reachable',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pump(tester, pro: true, scale: 2);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Add Note'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Cancel'),
      150,
      scrollable: find
          .descendant(
            of: find.byType(QuizNoteEditor),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next question'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'never-answered flags reveal the answer without inventing a result',
      (tester) async {
    await pump(tester, pro: false, unanswered: true);
    expect(
      tester.widget<FloatingBar>(find.byType(FloatingBar)).state,
      FloatingBarState.neutral,
    );
    expect(find.text('Correct because 1'), findsOneWidget);
    expect(find.text('your pick'), findsNothing);
    expect(find.byTooltip('Add Note'), findsNothing);
    expect(find.byType(QuizNoteEditor), findsNothing);
  });

  testWidgets('one shared frame follows exact opening and closing note tracks',
      (tester) async {
    await pump(tester, pro: true, reduced: false);
    final bar = find.byType(FloatingBar);
    final frameElement = tester.element(bar);
    expect(tester.getSize(bar).height, 60);
    final colors = tester.element(bar).colors;
    const curve = Cubic(.32, .72, 0, 1);
    BoxDecoration surface() => tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byKey(const ValueKey('quiz-viewer-surface')),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((w) => w.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.color != null);
    double fade(String key) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byKey(ValueKey(key)),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;
    await tester.tap(find.byTooltip('Add Note'));
    await tester.pump();
    expect(identical(tester.element(bar), frameElement), isTrue);
    await tester.pump(const Duration(milliseconds: 120));
    expect(fade('quiz-viewer-counter'), closeTo(0, .001));
    expect(fade('quiz-viewer-note-form'), closeTo(0, .001));
    expect(
      tester.getSize(bar).height,
      closeTo(60 + 258 * curve.transform(120 / 420), .1),
    );
    expect(
      (surface().borderRadius! as BorderRadius).topLeft.x,
      closeTo(30 - 6 * curve.transform(120 / 420), .01),
    );
    expect(
      surface().color,
      Color.lerp(
        colors.floatingWrong,
        colors.surface,
        curve.transform(120 / 420),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(fade('quiz-viewer-note-form'), closeTo(.5, .01));
    await tester.pump(const Duration(milliseconds: 180));
    expect(tester.getSize(bar).height, closeTo(318, .01));
    expect(surface().color, colors.surface);
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));
    expect(fade('quiz-viewer-note-form'), closeTo(0, .001));
    expect(fade('quiz-viewer-counter'), closeTo(0, .001));
    await tester.pump(const Duration(milliseconds: 120));
    expect(fade('quiz-viewer-counter'), closeTo(0, .001));
    await tester.pump(const Duration(milliseconds: 160));
    expect(tester.getSize(bar).height, closeTo(60, .01));
    expect(fade('quiz-viewer-counter'), closeTo(160 / 220, .01));
    await tester.pump(const Duration(milliseconds: 60));
    expect(fade('quiz-viewer-counter'), 1);
    expect(surface().color, colors.floatingWrong);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved note icon follows delayed pop track', (tester) async {
    await pump(tester, pro: true, reduced: false);
    await tester.tap(find.byTooltip('Add Note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I misread it'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Note'));
    await tester.pump();
    double scale() {
      final icon = find.descendant(
        of: find.byTooltip('Edit Note'),
        matching: find.byType(Icon),
      );
      final box = tester.renderObject<RenderBox>(icon);
      final parent =
          tester.renderObject<RenderBox>(find.byType(QuizQuestionViewer));
      return MatrixUtils.transformRect(
            box.getTransformTo(parent),
            Offset.zero & box.size,
          ).width /
          box.size.width;
    }

    await tester.pump(const Duration(milliseconds: 300));
    expect(scale(), closeTo(.6, .001));
    await tester.pump(const Duration(milliseconds: 260));
    expect(scale(), closeTo(1.1, .001));
    await tester.pump(const Duration(milliseconds: 160));
    expect(scale(), closeTo(1, .001));
  });

  testWidgets('canceling a draft never seeds the next editor', (tester) async {
    await pump(tester, pro: true);
    await tester.tap(find.byTooltip('Add Note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Type my own'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Canceled draft');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add Note'));
    await tester.pumpAndSettle();
    expect(find.text('Canceled draft'), findsNothing);
  });
}
