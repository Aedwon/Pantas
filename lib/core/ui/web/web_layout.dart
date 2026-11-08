import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';

/// Width tiers of the web app (design system TabletLayout, D136). Breakpoints
/// come from `PantasLayout`.
///
/// - `phone`: under `bpTabletPortrait` (600). TabBar.
/// - `tabletPortrait`: 600 up to `bpTabletLandscape` (1024). TabBar, with the
///   page in the centered tablet column.
/// - `compact`: 1024 up to `bpWide` (1440). The sidebar at its minimum width
///   and 32 px main sides.
/// - `wide`: from `bpWide`. The full sidebar and 44 px main sides.
enum WebLayoutTier { phone, tabletPortrait, compact, wide }

WebLayoutTier webLayoutTier({required double width, bool web = kIsWeb}) {
  if (!web || width < PantasLayout.bpTabletPortrait) return WebLayoutTier.phone;
  if (width < PantasLayout.bpTabletLandscape) {
    return WebLayoutTier.tabletPortrait;
  }
  if (width < PantasLayout.bpWide) return WebLayoutTier.compact;
  return WebLayoutTier.wide;
}

/// Desktop content and the sidebar start together, at 1024.
bool isWideWebLayout({required double width, bool web = kIsWeb}) =>
    webLayoutTier(width: width, web: web).index >= WebLayoutTier.compact.index;

/// Overrides only the platform input for native widget tests.
@visibleForTesting
bool? debugWebPlatformOverride;

extension WebLayoutContext on BuildContext {
  bool get webPlatform => debugWebPlatformOverride ?? kIsWeb;
  WebLayoutTier get webTier => webLayoutTier(
        width: MediaQuery.sizeOf(this).width,
        web: webPlatform,
      );
  bool get wideWeb => webTier.index >= WebLayoutTier.compact.index;

  /// The page's scrolling content ends with `layout-main-pad-bottom` (44),
  /// not the window: the shell stops at the window bottom, so rows scroll to
  /// the edge and the last one rests this far above it. The Navigator under
  /// the shell clips hard at its own box, so padding the shell leaves would
  /// show as a cut line. Below 1024 the TabBar reserve covers this instead.
  double get webPageBottomInset => wideWeb ? PantasLayout.mainPadBottom : 0;
}
