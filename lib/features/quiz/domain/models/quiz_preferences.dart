import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';

class QuizPreferences {
  QuizPreferences({
    required this.sessionLength,
    required this.ordering,
    required this.newCardCap,
  }) {
    if (!_allowedSessionLengths.contains(sessionLength)) {
      throw ArgumentError.value(
        sessionLength,
        'sessionLength',
        'must be 5, 10, 20, or allDueSessionLength',
      );
    }
    if (newCardCap < 0) {
      throw ArgumentError.value(
        newCardCap,
        'newCardCap',
        'cannot be negative',
      );
    }
  }

  static const allDueSessionLength = -1;
  static const _allowedSessionLengths = {5, 10, 20, allDueSessionLength};

  static final defaults = QuizPreferences(
    sessionLength: 10,
    ordering: QuizOrdering.defaultOrdering,
    newCardCap: 10,
  );

  final int sessionLength;
  final QuizOrdering ordering;
  final int newCardCap;
}
