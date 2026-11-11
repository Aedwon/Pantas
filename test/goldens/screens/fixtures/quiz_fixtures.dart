// Fake data for the Quiz screens, lifted from
// test/features/quiz/presentation/quiz_ds_matrix_test.dart.
import 'dart:async';

import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

import '../../../features/quiz/presentation/session_end_screen_test.dart'
    show completedSession;

class ReviewWork implements TodayQuestionWork {
  @override
  List<int> get reviewSizes => [10, 10, 4];
  @override
  List<int> get reviewProgress => [10, 0, 0];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A quiz controller that starts already running a session.
class RunningQuizController extends QuizController {
  RunningQuizController(super.ref, QuizSession session, {String? selected}) {
    state = QuizRunning(
      session: session,
      questionShownAt: DateTime.utc(2026),
      selectedChoiceId: selected,
    );
  }

  @override
  Future<void> start({
    required String examId,
    String? topicId,
    int count = 10,
    int? randomSeed,
  }) async {}
}

/// A ten-question session stopped at question 4, picking or revealed.
QuizSession midSession({required bool revealed}) {
  final full = completedSession(batch: true);
  return full.copyWith(
    currentIndex: 3,
    outcomes: full.outcomes.take(revealed ? 4 : 3).toList(),
  );
}
