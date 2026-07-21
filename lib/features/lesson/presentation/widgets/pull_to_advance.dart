import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PullToAdvance extends StatefulWidget {
  const PullToAdvance({
    required this.child,
    required this.nextTitle,
    required this.onAdvance,
    required this.isAtEnd,
    super.key,
  });

  final Widget child;
  final String? nextTitle;
  final VoidCallback? onAdvance;

  /// Whether the reader has reached the end of the lesson.
  ///
  /// The handle used to sit under every lesson from the first line, offering
  /// the next topic to someone who had not read a word of this one. It is an
  /// ending, so it arrives at the end.
  final ValueListenable<bool> isAtEnd;

  @override
  State<PullToAdvance> createState() => _PullToAdvanceState();
}

class _PullToAdvanceState extends State<PullToAdvance>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  static const _maxRange = 150.0;
  static const _threshold = 90.0;

  bool get _hasHandle =>
      widget.nextTitle != null &&
      widget.onAdvance != null &&
      widget.isAtEnd.value;
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
      // The lift is not released. The page keeps travelling up into the
      // route transition, which carries the same motion on, so the hand and
      // the screen never disagree about which way the reader is going.
      widget.onAdvance?.call();
      return;
    }
    setState(() {
      _dragOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      behavior: HitTestBehavior.translucent,
      // The pull moves the sheet. Without this the gesture changed the
      // handle's width and nothing else, so the drag had no object: the
      // hand pulled and the page stayed where it was.
      child: Transform.translate(
        offset: Offset(0, -_dragOffset),
        child: Column(
          children: [
            Expanded(child: widget.child),
            // Fades and grows in as the end comes into view rather than
            // appearing outright, so the arrival is part of the reading.
            ValueListenableBuilder<bool>(
              valueListenable: widget.isAtEnd,
              builder: (context, _, __) => AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: !_hasHandle
                    ? const SizedBox(width: double.infinity)
                    : AnimatedOpacity(
                        opacity: 1,
                        duration: const Duration(milliseconds: 260),
                        child: Container(
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
                                        color: _isArmed
                                            ? colors.board
                                            : colors.ink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
