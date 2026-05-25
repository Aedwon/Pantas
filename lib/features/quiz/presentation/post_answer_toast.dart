import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:flutter/material.dart';

class PostAnswerToast extends StatelessWidget {
  const PostAnswerToast({required this.outcome, super.key});

  final AnswerOutcome outcome;

  static SnackBar snackBar(AnswerOutcome outcome) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1500),
      content: PostAnswerToast(outcome: outcome),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_label(outcome.derivedRating)} · next review in '
      '${_interval(outcome.nextReviewIntervalDays)}',
    );
  }

  static String _label(Rating rating) => switch (rating) {
        Rating.again => 'Again',
        Rating.hard => 'Hard',
        Rating.good => 'Good',
        Rating.easy => 'Easy',
      };

  static String _interval(int days) {
    if (days <= 1) {
      return '1d';
    }
    return '${days}d';
  }
}
