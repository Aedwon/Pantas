import 'package:cryptography/cryptography.dart';

typedef ContentSigningKeyLookup = SimplePublicKey? Function(String keyId);

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

  static const Map<String, List<int>> _authorizedEd25519PublicKeys =
      <String, List<int>>{};
}
