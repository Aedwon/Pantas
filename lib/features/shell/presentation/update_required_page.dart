import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/platform/app_update/app_update.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:url_launcher/url_launcher.dart';

/// Whether this build is below the minimum the server publishes.
///
/// A published minimum of 0 blocks nothing, which is the state every
/// install is in until someone sets it deliberately.
bool updateIsRequired({
  required int currentBuild,
  required int minimumSupportedBuild,
}) {
  if (minimumSupportedBuild <= 0) return false;
  return currentBuild < minimumSupportedBuild;
}

/// The only modal in the app a student cannot dismiss.
///
/// That is justified only because the alternative is an app that is
/// actively wrong. It says the one thing the student can act on and
/// nothing else: no version numbers, no changelog, no apology.
class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({
    super.key,
    this.storeUrl,
    this.isWeb = kIsWeb,
    this.updateInPlace = updateWebAppInPlace,
  });

  /// Overridden in tests. Null uses the platform's own listing.
  final Uri? storeUrl;

  /// On web the page updates in place. Overridden in tests.
  final bool isWeb;

  /// Reloads the web app on its newest build. Overridden in tests.
  final Future<void> Function() updateInPlace;

  static const double _logoSize = 96;

  static final Uri _playListing = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.aedwon.pantas',
  );

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      return PopScope(
        canPop: false,
        child: WebFullNotice(
          title: 'Pantas needs an update to keep working.',
          actionLabel: 'Update',
          onPressed: () => _openStore(context),
        ),
      );
    }
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.colors.bgPage,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        PantasSpace.s32,
                        PantasSpace.s8,
                        PantasSpace.s32,
                        PantasSpace.s56 + PantasSpace.s56 + PantasSpace.s8,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PantasLogo(size: _logoSize),
                            const SizedBox(height: PantasSpace.s14),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                'Pantas needs an update to keep working.',
                                textAlign: TextAlign.center,
                                style: PantasType.phoneTitle2.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s16,
                    PantasSpace.s14,
                    PantasSpace.s16,
                    // `phone-bottom` pads 30 under the button.
                    PantasSpace.s28 + PantasSpace.s2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.colors.bgPage.withValues(alpha: 0),
                        context.colors.bgPage,
                      ],
                      stops: const [0, .26],
                    ),
                  ),
                  child: PantasButton(
                    label: 'Update',
                    onPressed: () => _openStore(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(BuildContext context) async {
    if (isWeb) {
      await updateInPlace();
      return;
    }
    await launchUrl(
      storeUrl ?? _playListing,
      mode: LaunchMode.externalApplication,
    );
  }
}
