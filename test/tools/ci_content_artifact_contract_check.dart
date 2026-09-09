import 'dart:io';

void main() {
  final workflow = File('.github/workflows/main.yml').readAsStringSync();

  final buildsPlaintextSeed =
      workflow.contains('tools/build_content_seed/seed_writer.dart') &&
          workflow.contains('assets/seed/content.db');
  final uploadsDevApk = workflow.contains('actions/upload-artifact@') &&
      workflow.contains('app-dev-debug.apk');

  if (buildsPlaintextSeed && uploadsDevApk) {
    stderr.writeln(
      'FAIL: main CI publishes an APK after generating a plaintext content.db.',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln('PASS: no plaintext-content APK artifact publication path.');
}
