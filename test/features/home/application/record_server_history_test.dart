import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test(
      'web record combines server mock history once '
      'without local mock authority', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final start = DateTime(2026, 10, 24);
    await db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: 'mock_1',
            userId: 'local',
            examId: 'exam_cse_professional',
            blueprintId: 'bp',
            blueprintName: 'CSE simulation',
            durationMinutes: 120,
            status: 'completed',
            strictMode: false,
            sampledQuestionsJson: '[]',
            startedAt: start,
            lastFlushedAt: start,
            updatedAt: start,
            submittedAt: Value(start.add(const Duration(minutes: 10))),
            elapsedSeconds: const Value(600),
            scoreRaw: const Value(8),
            scoreTotal: const Value(10),
          ),
        );
    final storedRow = await db.select(db.mockAttempts).getSingle();
    final mock = MockAttempt.fromRow(storedRow);
    await db.delete(db.mockAttempts).go();
    final scope = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        mockUsesServerProvider.overrideWithValue(true),
        mockHistoryProvider.overrideWith(
          (_) => Stream.value([
            MockHistoryEntry(
              attempt: mock,
              results: const MockResults(
                scoreRaw: 8,
                scoreTotal: 10,
                percent: 80,
                sections: [
                  SectionResult(
                    sectionId: 's',
                    name: 'Science',
                    correct: 8,
                    total: 10,
                    retiredCount: 0,
                    timeSeconds: 600,
                  ),
                ],
                topWeak: [],
                totalTimeSeconds: 600,
                wasStrict: false,
              ),
            ),
          ]),
        ),
      ],
    );
    addTearDown(scope.dispose);
    final record = await scope.read(recordProvider.future);
    expect(record.questionsAnswered, 10);
    expect(record.sessionMinutes, 10);
    expect(record.bestMockPercent, 80);
    expect(record.mocks.single.blueprintName, 'CSE simulation');
    expect(record.daysActive, 1);
    expect(await db.select(db.mockAttempts).get(), isEmpty);
    final previous = MockAttempt.fromRow(
      storedRow.copyWith(
        id: 'mock_previous',
        startedAt: start.subtract(const Duration(days: 7)),
        submittedAt: Value(
          start
              .subtract(const Duration(days: 7))
              .add(const Duration(minutes: 10)),
        ),
      ),
    );
    scope.updateOverrides([
      appDatabaseProvider.overrideWithValue(db),
      mockUsesServerProvider.overrideWithValue(true),
      mockHistoryProvider.overrideWith(
        (_) => Stream.value([
          for (final m in [mock, previous])
            MockHistoryEntry(
              attempt: m,
              results: const MockResults(
                scoreRaw: 8,
                scoreTotal: 10,
                percent: 80,
                sections: [
                  SectionResult(
                    sectionId: 's',
                    name: 'Science',
                    correct: 8,
                    total: 10,
                    retiredCount: 0,
                    timeSeconds: 600,
                  ),
                ],
                topWeak: [],
                totalTimeSeconds: 600,
                wasStrict: false,
              ),
            ),
        ]),
      ),
    ]);
    await scope.pump();
    scope
      ..invalidate(mockHistoryProvider)
      ..invalidate(recordProvider);
    final updated = await scope.read(recordProvider.future);
    expect(
      updated.accuracySeries.map((p) => p.accuracy).toList(),
      [80.0, 80.0],
    );
  });
}
