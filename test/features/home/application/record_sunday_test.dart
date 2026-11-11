import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  test('weekly record groups Sunday and following Monday together', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final dates = [
      DateTime(2026, 9, 27, 12),
      DateTime(2026, 10, 4, 12),
      DateTime(2026, 10, 5, 12),
    ];
    for (var i = 0; i < dates.length; i++) {
      await db.into(db.attemptsLocal).insert(
            AttemptsLocalCompanion.insert(
              id: 'a$i',
              examId: 'e',
              startedAt: dates[i],
              completedAt: Value(dates[i]),
              itemsJson: jsonEncode([
                {
                  'questionId': 'q$i',
                  'chosenChoiceId': 'a',
                  'correctChoiceId': 'a',
                  'responseMs': 100,
                  'questionVersion': 1,
                }
              ]),
            ),
          );
    }
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        recordNowProvider.overrideWithValue(DateTime(2026, 10, 6)),
      ],
    );
    addTearDown(container.dispose);
    final record = await container.read(recordProvider.future);
    expect(
      record.accuracySeries.map((p) => p.weekStart),
      [DateTime(2026, 9, 27), DateTime(2026, 10, 4)],
    );
    expect(record.accuracySeries.every((p) => p.accuracy == 100), true);
  });
}
