import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

class ValueWheel extends StatefulWidget {
  const ValueWheel({
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    required this.label,
    this.invalidIndices = const {},
    this.shortValues,
    this.groupShare = .5,
    super.key,
  })  : horizontal = false,
        birthYear = false;
  const ValueWheel.birthYear({
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    required this.label,
    super.key,
  })  : horizontal = false,
        birthYear = true,
        shortValues = null,
        groupShare = 1,
        invalidIndices = const {};
  const ValueWheel.horizontal({
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    required this.label,
    this.invalidIndices = const {},
    super.key,
  })  : horizontal = true,
        shortValues = null,
        groupShare = 1,
        birthYear = false;
  final bool horizontal;
  final bool birthYear;
  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String label;
  final Set<int> invalidIndices;

  /// A shorter text for each value (Jan, Feb for January, February). The
  /// wheel draws it when its column is narrow (the group is under
  /// `layout-wheel-full`, 21rem, wide); the full value stays the accessible
  /// name (D190 item 6).
  final List<String>? shortValues;

  /// The share of the wheel group this wheel's column takes, for the width
  /// test above (the month wheel of a month, day, year group is about half).
  final double groupShare;
  @override
  State<ValueWheel> createState() => _ValueWheelState();
}

class _ValueWheelState extends State<ValueWheel> {
  static const double _cellBase = PantasSpace.s56;
  late final FixedExtentScrollController _scroll =
      FixedExtentScrollController(initialItem: widget.selectedIndex);
  late final ScrollController _horizontalScroll =
      ScrollController(initialScrollOffset: widget.selectedIndex * _cellBase);
  double _cellWidth = _cellBase;
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
      _jumpVertical(widget.selectedIndex);
    }
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        _horizontalScroll.hasClients) {
      jumpHorizontal(widget.selectedIndex * _cellWidth);
    }
  }

  void _jumpVertical(int index) {
    _jumping = true;
    try {
      _scroll.jumpToItem(index);
    } finally {
      _jumping = false;
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
      _jumpVertical(next);
    }
    widget.onSelected(next);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) return const SizedBox.shrink();
    final scaler = MediaQuery.textScalerOf(context);
    final colors = context.colors;
    // The row height follows the scaled line (D190): the larger of 36 and the
    // wheel line plus 16 (the birth year wheel: its 22 px line plus 14, 44 at
    // least). The viewport, the snap spacing and the band share it.
    final line = widget.birthYear
        ? scaler.scale(PantasType.phoneTitle2.fontSize!) *
                PantasType.phoneTitle2.height! +
            PantasSpace.s14
        : scaler.scale(PantasType.phoneWheel.fontSize!) *
                PantasType.phoneWheel.height! +
            PantasSpace.s16;
    final minimum =
        widget.birthYear ? PantasSize.targetTouch : PantasSize.wheelRow;
    final row = line > minimum ? line : minimum;
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
          const SingleActivator(
            LogicalKeyboardKey.enter,
            includeRepeats: false,
          ): () => widget.onSelected(widget.selectedIndex),
        },
        child: Focus(
          child: widget.horizontal
              ? horizontalWheel(context)
              : SizedBox(
                  height: row * (widget.birthYear ? 7 : 5),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: widget.birthYear ? 0 : PantasSpace.s12,
                        right: widget.birthYear ? 0 : PantasSpace.s12,
                        child: Container(
                          key: const ValueKey('wheel-selection'),
                          height: row,
                          decoration: BoxDecoration(
                            color:
                                widget.birthYear ? colors.fill : colors.bgPage,
                            borderRadius: BorderRadius.circular(
                              widget.birthYear
                                  ? PantasRadius.md
                                  : PantasRadius.sm,
                            ),
                          ),
                        ),
                      ),
                      ListWheelScrollView.useDelegate(
                        controller: _scroll,
                        itemExtent: row,
                        diameterRatio: widget.birthYear ? 1000 : 2.4,
                        perspective: .002,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) {
                          if (!_jumping && !widget.invalidIndices.contains(i)) {
                            widget.onSelected(i);
                          }
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: widget.values.length,
                          builder: (context, i) => Center(
                            child: LayoutBuilder(
                              builder: (context, box) {
                                final compact = widget.shortValues != null &&
                                    box.maxWidth < _compactBelow(scaler);
                                final selected = i == widget.selectedIndex;
                                final base = widget.birthYear
                                    ? (selected
                                        ? PantasType.phoneTitle2.copyWith(
                                            fontWeight: FontWeight.w600,
                                          )
                                        : PantasType.webSearchInput)
                                    : PantasType.phoneWheel.copyWith(
                                        fontWeight: selected
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                      );
                                return Text(
                                  compact
                                      ? widget.shortValues![i]
                                      : widget.values[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: base.copyWith(
                                    fontFeatures: widget.birthYear
                                        ? const [FontFeature.tabularFigures()]
                                        : null,
                                    color: selected ||
                                            (widget.birthYear &&
                                                (i - widget.selectedIndex)
                                                        .abs() ==
                                                    1)
                                        ? colors.textPrimary
                                        : colors.textSecondary,
                                    decoration:
                                        widget.invalidIndices.contains(i)
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                                );
                              },
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

  /// The column width under which the short values show: the group's
  /// `layout-wheel-full` (21rem at the scaled text), times this column's share.
  double _compactBelow(TextScaler scaler) =>
      PantasLayout.wheelFull *
      scaler.scale(PantasSpace.s16) /
      PantasSpace.s16 *
      widget.groupShare;

  Widget horizontalWheel(BuildContext context) {
    final colors = context.colors;
    final scale = MediaQuery.textScalerOf(context)
            .scale(PantasType.webSearchInput.fontSize!) /
        PantasType.webSearchInput.fontSize!;
    final widthChanged = _cellWidth != _cellBase * scale;
    _cellWidth = _cellBase * scale;
    if (widthChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _horizontalScroll.hasClients) {
          jumpHorizontal(widget.selectedIndex * _cellWidth);
        }
      });
    }
    final height = PantasSize.field * scale;
    return LayoutBuilder(
      builder: (context, constraints) {
        final sidePad = (constraints.maxWidth - _cellWidth) / 2;
        return SizedBox(
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: _cellWidth,
                height: PantasSpace.s40 * scale,
                decoration: BoxDecoration(
                  color: colors.accentTint,
                  borderRadius: BorderRadius.circular(PantasRadius.md),
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
                  valid.sort(
                    (a, b) => (a - raw).abs().compareTo((b - raw).abs()),
                  );
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
                      Colors.transparent,
                      colors.textPrimary,
                      colors.textPrimary,
                      Colors.transparent,
                    ],
                    stops: const [0, .22, .78, 1],
                  ).createShader(bounds),
                  child: ListView.builder(
                    controller: _horizontalScroll,
                    scrollDirection: Axis.horizontal,
                    itemExtent: _cellWidth,
                    padding: EdgeInsets.symmetric(horizontal: sidePad),
                    itemCount: widget.values.length,
                    itemBuilder: (context, i) => Opacity(
                      opacity: widget.invalidIndices.contains(i)
                          ? PantasOpacity.disabled
                          : 1,
                      child: Center(
                        key: ValueKey('wheel-cell-$i'),
                        child: Text(
                          widget.values[i],
                          style: (i == widget.selectedIndex
                                  ? PantasType.webSearchInput
                                  : PantasType.webBody)
                              .copyWith(
                            fontWeight: i == widget.selectedIndex
                                ? FontWeight.w700
                                : FontWeight.w500,
                            height: PantasType.webBody.height,
                            color: i == widget.selectedIndex
                                ? colors.textPrimary
                                : colors.textSecondary,
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
        );
      },
    );
  }
}
