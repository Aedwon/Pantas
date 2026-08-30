import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/model/sync_document.dart';

class FirestoreWrite {
  const FirestoreWrite.set({
    required this.path,
    required this.data,
    this.merge = true,
  }) : isDelete = false;

  const FirestoreWrite.delete({required this.path})
      : data = const {},
        merge = false,
        isDelete = true;

  final String path;
  final Map<String, Object?> data;
  final bool merge;
  final bool isDelete;
}

abstract interface class FirestoreGateway {
  Future<void> commitBatch(List<FirestoreWrite> writes);

  Future<List<SyncDocument>> readCollection(String path);

  Future<SyncDocument?> readDocument(String path);

  Stream<List<SyncDocument>> watchCollection(String path);

  Stream<SyncDocument?> watchDocument(String path);

  Future<RowCommitResult> commitRowIfBaseMatches({
    required String path,
    required SyncCausalBase base,
    required Map<String, Object?> data,
  });
}

class SyncGatewayException implements Exception {
  const SyncGatewayException(this.code, {this.details});

  final String code;
  final Map<String, Object?>? details;

  @override
  String toString() => 'SyncGatewayException($code)';
}

class FakeFirestoreGateway implements FirestoreGateway {
  FakeFirestoreGateway({DateTime Function()? serverNow})
      : _serverNow = serverNow ?? DateTime.now;

  final DateTime Function() _serverNow;
  final committedBatches = <List<FirestoreWrite>>[];
  final collections = <String, List<Map<String, Object?>>>{};
  final documents = <String, Map<String, Object?>>{};

  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) async {
    committedBatches.add(List.unmodifiable(writes));
    for (final write in writes) {
      if (write.isDelete) {
        documents.remove(write.path);
      } else {
        documents[write.path] = _resolveServerTimestamps(write.data);
      }
    }
  }

  @override
  Future<List<SyncDocument>> readCollection(String path) async {
    final rows = collections[path] ?? const [];
    return [
      for (var index = 0; index < rows.length; index += 1)
        SyncDocument(
          id: _rowId(rows[index], index),
          data: rows[index],
        ),
    ];
  }

  @override
  Future<SyncDocument?> readDocument(String path) async {
    final data = documents[path];
    if (data == null) {
      return null;
    }
    return SyncDocument(id: _pathId(path), data: data);
  }

  @override
  Stream<List<SyncDocument>> watchCollection(String path) async* {
    yield await readCollection(path);
  }

  @override
  Stream<SyncDocument?> watchDocument(String path) async* {
    yield await readDocument(path);
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

    final current = await readDocument(path);
    if (!_matchesBase(base, current)) {
      return RowStale(current);
    }

    final authoritative = _resolveServerTimestamps(data);
    documents[path] = authoritative;
    return RowCommitted(
      SyncDocument(id: _pathId(path), data: authoritative),
    );
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

  Map<String, Object?> _resolveServerTimestamps(Map<String, Object?> source) {
    return {
      for (final entry in source.entries) entry.key: _resolveValue(entry.value),
    };
  }

  Object? _resolveValue(Object? value) {
    if (identical(value, FirestoreServerTimestamp.value)) {
      return _serverNow().toUtc();
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _resolveValue(entry.value),
      };
    }
    if (value is List) {
      return [for (final item in value) _resolveValue(item)];
    }
    return value;
  }

  static String _pathId(String path) => path.split('/').last;

  static String _rowId(Map<String, Object?> row, int index) {
    for (final key in const [
      'id',
      'examId',
      'questionId',
      'lessonId',
      'topicId',
    ]) {
      final value = row[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return index.toString();
  }
}
