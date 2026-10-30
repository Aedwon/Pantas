import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum WebLayoutTier { phone, tabletPortrait, tabletLandscape, desktop }

WebLayoutTier webLayoutTier({required double width, bool web = kIsWeb}) {
  if (!web || width < 600) return WebLayoutTier.phone;
  if (width < 1024) return WebLayoutTier.tabletPortrait;
  if (width < 1280) return WebLayoutTier.tabletLandscape;
  return WebLayoutTier.desktop;
}

/// Desktop content starts on landscape tablets. The sidebar starts on desktop.
bool isWideWebLayout({required double width, bool web = kIsWeb}) =>
    webLayoutTier(width: width, web: web).index >=
    WebLayoutTier.tabletLandscape.index;

/// Overrides only the platform input for native widget tests.
@visibleForTesting
bool? debugWebPlatformOverride;

extension WebLayoutContext on BuildContext {
  bool get webPlatform => debugWebPlatformOverride ?? kIsWeb;
  WebLayoutTier get webTier => webLayoutTier(
        width: MediaQuery.sizeOf(this).width,
        web: webPlatform,
      );
  bool get wideWeb => webTier.index >= WebLayoutTier.tabletLandscape.index;
}
