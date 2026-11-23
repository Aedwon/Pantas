// Runs the content gate on the export CI built (PANTAS_CONTENT_EXPORT), or
// builds one from this tree when the variable is unset. See README.md.
//
// PANTAS_CONTENT_GATE_REPORT=<file> also writes the per-exam report.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/prebuilt_content.dart';
import 'content_gate.dart';

void main() {
  testWidgets(
    'every active item works through the real app code',
    (tester) async {
      final dir = Directory.systemTemp.createTempSync('pantas_gate_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final export = File('${dir.path}/export.json');
      if (!copyPrebuiltExport(export)) {
        final result = await tester.runAsync(
          () => Process.run('dart', [
            'run',
            'tools/build_content_export/build_content_export.dart',
            export.path,
          ]),
        );
        expect(result!.exitCode, 0, reason: '${result.stderr}');
      }
      final clock = Stopwatch()..start();
      final report = await runContentGate(tester, export);
      clock.stop();
      final out = Platform.environment['PANTAS_CONTENT_GATE_REPORT'];
      if (out != null && out.isNotEmpty) {
        File(out).writeAsStringSync(
          report.toMarkdown(title: 'Content gate', took: clock.elapsed),
        );
      }
      // ignore: avoid_print
      print('content gate took ${clock.elapsed.inSeconds}s, '
          '${report.counts}');
      expect(report.failures, isEmpty, reason: report.summary());
    },
    timeout: const Timeout(Duration(minutes: 30)),
  );
}
