import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hashes;
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/content/bundle/protected_content_installer.dart';
import 'package:pantas/core/content/content_database_opener.dart';
import 'package:pantas/core/content/security/content_cipher_profile.dart';
import 'package:pantas/core/content/security/content_key_store.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';
import 'package:pantas/core/content/security/content_package_verifier.dart';
import 'package:pantas/core/content/security/content_signing_keys.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../tools/build_content_package/build_content_package.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _StaticVerifier implements ContentPackageVerifier {
  _StaticVerifier(this.package);

  final VerifiedContentPackage package;

  @override
  Future<VerifiedContentPackage> verifyBundled() async => package;
}

void main() {
  test('installer consumes ContentPackageVerifier and rejects bad schema',
      () async {
    final temp = Directory.systemTemp.createTempSync('pantas_bad_schema_');
    addTearDown(() => temp.deleteSync(recursive: true));

    final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x31));
    final installKey = Uint8List.fromList(List<int>.filled(32, 0x62));
    final invalid = File('${temp.path}/invalid.db');
    sqlite3.open(invalid.path)
      ..execute('PRAGMA user_version = 7')
      ..close();
    ContentCipherProfile.protectPlaintextFile(invalid, bootstrapKey);

    final package = VerifiedContentPackage(
      manifest: ContentPackageManifest.production(
        releaseSequence: 1,
        sourceContentSha256: 'a' * 64,
        payloadSha256: 'b' * 64,
      ),
      payloadBytes: invalid.readAsBytesSync(),
      bootstrapKeyBytes: bootstrapKey,
      manifestSha256: 'c' * 64,
      signatureSha256: 'd' * 64,
    );
    final storage = _MockSecureStorage();
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => null);
    var writes = 0;
    when(
      () => storage.write(
        key: ContentKeyStore.storageKey,
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {
      writes++;
    });

    final installRoot = Directory('${temp.path}/installed');
    await expectLater(
      ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: ContentKeyStore(
          storage: storage,
          generateKey: () => installKey,
        ),
        directory: installRoot,
      ),
      throwsFormatException,
    );
    expect(File('${installRoot.path}/content.db').existsSync(), isFalse);
    expect(
      File('${installRoot.path}/content.db.pending').existsSync(),
      isFalse,
    );
    expect(
      writes,
      0,
      reason: 'invalid bootstrap/schema must not create a content key',
    );
    expect(_protectedResidueNames(installRoot), isEmpty);
  });

  test(
      'schema validation covers every ContentDatabase table before key '
      'creation', () async {
    final temp = Directory.systemTemp.createTempSync('pantas_bad_shape_');
    addTearDown(() => temp.deleteSync(recursive: true));

    final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x21));
    final installKey = Uint8List.fromList(List<int>.filled(32, 0x42));
    final signingSeed =
        Uint8List.fromList(List<int>.generate(32, (i) => 0x60 + i));
    final built = await buildContentPackage(
      releaseSequence: 2,
      inputJson: File('test/fixtures/sanity/content_sample.json'),
      outputDirectory: Directory('${temp.path}/bundle'),
      bootstrapKey: bootstrapKey,
      signingPrivateKeySeed: signingSeed,
      versionFile: File('${temp.path}/content_seed_version.dart'),
    );
    final db = ContentCipherProfile.open(built.payload, bootstrapKey);
    try {
      db.execute('DROP TABLE content_choices');
    } finally {
      db.close();
    }

    final package = VerifiedContentPackage(
      manifest: ContentPackageManifest.production(
        releaseSequence: 2,
        sourceContentSha256: '1' * 64,
        payloadSha256: '2' * 64,
      ),
      payloadBytes: built.payload.readAsBytesSync(),
      bootstrapKeyBytes: bootstrapKey,
      manifestSha256: '3' * 64,
      signatureSha256: '4' * 64,
    );
    final storage = _MockSecureStorage();
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => null);
    var writes = 0;
    when(
      () => storage.write(
        key: ContentKeyStore.storageKey,
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {
      writes++;
    });
    final installRoot = Directory('${temp.path}/installed');

    await expectLater(
      ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: ContentKeyStore(
          storage: storage,
          generateKey: () => installKey,
        ),
        directory: installRoot,
      ),
      throwsFormatException,
    );

    expect(File('${installRoot.path}/content.db').existsSync(), isFalse);
    expect(
      File('${installRoot.path}/content.db.pending').existsSync(),
      isFalse,
    );
    expect(
      writes,
      0,
      reason: 'incomplete schema must not create a content key',
    );
    expect(_protectedResidueNames(installRoot), isEmpty);
  });

  test('corpus mismatch fails closed and preserves user database sentinel',
      () async {
    final temp = Directory.systemTemp.createTempSync('pantas_bad_corpus_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final installRoot = Directory('${temp.path}/installed')..createSync();
    final userDb = File('${installRoot.path}/pantas.db')
      ..writeAsBytesSync(const [1, 2, 3, 4]);

    final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x21));
    final installKey = Uint8List.fromList(List<int>.filled(32, 0x42));
    final signingSeed =
        Uint8List.fromList(List<int>.generate(32, (i) => 0x20 + i));
    final built = await buildContentPackage(
      releaseSequence: 3,
      inputJson: File('test/fixtures/sanity/content_sample.json'),
      outputDirectory: Directory('${temp.path}/bundle'),
      bootstrapKey: bootstrapKey,
      signingPrivateKeySeed: signingSeed,
      versionFile: File('${temp.path}/content_seed_version.dart'),
    );
    final db = ContentCipherProfile.open(built.payload, bootstrapKey);
    try {
      db.execute('DELETE FROM content_exams');
    } finally {
      db.close();
    }

    final package = VerifiedContentPackage(
      manifest: ContentPackageManifest.production(
        releaseSequence: 3,
        sourceContentSha256: '1' * 64,
        payloadSha256: '2' * 64,
      ),
      payloadBytes: built.payload.readAsBytesSync(),
      bootstrapKeyBytes: bootstrapKey,
      manifestSha256: '3' * 64,
      signatureSha256: '4' * 64,
    );
    final storage = _MockSecureStorage();
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => null);
    var writes = 0;
    when(
      () => storage.write(
        key: ContentKeyStore.storageKey,
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {
      writes++;
    });

    await expectLater(
      ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: ContentKeyStore(
          storage: storage,
          generateKey: () => installKey,
        ),
        directory: installRoot,
      ),
      throwsFormatException,
    );

    expect(File('${installRoot.path}/content.db').existsSync(), isFalse);
    expect(
      File('${installRoot.path}/content.db.pending').existsSync(),
      isFalse,
    );
    expect(userDb.readAsBytesSync(), const [1, 2, 3, 4]);
    expect(writes, 0, reason: 'invalid corpus must not create a content key');
    expect(_protectedResidueNames(installRoot), isEmpty);
  });

  test('wrong bootstrap key fails before promotion and cleans pending',
      () async {
    final temp = Directory.systemTemp.createTempSync('pantas_wrong_bootstrap_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final actualBootstrap = Uint8List.fromList(List<int>.filled(32, 0x11));
    final wrongBootstrap = Uint8List.fromList(List<int>.filled(32, 0x12));
    final installKey = Uint8List.fromList(List<int>.filled(32, 0x13));
    final encrypted = File('${temp.path}/encrypted.db');
    sqlite3.open(encrypted.path)
      ..execute('PRAGMA user_version = 8')
      ..close();
    ContentCipherProfile.protectPlaintextFile(encrypted, actualBootstrap);

    final package = VerifiedContentPackage(
      manifest: ContentPackageManifest.production(
        releaseSequence: 3,
        sourceContentSha256: '5' * 64,
        payloadSha256: '6' * 64,
      ),
      payloadBytes: encrypted.readAsBytesSync(),
      bootstrapKeyBytes: wrongBootstrap,
      manifestSha256: '7' * 64,
      signatureSha256: '8' * 64,
    );
    final storage = _MockSecureStorage();
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => null);
    var writes = 0;
    when(
      () => storage.write(
        key: ContentKeyStore.storageKey,
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {
      writes++;
    });
    final installRoot = Directory('${temp.path}/installed');

    await expectLater(
      ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: ContentKeyStore(
          storage: storage,
          generateKey: () => installKey,
        ),
        directory: installRoot,
      ),
      throwsA(anything),
    );
    expect(File('${installRoot.path}/content.db').existsSync(), isFalse);
    expect(
      File('${installRoot.path}/content.db.pending').existsSync(),
      isFalse,
    );
    expect(
      writes,
      0,
      reason: 'wrong bootstrap key must not create a content key',
    );
    expect(_protectedResidueNames(installRoot), isEmpty);
  });

  test('tampered bundled payload is rejected before any content write',
      () async {
    final temp = Directory.systemTemp.createTempSync('pantas_tampered_bundle_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x71));
    final signingSeed =
        Uint8List.fromList(List<int>.generate(32, (i) => 0x40 + i));
    final built = await buildContentPackage(
      releaseSequence: 4,
      inputJson: File('test/fixtures/sanity/content_sample.json'),
      outputDirectory: Directory('${temp.path}/bundle'),
      bootstrapKey: bootstrapKey,
      signingPrivateKeySeed: signingSeed,
      versionFile: File('${temp.path}/content_seed_version.dart'),
    );
    final publicKey = await (await Ed25519().newKeyPairFromSeed(signingSeed))
        .extractPublicKey();
    final verifier = BundledContentPackageVerifier(
      loadAssetBytes: (path) async {
        if (path == ContentPackageAssets.manifestPath) {
          return built.manifest.readAsBytes();
        }
        if (path == ContentPackageAssets.signaturePath) {
          return built.signature.readAsBytes();
        }
        if (path == ContentPackageAssets.payloadPath) {
          final bytes = await built.payload.readAsBytes();
          bytes[0] ^= 0xff;
          return bytes;
        }
        throw StateError('unexpected asset: $path');
      },
      signingKeyLookup: (id) => ContentSigningKeyEntry(
        keyId: id,
        publicKey: publicKey,
        sequenceWindow: const ContentSequenceWindow(minReleaseSequence: 1),
      ),
      bootstrapKeyLookup: (id) => ContentBootstrapKeyEntry(
        keyId: id,
        keyBytes: bootstrapKey,
        sequenceWindow: const ContentSequenceWindow(minReleaseSequence: 1),
      ),
    );
    final installRoot = Directory('${temp.path}/installed')..createSync();
    final userDb = File('${installRoot.path}/pantas.db')
      ..writeAsBytesSync(const [9, 8, 7]);

    await expectLater(
      ensureProtectedContentInstalled(
        verifier: verifier,
        directory: installRoot,
      ),
      throwsFormatException,
    );
    expect(File('${installRoot.path}/content.db').existsSync(), isFalse);
    expect(
      File('${installRoot.path}/content.db.pending').existsSync(),
      isFalse,
    );
    expect(userDb.readAsBytesSync(), const [9, 8, 7]);
    expect(_protectedResidueNames(installRoot), isEmpty);
  });

  test(
      'fresh install rekeys authenticated encrypted payload and opens keyed DB',
      () async {
    final temp =
        Directory.systemTemp.createTempSync('pantas_protected_install_');
    addTearDown(() => temp.deleteSync(recursive: true));

    final bootstrapKey =
        Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
    final installKey = Uint8List.fromList(List<int>.filled(32, 0x5a));
    final signingSeed =
        Uint8List.fromList(List<int>.generate(32, (i) => 0xc0 - i));
    final built = await buildContentPackage(
      releaseSequence: 7,
      inputJson: File('test/fixtures/sanity/content_sample.json'),
      outputDirectory: Directory('${temp.path}/bundle'),
      bootstrapKey: bootstrapKey,
      signingPrivateKeySeed: signingSeed,
      versionFile: File('${temp.path}/content_seed_version.dart'),
    );
    final publicKey = await (await Ed25519().newKeyPairFromSeed(signingSeed))
        .extractPublicKey();
    final verifier = BundledContentPackageVerifier(
      loadAssetBytes: (path) async {
        if (path == ContentPackageAssets.manifestPath) {
          return built.manifest.readAsBytes();
        }
        if (path == ContentPackageAssets.signaturePath) {
          return built.signature.readAsBytes();
        }
        if (path == ContentPackageAssets.payloadPath) {
          return built.payload.readAsBytes();
        }
        throw StateError('unexpected asset: $path');
      },
      signingKeyLookup: (id) => ContentSigningKeyEntry(
        keyId: id,
        publicKey: publicKey,
        sequenceWindow: const ContentSequenceWindow(minReleaseSequence: 1),
      ),
      bootstrapKeyLookup: (id) => ContentBootstrapKeyEntry(
        keyId: id,
        keyBytes: bootstrapKey,
        sequenceWindow: const ContentSequenceWindow(minReleaseSequence: 1),
      ),
    );

    final storage = _MockSecureStorage();
    String? storedKey;
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => storedKey);
    when(
      () => storage.write(
        key: ContentKeyStore.storageKey,
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      storedKey = invocation.namedArguments[#value] as String?;
    });
    final keyStore = ContentKeyStore(
      storage: storage,
      generateKey: () => installKey,
    );
    final installRoot = Directory('${temp.path}/installed');

    final result = await ensureProtectedContentInstalled(
      verifier: verifier,
      keyStore: keyStore,
      directory: installRoot,
    );

    expect(result.decision, ContentInstallDecision.freshInstall);
    expect(result.activeFile.existsSync(), isTrue);
    expect(
      File('${installRoot.path}/content.db.pending').existsSync(),
      isFalse,
    );
    expect(_protectedResidueNames(installRoot), isEmpty);
    expect(storedKey, isNotNull);

    final source = ContentCipherProfile.open(built.payload, bootstrapKey);
    final keyed = ContentCipherProfile.open(result.activeFile, installKey);
    try {
      expect(keyed.select('PRAGMA user_version').single.values.single, 9);
      expect(_corpusSnapshot(keyed), _corpusSnapshot(source));
    } finally {
      keyed.close();
      source.close();
    }

    final ordinary = sqlite3.open(result.activeFile.path);
    try {
      expect(
        () => ordinary.select('SELECT count(*) FROM sqlite_schema'),
        throwsA(anything),
      );
    } finally {
      ordinary.close();
    }

    final reopened = await openProtectedContentDatabase(
      file: result.activeFile,
      keyStore: keyStore,
    );
    expect(await reopened.select(reopened.contentExams).get(), isNotEmpty);
    await reopened.close();

    final missingStorage = _MockSecureStorage();
    when(() => missingStorage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => null);
    await expectLater(
      openProtectedContentDatabase(
        file: result.activeFile,
        keyStore: ContentKeyStore(storage: missingStorage),
      ),
      throwsStateError,
    );

    final wrongStorage = _MockSecureStorage();
    when(() => wrongStorage.read(key: ContentKeyStore.storageKey)).thenAnswer(
      (_) async => List<String>.filled(64, '0').join(),
    );
    await expectLater(
      openProtectedContentDatabase(
        file: result.activeFile,
        keyStore: ContentKeyStore(storage: wrongStorage),
      ),
      throwsA(anything),
    );
  });

  test('fresh install persists complete device-local accepted package record',
      () async {
    final temp = Directory.systemTemp.createTempSync('pantas_accepted_state_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x21));
    final installKey = Uint8List.fromList(List<int>.filled(32, 0x42));
    final package = await _buildVerifiedPackage(
      temp: temp,
      tag: 'accepted',
      releaseSequence: 10,
      bootstrapKey: bootstrapKey,
      signingSeedByte: 0x31,
    );
    final harness = _KeyStoreHarness(installKey);
    final installRoot = Directory('${temp.path}/installed');

    await ensureProtectedContentInstalled(
      verifier: _StaticVerifier(package),
      keyStore: harness.keyStore,
      directory: installRoot,
    );

    final stateFile = File('${installRoot.path}/content.install-state.json');
    expect(stateFile.existsSync(), isTrue);
    final state =
        jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
    final accepted = state['accepted'] as Map<String, dynamic>;
    final manifest = package.manifest;
    expect(accepted['formatVersion'], manifest.formatVersion);
    expect(accepted['releaseSequence'], manifest.releaseSequence);
    expect(accepted['sourceContentSha256'], manifest.sourceContentSha256);
    expect(accepted['contentSeedVersion'], manifest.contentSeedVersion);
    expect(accepted['payloadSha256'], manifest.payloadSha256);
    expect(accepted['manifestSha256'], package.manifestSha256);
    expect(accepted['signatureSha256'], package.signatureSha256);
    expect(accepted['signingKeyId'], manifest.signingKeyId);
    expect(accepted['bootstrapKeyId'], manifest.bootstrapKeyId);
    expect(accepted['cipherProfile'], manifest.cipherProfile);
    expect(accepted['contentSchemaVersion'], manifest.contentSchemaVersion);
    expect(accepted['readerSchemaMin'], manifest.readerSchemaMin);
    expect(accepted['readerSchemaMax'], manifest.readerSchemaMax);
    expect(state['previousAccepted'], isNull);
    expect(state['promotion'], isNull);
  });

  test(
      'accepted state enforces replay fork idempotence and signed sequence '
      'upgrade', () async {
    final temp = Directory.systemTemp.createTempSync('pantas_chronology_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x51));
    final installKey = Uint8List.fromList(List<int>.filled(32, 0x52));
    final harness = _KeyStoreHarness(installKey);
    final installRoot = Directory('${temp.path}/installed');
    final accepted = await _buildVerifiedPackage(
      temp: temp,
      tag: 'accepted',
      releaseSequence: 10,
      bootstrapKey: bootstrapKey,
      signingSeedByte: 0x61,
    );

    await ensureProtectedContentInstalled(
      verifier: _StaticVerifier(accepted),
      keyStore: harness.keyStore,
      directory: installRoot,
    );

    final replay = await ensureProtectedContentInstalled(
      verifier: _StaticVerifier(accepted),
      keyStore: harness.keyStore,
      directory: installRoot,
    );
    expect(replay.decision, ContentInstallDecision.idempotent);

    final lower = await _buildVerifiedPackage(
      temp: temp,
      tag: 'lower',
      releaseSequence: 9,
      bootstrapKey: bootstrapKey,
      signingSeedByte: 0x62,
    );
    await expectLater(
      ensureProtectedContentInstalled(
        verifier: _StaticVerifier(lower),
        keyStore: harness.keyStore,
        directory: installRoot,
      ),
      throwsA(isA<ContentPackageReplayException>()),
    );

    final fork = await _buildVerifiedPackage(
      temp: temp,
      tag: 'fork',
      releaseSequence: 10,
      bootstrapKey: bootstrapKey,
      signingSeedByte: 0x63,
    );
    await expectLater(
      ensureProtectedContentInstalled(
        verifier: _StaticVerifier(fork),
        keyStore: harness.keyStore,
        directory: installRoot,
      ),
      throwsA(isA<ContentPackageReplayException>()),
    );

    final higher = await _buildVerifiedPackage(
      temp: temp,
      tag: 'higher',
      releaseSequence: 11,
      bootstrapKey: bootstrapKey,
      signingSeedByte: 0x64,
    );
    final upgraded = await ensureProtectedContentInstalled(
      verifier: _StaticVerifier(higher),
      keyStore: harness.keyStore,
      directory: installRoot,
    );
    expect(upgraded.decision, ContentInstallDecision.upgrade);

    final state = jsonDecode(
      File('${installRoot.path}/content.install-state.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final current = state['accepted'] as Map<String, dynamic>;
    expect(current['releaseSequence'], 11);
    expect(current['manifestSha256'], higher.manifestSha256);
    expect(state['previousAccepted'], isNull);
    expect(state['promotion'], isNull);
    expect(_protectedResidueNames(installRoot), isEmpty);
  });

  test('promotion crash boundaries recover without losing accepted content',
      () async {
    const crashPoints = ProtectedContentInstallFault.values;
    for (final crashPoint in crashPoints) {
      final temp = Directory.systemTemp.createTempSync(
        'pantas_promotion_${crashPoint.name}_',
      );
      addTearDown(() => temp.deleteSync(recursive: true));
      final bootstrapKey =
          Uint8List.fromList(List<int>.filled(32, 0x31 + crashPoint.index));
      final installKey =
          Uint8List.fromList(List<int>.filled(32, 0x71 + crashPoint.index));
      final harness = _KeyStoreHarness(installKey);
      final installRoot = Directory('${temp.path}/installed')..createSync();
      final userDb = File('${installRoot.path}/pantas.db')
        ..writeAsBytesSync(const [4, 2, 4, 2]);
      final accepted = await _buildVerifiedPackage(
        temp: temp,
        tag: 'accepted',
        releaseSequence: 20,
        bootstrapKey: bootstrapKey,
        signingSeedByte: 0x21,
      );
      final candidate = await _buildVerifiedPackage(
        temp: temp,
        tag: 'candidate',
        releaseSequence: 21,
        bootstrapKey: bootstrapKey,
        signingSeedByte: 0x41,
      );

      await ensureProtectedContentInstalled(
        verifier: _StaticVerifier(accepted),
        keyStore: harness.keyStore,
        directory: installRoot,
      );

      await expectLater(
        ensureProtectedContentInstalled(
          verifier: _StaticVerifier(candidate),
          keyStore: harness.keyStore,
          directory: installRoot,
          failAt: crashPoint,
        ),
        throwsA(anything),
        reason: 'fault injection must interrupt at ${crashPoint.name}',
      );

      final active = File('${installRoot.path}/content.db');
      final previous = File('${installRoot.path}/content.db.previous');
      expect(
        active.existsSync() || previous.existsSync(),
        isTrue,
        reason: '${crashPoint.name} must never lose both valid copies',
      );
      expect(userDb.readAsBytesSync(), const [4, 2, 4, 2]);
      for (final file in <File>[active, previous]) {
        if (!file.existsSync()) continue;
        final ordinary = sqlite3.open(file.path);
        try {
          expect(
            () => ordinary.select('SELECT count(*) FROM sqlite_schema'),
            throwsA(anything),
            reason: '${file.path} must remain protected at ${crashPoint.name}',
          );
        } finally {
          ordinary.close();
        }
      }

      await ensureProtectedContentInstalled(
        verifier: _StaticVerifier(candidate),
        keyStore: harness.keyStore,
        directory: installRoot,
      );

      final finalState = jsonDecode(
        File('${installRoot.path}/content.install-state.json')
            .readAsStringSync(),
      ) as Map<String, dynamic>;
      final finalAccepted = finalState['accepted'] as Map<String, dynamic>;
      expect(finalAccepted['releaseSequence'], 21);
      expect(finalAccepted['manifestSha256'], candidate.manifestSha256);
      expect(finalState['previousAccepted'], isNull);
      expect(finalState['promotion'], isNull);
      expect(_protectedResidueNames(installRoot), isEmpty);
      expect(userDb.readAsBytesSync(), const [4, 2, 4, 2]);
      final reopened = ContentCipherProfile.open(active, installKey);
      try {
        expect(reopened.select('PRAGMA user_version').single.values.single, 9);
      } finally {
        reopened.close();
      }
    }
  });

  test('invalid interrupted first install is never accepted and is rebuilt',
      () async {
    final temp =
        Directory.systemTemp.createTempSync('pantas_first_install_crash_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x53));
    final installKey = Uint8List.fromList(List<int>.filled(32, 0x54));
    final harness = _KeyStoreHarness(installKey);
    final installRoot = Directory('${temp.path}/installed');
    final package = await _buildVerifiedPackage(
      temp: temp,
      tag: 'fresh',
      releaseSequence: 30,
      bootstrapKey: bootstrapKey,
      signingSeedByte: 0x55,
    );

    await expectLater(
      ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: harness.keyStore,
        directory: installRoot,
        failAt:
            ProtectedContentInstallFault.afterReplacementBeforeAcceptedState,
      ),
      throwsA(anything),
    );

    final stateFile = File('${installRoot.path}/content.install-state.json');
    final interrupted =
        jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
    expect(interrupted['accepted'], isNull);
    expect(interrupted['promotion'], isNotNull);
    final active = File('${installRoot.path}/content.db');
    expect(active.existsSync(), isTrue);

    final bytes = active.readAsBytesSync();
    bytes[0] ^= 0xff;
    active.writeAsBytesSync(bytes, flush: true);

    final recovered = await ensureProtectedContentInstalled(
      verifier: _StaticVerifier(package),
      keyStore: harness.keyStore,
      directory: installRoot,
    );
    expect(recovered.decision, ContentInstallDecision.freshInstall);
    final finalState =
        jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
    expect(
      (finalState['accepted'] as Map<String, dynamic>)['releaseSequence'],
      30,
    );
    expect(finalState['previousAccepted'], isNull);
    expect(finalState['promotion'], isNull);
    expect(_protectedResidueNames(installRoot), isEmpty);
  });
  test(
      'anti-replay state survives user reset sign-out and account switch files',
      () async {
    final temp = Directory.systemTemp.createTempSync('pantas_replay_lifetime_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x61));
    final installKey = Uint8List.fromList(List<int>.filled(32, 0x62));
    final harness = _KeyStoreHarness(installKey);
    final installRoot = Directory('${temp.path}/installed')..createSync();
    final accepted = await _buildVerifiedPackage(
      temp: temp,
      tag: 'accepted',
      releaseSequence: 40,
      bootstrapKey: bootstrapKey,
      signingSeedByte: 0x63,
    );
    final lower = await _buildVerifiedPackage(
      temp: temp,
      tag: 'lower',
      releaseSequence: 39,
      bootstrapKey: bootstrapKey,
      signingSeedByte: 0x64,
    );

    await ensureProtectedContentInstalled(
      verifier: _StaticVerifier(accepted),
      keyStore: harness.keyStore,
      directory: installRoot,
    );

    final userDb = File('${installRoot.path}/pantas.db')
      ..writeAsBytesSync(const [1, 1, 2, 3]);
    final accountState = File('${installRoot.path}/account-state.json')
      ..writeAsStringSync('{"account":"one"}');
    userDb.deleteSync();
    accountState
      ..writeAsStringSync('{"account":"two"}')
      ..deleteSync();

    await expectLater(
      ensureProtectedContentInstalled(
        verifier: _StaticVerifier(lower),
        keyStore: harness.keyStore,
        directory: installRoot,
      ),
      throwsA(isA<ContentPackageReplayException>()),
    );
    final state = jsonDecode(
      File('${installRoot.path}/content.install-state.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect((state['accepted'] as Map<String, dynamic>)['releaseSequence'], 40);
  });

  test('malformed and inconsistent install state fail closed', () async {
    final temp = Directory.systemTemp.createTempSync('pantas_invalid_state_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x65));
    final installKey = Uint8List.fromList(List<int>.filled(32, 0x66));
    final harness = _KeyStoreHarness(installKey);
    final installRoot = Directory('${temp.path}/installed');
    final package = await _buildVerifiedPackage(
      temp: temp,
      tag: 'accepted',
      releaseSequence: 50,
      bootstrapKey: bootstrapKey,
      signingSeedByte: 0x67,
    );

    await ensureProtectedContentInstalled(
      verifier: _StaticVerifier(package),
      keyStore: harness.keyStore,
      directory: installRoot,
    );

    final active = File('${installRoot.path}/content.db');
    final stateFile = File('${installRoot.path}/content.install-state.json');
    final activeBytes = active.readAsBytesSync();
    final cleanStateText = stateFile.readAsStringSync();

    stateFile.writeAsStringSync('{', flush: true);
    await expectLater(
      ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: harness.keyStore,
        directory: installRoot,
      ),
      throwsA(isA<FormatException>()),
    );
    expect(active.readAsBytesSync(), activeBytes);

    final inconsistent = jsonDecode(cleanStateText) as Map<String, dynamic>;
    inconsistent['previousAccepted'] = inconsistent['accepted'];
    inconsistent['promotion'] = null;
    stateFile.writeAsStringSync(jsonEncode(inconsistent), flush: true);

    await expectLater(
      ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: harness.keyStore,
        directory: installRoot,
      ),
      throwsA(isA<FormatException>()),
    );
    expect(active.readAsBytesSync(), activeBytes);
  });

  test(
    'missing install key rebuilds the exact accepted authenticated package '
    'under a new independent key',
    () async {
      final temp =
          Directory.systemTemp.createTempSync('pantas_key_loss_rebuild_');
      addTearDown(() => temp.deleteSync(recursive: true));
      final installRoot = Directory('${temp.path}/installed')..createSync();
      final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x81));
      final oldInstallKey = Uint8List.fromList(List<int>.filled(32, 0x82));
      final newInstallKey = Uint8List.fromList(List<int>.filled(32, 0x83));
      final harness = _KeyStoreHarness(oldInstallKey);
      final package = await _buildVerifiedPackage(
        temp: temp,
        tag: 'key-loss-rebuild',
        releaseSequence: 60,
        bootstrapKey: bootstrapKey,
        signingSeedByte: 0x84,
      );
      final userDb = File('${installRoot.path}/pantas.db')
        ..writeAsBytesSync(const [8, 6, 7, 5, 3, 0, 9], flush: true);
      final userDbBytes = userDb.readAsBytesSync();

      final initial = await ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: harness.keyStore,
        directory: installRoot,
      );
      final active = initial.activeFile;
      final stateFile = File('${installRoot.path}/content.install-state.json');
      final acceptedStateBefore =
          jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;

      harness
        ..storedKey = null
        ..generatedKey = newInstallKey;

      final recovered = await ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: harness.keyStore,
        directory: installRoot,
      );

      expect(recovered.activeFile.path, active.path);
      expect(newInstallKey, isNot(equals(oldInstallKey)));
      expect(harness.storedKey, isNotNull);
      expect(await harness.keyStore.read(), orderedEquals(newInstallKey));
      final acceptedStateAfter =
          jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
      expect(acceptedStateAfter, equals(acceptedStateBefore));
      expect(userDb.readAsBytesSync(), orderedEquals(userDbBytes));

      final reopened = ContentCipherProfile.open(active, newInstallKey);
      try {
        expect(reopened.select('PRAGMA user_version').single.values.single, 9);
      } finally {
        reopened.close();
      }
      expect(
        () => ContentCipherProfile.open(active, oldInstallKey),
        throwsA(anything),
      );
      final ordinary = sqlite3.open(active.path);
      try {
        expect(
          () => ordinary.select('SELECT count(*) FROM sqlite_schema'),
          throwsA(anything),
        );
      } finally {
        ordinary.close();
      }
    },
  );

  test(
    'missing key never downgrades a known newer accepted package',
    () async {
      final temp =
          Directory.systemTemp.createTempSync('pantas_key_loss_newer_');
      addTearDown(() => temp.deleteSync(recursive: true));
      final installRoot = Directory('${temp.path}/installed');
      final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0x91));
      final installKey = Uint8List.fromList(List<int>.filled(32, 0x92));
      final harness = _KeyStoreHarness(installKey);
      final availableOffline = await _buildVerifiedPackage(
        temp: temp,
        tag: 'available-offline',
        releaseSequence: 70,
        bootstrapKey: bootstrapKey,
        signingSeedByte: 0x93,
      );
      final newerAccepted = await _buildVerifiedPackage(
        temp: temp,
        tag: 'newer-accepted',
        releaseSequence: 71,
        bootstrapKey: bootstrapKey,
        signingSeedByte: 0x94,
      );

      final installed = await ensureProtectedContentInstalled(
        verifier: _StaticVerifier(newerAccepted),
        keyStore: harness.keyStore,
        directory: installRoot,
      );
      final active = installed.activeFile;
      final activeBytesBefore = active.readAsBytesSync();
      final stateFile = File('${installRoot.path}/content.install-state.json');
      final acceptedStateBefore = stateFile.readAsStringSync();

      harness.storedKey = null;

      await expectLater(
        ensureProtectedContentInstalled(
          verifier: _StaticVerifier(availableOffline),
          keyStore: harness.keyStore,
          directory: installRoot,
        ),
        throwsA(isA<ContentPackageReplayException>()),
      );

      expect(active.readAsBytesSync(), orderedEquals(activeBytesBefore));
      expect(stateFile.readAsStringSync(), acceptedStateBefore);
      expect(harness.storedKey, isNull);
      final acceptedState =
          jsonDecode(acceptedStateBefore) as Map<String, dynamic>;
      expect(
        (acceptedState['accepted'] as Map<String, dynamic>)['releaseSequence'],
        71,
      );
      final ordinary = sqlite3.open(active.path);
      try {
        expect(
          () => ordinary.select('SELECT count(*) FROM sqlite_schema'),
          throwsA(anything),
        );
      } finally {
        ordinary.close();
      }
    },
  );

  test(
    'clean accepted state with missing active database fails closed instead '
    'of reinstalling',
    () async {
      final temp =
          Directory.systemTemp.createTempSync('pantas_missing_active_');
      addTearDown(() => temp.deleteSync(recursive: true));
      final installRoot = Directory('${temp.path}/installed')..createSync();
      final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0xa1));
      final installKey = Uint8List.fromList(List<int>.filled(32, 0xa2));
      final harness = _KeyStoreHarness(installKey);
      final package = await _buildVerifiedPackage(
        temp: temp,
        tag: 'missing-active',
        releaseSequence: 61,
        bootstrapKey: bootstrapKey,
        signingSeedByte: 0xa3,
      );
      final userDb = File('${installRoot.path}/pantas.db')
        ..writeAsBytesSync(const [1, 3, 3, 7], flush: true);

      final installed = await ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: harness.keyStore,
        directory: installRoot,
      );
      final active = installed.activeFile;
      final stateFile = File('${installRoot.path}/content.install-state.json');
      final acceptedStateBefore = stateFile.readAsStringSync();
      final storedKeyBefore = harness.storedKey;
      final userDbBytesBefore = userDb.readAsBytesSync();

      active.deleteSync();

      await expectLater(
        ensureProtectedContentInstalled(
          verifier: _StaticVerifier(package),
          keyStore: harness.keyStore,
          directory: installRoot,
        ),
        throwsA(anything),
      );

      expect(stateFile.readAsStringSync(), acceptedStateBefore);
      expect(harness.storedKey, storedKeyBefore);
      expect(userDb.readAsBytesSync(), orderedEquals(userDbBytesBefore));
    },
  );

  test(
    'clean accepted state with a present wrong install key fails closed '
    'instead of rotating ciphertext',
    () async {
      final temp =
          Directory.systemTemp.createTempSync('pantas_wrong_install_key_');
      addTearDown(() => temp.deleteSync(recursive: true));
      final installRoot = Directory('${temp.path}/installed')..createSync();
      final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0xb1));
      final installKey = Uint8List.fromList(List<int>.filled(32, 0xb2));
      final wrongInstallKey = Uint8List.fromList(List<int>.filled(32, 0xb3));
      final wrongInstallKeyHex = wrongInstallKey
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      final harness = _KeyStoreHarness(installKey);
      final package = await _buildVerifiedPackage(
        temp: temp,
        tag: 'wrong-install-key',
        releaseSequence: 62,
        bootstrapKey: bootstrapKey,
        signingSeedByte: 0xb4,
      );
      final userDb = File('${installRoot.path}/pantas.db')
        ..writeAsBytesSync(const [2, 4, 6, 8], flush: true);

      final installed = await ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: harness.keyStore,
        directory: installRoot,
      );
      final active = installed.activeFile;
      final stateFile = File('${installRoot.path}/content.install-state.json');
      final activeBytesBefore = active.readAsBytesSync();
      final acceptedStateBefore = stateFile.readAsStringSync();
      final userDbBytesBefore = userDb.readAsBytesSync();

      harness.storedKey = wrongInstallKeyHex;

      await expectLater(
        ensureProtectedContentInstalled(
          verifier: _StaticVerifier(package),
          keyStore: harness.keyStore,
          directory: installRoot,
        ),
        throwsA(anything),
      );

      expect(active.readAsBytesSync(), orderedEquals(activeBytesBefore));
      expect(stateFile.readAsStringSync(), acceptedStateBefore);
      expect(harness.storedKey, wrongInstallKeyHex);
      expect(await harness.keyStore.read(), orderedEquals(wrongInstallKey));
      expect(userDb.readAsBytesSync(), orderedEquals(userDbBytesBefore));
    },
  );

  test(
    'same-identity key-loss retry preserves a protected copy across '
    'active-to-previous interruption',
    () async {
      final temp =
          Directory.systemTemp.createTempSync('pantas_key_loss_crash_');
      addTearDown(() => temp.deleteSync(recursive: true));
      final installRoot = Directory('${temp.path}/installed')..createSync();
      final bootstrapKey = Uint8List.fromList(List<int>.filled(32, 0xc1));
      final oldInstallKey = Uint8List.fromList(List<int>.filled(32, 0xc2));
      final regeneratedInstallKey =
          Uint8List.fromList(List<int>.filled(32, 0xc3));
      final harness = _KeyStoreHarness(oldInstallKey);
      final package = await _buildVerifiedPackage(
        temp: temp,
        tag: 'key-loss-crash',
        releaseSequence: 63,
        bootstrapKey: bootstrapKey,
        signingSeedByte: 0xc4,
      );
      final userDb = File('${installRoot.path}/pantas.db')
        ..writeAsBytesSync(const [5, 8, 13, 21], flush: true);
      final userDbBytesBefore = userDb.readAsBytesSync();

      final installed = await ensureProtectedContentInstalled(
        verifier: _StaticVerifier(package),
        keyStore: harness.keyStore,
        directory: installRoot,
      );
      final active = installed.activeFile;
      final pending = File('${installRoot.path}/content.db.pending');
      final previous = File('${installRoot.path}/content.db.previous');
      final stateFile = File('${installRoot.path}/content.install-state.json');
      final acceptedStateBefore =
          jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
      final acceptedBefore =
          acceptedStateBefore['accepted'] as Map<String, dynamic>;

      harness
        ..storedKey = null
        ..generatedKey = regeneratedInstallKey;

      await expectLater(
        ensureProtectedContentInstalled(
          verifier: _StaticVerifier(package),
          keyStore: harness.keyStore,
          directory: installRoot,
          failAt: ProtectedContentInstallFault.afterIntentBeforeReplacement,
        ),
        throwsA(anything),
      );

      final interruptedState =
          jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
      expect(interruptedState['promotion'], isNotNull);
      final interruptedPromotion =
          interruptedState['promotion'] as Map<String, dynamic>;
      final interruptedCandidate =
          interruptedPromotion['candidate'] as Map<String, dynamic>;
      expect(
        interruptedCandidate['releaseSequence'],
        package.manifest.releaseSequence,
      );
      expect(interruptedCandidate['manifestSha256'], package.manifestSha256);
      expect(pending.existsSync(), isTrue);
      expect(active.existsSync(), isTrue);
      expect(previous.existsSync(), isFalse);

      active.renameSync(previous.path);
      expect(active.existsSync(), isFalse);
      expect(previous.existsSync(), isTrue);
      expect(pending.existsSync(), isTrue);

      final corruptPayload = Uint8List.fromList(package.payloadBytes);
      corruptPayload[0] ^= 0xff;
      final corruptClone = VerifiedContentPackage(
        manifest: package.manifest,
        payloadBytes: corruptPayload,
        bootstrapKeyBytes: package.bootstrapKeyBytes,
        manifestSha256: package.manifestSha256,
        signatureSha256: package.signatureSha256,
      );

      await expectLater(
        ensureProtectedContentInstalled(
          verifier: _StaticVerifier(corruptClone),
          keyStore: harness.keyStore,
          directory: installRoot,
        ),
        throwsA(anything),
      );

      expect(
        active.existsSync() || previous.existsSync(),
        isTrue,
        reason: 'failed same-identity recovery must preserve a protected copy',
      );
      final postFailureState =
          jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
      expect(postFailureState['promotion'], isNotNull);
      final postFailurePromotion =
          postFailureState['promotion'] as Map<String, dynamic>;
      final postFailureCandidate =
          postFailurePromotion['candidate'] as Map<String, dynamic>;
      expect(
        postFailureCandidate['releaseSequence'],
        package.manifest.releaseSequence,
      );
      expect(postFailureCandidate['manifestSha256'], package.manifestSha256);
      final acceptedAfter =
          postFailureState['accepted'] as Map<String, dynamic>;
      expect(
        acceptedAfter['releaseSequence'],
        acceptedBefore['releaseSequence'],
      );
      expect(acceptedAfter['manifestSha256'], acceptedBefore['manifestSha256']);
      expect(userDb.readAsBytesSync(), orderedEquals(userDbBytesBefore));
    },
  );
}

