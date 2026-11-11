import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';

/// The Columns "primary and secondary" pair (design system Columns): the main
/// block grows 1.45 from 480, the side block 1 from 340, 28 apart. Below the
/// sum of both bases and the gap the side block goes under the main one.
/// Home, Plan, Performance and Record all use this one pair.
abstract final class HomeColumns {
  static const PantasFlex _primary = PantasLayout.colPrimary;
  static const PantasFlex _secondary = PantasLayout.colSecondary;

  /// The gap between the two blocks and between wrapped rows.
  static const double gap = PantasLayout.sectionGap;

  /// The content width under which the pair stacks.
  static final double stackBelow = _primary.basis + _secondary.basis + gap;

  /// Whether the pair stacks in a row [width] wide.
  static bool stacks(double width) => width < stackBelow;

  /// The main block's width in a row [width] wide: its basis plus its share
  /// of the free space.
  static double primaryWidth(double width) {
    final free = (width - stackBelow).clamp(0.0, double.infinity);
    return _primary.basis +
        free * _primary.grow / (_primary.grow + _secondary.grow);
  }
}
