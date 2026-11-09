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

  static const declinedTitle = 'Response sent';
  static const declinedDetail =
      'The account was not confirmed. You can close this page.';
}

/// The notice for teens is published with the legal documents.
const teenNoticeReady = true;

/// Version of the confirmation page's explanation and agreement wording.
const guardianNoticeWordingVersion = '2026-11-11';
