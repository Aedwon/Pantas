import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/web/web_components.dart';

/// The board's four-color Google mark (ST_AccountOut), 18 px.
const _googleMark = '''
<svg viewBox="0 0 24 24">
<path fill="#4285F4" d="M22.5 12.3c0-.8-.1-1.5-.2-2.3H12v4.4h5.9a5 5 0 0 1-2.2 3.3v2.7h3.5c2.1-1.9 3.3-4.7 3.3-8.1z"/>
<path fill="#34A853" d="M12 23c3 0 5.5-1 7.2-2.7l-3.5-2.7c-1 .7-2.2 1-3.7 1-2.9 0-5.3-1.9-6.2-4.5H2.2v2.8A11 11 0 0 0 12 23z"/>
<path fill="#FBBC05" d="M5.8 14.1a6.6 6.6 0 0 1 0-4.2V7.1H2.2a11 11 0 0 0 0 9.8z"/>
<path fill="#EA4335" d="M12 5.4c1.6 0 3.1.6 4.2 1.7l3.1-3.1A11 11 0 0 0 2.2 7.1l3.6 2.8C6.7 7.3 9.1 5.4 12 5.4z"/>
</svg>''';

/// The standard Google sign-in button: the white button with the four-color
/// G (Google's brand rules require the mark). The same button on the phone and
/// on a wide screen; [expand] stretches it across a phone column.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    this.label = 'Continue with Google',
    this.busy = false,
    this.expand = false,
    this.size,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool expand;

  /// A size class for a place the field height is too big, such as a card
  /// footer (`sm`, 42). Null keeps the 48 px field height.
  final PantasButtonSize? size;

  @override
  Widget build(BuildContext context) => WebButton(
        label: label,
        variant: WebButtonVariant.white,
        size: size,
        height: size == null ? PantasSize.field : null,
        expand: expand,
        icon: SvgPicture.string(_googleMark, width: 18, height: 18),
        busy: busy,
        onPressed: onPressed,
      );
}
