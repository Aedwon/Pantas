import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/platform/figure_viewer_history_stub.dart'
    if (dart.library.js_interop) 'package:pantas/core/platform/figure_viewer_history_web.dart'
    as browser;

/// Gives the open figure viewer a browser history entry of its own.
///
/// A page opened as a fresh load has no earlier page of the app behind it, so
/// browser Back left the app and the viewer with it (6U-5). With an entry for
/// the viewer, Back removes that entry first and calls `onBack`, which closes
/// the viewer. The result releases the entry when the viewer closes another
/// way; it is null where there is no browser history.
typedef ViewerHistoryOpener = VoidCallback? Function(VoidCallback onBack);

final figureViewerHistoryProvider = Provider<ViewerHistoryOpener>(
  (ref) => browser.openViewerHistoryEntry,
);

/// Opens the viewer's entry through the surrounding provider scope, or the
/// browser's own when there is none (a bare widget test).
VoidCallback? openFigureViewerHistory(
  BuildContext context,
  VoidCallback onBack,
) {
  final container = context
      .getInheritedWidgetOfExactType<UncontrolledProviderScope>()
      ?.container;
  final open = container?.read(figureViewerHistoryProvider) ??
      browser.openViewerHistoryEntry;
  return open(onBack);
}
