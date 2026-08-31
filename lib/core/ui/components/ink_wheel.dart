import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// One column of a wheel picker, without iOS chrome.
///
/// CupertinoPicker was rejected: it brings its own selection overlay and its
/// own type. This is the same ListWheelScrollView underneath with our band
/// and our text styles, so a wheel looks like the rest of the app.
class InkWheel<T> extends StatefulWidget {
  const InkWheel({
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    required this.labelBuilder,
    this.semanticLabel,
    this.semanticValueBuilder,
    super.key,
  });

  final List<T> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String Function(T value) labelBuilder;
  final String? semanticLabel;
  final String Function(T value)? semanticValueBuilder;

  static const double itemHeight = 30;
  static const int visibleItems = 5;

  @override
  State<InkWheel<T>> createState() => _InkWheelState<T>();
}

class _InkWheelState<T> extends State<InkWheel<T>> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.selectedIndex);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    if (widget.values.isEmpty) return const SizedBox.shrink();

    final selectedIndex =
        widget.selectedIndex.clamp(0, widget.values.length - 1);
    String semanticValueAt(int index) {
      final value = widget.values[index];
      return widget.semanticValueBuilder?.call(value) ??
          widget.labelBuilder(value);
    }

    void select(int index) {
      final next = index.clamp(0, widget.values.length - 1);
      _controller.jumpToItem(next);
      widget.onSelected(next);
    }

    final wheel = ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: InkWheel.itemHeight,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 2.4,
      perspective: 0.002,
      onSelectedItemChanged: widget.onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: widget.values.length,
        builder: (context, index) {
          return Center(
            child: Text(
              widget.labelBuilder(widget.values[index]),
              style: styles.bodyLarge.copyWith(
                fontSize: 17,
                color: colors.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          );
        },
      ),
    );
    if (widget.semanticLabel == null) return wheel;

    return Semantics(
      label: widget.semanticLabel,
      value: semanticValueAt(selectedIndex),
      increasedValue: selectedIndex < widget.values.length - 1
          ? semanticValueAt(selectedIndex + 1)
          : null,
      decreasedValue:
          selectedIndex > 0 ? semanticValueAt(selectedIndex - 1) : null,
      slider: true,
      onIncrease: selectedIndex < widget.values.length - 1
          ? () => select(selectedIndex + 1)
          : null,
      onDecrease: selectedIndex > 0 ? () => select(selectedIndex - 1) : null,
      excludeSemantics: true,
      child: wheel,
    );
  }
}

/// The band behind the live row. Drawn once behind a Row of wheels so every
/// column shares one band rather than each drawing its own.
class InkWheelBand extends StatelessWidget {
  const InkWheelBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: InkWheel.itemHeight,
        decoration: BoxDecoration(
          color: context.colors.ruleFaint,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
