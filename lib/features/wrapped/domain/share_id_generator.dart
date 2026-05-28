import 'dart:math';

/// Generates the unguessable token embedded in a Wrapped share link.
///
/// A `shareId` is a random 128-bit value rendered as 32 lowercase hex
/// characters. At expected volume the collision probability is negligible,
/// so no collision handling is performed (landing-page spec §8.3).
class ShareIdGenerator {
  ShareIdGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  /// Returns a fresh 32-character lowercase hex token (128 bits of entropy).
  String generate() {
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
