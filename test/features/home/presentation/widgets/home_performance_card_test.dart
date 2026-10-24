import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/presentation/widgets/home_performance_card.dart';

void main() {
  PerformanceRow row(String id, int correct, int answered) => PerformanceRow(
        id: id,
        title: id,
        subtext: null,
        correct: correct,
        answered: answered,
        secondsPerQuestion: null,
      );
  Widget show(
    List<PerformanceRow> rows, {
    bool pro = false,
    int? overallCorrect,
    int? overallAnswered,
    bool large = false,
  }) =>
      MaterialApp(
        theme: buildLightTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(large ? 2 : 1),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: HomePerformanceCard(
                rows: rows,
                overallCorrect: overallCorrect,
                overallAnswered: overallAnswered,
                pro: pro,
                onOpen: () {},
              ),
            ),
          ),
        ),
      );
  testWidgets('server overall includes answers outside displayed subjects',
      (tester) async {
    await tester.pumpWidget(
      show([row('Math', 1, 2)], overallCorrect: 3, overallAnswered: 4),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<HalfRingGauge>(find.byType(HalfRingGauge)).fraction,
      .75,
    );
  });
  testWidgets(
      'overall accuracy uses every finished answer, empty subjects stay hidden',
      (tester) async {
    await tester.pumpWidget(
      show([row('Math', 1, 2), row('Science', 3, 3), row('Empty', 0, 0)]),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<HalfRingGauge>(find.byType(HalfRingGauge)).fraction,
      .8,
    );
    expect(find.text('Empty'), findsNothing);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('See all topics and lessons'), findsOneWidget);
    expect(find.text('Pro'), findsOneWidget);
  });
  testWidgets('no answers hide the performance section instead of showing zero',
      (tester) async {
    await tester.pumpWidget(show([row('Empty', 0, 0)]));
    expect(find.byType(HalfRingGauge), findsNothing);
    expect(find.text('YOUR PERFORMANCE'), findsNothing);
  });
  testWidgets('large text does not overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester
        .pumpWidget(show([row('Reading Comprehension', 2, 3)], large: true));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
