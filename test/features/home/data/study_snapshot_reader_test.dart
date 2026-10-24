import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/data/study_read_cache.dart';
import 'package:pantas/features/home/data/study_snapshot_reader.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  test('public cached snapshot arrives before fresh paid model', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final cache = StudyReadCache(
      db,
      uid: 'old',
      examId: 'cse',
      coreToken: 'c',
      isCurrent: () async => true,
    );
    await cache.write('getRoadmap', {
      'examId': 'cse',
      'proCovered': true,
      'comingUp': {'hidden': 'old'},
    });
    final pending = Completer<Object?>();
    final reader = StudySnapshotReader(
      request: StudyRequest(
        api: StudyApi((_, data) => pending.future),
        uid: 'old',
        examId: 'cse',
        isCurrent: () async => true,
      ),
      cache: cache,
    );
    final snapshots = <Map<String, Object?>>[];
    final subscription = reader.read('getRoadmap').listen(snapshots.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(snapshots.single['proCovered'], false);
    expect(snapshots.single.containsKey('comingUp'), false);
    pending.complete({
      'examId': 'cse',
      'proCovered': true,
      'serverNow': 100,
      'accessRecheckAt': 10000,
      'comingUp': {'actual': 'fresh'},
    });
    await subscription.asFuture<void>();
    expect(snapshots.last['proCovered'], true);
    expect(snapshots.last['comingUp'], {'actual': 'fresh'});
  });
  test('response whose paid access expired in transit suppresses paid fields',
      () {
    final result = suppressExpiredStudyAccess(
      {
        'proCovered': true,
        'serverNow': 100,
        'accessRecheckAt': 105,
        'comingUp': {'secret': 1},
      },
      const Duration(milliseconds: 10),
    );
    expect(result['proCovered'], false);
    expect(result.containsKey('comingUp'), false);
  });
}
