import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/home/data/study_read_cache.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());
  test(
      'cache keeps original identity and never restores paid details unchecked',
      () async {
    final cache = StudyReadCache(
      db,
      uid: 'u1',
      examId: 'cse',
      coreToken: 'core1',
      isCurrent: () async => true,
    );
    await cache.write('getStudyInsights', {
      'examId': 'cse',
      'serverNow': 100,
      'accessRecheckAt': 101,
      'proCovered': true,
      'performance': {
        'overall': {'correct': 1, 'answered': 2},
        'subjects': <Object?>[],
        'topics': [
          {'id': 'paid'},
        ],
        'lessons': <Object?>[],
        'topicDetails': [
          {
            'id': 'paid-topic',
            'lessons': [
              {'read': true},
            ],
          }
        ],
      },
      'tendencies': {'hidden': 1},
      'whenYouWork': {'hidden': 1},
    });
    final restored = await cache.read('getStudyInsights');
    expect(restored?['proCovered'], false);
    expect(restored?['accessRecheckAt'], isNull);
    expect(restored?.containsKey('tendencies'), false);
    expect((restored?['performance'] as Map?)?.containsKey('topics'), false);
    expect(
      (restored?['performance'] as Map?)?.containsKey('topicDetails'),
      false,
    );
    final other = StudyReadCache(
      db,
      uid: 'u2',
      examId: 'cse',
      coreToken: 'core1',
      isCurrent: () async => true,
    );
    expect(await other.read('getStudyInsights'), isNull);
  });
  test('a retired request cannot restore cache after a wipe', () async {
    var alive = true;
    final cache = StudyReadCache(
      db,
      uid: 'u1',
      examId: 'cse',
      coreToken: 'core1',
      isCurrent: () async => alive,
    );
    alive = false;
    await expectLater(
      cache.write('getRoadmap', {'examId': 'cse'}),
      throwsStateError,
    );
    expect(await db.select(db.devicePrefs).get(), isEmpty);
  });
}
