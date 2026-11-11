import 'dart:typed_data';

/// A Wrapped card that the user has published to a public `pantas.study` link.
class WrappedSharedCard {
  const WrappedSharedCard({
    required this.shareId,
    required this.archetypeId,
    required this.createdAt,
    this.revoked = false,
  });

  final String shareId;
  final String archetypeId;
  final DateTime createdAt;
  final bool revoked;
}

/// Publishes and revokes hosted Wrapped cards.
///
/// Implementations live outside the domain (Firebase Storage + Firestore).
/// Keeping the contract pure lets the share flow be tested with a fake.
abstract class WrappedShareHost {
  /// Uploads the rendered PNG and creates the `wrapped_shares/<shareId>` doc.
  Future<void> publish({
    required String uid,
    required String shareId,
    required String archetypeId,
    required Uint8List pngBytes,
  });

  /// Marks the share revoked and deletes its stored image. The link then
  /// falls back to the generic marketing page.
  Future<void> revoke({required String uid, required String shareId});
}
