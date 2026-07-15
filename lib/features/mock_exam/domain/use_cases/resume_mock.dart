import 'package:cse_cet_reviewer/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_results.dart';

class ResumeMock {
  const ResumeMock({required MockAttemptRepo repo}) : _repo = repo;

  final MockAttemptRepo _repo;

  Future<MockResumeResult> call({
    required String userId,
    required DateTime now,
  }) async {
    final attempt = await _repo.findInProgress(userId);
    if (attempt == null) return const MockResumeResult();

    final elapsed = _elapsedOnResume(attempt, now);
    final durationSeconds = attempt.durationMinutes * 60;
    if (elapsed >= durationSeconds) {
      const emptyResults = MockResults(
        scoreRaw: 0,
        scoreTotal: 0,
        percent: 0,
        sections: [],
        topWeak: [],
        totalTimeSeconds: 0,
        wasStrict: false,
      );
      await _repo.submit(
        attemptId: attempt.id,
        status: MockAttemptStatus.completed,
        results: emptyResults,
        sectionResultsJson: '{"sections":[],"reason":"timeUp"}',
        submittedAt: now,
      );
      return MockResumeResult(
        attempt: await _repo.findById(attempt.id),
        autoSubmitted: true,
      );
    }

    await _repo.flushProgress(
      attemptId: attempt.id,
      elapsedSeconds: elapsed,
      accumulatedPausedSeconds: attempt.accumulatedPausedSeconds,
      pausedAtLastFlush: false,
      answersJson: attempt.answersJson,
      flagsJson: attempt.flagsJson,
      currentIndex: attempt.currentIndex,
      flushedAt: now,
      updateSyncTimestamp: false,
    );

    return MockResumeResult(attempt: await _repo.findById(attempt.id));
  }

  int _elapsedOnResume(MockAttempt attempt, DateTime now) {
    if (attempt.pausedAtLastFlush) return attempt.elapsedSeconds;
    final wallClock = now.difference(attempt.startedAt).inSeconds -
        attempt.accumulatedPausedSeconds;
    return wallClock > attempt.elapsedSeconds
        ? wallClock
        : attempt.elapsedSeconds;
  }
}

class MockResumeResult {
  const MockResumeResult({
    this.attempt,
    this.autoSubmitted = false,
  });

  final MockAttempt? attempt;
  final bool autoSubmitted;
}
