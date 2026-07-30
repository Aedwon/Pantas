import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
  const UpdateRequiredPage({super.key, this.storeUrl});

  /// Overridden in tests. Null uses the platform's own listing.
  final Uri? storeUrl;

  static final Uri _playListing = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.pantas.app',
  );

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pantas needs an update to keep working.',
                  style: styles.headlineMedium.copyWith(
                    fontFamily: 'SourceSans3',
                  ),
                ),
                const SizedBox(height: 24),
                BoardButton(
                  label: 'Update',
                  onPressed: () => _openStore(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(BuildContext context) async {
    await launchUrl(
      storeUrl ?? _playListing,
      mode: LaunchMode.externalApplication,
    );
  }
}
