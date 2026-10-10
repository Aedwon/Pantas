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
  });
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
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ValueWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex && _scroll.hasClients) {
      _scroll.jumpToItem(widget.selectedIndex);
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
    _scroll.jumpToItem(next);
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
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => move(-1),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () => move(1),
          const SingleActivator(LogicalKeyboardKey.enter): () =>
              widget.onSelected(widget.selectedIndex),
        },
        child: Focus(
          child: SizedBox(
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
}
