import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class ValueWheel extends StatefulWidget {
  const ValueWheel({
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    required this.label,
    this.invalidIndices = const {},
    super.key,
  }) : horizontal = false;
  const ValueWheel.horizontal({
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    required this.label,
    this.invalidIndices = const {},
    super.key,
  }) : horizontal = true;
  final bool horizontal;
  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String label;
  final Set<int> invalidIndices;
  @override
  State<ValueWheel> createState() => _ValueWheelState();
}

class _ValueWheelState extends State<ValueWheel> {
  late final FixedExtentScrollController _scroll =
      FixedExtentScrollController(initialItem: widget.selectedIndex);
  late final ScrollController _horizontalScroll =
      ScrollController(initialScrollOffset: widget.selectedIndex * 56);
  double _cellWidth = 56;
  bool _jumping = false;

  void jumpHorizontal(double offset) {
    _jumping = true;
    try {
      _horizontalScroll.jumpTo(offset);
    } finally {
      _jumping = false;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ValueWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex && _scroll.hasClients) {
      _scroll.jumpToItem(widget.selectedIndex);
    }
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        _horizontalScroll.hasClients) {
      jumpHorizontal(widget.selectedIndex * _cellWidth);
    }
  }

  int? nextIndex(int direction) {
    var next = widget.selectedIndex + direction;
    while (next >= 0 &&
        next < widget.values.length &&
        widget.invalidIndices.contains(next)) {
      next += direction;
    }
    return next < 0 || next >= widget.values.length ? null : next;
  }

  void move(int direction) {
    final next = nextIndex(direction);
    if (next == null) return;
    if (widget.horizontal) {
      jumpHorizontal(next * _cellWidth);
    } else {
      _scroll.jumpToItem(next);
    }
    widget.onSelected(next);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) return const SizedBox.shrink();
    final extent = MediaQuery.textScalerOf(context).scale(20) * 1.35 + 6;
    final row = extent > 36 ? extent : 36.0;
    return Semantics(
      label: widget.label,
      value: widget.values[widget.selectedIndex],
      increasedValue:
          nextIndex(1) == null ? null : widget.values[nextIndex(1)!],
      decreasedValue:
          nextIndex(-1) == null ? null : widget.values[nextIndex(-1)!],
      onIncrease: nextIndex(1) == null ? null : () => move(1),
      onDecrease: nextIndex(-1) == null ? null : () => move(-1),
      excludeSemantics: true,
      child: CallbackShortcuts(
        bindings: {
          if (widget.horizontal) ...{
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () => move(-1),
            const SingleActivator(LogicalKeyboardKey.arrowRight): () => move(1),
          },
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => move(-1),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () => move(1),
          const SingleActivator(LogicalKeyboardKey.enter): () =>
              widget.onSelected(widget.selectedIndex),
        },
        child: Focus(
          child: widget.horizontal
              ? horizontalWheel(context)
              : SizedBox(
                  height: row * 5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 12,
                        right: 12,
                        child: Container(
                          height: row,
                          decoration: BoxDecoration(
                            color: context.colors.background,
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                      ListWheelScrollView.useDelegate(
                        controller: _scroll,
                        itemExtent: row,
                        diameterRatio: 2.4,
                        perspective: .002,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) {
                          if (!widget.invalidIndices.contains(i)) {
                            widget.onSelected(i);
                          }
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: widget.values.length,
                          builder: (context, i) => Center(
                            child: Text(
                              widget.values[i],
                              style: context.type.body.copyWith(
                                fontSize: 20,
                                letterSpacing: -.24,
                                fontWeight: i == widget.selectedIndex
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                color: i == widget.selectedIndex
                                    ? context.colors.label
                                    : context.colors.tertiaryLabel,
                                decoration: widget.invalidIndices.contains(i)
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget horizontalWheel(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(19) / 19;
    final widthChanged = _cellWidth != 56 * scale;
    _cellWidth = 56 * scale;
    if (widthChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _horizontalScroll.hasClients) {
          jumpHorizontal(widget.selectedIndex * _cellWidth);
        }
      });
    }
    final height = 48 * scale;
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: _cellWidth,
              height: 40 * scale,
              decoration: BoxDecoration(
                color: context.colors.accentTint,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            NotificationListener<ScrollEndNotification>(
              onNotification: (notification) {
                if (_jumping) return false;
                final raw = (_horizontalScroll.offset / _cellWidth).round();
                final valid = [
                  for (var i = 0; i < widget.values.length; i++)
                    if (!widget.invalidIndices.contains(i)) i,
                ];
                if (valid.isEmpty) return false;
                valid
                    .sort((a, b) => (a - raw).abs().compareTo((b - raw).abs()));
                final next = valid.first;
                if (next != widget.selectedIndex) widget.onSelected(next);
                final target = next * _cellWidth;
                if ((_horizontalScroll.offset - target).abs() > .1) {
                  jumpHorizontal(target);
                }
                return false;
              },
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    context.colors.transparent,
                    context.colors.label,
                    context.colors.label,
                    context.colors.transparent,
                  ],
                  stops: const [0, .22, .78, 1],
                ).createShader(bounds),
                child: ListView.builder(
                  controller: _horizontalScroll,
                  scrollDirection: Axis.horizontal,
                  itemExtent: _cellWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: (constraints.maxWidth - _cellWidth) / 2,
                  ),
                  itemCount: widget.values.length,
                  itemBuilder: (context, i) => Opacity(
                    opacity: widget.invalidIndices.contains(i) ? .3 : 1,
                    child: Center(
                      key: ValueKey('wheel-cell-$i'),
                      child: Text(
                        widget.values[i],
                        style: context.type.body.copyWith(
                          fontSize: i == widget.selectedIndex ? 19 : 16,
                          fontWeight: i == widget.selectedIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                          height: 1.35,
                          letterSpacing: i == widget.selectedIndex ? -.228 : 0,
                          color: i == widget.selectedIndex
                              ? context.colors.label
                              : context.colors.secondaryLabel,
                          decoration: widget.invalidIndices.contains(i)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
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
