import 'package:pantas/core/ui/ds.dart';

/// Scrolling without scroll bars, on every platform and layout.
///
/// The default behavior wraps vertical scrollables in a `Scrollbar` on macOS,
/// Windows and Linux, which is why a desktop browser shows bars and a phone
/// does not. This keeps everything else the default does (drag devices,
/// overscroll, physics), so mouse drag is not added.
class NoScrollBarsBehavior extends MaterialScrollBehavior {
  const NoScrollBarsBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}
