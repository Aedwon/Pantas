import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
    expect((document!.data['nested']! as Map)['when'], at);
    expect((document.data['list']! as List).single, at);
  });

  group('the SDK client reads only what the server confirmed', () {
    late _MockFirestore firestore;
    late _MockCollection collection;

    setUpAll(() {
      registerFallbackValue(const GetOptions());
    });

    setUp(() {
      firestore = _MockFirestore();
      collection = _MockCollection();
      when(() => firestore.collection('c')).thenReturn(collection);
    });

    _MockQuerySnapshot snapshot({required bool fromCache}) {
      final metadata = _MockMetadata();
      when(() => metadata.isFromCache).thenReturn(fromCache);
      final result = _MockQuerySnapshot();
      when(() => result.metadata).thenReturn(metadata);
      when(() => result.docs).thenReturn(const []);
      return result;
    }

    test('a cached copy never reaches the engine', () async {
      when(() => collection.snapshots(includeMetadataChanges: true)).thenAnswer(
        (_) => Stream.fromIterable([
          snapshot(fromCache: true),
          snapshot(fromCache: false),
          snapshot(fromCache: true),
        ]),
      );

      final delivered = await FirebaseFirestoreSdkClient(firestore: firestore)
          .watchCollection('c')
          .toList();

      expect(delivered, hasLength(1));
    });

    test('a collection read asks the server and reports being offline',
        () async {
      when(() => collection.get(any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      await expectLater(
        FirebaseFirestoreSdkClient(firestore: firestore).readCollection('c'),
        throwsA(
          isA<SyncGatewayException>()
              .having((e) => e.code, 'code', 'unavailable'),
        ),
      );
      final options = verify(() => collection.get(captureAny())).captured.single
          as GetOptions;
      expect(options.source, Source.server);
    });
  });

  group('native server timestamps carry microseconds', () {
    // Row metadata and the journal store milliseconds.
    final stored = DateTime.utc(2026, 11, 5, 1, 2, 3, 123);
    final micros = Timestamp.fromDate(
      DateTime.utc(2026, 11, 5, 1, 2, 3, 123, 456),
    );

    test('a row version is read at the precision it is stored', () async {
      final client = RecordingFirestoreClient()
        ..readDocumentResult = FirebaseFirestoreRawDocument(
          id: 'a',
          data: {'updatedAt': micros},
        );

      final document = await FirebaseFirestoreGateway(client: client)
          .readDocument('users/u/doc/a');

      expect(document?.updatedAt, stored);
    });

    test('an edit against the unchanged row is not treated as stale', () async {
      final client = RecordingFirestoreClient()
        ..transactionDocument = FirebaseFirestoreRawDocument(
          id: 'a',
          data: {'updatedAt': micros},
        )
        ..serverReadResult = FirebaseFirestoreRawDocument(
          id: 'a',
          data: {'updatedAt': micros},
        );

      final result =
          await FirebaseFirestoreGateway(client: client).commitRowIfBaseMatches(
        path: 'users/u/sync_generations/g/lesson_bookmarks/a',
        base: SyncCausalBase.knownVersion(stored),
        data: {'updatedAt': FirestoreServerTimestamp.value},
      );

      expect(result, isA<RowCommitted>());
    });

    test('a different millisecond is still stale', () async {
      final client = RecordingFirestoreClient()
        ..transactionDocument = FirebaseFirestoreRawDocument(
          id: 'a',
          data: {'updatedAt': micros},
        );

      final result =
          await FirebaseFirestoreGateway(client: client).commitRowIfBaseMatches(
        path: 'users/u/sync_generations/g/lesson_bookmarks/a',
        base: SyncCausalBase.knownVersion(
          stored.subtract(const Duration(milliseconds: 1)),
        ),
        data: {'updatedAt': FirestoreServerTimestamp.value},
      );

      expect(result, isA<RowStale>());
    });

    test('other timestamps keep their precision', () async {
      final client = RecordingFirestoreClient()
        ..readDocumentResult = FirebaseFirestoreRawDocument(
          id: 'a',
          data: {'markedAt': micros},
        );

      final document = await FirebaseFirestoreGateway(client: client)
          .readDocument('users/u/doc/a');

      expect(document!.data['markedAt'], micros.toDate().toUtc());
    });
  });

  test(
      'known-absent conditional create writes only when transaction sees '
      'absent', () async {
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
      client.serverReadPaths,
      ['users/u/sync_generations/g/quiz_attempts/a'],
    );
  });

  test(
      'known-version mismatch returns normalized current state and does not '
      'write', () async {
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
    expect(
      client.transactionWrites.single.path,
      'users/u/sync_generations/g/fsrs_cards/q',
    );
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
    String path,
  ) async =>
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

// ignore_for_file: subtype_of_sealed_class
class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class _MockMetadata extends Mock implements SnapshotMetadata {}
