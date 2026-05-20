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

  @override
  bool operator ==(Object other) => other is LinkedExistingSignInResult;

  @override
  int get hashCode => Object.hash(LinkedExistingSignInResult, 0);
}

class SwitchedToExistingSignInResult extends SignInResult {
  const SwitchedToExistingSignInResult({
    required this.meaningfulCloudData,
    required this.meaningfulLocalData,
  });

  final bool meaningfulCloudData;
  final bool meaningfulLocalData;

  @override
  bool operator ==(Object other) {
    return other is SwitchedToExistingSignInResult &&
        other.meaningfulCloudData == meaningfulCloudData &&
        other.meaningfulLocalData == meaningfulLocalData;
  }

  @override
  int get hashCode {
    return Object.hash(
      SwitchedToExistingSignInResult,
      meaningfulCloudData,
      meaningfulLocalData,
    );
  }
}

class CancelledSignInResult extends SignInResult {
  const CancelledSignInResult();

  @override
  bool operator ==(Object other) => other is CancelledSignInResult;

  @override
  int get hashCode => Object.hash(CancelledSignInResult, 0);
}

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
