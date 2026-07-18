import 'package:meta/meta.dart';

/// How far the question wheel turns.
///
/// Past what the corpus holds, on purpose. A student whose exam really is
/// 150 questions may have ticked only Science, which holds 60: capping the
/// wheel at the corpus is the one option that throws their true answer
/// away, and that answer is the signal that says which exam to author next.
const int questionWheelCeiling = 240;

/// What the student asked for against what their track can supply.
@immutable
class CorpusFit {
  const CorpusFit({required this.requested, required this.available});

  final int requested;
  final int available;

  bool get fits => requested <= available;

  /// How many more questions the track would need to carry.
  int get shortfall => fits ? 0 : requested - available;
}

abstract final class CheckCorpusFit {
  /// The refusal happens at save, never at the wheel.
  ///
  /// Accepting 150 and quietly running 60 was ruled out: a mock sells
  /// fidelity, and that would sell it, deliver a shorter paper, and tell
  /// the student only after they had taken the whole thing.
  static CorpusFit call({required int requested, required int available}) =>
      CorpusFit(requested: requested, available: available);
}
