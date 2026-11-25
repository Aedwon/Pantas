import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  // P10/U60: the last point is "this week" only if it is the week of now.
  for (final scenario in [
    (name: 'on the same week', now: DateTime(2026, 10, 6), current: true),
    (
      name: 'the Saturday of that week',
      now: DateTime(2026, 10, 10, 23),
      current: true
    ),
    (name: 'the next Sunday', now: DateTime(2026, 10, 11), current: false),
    (name: 'three weeks later', now: DateTime(2026, 10, 27), current: false),
  ]) {
    test('latest week is current ${scenario.name}', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final contentDb = openTestContentDatabase();
      addTearDown(contentDb.close);
      for (final (i, day)
          in [DateTime(2026, 9, 27, 12), DateTime(2026, 10, 5, 12)].indexed) {
        await db.into(db.attemptsLocal).insert(
              AttemptsLocalCompanion.insert(
                id: 'a$i',
                examId: 'e',
                startedAt: day,
                completedAt: Value(day),
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
          contentDatabaseProvider.overrideWithValue(contentDb),
          recordNowProvider.overrideWithValue(scenario.now),
        ],
      );
      addTearDown(container.dispose);
      final record = await container.read(recordProvider.future);
      expect(record.accuracySeries, hasLength(2));
      expect(record.latestWeekIsCurrent, scenario.current);
    });
  }

  test('weekly record groups Sunday and following Monday together', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    addTearDown(contentDb.close);
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
        contentDatabaseProvider.overrideWithValue(contentDb),
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
