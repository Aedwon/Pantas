import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';

final lessonTextScaleProvider =
    StateNotifierProvider<LessonTextScaleController, double>((ref) {
  return LessonTextScaleController(ref.watch(appPreferencesRepositoryProvider));
});

class LessonTextScaleController extends StateNotifier<double> {
  LessonTextScaleController(this._preferences) : super(1.0) {
    unawaited(_load());
  }

  static const _key = 'lesson_text_scale';
  final AppPreferencesRepository _preferences;
  int _revision = 0;
  Future<void> _writes = Future<void>.value();

  Future<void> _load() async {
    final revision = _revision;
    try {
      final raw = await _preferences.deviceValue(_key);
      final saved = double.tryParse(raw ?? '');
      if (mounted &&
          revision == _revision &&
          saved != null &&
          saved.isFinite &&
          saved > 0) {
        state = saved;
      }
    } on Exception {
      // An unavailable preference keeps the readable default.
    }
  }

  Future<void> setScale(double scale) async {
    if (!scale.isFinite || scale <= 0) {
      throw ArgumentError.value(scale, 'scale', 'Must be finite and positive');
    }
    final revision = ++_revision;
    final write = _writes
        .then((_) => _preferences.setDeviceValue(_key, scale.toString()));
    // Slider updates keep their write order. Each caller still sees its error.
    _writes = write.catchError((Object _) {});
    await write;
    if (mounted && revision == _revision) state = scale;
  }
}

/// Applies the lesson preference without changing controls outside this subtree.
class LessonTextScale extends ConsumerWidget {
  const LessonTextScale({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factor = ref.watch(lessonTextScaleProvider);
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(textScaler: _LessonScaler(media.textScaler, factor)),
      child: child,
    );
  }
}

class _LessonScaler extends TextScaler {
  const _LessonScaler(this.phone, this.factor);

  final TextScaler phone;
  final double factor;

  @override
  double scale(double fontSize) => phone.scale(fontSize) * factor;

  @override
  double get textScaleFactor => scale(14) / 14;
}
