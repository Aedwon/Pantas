import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MockAttemptRepo repo;
  final startedAt = DateTime.utc(2026, 5, 20, 8);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MockAttemptRepo(db);
  });

  tearDown(() => db.close());

  Future<void> insertAttempt({
    int elapsedSeconds = 0,
    bool pausedAtLastFlush = false,
    int durationMinutes = 90,
  }) {
    return repo
        .insertStart(
          MockAttemptStart(
            id: 'mock_1',
            userId: 'user_1',
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
            blueprintName: 'CSE Practice',
            durationMinutes: durationMinutes,
            strictMode: false,
            sampledQuestionsJson: '[]',
            startedAt: startedAt,
          ),
        )
        .then(
          (_) => repo.flushProgress(
            attemptId: 'mock_1',
            elapsedSeconds: elapsedSeconds,
            accumulatedPausedSeconds: 0,
            pausedAtLastFlush: pausedAtLastFlush,
            answersJson: '{}',
            flagsJson: '[]',
            currentIndex: 0,
            flushedAt: startedAt,
            updateSyncTimestamp: false,
          ),
        );
  }

  test('startMock inserts frozen blueprint duration and sampled questions',
      () async {
    final useCase = StartMock(repo: repo);
    final sample = _sample(['q1', 'q2']);

    final attempt = await useCase(
      MockStartRequest(
        id: 'mock_1',
        userId: 'user_1',
        examId: 'exam_cse',
        blueprintId: 'bp_cse',
        blueprintName: 'CSE Practice',
        durationMinutes: 90,
        strictMode: true,
        sample: sample,
        startedAt: startedAt,
      ),
    );

    expect(attempt.id, 'mock_1');
    expect(attempt.durationMinutes, 90);
    expect(attempt.strictMode, isTrue);
    expect(attempt.sampledQuestionsJson, contains('q1'));
    expect(attempt.status, MockAttemptStatus.inProgress);
  });

  test('startMock refuses unavailable free-tier slot', () async {
    final useCase = StartMock(repo: repo);

    expect(
      () => useCase(
        MockStartRequest(
          id: 'mock_1',
          userId: 'user_1',
          examId: 'exam_cse',
          blueprintId: 'bp_cse',
          blueprintName: 'CSE Practice',
          durationMinutes: 90,
          strictMode: false,
          sample: _sample(['q1']),
          startedAt: startedAt,
          availability: const MockStartAvailability(blockedReason: 'cooldown'),
        ),
      ),
      throwsA(isA<MockStartBlockedException>()),
    );
  });

  test('resumeMock preserves elapsed when pausedAtLastFlush is true', () async {
    await insertAttempt(elapsedSeconds: 120, pausedAtLastFlush: true);
    final useCase = ResumeMock(repo: repo);

    final resumed = await useCase(
      userId: 'user_1',
      now: startedAt.add(const Duration(minutes: 20)),
    );

    expect(resumed.attempt!.elapsedSeconds, 120);
    expect(resumed.autoSubmitted, isFalse);
  });

  test('resumeMock catches wall clock up when attempt was active', () async {
    await insertAttempt(elapsedSeconds: 120);
    final useCase = ResumeMock(repo: repo);

    final resumed = await useCase(
      userId: 'user_1',
      now: startedAt.add(const Duration(minutes: 20)),
    );

    expect(resumed.attempt!.elapsedSeconds, 1200);
  });

  test('resumeMock auto-submits stale attempts as timeUp', () async {
    await insertAttempt(elapsedSeconds: 120, durationMinutes: 10);
    final useCase = ResumeMock(repo: repo);

    final resumed = await useCase(
      userId: 'user_1',
      now: startedAt.add(const Duration(minutes: 20)),
    );

    expect(resumed.autoSubmitted, isTrue);
    expect(resumed.attempt!.status, MockAttemptStatus.completed);
    expect(
      resumed.attempt!.submittedAt,
      startedAt.add(const Duration(minutes: 20)),
    );
  });

  test('discardMock marks discarded and makes availability true', () async {
    await insertAttempt();
    final useCase = DiscardMock(repo: repo);

    final attempt = await useCase(
      attemptId: 'mock_1',
      discardedAt: startedAt.add(const Duration(minutes: 5)),
    );

    expect(attempt.status, MockAttemptStatus.discarded);
    expect(await repo.lastCooldownAttempt('user_1', 'exam_cse'), isNull);
  });

  test('submitMock persists score fields and terminal status', () async {
    await insertAttempt();
    final useCase = SubmitMock(repo: repo);
    const results = MockResults(
      scoreRaw: 1,
      scoreTotal: 2,
      percent: 50,
      band: ScoreBand.fail,
      sections: [],
      topWeak: [],
      totalTimeSeconds: 300,
      wasStrict: false,
    );

    final attempt = await useCase(
      attemptId: 'mock_1',
      results: results,
      submittedAt: startedAt.add(const Duration(minutes: 5)),
    );

    expect(attempt.status, MockAttemptStatus.completed);
    expect(attempt.scoreRaw, 1);
    expect(attempt.scoreTotal, 2);
    expect(attempt.totalTimeSeconds, 300);
    expect(attempt.sectionResultsJson, contains('sections'));
  });
}

MockSample _sample(List<String> questionIds) {
  return MockSample(
    expectedQuestionCount: questionIds.length,
    sections: [
      SampledMockSection(
        sectionId: 's1',
        name: 'Part 1',
        questionIds: questionIds,
      ),
    ],
  );
}
