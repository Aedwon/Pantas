import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// A one-block paper (CSE) has no subjects with a time of their own, so its
/// line drops "in this subject" (D191).
String proctorCopyFor(int minutes, {bool oneBlock = false}) {
  final unit = minutes == 1 ? 'minute' : 'minutes';
  return oneBlock
      ? '$minutes $unit left.'
      : '$minutes $unit left in this subject.';
}

/// Board MK_Proctor: the call stays above the bar for 2.5 seconds.
const proctorToastDisplayDuration = Duration(milliseconds: 2500);

class ProctorToast extends StatefulWidget {
  const ProctorToast({
    required this.minutes,
    this.oneBlock = false,
    super.key,
  });

  final int minutes;

  /// The paper is one block (CSE), so the line does not name a subject.
  final bool oneBlock;

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

    final copy = proctorCopyFor(widget.minutes, oneBlock: widget.oneBlock);
    return Semantics(
      container: true,
      role: SemanticsRole.status,
      label: copy,
      excludeSemantics: true,
      child: MockToastSurface(
        child: Text(
          copy,
          textAlign: TextAlign.center,
          style: PantasType.webLabel.copyWith(color: color),
        ),
      ),
    );
  }
}

/// The mock's floating surface (board MK_Proctor): a card pill with a hairline
/// edge and the popover shadow. The proctor call and a failed save sit on it.
class MockToastSurface extends StatelessWidget {
  const MockToastSurface({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(PantasRadius.r2xl),
        border: Border.all(
          color: colors.edgeCard,
          width: PantasBorder.hairline,
        ),
        boxShadow: context.shadows.popover,
      ),
      // Board MK_Proctor: a 44 px pill, the content centered.
      constraints: const BoxConstraints(minHeight: PantasSize.targetTouch),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: PantasSpace.s16,
        vertical: PantasSpace.s10,
      ),
      child: child,
    );
  }
}
