import 'package:flutter/widgets.dart';

/// True while a sheet that covers the phone tab bar is open. The Bookmarks
/// sheet on Study hides the bar, as the BM_Open board does.
final ValueNotifier<bool> phoneTabBarHidden = ValueNotifier<bool>(false);

/// Marks the pages the shell draws under the phone's floating tab bar.
///
/// The shell publishes the space the bar covers as the bottom
/// `MediaQuery.padding`. That is not a safe area to keep content out of: the
/// bar floats, so lists scroll under it. A page inside this scope leaves that
/// padding for its scrolling content to use (see [clearance]) instead of
/// cutting the screen short above the bar.
class FloatingTabBarScope extends InheritedWidget {
  const FloatingTabBarScope({required super.child, super.key});

  /// QZ_Tab and ST_Root keep 104 px under their content for the bar. The bar
  /// and the gap under it cover 88, so 16 px is the room above the bar.
  static const double gapAboveBar = 16;

  /// Whether [context] sits under the floating tab bar.
  static bool of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<FloatingTabBarScope>() != null;

  /// How much room scrolling content leaves at its bottom so the last row can
  /// scroll clear of the bar. Outside the scope it is [minimum]. Inside, it is
  /// the bar's space plus [gapAboveBar], or [minimum] when that is larger.
  static double clearance(BuildContext context, {double minimum = 0}) {
    if (!of(context)) return minimum;
    final underBar = MediaQuery.paddingOf(context).bottom + gapAboveBar;
    return underBar > minimum ? underBar : minimum;
  }

  @override
  bool updateShouldNotify(FloatingTabBarScope oldWidget) => false;
}
