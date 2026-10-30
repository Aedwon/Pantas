import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/callable_options.dart';

void main() {
  test('replay-protected callables ask for limited-use tokens', () {
    for (final name in replayProtectedCallables) {
      expect(
        callableOptionsFor(name).limitedUseAppCheckToken,
        isTrue,
        reason: name,
      );
    }
  });

  test('other callables use the default token', () {
    for (final name in ['getContent', 'getWebEntitlement', 'submitMock']) {
      expect(
        callableOptionsFor(name).limitedUseAppCheckToken,
        isFalse,
        reason: name,
      );
    }
  });

  test('the list matches the server callables that consume the token', () {
    // Each server file that sets consumeAppCheckToken names its callables.
    final server = Directory('functions/src')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.ts'))
        .map((f) => f.readAsStringSync())
        .join('\n');
    final consuming = RegExp(
      r'export const (\w+)\s*=\s*onCall\(\s*(\{[^;]*?consumeAppCheckToken|\{\.\.\.options, consumeAppCheckToken)',
    ).allMatches(server).map((m) => m.group(1)!).toSet();
    expect(consuming, replayProtectedCallables);
  });
}
