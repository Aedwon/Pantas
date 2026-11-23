/// The guardian code gate (under-13 board 8A, spec B2 rule 4b). A 6-digit code
/// is mailed to the parent or guardian and guards one action for one child.
/// Nothing here is stored on the device (rule 4d): the masked email and the
/// nickname live in memory for one screen.
library;

/// What a code guards. The names are the server's `GUARDIAN_CODE_ACTIONS`.
enum GuardianAction {
  addChild,
  dataCopy,
  withdraw,
  delete,
  siblingOptIn,
  switchInto;

  /// The value the server expects.
  String get serverName => name;
}

/// One run of the gate: which action, for which child. [actionPhrase] is the
/// word that follows "Confirm" in the title and the body, such as
/// "withdrawal". The caller supplies it, so a later action brings its own.
class GuardianGateRequest {
  const GuardianGateRequest({
    required this.action,
    required this.nickname,
    required this.actionPhrase,
    this.childId,
  });

  final GuardianAction action;

  /// Null for [GuardianAction.addChild], which names no child yet.
  final String? childId;
  final String nickname;
  final String actionPhrase;
}

/// What the server returns when it sends a code. The masked email is held in
/// memory for the screen only.
class GuardianCodeSent {
  const GuardianCodeSent({
    required this.maskedEmail,
    required this.resendAfterSeconds,
    required this.expiresInSeconds,
  });

  final String maskedEmail;
  final int resendAfterSeconds;
  final int expiresInSeconds;
}

/// Why the gate or the action behind it was refused, read from the callable's
/// `reason`.
enum GuardianGateFailure {
  /// The code is wrong. [GuardianGateException.triesLeft] says how many tries
  /// remain.
  wrong,
  tooManyTries,
  expired,

  /// Decision 9 item 6: no more codes today for this parent.
  dailyLimit,

  /// Too many requests or checks in a short time.
  rateLimited,

  /// The mail could not be sent.
  sendFailed,

  /// The account is not linked to that child.
  notLinked,

  /// The proof was used, expired or belongs to another action.
  proofInvalid,
  other;

  /// The failure for a server `reason` and error `code`.
  static GuardianGateFailure from({String? reason, String? code}) =>
      switch (reason) {
        'wrong' => wrong,
        'tooManyTries' => tooManyTries,
        'expired' => expired,
        'guardian-code-daily-limit' => dailyLimit,
        'not-linked' => notLinked,
        'guardian-proof-invalid' => proofInvalid,
        _ => switch (code) {
            'resource-exhausted' => rateLimited,
            'unavailable' => sendFailed,
            _ => other,
          },
      };
}

class GuardianGateException implements Exception {
  const GuardianGateException(this.failure, {this.triesLeft});

  final GuardianGateFailure failure;
  final int? triesLeft;

  @override
  String toString() => 'GuardianGateException($failure)';
}

/// Fixed wording of the code gate page (board 8A) and the lead's rulings on
/// its other states.
abstract final class GuardianGateCopy {
  /// The word after "Confirm" for each action the gate serves today.
  static const withdrawalPhrase = 'withdrawal';
  static const deletionPhrase = 'deletion';

  static String title({required String action, required String nickname}) =>
      'Confirm $action for $nickname';

  static const bodyLead = 'We sent a 6-digit code to ';

  static String bodyTail({required String action, required String nickname}) =>
      '. Enter it to confirm $action for $nickname.';

  static const fieldLabel = '6-digit code';
  static const sendNewCode = 'Send a New Code';
  static const confirm = 'Confirm';
  static const finePrintLead = "Can't reach that email? Write to ";
  static const finePrintTail = ' for another way to verify.';
  static const wrongCode = 'That code is not right. Check it and try again.';
  static const resent = 'We sent a new code.';

  // Lead rulings on copy (rule 4, final).
  static const tooManyTries = 'Too many wrong tries. Send a new code.';
  static const expired = 'This code has expired. Send a new code.';
  static const dailyLimitLead = "You have reached today's code limit. Try "
      'again tomorrow, or write to ';
  static const dailyLimitTail = ' for another way to verify.';

  // Existing sign-in wording, reused (email_sign_in_page.dart).
  static const rateLimited = 'Too many tries. Try again later.';
  static const sendFailed = "We couldn't send the code. Try again.";
  static String waitingToResend(String clock) =>
      "Didn't get it? You can resend in $clock.";
  static String waitToResend(String clock) =>
      'You can request a code in $clock.';

  // Not on a board: a check that failed for another reason.
  static const checkFailed = "We couldn't check the code. Try again.";
  static const dpoEmail = 'dpo@pantas.study';
}

/// What a parent can do on the For parents page. Each needs a code first.
enum ParentsAction { withdraw, delete }

/// Fixed wording of the For parents page (board 4B), its four confirms
/// (D4W, D4D, D4LW, D4L) and the receipt link.
abstract final class ParentsCopy {
  // Settings (board ST4B).
  static const settingsRow = 'For parents';
  static const managedLine = 'This account is managed by a parent or guardian.';

  // The page (board ST4B2).
  static const backToSettings = 'Settings';
  static const title = 'For parents';
  static const lead = 'These actions apply to this child only.';
  static const readNotice = 'Read the Child Notice';
  static const dataCopyRow = "Get a copy of your child's data";
  static const withdrawRow = 'Withdraw permission and close account';
  static const withdrawSub = 'This is free. Study processing stops and the '
      'account closes. Limited records remain for the purposes and periods in '
      'the Child Notice. Earlier lawful processing remains lawful.';
  static const deleteRow = 'Delete this account';

  // The four confirms.
  static String withdrawTitle(String nickname) =>
      'Withdraw Permission for $nickname?';
  static String withdrawBody(String nickname) =>
      '$nickname is signed out. Their account and study records are deleted. '
      'This cannot be undone. It does not cancel an app store subscription. '
      'Withdrawing is free. Limited records stay as the Child Notice '
      'explains.';
  static const withdrawButton = 'Withdraw';
  static const deleteTitle = 'Delete this account?';
  static const deleteBody = "This deletes your child's study records from our "
      'servers. It keeps only the records the Child Notice lists. Copies on '
      'other devices stay until cleared.';
  static const deleteButton = 'Delete';
  static const cancel = 'Cancel';

  /// Added to either confirm when this is the holder's last child.
  static const lastChild = 'This is your last child on this email. Closing it '
      'also closes your sign-in and removes its active sign-in details. '
      'Limited consent, payment, security, support and backup records remain '
      'as the Child Notice explains.';

  // The data copy (lead ruling, rule 4: the export is not built, so the
  // data protection officer answers).
  static const dataCopyTitle = "Get a copy of your child's data";
  static const dataCopyLead = 'Write to ';
  static const dataCopyTail = ' from the email you used to set up this '
      'account. We will check it is you and send the copy.';
  static const gotIt = 'Got It';

  /// Not on a board: stands in for the nickname when the server did not
  /// return it.
  static const nicknameFallback = 'your child';

  // Lead ruling: the same sentence for a failed withdrawal and a failed
  // deletion.
  static const closeFailed = 'We could not close this account. Try again, or '
      'write to ${GuardianGateCopy.dpoEmail}.';

  // The receipt link (lead ruling).
  static const otherAccount = 'This link is for another account. Sign in with '
      'the email that set up this child.';
}
