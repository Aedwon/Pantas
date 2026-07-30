import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMockBlueprintRepo implements MockBlueprintRepo {
  @override
  ContentDatabase get database => throw UnimplementedError();

  @override
  Future<List<MockBlueprint>> byExam(String examId) async {
    if (examId == 'exam_no_blueprint') return [];
    return [
      const MockBlueprint(
        id: 'bp_1',
        examId: 'exam_cse',
        name: 'CSE Practice',
        durationMinutes: 90,
        sectionsJson: '[]',
        totalPublishedItems: 90,
      ),
    ];
  }
}

void main() {
  late AppDatabase db;
  late MockAttemptRepo repo;
  final now = DateTime.utc(2026, 5, 20);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MockAttemptRepo(db);
  });

  tearDown(() => db.close());

  Future<MockAvailability> availability({
    required bool proIsActive,
    String examId = 'exam_cse',
  }) async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        mockBlueprintRepoProvider.overrideWithValue(_FakeMockBlueprintRepo()),
        mockEntitlementProvider.overrideWithValue(
          MockEntitlementSnapshot(proIsActive: proIsActive),
        ),
        mockAvailabilityClockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    return container.read(
      mockAvailabilityProvider(
        MockAvailabilityRequest(userId: 'user_1', examId: examId),
      ).future,
    );
  }

  Future<void> insertStarted({String id = 'mock_1'}) {
    return repo.insertStart(
      MockAttemptStart(
        id: id,
        userId: 'user_1',
        examId: 'exam_cse',
        blueprintId: 'bp_cse',
        blueprintName: 'CSE Practice',
        durationMinutes: 90,
        strictMode: false,
        sampledQuestionsJson: '[]',
        startedAt: now,
      ),
    );
  }

  Future<void> insertTerminal({required DateTime submittedAt}) async {
    await insertStarted();
    await repo.submit(
      attemptId: 'mock_1',
      status: MockAttemptStatus.completed,
      results: const MockResults(
        scoreRaw: 1,
        scoreTotal: 1,
        percent: 100,
        band: ScoreBand.pass,
        sections: [],
        topWeak: [],
        totalTimeSeconds: 60,
        wasStrict: false,
      ),
      sectionResultsJson: '{"sections":[]}',
      submittedAt: submittedAt,
    );
  }

  test('free user with no prior terminal attempt is available', () async {
    final result = await availability(proIsActive: false);

    expect(result.state, MockAvailabilityState.available);
  });

  test('free user with in-progress attempt must resume', () async {
    await insertStarted();

    final result = await availability(proIsActive: false);

    expect(result.state, MockAvailabilityState.inProgress);
    expect(result.activeAttempt!.id, 'mock_1');
  });

  test('free user before fourteen days sees cooldown remaining', () async {
    await insertTerminal(submittedAt: now.subtract(const Duration(days: 7)));

    final result = await availability(proIsActive: false);

    expect(result.state, MockAvailabilityState.cooldown);
    expect(result.cooldownRemaining!.inDays, 7);
  });

  test('free user after fourteen days is available', () async {
    await insertTerminal(submittedAt: now.subtract(const Duration(days: 14)));

    final result = await availability(proIsActive: false);

    expect(result.state, MockAvailabilityState.available);
  });

  test('discarded attempt does not start cooldown', () async {
    await insertStarted();
    await repo.discard('mock_1', now.subtract(const Duration(days: 1)));

    final result = await availability(proIsActive: false);

    expect(result.state, MockAvailabilityState.available);
  });

  test('pro user is always available unless in-progress must resume', () async {
    await insertTerminal(submittedAt: now);

    var result = await availability(proIsActive: true);
    expect(result.state, MockAvailabilityState.available);

    await insertStarted(id: 'mock_2');
    result = await availability(proIsActive: true);
    expect(result.state, MockAvailabilityState.inProgress);
  });
}
