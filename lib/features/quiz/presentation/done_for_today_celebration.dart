import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoneForTodayCelebration extends StatelessWidget {
  const DoneForTodayCelebration({
    required this.attempt,
    required this.session,
    super.key,
  });

  final Attempt attempt;
  final QuizSession session;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    final score = attempt.score;
    final isToday = session.origin == SessionOrigin.todayTopic ||
        session.origin == SessionOrigin.todayInterleaved;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isToday ? 'Done for today' : 'Session complete',
              style: styles.headlineMedium,
            ),
            const SizedBox(height: 12),
            StatsBand(
              figures: [
                StatFigure(
                  value: '${score.$1}',
                  suffix: '/${score.$2}',
                  label: 'correct',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isToday
                  ? 'Your streak is updated if this is your first completed '
                      "Today's session for the day."
                  : 'Practice saved. Your review schedule has been updated.',
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 20),
            BoardButton(
              label: 'Review results',
              onPressed: () => context.go('/quiz/results/${attempt.id}'),
            ),
          ],
        ),
      ),
    );
  }
}
