import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/report_providers.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/features/quiz/presentation/quiz_question_viewer.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _Accepting implements ReportSender {
  @override
  Future<void> send(QuestionReport report) async {}
}

final _questions = [
  const Question(
    id: 'q1',
    version: 1,
    examIds: ['e'],
    topicId: 't',
    language: 'en',
    stem: 'Original question 1',
    explanation: 'Correct because 1',
    choices: [
      Choice(id: 'a1', label: 'A', text: 'Right 1', isCorrect: true),
      Choice(id: 'b1', label: 'B', text: 'Wrong 1', isCorrect: false),
    ],
  ),
];
const _items = [
  AttemptItem(
    questionId: 'q1',
    questionVersion: 1,
    chosenChoiceId: 'b1',
    correctChoiceId: 'a1',
    responseMs: 12,
  ),
];

/// Aedwon's finding 5: the confirmation drew as a second element over the
/// bar, and the report form was a dialog over the bar. The bar must be the
/// one element that becomes the form and then the confirmation.
void main() {
  Widget viewer() => QuizQuestionViewer(
        questions: _questions,
        items: _items,
        pro: false,
        onBack: () {},
        onNote: (_, __, ___) async {},
        onReport: (_) async => null,
      );

  Future<void> pump(
    WidgetTester tester, {
    bool online = true,
    bool pushed = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpAppWithProviders(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: pushed
            ? Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => unawaited(
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(builder: (_) => viewer()),
                      ),
                    ),
                    child: const Text('Open quiz'),
                  ),
                ),
              )
            : viewer(),
      ),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        reportQueueProvider.overrideWith(
          (ref) => ReportQueue(
            db,
            sender: online ? _Accepting() : null,
            account: () => 'acct',
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the bar becomes the report field and the confirmation',
      (tester) async {
    await pump(tester);
    final bar = find.byKey(const ValueKey('quiz-viewer-surface'));
    expect(find.byType(FloatingBar), findsOneWidget);

    await tester.tap(find.byTooltip('Report a question'));
    await tester.pumpAndSettle();
    // The field lives inside the bar, and the bar is the same element.
    expect(
      find.descendant(of: bar, matching: find.byType(PantasField)),
      findsOneWidget,
    );
    final element = tester.element(bar);
    expect(find.byType(FloatingBar), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);

    await tester.enterText(find.byType(TextField), 'Two answers look right.');
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    // The confirmation is inside the same bar, never a second element.
    expect(
      find.descendant(
        of: bar,
        matching: find.text("Thank you. We'll take a look."),
      ),
      findsOneWidget,
    );
    expect(find.text("Thank you. We'll take a look."), findsOneWidget);
    expect(find.byType(FloatingBar), findsOneWidget);
    expect(identical(tester.element(bar), element), isTrue);
  });

  testWidgets('back while the form is open closes the form, not the quiz',
      (tester) async {
    await pump(tester, pushed: true);
    await tester.tap(find.text('Open quiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Report a question'));
    await tester.pumpAndSettle();
    expect(find.byType(PantasField), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    // The form is gone and the quiz is still on screen.
    expect(find.byType(PantasField), findsNothing);
    expect(find.byType(QuizQuestionViewer), findsOneWidget);
    expect(find.text('1 of 1'), findsOneWidget);

    // With no form open, back leaves the quiz as before.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(QuizQuestionViewer), findsNothing);
    expect(find.text('Open quiz'), findsOneWidget);
  });
}
