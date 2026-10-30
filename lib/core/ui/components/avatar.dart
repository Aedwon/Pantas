import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

class Avatar extends StatelessWidget {
  const Avatar({this.name = '', this.photo, super.key});
  static final _letter = RegExp(r'^\p{L}', unicode: true);
  final String name;
  final ImageProvider<Object>? photo;
  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '' : name.trim().characters.first;
    final emoji = initial.isNotEmpty &&
        (initial.runes.first >= 0x1F000 ||
            (initial.runes.first >= 0x2600 && initial.runes.first <= 0x27BF) ||
            initial.runes.contains(0xFE0F) ||
            initial.runes.contains(0x20E3));
    final c = context.colors;
    final wide = context.wideWeb;
    final plain = !emoji && !_letter.hasMatch(initial);
    final fallback = plain
        ? Icon(PantasIcons.profile, size: 30, color: c.secondaryLabel)
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              emoji ? initial : initial.toUpperCase(),
              style: context.type.emphasized.copyWith(
                fontSize: wide ? 19 : 25,
                color: wide ? context.webTokens.tintText : c.onAccent,
                letterSpacing: -.3,
              ),
            ),
          );
    return Semantics(
      label: name.trim().isEmpty ? 'Profile' : name,
      excludeSemantics: true,
      child: ClipOval(
        child: Container(
          width: wide ? 44 : 58,
          height: wide ? 44 : 58,
          color: plain
              ? c.fill
              : emoji || wide
                  ? c.accentTint
                  : c.accentFill,
          alignment: Alignment.center,
          child: photo == null
              ? fallback
              : Image(
                  image: photo!,
                  width: wide ? 44 : 58,
                  height: wide ? 44 : 58,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => fallback,
                ),
        ),
      ),
    );
  }
}
