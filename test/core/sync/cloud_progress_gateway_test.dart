import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/cloud_progress_gateway.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';

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

  test('cloud progress is true when assessments has a document', () async {
    final gateway = FakeFirestoreGateway()
      ..collections['users/user-1/assessments'] = [
        {'id': 'assessment-1'},
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

  test('cloud progress is true when lesson_bookmarks has a document', () async {
    final gateway = FakeFirestoreGateway()
      ..collections['users/user-1/lesson_bookmarks'] = [
        {'lessonId': 'lesson_1'},
      ];

    expect(
      await SyncCloudProgressGateway(gateway).hasMeaningfulProgress('user-1'),
      isTrue,
    );
  });

  test('cloud progress is true when question_flags has a document', () async {
    final gateway = FakeFirestoreGateway()
      ..collections['users/user-1/question_flags'] = [
        {'questionId': 'q1'},
      ];

    expect(
      await SyncCloudProgressGateway(gateway).hasMeaningfulProgress('user-1'),
      isTrue,
    );
  });

  test('cloud progress is true when mock_exam_attempts has a document',
      () async {
    final gateway = FakeFirestoreGateway()
      ..collections['users/user-1/mock_exam_attempts'] = [
        {'id': 'mock-1'},
      ];

    expect(
      await SyncCloudProgressGateway(gateway).hasMeaningfulProgress('user-1'),
      isTrue,
    );
  });

  test('uid text is opaque to cloud progress checks', () async {
    final gateway = FakeFirestoreGateway()
      ..collections['users/anon-looking-but-named/quiz_attempts'] = [
        {'id': 'a1'},
      ];

    expect(
      await SyncCloudProgressGateway(gateway)
          .hasMeaningfulProgress('anon-looking-but-named'),
      isTrue,
    );
  });
}
