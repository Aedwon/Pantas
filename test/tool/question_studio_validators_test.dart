import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('question_studio validators pass node:test', () async {
    final result = await Process.run(
      'node',
      ['--test', 'tools/question_studio/validators.test.mjs'],
    );
    expect(result.exitCode, 0,
        reason: '${result.stdout}\n${result.stderr}');
  });
}
