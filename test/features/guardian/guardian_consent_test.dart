import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';

void main() {
  test('an email is masked to its first letters and last label', () {
    expect(maskEmail('maria@gmail.com'), 'm***@g***.com');
    expect(maskEmail('a.b@mail.example.co.ph'), 'a***@m***.ph');
    expect(maskEmail('not-an-email'), 'not-an-email');
  });

  test('email shape check', () {
    expect(looksLikeEmail('maria@gmail.com'), isTrue);
    expect(looksLikeEmail(' maria@gmail.com '), isTrue);
    for (final bad in [
      '',
      'maria',
      'maria@',
      '@gmail.com',
      'a@b',
      'a b@c.com',
    ]) {
      expect(looksLikeEmail(bad), isFalse, reason: bad);
    }
  });

  test('the date is written in Philippine time', () {
    expect(
      guardianDateLabel(DateTime.utc(2026, 11, 8, 17)),
      'Nov 9, 2026',
    );
    expect(
      guardianDateLabel(DateTime.utc(2026, 11, 8, 15, 59)),
      'Nov 8, 2026',
    );
  });

  test('status parses the server answer and ignores unknown values', () {
    final s = GuardianStatus.fromJson({
      'status': 'pending',
      'maskedEmail': 'm***@g***.com',
      'expiresAt': DateTime.utc(2026, 11, 9).millisecondsSinceEpoch,
    });
    expect(s.status, GuardianConsentStatus.pending);
    expect(s.maskedEmail, 'm***@g***.com');
    expect(s.expiresAt, DateTime.utc(2026, 11, 9));
    expect(
      GuardianStatus.fromJson({'status': 'weird'}).status,
      GuardianConsentStatus.none,
    );
    expect(
      GuardianStatus.fromJson({'status': 'expired'}).status,
      GuardianConsentStatus.expired,
    );
  });
}
