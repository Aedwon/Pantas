import 'package:pantas/features/metrics/atoms/atom.dart';
import 'package:pantas/features/metrics/atoms/atom_rotation.dart';
import 'package:pantas/features/metrics/atoms/home_atoms.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class HomeAtomRequest {
  const HomeAtomRequest({
    required this.examId,
    required this.userId,
    required this.localDate,
    required this.now,
    this.prepStartedAt,
    this.rotationOrderOverride,
  });

  final String examId;
  final String userId;
  final DateTime localDate;
  final DateTime now;
  final DateTime? prepStartedAt;
  final List<AtomKey>? rotationOrderOverride;

  @override
  bool operator ==(Object other) {
    return other is HomeAtomRequest &&
        other.examId == examId &&
        other.userId == userId &&
        other.localDate == localDate &&
        other.now == now &&
        other.prepStartedAt == prepStartedAt &&
        _sameOrder(other.rotationOrderOverride, rotationOrderOverride);
  }

  @override
  int get hashCode => Object.hash(
        examId,
        userId,
        localDate,
        now,
        prepStartedAt,
        Object.hashAll(rotationOrderOverride ?? const []),
      );
}

final homeAtomProvider = FutureProvider.family
    .autoDispose<AtomChip?, HomeAtomRequest>((ref, request) async {
  Future<Object?> readSignal({
    required SignalKey signal,
    required MetricsWindow window,
    required String examId,
  }) async {
    final result = await ref.read(
      metricsSignalProvider(
        MetricsSignalRequest(
          signal: signal,
          window: window,
          examId: examId,
          now: request.now,
          prepStartedAt: request.prepStartedAt,
        ),
      ).future,
    );
    return result?.value;
  }

  final atoms = <Atom>[
    TimeOfDayAtom(readSignal),
    SessionShapeAtom(readSignal),
    ConsistencyAtom(readSignal),
    PerQuestionSpeedAtom(readSignal),
    SubjectAffinityAtom(readSignal),
    CoverageBreadthAtom(readSignal),
    RetentionShapeAtom(readSignal),
  ];
  final chips = <AtomKey, AtomChip>{};
  for (final atom in atoms) {
    final chip = await atom.select(examId: request.examId);
    if (chip != null) chips[atom.key] = chip;
  }
  final available = request.rotationOrderOverride ??
      atoms.map((atom) => atom.key).where(chips.containsKey).toList();
  for (final key in available) {
    if (!chips.containsKey(key)) continue;
    final selected = const AtomRotation().pick(
      userId: request.userId,
      localDate: request.localDate,
      available: available.where(chips.containsKey).toList(),
    );
    if (selected == null) return null;
    return chips[selected];
  }
  return null;
});

bool _sameOrder(List<AtomKey>? a, List<AtomKey>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i += 1) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
