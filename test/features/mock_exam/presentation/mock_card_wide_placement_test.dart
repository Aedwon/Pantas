import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';

import '../../../helpers/button_placement.dart';

/// The wide Quiz tab mock card (patterns.md, "Button placement"): its action
/// sits at the right end at natural width, and the custom mock's Change the
/// Setup sits before Take the Exam in one row. It spanned the card, with
/// Change the Setup stacked under it, until Nov 25.
void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  for (final state in [
    MockCardState.neverTaken,
    MockCardState.waiting,
    MockCardState.inProgress,
    MockCardState.customUnset,
    MockCardState.customReady,
  ]) {
    testWidgets('wide ${state.name}: the action is at the right end',
        (tester) async {
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(1440, 900),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 520,
                  child: MockCard(
                    model: MockCardModel(
                      state: state,
                      name: 'UPCAT simulation',
                      durationMinutes: 165,
                      lastPercent: 69,
                      lastAttemptAt: DateTime(2026, 9, 26),
                      nextOpensAt: DateTime(2026, 10, 10),
                      customQuestions: 120,
                    ),
                    onTake: () {},
                    onResume: () {},
                    onViewResults: () {},
                    onSetUp: () {},
                    onChangeSetup: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expectWidePlacement(tester);
    });
  }
}
