import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// Shows [message] as the system's Toast (design system 4.0, Toast), through
/// the page's messenger so the timing and the replacement of an earlier
/// message stay as they were. The messenger's own bar is made invisible.
void showMockToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context); // ds-raw: toast host
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        // ds-raw: transparent host for Toast
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.all(PantasSpace.s16),
        content: Toast(message: message, web: context.wideWeb),
      ),
    );
}
