import 'package:pantas/core/auth/auth.dart';

// ignore: one_member_abstracts
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
