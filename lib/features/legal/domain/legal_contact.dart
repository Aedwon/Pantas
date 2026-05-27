class LegalContact {
  const LegalContact({
    required this.dpoEmail,
    required this.supportEmail,
    required this.physicalAddress,
  });

  final String dpoEmail;
  final String supportEmail;
  final String physicalAddress;
}

const defaultLegalContact = LegalContact(
  dpoEmail: 'privacy@csecetreviewer.ph',
  supportEmail: 'support@csecetreviewer.ph',
  physicalAddress: 'CSE Reviewer, Metro Manila, Philippines',
);
