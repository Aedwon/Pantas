import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

/// The Switch of the design system: a 51 by 31 track, a 27 thumb inset 2 and
/// a 44 high hit area.
///
/// Off is the `switch-off` fill with a 1.5 `border-control` ring. On is
/// `accent-fill` with no ring. Hover darkens the track, press shrinks the
/// thumb to 96 percent, keyboard focus draws a 2 `accent` ring at offset 2 and
/// a null [onChanged] disables it (`opacity-disabled`).
class PantasSwitch extends StatefulWidget {
  const PantasSwitch({
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;

  @override
  State<PantasSwitch> createState() => _PantasSwitchState();
}

class _PantasSwitchState extends State<PantasSwitch> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  // A press elsewhere takes the ring away without moving focus, and a key
  // press brings it back, so the ring also follows the last input.
  void _inputChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    webKeyboardInput.addListener(_inputChanged);
  }

  @override
  void dispose() {
    webKeyboardInput.removeListener(_inputChanged);
    super.dispose();
  }

  static const double _inset = PantasSpace.s2;
  static const double _travel =
      PantasSize.switchW - PantasSize.switchThumb - _inset * 2;
  static const double _pressedThumb = 0.96;
  static const double _ringOutset = PantasBorder.focus + PantasSpace.s2;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final value = widget.value;
    final enabled = widget.onChanged != null;
    final still = MediaQuery.disableAnimationsOf(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hovered = enabled && _hovered;
    final track = value
        ? (hovered ? c.accentFillHover : c.accentFill)
        : (hovered ? c.dividerStrong : c.switchOff);
    final knobShadow = (dark ? PantasShadow.dark : PantasShadow.light).knob;
    final ring = webFocusRing(
      {if (_focused) WidgetState.focused},
      c.accent,
    );
    return Semantics(
      label: widget.label,
      toggled: value,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : PantasOpacity.disabled,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled ? () => widget.onChanged!(!value) : null,
            onHover: (hover) => setState(() => _hovered = hover),
            onFocusChange: (focus) => setState(() => _focused = focus),
            onHighlightChanged: (down) => setState(() => _pressed = down),
            borderRadius: BorderRadius.circular(PantasRadius.full),
            splashFactory: NoSplash.splashFactory,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            child: SizedBox(
              width: PantasSize.switchW,
              height: PantasSize.targetTouch,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween:
                      Tween<double>(begin: value ? 1 : 0, end: value ? 1 : 0),
                  duration:
                      still ? Duration.zero : PantasDurations.switchDuration,
                  curve: PantasCurves.spring,
                  builder: (context, position, child) =>
                      TweenAnimationBuilder<Color?>(
                    tween: ColorTween(begin: track, end: track),
                    // Reduced motion keeps the final thumb position and fades
                    // the track over 150ms.
                    duration:
                        still ? PantasDurations.short2 : PantasDurations.fade,
                    curve: PantasCurves.fade,
                    builder: (context, trackColor, child) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        DecoratedBox(
                          key: const ValueKey('pantas-switch-track'),
                          decoration: BoxDecoration(
                            color: trackColor,
                            borderRadius:
                                BorderRadius.circular(PantasRadius.full),
                            border: value
                                ? null
                                : Border.all(
                                    color: c.borderControl,
                                    width: PantasBorder.ringStrong,
                                  ),
                          ),
                          child: SizedBox(
                            width: PantasSize.switchW,
                            height: PantasSize.switchH,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: _inset,
                                  left: _inset + position * _travel,
                                  child: Transform.scale(
                                    scale:
                                        enabled && _pressed ? _pressedThumb : 1,
                                    child: DecoratedBox(
                                      key: const ValueKey('pantas-switch-knob'),
                                      decoration: BoxDecoration(
                                        color: c.switchThumb,
                                        shape: BoxShape.circle,
                                        boxShadow: knobShadow,
                                      ),
                                      child: const SizedBox.square(
                                        dimension: PantasSize.switchThumb,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (ring != null)
                          Positioned(
                            left: -_ringOutset,
                            top: -_ringOutset,
                            right: -_ringOutset,
                            bottom: -_ringOutset,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                key: const ValueKey('pantas-switch-focus'),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    PantasRadius.full,
                                  ),
                                  border: Border.fromBorderSide(ring),
                                ),
                              ),
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
    );
  }
}
