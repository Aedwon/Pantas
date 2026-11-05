import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// QA 4N-9: one apostrophe style in student text. It is the straight one
// (QA C-21). The lesson reader's strings follow its own boards (RD_), which
// set the curly one, and are the only exceptions.
void main() {
  const reader = {
    'lib/core/ui/components/content_renderer.dart',
    'lib/features/lesson/presentation/widgets/web_ending_layout.dart',
  };
  test('no student text uses a curly apostrophe outside the reader', () {
    final curly = String.fromCharCode(0x2019);
    const escaped = r'\u2019';
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path;
      if (path.startsWith('lib/l10n/') || reader.contains(path)) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        // The character itself, or its escape written in the source.
        if (lines[i].contains(curly) || lines[i].contains(escaped)) {
          offenders.add('$path:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
