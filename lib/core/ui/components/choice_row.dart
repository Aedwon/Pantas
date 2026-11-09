import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

enum ChoiceRowState { plain, picked, right, wrong, dimmed }

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
    if (context.wideWeb) {
      final optionState = switch (state) {
        ChoiceRowState.plain => WebOptionState.normal,
        ChoiceRowState.picked => WebOptionState.selected,
        ChoiceRowState.right => WebOptionState.right,
        ChoiceRowState.wrong => WebOptionState.wrong,
        ChoiceRowState.dimmed => WebOptionState.dimmed,
      };
      return WebAnswerOption(
        letter: letter,
        onPressed: onTap,
        state: optionState,
        child: MathText(
          text,
          style: WebAnswerOption.textStyle(context, optionState),
        ),
      );
    }
    final c = context.colors;
    final right = state == ChoiceRowState.right;
    final wrong = state == ChoiceRowState.wrong;
    final dimmed = state == ChoiceRowState.dimmed;
    final filled = right || wrong || state == ChoiceRowState.picked;
    final circle = wrong ? c.dangerFill : c.accentFill;
    final background = right
        ? c.accentTint
        : wrong
            ? c.dangerTint
            : c.surfaceCard;
    // The badge grows with the letter: at least 2em of the 15 px letter.
    final size = math.max(
      PantasSize.optBadgePhone,
      MediaQuery.textScalerOf(context).scale(PantasType.webLink.fontSize!) * 2,
    );
    final action =
        state == ChoiceRowState.plain || state == ChoiceRowState.picked
            ? onTap
            : null;
    final foreground =
        filled ? (wrong ? c.onDanger : c.onAccent) : c.textSecondary;
    final result = right
        ? ', correct answer'
        : wrong
            ? ', your answer, wrong'
            : state == ChoiceRowState.picked
                ? ', selected'
                : '';
    final spoken = inlineMathSemantics(text)?.label ?? text;
    // The result shows as the mark in the badge and as words, never as color
    // alone. The badge holds the check, so no mark sits at the right end.
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
                color: dimmed ? c.divider : c.borderControl,
                width: PantasBorder.ringStrong,
              ),
      ),
      alignment: Alignment.center,
      child: right || wrong
          ? Icon(
              right ? PantasIcons.check : PantasIcons.close,
              size: PantasSize.icon,
              color: foreground,
            )
          : Text(
              letter,
              style: PantasType.webLink.copyWith(
                // ds-board: README type: web-glyph leading 1
                height: 1,
                color: foreground,
              ),
            ),
    );
    return Semantics(
      label: '$letter, $spoken$result',
      selected: state == ChoiceRowState.picked,
      inMutuallyExclusiveGroup: true,
      checked: state == ChoiceRowState.picked || wrong,
      button: action != null,
      onTap: action,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: action,
            borderRadius: BorderRadius.circular(PantasRadius.lg),
            child: AnimatedContainer(
              key: const ValueKey('choice-surface'),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : PantasDurations.short3,
              curve: PantasCurves.fade,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(PantasRadius.lg),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PantasRadius.lg),
                border: Border.all(
                  color: filled
                      ? (wrong ? c.danger : c.accent)
                      : Colors.transparent,
                  width: PantasBorder.ringSelected,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: PantasSpace.s14,
                vertical: PantasSpace.s14,
              ),
              child: Row(
                children: [
                  mark,
                  const SizedBox(width: PantasSpace.s12),
                  Expanded(
                    child: MathText(
                      text,
                      style: PantasType.phoneOption.copyWith(
                        fontWeight: right ? FontWeight.w600 : FontWeight.w400,
                        color: dimmed ? c.textSecondary : c.textPrimary,
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
