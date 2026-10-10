import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class SegmentedSwitch extends StatelessWidget {
  const SegmentedSwitch({
    required this.labels,
    required this.selected,
    required this.onChanged,
    super.key,
  })  : assert(
          labels.length > 1,
          'A segmented switch needs two or more labels.',
        ),
        assert(
          selected >= 0 && selected < labels.length,
          'Selected segment must exist.',
        );

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
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
                                    : const [
                                        BoxShadow(
                                          color: Color(0x1A000000),
                                          blurRadius: 3,
                                          offset: Offset(0, 1),
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
                                            : FontWeight.w500,
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
}
