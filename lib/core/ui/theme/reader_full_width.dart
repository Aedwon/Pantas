import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';

/// The lesson column on wide web is 680 px with full width off.
const double readerStandardWidth = 680;

/// The reader's body text size with full width off, in px.
const double readerBaseTextSize = 18;

/// Immersion (full width on, 1024 px and up): the body text size for a window
/// [width] wide. It grows with the window from 20 px to 25 px.
double immersionBodySize(double width) => (width / 60).clamp(20.0, 25.0);

/// Immersion: the one centered column, 33 times the body text size (about 72
/// characters of Geist a line), and never wider than the window less 56 px on
/// each side.
double immersionColumnWidth(double width) =>
    math.min(33 * immersionBodySize(width), width - 2 * 56);

/// Tells the lesson below it that it is drawn in Immersion at [bodySize] px.
///
/// The lesson text scale multiplies every reader type size by
/// `bodySize / 18`, and a figure stops at 65% of the window height.
class ReaderImmersion extends InheritedWidget {
  const ReaderImmersion({
    required this.bodySize,
    required super.child,
    super.key,
  });

  final double bodySize;

  /// What the reader's type sizes are multiplied by.
  double get scale => bodySize / readerBaseTextSize;

  static ReaderImmersion? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ReaderImmersion>();

  @override
  bool updateShouldNotify(ReaderImmersion oldWidget) =>
      bodySize != oldWidget.bodySize;
}

/// The student's saved full width choice, remembered on this device the way
/// the lesson text size is. Null means no choice is saved, and full width is
/// on (Aedwon, Nov 29: on for every lesson). A saved choice wins.
final readerFullWidthProvider =
    StateNotifierProvider<ReaderFullWidthController, bool?>((ref) {
  return ReaderFullWidthController(
    ref.watch(appPreferencesRepositoryProvider),
  );
});

class ReaderFullWidthController extends StateNotifier<bool?> {
  ReaderFullWidthController(this._preferences) : super(null) {
    unawaited(_load());
  }

  static const _key = 'reader_full_width';
  final AppPreferencesRepository _preferences;
  int _revision = 0;
  Future<void> _writes = Future<void>.value();

  Future<void> _load() async {
    final revision = _revision;
    try {
      final raw = await _preferences.deviceValue(_key);
      if (mounted && revision == _revision && (raw == '0' || raw == '1')) {
        state = raw == '1';
      }
    } on Exception {
      // An unavailable preference counts as no saved choice.
    }
  }

  /// Applies the choice at once, then saves it. If the save fails the choice
  /// still holds for this session and the caller sees the error.
  Future<void> setFullWidth({required bool fullWidth}) async {
    _revision++;
    state = fullWidth;
    final write = _writes.then(
      (_) => _preferences.setDeviceValue(_key, fullWidth ? '1' : '0'),
    );
    // Writes keep their order. Each caller still sees its own error.
    _writes = write.catchError((Object _) {});
    await write;
  }
}
