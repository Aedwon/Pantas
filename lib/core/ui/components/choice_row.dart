import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum ChoiceRowState { plain, picked, right, wrong, dimmed }

const choiceEmptyOutline = Color(0xFFD1D1D6);

class ChoiceRow extends StatelessWidget {
  const ChoiceRow({
    required this.letter,
    required this.text,
    this.state = ChoiceRowState.plain,
    this.onTap,
    super.key,
  });
  final String letter;
  final String text;
  final ChoiceRowState state;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final filled = state == ChoiceRowState.picked ||
        state == ChoiceRowState.right ||
        state == ChoiceRowState.wrong;
    final right = state == ChoiceRowState.right;
    final wrong = state == ChoiceRowState.wrong;
    final circle = wrong ? c.destructive : c.accentFill;
    final bg = right
        ? c.accentTint
        : wrong
            ? c.wrongTint
            : c.surface;
    final size = (MediaQuery.textScalerOf(context).scale(15) * 1.35 + 4)
        .clamp(30.0, double.infinity);
    final enabled =
        state == ChoiceRowState.plain || state == ChoiceRowState.picked;
    return Opacity(
      key: const ValueKey('choice-opacity'),
      opacity: state == ChoiceRowState.dimmed ? .45 : 1,
      child: Semantics(
        selected: state == ChoiceRowState.picked,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              key: const ValueKey('choice-surface'),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              curve: PantasCurves.ease,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: filled
                      ? (wrong ? c.destructive : c.accent)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              child: Row(
                children: [
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? circle : null,
                      border: filled
                          ? null
                          : Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? choiceEmptyOutline
                                  : c.chevron,
                              width: 1.5,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: context.type.subheadStrong.copyWith(
                        color: filled
                            ? (wrong ||
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                ? Colors.white
                                : c.surface)
                            : c.secondaryLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MathText(
                      text,
                      style: context.type.body.copyWith(
                        fontWeight:
                            right || wrong ? FontWeight.w600 : FontWeight.w400,
                        color: wrong ? c.wrongText : c.label,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
