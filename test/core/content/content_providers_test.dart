import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hashes;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/content_database_opener.dart';
import 'package:pantas/core/content/security/content_cipher_profile.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../tools/build_content_seed/seed_writer.dart';

const _e02ContentSha256 =
    'eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45';
const _e02ExportSha256 =
    '51349cfe24049a282b8dc053c3a01df65d5636e7808b055d3008cead2504ff67';
const _e02ExportGzipSha256 =
    '74d952691046485458c06b82313984e551b2a57e5a5f7b02f93c5023dfabfc78';

void main() {
  late Directory fixtureDirectory;
  late File e02PlaintextSeed;

  setUpAll(() async {
    fixtureDirectory =
        Directory.systemTemp.createTempSync('pantas_e02_fixture_');
    final export = File('${fixtureDirectory.path}/export.json');
    e02PlaintextSeed = File('${fixtureDirectory.path}/e02-content.db');

    // E02 migration must use the approved pre-QA bank, not the live corpus.
    final frozenExport = File('test/fixtures/content/e02_export.json.gz');
    expect(_sha256(frozenExport), _e02ExportGzipSha256);
    final exportBytes = gzip.decode(frozenExport.readAsBytesSync());
    expect(hashes.sha256.convert(exportBytes).toString(), _e02ExportSha256);
    export.writeAsBytesSync(exportBytes);
    await writeContentSeed(
      inputJson: export,
      outputDb: e02PlaintextSeed,
      legacySchema8Fixture: true,
    );
    expect(_sha256(e02PlaintextSeed), _e02ContentSha256);
  });

  tearDownAll(() => fixtureDirectory.deleteSync(recursive: true));
  test(
    'shipping bootstrap installs protected content before opening final '
    'content overrides',
    () {
      final source = File('lib/app/bootstrap.dart').readAsStringSync();
      final bootstrapStart = source.indexOf('Future<void> _bootstrap(');
      expect(bootstrapStart, greaterThanOrEqualTo(0));

      final bootstrapSource = source.substring(bootstrapStart);
      final protectedInstallIndex =
          bootstrapSource.indexOf('await ensureProtectedContentInstalled(');
      final contentOverridesIndex =
          bootstrapSource.indexOf('bootstrapContentOverrides(');

      expect(
        protectedInstallIndex,
        greaterThanOrEqualTo(0),
        reason: 'shipping bootstrap must run protected install/recovery',
      );
      expect(
        contentOverridesIndex,
        greaterThanOrEqualTo(0),
        reason: 'shipping bootstrap must obtain final content overrides',
      );
      expect(
        protectedInstallIndex,
        lessThan(contentOverridesIndex),
        reason:
            'protected install/recovery must complete before final content open',
      );
      expect(
        source,
        isNot(contains('bundle/seed_installer.dart')),
        reason: 'shipping bootstrap must not import the legacy SeedInstaller',
      );
      expect(
        source,
        isNot(contains('SeedInstaller')),
        reason: 'shipping bootstrap must not use the legacy SeedInstaller',
      );
    },
  );

  test(
    'shipping bootstrap retry/reopen after process death avoids legacy seed-version gating',
    () {
      final source = File('lib/app/bootstrap.dart').readAsStringSync();
      const legacyGateSymbols = <String>[
        '_installContentSeed',
        'installedContentSeedVersion',
        'setInstalledContentSeedVersion',
        'SeedInstaller',
      ];

      for (final symbol in legacyGateSymbols) {
        expect(
          source,
          isNot(contains(symbol)),
          reason: 'shipping bootstrap must not gate recovery on $symbol',
        );
      }
    },
  );

  test('production content bootstrap defaults to protected database opener',
      () {
    final source = File('lib/core/content/content.dart').readAsStringSync();
    expect(
      source,
      contains('open = openProtectedContentDatabase'),
    );
    expect(source, isNot(contains('open = openContentDatabase')));
  });

  test('exact approved E02 plaintext migrates to independently keyed content',
      () async {
    final temp = Directory.systemTemp.createTempSync('pantas_e02_open_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final active = _copyE02Seed(e02PlaintextSeed, temp, 'content.db');
    final key = _contentKey(0x51);

    expect(_sha256(active), _e02ContentSha256);

    final db = await openProtectedContentDatabase(file: active, key: key);
    await db.close();

    expect(_sha256(active), isNot(_e02ContentSha256));
    final protected = ContentCipherProfile.open(active, key);
    try {
      expect(protected.select('PRAGMA user_version').single.values.single, 8);
    } finally {
      protected.close();
    }
    final ordinary = sqlite3.open(active.path);
    try {
      expect(
        () => ordinary.select('SELECT count(*) FROM sqlite_schema'),
        throwsA(anything),
      );
    } finally {
      ordinary.close();
    }
  });

  test('already encrypted content is never interpreted as legacy plaintext',
      () async {
    final temp = Directory.systemTemp.createTempSync('pantas_encrypted_open_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final active = _copyE02Seed(e02PlaintextSeed, temp, 'content.db');
    final key = _contentKey(0x52);
    ContentCipherProfile.protectPlaintextFile(active, key);
    final before = active.readAsBytesSync();

    final db = await openProtectedContentDatabase(file: active, key: key);
    await db.close();

    expect(active.readAsBytesSync(), before);
    ContentCipherProfile.open(active, key).close();
  });

  test('stale newer and unknown plaintext identities are rejected unchanged',
      () async {
    final temp = Directory.systemTemp.createTempSync('pantas_unknown_legacy_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final key = _contentKey(0x53);
    final mutations = <String, void Function(Database)>{
      'stale': (db) => db.execute('PRAGMA user_version = 7'),
      'newer': (db) => db.execute('PRAGMA user_version = 9'),
      'unknown': (db) => db.execute(
            'CREATE TABLE unsupported_legacy_marker (id INTEGER PRIMARY KEY)',
          ),
    };

    for (final entry in mutations.entries) {
      final active = _copyE02Seed(e02PlaintextSeed, temp, '${entry.key}.db');
      final plaintext = sqlite3.open(active.path);
      entry.value(plaintext);
      plaintext.close();
      final before = active.readAsBytesSync();
      expect(_sha256(active), isNot(_e02ContentSha256));

      await expectLater(
        openProtectedContentDatabase(file: active, key: key),
        throwsA(
          predicate<Object>(
            (error) => error.toString().contains('unsupported legacy content'),
          ),
        ),
        reason: '${entry.key} plaintext must fail closed as non-E02',
      );
      expect(active.readAsBytesSync(), before);
    }
  });

  test('legacy plaintext survives protected destination promotion failure',
      () async {
    if (!Platform.isMacOS) {
      return;
    }
    final temp = Directory.systemTemp.createTempSync('pantas_e02_promotion_');
    final active = _copyE02Seed(e02PlaintextSeed, temp, 'content.db');
    addTearDown(() {
      if (active.existsSync()) {
        Process.runSync('chflags', ['nouchg', active.path]);
      }
      if (temp.existsSync()) {
        temp.deleteSync(recursive: true);
      }
    });
    final before = active.readAsBytesSync();
    final key = _contentKey(0x54);
    final immutable = Process.runSync('chflags', ['uchg', active.path]);
    expect(immutable.exitCode, 0, reason: immutable.stderr.toString());

    await expectLater(
      openProtectedContentDatabase(file: active, key: key),
      throwsA(isA<FileSystemException>()),
    );

    expect(active.readAsBytesSync(), before);
    expect(_sha256(active), _e02ContentSha256);
  });

  test('successful E02 migration never mutates the sibling user database',
      () async {
    final temp = Directory.systemTemp.createTempSync('pantas_e02_user_db_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final active = _copyE02Seed(e02PlaintextSeed, temp, 'content.db');
    final userDb = File('${temp.path}/pantas.db')
      ..writeAsBytesSync(const [9, 8, 7, 6, 5, 4]);
    final before = userDb.readAsBytesSync();

    final db = await openProtectedContentDatabase(
      file: active,
      key: _contentKey(0x55),
    );
    await db.close();

    expect(userDb.readAsBytesSync(), before);
  });

  test('contentDatabaseProvider throws until bootstrap override is supplied',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(contentDatabaseProvider),
      throwsA(isA<UnimplementedError>()),
    );
  });

  test('contentDatabaseProvider returns supplied content database override',
      () {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [contentDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    expect(container.read(contentDatabaseProvider), same(db));
  });

  test('bootstrap content override returns a ContentDatabase instance',
      () async {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final overrides = await bootstrapContentOverrides(open: () async => db);
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);

    expect(container.read(contentDatabaseProvider), same(db));
  });

  test('content repository providers use contentDatabaseProvider', () {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [contentDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    expect(container.read(examRepoProvider).database, same(db));
    expect(container.read(questionRepoProvider).database, same(db));
    expect(container.read(lessonRepoProvider).database, same(db));
  });
}

File _copyE02Seed(File source, Directory directory, String name) {
  final file = File('${directory.path}/$name');
  source.copySync(file.path);
  expect(_sha256(file), _e02ContentSha256);
  return file;
}

String _sha256(File file) =>
    hashes.sha256.convert(file.readAsBytesSync()).toString();

Uint8List _contentKey(int byte) =>
    Uint8List.fromList(List<int>.filled(32, byte));
