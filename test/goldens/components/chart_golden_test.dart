import 'package:pantas/core/ui/components/pantas_chart.dart';

import '../golden_harness.dart';

const _points = [
  PantasChartPoint(label: 'Oct 5', value: 58),
  PantasChartPoint(label: 'Oct 12', value: 64),
  PantasChartPoint(label: 'Oct 19', value: 61),
  PantasChartPoint(label: 'Oct 26', value: 72),
  PantasChartPoint(label: 'Nov 2', value: 70.5),
  PantasChartPoint(label: 'Nov 9', value: 81),
];

PantasChart _chart({
  List<PantasChartPoint> points = _points,
  PantasChartKind kind = PantasChartKind.bar,
  List<double?>? secondary,
}) =>
    PantasChart(
      title: 'Mock scores',
      summary: switch (points.length) {
        0 => 'No mocks taken yet.',
        1 => 'Your first mock scored 58%.',
        _ => 'Your last ${points.length} mocks ranged from 58% to 81%.',
      },
      points: points,
      kind: kind,
      secondary: secondary,
      primaryName: 'You',
      secondaryName: 'Passing mark',
      unit: 'mocks',
    );

void main() {
  goldenSheet(
    'chart',
    [
      GoldenState('Bars', (_) => _chart(), width: 520),
      GoldenState(
        'Line',
        (_) => _chart(kind: PantasChartKind.line),
        width: 520,
      ),
      GoldenState(
        'Two series',
        (_) => _chart(
          kind: PantasChartKind.line,
          secondary: const [60, 60, 60, 60, 60, 60],
        ),
        width: 520,
      ),
      GoldenState(
        'One point',
        (_) => _chart(points: _points.take(1).toList()),
        width: 520,
      ),
      GoldenState('Empty', (_) => _chart(points: const []), width: 520),
    ],
    cellWidth: 520,
    columns: 2,
    web: true,
    settle: const Duration(seconds: 2),
  );
}
