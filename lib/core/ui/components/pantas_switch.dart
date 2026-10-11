import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class PantasSwitch extends StatelessWidget {
  const PantasSwitch({
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final motion = !MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: label,
      toggled: value,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            width: 51,
            height: 44,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: value ? 1 : 0, end: value ? 1 : 0),
                duration:
                    motion ? const Duration(milliseconds: 350) : Duration.zero,
                curve: PantasCurves.popC,
                builder: (context, position, child) =>
                    TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    begin: value
                        ? context.colors.accentFill
                        : context.colors.separator,
                    end: value
                        ? context.colors.accentFill
                        : context.colors.separator,
                  ),
                  duration: motion
                      ? const Duration(milliseconds: 250)
                      : Duration.zero,
                  curve: PantasCurves.ease,
                  builder: (context, trackColor, child) => DecoratedBox(
                    key: const ValueKey('pantas-switch-track'),
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: SizedBox(
                      width: 51,
                      height: 31,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 2,
                            left: 2 + position * 20,
                            child: DecoratedBox(
                              key: const ValueKey('pantas-switch-knob'),
                              decoration: BoxDecoration(
                                color: context.colors.switchThumb,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colors.switchThumbShadow,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const SizedBox.square(dimension: 27),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
