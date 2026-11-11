import 'dart:ui';

import 'package:pantas/features/quiz/application/quiz_performance_probe.dart';

enum Qlp5Metric {
  startFeedback,
  retryFeedback,
  firstRecommendation,
  unchangedRecommendationFrame,
  warmStart,
  coldDailyRoute,
  resume5,
  resume10,
  resume20,
  preparedNext,
  firstAnswerable,
  launchToAnswerable,
}

enum Qlp5RunTemperature { cold, warm }

final class Qlp5EvidenceProvenance {
  const Qlp5EvidenceProvenance({
    required this.sourceSha,
    required this.contentSeedVersion,
    required this.payloadSha256,
    required this.manifestSha256,
    required this.signatureSha256,
    required this.deviceModel,
    required this.androidVersion,
    required this.memoryClassMb,
    required this.refreshRateHz,
    required this.buildMode,
  });

  final String sourceSha;
  final String contentSeedVersion;
  final String payloadSha256;
  final String manifestSha256;
  final String signatureSha256;
  final String deviceModel;
  final String androidVersion;
  final int memoryClassMb;
  final int refreshRateHz;
  final String buildMode;

  Map<String, Object> toJson() => {
        'source_sha': sourceSha,
        'content_seed_version': contentSeedVersion,
        'payload_sha256': payloadSha256,
        'manifest_sha256': manifestSha256,
        'signature_sha256': signatureSha256,
        'device_model': deviceModel,
        'android_version': androidVersion,
        'memory_class_mb': memoryClassMb,
        'refresh_rate_hz': refreshRateHz,
        'build_mode': buildMode,
      };
}

final class Qlp5PerformanceCollector {
  final List<_Observation> _observations = <_Observation>[];
  final List<QuizPerformanceSample> _phaseSamples = <QuizPerformanceSample>[];
  final List<_FrameSample> _frames = <_FrameSample>[];

  List<QuizPerformanceSample> get phaseSamples =>
      List<QuizPerformanceSample>.unmodifiable(_phaseSamples);

  void recordObservation(
    Qlp5Metric metric,
    Duration elapsed, {
    required Qlp5RunTemperature temperature,
  }) {
    _observations.add(
      _Observation(metric: metric, temperature: temperature, elapsed: elapsed),
    );
  }

  void recordPhaseSample(QuizPerformanceSample sample) {
    _phaseSamples.add(sample);
  }

  void recordFrame({
    required Duration buildDuration,
    required Duration rasterDuration,
  }) {
    _frames.add(
      _FrameSample(
        buildDuration: buildDuration,
        rasterDuration: rasterDuration,
      ),
    );
  }

  void recordFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      recordFrame(
        buildDuration: timing.buildDuration,
        rasterDuration: timing.rasterDuration,
      );
    }
  }

  Qlp5MetricSummary summary(
    Qlp5Metric metric, {
    required Qlp5RunTemperature temperature,
  }) {
    final values = <int>[
      for (final observation in _observations)
        if (observation.metric == metric &&
            observation.temperature == temperature)
          observation.elapsed.inMicroseconds,
    ]..sort();
    if (values.isEmpty) {
      throw StateError('no observations for requested metric and temperature');
    }
    return Qlp5MetricSummary(
      metric: metric,
      temperature: temperature,
      sampleCount: values.length,
      medianUs: _median(values),
      p95Us: _percentile95(values),
      maxUs: values.last,
    );
  }

  Qlp5FrameSummary get frameSummary {
    if (_frames.isEmpty) throw StateError('no frame samples recorded');
    final builds = _frames
        .map((frame) => frame.buildDuration.inMicroseconds)
        .toList()
      ..sort();
    final rasters = _frames
        .map((frame) => frame.rasterDuration.inMicroseconds)
        .toList()
      ..sort();
    return Qlp5FrameSummary(
      sampleCount: _frames.length,
      p95BuildUs: _percentile95(builds),
      p95RasterUs: _percentile95(rasters),
      maxBuildUs: builds.last,
      maxRasterUs: rasters.last,
      missedBuildFrames60Hz: _frames
          .where((frame) => frame.buildDuration > _frameBudget60Hz)
          .length,
      missedRasterFrames60Hz: _frames
          .where((frame) => frame.rasterDuration > _frameBudget60Hz)
          .length,
    );
  }
}

final class Qlp5MetricSummary {
  const Qlp5MetricSummary({
    required this.metric,
    required this.temperature,
    required this.sampleCount,
    required this.medianUs,
    required this.p95Us,
    required this.maxUs,
  });

  final Qlp5Metric metric;
  final Qlp5RunTemperature temperature;
  final int sampleCount;
  final int medianUs;
  final int p95Us;
  final int maxUs;

  bool get hasOrdinarySampleMinimum => sampleCount >= 30;

  Map<String, Object> toJson() => {
        'metric': _metricName(metric),
        'temperature': temperature.name,
        'samples': sampleCount,
        'median_us': medianUs,
        'p95_us': p95Us,
        'max_us': maxUs,
      };
}

final class Qlp5FrameSummary {
  const Qlp5FrameSummary({
    required this.sampleCount,
    required this.p95BuildUs,
    required this.p95RasterUs,
    required this.maxBuildUs,
    required this.maxRasterUs,
    required this.missedBuildFrames60Hz,
    required this.missedRasterFrames60Hz,
  });

  final int sampleCount;
  final int p95BuildUs;
  final int p95RasterUs;
  final int maxBuildUs;
  final int maxRasterUs;
  final int missedBuildFrames60Hz;
  final int missedRasterFrames60Hz;

  Map<String, Object> toJson() => {
        'samples': sampleCount,
        'build_p95_us': p95BuildUs,
        'raster_p95_us': p95RasterUs,
        'build_max_us': maxBuildUs,
        'raster_max_us': maxRasterUs,
        'missed_build_frames_60hz': missedBuildFrames60Hz,
        'missed_raster_frames_60hz': missedRasterFrames60Hz,
      };
}

final class _Observation {
  const _Observation({
    required this.metric,
    required this.temperature,
    required this.elapsed,
  });

  final Qlp5Metric metric;
  final Qlp5RunTemperature temperature;
  final Duration elapsed;
}

final class _FrameSample {
  const _FrameSample({
    required this.buildDuration,
    required this.rasterDuration,
  });

  final Duration buildDuration;
  final Duration rasterDuration;
}

const _frameBudget60Hz = Duration(microseconds: 16700);

int _median(List<int> sorted) {
  final middle = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[middle];
  return (sorted[middle - 1] + sorted[middle]) ~/ 2;
}

int _percentile95(List<int> sorted) {
  final rank = ((sorted.length * 95) + 99) ~/ 100;
  return sorted[rank.clamp(1, sorted.length) - 1];
}

String _metricName(Qlp5Metric metric) => switch (metric) {
      Qlp5Metric.startFeedback => 'start_feedback',
      Qlp5Metric.retryFeedback => 'retry_feedback',
      Qlp5Metric.firstRecommendation => 'first_recommendation',
      Qlp5Metric.unchangedRecommendationFrame =>
        'unchanged_recommendation_frame',
      Qlp5Metric.warmStart => 'warm_start',
      Qlp5Metric.coldDailyRoute => 'cold_daily_route',
      Qlp5Metric.resume5 => 'resume_5',
      Qlp5Metric.resume10 => 'resume_10',
      Qlp5Metric.resume20 => 'resume_20',
      Qlp5Metric.preparedNext => 'prepared_next',
      Qlp5Metric.firstAnswerable => 'first_answerable',
      Qlp5Metric.launchToAnswerable => 'launch_to_answerable',
    };
