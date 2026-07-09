import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PullToAdvance extends StatefulWidget {
  const PullToAdvance({
    required this.child,
    required this.nextTitle,
    required this.onAdvance,
    super.key,
  });

  final Widget child;
  final String? nextTitle;
  final VoidCallback? onAdvance;

  @override
  State<PullToAdvance> createState() => _PullToAdvanceState();
}

class _PullToAdvanceState extends State<PullToAdvance>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  static const _maxRange = 150.0;
  static const _threshold = 90.0;

  bool get _hasHandle => widget.nextTitle != null && widget.onAdvance != null;
  bool get _isArmed => _dragOffset >= _threshold;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_hasHandle) return;
    setState(() {
      _dragOffset = (_dragOffset - details.delta.dy).clamp(0.0, _maxRange);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_hasHandle) return;
    if (_isArmed) {
      widget.onAdvance?.call();
    }
    setState(() {
      _dragOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasHandle) {
      return widget.child;
    }

    final colors = context.colors;
    final textStyles = context.textStyles;

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          Expanded(child: widget.child),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  key: const ValueKey('pull-handle'),
                  duration: const Duration(milliseconds: 120),
                  width: _isArmed ? 52 : 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _isArmed ? colors.board : colors.rule,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Pull up for ',
                        style: textStyles.bodySmall.copyWith(
                          color: colors.inkMuted,
                        ),
                      ),
                      TextSpan(
                        text: widget.nextTitle,
                        style: textStyles.bodySmall.copyWith(
                          color: _isArmed ? colors.board : colors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
