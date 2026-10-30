import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _owned = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _editing = false;
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

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    final field = Container(
      key: const ValueKey('search-fill'),
      constraints: BoxConstraints(minHeight: widget.outlined ? 44 : 38),
      padding: EdgeInsets.symmetric(horizontal: widget.outlined ? 14 : 10),
      decoration: BoxDecoration(
        color: widget.outlined ? context.colors.surface : context.colors.fill,
        border: widget.outlined
            ? Border.all(color: context.colors.separator)
            : null,
        borderRadius: BorderRadius.circular(widget.outlined ? 12 : 11),
      ),
      child: Row(
        children: [
          Icon(
            PantasIcons.search,
            size: 17,
            color: context.colors.searchPlaceholder,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _text,
              focusNode: _focus,
              onChanged: widget.onChanged,
              style: widget.outlined
                  ? context.type.body.copyWith(fontSize: 16)
                  : context.type.body,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: context.type.body.copyWith(
                  fontSize: widget.outlined ? 16 : null,
                  color: context.colors.searchPlaceholder,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 7),
              ),
            ),
          ),
        ],
      ),
    );
    final delay = widget.fieldEntryDelay?.inMilliseconds;
    final enteringField = delay == null
        ? field
        : TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : Duration(milliseconds: delay + 450),
            curve: Interval(
              delay / (delay + 450),
              1,
              curve: PantasCurves.houseOut,
            ),
            builder: (context, value, child) => ExcludeFocus(
              excluding: value == 0,
              child: ExcludeSemantics(
                excluding: value == 0,
                child: Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
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
      curve: PantasCurves.houseOut,
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
        onPressed: () {
          _text.clear();
          widget.onChanged('');
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() => _editing = false);
          widget.onEditingChanged?.call(false);
        },
        child: Text(
          'Cancel',
          style: context.type.body.copyWith(color: context.colors.accent),
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
            curve: PantasCurves.houseOut,
            builder: (context, value, child) => ClipRect(
              child: Align(
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
              padding: EdgeInsets.only(left: widget.titleInset, bottom: 14),
              child: Text(widget.title!, style: context.type.largeTitle),
            ),
          ),
        Row(children: [Expanded(child: enteringField), cancel]),
      ],
    );
  }
}
