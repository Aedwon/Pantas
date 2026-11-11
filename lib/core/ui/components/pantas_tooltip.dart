import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

/// Esc dismisses an open tooltip wherever focus is and whatever shows it, a
/// pointer included (WCAG 1.4.13, dismissible). It is a keyboard handler, not
/// a shortcut under the anchor, because a tooltip held open by the pointer
/// alone has no focus to carry the key. The key is consumed only when a
/// tooltip was open, so Esc still closes a dialog when none is.
abstract final class _TooltipEscape {
  static int _users = 0;

  static void retain() {
    if (_users++ == 0) HardwareKeyboard.instance.addHandler(_handle);
  }

  static void release() {
    if (--_users == 0) HardwareKeyboard.instance.removeHandler(_handle);
  }

  static bool _handle(KeyEvent event) =>
      event is KeyDownEvent &&
      event.logicalKey == LogicalKeyboardKey.escape &&
      Tooltip.dismissAllToolTips();
}

/// The look of a Tooltip: `toast-bg` with `toast-text`, `elev-toast`,
/// `web-caption`, padding 4 by 8, radius `radius-sm`, at most
/// `size-tooltip-max` wide. The WeekStrip draws its own positioned tooltip
/// with it.
class PantasTooltipBubble extends StatelessWidget {
  const PantasTooltipBubble({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: PantasSize.tooltipMax),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.toastBg,
          borderRadius: BorderRadius.circular(PantasRadius.sm),
          boxShadow: context.shadows.toast,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PantasSpace.s8,
            vertical: PantasSpace.s4,
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: PantasType.webCaption.copyWith(color: colors.toastText),
          ),
        ),
      ),
    );
  }
}

/// A short label that names an icon-only control or shows a cut title in
/// full, with its keyboard shortcut (design system: Tooltip).
///
/// Text is the control's name plus the shortcut in brackets: "Flag (F)",
/// "Close (Esc)". The surface is `toast-bg` with `toast-text`, `web-caption`,
/// padding 4 by 8, radius `radius-sm`, at most `size-tooltip-max` wide, 8
/// from the anchor, above it unless there is no room.
///
/// A pointer shows it after `PantasDurations.tooltip` (500ms). Keyboard
/// focus shows it at once. Esc hides it without moving focus, and leaving
/// the control hides it. The pointer may move from the anchor onto the
/// tooltip, across an invisible 8 point bridge, and the tooltip stays while
/// the pointer is on either (WCAG 1.4.13, hoverable and persistent). Esc
/// hides it wherever the pointer or focus is. It fades in over
/// `PantasDurations.short2`, also under reduced motion. Touch never shows
/// it: the control keeps its own label (and its semantic label), so a long
/// press does nothing.
///
/// The anchor keeps its own accessible name. The tooltip adds the same text
/// as the semantic tooltip of the anchor, so a screen reader reads it as a
/// supplement. Set [describesAnchor] to false when the anchor's name already
/// contains the text (the WeekStrip days): the tooltip is then hidden from
/// semantics.
class PantasTooltip extends StatefulWidget {
  const PantasTooltip({
    required this.message,
    required this.child,
    this.shortcut,
    this.anchorHeight = PantasSize.targetTouch,
    this.preferBelow = false,
    this.describesAnchor = true,
    super.key,
  });

  /// The control's name: "Flag", "Close".
  final String message;

  /// The shortcut shown in brackets after [message]: "F", "Esc".
  final String? shortcut;

  /// The control the tooltip names.
  final Widget child;

  /// How tall the anchor is. The gap to the anchor is measured from its
  /// center, so a taller anchor needs a larger offset to keep the 8 point gap.
  final double anchorHeight;

  /// True when there is no room above the anchor.
  final bool preferBelow;

  /// False when the anchor's accessible name already holds the text.
  final bool describesAnchor;

  /// The label as shown: the name and its shortcut in brackets. A letter
  /// shortcut drops out while Keyboard Shortcuts is off.
  String textFor({required bool lettersOn}) {
    final key = shortcut;
    if (key == null || (!lettersOn && isCharacterKeyHint(key))) return message;
    return '$message ($key)';
  }

  @override
  State<PantasTooltip> createState() => _PantasTooltipState();
}

class _PantasTooltipState extends State<PantasTooltip> {
  final GlobalKey<TooltipState> _tooltip = GlobalKey<TooltipState>();

  /// True while the keyboard (not the pointer) is what shows the tooltip.
  bool _shownByFocus = false;

  static bool _isTouch(TargetPlatform platform) =>
      platform == TargetPlatform.android ||
      platform == TargetPlatform.iOS ||
      platform == TargetPlatform.fuchsia;

  @override
  void initState() {
    super.initState();
    // Start listening for keys now, so the Tab that lands on the anchor is
    // already seen when focus arrives.
    webKeyboardInput;
    _TooltipEscape.retain();
  }

  @override
  void dispose() {
    _TooltipEscape.release();
    super.dispose();
  }

  void _focusChanged(bool focused) {
    if (focused) {
      if (webKeyboardFocus({WidgetState.focused})) {
        _shownByFocus = true;
        _tooltip.currentState?.ensureTooltipVisible();
      }
    } else if (_shownByFocus) {
      _shownByFocus = false;
      Tooltip.dismissAllToolTips();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _focusChanged,
      child: Tooltip(
        key: _tooltip,
        message: widget.textFor(
          lettersOn: LetterShortcutsScope.enabledOf(context),
        ),
        excludeFromSemantics: !widget.describesAnchor,
        waitDuration: PantasDurations.tooltip,
        // On touch the tooltip never shows by itself.
        triggerMode: _isTouch(Theme.of(context).platform)
            ? TooltipTriggerMode.manual
            : null,
        enableFeedback: false,
        preferBelow: widget.preferBelow,
        // The 8 point gap is the tooltip's own margin: the bridge the
        // pointer crosses from the anchor onto the tooltip.
        verticalOffset: widget.anchorHeight / 2,
        margin: widget.preferBelow
            ? const EdgeInsets.only(top: PantasSpace.s8)
            : const EdgeInsets.only(bottom: PantasSpace.s8),
        ignorePointer: false,
        padding: const EdgeInsets.symmetric(
          horizontal: PantasSpace.s8,
          vertical: PantasSpace.s4,
        ),
        constraints: const BoxConstraints(maxWidth: PantasSize.tooltipMax),
        textAlign: TextAlign.center,
        textStyle: PantasType.webCaption.copyWith(color: colors.toastText),
        decoration: BoxDecoration(
          color: colors.toastBg,
          borderRadius: BorderRadius.circular(PantasRadius.sm),
          boxShadow: context.shadows.toast,
        ),
        child: widget.child,
      ),
    );
  }
}
