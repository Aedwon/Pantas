/// The server's answer about a student's guardian request.
enum GuardianConsentStatus {
  /// No request has been sent.
  none,
  pending,
  confirmed,
  declined,
  expired;

  static GuardianConsentStatus parse(Object? raw) => switch (raw) {
        'pending' => pending,
        'confirmed' => confirmed,
        'declined' => declined,
        'expired' => expired,
        _ => none,
      };

  String get wire => name;
}

class GuardianStatus {
  const GuardianStatus({
    required this.status,
    this.maskedEmail,
    this.expiresAt,
  });

  factory GuardianStatus.fromJson(Map<Object?, Object?> json) {
    final expires = json['expiresAt'];
    final masked = json['maskedEmail'];
    return GuardianStatus(
      status: GuardianConsentStatus.parse(json['status']),
      maskedEmail: masked is String ? masked : null,
      expiresAt: expires is int
          ? DateTime.fromMillisecondsSinceEpoch(expires, isUtc: true)
          : null,
    );
  }

  final GuardianConsentStatus status;
  final String? maskedEmail;
  final DateTime? expiresAt;
}

/// What the guardian sees when they open the link. Reading never confirms.
sealed class GuardianLinkView {
  const GuardianLinkView();
}

class GuardianLinkOpen extends GuardianLinkView {
  const GuardianLinkOpen({required this.studentName, required this.expiresAt});
  final String? studentName;
  final DateTime expiresAt;
}

/// The link was answered already, has run out, or was never valid.
class GuardianLinkClosed extends GuardianLinkView {
  const GuardianLinkClosed(this.reason);
  final GuardianLinkClosedReason reason;
}

enum GuardianLinkClosedReason { used, expired, unknown }

enum GuardianAnswer { confirmed, declined, used, expired, unknown }

/// The parent or guardian's contact, kept on this device only so the student
/// can resend. The server keeps a masked address and hashes.
class GuardianContact {
  const GuardianContact({required this.name, required this.email});
  final String name;
  final String email;
}

/// `maria@gmail.com` becomes `m***@g***.com`.
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at < 1 || at == email.length - 1) return email;
  final domain = email.substring(at + 1);
  final dot = domain.lastIndexOf('.');
  if (dot < 1) return email;
  return '${email[0]}***@${domain[0]}***.${domain.substring(dot + 1)}';
}

final _simpleEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

bool looksLikeEmail(String value) {
  final text = value.trim();
  return text.length <= 254 && _simpleEmail.hasMatch(text);
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Nov 9, 2026" in Philippine time (UTC+8), the same date the email shows.
String guardianDateLabel(DateTime at) {
  final ph = at.toUtc().add(const Duration(hours: 8));
  return '${_months[ph.month - 1]} ${ph.day}, ${ph.year}';
}
