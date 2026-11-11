import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/platform/callable_options.dart';

typedef StudyCallable = Future<Object?> Function(
  String name,
  Map<String, Object?> data,
);

/// Every request retains the original authenticated owner in its payload.
/// The server compares this expectation with the actual token at dispatch.
class StudyApi {
  const StudyApi(this.call);
  factory StudyApi.firebase() => StudyApi(
        (name, data) async =>
            (await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
                    .httpsCallable(name, options: callableOptionsFor(name))
                    .call<Object?>(data))
                .data,
      );
  final StudyCallable call;

  Future<Map<String, Object?>> request(
    String name, {
    required String expectedUid,
    required String examId,
    Map<String, Object?> payload = const {},
  }) async {
    if (expectedUid.isEmpty ||
        examId.isEmpty ||
        payload.containsKey('expectedUid') ||
        payload.containsKey('examId')) {
      throw ArgumentError('Original account and exam are required');
    }
    final data = Map<String, Object?>.unmodifiable({
      ...payload,
      'expectedUid': expectedUid,
      'examId': examId,
    });
    final result = await call(name, data);
    if (result is! Map) throw const FormatException('Invalid study response');
    return Map<String, Object?>.unmodifiable(result.cast<String, Object?>());
  }
}

class StudyRequest {
  const StudyRequest({
    required this.api,
    required this.uid,
    required this.examId,
    required this.isCurrent,
    this.recoverMissingSettings,
  });
  final StudyApi api;
  final String uid;
  final String examId;
  final Future<bool> Function() isCurrent;
  final Future<bool> Function()? recoverMissingSettings;
  Future<Map<String, Object?>> read(
    String name, {
    Map<String, Object?> payload = const {},
  }) async {
    if (!await isCurrent()) throw StateError('Study owner changed');
    Future<Map<String, Object?>> send() => api.request(
          name,
          expectedUid: uid,
          examId: examId,
          payload: payload,
        );
    Map<String, Object?> result;
    try {
      result = await send();
    } on FirebaseFunctionsException catch (error) {
      if (error.code != 'failed-precondition' ||
          error.message != 'Set your exam first.' ||
          recoverMissingSettings == null ||
          !await isCurrent() ||
          !await recoverMissingSettings!()) {
        rethrow;
      }
      if (!await isCurrent()) throw StateError('Study owner changed');
      // Retry outside the catch: a second no-settings response cannot loop.
      result = await send();
    }
    if (!await isCurrent()) throw StateError('Study owner changed');
    return result;
  }
}
