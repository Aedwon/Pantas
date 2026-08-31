import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// The pager, floating over the paper.
///
/// The mock has one and the practice quiz does not: in practice you move
/// forward and the reveal is the event, and in a mock you move both ways
/// constantly with nothing ever revealed, so paging is the primary
/// interaction. It also frees the app bar for the clock.
///
/// This is the app's one approved shadow, and the only radius. Do not
/// propagate either, and do not "fix" them to match the identity ban.
class MockFloatingBar extends StatelessWidget {
  const MockFloatingBar({
    required this.position,
    required this.total,
    required this.isFlagged,
    required this.onPrevious,
    required this.onNext,
    required this.onGrid,
    required this.onFlag,
    super.key,
  });

  final int position;
  final int total;
  final bool isFlagged;

  /// Null dims the control and leaves it in place. A control that vanishes
  /// moves the ones beside it.
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  final VoidCallback onGrid;
  final VoidCallback onFlag;

  static const double baseGap = 16;

  /// The grid glyph is a solid block dense to its edges while the pennant
  /// is open on its lower right and carries its own whitespace, so equal
  /// metric gaps read unequal. An optical correction, not an
  /// inconsistency: do not normalise this to the base gap.
  double get gridSideGap => baseGap + 5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    // The 14px inset from the bottom and each side belongs to the page
    // that floats this, so the bar itself measures the 54 it claims.
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.rule,
          // ignore: avoid_redundant_argument_values
          width: AppDimensions.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BarControl(
            controlKey: const ValueKey('mock-prev'),
            semanticLabel: 'Previous question',
            onTap: onPrevious,
            child: Text('\u2039', style: styles.headlineMedium),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BarControl(
                controlKey: const ValueKey('mock-grid'),
                semanticLabel: 'Question navigator',
                onTap: onGrid,
                child: _GridGlyph(color: colors.ink),
              ),
              SizedBox(width: gridSideGap),
              // The counter is a control, not a label: both it and the
              // glyph open the grid.
              Semantics(
                button: true,
                enabled: true,
                label: 'Question $position of $total, open question navigator',
                onTap: onGrid,
                excludeSemantics: true,
                child: InkWell(
                  onTap: onGrid,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Center(
                      child: Text(
                        '$position of $total',
                        style: styles.bodyMedium.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: baseGap),
              _BarControl(
                controlKey: const ValueKey('mock-flag'),
                semanticLabel: 'Flag question',
                isToggled: isFlagged,
                onTap: onFlag,
                child: PennantMark(
                  isSet: isFlagged,
                  size: 18,
                  color: isFlagged ? colors.ink : colors.inkMuted,
                ),
              ),
            ],
          ),
          _BarControl(
            controlKey: const ValueKey('mock-next'),
            semanticLabel: 'Next question',
            onTap: onNext,
            child: Text('\u203a', style: styles.headlineMedium),
          ),
        ],
      ),
    );
  }
}

class _BarControl extends StatelessWidget {
  const _BarControl({
    required this.controlKey,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
    this.isToggled,
  });

  final Key controlKey;
  final String semanticLabel;
  final VoidCallback? onTap;
  final Widget child;
  final bool? isToggled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      toggled: isToggled,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        key: controlKey,
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.32 : 1,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// Nine filled squares, 5.4px each with 1.6px gaps in a 24 viewBox.
class _GridGlyph extends StatelessWidget {
  const _GridGlyph({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(19, 19), painter: _GridPainter(color));
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const viewBox = 24.0;
    const square = 5.4;
    const gap = 1.6;
    final scale = size.width / viewBox;
    final paint = Paint()..color = color;

    for (var row = 0; row < 3; row += 1) {
      for (var column = 0; column < 3; column += 1) {
        final left = column * (square + gap) * scale;
        final top = row * (square + gap) * scale;
        canvas.drawRect(
          Rect.fromLTWH(left, top, square * scale, square * scale),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}
