import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';

/// Note B is what a Pro subscriber buys at the answer reveal, and it lives
/// in the corpus rather than in the app.
///
/// **Every part of the chain has been broken at least once.** The field was
/// absent from the schema, then dropped by three writers, then present in
/// the YAML and missing from the built asset because nobody rebuilt it. This
/// test reads the database the app actually ships and counts.
///
/// The floor only ever moves up. It is not a target: it is the line under
/// which something has been lost.
void main() {
  test('the shipped seed carries note B', () async {
    final asset = File('assets/seed/content.db');
    if (!asset.existsSync()) {
      fail(
        'assets/seed/content.db is missing. It is generated and gitignored:\n'
        '  mkdir -p build\n'
        '  dart run tools/build_content_export/build_content_export.dart '
        'build/export.json\n'
        '  dart run tools/build_content_seed/seed_writer.dart build/export.json '
        'assets/seed/content.db',
      );
    }

    final db = ContentDatabase(NativeDatabase(asset));
    addTearDown(db.close);

    final withNote = await db
        .customSelect(
          'select count(*) as c from content_choices where rationale is not null',
        )
        .getSingle();
    final count = withNote.read<int>('c');

    expect(
      count,
      greaterThanOrEqualTo(2200),
      reason: 'note B has gone missing from the built seed. Rebuild the asset '
          'and check the exporter still carries `rationale`.',
    );
  });

  test('no rationale sits on a correct choice', () async {
    final db = ContentDatabase(NativeDatabase(File('assets/seed/content.db')));
    addTearDown(db.close);

    // The correct choice already has note A. A note there would draw twice.
    final row = await db
        .customSelect(
          'select count(*) as c from content_choices '
          'where rationale is not null and is_correct = 1',
        )
        .getSingle();

    expect(row.read<int>('c'), 0);
  });
}
