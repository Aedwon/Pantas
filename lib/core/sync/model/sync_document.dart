import 'dart:collection';

class FirestoreServerTimestamp {
  const FirestoreServerTimestamp._();

  static const value = FirestoreServerTimestamp._();
}

class SyncDocument extends MapBase<String, Object?> {
  SyncDocument({required this.id, required Map<String, Object?> data})
      : data = Map.unmodifiable(data);

  final String id;
  final Map<String, Object?> data;

  DateTime? get updatedAt {
    final value = data['updatedAt'];
    return value is DateTime ? value : null;
  }

  bool get deleted => data['deleted'] == true;

  String? get originDeviceId {
    final value = data['originDeviceId'];
    return value is String ? value : null;
  }

  String? get mutationId {
    final value = data['mutationId'];
    return value is String ? value : null;
  }

  @override
  Object? operator [](Object? key) => data[key];

  @override
  void operator []=(String key, Object? value) {
    throw UnsupportedError('SyncDocument is immutable.');
  }

  @override
  void clear() {
    throw UnsupportedError('SyncDocument is immutable.');
  }

  @override
  Iterable<String> get keys => data.keys;

  @override
  Object? remove(Object? key) {
    throw UnsupportedError('SyncDocument is immutable.');
  }
}

sealed class RowCommitResult {
  const RowCommitResult();
}

class RowCommitted extends RowCommitResult {
  const RowCommitted(this.authoritative);

  final SyncDocument authoritative;
}

class RowStale extends RowCommitResult {
  const RowStale(this.current);

  final SyncDocument? current;
}
