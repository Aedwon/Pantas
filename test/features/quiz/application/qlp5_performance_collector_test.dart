import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/application/quiz_performance_probe.dart';

import '../../../../integration_test/release/support/qlp5_performance_collector.dart';

void main() {
  test('collector reports deterministic median p95 max and 30-run readiness',
      () {
    final collector = Qlp5PerformanceCollector();
    for (var i = 1; i <= 30; i++) {
      collector.recordObservation(
        Qlp5Metric.firstRecommendation,
        Duration(milliseconds: i),
        temperature: Qlp5RunTemperature.warm,
      );
    }

    final summary = collector.summary(
      Qlp5Metric.firstRecommendation,
      temperature: Qlp5RunTemperature.warm,
    );
    expect(summary.sampleCount, 30);
    expect(summary.medianUs, 15500);
    expect(summary.p95Us, 29000);
    expect(summary.maxUs, 30000);
    expect(summary.hasOrdinarySampleMinimum, isTrue);
    expect(
      summary.toJson().keys,
      {'metric', 'temperature', 'samples', 'median_us', 'p95_us', 'max_us'},
    );
  });

  test('frame collector reports build raster and 60 Hz misses', () {
    final summary = (Qlp5PerformanceCollector()
          ..recordFrame(
            buildDuration: const Duration(milliseconds: 10),
            rasterDuration: const Duration(milliseconds: 12),
          )
          ..recordFrame(
            buildDuration: const Duration(milliseconds: 18),
            rasterDuration: const Duration(milliseconds: 20),
          ))
        .frameSummary;
    expect(summary.sampleCount, 2);
    expect(summary.missedBuildFrames60Hz, 1);
    expect(summary.missedRasterFrames60Hz, 1);
    expect(summary.maxBuildUs, 18000);
    expect(summary.maxRasterUs, 20000);
    expect(
      summary.toJson().keys,
      {
        'samples',
        'build_p95_us',
        'raster_p95_us',
        'build_max_us',
        'raster_max_us',
        'missed_build_frames_60hz',
        'missed_raster_frames_60hz',
      },
    );
  });

  test('collector accepts fixed internal phase samples without payload fields',
      () {
    final collector = Qlp5PerformanceCollector()
      ..recordPhaseSample(
        const QuizPerformanceSample(
          phase: QuizPerformancePhase.hydration,
          elapsed: Duration(microseconds: 321),
        ),
      );

    expect(collector.phaseSamples.single.toJson(), {
      'phase': 'hydration',
      'elapsed_us': 321,
    });
  });
}
