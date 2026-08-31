import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';

class SyncCloudProgressGateway {
  SyncCloudProgressGateway(this._gateway);

  final FirestoreGateway _gateway;

  Future<bool> hasMeaningfulProgress(String uid) async {
    final pointer =
        await _gateway.readDocument('users/$uid/sync_state/current');
    if (pointer == null) return false;
    final generationId = pointer['activeGenerationId'];
    if (generationId is! String || generationId.isEmpty) {
      throw const FormatException('active Sync generation pointer missing');
    }

    for (final entry in activeSyncCollections) {
      final rows = await _gateway.readCollection(
        'users/$uid/sync_generations/$generationId/${entry.firestorePath}',
      );
      if (rows.any((row) => !row.deleted)) return true;
    }
    return false;
  }
}
