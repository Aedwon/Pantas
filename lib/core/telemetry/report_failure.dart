import 'dart:async';

import 'package:pantas/core/telemetry/telemetry.dart';

/// Reports a failure a screen otherwise swallows, so it reaches client
/// telemetry with [where] as its tag, for example `quiz.write`.
///
/// The report carries the original error type and message in text, behind the
/// tag. The existing scrubbing in the telemetry seam still runs on it, and the
/// stack is trimmed there. Nothing is added: no ids, no answers, no notes.
/// Never throws, and never changes what the student sees.
void reportFailure(
  Telemetry telemetry,
  String where,
  Object error,
  StackTrace stack,
) {
  try {
    unawaited(
      telemetry.recordError(_TaggedFailure(where, error), stack).catchError(
            (Object _) {},
          ),
    );
  } on Object {
    // Reporting a problem must never cause one.
  }
}

class _TaggedFailure implements Exception {
  const _TaggedFailure(this.where, this.error);
  final String where;
  final Object error;

  @override
  String toString() => '$where: ${error.runtimeType}: $error';
}
