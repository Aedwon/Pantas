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

  /// The board's `.main` ends with 44 px of padding. It belongs to the end of a
  /// page's scrolling content, not to the window: the shell stops at the window
  /// bottom, so rows scroll to the edge and the last one rests this far above
  /// it. The Navigator under the shell clips hard at its own box, so padding
  /// the shell leaves would show as a cut line. On a landscape tablet the
  /// floating navigation covers the bottom 100 px, so the content scrolls
  /// under it and ends clear of it (3K-9).
  double get webPageBottomInset => switch (webTier) {
        WebLayoutTier.desktop => 44,
        WebLayoutTier.tabletLandscape => 100,
        _ => 0,
      };
}
