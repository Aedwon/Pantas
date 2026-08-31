import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/firestore/firebase_firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/model/sync_document.dart';

void main() {
  test('normalizes Firestore Timestamp values at gateway boundary', () async {
    final at = DateTime.utc(2026, 8, 29, 10, 15);
    final client = RecordingFirestoreClient()
      ..readDocumentResult = FirebaseFirestoreRawDocument(
        id: 'a',
        data: {
          'updatedAt': Timestamp.fromDate(at),
          'nested': {
            'when': Timestamp.fromDate(at),
          },
          'list': [Timestamp.fromDate(at)],
        },
      );
    final gateway = FirebaseFirestoreGateway(client: client);

    final document = await gateway.readDocument('users/u/doc/a');

    expect(document?.updatedAt, at);
    expect((document?.data['nested'] as Map)['when'], at);
    expect((document?.data['list'] as List).single, at);
  });

  test(
      'known-absent conditional create writes only when transaction sees absent',
      () async {
    final authoritativeAt = DateTime.utc(2026, 8, 29, 11);
    final client = RecordingFirestoreClient()
      ..transactionDocument = null
      ..serverReadResult = FirebaseFirestoreRawDocument(
        id: 'a',
        data: {
          'value': 1,
          'updatedAt': Timestamp.fromDate(authoritativeAt),
        },
      );
    final gateway = FirebaseFirestoreGateway(client: client);

    final result = await gateway.commitRowIfBaseMatches(
      path: 'users/u/sync_generations/g/quiz_attempts/a',
      base: const SyncCausalBase.knownAbsent(),
      data: {'value': 1, 'updatedAt': FirestoreServerTimestamp.value},
    );

    expect(result, isA<RowCommitted>());
    expect((result as RowCommitted).authoritative.updatedAt, authoritativeAt);
    expect(client.transactionWrites, hasLength(1));
    expect(
        client.serverReadPaths, ['users/u/sync_generations/g/quiz_attempts/a']);
  });

  test(
      'known-version mismatch returns normalized current state and does not write',
      () async {
    final v1 = DateTime.utc(2026, 8, 29, 10);
    final v2 = DateTime.utc(2026, 8, 29, 11);
    final client = RecordingFirestoreClient()
      ..transactionDocument = FirebaseFirestoreRawDocument(
        id: 'q',
        data: {'updatedAt': Timestamp.fromDate(v2), 'value': 2},
      );
    final gateway = FirebaseFirestoreGateway(client: client);

    final result = await gateway.commitRowIfBaseMatches(
      path: 'users/u/sync_generations/g/fsrs_cards/q',
      base: SyncCausalBase.knownVersion(v1),
      data: {'value': 3},
    );

    expect(result, isA<RowStale>());
    expect((result as RowStale).current?.updatedAt, v2);
    expect(client.transactionWrites, isEmpty);
    expect(client.serverReadPaths, isEmpty);
  });

  test('known-version match writes then server-reads authoritative timestamp',
      () async {
    final v1 = DateTime.utc(2026, 8, 29, 10);
    final v2 = DateTime.utc(2026, 8, 29, 11);
    final client = RecordingFirestoreClient()
      ..transactionDocument = FirebaseFirestoreRawDocument(
        id: 'q',
        data: {'updatedAt': Timestamp.fromDate(v1), 'value': 1},
      )
      ..serverReadResult = FirebaseFirestoreRawDocument(
        id: 'q',
        data: {'updatedAt': Timestamp.fromDate(v2), 'value': 2},
      );
    final gateway = FirebaseFirestoreGateway(client: client);

    final result = await gateway.commitRowIfBaseMatches(
      path: 'users/u/sync_generations/g/fsrs_cards/q',
      base: SyncCausalBase.knownVersion(v1),
      data: {'value': 2, 'updatedAt': FirestoreServerTimestamp.value},
    );

    expect(result, isA<RowCommitted>());
    expect((result as RowCommitted).authoritative.updatedAt, v2);
    expect(client.transactionWrites.single.path,
        'users/u/sync_generations/g/fsrs_cards/q');
  });
}

class RecordingFirestoreClient implements FirebaseFirestoreClient {
  FirebaseFirestoreRawDocument? readDocumentResult;
  FirebaseFirestoreRawDocument? transactionDocument;
  FirebaseFirestoreRawDocument? serverReadResult;
  final transactionWrites = <FirebaseFirestoreTransactionWrite>[];
  final serverReadPaths = <String>[];

  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) async {}

  @override
  Future<List<FirebaseFirestoreRawDocument>> readCollection(
          String path) async =>
      const [];

  @override
  Future<FirebaseFirestoreRawDocument?> readDocument(
    String path, {
    bool serverOnly = false,
  }) async {
    if (serverOnly) {
      serverReadPaths.add(path);
      return serverReadResult;
    }
    return readDocumentResult;
  }

  @override
  Stream<List<FirebaseFirestoreRawDocument>> watchCollection(String path) =>
      const Stream.empty();

  @override
  Stream<FirebaseFirestoreRawDocument?> watchDocument(String path) =>
      const Stream.empty();

  @override
  Future<T> runTransaction<T>(
    Future<T> Function(FirebaseFirestoreTransaction transaction) action,
  ) {
    return action(_RecordingTransaction(this));
  }
}

class _RecordingTransaction implements FirebaseFirestoreTransaction {
  _RecordingTransaction(this.client);
  final RecordingFirestoreClient client;

  @override
  Future<FirebaseFirestoreRawDocument?> readDocument(String path) async =>
      client.transactionDocument;

  @override
  void setDocument(String path, Map<String, Object?> data) {
    client.transactionWrites.add(
      FirebaseFirestoreTransactionWrite(path: path, data: data),
    );
  }
}
