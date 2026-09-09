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
  late Directory fixtureDirectory;
  late File plaintextCorpus;

  setUpAll(() async {
    fixtureDirectory =
        Directory.systemTemp.createTempSync('pantas_note_b_fixture_');
    final export = File('${fixtureDirectory.path}/export.json');
    plaintextCorpus = File('${fixtureDirectory.path}/content.db');

    await _runDartTool([
      'run',
      'tools/build_content_export/build_content_export.dart',
      export.path,
    ]);
    await _runDartTool([
      'run',
      'tools/build_content_seed/seed_writer.dart',
      export.path,
      plaintextCorpus.path,
    ]);
  });

  tearDownAll(() => fixtureDirectory.deleteSync(recursive: true));

  test('the generated source corpus carries note B', () async {
    final db = ContentDatabase(NativeDatabase(plaintextCorpus));
    addTearDown(db.close);

    final withNote = await db
        .customSelect(
          'select count(*) as c from content_choices '
          'where rationale is not null',
        )
        .getSingle();
    final count = withNote.read<int>('c');

    expect(
      count,
      greaterThanOrEqualTo(2200),
      reason: 'note B has gone missing from the generated source corpus. '
          'Check the exporter still carries `rationale`.',
    );
  });

  test('no rationale sits on a correct choice', () async {
    final db = ContentDatabase(NativeDatabase(plaintextCorpus));
    addTearDown(db.close);

    final row = await db
        .customSelect(
          'select count(*) as c from content_choices '
          'where rationale is not null and is_correct = 1',
        )
        .getSingle();

    expect(row.read<int>('c'), 0);
  });
}

Future<void> _runDartTool(List<String> arguments) async {
  final result = await Process.run('dart', arguments);
  expect(
    result.exitCode,
    0,
    reason: result.stdout.toString() + result.stderr.toString(),
  );
}
