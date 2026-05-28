import 'package:cse_cet_reviewer/features/metrics/atoms/atom.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_key.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';

typedef SignalReader = Future<Object?> Function({
  required SignalKey signal,
  required MetricsWindow window,
  required String examId,
});

class TimeOfDayAtom implements Atom {
  const TimeOfDayAtom(this._read);

  final SignalReader _read;

  @override
  AtomKey get key => AtomKey.timeOfDay;

  @override
  Future<AtomChip?> select({required String examId}) async {
    final signal = await _read(
      signal: SignalKey.timeOfDay,
      window: MetricsWindow.rolling30d,
      examId: examId,
    );
    if (signal is! DayHourHistogram || signal.buckets.isEmpty) return null;
    final best = [...signal.buckets]
      ..sort((a, b) => b.accuracy.compareTo(a.accuracy));
    final hour = best.first.hour;
    return AtomChip(
      text: 'Sharpest at ${_hourLower(hour)}',
      metric: _hourUpper(hour),
      proDepth: ProDepth(label: 'Hourly accuracy', data: signal),
    );
  }
}

class SessionShapeAtom implements Atom {
  const SessionShapeAtom(this._read);

  final SignalReader _read;

  @override
  AtomKey get key => AtomKey.sessionShape;

  @override
  Future<AtomChip?> select({required String examId}) async {
    final signal = await _read(
      signal: SignalKey.sessionShape,
      window: MetricsWindow.rolling30d,
      examId: examId,
    );
    if (signal is! DurationDistribution) return null;
    final minutes = signal.averageMinutes.round();
    return AtomChip(
      text: 'Avg $minutes-min sits',
      metric: '$minutes min',
      proDepth: ProDepth(label: 'Session trend', data: signal),
    );
  }
}

class ConsistencyAtom implements Atom {
  const ConsistencyAtom(this._read);

  final SignalReader _read;

  @override
  AtomKey get key => AtomKey.consistency;

  @override
  Future<AtomChip?> select({required String examId}) async {
    final signal = await _read(
      signal: SignalKey.consistency,
      window: MetricsWindow.allTime,
      examId: examId,
    );
    if (signal is! StreakPattern || signal.currentStreakDays <= 0) return null;
    return AtomChip(
      text: 'Day ${signal.currentStreakDays} streak',
      metric: '${signal.currentStreakDays}',
      proDepth: ProDepth(label: 'Weekday heatmap', data: signal),
    );
  }
}

class PerQuestionSpeedAtom implements Atom {
  const PerQuestionSpeedAtom(this._read);

  final SignalReader _read;

  @override
  AtomKey get key => AtomKey.perQuestionSpeed;

  @override
  Future<AtomChip?> select({required String examId}) async {
    final signal = await _read(
      signal: SignalKey.perQuestionSpeed,
      window: MetricsWindow.rolling30d,
      examId: examId,
    );
    if (signal is! LatencyDistribution) return null;
    final seconds = (signal.averageMs / 1000).round();
    return AtomChip(
      text: '${seconds}s avg, fast and accurate',
      metric: '${seconds}s',
      proDepth: ProDepth(label: 'Speed x accuracy', data: signal),
    );
  }
}

class SubjectAffinityAtom implements Atom {
  const SubjectAffinityAtom(this._read);

  final SignalReader _read;

  @override
  AtomKey get key => AtomKey.subjectAffinity;

  @override
  Future<AtomChip?> select({required String examId}) async {
    final signal = await _read(
      signal: SignalKey.subjectAffinity,
      window: MetricsWindow.rolling30d,
      examId: examId,
    );
    if (signal is! SubjectAccuracySpeed || signal.subjects.length < 2) {
      return null;
    }
    final rows = signal.subjects.entries.toList()
      ..sort((a, b) => a.value.averageMs.compareTo(b.value.averageMs));
    final fastest = rows.first;
    final others = rows.skip(1).map((entry) => entry.value.averageMs);
    final otherAverage = others.reduce((a, b) => a + b) / others.length;
    final fasterPct =
        ((otherAverage - fastest.value.averageMs) / otherAverage * 100).round();
    return AtomChip(
      text: '${fastest.key} $fasterPct% faster',
      metric: fastest.key,
      proDepth: ProDepth(label: 'Subject deltas', data: signal),
    );
  }
}

class CoverageBreadthAtom implements Atom {
  const CoverageBreadthAtom(this._read);

  final SignalReader _read;

  @override
  AtomKey get key => AtomKey.coverageBreadth;

  @override
  Future<AtomChip?> select({required String examId}) async {
    final signal = await _read(
      signal: SignalKey.coverageBreadth,
      window: MetricsWindow.allTime,
      examId: examId,
    );
    if (signal is! CoveragePct || signal.totalTopics == 0) return null;
    final pct = (signal.percent * 100).round();
    return AtomChip(
      text: 'Touched $pct% of syllabus',
      metric: '$pct%',
      proDepth: ProDepth(label: 'Coverage bars', data: signal),
    );
  }
}

class RetentionShapeAtom implements Atom {
  const RetentionShapeAtom(this._read);

  final SignalReader _read;

  @override
  AtomKey get key => AtomKey.retentionShape;

  @override
  Future<AtomChip?> select({required String examId}) async {
    final signal = await _read(
      signal: SignalKey.retentionShape,
      window: MetricsWindow.rolling30d,
      examId: examId,
    );
    if (signal is! RetentionCurve) return null;
    final lapse = (signal.lapseRate * 100).round();
    return AtomChip(
      text: 'Strong cards lapse $lapse%',
      metric: '$lapse%',
      proDepth: ProDepth(label: 'FSRS stability', data: signal),
    );
  }
}

String _hourLower(int hour) {
  final suffix = hour >= 12 ? 'pm' : 'am';
  final display = hour % 12 == 0 ? 12 : hour % 12;
  return '$display$suffix';
}

String _hourUpper(int hour) {
  final suffix = hour >= 12 ? 'PM' : 'AM';
  final display = hour % 12 == 0 ? 12 : hour % 12;
  return '$display $suffix';
}
