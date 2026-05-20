import 'package:cse_cet_reviewer/core/auth/auth.dart';
import 'package:cse_cet_reviewer/core/telemetry/crash_reporting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CrashReporter clears user id for signedOut', () async {
    final sink = RecordingCrashReportingSink();
    final reporter = CrashReporter(sink);

    await reporter.applyAuthState(const AuthState.signedOut());

    expect(sink.userIds, ['']);
  });

  test('CrashReporter sets anonymous uid and named uid without email',
      () async {
    final sink = RecordingCrashReportingSink();
    final reporter = CrashReporter(sink);

    await reporter.applyAuthState(const AuthState.anonymous(uid: 'anon-1'));
    await reporter.applyAuthState(
      const AuthState.signedIn(
        user: AuthUser(
          uid: 'user-1',
          email: 'reader@example.com',
          displayName: 'Reader',
        ),
      ),
    );

    expect(sink.userIds, ['anon-1', 'user-1']);
  });
}

class RecordingCrashReportingSink implements CrashReportingSink {
  final userIds = <String>[];

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userIds.add(identifier);
  }
}
