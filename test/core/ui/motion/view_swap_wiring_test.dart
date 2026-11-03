import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Item 17, demo 9: where a switch changes the block under it. The motion is
// tested in view_swap_test.dart; this keeps a rebuild of one of these screens
// from quietly dropping it, and keeps the phone list on the slide-only variant
// (a nearly full-screen block must not fade, item 16).
void main() {
  test('the practice modes swap their block on phone and wide web', () {
    final source = File(
      'lib/features/quiz/presentation/practice_picker_screen.dart',
    ).readAsStringSync();
    expect(RegExp(r'ViewSwap\(').allMatches(source).length, 2);
    expect(source, contains('index: _mode.index'));
  });

  test('the wide performance list swaps with a fade', () {
    final source = File(
      'lib/features/home/presentation/widgets/web_performance_layout.dart',
    ).readAsStringSync();
    expect(source, contains('ViewSwap('));
    expect(source, contains('index: widget.level'));
    expect(source, isNot(contains('fade: false')));
  });

  test('the phone performance list slides without a fade', () {
    final source = File(
      'lib/features/home/presentation/performance_page.dart',
    ).readAsStringSync();
    expect(source, contains('ViewSwap('));
    expect(source, contains('fade: false'));
  });
}
