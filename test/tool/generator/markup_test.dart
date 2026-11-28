// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';
import '../../../tool/generator/lib/src/check/markup.dart';

void main() {
  for (final text in [
    r'$x',
    r'${x$',
    r'$x}$',
    r'$\frac{1}{2}$',
    r'${\frac{1}{2}}$',
    r'$\dfrac{1}{2} + \frac{3}{4}$',
  ]) {
    test('rejects invalid markup $text', () {
      expect(checkMarkup(text), isNotEmpty);
    });
  }
  for (final text in [
    r'Cost \$5',
    r'$x^2$',
    r'$\dfrac{\frac{1}{2}}{3}$',
    r'$\dfrac{1}{\frac{2}{3}}$',
    r'$\dfrac{\frac{1}{2}}{\frac{3}{4}}$',
    r'$\{x\}$',
    r'$\dfrac{1}{2}$ and $x$',
  ]) {
    test('accepts markup $text', () {
      expect(checkMarkup(text), isEmpty);
    });
  }
}
