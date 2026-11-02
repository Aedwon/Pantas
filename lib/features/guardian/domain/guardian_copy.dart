/// Wording on the guardian page that the approved brief did not list.
///
/// UNAPPROVED: every string in this file was written to make the screens
/// work and needs Aedwon's review before release.
abstract final class GuardianCopy {
  static const closedTitle = 'This link no longer works';
  static const closedDetail = 'It has expired or was already used.';

  static const confirmedTitle = 'Thank you';
  static String confirmedDetail(String student) =>
      "$student's account is confirmed. You can close this page.";

  static const declinedTitle = 'Response sent';
  static String declinedDetail(String student) =>
      "$student's account was not confirmed. You can close this page.";

  /// Used when the student's name was not known when the link was sent.
  static const unnamedStudent = 'your child';

  /// A name at the start of a sentence, so the fallback reads "Your child".
  static String atSentenceStart(String name) =>
      '${name[0].toUpperCase()}${name.substring(1)}';
}
