import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Item 17, demo 8: the tiles and cards that answer a press with a shrink. The
// motion itself is tested in press_scale_test.dart; this keeps a rebuild of one
// of these screens from quietly dropping it.
void main() {
  const tiles = {
    'lib/features/settings/presentation/pages/appearance_page.dart': 2,
    'lib/core/ui/components/pantas_button.dart': 1,
  };
  for (final entry in tiles.entries) {
    test('${entry.key} presses with a shrink', () {
      final source = File(entry.key).readAsStringSync();
      expect(
        RegExp(r'PressScale\(').allMatches(source).length,
        greaterThanOrEqualTo(entry.value),
      );
    });
  }

  test('nothing but PressScale shrinks a tile with a raw press listener', () {
    // One implementation of the press, so one set of numbers (120/180 ms).
    final offenders = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (file.path.endsWith('press_scale.dart')) continue;
      final source = file.readAsStringSync();
      if (source.contains('PantasDurations.short1') &&
          source.contains('Transform.scale')) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
