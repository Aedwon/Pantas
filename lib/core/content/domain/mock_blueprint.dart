import 'package:flutter/foundation.dart';

/// How the testing body times this exam's parts.
///
/// `null` means unpublished, and it is a real state: ACET, DCAT and
/// MSU-SASE publish nothing. It is never defaulted to either value,
/// because guessing wrong about whether a student can go back is the most
/// expensive wrong guess this app can make.
enum SectionalTiming { sectional, roamable }

/// The percentage at which this exam calls a score a pass, and the one
/// above which it is close. Content, per exam. `null` means the exam has
/// not published them.
@immutable
class ScoreBands {
  const ScoreBands({required this.passAtPercent, required this.closeAtPercent});

  final int passAtPercent;
  final int closeAtPercent;

  @override
  bool operator ==(Object other) =>
      other is ScoreBands &&
      other.passAtPercent == passAtPercent &&
      other.closeAtPercent == closeAtPercent;

  @override
  int get hashCode => Object.hash(passAtPercent, closeAtPercent);
}

class MockBlueprint {
  const MockBlueprint({
    required this.id,
    required this.examId,
    required this.name,
    required this.durationMinutes,
    required this.sectionsJson,
    this.sectionalTiming,
    this.scoreBands,
  });

  final String id;
  final String examId;
  final String name;
  final int durationMinutes;
  final String sectionsJson;

  /// Null means the testing body has not published how it times the parts.
  final SectionalTiming? sectionalTiming;

  /// Null means the exam has not published its thresholds.
  final ScoreBands? scoreBands;
}
