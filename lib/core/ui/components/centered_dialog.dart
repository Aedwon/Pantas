import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

class CenteredDialog extends StatelessWidget {
  const CenteredDialog({
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onConfirm,
    required this.onCancel,
    this.destructive = false,
    this.inlineActions = false,
    this.content,
    this.allowEscape = true,
    this.horizontalInset = 28,
    this.actionGap = 8,
    this.lift = 0,
    super.key,
  });
  final String title;
  final String message;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool destructive;
  final bool inlineActions;
  final Widget? content;
  final bool allowEscape;

  /// Phone gap to the screen edge. ST_SignOut uses 24, the leave dialogs 28.
  final double horizontalInset;

  /// Phone gap between side-by-side buttons. ST_SignOut uses 10.
  final double actionGap;

  /// Phone: how far above the screen center the card sits (the mock boards
  /// center it 30 px high). A negative value sits it lower.
  final double lift;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (context.wideWeb) {
      final t = context.webTokens;
      return CallbackShortcuts(
        bindings: {
          if (allowEscape)
            const SingleActivator(LogicalKeyboardKey.escape): onCancel,
        },
        // Keys only reach the shortcut from a focused node inside it, and a
        // dialog opens with focus on its route, not on anything in the card.
        child: Focus(
          autofocus: true,
          child: Dialog(
            backgroundColor: t.colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.all(24),
            child: SizedBox(
              width: content == null ? 440 : 560,
              child: WebCard(
                key: const ValueKey('centered-dialog-surface'),
                radius: 22,
                padding: const EdgeInsets.all(26),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(title, style: t.h3),
                      const SizedBox(height: 18),
                      Text(
                        message,
                        style: t.style(
                          16,
                          height: 1.45,
                          color: t.colors.secondaryLabel,
                        ),
                      ),
                      if (content != null) ...[
                        const SizedBox(height: 18),
                        content!,
                      ],
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          WebButton(
                            label: secondaryLabel,
                            variant: WebButtonVariant.tertiary,
                            onPressed: onCancel,
                          ),
                          WebButton(
                            label: primaryLabel,
                            variant: destructive
                                ? WebButtonVariant.danger
                                : WebButtonVariant.primary,
                            onPressed: onConfirm,
                          ),
                        ],
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
    Widget pill(String label, VoidCallback action, {required bool primary}) =>
        TextButton(
          onPressed: action,
          style: TextButton.styleFrom(
            backgroundColor: primary
                ? destructive
                    ? c.destructive
                    : c.accentFill
                : c.fill,
            foregroundColor: primary
                ? destructive
                    ? c.onDestructive
                    : c.onAccent
                : c.label,
            minimumSize: const Size(0, 46),
            visualDensity: VisualDensity.standard,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            style: context.type.emphasized.copyWith(
              fontSize: 16,
              color: primary
                  ? destructive
                      ? c.onDestructive
                      : c.onAccent
                  : c.label,
            ),
          ),
        );
    return CallbackShortcuts(
      bindings: {
        if (allowEscape)
          const SingleActivator(LogicalKeyboardKey.escape): onCancel,
      },
      child: Dialog(
        backgroundColor: context.colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: EdgeInsets.fromLTRB(
          horizontalInset,
          24 + (lift < 0 ? -2 * lift : 0),
          horizontalInset,
          24 + (lift > 0 ? 2 * lift : 0),
        ),
        child: DecoratedBox(
          key: const ValueKey('centered-dialog-surface'),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withValues(alpha: .2),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
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
                if (content != null) content!,
                SizedBox(
                  height: content != null
                      ? 8
                      : destructive || inlineActions
                          ? 20
                          : 18,
                ),
                ButtonPair(
                  stacked: !destructive && !inlineActions,
                  gap: actionGap,
                  primary: destructive || inlineActions
                      ? pill(primaryLabel, onConfirm, primary: true)
                      : PantasButton(
                          label: primaryLabel,
                          onPressed: onConfirm,
                        ),
                  secondary: destructive || inlineActions
                      ? pill(secondaryLabel, onCancel, primary: false)
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
      ),
    );
  }
}
