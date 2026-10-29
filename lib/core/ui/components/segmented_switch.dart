import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

class SegmentedSwitch extends StatelessWidget {
  const SegmentedSwitch({
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.unselectedFontWeight = FontWeight.w500,
    super.key,
  })  : bookmarks = false,
        enabled = true,
        assert(
          labels.length > 1,
          'A segmented switch needs two or more labels.',
        ),
        assert(
          selected >= 0 && selected < labels.length,
          'Selected segment must exist.',
        );

  const SegmentedSwitch.bookmarks({
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    super.key,
  })  : bookmarks = true,
        unselectedFontWeight = FontWeight.w500;
  final bool bookmarks;
  final bool enabled;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final FontWeight unselectedFontWeight;

  @override
  Widget build(BuildContext context) {
    if (bookmarks) return _bookmarks(context);
    if (context.wideWeb) {
      return WebSegmentedControl(
        labels: labels,
        selected: selected,
        onChanged: onChanged,
      );
    }
    final colors = context.colors;
    final large = MediaQuery.textScalerOf(context).scale(14) > 20;
    return Stack(
      children: [
        Positioned.fill(
          top: 6,
          bottom: 6,
          child: DecoratedBox(
            key: const ValueKey('segmented-switch-track'),
            decoration: BoxDecoration(
              color: colors.fill,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2),
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == selected,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => onChanged(i),
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 44),
                          child: Center(
                            heightFactor: 1,
                            child: DecoratedBox(
                              key: ValueKey('segment-$i'),
                              decoration: BoxDecoration(
                                color: i != selected
                                    ? null
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? colors.chevron
                                        : colors.surface,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: i != selected
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: context.colors.segmentedShadow,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                              ),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minHeight: 32),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: large ? 6 : 0,
                                  ),
                                  child: Center(
                                    heightFactor: 1,
                                    child: Text(
                                      labels[i],
                                      textAlign: TextAlign.center,
                                      style: context.type.subhead.copyWith(
                                        fontSize: 14,
                                        fontWeight: i == selected
                                            ? FontWeight.w600
                                            : unselectedFontWeight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
      ],
    );
  }

  Widget _bookmarks(BuildContext context) {
    final c = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    return AnimatedOpacity(
      duration: still ? Duration.zero : const Duration(milliseconds: 250),
      curve: PantasCurves.houseOut,
      opacity: enabled ? 1 : .4,
      child: ExcludeFocus(
        excluding: !enabled,
        child: IgnorePointer(
          ignoring: !enabled,
          child: Semantics(
            enabled: enabled,
            child: Stack(
              children: [
                Positioned.fill(
                  top: 6,
                  bottom: 6,
                  child: DecoratedBox(
                    key: const ValueKey('segmented-switch-track'),
                    decoration: BoxDecoration(
                      color: c.fill,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned.fill(
                  left: 2,
                  right: 2,
                  top: 8,
                  bottom: 8,
                  child: AnimatedAlign(
                    key: const ValueKey('bookmark-sort-position'),
                    alignment: Alignment(
                      -1 + 2 * selected / (labels.length - 1),
                      0,
                    ),
                    duration: still
                        ? Duration.zero
                        : const Duration(milliseconds: 300),
                    curve: PantasCurves.houseOut,
                    child: FractionallySizedBox(
                      widthFactor: 1 / labels.length,
                      heightFactor: 1,
                      child: DecoratedBox(
                        key: const ValueKey('bookmark-sort-pill'),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: c.segmentedShadow,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      for (var i = 0; i < labels.length; i++)
                        Expanded(
                          child: Semantics(
                            selected: i == selected,
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: enabled ? () => onChanged(i) : null,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 44,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 6,
                                    ),
                                    child: Center(
                                      heightFactor: 1,
                                      child: Text(
                                        labels[i],
                                        textAlign: TextAlign.center,
                                        style: context.type.footnote.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: c.label,
                                        ),
                                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
