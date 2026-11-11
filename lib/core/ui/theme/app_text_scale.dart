import 'package:flutter/widgets.dart';

/// The most the UI text follows the OS text size (design system, Text
/// scaling: "UI text follows the OS text size up to 2.0").
const double maxUiTextScale = 2;

/// The OS text scaler, captured at the app root before the UI clamp.
///
/// The reader and the quiz question column read this value, never the
/// clamped `MediaQuery` one, so lesson text keeps the full OS size and the
/// lesson scale multiplies it (D190 item 11). It is an inherited value, so it
/// also reaches Sheets and Drawers that mount outside the page root.
class OsTextScaler extends InheritedWidget {
  const OsTextScaler({required this.scaler, required super.child, super.key});

  final TextScaler scaler;

  /// The captured OS scaler. Without an [AppTextScale] above (a unit test of
  /// one widget) it is the ambient `MediaQuery` scaler.
  static TextScaler of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<OsTextScaler>();
    return inherited?.scaler ?? MediaQuery.textScalerOf(context);
  }

  @override
  bool updateShouldNotify(OsTextScaler oldWidget) => scaler != oldWidget.scaler;
}

/// App root: keeps the OS scaler for the reader and clamps the UI scaler to
/// [maxUiTextScale].
class AppTextScale extends StatelessWidget {
  const AppTextScale({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final os = media.textScaler;
    return OsTextScaler(
      scaler: os,
      child: MediaQuery(
        data: media.copyWith(
          textScaler: os.clamp(maxScaleFactor: maxUiTextScale),
        ),
        child: child,
      ),
    );
  }
}
