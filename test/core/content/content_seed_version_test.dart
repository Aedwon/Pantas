import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:pantas/core/content/content_database_opener.dart';
import 'package:flutter_test/flutter_test.dart';

/// The installed corpus goes stale silently, so this is the guard.
///
/// A device installs the bundled database only when [contentSeedVersion]
/// differs from the string it recorded last time. While that was a date kept by
/// hand it was missed by three content stages in a row, and then by a rebuild
/// on a day whose bump had already happened. Every one of those would have
/// shipped an app whose corpus never reached the student who updated to it.
///
/// The digest is generated from the asset's bytes by the seed writer, so the
/// only way to break the pair now is to rebuild the asset without committing
/// the file that comes with it. That is what this catches.
void main() {
  test('the recorded seed version is the digest of the shipped asset', () {
    final asset = File('assets/seed/content.db');
    if (!asset.existsSync()) {
      fail(
        'assets/seed/content.db is missing. It is generated and gitignored, so '
        'a fresh clone has to build it first:\n'
        '  mkdir -p build\n'
        '  dart run tools/build_content_export/build_content_export.dart '
        'build/export.json\n'
        '  dart run tools/build_content_seed/seed_writer.dart build/export.json '
        'assets/seed/content.db',
      );
    }

    final digest = sha256.convert(asset.readAsBytesSync()).toString();
    expect(
      contentSeedVersion,
      digest.substring(0, contentSeedVersion.length),
      reason: 'assets/seed/content.db has been rebuilt without committing the '
          'generated version beside it. Re-run seed_writer.dart and commit '
          'lib/core/content/content_seed_version.g.dart. Until they match, an '
          'app that updates keeps the corpus it already had.',
    );
  });
}
