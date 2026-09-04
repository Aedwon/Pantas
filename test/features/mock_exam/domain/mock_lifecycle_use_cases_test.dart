import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

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
    String id = 'mock_1',
    String userId = 'user_1',
    DateTime? attemptStartedAt,
    int elapsedSeconds = 0,
    int accumulatedPausedSeconds = 0,
    bool pausedAtLastFlush = false,
    int durationMinutes = 90,
    String answersJson = '{}',
    DateTime? flushedAt,
  }) {
    return repo
        .insertStart(
          MockAttemptStart(
            id: id,
            userId: userId,
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
            blueprintName: 'CSE Practice',
            durationMinutes: durationMinutes,
            strictMode: false,
            sampledQuestionsJson: '[]',
            startedAt: attemptStartedAt ?? startedAt,
          ),
        )
        .then(
          (_) => repo.flushProgress(
            attemptId: id,
            elapsedSeconds: elapsedSeconds,
            accumulatedPausedSeconds: accumulatedPausedSeconds,
            pausedAtLastFlush: pausedAtLastFlush,
            answersJson: answersJson,
            flagsJson: '[]',
            currentIndex: 0,
            flushedAt: flushedAt ?? startedAt,
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
        partsTimedSeparately: false,
        parts: const [
          MockPersistedPart(
            name: '',
            startIndex: 0,
            count: 2,
            minutes: null,
          ),
        ],
        startedAt: startedAt,
      ),
    );

    expect(attempt.id, 'mock_1');
    expect(attempt.durationMinutes, 90);
    expect(attempt.strictMode, isTrue);
    expect(attempt.sampledQuestionsJson, contains('q1'));
    expect(
      attempt.sampledQuestionsJson,
      contains('"currentPartIndex":0'),
    );
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
          partsTimedSeparately: false,
          parts: const [
            MockPersistedPart(
              name: '',
              startIndex: 0,
              count: 1,
              minutes: null,
            ),
          ],
          startedAt: startedAt,
          availability: const MockStartAvailability(blockedReason: 'cooldown'),
        ),
      ),
      throwsA(isA<MockStartBlockedException>()),
    );
  });

  test('resumeMock preserves elapsed when pausedAtLastFlush is true', () async {
    await insertAttempt(
      elapsedSeconds: 120,
      accumulatedPausedSeconds: 30,
      pausedAtLastFlush: true,
      flushedAt: startedAt.add(const Duration(minutes: 2)),
    );
    final useCase = ResumeMock(repo: repo);

    final resumed = await useCase(
      attemptId: 'mock_1',
      userId: 'user_1',
      now: startedAt.add(const Duration(minutes: 20)),
    );

    expect(resumed.attempt!.elapsedSeconds, 120);
    expect(resumed.attempt!.accumulatedPausedSeconds, 1110);
    expect(resumed.autoSubmitted, isFalse);
  });

  test('resumeMock catches wall clock up when attempt was active', () async {
    await insertAttempt(elapsedSeconds: 120);
    final useCase = ResumeMock(repo: repo);

    final resumed = await useCase(
      attemptId: 'mock_1',
      userId: 'user_1',
      now: startedAt.add(const Duration(minutes: 20)),
    );

    expect(resumed.attempt!.elapsedSeconds, 1200);
  });

  test('resumeMock leaves an expired snapshot intact for scored submission',
      () async {
    await insertAttempt(
      elapsedSeconds: 120,
      durationMinutes: 10,
      answersJson: '{"q1":{"selectedIndex":1,"atSec":30}}',
    );
    final useCase = ResumeMock(repo: repo);

    final resumed = await useCase(
      attemptId: 'mock_1',
      userId: 'user_1',
      now: startedAt.add(const Duration(minutes: 20)),
    );

    expect(resumed.autoSubmitted, isFalse);
    expect(resumed.attempt!.status, MockAttemptStatus.inProgress);
    expect(resumed.attempt!.elapsedSeconds, 600);
    expect(resumed.attempt!.answersJson, contains('selectedIndex'));
    expect(resumed.attempt!.submittedAt, isNull);
  });

  test('resumeMock updates only the requested active attempt', () async {
    await insertAttempt(id: 'mock_requested', elapsedSeconds: 60);
    await insertAttempt(
      id: 'mock_newer',
      attemptStartedAt: startedAt.add(const Duration(minutes: 1)),
      elapsedSeconds: 120,
    );
    final useCase = ResumeMock(repo: repo);

    final resumed = await useCase(
      attemptId: 'mock_requested',
      userId: 'user_1',
      now: startedAt.add(const Duration(minutes: 20)),
    );

    expect(resumed.attempt!.id, 'mock_requested');
    expect(resumed.attempt!.elapsedSeconds, 1200);
    expect((await repo.findById('mock_newer'))!.elapsedSeconds, 120);
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
