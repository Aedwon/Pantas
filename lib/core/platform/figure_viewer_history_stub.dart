import 'package:flutter/widgets.dart';

/// Native builds have no browser history.
VoidCallback? openViewerHistoryEntry(VoidCallback onBack) => null;
