import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class CenteredDialog extends StatelessWidget {
  const CenteredDialog({
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onConfirm,
    required this.onCancel,
    this.destructive = false,
    super.key,
  });
  final String title;
  final String message;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool destructive;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget pill(String label, VoidCallback action, {required bool red}) =>
        TextButton(
          onPressed: action,
          style: TextButton.styleFrom(
            backgroundColor: red ? c.destructive : c.fill,
            foregroundColor: red ? Colors.white : c.label,
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            style: context.type.emphasized
                .copyWith(fontSize: 16, color: red ? Colors.white : c.label),
          ),
        );
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): onCancel},
      child: Dialog(
        backgroundColor: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: context.type.emphasized.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: context.type.subhead
                    .copyWith(color: c.secondaryLabel, height: 1.45),
              ),
              const SizedBox(height: 16),
              ButtonPair(
                stacked: !destructive,
                primary: destructive
                    ? pill(primaryLabel, onConfirm, red: true)
                    : PantasButton(
                        label: primaryLabel,
                        onPressed: onConfirm,
                      ),
                secondary: destructive
                    ? pill(secondaryLabel, onCancel, red: false)
                    : PantasButton(
                        label: secondaryLabel,
                        onPressed: onCancel,
                        variant: PantasButtonVariant.tertiary,
                        height: 44,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
