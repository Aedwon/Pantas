import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/model/sync_document.dart';

class FirebaseFirestoreRawDocument {
  const FirebaseFirestoreRawDocument({
    required this.id,
    required this.data,
  });

  final String id;
  final Map<String, Object?> data;
}

class FirebaseFirestoreTransactionWrite {
  const FirebaseFirestoreTransactionWrite({
    required this.path,
    required this.data,
  });

  final String path;
  final Map<String, Object?> data;
}

abstract interface class FirebaseFirestoreTransaction {
  Future<FirebaseFirestoreRawDocument?> readDocument(String path);

  void setDocument(String path, Map<String, Object?> data);
}

abstract interface class FirebaseFirestoreClient {
  Future<void> commitBatch(List<FirestoreWrite> writes);

  Future<List<FirebaseFirestoreRawDocument>> readCollection(String path);

  Future<FirebaseFirestoreRawDocument?> readDocument(
    String path, {
    bool serverOnly = false,
  });

  Stream<List<FirebaseFirestoreRawDocument>> watchCollection(String path);

  Stream<FirebaseFirestoreRawDocument?> watchDocument(String path);

  Future<T> runTransaction<T>(
    Future<T> Function(FirebaseFirestoreTransaction transaction) action,
  );
}

class FirebaseFirestoreSdkClient implements FirebaseFirestoreClient {
  FirebaseFirestoreSdkClient({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) async {
    await refreshOnceAfterPermissionDenied(() => _commitBatch(writes));
  }

  Future<void> _commitBatch(List<FirestoreWrite> writes) async {
    final batch = _firestore.batch();
    for (final write in writes) {
      final reference = _firestore.doc(write.path);
      if (write.isDelete) {
        batch.delete(reference);
      } else {
        batch.set(
          reference,
          _encodeMap(write.data),
          SetOptions(merge: write.merge),
        );
      }
    }
    await batch.commit();
  }

  @override
  Future<List<FirebaseFirestoreRawDocument>> readCollection(String path) async {
    final snapshot = await refreshOnceAfterPermissionDenied(
      () => _firestore.collection(path).get(),
    );
    return [
      for (final document in snapshot.docs) _raw(document),
    ];
  }

  @override
  Future<FirebaseFirestoreRawDocument?> readDocument(
    String path, {
    bool serverOnly = false,
  }) async {
    final reference = _firestore.doc(path);
    final snapshot = serverOnly
        ? await refreshOnceAfterPermissionDenied(
            () => reference.get(const GetOptions(source: Source.server)),
          )
        : await refreshOnceAfterPermissionDenied(reference.get);
    if (!snapshot.exists) {
      return null;
    }
    return _raw(snapshot);
  }

  @override
  Stream<List<FirebaseFirestoreRawDocument>> watchCollection(String path) {
    return _firestore.collection(path).snapshots().map(
          (snapshot) => [
            for (final document in snapshot.docs) _raw(document),
          ],
        );
  }

  @override
  Stream<FirebaseFirestoreRawDocument?> watchDocument(String path) {
    return _firestore.doc(path).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return _raw(snapshot);
    });
  }

  @override
  Future<T> runTransaction<T>(
    Future<T> Function(FirebaseFirestoreTransaction transaction) action,
  ) {
    return refreshOnceAfterPermissionDenied(
      () => _firestore.runTransaction(
        (transaction) => action(
          _FirebaseFirestoreSdkTransaction(_firestore, transaction),
        ),
      ),
    );
  }

  static FirebaseFirestoreRawDocument _raw(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw const SyncGatewayException('missing-firestore-document-data');
    }
    return FirebaseFirestoreRawDocument(
      id: snapshot.id,
      data: Map<String, Object?>.from(data),
    );
  }
}

class _FirebaseFirestoreSdkTransaction implements FirebaseFirestoreTransaction {
  _FirebaseFirestoreSdkTransaction(this._firestore, this._transaction);

  final FirebaseFirestore _firestore;
  final Transaction _transaction;

