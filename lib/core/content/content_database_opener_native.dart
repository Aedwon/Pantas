// coverage:ignore-file
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/security/content_cipher_profile.dart';
import 'package:pantas/core/content/security/content_key_store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Which build of the corpus this app carries, re-exported so callers keep
/// importing one file. Written by the seed writer from the asset's own bytes,
/// because a hand-maintained version was missed by three content stages in a
/// row and then by a same-day rebuild.
export 'package:pantas/core/content/content_seed_version.dart';

const contentDbFileName = 'content.db';

const _approvedE02ContentSeedVersion = 'eb3a9da425b80a51';
const _approvedE02ContentSha256 =
    'eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45';
const _unsupportedLegacyContentMessage = 'unsupported legacy content';

Future<ContentDatabase> openProtectedContentDatabase({
  File? file,
  Uint8List? key,
  ContentKeyStore? keyStore,
}) async {
  final resolvedFile = file ?? await _defaultContentFile();
  final resolvedKey = key ?? await (keyStore ?? ContentKeyStore()).read();
  if (resolvedKey == null) {
    throw StateError('protected content key is missing');
  }

  // Authenticate an already-protected install before considering the bounded
  // legacy path. Ciphertext is never opened as ordinary SQLite.
  try {
    ContentCipherProfile.open(resolvedFile, resolvedKey).close();
    return _backgroundContentDatabase(resolvedFile, resolvedKey);
  } catch (_) {
    // Only the exact approved E02 bytes are eligible for plaintext migration.
  }

  final sourceSha256 = await _sha256(resolvedFile);
  if (!_isApprovedE02(sourceSha256)) {
    throw StateError(_unsupportedLegacyContentMessage);
  }

  await _migrateApprovedE02(resolvedFile, resolvedKey);
  return _backgroundContentDatabase(resolvedFile, resolvedKey);
}

ContentDatabase _backgroundContentDatabase(File file, Uint8List key) {
  return ContentDatabase(
    NativeDatabase.createInBackground(
      file,
      setup: (db) => ContentCipherProfile.configure(db, key),
    ),
  );
}

Future<void> _migrateApprovedE02(File source, Uint8List key) async {
  final protectedCopy = File('${source.path}.legacy-protected.tmp');
  if (protectedCopy.existsSync()) {
    await protectedCopy.delete();
  }

  try {
    await protectedCopy.writeAsBytes(
      await source.readAsBytes(),
      flush: true,
    );
    ContentCipherProfile.protectPlaintextFile(protectedCopy, key);

    // Validate the independently keyed destination before replacing the sole
    // legacy source. Rename stays on the same filesystem because the temporary
    // destination is a sibling of the source.
    ContentCipherProfile.open(protectedCopy, key).close();
    await protectedCopy.rename(source.path);
  } catch (_) {
    try {
      if (protectedCopy.existsSync()) {
        await protectedCopy.delete();
      }
    } catch (_) {
      // Preserve the original migration failure.
    }
    rethrow;
  }
}

bool _isApprovedE02(String sha256) {
  return sha256 == _approvedE02ContentSha256 &&
      sha256.startsWith(_approvedE02ContentSeedVersion);
}

Future<String> _sha256(File file) async {
  final digest = await Sha256().hash(await file.readAsBytes());
  return digest.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}

@Deprecated('Use openProtectedContentDatabase after protected installation.')
Future<ContentDatabase> openContentDatabase() => openProtectedContentDatabase();

Future<File> _defaultContentFile() async {
  final dir = await getApplicationSupportDirectory();
  return File(p.join(dir.path, contentDbFileName));
}
