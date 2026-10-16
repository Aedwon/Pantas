import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
    final color = widget.minutes == 1
        ? colors.wrongText
        : widget.minutes == 5
            ? colors.warningText
            : colors.label;

    final copy = proctorCopyFor(widget.minutes);
    return Semantics(
      container: true,
      role: SemanticsRole.status,
      label: copy,
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.shadow.withValues(alpha: .05)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: .12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          copy,
          textAlign: TextAlign.center,
          style: context.type.subheadStrong.copyWith(
            fontSize: 14,
            color: color,
          ),
        ),
      ),
    );
  }
}
