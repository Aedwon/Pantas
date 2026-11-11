import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/data/study_read_cache.dart';

Map<String, Object?> suppressExpiredStudyAccess(
  Map<String, Object?> value,
  Duration elapsed,
) {
  final deadline = value['accessRecheckAt'];
  final now = value['serverNow'];
  if (value['proCovered'] != true ||
      deadline is! num ||
      now is! num ||
      deadline > now + elapsed.inMilliseconds) {
    return value;
  }
  final public = Map<String, Object?>.of(value)
    ..['proCovered'] = false
    ..removeWhere(
      (key, _) => const {
        'comingUp',
        'history',
        'tendencies',
        'whenYouWork',
        'trialEndsAt',
      }.contains(key),
    );
  final performance = public['performance'];
  if (performance is Map) {
    public['performance'] =
        Map<String, Object?>.from(performance.cast<String, Object?>())
          ..removeWhere(
            (key, _) =>
                key == 'topics' || key == 'lessons' || key == 'topicDetails',
          );
  }
  return Map.unmodifiable(public);
}

class StudySnapshotReader {
  const StudySnapshotReader({
    required this.request,
    required this.cache,
    this.beforeRead,
    this.recordError,
  });
  final StudyRequest request;
  final StudyReadCache cache;
  final Future<void> Function()? beforeRead;
  final Future<void> Function(Object, StackTrace)? recordError;
  Stream<Map<String, Object?>> read(String kind) async* {
    final cached = await cache.read(kind);
    if (cached != null) yield cached;
    final elapsed = Stopwatch()..start();
    try {
      try {
        await beforeRead?.call();
      } catch (error, stack) {
        await recordError?.call(error, stack);
        if (!await request.isCurrent()) rethrow;
      }
      final current = await request.read(kind);
      final safe = suppressExpiredStudyAccess(current, elapsed.elapsed);
      await cache.write(kind, current);
      if (!await request.isCurrent()) throw StateError('Study owner changed');
      yield safe;
    } on FirebaseFunctionsException catch (error) {
      if (cached == null ||
          !const {'unavailable', 'deadline-exceeded'}.contains(error.code)) {
        rethrow;
      }
    }
  }
}
