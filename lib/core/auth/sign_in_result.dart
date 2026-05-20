sealed class SignInResult {
  const SignInResult();

  const factory SignInResult.linkedExisting() = LinkedExistingSignInResult;

  const factory SignInResult.switchedToExisting({
    required bool meaningfulCloudData,
    required bool meaningfulLocalData,
  }) = SwitchedToExistingSignInResult;

  const factory SignInResult.cancelled() = CancelledSignInResult;

  const factory SignInResult.failed({required String reason}) =
      FailedSignInResult;
}

class LinkedExistingSignInResult extends SignInResult {
  const LinkedExistingSignInResult();
}

class SwitchedToExistingSignInResult extends SignInResult {
  const SwitchedToExistingSignInResult({
    required this.meaningfulCloudData,
    required this.meaningfulLocalData,
  });

  final bool meaningfulCloudData;
  final bool meaningfulLocalData;
}

class CancelledSignInResult extends SignInResult {
  const CancelledSignInResult();
}

class FailedSignInResult extends SignInResult {
  const FailedSignInResult({required this.reason});

  final String reason;
}
