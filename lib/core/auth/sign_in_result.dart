import 'package:meta/meta.dart';

@immutable
sealed class SignInResult {
  const SignInResult();

  const factory SignInResult.linkedExisting() = LinkedExistingSignInResult;

  const factory SignInResult.switchedToExisting() =
      SwitchedToExistingSignInResult;

  const factory SignInResult.cancelled() = CancelledSignInResult;

  const factory SignInResult.failed({required String reason}) =
      FailedSignInResult;
}

@immutable
class LinkedExistingSignInResult extends SignInResult {
  const LinkedExistingSignInResult();

  @override
  bool operator ==(Object other) => other is LinkedExistingSignInResult;

  @override
  int get hashCode => Object.hash(LinkedExistingSignInResult, 0);
}

@immutable
class SwitchedToExistingSignInResult extends SignInResult {
  const SwitchedToExistingSignInResult();

  @override
  bool operator ==(Object other) => other is SwitchedToExistingSignInResult;

  @override
  int get hashCode => Object.hash(SwitchedToExistingSignInResult, 0);
}

@immutable
class CancelledSignInResult extends SignInResult {
  const CancelledSignInResult();

  @override
  bool operator ==(Object other) => other is CancelledSignInResult;

  @override
  int get hashCode => Object.hash(CancelledSignInResult, 0);
}

@immutable
class FailedSignInResult extends SignInResult {
  const FailedSignInResult({required this.reason});

  final String reason;

  @override
  bool operator ==(Object other) {
    return other is FailedSignInResult && other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(FailedSignInResult, reason);
}
