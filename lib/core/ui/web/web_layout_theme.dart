import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// Keep narrow web identical to the existing app, including its palette.
class WebLayoutTheme extends StatelessWidget {
  const WebLayoutTheme({required this.child, this.web = kIsWeb, super.key});
  final Widget child;
  final bool web;

  @override
  Widget build(BuildContext context) {
    if (!isWideWebLayout(width: MediaQuery.sizeOf(context).width, web: web)) {
      return child;
    }
    return Theme(
      data: Theme.of(context).brightness == Brightness.dark
          ? buildDarkTheme(web: true)
          : buildLightTheme(web: true),
      child: child,
    );
  }
}
