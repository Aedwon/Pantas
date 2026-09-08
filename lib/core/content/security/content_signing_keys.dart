import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

typedef ContentSigningKeyLookup = SimplePublicKey? Function(String keyId);
typedef ContentSigningKeyEntryLookup = ContentSigningKeyEntry? Function(
  String keyId,
);
typedef ContentBootstrapKeyEntryLookup = ContentBootstrapKeyEntry? Function(
  String keyId,
);

final class ContentSequenceWindow {
  const ContentSequenceWindow({
    required this.minReleaseSequence,
    this.maxReleaseSequence,
  });

  final int minReleaseSequence;
  final int? maxReleaseSequence;

  bool get isWellFormed =>
      minReleaseSequence > 0 &&
      (maxReleaseSequence == null || maxReleaseSequence! >= minReleaseSequence);

  bool contains(int releaseSequence) =>
      isWellFormed &&
      releaseSequence >= minReleaseSequence &&
      (maxReleaseSequence == null || releaseSequence <= maxReleaseSequence!);
}

final class ContentSigningKeyEntry {
  const ContentSigningKeyEntry({
    required this.keyId,
    required this.publicKey,
    required this.sequenceWindow,
  });

  final String keyId;
  final SimplePublicKey publicKey;
  final ContentSequenceWindow sequenceWindow;
}

final class ContentBootstrapKeyEntry {
  ContentBootstrapKeyEntry({
    required this.keyId,
    required Uint8List keyBytes,
    required this.sequenceWindow,
  }) : keyBytes = Uint8List.fromList(keyBytes);

  final String keyId;
  final Uint8List keyBytes;
  final ContentSequenceWindow sequenceWindow;
}

/// Public verification keys authorized for protected content packages.
///
/// No production key is present until an exact, separately authorized
/// Ed25519 public key is committed for `content-signing-v1`. Missing and
/// unknown keys deliberately fail closed.
abstract final class ContentSigningKeys {
  static SimplePublicKey? lookup(String keyId) {
    final bytes = _authorizedEd25519PublicKeys[keyId];
    if (bytes == null) return null;
    return SimplePublicKey(bytes, type: KeyPairType.ed25519);
  }

  static ContentSigningKeyEntry? lookupEntry(String keyId) {
    final publicKey = lookup(keyId);
    final sequenceWindow = _authorizedSequenceWindows[keyId];
    if (publicKey == null || sequenceWindow == null) return null;
    return ContentSigningKeyEntry(
      keyId: keyId,
      publicKey: publicKey,
      sequenceWindow: sequenceWindow,
    );
  }

  static const Map<String, List<int>> _authorizedEd25519PublicKeys =
      <String, List<int>>{};
  static const Map<String, ContentSequenceWindow> _authorizedSequenceWindows =
      <String, ContentSequenceWindow>{};
}
