import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/guardian/presentation/guardian_screen.dart';

void main() {
  const text = 'aaaa bbbb cccc ddddd';
  const style = TextStyle(fontSize: 10);

  Future<List<String>> lines(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 150, child: child),
        ),
      ),
    );
    final box = tester.getSize(find.text(text));
    final painter = TextPainter(
      text: const TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: box.width);
    final result = <String>[];
    var offset = 0;
    while (offset < text.length) {
      final line = painter.getLineBoundary(TextPosition(offset: offset));
      result.add(text.substring(line.start, line.end).trim());
      offset = line.end;
    }
    return result;
  }

  testWidgets('plain text leaves one word alone, balanced text does not',
      (tester) async {
    expect(
      await lines(tester, const Text(text, style: style)),
      ['aaaa bbbb cccc', 'ddddd'],
    );
    expect(
      await lines(tester, const BalancedText(text, style: style)),
      ['aaaa bbbb', 'cccc ddddd'],
    );
  });

  testWidgets('a title that fits on one line is left alone', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child:
              SizedBox(width: 400, child: BalancedText('Short', style: style)),
        ),
      ),
    );
    expect(tester.getSize(find.text('Short')).height, 10);
  });
}
