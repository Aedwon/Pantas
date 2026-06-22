import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notifications route wrapped payloads without trigger rules', () {
    final notificationFiles = _dartFiles('lib/features/notifications')
        .map((file) => MapEntry(file.path, file.readAsStringSync()))
        .where((entry) => entry.key.endsWith('.dart'));

    final triggerRuleImports = notificationFiles
        .where((entry) => entry.value.contains('/features/wrapped/artifacts/'))
        .map((entry) => entry.key)
        .toList();

    expect(triggerRuleImports, isEmpty);
  });

  test('no analytics event names are introduced outside wrapped allowances',
      () {
    final sources =
        _dartFiles('lib').map((file) => file.readAsStringSync()).join('\n');

    final eventNames = RegExp('wrapped_(shared|revealed)').allMatches(sources);
    expect(eventNames.length, lessThanOrEqualTo(2));
  });

  test('only the telemetry seam may call the analytics SDK', () {
    // Amended 3 August 2026. This assertion used to be `isNot(contains(
    // 'logEvent('))` over all of lib/, written when the app had no analytics
    // at all. Analytics now exists, so a blanket ban would have had to be
    // deleted the day it shipped. Confining the call to one file is the
    // stronger form of the same rule: events are a closed enum in
    // core/telemetry/telemetry.dart and every property is whitelisted there.
    final callers = _dartFiles('lib')
        .where((file) => file.readAsStringSync().contains('logEvent('))
        .map((file) => file.path)
        .toList();

    expect(callers, ['lib/core/telemetry/firebase_telemetry.dart']);
  });
}

Iterable<File> _dartFiles(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
