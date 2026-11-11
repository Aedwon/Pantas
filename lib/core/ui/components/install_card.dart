import 'package:flutter/material.dart';
import 'package:pantas/core/platform/install/install_platform.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The Home card that offers to install Pantas (PWA install board, option A).
///
/// It lays out as one row when there is room and as a stack on a phone. The
/// primary button opens the browser's install dialog, or on iPhone Safari the
/// three-step sheet. Whether to show the card at all is decided by the caller.
class InstallCard extends StatelessWidget {
  const InstallCard({
    required this.path,
    required this.onPrimary,
    required this.onNotNow,
    super.key,
  }) : assert(
          path != InstallPath.none,
          'Do not build the card when there is no install path.',
        );

  final InstallPath path;
  final VoidCallback onPrimary;
  final VoidCallback onNotNow;

  /// Below this width the card stacks, as drawn for the phone.
  static const double rowBreakpoint = 560;

  bool get _ios => path == InstallPath.iosInstructions;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= rowBreakpoint;
        // An iPad is wide but still adds to the Home Screen, so it keeps the
        // Home Screen wording.
        final desktopCopy = wide && !_ios;
        final title = desktopCopy
            ? 'Keep Pantas one click away'
            : 'Keep Pantas on your Home Screen';
        final body = desktopCopy
            ? 'Install it and Pantas opens in its own window, like any app. '
                'Your progress stays the same.'
            : 'Pantas opens faster and keeps working without internet. '
                'Your progress stays the same.';
        final primary = WebButton(
          label: _ios ? 'Show Me How' : 'Install Pantas',
          onPressed: onPrimary,
        );
        final notNow = WebButton(
          label: 'Not Now',
          variant: WebButtonVariant.tertiary,
          onPressed: onNotNow,
        );
        final titleStyle = (wide ? PantasType.webH3 : PantasType.phoneTitle3)
            .copyWith(color: t.colors.textPrimary);
        final bodyStyle = (wide ? PantasType.webSub : PantasType.webRowSub)
            .copyWith(color: t.colors.textSecondary);
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: titleStyle),
            ),
            const SizedBox(height: PantasSpace.s4),
            Text(body, style: bodyStyle),
          ],
        );
        if (wide) {
          return WebCard(
            padding: const EdgeInsets.symmetric(
              horizontal: PantasSpace.s20,
              vertical: PantasSpace.s18,
            ),
            child: Row(
              children: [
                const PantasLogo(size: PantasSize.avatarLg),
                const SizedBox(width: PantasSpace.s18),
                Expanded(child: text),
                const SizedBox(width: PantasSpace.s18),
                notNow,
                const SizedBox(width: PantasSpace.s10),
                primary,
              ],
            ),
          );
        }
        return WebCard(
          padding: const EdgeInsets.all(PantasSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PantasLogo(size: PantasSpace.s40),
                  const SizedBox(width: PantasSpace.s14),
                  Expanded(child: text),
                ],
              ),
              const SizedBox(height: PantasSpace.s14),
              Wrap(
                spacing: PantasSpace.s10,
                runSpacing: PantasSpace.s10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [primary, notNow],
              ),
            ],
          ),
        );
      },
    );
  }
}
