import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// What a checkbox is showing.
///
/// [partial] exists because a parent row can be partly selected: a topic with
/// some of its lessons picked is neither on nor off, and showing it as either
/// would lie about the selection underneath it.
enum InkCheckState { off, partial, on }

/// The project's checkbox: 15 by 15, radius 3, a 1.4px `inkMuted` border,
/// filling `board` with a white check when selected.
///
/// **Four plans named this component and none built it**, which is how the
/// practice picker ended up with a private copy. It lives here so the next
/// plan that needs one finds it instead of drawing a second.
class InkCheckbox extends StatelessWidget {
  const InkCheckbox({
    required this.state,
    this.onTap,
    this.size = 15,
    this.enabled = true,
    super.key,
  });

  /// The common two-state case, for a row that is simply picked or not.
  const factory InkCheckbox.binary({
    required bool isSelected,
    VoidCallback? onTap,
    double size,
    bool enabled,
  }) = _BinaryInkCheckbox;

  final InkCheckState state;
  final VoidCallback? onTap;
  final double size;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = state != InkCheckState.off;

    final box = Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? colors.board : null,
          borderRadius: BorderRadius.circular(3),
          border:
              filled ? null : Border.all(color: colors.inkMuted, width: 1.4),
        ),
        child: switch (state) {
          InkCheckState.on =>
            Icon(Icons.check, size: size - 4, color: colors.onBoard),
          // A bar, not a smaller tick: partial has to be legible at 15px and
          // two ticks of different sizes read as the same thing.
          InkCheckState.partial => Center(
              child: Container(
                width: size - 6,
                height: 1.6,
                color: colors.onBoard,
              ),
            ),
          InkCheckState.off => null,
        },
      ),
    );

    if (onTap == null || !enabled) return box;
    return GestureDetector(onTap: onTap, child: box);
  }
}

class _BinaryInkCheckbox extends InkCheckbox {
  const _BinaryInkCheckbox({
    required bool isSelected,
    super.onTap,
    super.size,
    super.enabled,
  }) : super(state: isSelected ? InkCheckState.on : InkCheckState.off);
}
