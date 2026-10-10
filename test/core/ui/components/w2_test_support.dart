import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void expectContrast(
  Color foreground,
  Color background, {
  double minimum = 4.5,
}) {
  final values = [foreground.computeLuminance(), background.computeLuminance()]
    ..sort();
  expect(
    (values.last + .05) / (values.first + .05),
    greaterThanOrEqualTo(minimum),
    reason: '$foreground on $background',
  );
}
