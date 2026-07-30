import 'package:pantas/core/sync/cloud_progress_gateway.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cloud progress is false when all meaningful collections are empty',
      () async {
    final gateway = FakeFirestoreGateway();

    expect(
      await SyncCloudProgressGateway(gateway).hasMeaningfulProgress('user-1'),
      isFalse,
    );
  });

  test('cloud progress is true when quiz_attempts has a document', () async {
    final gateway = FakeFirestoreGateway()
      ..collections['users/user-1/quiz_attempts'] = [
        {'id': 'a1'},
      ];

    expect(
      await SyncCloudProgressGateway(gateway).hasMeaningfulProgress('user-1'),
      isTrue,
    );
  });

  test('cloud progress is true when lesson_progress has a document', () async {
    final gateway = FakeFirestoreGateway()
      ..collections['users/user-1/lesson_progress'] = [
        {'lessonId': 'lesson_1'},
      ];

    expect(
      await SyncCloudProgressGateway(gateway).hasMeaningfulProgress('user-1'),
      isTrue,
    );
  });

  test('cloud progress is true when fsrs_cards has a document', () async {
    final gateway = FakeFirestoreGateway()
      ..collections['users/user-1/fsrs_cards'] = [
        {'questionId': 'q1'},
      ];

    expect(
      await SyncCloudProgressGateway(gateway).hasMeaningfulProgress('user-1'),
      isTrue,
    );
  });

  test('anonymous uid checks are rejected before Firestore call', () async {
    final gateway = FakeFirestoreGateway();

    expect(
      () => SyncCloudProgressGateway(gateway).hasMeaningfulProgress('anon-1'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
