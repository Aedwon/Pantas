// His words (Nov 25): "the space on top and bottom of discard in the quiz tab
// got too small though". The Nov 24 borderless buttons change made Discard
// the 24 px text line, so the space around it fell from about 18 and 22 to
// 12 and 14. Board A draws 12 and 16; his call from using the app wins.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

import '../../../goldens/screens/quiz_tab_golden_test.dart';
import '../../../goldens/screens/screen_harness.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  testWidgets(
      'phone paused card: 18 above and 22 below the Discard line, '
      'no sentence', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpScreen(
      tester,
      390,
      scaffolded(
        inShell(
          const QuizTabScreen(
            mockPanel: MockCard(
              model: MockCardModel(
                state: MockCardState.waiting,
                name: 'CSE simulation',
                durationMinutes: 190,
                lastPercent: 69,
              ),
            ),
          ),
          390,
          ShellTab.quiz,
        ),
      ),
      overrides: pausedQuizTabOverrides(db),
    );
    expect(find.textContaining('You paused'), findsNothing);
    final resume = tester.getRect(find.widgetWithText(PantasButton, 'Resume'));
    // The line's 24 px box holds its 20 px text 2 px in from each edge, so
    // 16 and 20 outside the box are 18 and 22 around the text.
    final line = tester.getRect(
      find.widgetWithText(PantasButton, 'Discard this session'),
    );
    final card = tester.getRect(
      find
          .ancestor(
            of: find.text('Discard this session'),
            matching: find.byKey(const ValueKey('grouped-section-surface')),
          )
          .first,
    );
    expect(line.height, moreOrLessEquals(24, epsilon: 0.5));
    expect(line.top - resume.bottom, moreOrLessEquals(16, epsilon: 0.5));
    expect(card.bottom - line.bottom, moreOrLessEquals(20, epsilon: 0.5));
    expect(line.center.dx, moreOrLessEquals(resume.center.dx, epsilon: 1));
  });

  test('a paused quiz the rows do not show is named; Reviews is not', () {
    const reviews = SessionPanelInProgress(
      position: 2,
      total: 11,
      reviewSession: (ordinal: 1, total: 1, done: 1, questions: 11),
      origin: SessionOrigin.todayInterleaved,
    );
    expect(reviews.pausedName, isNull);
    expect(
      const SessionPanelInProgress(
        position: 1,
        total: 10,
        origin: SessionOrigin.todayInterleaved,
      ).pausedName,
      'Weakest topics practice',
    );
    expect(
      const SessionPanelInProgress(
        position: 1,
        total: 10,
        topicName: 'Algebra',
        origin: SessionOrigin.drill,
      ).pausedName,
      'Algebra practice',
    );
    expect(
      const SessionPanelInProgress(
        position: 1,
        total: 5,
        origin: SessionOrigin.flagged,
      ).pausedName,
      'Flagged questions',
    );
    expect(
      const SessionPanelInProgress(
        position: 1,
        total: 5,
        origin: SessionOrigin.newQuestions,
      ).pausedName,
      isNull,
    );
  });
}
