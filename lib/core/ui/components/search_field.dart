import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

// Aedwon accepted ST_Search's inactive placeholder pair, October 10.

class SearchField extends StatefulWidget {
  const SearchField({
    required this.onChanged,
    this.hint = 'Search',
    this.title,
    this.controller,
    this.onEditingChanged,
    this.titleInset = 0,
    this.fieldEntryDelay,
    this.autofocus = false,
    this.outlined = false,
    this.keyHint,
    super.key,
  });
  final ValueChanged<String> onChanged;
  final String hint;
  final String? title;
  final TextEditingController? controller;
  final ValueChanged<bool>? onEditingChanged;
  final double titleInset;
  final Duration? fieldEntryDelay;
  final bool autofocus;
  final bool outlined;

  /// The key hint (a `WebKeyHint`, "Ctrl K"), shown at the right of an empty
  /// desktop field. It is decoration: hidden on touch screens.
  final Widget? keyHint;
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _owned = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _editing = false;
  bool _hovered = false;
  bool _focused = false;
  TextEditingController get _text => widget.controller ?? _owned;
  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
    if (widget.autofocus) _focus.requestFocus();
  }

  @override
  void didUpdateWidget(covariant SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autofocus && !oldWidget.autofocus) _focus.requestFocus();
  }

  void _focusChanged() {
    if (_focused != _focus.hasFocus) {
      setState(() => _focused = _focus.hasFocus);
    }
    if (_focus.hasFocus && !_editing) {
      setState(() => _editing = true);
      widget.onEditingChanged?.call(true);
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_focusChanged)
      ..dispose();
    _owned.dispose();
    super.dispose();
  }

  void _clear() {
    _text.clear();
    widget.onChanged('');
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final duration = still ? Duration.zero : PantasDurations.flip;
    // The pointer-first desktop field is 38; the phone and the outlined
    // field are 44 with a larger radius and the phone body text.
    final phone = widget.outlined || !context.wideWeb;
    final ringColor = _focused
        ? colors.accent
        : _hovered
            ? colors.textSecondary
            : colors.borderControl;
    final radius = BorderRadius.circular(
      phone ? PantasRadius.md : PantasRadius.sm,
    );
    final textStyle = (phone ? PantasType.phoneBody : PantasType.webSub)
        .copyWith(color: colors.textPrimary);
    final field = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (_text.text.isNotEmpty) _clear();
          },
        },
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: ringColor),
          duration: still ? Duration.zero : PantasDurations.short2,
          curve: PantasCurves.fade,
          builder: (context, ring, _) => Container(
            key: const ValueKey('search-fill'),
            constraints: BoxConstraints(
              minHeight: phone ? PantasSize.iconBtn : PantasSize.search,
            ),
            padding: EdgeInsets.only(
              left: phone ? PantasSpace.s14 : PantasSpace.s12,
              right: phone ? PantasSpace.s8 : PantasSpace.s10,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: radius,
            ),
            // The ring is drawn over the well (an inset ring), so it never
            // changes the room the 44 px clear button needs.
            foregroundDecoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: ring ?? ringColor,
                width: _focused ? PantasBorder.ringSelected : PantasBorder.ring,
              ),
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    PantasIcons.search,
                    size: PantasSize.icon - PantasSpace.s2,
                    color: colors.iconMuted,
                  ),
                ),
                const SizedBox(width: PantasSpace.s8),
                Expanded(
                  child: TextField(
                    controller: _text,
                    focusNode: _focus,
                    onChanged: widget.onChanged,
                    style: textStyle,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle:
                          textStyle.copyWith(color: colors.textSecondary),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: PantasSpace.s8,
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _text,
                  builder: (context, value, _) {
                    if (value.text.isNotEmpty) return _clearButton(context);
                    final hint = widget.keyHint;
                    if (hint == null || phone) return const SizedBox.shrink();
                    return ExcludeSemantics(child: hint);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final delay = widget.fieldEntryDelay?.inMilliseconds;
    final enteringField = delay == null
        ? field
        : TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : Duration(
                    milliseconds: delay + PantasDurations.long1.inMilliseconds,
                  ),
            curve: Interval(
              delay / (delay + PantasDurations.long1.inMilliseconds),
              1,
              curve: PantasCurves.house,
            ),
            builder: (context, value, child) => ExcludeFocus(
              excluding: value == 0,
              child: ExcludeSemantics(
                excluding: value == 0,
                child: Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, PantasSpace.s12 * (1 - value)),
                    child: child,
                  ),
                ),
              ),
            ),
            child: field,
          );
    final cancel = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _editing ? 1 : 0),
      duration: duration,
      curve: PantasCurves.house,
      builder: (context, value, child) => ClipRect(
        child: Align(
          widthFactor: value,
          child: Opacity(
            opacity: value,
            child: ExcludeFocus(
              excluding: !_editing,
              child: ExcludeSemantics(
                excluding: !_editing,
                child: child,
              ),
            ),
          ),
        ),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(PantasSize.field, PantasSize.targetTouch),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.standard,
        ),
        onPressed: () {
          _text.clear();
          widget.onChanged('');
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() => _editing = false);
          widget.onEditingChanged?.call(false);
        },
        child: Text(
          'Cancel',
          style: PantasType.phoneBody.copyWith(color: colors.accent),
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: _editing ? 0 : 1),
            duration: duration,
            curve: PantasCurves.house,
            builder: (context, value, child) => ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                heightFactor: value,
                child: Opacity(
                  opacity: value,
                  child: ExcludeSemantics(
                    excluding: _editing,
                    child: child,
                  ),
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: widget.titleInset,
                bottom: PantasSpace.s14,
              ),
              child: Text(
                widget.title!,
                style: PantasType.phoneLargeTitle.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        // The field stays 14 px under the title whatever the Cancel height.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: enteringField), cancel],
        ),
      ],
    );
  }

  /// The clear button (`icon-btn--sm`, 32 drawn, 44 hit area). Keyboard users
  /// clear with Esc or Cancel, so it takes no Tab stop.
  Widget _clearButton(BuildContext context) => Semantics(
        button: true,
        label: 'Clear search',
        excludeSemantics: true,
        onTap: _clear,
        child: InkWell(
          onTap: _clear,
          canRequestFocus: false,
          borderRadius: BorderRadius.circular(PantasRadius.md),
          hoverColor: context.colors.textPrimary.withValues(
            alpha: PantasOpacity.hover,
          ),
          child: SizedBox.square(
            dimension: PantasSize.targetTouch,
            child: Center(
              child: Icon(
                PantasIcons.close,
                size: PantasSize.icon - PantasSpace.s4,
                color: context.colors.iconMuted,
              ),
            ),
          ),
        ),
      );
}
