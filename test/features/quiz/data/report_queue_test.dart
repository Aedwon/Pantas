import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/data/report_queue.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('reports survive reopening and the fourth for a question is refused',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = ReportQueue(db);
    final now = DateTime(2026, 10, 12, 23);
    for (var i = 0; i < 3; i++) {
      expect(await queue.add('q', '  Concern $i  ', now), ReportResult.queued);
    }
    expect(await queue.add('q', 'Fourth', now), ReportResult.questionLimit);
    final reopened = ReportQueue(db);
    final reports = await reopened.pending();
    expect(reports, hasLength(3));
    expect(reports.first.message, 'Concern 0');
    await reopened.sendPending();
    expect(await reopened.pending(), hasLength(3));
  });

  test('twenty per local day, reset at midnight, blank does not use a slot',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = ReportQueue(db);
    final now = DateTime(2026, 10, 12, 23, 59);
    expect(await queue.add('q', '   ', now), ReportResult.empty);
    await Future.wait([
      for (var i = 0; i < 20; i++) queue.add('q$i', 'Concern', now),
    ]);
    expect(await queue.add('new', 'Concern', now), ReportResult.dailyLimit);
    expect(
      await queue.add('new', 'Concern', DateTime(2026, 10, 13)),
      ReportResult.queued,
    );
    expect(await queue.pending(), hasLength(21));
  });
}
