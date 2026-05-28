import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metric_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_key.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/consistency_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/coverage_breadth_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/difficulty_calibration_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/flag_revisit_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/metrics_window_resolver.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/mock_pacing_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/mock_stamina_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/per_question_speed_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/read_then_quiz_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/retention_shape_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/session_shape_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/subject_affinity_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/test_mode_delta_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/time_of_day_signal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

typedef MetricsSignalFactory = Signal<Object?> Function(AppDatabase db);

final Map<SignalKey, MetricsSignalFactory> metricsSignalRegistry = {
  SignalKey.timeOfDay: TimeOfDaySignal.new,
  SignalKey.sessionShape: SessionShapeSignal.new,
  SignalKey.consistency: ConsistencySignal.new,
  SignalKey.perQuestionSpeed: PerQuestionSpeedSignal.new,
  SignalKey.mockPacing: MockPacingSignal.new,
  SignalKey.mockStamina: MockStaminaSignal.new,
  SignalKey.flagRevisit: FlagRevisitSignal.new,
  SignalKey.subjectAffinity: SubjectAffinitySignal.new,
  SignalKey.testModeDelta: TestModeDeltaSignal.new,
  SignalKey.difficultyCalibration: DifficultyCalibrationSignal.new,
  SignalKey.readThenQuiz: ReadThenQuizSignal.new,
  SignalKey.retentionShape: RetentionShapeSignal.new,
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
  });

  final SignalKey signal;
  final MetricsWindow window;
  final String examId;
  final DateTime now;
  final DateTime? prepStartedAt;

  @override
  bool operator ==(Object other) {
    return other is MetricsSignalRequest &&
        other.signal == signal &&
        other.window == window &&
        other.examId == examId &&
        other.now == now &&
        other.prepStartedAt == prepStartedAt;
  }

  @override
  int get hashCode => Object.hash(signal, window, examId, now, prepStartedAt);
}

final metricsSignalProvider = FutureProvider.family
    .autoDispose<SignalResult<Object?>?, MetricsSignalRequest>(
        (ref, request) async {
  final db = ref.watch(appDatabaseProvider);
  final signal = metricsSignalRegistry[request.signal]!(db);
  if (!signal.supportedWindows.contains(request.window)) return null;
  final resolved = await MetricsWindowResolver(db).resolve(
    examId: request.examId,
    window: request.window,
    now: request.now,
    prepStartedAt: request.prepStartedAt,
  );
  return SignalResult<Object?>(
    window: resolved,
    value: await signal.compute(window: resolved, examId: request.examId),
  );
});
