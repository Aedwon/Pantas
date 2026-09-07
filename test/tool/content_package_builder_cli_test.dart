import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('content package builder is an executable fail-closed CLI', () async {
    final environment = Map<String, String>.from(Platform.environment)
      ..remove('PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64')
      ..remove('PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64');

    final noArgs = await Process.run(
      'dart',
      <String>[
        'run',
        'tools/build_content_package/build_content_package.dart',
      ],
      environment: environment,
    );
    expect(noArgs.exitCode, 64);
    final usage = <String>[
      'usage: dart run tools/build_content_package/',
      'build_content_package.dart',
    ].join();
    expect(
      '${noArgs.stdout}${noArgs.stderr}',
      contains(usage),
    );

    final missingSecrets = await Process.run(
      'dart',
      <String>[
        'run',
        'tools/build_content_package/build_content_package.dart',
        '.dart_tool/e04-export-after.json',
        'assets/seed',
        'lib/core/content/content_seed_version.dart',
      ],
      environment: environment,
    );
    expect(missingSecrets.exitCode, isNot(0));
    expect(
      '${missingSecrets.stdout}${missingSecrets.stderr}',
      contains('PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64'),
    );
  });
}
