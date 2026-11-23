// Runs the content gate on what students receive. See README.md.
//
// PANTAS_CONTENT_SERVED: the directory the upload packaging wrote (catalog/,
// questions/, lessons/ and invalid.txt). CI builds it before the shards run.
// When it is unset this test builds it from ./content, which needs
// `npm ci --prefix functions && npm run build --prefix functions` first.
// PANTAS_CONTENT_EXPORT: the export the catalog structure comes from (exams,
// subjects, topics, mock blueprints). Built here when unset.
// PANTAS_CONTENT_GATE_REPORT=<file> also writes the per-exam report.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/prebuilt_content.dart';
import 'content_gate.dart';

void main() {
  testWidgets(
    'every item students receive works through the real app code',
    (tester) async {
      final dir = Directory.systemTemp.createTempSync('pantas_gate_');
      addTearDown(() => dir.deleteSync(recursive: true));
      var served = Directory(
        Platform.environment['PANTAS_CONTENT_SERVED'] ?? '',
      );
      if (served.path.isEmpty || !served.existsSync()) {
        final export = File('${dir.path}/export.json');
        served = Directory('${dir.path}/served');
        await tester.runAsync(() async {
          if (!copyPrebuiltExport(export)) {
            final built = await Process.run('dart', [
              'run',
              'tools/build_content_export/build_content_export.dart',
              export.path,
            ]);
            expect(built.exitCode, 0, reason: '${built.stderr}');
          }
          // The upload's own packaging, writing files and touching no database.
          final root = Platform.environment['PANTAS_CONTENT_ROOT'] ?? 'content';
          final packaged = await Process.run('node', [
            'tools/upload_content/upload_content.mjs',
            '--root',
            root,
            '--export',
            export.path,
            '--out-dir',
            served.path,
            '--skip-invalid',
          ]);
          expect(
            packaged.exitCode,
            0,
            reason: 'the upload packaging refused this content:\n'
                '${packaged.stdout}${packaged.stderr}',
          );
          File('${served.path}/invalid.txt')
              .writeAsStringSync('${packaged.stderr}');
        });
      }
      final clock = Stopwatch()..start();
      final report = await runContentGate(tester, served);
      clock.stop();
      final out = Platform.environment['PANTAS_CONTENT_GATE_REPORT'];
      if (out != null && out.isNotEmpty) {
        File(out).writeAsStringSync(
          report.toMarkdown(title: 'Content gate', took: clock.elapsed),
        );
      }
      // ignore: avoid_print
      print('content gate took ${clock.elapsed.inSeconds}s, ${report.counts}');
      expect(report.failures, isEmpty, reason: report.summary());
    },
    timeout: const Timeout(Duration(minutes: 30)),
  );
}
