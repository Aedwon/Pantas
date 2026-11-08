import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';

/// Width tiers of the web app. Breakpoints come from `PantasLayout`.
///
/// - `phone`: under `bpTabletPortrait` (600).
/// - `tabletPortrait`: 600 up to `bpTabletLandscape` (1024).
/// - `tabletLandscape`: 1024 up to the sidebar start (see below).
/// - `desktop`: from the sidebar start.
///
/// Design system D136 starts the sidebar at `bpTabletLandscape` (1024), with
/// a compact layout up to `bpWide` - 1 (1439) and the full layout from
/// `bpWide` (1440). The shell still starts it at 1280, so family C (shell and
/// navigation) moves [_sidebarFromWidth] to 1024, adds the compact and full
/// split and retires `tabletLandscape`.
enum WebLayoutTier { phone, tabletPortrait, tabletLandscape, desktop }

// LEGACY: remove in family C. The width where the sidebar starts today.
const double _sidebarFromWidth = 1280;

WebLayoutTier webLayoutTier({required double width, bool web = kIsWeb}) {
  if (!web || width < PantasLayout.bpTabletPortrait) return WebLayoutTier.phone;
  if (width < PantasLayout.bpTabletLandscape) {
    return WebLayoutTier.tabletPortrait;
  }
  if (width < _sidebarFromWidth) return WebLayoutTier.tabletLandscape;
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
