import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('android Gradle config defines dev and prod flavors', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('create("dev")'));
    expect(gradle, contains('create("prod")'));
  });

  test('dev flavor uses com.aedwon.pantas.dev', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('applicationId = "com.aedwon.pantas.dev"'));
  });

  test('prod flavor uses com.aedwon.pantas', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('applicationId = "com.aedwon.pantas"'));
  });

  test('no google-services json is tracked by git', () {
    // Asks git, not the filesystem. From 12 August every configured machine
    // has three of these files, one per flavor, written by
    // `flutterfire configure`. The old check looked for the files at all and
    // so failed as soon as Firebase was actually set up. What must never
    // happen is committing one, and that is what this asks now.
    final tracked = Process.runSync('git', [
      'ls-files',
      '--',
      '*google-services.json',
    ]);

    expect(tracked.exitCode, 0, reason: 'git ls-files failed');
    expect((tracked.stdout as String).trim(), isEmpty);
  });
}
