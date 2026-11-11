import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/presentation/widgets/accuracy_line.dart';

void main() {
  test('axis fits the data in steps of 20 without clipping', () {
    final a = AccuracyLinePainter.axisRange([52, 74, 61]);
    expect((a.low, a.high), (40, 80));
    final b = AccuracyLinePainter.axisRange([30, 74]);
    expect((b.low, b.high), (20, 80));
    final c = AccuracyLinePainter.axisRange([60, 60]);
    expect((c.low, c.high), (60, 100));
    final d = AccuracyLinePainter.axisRange([85, 96]);
    expect((d.low, d.high), (60, 100));
    final e = AccuracyLinePainter.axisRange([0, 100]);
    expect((e.low, e.high), (0, 100));
  });
}
