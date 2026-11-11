import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/pantas_popover.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/core/ui/components/typeahead_buffer.dart';
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
/// the placeholder.
///
/// [searchable] adds a search field at the top of the list, then a hairline.
/// It filters the options as you type (a label that contains the text, any
/// case) and takes focus when the list opens; the arrows move the active
/// item, Enter picks it and Esc closes. "No results" shows only when no option
/// is visible. A `role="status"` region announces the count ("3 results",
/// "No results"). [loading] shows the spinner with [loadingText] (such as
/// "Loading provinces") in place of the options. Reduced motion keeps the list
/// appearing at once.
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
    this.searchable = false,
    this.searchHint = 'Search',
    this.loading = false,
    this.loadingText,
    this.noResultsText = 'No results',
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

  /// Adds the search field at the top of the list (more than about ten
  /// options).
  final bool searchable;
  final String searchHint;

  /// True while the options load: the list shows the spinner and
  /// [loadingText] instead of the options.
  final bool loading;
  final String? loadingText;

  /// The row shown when no option matches the search.
  final String noResultsText;

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
  final TypeaheadBuffer _typeahead = TypeaheadBuffer();
  final TextEditingController _query = TextEditingController();
  double _width = 0;

  int get _selectedIndex =>
      widget.options.indexWhere((o) => o.value == widget.value);

  /// The indices of the options the search leaves visible.
  List<int> get _visible {
    final q = _query.text.trim().toLowerCase();
    return [
      for (var i = 0; i < widget.options.length; i++)
        if (q.isEmpty || widget.options[i].label.toLowerCase().contains(q)) i,
    ];
  }

  String _countText(int count) => count == 0
      ? widget.noResultsText
      : count == 1
          ? '1 result'
          : '$count results';

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
    FocusManager.instance.removeEarlyKeyEventHandler(_onEarlyKey);
    _query.dispose();
    _open.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _still => MediaQuery.disableAnimationsOf(context);

  void _show() {
    if (_isOpen || !widget.enabled) return;
    if (widget.options.isEmpty && !widget.loading) return;
    _query.clear();
    _typeahead.reset();
    _active = math.max(0, _visible.indexOf(_selectedIndex));
    if (widget.searchable) {
      FocusManager.instance.addEarlyKeyEventHandler(_onEarlyKey);
    }
    setState(() => _isOpen = true);
    _portal.show();
    if (_still) {
      _open.value = 1;
    } else {
      _open.forward(from: 0);
    }
  }

  /// With search, the field holds focus and clears itself on Esc. Esc closes
  /// the list instead (Select README, Keyboard), so it is taken before the
  /// field sees it.
  KeyEventResult _onEarlyKey(KeyEvent event) {
    if (!_isOpen || !widget.searchable) return KeyEventResult.ignored;
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _hide();
      _focus.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _hide() {
    if (!_isOpen) return;
    FocusManager.instance.removeEarlyKeyEventHandler(_onEarlyKey);
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

  /// Picks the [position]th visible option.
  void _pick(int position) {
    final visible = _visible;
    if (position < 0 || position >= visible.length) return;
    widget.onChanged(widget.options[visible[position]].value);
    _hide();
    _focus.requestFocus();
  }

  void _move(int to) => setState(
        () => _active = to.clamp(0, math.max(0, _visible.length - 1)),
      );

  /// Keys while the search field has focus: the arrows move the active item,
  /// Enter picks it, Tab closes. Home, End and Space stay with the text.
  KeyEventResult _onSearchKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(_active + 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _move(_active - 1);
    } else if (key == LogicalKeyboardKey.enter) {
      _pick(_active);
    } else if (key == LogicalKeyboardKey.tab) {
      // Closing returns focus to the button (Select README, Keyboard).
      _hide();
      _focus.requestFocus();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

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
      _move(_visible.length - 1);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _pick(_active);
    } else if (key == LogicalKeyboardKey.tab) {
      _hide();
      return KeyEventResult.ignored;
    } else if (!widget.searchable && TypeaheadBuffer.accepts(event)) {
      // Typeahead: the first letters jump to a match.
      final at = _typeahead.searchEvent(
        event,
        [for (final i in _visible) widget.options[i].label],
      );
      if (at != null) _move(at);
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
                      child: Material(
                        type: MaterialType.transparency,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.searchable) ...[
                              Padding(
                                padding: const EdgeInsets.all(PantasSpace.s6),
                                child: Focus(
                                  canRequestFocus: false,
                                  skipTraversal: true,
                                  onKeyEvent: _onSearchKey,
                                  child: SearchField(
                                    controller: _query,
                                    hint: widget.searchHint,
                                    autofocus: true,
                                    showCancel: false,
                                    onChanged: (_) =>
                                        setState(() => _active = 0),
                                  ),
                                ),
                              ),
                              const PantasPopoverSeparator(),
                            ],
                            Flexible(child: _results(context)),
                          ],
                        ),
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

  /// The rows under the search field: the spinner while loading, "No results"
  /// when the search leaves nothing, else the visible options. A status
  /// region carries the count for a screen reader.
  Widget _results(BuildContext context) {
    final colors = context.colors;
    final visible = _visible;
    final selected = _selectedIndex;
    final Widget body;
    final String status;
    if (widget.loading) {
      status = widget.loadingText ?? 'Loading';
      body = Padding(
        padding: const EdgeInsets.all(PantasSpace.s12),
        child: Row(
          children: [
            const ExcludeSemantics(child: PantasSpinner()),
            const SizedBox(width: PantasSpace.s10),
            Expanded(
              child: Text(
                status,
                style: PantasType.webSub.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (visible.isEmpty) {
      status = widget.noResultsText;
      body = PantasPopoverEmpty(widget.noResultsText);
    } else {
      status = _countText(visible.length);
      body = ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(PantasSpace.s6),
        children: [
          for (var p = 0; p < visible.length; p++)
            _item(context, p, visible[p] == selected),
        ],
      );
    }
    return Semantics(
      key: const ValueKey('select-status'),
      container: true,
      liveRegion: true,
      label: widget.searchable || widget.loading || visible.isEmpty
          ? status
          : null,
      explicitChildNodes: true,
      child: body,
    );
  }

  Widget _item(BuildContext context, int position, bool chosen) {
    final colors = context.colors;
    final i = _visible[position];
    final active = position == _active;
    final radius = BorderRadius.circular(PantasRadius.md);
    return Semantics(
      button: true,
      selected: chosen,
      label: widget.options[i].label,
      excludeSemantics: true,
      onTap: () => _pick(position),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _pick(position),
          onHover: (hovering) {
            if (hovering) setState(() => _active = position);
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
