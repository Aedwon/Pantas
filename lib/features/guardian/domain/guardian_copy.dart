/// Fixed wording for the guardian result screens.
abstract final class GuardianCopy {
  static const closedTitle = 'This link no longer works';
  static const closedDetail = 'It has expired or was already used.';

  static const confirmedTitle = 'Thank you';
  static const confirmedDetail =
      'The account is confirmed. To change sharing or withdraw later, use '
      'Manage Permission or the link in your email.';

  static const explanation =
      "Pantas keeps your child's answers and study progress to run the app. "
      'Confirming here does not authorize a charge. If your child wants Pro, '
      'a parent or guardian makes the payment and ticks a box to accept the '
      'Terms.';

  static const sharingLabel = 'Allow optional usage sharing';
  static const sharingHelp = 'Optional. Helps us improve Pantas. Your child '
      'can turn it off at any time.';

  // The manage page (boards MA_*, WD_*, MS_States).
  static const manageTitle = 'Manage permission';
  static const manageDetail =
      "You confirmed your child's Pantas account. You can change this at any "
      'time.';
  static const manageSharingHelp =
      'Helps us improve Pantas. Your child can turn it off at any time.';
  static const withdrawLabel = 'Withdraw Permission';
  static const withdrawDialogTitle = 'Withdraw permission?';
  static const withdrawDialogBody =
      'Your child is signed out, and their account and study records are '
      'deleted. This cannot be undone. It does not cancel an app store '
      'subscription.';
  static const manageClosedDetail =
      'The account was closed, or a newer link replaced this one.';
  static const notConfirmedTitle = 'Confirm the account first';
  static const notConfirmedDetail =
      'Use the Review and Confirm link in the same email. After that, this '
      'page lets you manage permission.';
  static const changeFailedTitle = 'Your change was not saved';
  static const changeFailedDetail = 'Check your connection, then try again.';
  static const changeFailedLine = '$changeFailedTitle. $changeFailedDetail';
  static const withdrawnTitle = 'Permission withdrawn';
  static const withdrawnDetail =
      "Your child's account is closed and is being deleted. You can close "
      'this page.';
  // What the closed student sees, not the guardian.
  static const accountClosedTitle = 'Account closed';
  static const accountClosedDetail =
      'Your parent or guardian withdrew permission for this account. It is '
      'closed and is being deleted. Questions? Email support@pantas.study.';
  static const managePermissionLabel = 'Manage Permission';

  static const declinedTitle = 'Response sent';
  static const declinedDetail =
      'The account was not confirmed. You can close this page.';
}

/// The notice for teens is published with the legal documents.
const teenNoticeReady = true;

/// Version of the confirmation page's explanation and agreement wording.
const guardianNoticeWordingVersion = '2026-11-11';
