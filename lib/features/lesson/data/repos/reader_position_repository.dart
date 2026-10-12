import 'dart:convert';

import 'package:pantas/core/storage/storage.dart';

/// Device-local position. Offset and fraction share one preference write.
class ReaderPositionRepository {
  ReaderPositionRepository(this.preferences);
  final AppPreferencesRepository preferences;
  Future<void> _writes = Future<void>.value();

  String _key(String examId, String lessonId) =>
      'lesson_offset.$examId.$lessonId';

  Future<({double offset, double? fraction})> _read(
    String examId,
    String lessonId,
  ) async {
    final raw = await preferences.deviceValue(_key(examId, lessonId));
    final legacy = double.tryParse(raw ?? '');
    if (legacy != null) {
      return (
        offset: legacy.isFinite && legacy >= 0 ? legacy : 0.0,
        fraction: null
      );
    }
    try {
      final decoded = jsonDecode(raw ?? 'null');
      if (decoded is Map<String, Object?>) {
        final offset = decoded['offset'];
        final fraction = decoded['fraction'];
        return (
          offset: offset is num && offset.isFinite && offset >= 0
              ? offset.toDouble()
              : 0.0,
          fraction: fraction is num &&
                  fraction.isFinite &&
                  fraction >= 0 &&
                  fraction <= 1
              ? fraction.toDouble()
              : null,
        );
      }
    } on FormatException {
      // A damaged value cannot supply a reading position or ring fraction.
    }
    return (offset: 0.0, fraction: null);
  }

  Future<double> read(String examId, String lessonId) async {
    await _writes;
    return (await _read(examId, lessonId)).offset;
  }

  /// Null means no measured fraction, so the consumer draws an empty ring.
  Future<double?> readFraction(String examId, String lessonId) async {
    await _writes;
    return (await _read(examId, lessonId)).fraction;
  }

  void _validateFraction(double fraction) {
    if (!fraction.isFinite || fraction < 0 || fraction > 1) {
      throw ArgumentError.value(fraction, 'fraction', 'Must be from 0 to 1');
    }
  }

  Future<void> _queue(Future<void> Function() operation) {
    final write = _writes.then((_) => operation());
    _writes = write.catchError((Object _) {});
    return write;
  }

  /// Keeps an existing offset, including the older scalar format.
  Future<void> writeFraction(
    String examId,
    String lessonId,
    double fraction,
  ) async {
    _validateFraction(fraction);
    return _queue(() async {
      final position = await _read(examId, lessonId);
      await preferences.setDeviceValue(
        _key(examId, lessonId),
        jsonEncode({'offset': position.offset, 'fraction': fraction}),
      );
    });
  }

  Future<void> write(
    String examId,
    String lessonId,
    double offset, {
    double? fraction,
  }) async {
    if (!offset.isFinite || offset < 0) {
      throw ArgumentError.value(
        offset,
        'offset',
        'Must be finite and positive',
      );
    }
    if (fraction != null) _validateFraction(fraction);
    return _queue(
      () => preferences.setDeviceValue(
        _key(examId, lessonId),
        jsonEncode(
          {'offset': offset, if (fraction != null) 'fraction': fraction},
        ),
      ),
    );
  }
}
