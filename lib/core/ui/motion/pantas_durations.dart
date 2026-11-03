/// The small shared duration table from the Nov 3 motion preview (item 17).
///
/// New motion takes its time from here so the app keeps one rhythm. Existing
/// literals are not swept onto it; each later item moves the ones it touches.
///
/// Curves: movement uses `PantasCurves.shared`, fades use `PantasCurves.ease`.
abstract final class PantasDurations {
  /// Press down on tiles, chips and buttons. Curve: shared.
  static const tap = Duration(milliseconds: 120);

  /// Color and tint fades on rows, chips and labels. Curve: ease.
  static const quick = Duration(milliseconds: 160);

  /// Sliding markers, thumbs, view changes, detail panes and the legal fade.
  /// Curve: shared for movement, ease for a fade.
  static const base = Duration(milliseconds: 240);

  /// Opening a lesson. Curve: shared.
  static const page = Duration(milliseconds: 320);
}
