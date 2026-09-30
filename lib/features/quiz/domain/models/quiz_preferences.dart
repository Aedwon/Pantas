import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';

class QuizPreferences {
  QuizPreferences({
    required this.sessionLength,
    required this.ordering,
  }) {
    if (!_allowedSessionLengths.contains(sessionLength)) {
      throw ArgumentError.value(
        sessionLength,
        'sessionLength',
        'must be 5, 10, 20, or allDueSessionLength',
      );
    }
  }

  static const allDueSessionLength = -1;
  static const _allowedSessionLengths = {5, 10, 20, allDueSessionLength};

  static final defaults = QuizPreferences(
    sessionLength: 10,
    ordering: QuizOrdering.defaultOrdering,
  );

  final int sessionLength;
  final QuizOrdering ordering;
}
