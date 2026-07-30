import 'package:pantas/features/mock_exam/domain/mock_results.dart';

sealed class MockSessionState {
  const MockSessionState();
}

class MockSessionInProgress extends MockSessionState {
  const MockSessionInProgress({
    required this.attemptId,
    required this.durationSeconds,
    required this.questionIds,
    required this.currentIndex,
    required this.elapsedSeconds,
    required this.answers,
    required this.flags,
    required this.strictMode,
  });

  final String attemptId;
  final int durationSeconds;
  final List<String> questionIds;
  final int currentIndex;
  final int elapsedSeconds;
  final Map<String, MockAnswer> answers;
  final Set<String> flags;
  final bool strictMode;

  String get currentQuestionId => questionIds[currentIndex];
  int get remainingSeconds => durationSeconds - elapsedSeconds;

  MockSessionInProgress copyWith({
    int? currentIndex,
    int? elapsedSeconds,
    Map<String, MockAnswer>? answers,
    Set<String>? flags,
  }) {
    return MockSessionInProgress(
      attemptId: attemptId,
      durationSeconds: durationSeconds,
      questionIds: questionIds,
      currentIndex: currentIndex ?? this.currentIndex,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      answers: answers ?? this.answers,
      flags: flags ?? this.flags,
      strictMode: strictMode,
    );
  }
}

class MockSessionPaused extends MockSessionState {
  const MockSessionPaused(this.snapshot);

  final MockSessionInProgress snapshot;
}

class MockSessionSubmitted extends MockSessionState {
  const MockSessionSubmitted(this.reason);

  final MockSubmitReason reason;
}

class MockSessionForfeited extends MockSessionState {
  const MockSessionForfeited(this.reason);

  final MockSubmitReason reason;
}

enum MockTimeWarning { fiveMinutes, oneMinute }

enum MockSubmitReason { manual, timeUp, strictBackground }
