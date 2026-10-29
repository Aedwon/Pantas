/// How a student reaches us, and how we are reached about their data.
///
/// There is no postal address. Aedwon has no office, and a placeholder one
/// printed under a privacy policy is worse than none. Play asks for an
/// address when a developer account is verified, which is the console's
/// business and not the app's.
class LegalContact {
  const LegalContact({
    required this.dpoEmail,
    required this.supportEmail,
    required this.communityGroupUrl,
  });

  final String dpoEmail;

  /// Play requires a developer contact email on the listing. A community
  /// group does not satisfy that, so this address exists whether or not a
  /// row in the app points at it.
  final String supportEmail;

  /// Where "Send feedback" goes. Decided 3 August 2026: feedback is a group,
  /// not a hundred one-to-one mail threads.
  final String communityGroupUrl;
}

const defaultLegalContact = LegalContact(
  dpoEmail: 'dpo@pantas.study',
  supportEmail: 'contact@pantas.study',
  communityGroupUrl: 'https://www.facebook.com/groups/1760794271928040',
);
