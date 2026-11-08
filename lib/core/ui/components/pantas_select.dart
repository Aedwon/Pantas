import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// Phosphor caret-down.
const IconData _caretDown = IconData(0xe136, fontFamily: 'Phosphor');

/// Lets the learner pick one value from a list of six or more options
/// (design system Select): a label above, a button with the value and a
/// chevron, and a popover listbox 6 px under it, the same width.
///
/// The button is at least 48 high (56 for [large], the onboarding box),
/// `surface-card` with a 1 px `border-control` ring; hover draws the ring in
/// `text-secondary`, open a 2 px `accent` ring and turns the chevron over,
/// invalid a 2 px `danger` ring. The list rises 8 px and fades in over
/// `dur-medium-1`; reduced motion shows it at once. The selected item has
/// `accent-tint`, weight 600 and a check, so it is not shown by color alone.
///
/// Keyboard: Enter, Space and Arrow Down or Up open the list; in it the
/// arrows, Home and End move the active item, Enter or Space picks it, Esc
/// closes and returns focus to the button, and typing the first letters jumps
/// to a match. The consumer provides the label, the options, the value and
/// the placeholder. Search inside the list is not part of this widget.
class PantasSelect<T> extends StatefulWidget {
  const PantasSelect({
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.placeholder,
    this.errorText,
    this.helpText,
    this.optional = false,
    this.enabled = true,
    this.large = false,
    super.key,
  });

  final String label;

  /// The options: the value and the text shown for it.
  final List<PantasSelectOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? placeholder;
  final String? errorText;
  final String? helpText;
  final bool optional;
  final bool enabled;

  /// `select--lg`: 56 high, radius 14, 16 left padding.
  final bool large;

  @override
  State<PantasSelect<T>> createState() => _PantasSelectState<T>();
}

/// One option of a [PantasSelect].
@immutable
class PantasSelectOption<T> {
  const PantasSelectOption(this.value, this.label);
  final T value;
  final String label;
}

