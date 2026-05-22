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
}

class FakeFirestoreGateway implements FirestoreGateway {
  final committedBatches = <List<FirestoreWrite>>[];

  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) async {
    committedBatches.add(List.unmodifiable(writes));
  }
}
