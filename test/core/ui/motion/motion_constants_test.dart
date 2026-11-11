import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Item 17: new motion takes its time and curves from the shared tables, so the
// app keeps one rhythm and a change is made in one place.
void main() {
  const files = [
    'lib/core/ui/motion/selection_motion.dart',
    'lib/core/ui/motion/press_scale.dart',
    'lib/core/ui/motion/view_swap.dart',
  ];
  for (final path in files) {
    test('$path has no literal duration or curve', () {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('Duration(')));
      expect(source, isNot(contains('Cubic(')));
      expect(RegExp(r'(?<!Pantas)Curves\.').hasMatch(source), isFalse);
      expect(source, contains('PantasDurations'));
    });
  }
}
