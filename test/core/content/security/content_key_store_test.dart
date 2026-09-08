import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/content/security/content_key_store.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  test('uses an independent content key slot and preserves a valid key',
      () async {
    final storage = _MockSecureStorage();
    final key = Uint8List.fromList(List<int>.generate(32, (i) => i));
    final hex = key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => hex);

    final store = ContentKeyStore(storage: storage);
    expect(ContentKeyStore.storageKey, 'pantas_content_db_key_v1');
    expect(await store.read(), orderedEquals(key));
    verifyNever(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    );
  });

  test('generateCandidate returns injected bytes without touching storage', () {
    final storage = _MockSecureStorage();
    final generated = Uint8List.fromList(
      List<int>.generate(32, (i) => (i * 7 + 3) & 0xff),
    );
    final store = ContentKeyStore(
      storage: storage,
      generateKey: () => generated,
    );

    expect(store.generateCandidate(), orderedEquals(generated));
    verifyNever(() => storage.read(key: any(named: 'key')));
    verifyNever(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    );
    verifyNoMoreInteractions(storage);
  });

  test('persist writes canonical lowercase hex and read round-trips bytes',
      () async {
    final storage = _MockSecureStorage();
    final key = Uint8List.fromList(List<int>.generate(32, (i) => 0xa0 + i));
    const encoded =
        'a0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf';
    when(
      () => storage.write(
        key: ContentKeyStore.storageKey,
        value: encoded,
      ),
    ).thenAnswer((_) async {});
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => encoded);

    final store = ContentKeyStore(storage: storage);
    await store.persist(key);

    verify(
      () => storage.write(
        key: ContentKeyStore.storageKey,
        value: encoded,
      ),
    ).called(1);
    expect(await store.read(), orderedEquals(key));
    verify(() => storage.read(key: ContentKeyStore.storageKey)).called(1);
    verifyNoMoreInteractions(storage);
  });

  test('persist rejects non-32-byte input without altering storage', () async {
    final storage = _MockSecureStorage();
    final existing = Uint8List.fromList(List<int>.filled(32, 0x11));
    final encoded = '11' * 32;
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => encoded);

    final store = ContentKeyStore(storage: storage);
    expect(await store.read(), orderedEquals(existing));
    await expectLater(
      store.persist(Uint8List.fromList(List<int>.filled(31, 0x22))),
      throwsA(isA<StateError>()),
    );
    expect(await store.read(), orderedEquals(existing));

    verify(() => storage.read(key: ContentKeyStore.storageKey)).called(2);
    verifyNever(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    );
    verifyNoMoreInteractions(storage);
  });

  test('creates exactly one 32-byte per-install key when missing', () async {
    final storage = _MockSecureStorage();
    final generated = Uint8List.fromList(List<int>.filled(32, 0x5a));
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => null);
    when(
      () => storage.write(
        key: ContentKeyStore.storageKey,
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});

    final store = ContentKeyStore(
      storage: storage,
      generateKey: () => generated,
    );
    expect(await store.readOrCreate(), orderedEquals(generated));
    verify(
      () => storage.write(
        key: ContentKeyStore.storageKey,
        value: '5a' * 32,
      ),
    ).called(1);
  });

  test('malformed stored key fails closed instead of regenerating', () async {
    final storage = _MockSecureStorage();
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => 'not-a-key');

    final store = ContentKeyStore(storage: storage);
    await expectLater(store.readOrCreate(), throwsFormatException);
    verifyNever(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    );
  });

  test('delete removes only the independent content key slot', () async {
    final storage = _MockSecureStorage();
    when(() => storage.delete(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async {});

    await ContentKeyStore(storage: storage).delete();

    verify(() => storage.delete(key: ContentKeyStore.storageKey)).called(1);
    verifyNoMoreInteractions(storage);
  });
}
