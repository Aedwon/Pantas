import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/signals/consistency_signal.dart';
import 'package:pantas/features/metrics/signals/coverage_breadth_signal.dart';
import 'package:pantas/features/metrics/signals/difficulty_calibration_signal.dart';
import 'package:pantas/features/metrics/signals/flag_revisit_signal.dart';
import 'package:pantas/features/metrics/signals/metrics_window_resolver.dart';
import 'package:pantas/features/metrics/signals/mock_pacing_signal.dart';
import 'package:pantas/features/metrics/signals/mock_stamina_signal.dart';
import 'package:pantas/features/metrics/signals/per_question_speed_signal.dart';
import 'package:pantas/features/metrics/signals/read_then_quiz_signal.dart';
import 'package:pantas/features/metrics/signals/retention_shape_signal.dart';
import 'package:pantas/features/metrics/signals/session_shape_signal.dart';
import 'package:pantas/features/metrics/signals/subject_affinity_signal.dart';
import 'package:pantas/features/metrics/signals/test_mode_delta_signal.dart';
import 'package:pantas/features/metrics/signals/time_of_day_signal.dart';

/// Every signal is built from both databases even when it needs only one.
/// A uniform factory is what lets the registry stay a plain map; the signals
/// that never touch the corpus simply ignore the second argument.
typedef MetricsSignalFactory = Signal<Object?> Function(
  AppDatabase db,
  ContentDatabase contentDb,
);

final Map<SignalKey, MetricsSignalFactory> metricsSignalRegistry = {
  SignalKey.timeOfDay: (db, _) => TimeOfDaySignal(db),
  SignalKey.sessionShape: (db, _) => SessionShapeSignal(db),
  SignalKey.consistency: (db, _) => ConsistencySignal(db),
  SignalKey.perQuestionSpeed: (db, _) => PerQuestionSpeedSignal(db),
  SignalKey.mockPacing: (db, _) => MockPacingSignal(db),
  SignalKey.mockStamina: MockStaminaSignal.new,
  SignalKey.flagRevisit: (db, _) => FlagRevisitSignal(db),
  SignalKey.subjectAffinity: SubjectAffinitySignal.new,
  SignalKey.testModeDelta: TestModeDeltaSignal.new,
  SignalKey.difficultyCalibration: (db, _) => DifficultyCalibrationSignal(db),
  SignalKey.readThenQuiz: ReadThenQuizSignal.new,
  SignalKey.retentionShape: (db, _) => RetentionShapeSignal(db),
  SignalKey.coverageBreadth: CoverageBreadthSignal.new,
};

@immutable
class MetricsSignalRequest {
  const MetricsSignalRequest({
    required this.signal,
    required this.window,
    required this.examId,
    required this.now,
    this.prepStartedAt,
    this.forTendency = false,
  });

  final SignalKey signal;
  final MetricsWindow window;
  final String examId;
  final DateTime now;
  final DateTime? prepStartedAt;
  final bool forTendency;

  @override
  bool operator ==(Object other) {
    return other is MetricsSignalRequest &&
        other.signal == signal &&
        other.window == window &&
        other.examId == examId &&
        other.now == now &&
        other.prepStartedAt == prepStartedAt &&
        other.forTendency == forTendency;
  }

  @override
  int get hashCode =>
      Object.hash(signal, window, examId, now, prepStartedAt, forTendency);
}

final metricsSignalProvider = FutureProvider.family
    .autoDispose<SignalResult<Object?>?, MetricsSignalRequest>(
        (ref, request) async {
  final db = ref.watch(appDatabaseProvider);
  final contentDb = ref.watch(contentDatabaseProvider);
  final signal = metricsSignalRegistry[request.signal]!(db, contentDb);
  if (!signal.supportedWindows.contains(request.window)) return null;
  final resolved = await MetricsWindowResolver(db).resolve(
    examId: request.examId,
    window: request.window,
    now: request.now,
    prepStartedAt: request.prepStartedAt,
    bypassSessionFloor: request.forTendency &&
        const {
          SignalKey.testModeDelta,
          SignalKey.mockStamina,
          SignalKey.readThenQuiz,
          SignalKey.perQuestionSpeed,
          SignalKey.retentionShape,
        }.contains(request.signal),
  );
  return SignalResult<Object?>(
    window: resolved,
    value: await signal.compute(window: resolved, examId: request.examId),
  );
});
