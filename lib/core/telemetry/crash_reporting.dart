import 'package:cse_cet_reviewer/core/auth/auth.dart';

abstract interface class CrashReportingSink {
  Future<void> setUserIdentifier(String identifier);
}

class CrashReporter {
  const CrashReporter(this._sink);

  final CrashReportingSink _sink;

  Future<void> applyAuthState(AuthState state) async {
    final identifier = switch (state) {
      AnonymousAuthState(:final uid) => uid,
      SignedInAuthState(:final user) => user.uid,
      UnknownAuthState() || SignedOutAuthState() => '',
    };
    await _sink.setUserIdentifier(identifier);
  }
}
