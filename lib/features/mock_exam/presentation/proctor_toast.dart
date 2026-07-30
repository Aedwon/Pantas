import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

String proctorCopyFor(int minutes) {
  final unit = minutes == 1 ? 'minute' : 'minutes';
  return '$minutes $unit left in this subject.';
}

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
    final textStyles = context.textStyles;
    final isAmber = widget.minutes == 1;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.rule),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        proctorCopyFor(widget.minutes),
        textAlign: TextAlign.center,
        style: textStyles.labelLarge.copyWith(
          color: isAmber ? colors.amber : colors.ink,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
