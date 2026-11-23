/// Fixed wording and versions for the parent-held child setup screens
/// (under-13 boards 1A, 2, 2A, 7). Text comes from the signed-off legal draft,
/// section 4 and section 7.
abstract final class ChildSetupCopy {
  // Board 1A, the under-13 screen.
  static const underThirteenTitle =
      'Ask a parent or guardian to set up Pantas for you';
  static const underThirteenBody =
      'Pantas needs a parent or guardian to set up your account. They sign in '
      'with their own email. Then you can study with a nickname.';
  static const underThirteenNotice = 'What a Parent or Guardian Agrees To';
  static const underThirteenGuardian = "I'm the Parent or Guardian";

  /// Decision 9 item 9: the server keeps setup closed, so the screen drops
  /// the guardian button and says so.
  static const closedTitle = 'Pantas is for ages 13 and up for now';

  // Board 2, parent signs in.
  static const signInTitle = 'Sign in as the parent or guardian';
  static const signInLead = "Use your own email, not your child's. One email "
      'can hold up to 5 children.';
  static const continueWithEmail = 'Continue with Email';
  static const continueWithGoogle = 'Continue with Google';

  // Board 2A, parent setup.
  static const setupTitle = 'Set up Pantas for your child';
  static const setupLead = 'This sets up your first child. You can add more '
      'children later in Settings.';
  static const tick1Lead =
      'I am 18 or older and I am the parent or guardian with authority over '
      'this child. I accept the ';
  static const tick1Link = 'Terms';
  static const tick1Tail = " for myself and for my child's use of Pantas.";
  static const tick2Lead = "I consent to Pantas using my child's data as the ";
  static const tick2Link = 'Child Notice';
  static const tick2Tail = ' describes. I understand I can withdraw this '
      'consent at any time in "For parents."';
  static const setUpAccount = 'Set Up Account';
  static const useAnotherEmail = 'Use Another Email';

  // Plain messages for each refusal the server can give.
  static const emailHasAccount =
      'This email already has a Pantas account. Use another email.';
  static const childLimit = 'You have reached 5 children on this email. Email '
      'support@pantas.study if you need more.';
  static const staleConsentText = 'Reload to review the current terms.';
  static const namedSignInRequired =
      'Sign in with your email or Google to set up the account.';
  static const rateLimited = 'Too many tries. Try again later.';
  static const setupFailed = "We couldn't set up the account. Try again.";
  static const signInAgain = 'Sign In';

  // Board N2C, short child notice (legal draft, layer b).
  static const noticeTitle =
      'Hi. A parent or guardian is setting up Pantas for you.';
  static const noticeKeep = 'Pantas will keep your nickname, your answers and '
      'your scores so you can practice.';
  static const noticeConsent = 'Your parent or guardian says yes to this for '
      'you. They can say no later.';
  static const noticeMore = 'Want to know more? Tap "Read more for kids."';
  static const askParent = 'Ask My Parent or Guardian';
  static const readMore = 'Read More for Kids';

  // Board S7N, nickname step.
  static const nicknameTitle = 'Pick a nickname';
  static const nicknameLabel = "Child's nickname";
  static const nicknameHelp =
      'Not a real name. Pick a nickname your child will recognize.';
  static const nicknameContinue = 'Continue';
  static const nicknameFailed = "We couldn't save the nickname. Try again.";
}

/// The text versions the server checks at setup. Keep in step with
/// `GUARDIAN_TICK_TEXT_VERSIONS` and `CHILD_NOTICE_VERSION` in
/// `functions/src/guardianConsent.ts`.
abstract final class ChildSetupVersions {
  static const tick1 = '2026-11-20';
  static const tick2 = '2026-11-20';
  static const childNotice = '2026-11-20';
  static const siblingNotice = '2026-11-20';
}

/// Why the server refused setup, read from the callable's `reason`.
enum ChildSetupFailure {
  /// The email already holds an adult or teen account with progress.
  emailHasAccount,
  childLimit,
  staleConsentText,
  namedSignInRequired,

  /// Decision 9 item 9: setup is closed on this server.
  childAccountsClosed,
  rateLimited,
  other;

  /// The server's `reason` string for each refusal.
  static ChildSetupFailure fromReason(String? reason) => switch (reason) {
        'email-has-account' => emailHasAccount,
        'child-limit' => childLimit,
        'stale-consent-text' => staleConsentText,
        'named-sign-in-required' => namedSignInRequired,
        'child-accounts-closed' => childAccountsClosed,
        _ => other,
      };

  /// The plain message the setup screen shows. Closed has none: that screen
  /// is replaced.
  String get message => switch (this) {
        emailHasAccount => ChildSetupCopy.emailHasAccount,
        childLimit => ChildSetupCopy.childLimit,
        staleConsentText => ChildSetupCopy.staleConsentText,
        namedSignInRequired => ChildSetupCopy.namedSignInRequired,
        rateLimited => ChildSetupCopy.rateLimited,
        childAccountsClosed || other => ChildSetupCopy.setupFailed,
      };
}

class ChildSetupException implements Exception {
  const ChildSetupException(this.failure);
  final ChildSetupFailure failure;
  @override
  String toString() => 'ChildSetupException($failure)';
}

/// What a successful setup returns. The token is a secret: it never prints.
class ChildSetupResult {
  const ChildSetupResult({required this.childUid, required this.customToken});
  final String childUid;
  final String customToken;
  @override
  String toString() => 'ChildSetupResult($childUid)';
}
