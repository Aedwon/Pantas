import 'dart:convert';

import 'package:pantas/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_snapshot.dart';

class ResumeMock {
  const ResumeMock({required MockAttemptRepo repo}) : _repo = repo;

  final MockAttemptRepo _repo;

  Future<MockResumeResult> call({
    required String attemptId,
    required String userId,
    required DateTime now,
  }) async {
    final attempt = await _repo.findById(attemptId);
    if (attempt == null ||
        attempt.userId != userId ||
        attempt.status != MockAttemptStatus.inProgress) {
      return const MockResumeResult();
    }

    final betweenParts = _betweenParts(attempt);
    final durationSeconds = attempt.durationMinutes * 60;
    final resumedElapsed =
        betweenParts ? attempt.elapsedSeconds : _elapsedOnResume(attempt, now);
    final elapsed = resumedElapsed < 0
        ? 0
        : resumedElapsed > durationSeconds
            ? durationSeconds
            : resumedElapsed;
    final pausedSinceFlush = now.difference(attempt.lastFlushedAt).inSeconds;
    final accumulatedPausedSeconds = attempt.accumulatedPausedSeconds +
        (attempt.pausedAtLastFlush || betweenParts
            ? pausedSinceFlush < 0
                ? 0
                : pausedSinceFlush
            : 0);

    await _repo.flushProgress(
      attemptId: attempt.id,
      elapsedSeconds: elapsed,
      accumulatedPausedSeconds: accumulatedPausedSeconds,
      pausedAtLastFlush: false,
      answersJson: attempt.answersJson,
      flagsJson: attempt.flagsJson,
      currentIndex: attempt.currentIndex,
      flushedAt: now,
      updateSyncTimestamp: false,
    );

    return MockResumeResult(attempt: await _repo.findById(attempt.id));
  }

  bool _betweenParts(MockAttempt attempt) {
    final raw = jsonDecode(attempt.sampledQuestionsJson);
    if (raw is! List) throw const FormatException('invalid saved paper');
    if (raw.isEmpty) return false;
    final first = raw.first;
    if (first is! Map) throw const FormatException('invalid saved section');
    if (first['_session'] == null) return false;
    final saved = const MockSessionSnapshotCodec().decode(
      sampledQuestionsJson: attempt.sampledQuestionsJson,
      answersJson: attempt.answersJson,
      flagsJson: attempt.flagsJson,
    );
    if (!saved.betweenParts) return false;
    final part = saved.parts![saved.currentPartIndex!];
    if (attempt.currentIndex != part.startIndex ||
        attempt.elapsedSeconds != saved.partStartedAtSeconds) {
      throw const FormatException(
        'saved transition clock or position is invalid',
      );
    }
    return true;
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
