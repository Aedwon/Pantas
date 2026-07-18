import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_availability.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/widgets/mock_panel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpCustom(
    WidgetTester tester, {
    required MockAvailability availability,
    CustomMockSummary? customTrack,
    bool proIsActive = false,
  }) =>
      tester.pumpApp(
        MockPanel(
          availability: availability,
          lastAttempt: null,
          proIsActive: proIsActive,
          customTrack: customTrack,
          onSetUpCustom: () {},
          onChangeCustomSetup: () {},
          onTake: () {},
          onResume: () {},
          onViewResults: () {},
        ),
      );

  testWidgets('a custom track with no blueprint offers to build one',
      (tester) async {
    await pumpCustom(tester, availability: const MockAvailability.available());

    expect(
      find.text('You can build your own mock exam. Tell us how many '
          "questions and how long it runs, and we'll set it up for you."),
      findsOneWidget,
    );
    expect(find.text('Set one up'), findsOneWidget);
    // Nothing has been taken, so there is no count and nothing to take.
    expect(find.text('Take the exam'), findsNothing);
  });

  testWidgets('a set up track says what it is', (tester) async {
    await pumpCustom(
      tester,
      availability: const MockAvailability.available(),
      customTrack: const CustomMockSummary(questions: 120, minutes: 120),
    );

    expect(
      find.text('120 questions, 2 hours. You set this up.'),
      findsOneWidget,
    );
    expect(find.text('Change the setup'), findsOneWidget);
    expect(find.text('Set one up'), findsNothing);
  });

  testWidgets('an odd duration reads in hours and minutes', (tester) async {
    await pumpCustom(
      tester,
      availability: const MockAvailability.available(),
      customTrack: const CustomMockSummary(questions: 80, minutes: 95),
    );

    expect(find.text('80 questions, 1h 35m. You set this up.'), findsOneWidget);
  });

  testWidgets('the tier line is stated on a custom track too', (tester) async {
    await pumpCustom(
      tester,
      availability: const MockAvailability.available(),
      customTrack: const CustomMockSummary(questions: 120, minutes: 120),
    );

    expect(find.textContaining('every two weeks'), findsOneWidget);
  });

  testWidgets('a custom track serves the same cooldown', (tester) async {
    await pumpCustom(
      tester,
      availability: const MockAvailability.cooldown(
        Duration(days: 13, hours: 4),
      ),
      customTrack: const CustomMockSummary(questions: 120, minutes: 120),
    );

    // Same corpus, same sampler, same paper: skipping the cooldown here
    // would be a hole straight through the Pro proposition.
    final buttons = tester.widgetList<BoardButton>(find.byType(BoardButton));
    expect(buttons.where((b) => b.label == 'Take the exam'), isEmpty);
    expect(find.textContaining('13d'), findsOneWidget);
  });
}
