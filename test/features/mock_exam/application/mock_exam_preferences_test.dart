import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

void main() {
  late AppDatabase db;
  late MockExamPreferences prefs;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    prefs = MockExamPreferences(db);
  });

  tearDown(() => db.close());

  test('strict mock mode defaults to false', () async {
    expect(await prefs.strictMockMode(), isFalse);
  });

  test('strict mock mode persists in account preferences', () async {
    await prefs.setStrictMockMode(value: true);
    expect(await prefs.strictMockMode(), isTrue);

    await prefs.setStrictMockMode(value: false);
    expect(await prefs.strictMockMode(), isFalse);
  });

  test('the pause warning shows until the student has seen it', () async {
    expect(await prefs.pauseWarningSeen(), isFalse);

    await prefs.setPauseWarningSeen(value: true);
    expect(await prefs.pauseWarningSeen(), isTrue);

    await prefs.setPauseWarningSeen(value: false);
    expect(await prefs.pauseWarningSeen(), isFalse);
  });

  test('the pause warning is remembered on the device, not the account',
      () async {
    await prefs.setPauseWarningSeen(value: true);

    expect(
      await AppPreferencesRepository(db).deviceValue('mock_pause_warning_seen'),
      'true',
    );
  });

  test('startMock snapshots strict mode onto the attempt', () async {
    await prefs.setStrictMockMode(value: true);
    final repo = MockAttemptRepo(db);
    final start = StartMock(repo: repo);

    final attempt = await start(
      MockStartRequest(
        id: 'mock_1',
        userId: 'user_1',
        examId: 'exam_cse',
        blueprintId: 'bp_cse',
        blueprintName: 'CSE Practice',
        durationMinutes: 90,
        strictMode: await prefs.strictMockMode(),
        sample: const MockSample(
          expectedQuestionCount: 1,
          sections: [
            SampledMockSection(
              sectionId: 's1',
              name: 'Part 1',
              questionIds: ['q1'],
            ),
          ],
        ),
        partsTimedSeparately: false,
        parts: const [
          MockPersistedPart(
            name: '',
            startIndex: 0,
            count: 1,
            minutes: null,
          ),
        ],
        startedAt: DateTime.utc(2026, 5, 20),
      ),
    );

    expect(attempt.strictMode, isTrue);
  });
}