  @override
  Future<FirebaseFirestoreRawDocument?> readDocument(String path) async {
    final snapshot = await _transaction.get(_firestore.doc(path));
    if (!snapshot.exists) {
      return null;
    }
    return FirebaseFirestoreSdkClient._raw(snapshot);
  }

  @override
  void setDocument(String path, Map<String, Object?> data) {
    _transaction.set(_firestore.doc(path), _encodeMap(data));
  }
}

class FirebaseFirestoreGateway implements FirestoreGateway {
  FirebaseFirestoreGateway({FirebaseFirestoreClient? client})
      : _client = client ?? FirebaseFirestoreSdkClient();

  final FirebaseFirestoreClient _client;

  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) {
    return _client.commitBatch(writes);
  }

  @override
  Future<List<SyncDocument>> readCollection(String path) async {
    return [
      for (final document in await _client.readCollection(path))
        _normalizeDocument(document),
    ];
  }

  @override
  Future<SyncDocument?> readDocument(String path) async {
    final document = await _client.readDocument(path);
    return document == null ? null : _normalizeDocument(document);
  }

  @override
  Stream<List<SyncDocument>> watchCollection(String path) {
    return _client.watchCollection(path).map(
          (documents) => [
            for (final document in documents) _normalizeDocument(document),
          ],
        );
  }

  @override
  Stream<SyncDocument?> watchDocument(String path) {
    return _client.watchDocument(path).map(
          (document) => document == null ? null : _normalizeDocument(document),
        );
  }

  @override
  Future<RowCommitResult> commitRowIfBaseMatches({
    required String path,
    required SyncCausalBase base,
    required Map<String, Object?> data,
  }) async {
    if (base.state == SyncCausalBaseState.unbound) {
      throw const SyncGatewayException('unbound-causal-base');
    }

    final stale = await _client.runTransaction<SyncDocument?>(
      (transaction) async {
        final rawCurrent = await transaction.readDocument(path);
        final current =
            rawCurrent == null ? null : _normalizeDocument(rawCurrent);
        if (!_matchesBase(base, current)) {
          return current ?? const _KnownMissingDocument().document;
        }
        transaction.setDocument(path, data);
        return null;
      },
    );

    if (stale is _MissingSyncDocument) {
      return const RowStale(null);
    }
    if (stale != null) {
      return RowStale(stale);
    }

    final authoritativeRaw = await _client.readDocument(path, serverOnly: true);
    if (authoritativeRaw == null) {
      throw const SyncGatewayException('missing-authoritative-commit');
    }
    return RowCommitted(_normalizeDocument(authoritativeRaw));
  }

  bool _matchesBase(SyncCausalBase base, SyncDocument? current) {
    return switch (base.state) {
      SyncCausalBaseState.unbound => false,
      SyncCausalBaseState.knownAbsent => current == null,
      SyncCausalBaseState.knownVersion => current != null &&
          current.updatedAt != null &&
          current.updatedAt!.isAtSameMomentAs(base.updatedAt!),
    };
  }

  static SyncDocument _normalizeDocument(FirebaseFirestoreRawDocument raw) {
    return SyncDocument(
      id: raw.id,
      data: {
        for (final entry in raw.data.entries)
          entry.key: _normalizeValue(entry.value),
      },
    );
  }

  static Object? _normalizeValue(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _normalizeValue(entry.value),
      };
    }
    if (value is List) {
      return [for (final item in value) _normalizeValue(item)];
    }
    return value;
  }
}

class _MissingSyncDocument extends SyncDocument {
  _MissingSyncDocument() : super(id: '', data: const {});
}

class _KnownMissingDocument {
  const _KnownMissingDocument();
  SyncDocument get document => _MissingSyncDocument();
}

Map<String, dynamic> _encodeMap(Map<String, Object?> source) {
  return {
    for (final entry in source.entries) entry.key: _encodeValue(entry.value),
  };
}

Object? _encodeValue(Object? value) {
  if (identical(value, FirestoreServerTimestamp.value)) {
    return FieldValue.serverTimestamp();
  }
  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key.toString(): _encodeValue(entry.value),
    };
  }
  if (value is List) {
    return [for (final item in value) _encodeValue(item)];
  }
  return value;
}