class _PantasSelectState<T> extends State<PantasSelect<T>>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final FocusNode _focus = FocusNode();
  late final AnimationController _open;
  bool _hovered = false;
  bool _focused = false;
  bool _isOpen = false;
  int _active = 0;
  String _typed = '';
  DateTime _typedAt = DateTime.fromMillisecondsSinceEpoch(0);
  double _width = 0;

  int get _selectedIndex =>
      widget.options.indexWhere((o) => o.value == widget.value);

  @override
  void initState() {
    super.initState();
    _open = AnimationController(
      vsync: this,
      duration: PantasDurations.medium1,
    );
    _focus.addListener(() {
      if (mounted && _focused != _focus.hasFocus) {
        setState(() => _focused = _focus.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _open.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _still => MediaQuery.disableAnimationsOf(context);

  void _show() {
    if (_isOpen || !widget.enabled || widget.options.isEmpty) return;
    _active = _selectedIndex < 0 ? 0 : _selectedIndex;
    setState(() => _isOpen = true);
    _portal.show();
    if (_still) {
      _open.value = 1;
    } else {
      _open.forward(from: 0);
    }
  }

  void _hide() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    if (_still) {
      _open.value = 0;
      _portal.hide();
    } else {
      _open.reverse().whenComplete(() {
        if (mounted && !_isOpen) _portal.hide();
      });
    }
  }

  void _pick(int index) {
    widget.onChanged(widget.options[index].value);
    _hide();
    _focus.requestFocus();
  }

  void _move(int to) => setState(
        () => _active = to.clamp(0, widget.options.length - 1),
      );

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || !widget.enabled) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (!_isOpen) {
      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.arrowDown ||
          key == LogicalKeyboardKey.arrowUp) {
        _show();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.escape) {
      _hide();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(_active + 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _move(_active - 1);
    } else if (key == LogicalKeyboardKey.home) {
      _move(0);
    } else if (key == LogicalKeyboardKey.end) {
      _move(widget.options.length - 1);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _pick(_active);
    } else if (key == LogicalKeyboardKey.tab) {
      _hide();
      return KeyEventResult.ignored;
    } else if (event.character != null && event.character!.trim().isNotEmpty) {
      // Typeahead: the first letters jump to a match.
      final now = DateTime.now();
      _typed = now.difference(_typedAt) > const Duration(seconds: 1)
          ? event.character!
          : _typed + event.character!;
      _typedAt = now;
      final at = widget.options.indexWhere(
        (o) => o.label.toLowerCase().startsWith(_typed.toLowerCase()),
      );
      if (at >= 0) _move(at);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final invalid = widget.errorText != null;
    final disabled = !widget.enabled;
    final radius = BorderRadius.circular(
      widget.large ? PantasRadius.lg : PantasRadius.md,
    );
    final selected = _selectedIndex;
    final placeholder = selected < 0;
    final text =
        placeholder ? widget.placeholder ?? '' : widget.options[selected].label;

    final Color well;
    Color? ring;
    var ringWidth = PantasBorder.ring;
    if (disabled) {
      well = colors.fill;
    } else {
      well = colors.surfaceCard;
      if (invalid) {
        ring = colors.danger;
        ringWidth = PantasBorder.ringSelected;
      } else if (_isOpen) {
        ring = colors.accent;
        ringWidth = PantasBorder.ringSelected;
      } else if (_hovered) {
        ring = colors.textSecondary;
      } else {
        ring = colors.borderControl;
      }
    }
    final valueStyle = PantasType.webRowTitleSettings.copyWith(
      color: disabled
          ? colors.textDisabled
          : placeholder
              ? colors.textSecondary
              : colors.textPrimary,
    );

    final button = CompositedTransformTarget(
      link: _link,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _width = constraints.maxWidth;
          return MouseRegion(
            onEnter: disabled ? null : (_) => setState(() => _hovered = true),
            onExit: disabled ? null : (_) => setState(() => _hovered = false),
            cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
            child: OffsetFocusRing(
              borderRadius: radius,
              child: Focus(
                focusNode: _focus,
                canRequestFocus: !disabled,
                onKeyEvent: _onKey,
                child: Semantics(
                  button: true,
                  enabled: !disabled,
                  expanded: _isOpen,
                  label: widget.label,
                  value: text,
                  excludeSemantics: true,
                  onTap: disabled ? null : (_isOpen ? _hide : _show),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: disabled
                        ? null
                        : () {
                            _focus.requestFocus();
                            if (_isOpen) {
                              _hide();
                            } else {
                              _show();
                            }
                          },
                    child: Container(
                      key: const ValueKey('select-button'),
                      constraints: BoxConstraints(
                        minHeight:
                            widget.large ? PantasSize.select : PantasSize.field,
                      ),
                      padding: EdgeInsets.fromLTRB(
                        widget.large ? PantasSpace.s16 : PantasSpace.s14,
                        PantasSpace.s8,
                        PantasSpace.s12,
                        PantasSpace.s8,
                      ),
                      decoration: BoxDecoration(
                        color: well,
                        borderRadius: radius,
                      ),
                      foregroundDecoration: ring == null
                          ? null
                          : BoxDecoration(
                              borderRadius: radius,
                              border: Border.all(
                                color: ring,
                                width: ringWidth,
                              ),
                            ),
                      child: Row(
                        children: [
                          Expanded(child: Text(text, style: valueStyle)),
                          const SizedBox(width: PantasSpace.s8),
                          AnimatedRotation(
                            turns: _isOpen ? .5 : 0,
                            duration: _still
                                ? Duration.zero
                                : PantasDurations.medium1,
                            curve: PantasCurves.move,
                            child: Icon(
                              _caretDown,
                              size: PantasSize.icon - PantasSpace.s4,
                              color: disabled
                                  ? colors.textDisabled
                                  : colors.iconMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _listbox,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: PantasFieldLabel(widget.label, optional: widget.optional),
          ),
          const SizedBox(height: PantasSpace.s6),
          button,
          if (invalid) ...[
            const SizedBox(height: PantasSpace.s6),
            PantasFieldMessage(widget.errorText!, error: true),
          ] else if (widget.helpText != null) ...[
            const SizedBox(height: PantasSpace.s6),
            PantasFieldMessage(widget.helpText!),
          ],
        ],
      ),
    );
  }

  Widget _listbox(BuildContext context) {
    final colors = context.colors;
    final selected = _selectedIndex;
    return Stack(
      children: [
        // A press outside closes the list.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _hide,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          offset: const Offset(0, PantasSpace.s6),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _width,
              child: AnimatedBuilder(
                animation: _open,
                builder: (context, child) {
                  final t = PantasCurves.move.transform(_open.value);
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * PantasSpace.s8),
                      child: child,
                    ),
                  );
                },
                child: Semantics(
                  container: true,
                  label: widget.label,
                  child: DecoratedBox(
                    key: const ValueKey('select-list'),
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(PantasRadius.lg),
                      boxShadow: context.shadows.popover,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height / 2,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(PantasSpace.s6),
                        children: [
                          for (var i = 0; i < widget.options.length; i++)
                            _item(context, i, i == selected),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _item(BuildContext context, int i, bool chosen) {
    final colors = context.colors;
    final active = i == _active;
    final radius = BorderRadius.circular(PantasRadius.md);
    return Semantics(
      button: true,
      selected: chosen,
      label: widget.options[i].label,
      excludeSemantics: true,
      onTap: () => _pick(i),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _pick(i),
          onHover: (hovering) {
            if (hovering) setState(() => _active = i);
          },
          borderRadius: radius,
          hoverColor: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: chosen
                  ? colors.accentTint
                  : active
                      ? colors.surfaceHover
                      : null,
              border: active
                  ? Border.all(
                      color: colors.accent,
                      width: PantasBorder.focus,
                    )
                  : null,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: PantasSize.navItem),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s12,
                  vertical: PantasSpace.s8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.options[i].label,
                        style: PantasType.webSub.copyWith(
                          fontWeight:
                              chosen ? FontWeight.w600 : FontWeight.w400,
                          color: chosen
                              ? colors.accentTintText
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                    if (chosen)
                      Icon(
                        PantasIcons.check,
                        size: PantasSize.icon - PantasSpace.s4,
                        color: colors.accentTintText,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
