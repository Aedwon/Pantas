import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

String proctorCopyFor(int minutes) {
  final unit = minutes == 1 ? 'minute' : 'minutes';
  return '$minutes $unit left in this subject.';
}

const proctorToastDisplayDuration = Duration(seconds: 8);

class ProctorToast extends StatefulWidget {
  const ProctorToast({
    required this.minutes,
    super.key,
  });

  final int minutes;

  @override
  State<ProctorToast> createState() => _ProctorToastState();
}

class _ProctorToastState extends State<ProctorToast> {
  @override
  void initState() {
    super.initState();
    _proctorHaptic();
  }

  Future<void> _proctorHaptic() async {
    for (var i = 0; i < 3; i++) {
      await HapticFeedback.mediumImpact();
      if (i < 2) await Future<void>.delayed(const Duration(milliseconds: 60));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Red is for wrong answers; low time is `warning-text` (Timer README).
    final color = widget.minutes == 1 || widget.minutes == 5
        ? colors.warningText
        : colors.textPrimary;

    final copy = proctorCopyFor(widget.minutes);
    return Semantics(
      container: true,
      role: SemanticsRole.status,
      label: copy,
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(PantasRadius.r2xl),
          border: Border.all(
            color: colors.edgeCard,
            width: PantasBorder.hairline,
          ),
          boxShadow: context.shadows.popover,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: PantasSpace.s16,
          vertical: PantasSpace.s10,
        ),
        child: Text(
          copy,
          textAlign: TextAlign.center,
          style: PantasType.webLabel.copyWith(color: color),
        ),
      ),
    );
  }
}
