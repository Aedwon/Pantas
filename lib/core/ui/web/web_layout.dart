import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// One breakpoint for every desktop-web presentation fork.
bool isWideWebLayout({required double width, bool web = kIsWeb}) =>
    web && width >= 1024;

/// Overrides only the platform input for native widget tests.
@visibleForTesting
bool? debugWebPlatformOverride;

extension WebLayoutContext on BuildContext {
  bool get wideWeb => isWideWebLayout(
        width: MediaQuery.sizeOf(this).width,
        web: debugWebPlatformOverride ?? kIsWeb,
      );
}
