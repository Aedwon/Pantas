import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef ContentKeyGenerator = Uint8List Function();

final class ContentKeyStore {
  ContentKeyStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    ContentKeyGenerator? generateKey,
  })  : _storage = storage,
        _generateKey = generateKey ?? _generateSecureKey;

  static const storageKey = 'pantas_content_db_key_v1';

  final FlutterSecureStorage _storage;
  final ContentKeyGenerator _generateKey;

  Future<Uint8List?> read() async {
    final encoded = await _storage.read(key: storageKey);
    if (encoded == null) return null;
    return _decodeKey(encoded);
  }

  Future<Uint8List> readOrCreate() async {
    final existing = await read();
    if (existing != null) return existing;

    final generated = generateCandidate();
    await persist(generated);
    return generated;
  }

  Uint8List generateCandidate() {
    final generated = Uint8List.fromList(_generateKey());
    if (generated.length != 32) {
      throw StateError('content key generator must return exactly 32 bytes');
    }
    return generated;
  }

  Future<void> persist(Uint8List key) async {
    final candidate = Uint8List.fromList(key);
    if (candidate.length != 32) {
      throw StateError('content key must be exactly 32 bytes');
    }
    await _storage.write(key: storageKey, value: _encodeKey(candidate));
  }

  Future<void> delete() => _storage.delete(key: storageKey);

  static Uint8List _generateSecureKey() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
  }

  static String _encodeKey(Uint8List bytes) =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  static Uint8List _decodeKey(String encoded) {
    if (encoded.length != 64 || !RegExp(r'^[0-9a-f]{64}$').hasMatch(encoded)) {
      throw const FormatException('stored content key is not canonical hex');
    }
    return Uint8List.fromList([
      for (var offset = 0; offset < encoded.length; offset += 2)
        int.parse(encoded.substring(offset, offset + 2), radix: 16),
    ]);
  }
}
