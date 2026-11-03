import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';

/// The lesson column on wide web is 680 px by default.
const double readerStandardWidth = 680;

/// The widest the column grows when the student turns full width on.
///
/// About 97 characters a line at the default text size, inside the range the
/// line-length studies tested. Aedwon chose 800 px from the preview.
const double readerFullWidthMax = 800;

/// Whether the student widened the wide web lesson column, remembered on this
/// device the way the lesson text size is.
final readerFullWidthProvider =
    StateNotifierProvider<ReaderFullWidthController, bool>((ref) {
  return ReaderFullWidthController(
    ref.watch(appPreferencesRepositoryProvider),
  );
});

class ReaderFullWidthController extends StateNotifier<bool> {
  ReaderFullWidthController(this._preferences) : super(false) {
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
      if (mounted && revision == _revision && raw == '1') state = true;
    } on Exception {
      // An unavailable preference keeps the standard width.
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
