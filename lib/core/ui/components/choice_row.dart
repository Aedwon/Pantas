import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum ChoiceRowState { plain, picked, right, wrong, dimmed }

const choiceEmptyOutline = Color(0xFFD1D1D6);

class ChoiceRow extends StatelessWidget {
  const ChoiceRow(
      {required this.letter,
      required this.text,
      this.state = ChoiceRowState.plain,
      this.onTap,
      super.key});
  final String letter;
  final String text;
  final ChoiceRowState state;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final right = state == ChoiceRowState.right;
    final wrong = state == ChoiceRowState.wrong;
    final filled = right || wrong || state == ChoiceRowState.picked;
    final circle = wrong ? c.destructive : c.accentFill;
    final background = right
        ? c.accentTint
        : wrong
            ? c.wrongTint
            : c.surface;
    final size = (MediaQuery.textScalerOf(context).scale(15) * 1.35 + 4)
        .clamp(30.0, double.infinity);
    final action =
        state == ChoiceRowState.plain || state == ChoiceRowState.picked
            ? onTap
            : null;
    final foreground = filled
        ? (wrong || Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : c.surface)
        : c.secondaryLabel;
    final result = right
        ? 'correct'
        : wrong
            ? 'wrong'
            : state == ChoiceRowState.picked
                ? 'selected'
                : null;
    final spoken = inlineMathSemantics(text)?.label ?? text;
    final mark = Container(
      key: const ValueKey('choice-mark'),
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? circle : null,
          border: filled
              ? null
              : Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? choiceEmptyOutline
                      : c.chevron,
                  width: 1.5)),
      alignment: Alignment.center,
      child: right || wrong
          ? Icon(right ? PantasIcons.check : PantasIcons.close,
              size: 14, color: foreground)
          : Text(letter,
              style: context.type.subheadStrong.copyWith(color: foreground)),
    );
    return Semantics(
      label: '$letter${result == null ? '' : ', $result'}, $spoken',
      selected: state == ChoiceRowState.picked,
      button: action != null,
      onTap: action,
      child: ExcludeSemantics(
          child: Opacity(
        key: const ValueKey('choice-opacity'),
        opacity: state == ChoiceRowState.dimmed ? .45 : 1,
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: action,
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                key: const ValueKey('choice-surface'),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                curve: PantasCurves.ease,
                decoration: BoxDecoration(
                    color: background, borderRadius: BorderRadius.circular(14)),
                foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: filled
                            ? (wrong ? c.destructive : c.accent)
                            : Colors.transparent,
                        width: 1.5)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(children: [
                  mark,
                  const SizedBox(width: 12),
                  Expanded(
                      child: MathText(text,
                          style: context.type.body.copyWith(
                              fontWeight: right || wrong
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: wrong ? c.wrongText : c.label)))
                ]),
              ),
            )),
      )),
    );
  }
}
