/// Fixed wording for the guardian result screens.
abstract final class GuardianCopy {
  static const closedTitle = 'This link no longer works';
  static const closedDetail = 'It has expired or was already used.';

  static const confirmedTitle = 'Thank you';
  static const confirmedDetail =
      'The account is confirmed. You can close this page.';

  static const declinedTitle = 'Response sent';
  static const declinedDetail =
      'The account was not confirmed. You can close this page.';
}

/// Whether the notice for teens has been written. The link to it on the
/// guardian confirm page, and its address, stay hidden until this is true.
/// Set it to true when the text is added to the legal documents.
const teenNoticeReady = false;
