import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('progress does not introduce its own cache', () {
    final source = _dartFiles('lib/features/progress')
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(source, isNot(contains('progress_cache')));
    expect(source, isNot(contains('ProgressCache')));
  });

  test('progress consumes metrics windows and panel contracts', () {
    final source = File(
      'lib/features/progress/application/progress_providers.dart',
    ).readAsStringSync();

    expect(source, contains('ProgressPanelWindow.rolling30d'));
    expect(source, contains('ProgressPanelWindow.prepWindow'));
    expect(source, contains('ProgressPanelWindow.allTime'));
  });
}

Iterable<File> _dartFiles(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
