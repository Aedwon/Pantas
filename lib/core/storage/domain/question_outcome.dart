/// How a single question has gone recently. Both figures are counted from
/// `attempts_local`, never estimated.
class QuestionOutcome {
  const QuestionOutcome({required this.attempts, required this.correct});

  final int attempts;
  final int correct;
}

/// One day's answering, for the session panel's "caught up" state.
class DayTally {
  const DayTally({required this.answered, required this.correct});

  static const empty = DayTally(answered: 0, correct: 0);

  final int answered;
  final int correct;
}