final class _KeyStoreHarness {
  _KeyStoreHarness(this.generatedKey) {
    when(() => storage.read(key: ContentKeyStore.storageKey))
        .thenAnswer((_) async => storedKey);
    when(
      () => storage.write(
        key: ContentKeyStore.storageKey,
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      storedKey = invocation.namedArguments[#value] as String?;
    });
    keyStore = ContentKeyStore(
      storage: storage,
      generateKey: () => generatedKey,
    );
  }

  Uint8List generatedKey;
  final _MockSecureStorage storage = _MockSecureStorage();
  String? storedKey;
  late final ContentKeyStore keyStore;
}

Future<VerifiedContentPackage> _buildVerifiedPackage({
  required Directory temp,
  required String tag,
  required int releaseSequence,
  required Uint8List bootstrapKey,
  required int signingSeedByte,
}) async {
  final signingSeed = Uint8List.fromList(
    List<int>.generate(32, (i) => (signingSeedByte + i) & 0xff),
  );
  final built = await buildContentPackage(
    releaseSequence: releaseSequence,
    inputJson: File('test/fixtures/sanity/content_sample.json'),
    outputDirectory: Directory('${temp.path}/bundle_$tag'),
    bootstrapKey: bootstrapKey,
    signingPrivateKeySeed: signingSeed,
    versionFile: File('${temp.path}/content_seed_version_$tag.dart'),
  );
  final manifestBytes = built.manifest.readAsBytesSync();
  final signatureBytes = built.signature.readAsBytesSync();
  return VerifiedContentPackage(
    manifest: ContentPackageManifest.parse(manifestBytes),
    payloadBytes: built.payload.readAsBytesSync(),
    bootstrapKeyBytes: bootstrapKey,
    manifestSha256: hashes.sha256.convert(manifestBytes).toString(),
    signatureSha256: hashes.sha256.convert(signatureBytes).toString(),
  );
}

Map<String, List<String>> _corpusSnapshot(Database db) {
  final tables = db
      .select(
        'SELECT name FROM sqlite_schema '
        "WHERE type = 'table' AND name LIKE 'content_%' ORDER BY name",
      )
      .map((row) => row['name'])
      .whereType<String>();
  final snapshot = <String, List<String>>{};
  for (final table in tables) {
    final columns = db
        .select('PRAGMA table_info($table)')
        .map((row) => row['name'])
        .whereType<String>()
        .toList()
      ..sort();
    final rows = <String>[];
    for (final row in db.select('SELECT * FROM $table')) {
      rows.add(
        jsonEncode(<String, Object?>{
          for (final column in columns) column: row[column],
        }),
      );
    }
    rows.sort();
    snapshot[table] = rows;
  }
  return snapshot;
}

List<String> _protectedResidueNames(Directory root) {
  if (!root.existsSync()) return const [];
  final names = root
      .listSync()
      .map((entity) => entity.path.split(Platform.pathSeparator).last)
      .where(
        (name) =>
            name.contains('$contentDbFileName.pending') ||
            name.contains('$contentDbFileName.previous') ||
            name.endsWith('-wal') ||
            name.endsWith('-shm') ||
            name.endsWith('-journal'),
      )
      .toList()
    ..sort();
  return names;
}
