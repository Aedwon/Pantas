import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';

/// Reply of `getSessionDiagnosis`: `{status: 'ok' | 'pending', tier,
/// tracedCount}`; Pro replies add `traced` and `withinLesson`. Free results
/// keep only the count, even if a reply includes detail.
final class SessionDiagnosisData {
  const SessionDiagnosisData._(this.tracedCount, this.detail);

  final int tracedCount;
  final Map<String, Object?>? detail;

  static SessionDiagnosisData? decode(Map<String, Object?> json) {
    if (json['status'] == 'pending') return null;
    final count = json['tracedCount'];
    final tier = json['tier'];
    if (json['status'] != 'ok' ||
        count is! int ||
        count < 0 ||
        (tier != 'free' && tier != 'pro')) {
      throw const FormatException('Invalid diagnosis response');
    }
    return SessionDiagnosisData._(
      count,
      tier == 'pro'
          ? Map<String, Object?>.unmodifiable({
              'traced': _groups(json['traced']),
              'withinLesson': _groups(json['withinLesson']),
            })
          : null,
    );
  }

  static List<Map<String, Object?>> _groups(Object? value) {
    if (value is! List) {
      throw const FormatException('Invalid diagnosis detail');
    }
    return List.unmodifiable([
      for (final row in value)
        if (row is Map)
          Map<String, Object?>.unmodifiable(row.cast<String, Object?>())
        else
          throw const FormatException('Invalid diagnosis group'),
    ]);
  }
}

final class SessionDiagnosisApi {
  SessionDiagnosisApi(this.request, {this.wait = Future<void>.delayed});

  final StudyRequest request;
  final Future<void> Function(Duration) wait;

  Future<SessionDiagnosisData?> read(String sessionId) async {
    try {
      for (var attempt = 0; attempt < 2; attempt++) {
        final raw = await request.read(
          'getSessionDiagnosis',
          payload: {'sessionId': sessionId},
        );
        final result = SessionDiagnosisData.decode(raw);
        if (result != null) return result;
        if (attempt == 0) await wait(const Duration(seconds: 3));
      }
    } catch (_) {
      // A failed diagnosis has the same presentation as no diagnosis. Do not
      // log the response or exception: either can contain protected detail.
      return null;
    }
    return null;
  }
}

final sessionDiagnosisProvider = FutureProvider.autoDispose
    .family<SessionDiagnosisData?, String>((ref, sessionId) async {
  if (!ref.watch(studyUsesServerProvider)) return null;
  try {
    final exam = (await ref.watch(activeExamFocusProvider.future)).exam;
    if (exam == null) return null;
    final reader = await ref.watch(studySnapshotReaderProvider(exam.id).future);
    // Use the guarded request directly. Diagnosis detail is never cached.
    return await SessionDiagnosisApi(reader.request).read(sessionId);
  } catch (_) {
    return null;
  }
});
