import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_availability.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_panel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

MockAttempt submitted({
  int scoreRaw = 45,
  int scoreTotal = 60,
  DateTime? submittedAt,
}) =>
    MockAttempt(
      id: 'm_1',
      userId: 'local',
      examId: 'exam_cse_pro',
      blueprintId: 'bp_1',
      blueprintName: 'Full paper',
      durationMinutes: 210,
      status: MockAttemptStatus.completed,
      strictMode: false,
      sampledQuestionsJson: '[]',
      elapsedSeconds: 0,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: '{}',
      flagsJson: '[]',
      currentIndex: 0,
      scoreRaw: scoreRaw,
      scoreTotal: scoreTotal,
      startedAt: DateTime.utc(2026, 7, 22, 9),
      lastFlushedAt: DateTime.utc(2026, 7, 22, 12),
      submittedAt: submittedAt ?? DateTime.utc(2026, 7, 22, 12),
      updatedAt: DateTime.utc(2026, 7, 22, 12),
    );

Future<void> pumpPanel(
  WidgetTester tester, {
  required MockAvailability availability,
  MockAttempt? lastAttempt,
  bool proIsActive = false,
}) =>
    tester.pumpApp(
      MockPanel(
        availability: availability,
        lastAttempt: lastAttempt,
        proIsActive: proIsActive,
        onTake: () {},
        onResume: () {},
        onViewResults: () {},
      ),
    );

void main() {
  testWidgets('a first time student is told what it is', (tester) async {
    await pumpPanel(tester, availability: const MockAvailability.available());

    expect(find.text('Mock exam'), findsOneWidget);
    expect(
      find.text('The whole thing under exam timing. 3 hours 30, and no '
          'answers until the end.'),
      findsOneWidget,
    );
    expect(find.text('Take the exam'), findsOneWidget);
  });

  testWidgets('the Free rule is stated before the first attempt',
      (tester) async {
    await pumpPanel(tester, availability: const MockAvailability.available());

    expect(
      find.textContaining('get one every two weeks'),
      findsOneWidget,
    );
    expect(find.textContaining('Your next one opens on'), findsNothing);
  });

  testWidgets('the Pro rule is stated too', (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.available(),
      proIsActive: true,
    );

    expect(
      find.textContaining('can take as many as they want'),
      findsOneWidget,
    );
  });

  testWidgets('a returning student sees two figures and Take another',
      (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.available(),
      lastAttempt: submitted(),
    );

    expect(find.text('75'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
    expect(find.text('last score'), findsOneWidget);
    expect(find.text('taken'), findsOneWidget);
    expect(find.text('Take another'), findsOneWidget);
    expect(find.text('View your full results from last time'), findsOneWidget);
  });

  testWidgets('parts passed is not shown', (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.available(),
      lastAttempt: submitted(),
    );

    expect(find.textContaining('parts'), findsNothing);
    expect(find.textContaining(' of 5'), findsNothing);
  });

  testWidgets('a cooldown shows in the header and offers no button',
      (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.cooldown(
        Duration(days: 9, hours: 14),
      ),
      lastAttempt: submitted(),
    );

    expect(find.text('9d 14h'), findsOneWidget);
    expect(find.text('Take another'), findsNothing);
    expect(find.text('Take the exam'), findsNothing);
    expect(find.text('View your full results from last time'), findsOneWidget);
  });

  testWidgets('a cooldown names the day it reopens', (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.cooldown(
        Duration(days: 9, hours: 14),
      ),
      lastAttempt: submitted(),
    );

    expect(find.textContaining('Your next one opens on'), findsOneWidget);
  });

  testWidgets('an attempt in progress blocks the exam', (tester) async {
    await pumpPanel(
      tester,
      availability: MockAvailability.inProgress(submitted()),
    );

    expect(
      find.text("Finish your session first. It runs 3 hours 30 and can't "
          'be paused.'),
      findsOneWidget,
    );
    expect(find.text('Take the exam'), findsNothing);
    expect(find.text('Take another'), findsNothing);
  });

  testWidgets('every button is secondary, the session panel owns the board',
      (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.available(),
      lastAttempt: submitted(),
    );

    final buttons = tester.widgetList<BoardButton>(find.byType(BoardButton));
    expect(buttons, isNotEmpty);
    expect(buttons.every((button) => button.secondary), isTrue);
  });
}
