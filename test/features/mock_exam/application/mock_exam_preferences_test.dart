import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

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
    await prefs.setStrictMockMode(true);
    expect(await prefs.strictMockMode(), isTrue);

    await prefs.setStrictMockMode(false);
    expect(await prefs.strictMockMode(), isFalse);
  });

  test('startMock snapshots strict mode onto the attempt', () async {
    await prefs.setStrictMockMode(true);
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
        startedAt: DateTime.utc(2026, 5, 20),
      ),
    );

    expect(attempt.strictMode, isTrue);
  });
}
