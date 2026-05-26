import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('live validation doc keeps content database regenerable and out of sync',
      () {
    final file = File(
      'docs/superpowers/plans/2026-05-21-study-plan-live-validation.md',
    );
    expect(file.existsSync(), isTrue);
    final source = file.readAsStringSync();

    expect(source, contains('content.db is regenerable content only'));
    expect(source, contains('Do not sync content.db'));
    expect(source, contains('app.db is user data'));
  });
}
