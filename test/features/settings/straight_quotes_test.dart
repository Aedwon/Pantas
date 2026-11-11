import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// QA 5Q-4: Settings text uses one quote style, the straight one, on the phone
// and on the wide page (QA C-21 set the apostrophes the same way). The wide
// Appearance footer had curly double quotes where the phone had straight ones.
void main() {
  test('no Settings text uses a curly double quote', () {
    final open = String.fromCharCode(0x201C);
    final close = String.fromCharCode(0x201D);
    final offenders = <String>[];
    for (final entity in Directory('lib/features/settings').listSync(
      recursive: true,
    )) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains(open) ||
            lines[i].contains(close) ||
            lines[i].contains(r'\u201c') ||
            lines[i].contains(r'\u201d')) {
          offenders.add('${entity.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
