import 'dart:async';

import 'package:flutter/foundation.dart';

/// Installs the three collectors and runs [body] inside a guarded zone.
///
/// Flutter throws in three places and catching only one is the usual mistake:
/// inside the widget framework, outside it, and asynchronously. All three
/// funnel into the single [onError], so this file knows nothing about where a
/// report eventually goes.
///
/// Before this existed, `lib/` caught none of the three. An uncaught exception
/// showed a student the framework error screen and nobody was ever told.
Future<void> runGuarded(
  Future<void> Function() body, {
  required void Function(Object error, StackTrace stack) onError,
}) async {
  // 1. Inside the widget framework.
  FlutterError.onError = (details) {
    // `stack` is nullable here. Dropping the report when it is absent would
    // lose the error entirely, so fall back to an empty trace.
    onError(details.exception, details.stack ?? StackTrace.empty);
  };

  // 2. Outside it. Returning true claims the error, which stops the platform
  // printing it again on top of whatever the reporter does with it.
  PlatformDispatcher.instance.onError = (error, stack) {
    onError(error, stack);
    return true;
  };

  // 3. Asynchronous errors that escape both.
  final completer = Completer<void>();
  // The zone's return value is discarded on purpose: the guarded body may die
  // asynchronously, and `completer` is what releases the caller either way.
  unawaited(
    runZonedGuarded(
      () async {
        try {
          await body();
        } finally {
          if (!completer.isCompleted) completer.complete();
        }
      },
      (error, stack) {
        onError(error, stack);
        // An async error must not strand the caller: if the body died before
        // completing, release the await rather than hanging the app at startup.
        if (!completer.isCompleted) completer.complete();
      },
    ),
  );

  return completer.future;
}
