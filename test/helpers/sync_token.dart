import 'package:pantas/core/sync/engine/sync_active_context_store.dart';

/// Rotates the sync boundary token for real.
///
/// `clearStable()` keeps the token when the context is already cleared, so
/// it cannot stand in for a rotation. Publishing a context first makes the
/// following clear mint a new token.
Future<void> rotateSyncToken(SyncActiveContextStore contexts) async {
  await contexts.publishStable(uid: 'rotation-fixture', generationId: 'g');
  await contexts.clearStable();
}
