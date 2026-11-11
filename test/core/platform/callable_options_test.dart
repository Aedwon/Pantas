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
    // Each server file that sets consumeAppCheckToken names its callables,
    // either in the call itself or in a shared `options` object.
    final inline = RegExp(
      r'export const (\w+)\s*=\s*onCall\(\s*(\{[^;]*?consumeAppCheckToken|\{\.\.\.options, consumeAppCheckToken)',
    );
    final shared = RegExp(r'export const (\w+)\s*=\s*onCall\(\s*options\s*,');
    final sharedConsumes =
        RegExp(r'const options = \{[^;]*?consumeAppCheckToken');
    final consuming = <String>{};
    for (final file in Directory('functions/src')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.ts'))) {
      final source = file.readAsStringSync();
      consuming.addAll(inline.allMatches(source).map((m) => m.group(1)!));
      if (sharedConsumes.hasMatch(source)) {
        consuming.addAll(shared.allMatches(source).map((m) => m.group(1)!));
      }
    }
    expect(consuming, replayProtectedCallables);
  });

  test('the beta feedback callables ask for limited-use tokens', () {
    for (final name in const [
      'sendBetaFeedback',
      'recordBetaDay',
      'submitBetaSurvey',
      'activateBetaReward',
      'getBetaReward',
    ]) {
      expect(
        callableOptionsFor(name).limitedUseAppCheckToken,
        isTrue,
        reason: name,
      );
    }
  });
}
