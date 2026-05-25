import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
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
    final score = attempt.score;
    final isToday = session.origin == SessionOrigin.todayTopic ||
        session.origin == SessionOrigin.todayInterleaved;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isToday ? 'Done for today' : 'Session complete',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${score.$1}/${score.$2} correct',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isToday
                  ? 'Your streak is updated if this is your first completed '
                      "Today's Session for the day."
                  : 'Practice saved. Your review schedule has been updated.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/quiz/results/${attempt.id}'),
              child: const Text('Review results'),
            ),
          ],
        ),
      ),
    );
  }
}
