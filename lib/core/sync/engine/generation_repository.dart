import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:pantas/core/sync/model/sync_document.dart';
import 'package:pantas/core/sync/model/sync_generation.dart';

class GenerationRepository {
  GenerationRepository({
    required FirestoreGateway gateway,
    required SyncFunctionsGateway functionsGateway,
    required String uid,
  })  : _gateway = gateway,
        _functionsGateway = functionsGateway,
        _uid = uid;

  final FirestoreGateway _gateway;
  final SyncFunctionsGateway _functionsGateway;
  final String _uid;

  Future<String?> readActiveGenerationId() async {
    final doc = await _gateway.readDocument(_currentPath);
    if (doc == null) return null;
    final value = doc['activeGenerationId'];
    if (value is! String || value.isEmpty) {
      throw const FormatException('active Sync generation pointer missing');
    }
    return value;
  }

  Future<SyncGeneration?> readGeneration(String generationId) async {
    final doc = await _gateway.readDocument(_generationPath(generationId));
    if (doc == null) return null;
    return SyncGeneration.fromMap(id: generationId, data: doc.data);
  }

  Future<SyncGeneration?> readActiveGeneration() async {
    final id = await readActiveGenerationId();
    if (id == null) return null;
    return readGeneration(id);
  }

  Future<bool> hasMeaningfulCloudData(String generationId) async {
    for (final entry in activeSyncCollections) {
      final rows = await _gateway.readCollection(
        '${_generationPath(generationId)}/${entry.firestorePath}',
      );
      if (rows.any((row) => !row.deleted)) return true;
    }
    return false;
  }

  Future<void> stageGeneration({
    required String generationId,
    required String deviceId,
    required Map<String, Object?> preferences,
  }) {
    return _gateway.commitBatch([
      FirestoreWrite.set(
        path: 'users/$_uid/limits/syncGeneration',
        merge: false,
        data: {
          'lastStagedAt': FirestoreServerTimestamp.value,
          'generationId': generationId,
        },
      ),
      FirestoreWrite.set(
        path: _generationPath(generationId),
        merge: false,
        data: {
          'status': 'staging',
          'schemaVersion': 1,
          'createdAt': FirestoreServerTimestamp.value,
          'createdByDeviceId': deviceId,
          'preferences': preferences,
        },
      ),
    ]);
  }

  Future<void> activateGeneration({
    required String generationId,
    required String? expectedActiveGenerationId,
  }) {
    return _functionsGateway.activateGeneration(
      generationId: generationId,
      expectedActiveGenerationId: expectedActiveGenerationId,
    );
  }

  String get _currentPath => 'users/$_uid/sync_state/current';

  String _generationPath(String generationId) =>
      'users/$_uid/sync_generations/$generationId';
}
