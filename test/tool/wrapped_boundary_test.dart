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
    expect(sources, isNot(contains('logEvent(')));
  });
}

Iterable<File> _dartFiles(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
