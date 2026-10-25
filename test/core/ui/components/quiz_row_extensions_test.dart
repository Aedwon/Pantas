import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';

import '../../../helpers/accessibility.dart';

class _Canvas extends Fake implements Canvas {
  final sweeps = <double>[];
  @override
  void drawCircle(Offset c, double radius, Paint paint) {}
  @override
  void drawArc(
    Rect rect,
    double start,
    double sweep,
    bool center,
    Paint paint,
  ) {
    sweeps.add(sweep);
  }
}

void main() {
  testWidgets('QZ_Tab ring waits then fills over 700 milliseconds',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ProgressRing(
        fraction: .5,
        fillDuration: Duration(milliseconds: 700),
        fillDelay: Duration(milliseconds: 500),
      ),
    );
    final paint = tester
        .widget<CustomPaint>(find.byKey(const ValueKey('progress-ring-paint')))
        .painter!;
    final canvas = _Canvas();
    paint.paint(canvas, const Size(24, 24));
    expect(canvas.sweeps, isEmpty);
    await tester.pump(const Duration(milliseconds: 500));
    paint.paint(canvas, const Size(24, 24));
    expect(canvas.sweeps, isEmpty);
    await tester.pump(const Duration(milliseconds: 700));
    paint.paint(canvas, const Size(24, 24));
    expect(canvas.sweeps.single, closeTo(3.14159265, .0001));
  });

  testWidgets('QZ_Tab ring leads the row at 24 with a 12 gap', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      ListRow(
        title: 'Reviews',
        leading: const ProgressRing(fraction: .5),
        value: '12 of 18',
        onTap: () {},
      ),
      viewportSize: const Size(390, 844),
    );
    expect(tester.getSize(find.byType(ProgressRing)), const Size(24, 24));
    expect(
      tester.getTopLeft(find.text('Reviews')).dx -
          tester.getTopRight(find.byType(ProgressRing)).dx,
      12,
    );
  });

  testWidgets('QZ_Tab keeps 104 under content for the tab bar', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const PantasPage(
        title: 'Quiz',
        bottomInset: 104,
        children: [Text('Last row')],
      ),
    );
    final scroll = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
    expect(scroll.padding, const EdgeInsets.fromLTRB(16, 2, 16, 104));
  });
}
