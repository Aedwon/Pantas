import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import '../../../helpers/button_placement.dart';
import 'web_mock_layout_test.dart' show blueprint, pumpWide, question;

// Button placement (design/system/patterns.md): on a wide screen a single
// action is never full width. A side panel puts it at the panel's right end.
void main() {
  tearDown(() => debugWebPlatformOverride = null);

  testWidgets('wide mock setup: Start sits at the right end at natural width',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpWide(
      tester,
      MockSetupPage(parsedBlueprint: blueprint, onStart: (_) {}),
      dark: false,
    );
    expectWidePlacement(tester);
    final button = tester.getRect(
      find.widgetWithText(WebButton, 'Start the Mock Exam'),
    );
    final card = tester.getRect(find.byType(WebCard).first);
    // The strict mode card spans the column; Start ends where it ends.
    // Natural width: the button is narrower than the card it ends.
    expect(button.width, lessThan(card.width * .9));
    expect(button.right, closeTo(card.right, 1));
    // The fine print is right-aligned under the button.
    final fine = tester.getRect(find.text('The clock starts when you click.'));
    expect(fine.right, closeTo(button.right, 1));
    expect(fine.top, greaterThan(button.bottom));
  });

  testWidgets('wide paper panel: Submit the Exam is natural width, right end',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpWide(
      tester,
      ProviderScope(
        overrides: [
          hydratedMockQuestionProvider.overrideWith(
            (ref, id) async => const HydratedMockQuestion(question, null),
          ),
        ],
        child: MockSessionPage(
          state: const MockSessionInProgress(
            attemptId: 'a',
            durationSeconds: 5400,
            questionIds: ['q', 'q2'],
            currentIndex: 0,
            elapsedSeconds: 0,
            answers: {},
            flags: {},
            strictMode: false,
          ),
          remainingInPart: const Duration(minutes: 30),
          partPosition: 1,
          partTotal: 2,
          oneBlock: true,
          canGoPrevious: false,
          canGoNext: true,
          onPrevious: () {},
          onNext: () {},
          onAnswer: (_) {},
          onToggleFlag: () {},
          onPause: () {},
          onSubmitExam: () {},
        ),
      ),
      dark: false,
    );
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(WebButton, 'Submit the Exam');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    // The test font is wider than the real one, so the natural button here
    // is as wide as the panel's content; the "spans its box" check would
    // misfire. Check only that nothing is built full width.
    expect(
      widePlacementProblems(tester).where((p) => p.contains('full width')),
      isEmpty,
    );
    final button = tester.getRect(submit);
    final panel = tester.getRect(
      find.ancestor(of: submit, matching: find.byType(ListView)).first,
    );
    // The panel pads its content 24 px on each side.
    expect(button.width, lessThanOrEqualTo(panel.width - 48));
    expect(button.right, closeTo(panel.right - 24, 1));
  });
}
