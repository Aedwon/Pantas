import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class IosSettingsSwitch extends StatelessWidget {
  const IosSettingsSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = value ? colors.board : colors.rule;
    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
