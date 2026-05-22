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

  Future<List<Map<String, Object?>>> readCollection(String path);

  Future<Map<String, Object?>?> readDocument(String path);
}

class SyncGatewayException implements Exception {
  const SyncGatewayException(this.code);

  final String code;
}

class FakeFirestoreGateway implements FirestoreGateway {
  final committedBatches = <List<FirestoreWrite>>[];
  final collections = <String, List<Map<String, Object?>>>{};
  final documents = <String, Map<String, Object?>>{};

  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) async {
    committedBatches.add(List.unmodifiable(writes));
  }

  @override
  Future<List<Map<String, Object?>>> readCollection(String path) async {
    return collections[path] ?? const [];
  }

  @override
  Future<Map<String, Object?>?> readDocument(String path) async {
    return documents[path];
  }
}
