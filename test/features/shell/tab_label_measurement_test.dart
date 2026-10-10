import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

void main() {
  test('label measurement releases its text painter after reading width', () {
    final painter = TextPainter(
      text: const TextSpan(text: 'Settings', style: TextStyle(fontSize: 10)),
      textDirection: TextDirection.ltr,
    );
    final width = measureTabLabel(painter);
    expect(width, greaterThan(0));
    expect(painter.debugDisposed, isTrue);
  });
  test('label measurement also releases its painter when layout fails', () {
    final painter = TextPainter(text: const TextSpan(text: 'Settings'));
    expect(() => measureTabLabel(painter), throwsStateError);
    expect(painter.debugDisposed, isTrue);
  });
}
