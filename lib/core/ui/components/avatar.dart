import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The learner's avatar: a circle with the first letter of the name on
/// `accent-tint`, or the photo.
///
/// Two sizes: `size-avatar` 30 (sidebar) and `size-avatar-lg` 44 (Settings
/// profile row). The wide layout draws the 44 circle. [size] is the phone
/// diameter. The initial is `web-glyph` (14/700) at 30 and `web-h3` (20/700)
/// at 44. Next to the name as text, the avatar is hidden from the screen
/// reader; alone, it reads as the name.
class Avatar extends StatelessWidget {
  const Avatar({
    this.name = '',
    this.photo,
    this.size = _phoneDefault,
    super.key,
  });

  /// The phone profile circle (58): no token, so 44 plus 14.
  static const double _phoneDefault = PantasSize.avatarLg + PantasSpace.s14;
  static final _letter = RegExp(r'^\p{L}', unicode: true);
  final String name;
  final ImageProvider<Object>? photo;

  /// Phone diameter. The wide layout always draws `size-avatar-lg` (44).
  final double size;

  /// The smallest drawn size, `size-avatar` (30), for the sidebar.
  static const double small = PantasSize.avatar;

  /// The Settings profile size, `size-avatar-lg` (44).
  static const double large = PantasSize.avatarLg;

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
    final diameter = wide ? PantasSize.avatarLg : size;
    final plain = !emoji && !_letter.hasMatch(initial);
    // The initial follows the two system sizes: `web-glyph` up to the sidebar
    // circle, `web-h3` at the profile size and above. The phone circle (58)
    // scales the same style with the circle.
    final initialStyle =
        diameter <= PantasSize.avatar ? PantasType.webGlyph : PantasType.webH3;
    final fallback = plain
        ? wide
            // ST_Avatars: a plain person is a small teal dot on gray, no
            // made-up letter.
            ? Container(
                width: PantasSize.avatarLg * .13,
                height: PantasSize.avatarLg * .13,
                decoration: BoxDecoration(
                  color: c.accent,
                  shape: BoxShape.circle,
                ),
              )
            : Icon(
                PantasIcons.profile,
                size: PantasSize.avatar * size / _phoneDefault,
                color: c.textSecondary,
              )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              emoji ? initial : initial.toUpperCase(),
              style: initialStyle.copyWith(
                fontSize: wide
                    ? initialStyle.fontSize
                    : (initialStyle.fontSize ?? 0) *
                        diameter /
                        (diameter <= PantasSize.avatar
                            ? PantasSize.avatar
                            : PantasSize.avatarLg),
                color: c.accentTintText,
              ),
            ),
          );
    return Semantics(
      label: name.trim().isEmpty ? 'Profile' : name,
      excludeSemantics: true,
      child: ClipOval(
        child: Container(
          width: diameter,
          height: diameter,
          color: plain ? c.fill : c.accentTint,
          alignment: Alignment.center,
          child: photo == null
              ? fallback
              : Image(
                  image: photo!,
                  width: diameter,
                  height: diameter,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => fallback,
                ),
        ),
      ),
    );
  }
}
