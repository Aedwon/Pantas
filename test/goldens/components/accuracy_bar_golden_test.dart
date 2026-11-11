import 'package:pantas/core/ui/components/accuracy_bar.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'accuracy_bar',
    [
      for (final a in [0.3, 0.5, 0.6, 0.7, 0.9])
        GoldenState(
          '${(a * 100).round()} percent',
          (_) => AccuracyBar(accuracy: a),
        ),
      GoldenState(
        'Topic rows, 60 percent',
        (_) => const AccuracyBar.topicRows(accuracy: 0.6),
      ),
    ],
    cellWidth: 160,
  );
}
