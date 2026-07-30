import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fake gateway records batched set delete and root preference writes',
      () async {
    final gateway = FakeFirestoreGateway();

    await gateway.commitBatch([
      const FirestoreWrite.set(
        path: 'users/u1/quiz_attempts/a1',
        data: {'id': 'a1'},
      ),
      const FirestoreWrite.delete(path: 'users/u1/fsrs_cards/q1'),
      const FirestoreWrite.set(
        path: 'users/u1',
        data: {
          'preferences': {'reminder_time': '07:30'},
        },
      ),
    ]);

    expect(gateway.committedBatches, hasLength(1));
    expect(gateway.committedBatches.single.map((write) => write.path), [
      'users/u1/quiz_attempts/a1',
      'users/u1/fsrs_cards/q1',
      'users/u1',
    ]);
  });

  test('fake functions gateway records resetCloudUserData calls', () async {
    final gateway = FakeSyncFunctionsGateway();

    await gateway.resetCloudUserData();

    expect(gateway.resetCloudUserDataCalls, 1);
  });
}
