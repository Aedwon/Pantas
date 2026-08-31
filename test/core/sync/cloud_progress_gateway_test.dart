import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/cloud_progress_gateway.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';

void main() {
  test('no active generation means no meaningful cloud progress', () async {
    expect(
      await SyncCloudProgressGateway(FakeFirestoreGateway())
          .hasMeaningfulProgress('user-1'),
      isFalse,
    );
  });

  test('preferences-only active generation does not force meaningful conflict',
      () async {
    final gateway = FakeFirestoreGateway()
      ..documents['users/user-1/sync_state/current'] = {
        'activeGenerationId': 'gen-1',
        'schemaVersion': 1,
        'updatedAt': DateTime.utc(2026, 8, 30),
      }
      ..documents['users/user-1/sync_generations/gen-1'] = {
        'status': 'active',
        'schemaVersion': 1,
        'createdAt': DateTime.utc(2026, 8, 29),
        'createdByDeviceId': 'device-cloud',
        'preferences': {'reminder_time': '07:30'},
      };

    expect(
      await SyncCloudProgressGateway(gateway).hasMeaningfulProgress('user-1'),
      isFalse,
    );
  });

  test('only non-deleted data in active generation counts', () async {
    final gateway = FakeFirestoreGateway()
      ..documents['users/user-1/sync_state/current'] = {
        'activeGenerationId': 'gen-active',
      }
      ..collections['users/user-1/sync_generations/gen-old/lesson_progress'] = [
        {'lessonId': 'old', 'deleted': false},
      ]
      ..collections[
          'users/user-1/sync_generations/gen-active/lesson_progress'] = [
        {'lessonId': 'deleted', 'deleted': true},
      ];

    expect(
      await SyncCloudProgressGateway(gateway).hasMeaningfulProgress('user-1'),
      isFalse,
    );

    gateway.collections[
        'users/user-1/sync_generations/gen-active/lesson_progress'] = [
      {'lessonId': 'live', 'deleted': false},
    ];
    expect(
      await SyncCloudProgressGateway(gateway).hasMeaningfulProgress('user-1'),
      isTrue,
    );
  });
}
