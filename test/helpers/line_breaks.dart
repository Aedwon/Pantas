import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whether any text in [finder] breaks a word in two across lines. A soft wrap
/// is fine when the break falls at a space.
bool splitsAWord(WidgetTester tester, Finder finder) {
  for (final element in finder.evaluate()) {
    final render = element.renderObject;
    if (render is! RenderParagraph) continue;
    final text = render.text.toPlainText();
    double? top(int i) {
      final boxes = render.getBoxesForSelection(
          TextSelection(baseOffset: i, extentOffset: i + 1));
      return boxes.isEmpty ? null : boxes.first.top;
    }

    for (var i = 0; i < text.length - 1; i++) {
      final a = top(i);
      final b = top(i + 1);
      if (a == null || b == null || b <= a + 1) continue;
      if (text[i].trim().isNotEmpty && text[i + 1].trim().isNotEmpty) {
        return true;
      }
    }
  }
  return false;
}
