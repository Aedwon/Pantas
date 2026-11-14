import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/platform/app_update/update_overlay_registry.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// Asks one question over a scrim with at most two buttons (design system:
/// Dialog). Surface `surface-modal`, radius `radius-2xl`, shadow `elev-modal`.
///
/// Wide screens: 440 wide (560 with [content]), padding 24, gap 16, title
/// `web-h3`, the body scrolls while the actions stay in view, and the buttons
/// sit at the right: the safe one first, the main one last. Phone: inset 24,
/// padding 20 20 18, gap 8, title `phone-title-3`, and a pill pair 46 high,
/// 10 apart, that stacks with the main action on top at large text.
class CenteredDialog extends StatefulWidget {
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
    this.horizontalInset = PantasSpace.s24,
    this.actionGap = PantasSpace.s10,
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

  /// Kept for callers. The phone pair is always side by side now.
  final bool inlineActions;
  final Widget? content;
  final bool allowEscape;

  /// Phone gap to the screen edge (system: 24).
  final double horizontalInset;

  /// Phone gap between the pair (system: 10).
  final double actionGap;

  /// Phone: how far above the screen center the card sits (the mock boards
  /// center it 30 high). A negative value sits it lower.
  final double lift;

  /// Space between the card and the edge of the window.
  static const double _windowInset = PantasSpace.s24;

  /// The inset that moves a centered card by one unit of [lift].
  static const double _liftSpread = PantasSpace.s2;

  @override
  State<CenteredDialog> createState() => _CenteredDialogState();

  Widget _build(BuildContext context) {
    final colors = context.colors;
    final shortcuts = <ShortcutActivator, VoidCallback>{
      if (allowEscape)
        const SingleActivator(LogicalKeyboardKey.escape): onCancel,
    };
    // Moving the card up by `lift` takes `lift` off the top and puts twice
    // that on the bottom, since the dialog centers in what is left.
    final extraTop = lift < 0 ? -lift * _liftSpread : 0.0;
    final extraBottom = lift > 0 ? lift * _liftSpread : 0.0;
    final surface = BoxDecoration(
      color: colors.surfaceModal,
      borderRadius: BorderRadius.circular(PantasRadius.r2xl),
      boxShadow: context.shadows.modal,
    );
    // Tab reaches the safe action first in a destructive dialog and the main
    // action first otherwise, whatever the visual order.
    Widget order(Widget button, {required bool main}) => FocusTraversalOrder(
          order: NumericFocusOrder(main == destructive ? 1 : 0),
          child: button,
        );
    if (context.wideWeb) {
      return CallbackShortcuts(
        bindings: shortcuts,
        // Keys only reach the shortcut from a focused node inside it, and a
        // dialog opens with focus on its route, not on anything in the card.
        child: Focus(
          autofocus: true,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.all(_windowInset),
            child: SizedBox(
              width:
                  content == null ? PantasLayout.modal : PantasLayout.modalWide,
              child: DecoratedBox(
                key: const ValueKey('centered-dialog-surface'),
                decoration: surface,
                child: Padding(
                  padding: const EdgeInsets.all(PantasSpace.s24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: PantasType.webH3
                            .copyWith(color: colors.textPrimary),
                      ),
                      const SizedBox(height: PantasSpace.s16),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                message,
                                style: PantasType.webBody
                                    .copyWith(color: colors.textSecondary),
                              ),
                              if (content != null) ...[
                                const SizedBox(height: PantasSpace.s16),
                                content!,
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: PantasSpace.s16),
                      FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: PantasSpace.s8,
                          runSpacing: PantasSpace.s8,
                          children: [
                            order(
                              WebButton(
                                label: secondaryLabel,
                                variant: WebButtonVariant.tertiary,
                                onPressed: onCancel,
                              ),
                              main: false,
                            ),
                            order(
                              WebButton(
                                label: primaryLabel,
                                variant: destructive
                                    ? WebButtonVariant.danger
                                    : WebButtonVariant.primary,
                                onPressed: onConfirm,
                              ),
                              main: true,
                            ),
                          ],
                        ),
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
    Widget pill(
      String label,
      VoidCallback action, {
      required PantasButtonVariant variant,
    }) =>
        PantasButton(
          label: label,
          variant: variant,
          onPressed: action,
          height: PantasSize.btnBar,
          radius: PantasRadius.full,
          horizontalPadding: PantasSpace.s12,
        );
    return CallbackShortcuts(
      bindings: shortcuts,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PantasRadius.r2xl),
        ),
        insetPadding: EdgeInsets.fromLTRB(
          horizontalInset,
          _windowInset + extraTop,
          horizontalInset,
          _windowInset + extraBottom,
        ),
        child: DecoratedBox(
          key: const ValueKey('centered-dialog-surface'),
          decoration: surface,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s20,
              PantasSpace.s20,
              PantasSpace.s20,
              PantasSpace.s18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: PantasType.phoneTitle3
                      .copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: PantasSpace.s8),
                Text(
                  message,
                  style: PantasType.phoneExplanation
                      .copyWith(color: colors.textSecondary),
                ),
                if (content != null) ...[
                  const SizedBox(height: PantasSpace.s8),
                  content!,
                ],
                const SizedBox(height: PantasSpace.s12),
                FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: ButtonPair(
                    gap: actionGap,
                    primary: order(
                      pill(
                        primaryLabel,
                        onConfirm,
                        variant: destructive
                            ? PantasButtonVariant.destructive
                            : PantasButtonVariant.primary,
                      ),
                      main: true,
                    ),
                    secondary: order(
                      pill(
                        secondaryLabel,
                        onCancel,
                        variant: PantasButtonVariant.neutral,
                      ),
                      main: false,
                    ),
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

/// Opens a dialog over the current page: the one way a screen shows a
/// [CenteredDialog] (or the wide-web confirmation). It passes straight to the
/// framework's `showDialog` and changes nothing about it, so a screen never
/// needs the raw call.
Future<T?> showPantasDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? barrierColor,
  bool barrierDismissible = true,
}) =>
    showDialog<T>(
      context: context,
      builder: builder,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
    );

class _CenteredDialogState extends State<CenteredDialog> {
  @override
  void initState() {
    super.initState();
    updateOverlayRegistry.setOpen(this, open: true);
  }

  @override
  void dispose() {
    updateOverlayRegistry.setOpen(this, open: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget._build(context);
}
