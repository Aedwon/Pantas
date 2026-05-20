import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('android Gradle config defines dev and prod flavors', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('create("dev")'));
    expect(gradle, contains('create("prod")'));
  });

  test('dev flavor uses com.aerol.csecet.dev', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('applicationId = "com.aerol.csecet.dev"'));
  });

  test('prod flavor uses com.aerol.csecet', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('applicationId = "com.aerol.csecet"'));
  });

  test('repo does not commit google-services json placeholders', () {
    final generatedConfigs = Directory('android/app/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('google-services.json'))
        .toList();

    expect(generatedConfigs, isEmpty);
  });
}
