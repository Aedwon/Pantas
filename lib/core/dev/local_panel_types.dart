/// The two edges of the local test panel bridge that need a browser, so tests
/// can replace them. See `local_panel_bridge.dart`.
library;

/// The channel the panel page and the app tab talk over. The panel sends
/// JSON text and so does the app.
abstract interface class LocalPanelChannel {
  /// Messages from the panel, already decoded. Anything that is not a JSON
  /// object is dropped.
  Stream<Map<String, Object?>> get messages;

  void send(Map<String, Object?> message);

  void close();
}

/// The page the app runs in.
abstract interface class LocalPanelPage {
  /// Reads a `localStorage` value and removes it, so it is used once.
  String? takeStored(String key);

  /// Opens [url] in this tab.
  void navigate(String url);
}
