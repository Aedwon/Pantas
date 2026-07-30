import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

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
    super.key,
  });

  final List<T> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String Function(T value) labelBuilder;

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

    return ListWheelScrollView.useDelegate(
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
