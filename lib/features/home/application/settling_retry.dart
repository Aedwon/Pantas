import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// A failure that only says the app has not finished starting: the account,
/// the exam or the settings are still arriving, or a provider was replaced
/// while a read was in flight. Reading again a moment later succeeds, so a
/// screen holds its skeleton and retries instead of showing an error.
///
/// Matching is by message because the guards that raise these live in shared
/// code and throw plain `StateError`s. The test pins every message.
bool isSettlingFailure(Object error) {
  if (error is FirebaseFunctionsException) {
    return switch (error.code) {
      'unavailable' || 'deadline-exceeded' || 'unauthenticated' => true,
      // The exam settings are still on their way to the server.
      'failed-precondition' => error.message == 'Set your exam first.',
      _ => false,
    };
  }
  if (error is! StateError) return false;
  final message = error.message;
  return _settlingMessages.any(message.contains);
}

const _settlingMessages = <String>[
  // The owner guards: the account, exam or sync context moved under a read.
  'owner changed',
  'owner unavailable',
  'account is unavailable',
  'account changed',
  'account unavailable',
  'controller is unavailable',
  'Study exam changed',
  'exam unavailable',
  // Riverpod dropped a provider that was still loading.
  'disposed during loading state',
  'Cannot call onDispose after a provider was dispose',
];

/// Retries a screen's failed first read while the failure is only the app
/// settling. [failed] says whether the failure is held, meaning a retry is
/// coming and the screen must still look like it is loading. After
/// [delays] runs out the failure is real and is shown.
class SettlingRetry {
  SettlingRetry({
    required this.retry,
    this.delays = const [
      Duration(milliseconds: 150),
      Duration(milliseconds: 300),
      Duration(milliseconds: 600),
      Duration(milliseconds: 1200),
      Duration(milliseconds: 2000),
      Duration(milliseconds: 3000),
    ],
  });

  final VoidCallback retry;
  final List<Duration> delays;
  int _failures = 0;
  Timer? _timer;

  bool failed(Object error) {
    if (!isSettlingFailure(error) || _failures >= delays.length) return false;
    _timer?.cancel();
    _timer = Timer(delays[_failures++], retry);
    return true;
  }

  /// A read finished, or the student pressed Try Again: start counting anew.
  void reset() {
    _failures = 0;
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => _timer?.cancel();
}
