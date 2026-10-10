import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

// Aedwon accepted ST_Search's inactive placeholder pair, October 10.
const searchPlaceholderColor = Color(0xFF8E8E93);

class SearchField extends StatefulWidget {
  const SearchField({
    required this.onChanged,
    this.hint = 'Search',
    this.title,
    this.controller,
    super.key,
  });
  final ValueChanged<String> onChanged;
  final String hint;
  final String? title;
  final TextEditingController? controller;
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _owned = TextEditingController();
  final FocusNode _focus = FocusNode();
  TextEditingController get _text => widget.controller ?? _owned;
  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
  }

  void _focusChanged() {
    setState(() {});
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
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.colors.fill,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(PantasIcons.search, size: 17, color: searchPlaceholderColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _text,
              focusNode: _focus,
              onChanged: widget.onChanged,
              style: context.type.body,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle:
                    context.type.body.copyWith(color: searchPlaceholderColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 7),
              ),
            ),
          ),
        ],
      ),
    );
    final cancel = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _focus.hasFocus ? 1 : 0),
      duration: duration,
      curve: PantasCurves.houseOut,
      builder: (context, value, child) => ClipRect(
        child: Align(
          widthFactor: value,
          child: Opacity(
            opacity: value,
            child: ExcludeFocus(
              excluding: !_focus.hasFocus,
              child: ExcludeSemantics(
                excluding: !_focus.hasFocus,
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
          _focus.unfocus();
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
            tween: Tween(begin: 1, end: _focus.hasFocus ? 0 : 1),
            duration: duration,
            curve: PantasCurves.houseOut,
            builder: (context, value, child) => ClipRect(
              child: Align(
                heightFactor: value,
                child: Opacity(
                  opacity: value,
                  child: ExcludeSemantics(
                    excluding: _focus.hasFocus,
                    child: child,
                  ),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(widget.title!, style: context.type.largeTitle),
            ),
          ),
        Row(children: [Expanded(child: field), cancel]),
      ],
    );
  }
}
