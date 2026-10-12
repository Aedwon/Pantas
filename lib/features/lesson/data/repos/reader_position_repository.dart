import 'package:pantas/core/storage/storage.dart';

/// Reading position is local to this device, like the recently opened list.
class ReaderPositionRepository {
  ReaderPositionRepository(this.preferences);
  final AppPreferencesRepository preferences;
  Future<double> read(String examId, String lessonId) async {
    final raw =
        await preferences.deviceValue('lesson_offset.$examId.$lessonId');
    final value = double.tryParse(raw ?? '');
    return value != null && value.isFinite && value >= 0 ? value : 0;
  }

  Future<void> write(String examId, String lessonId, double offset) =>
      preferences.setDeviceValue(
        'lesson_offset.$examId.$lessonId',
        offset.toString(),
      );
}
