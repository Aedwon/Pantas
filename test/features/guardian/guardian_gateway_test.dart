import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';

class _Client implements GuardianCallableClient {
  _Client(this.reply);
  Object? Function(String name, Map<String, Object?> data) reply;
  final calls = <(String, Map<String, Object?>)>[];
  @override
  Future<Object?> call(String name, Map<String, Object?> data) async {
    calls.add((name, data));
    return reply(name, data);
  }
}

void main() {
  test('sending a link names the callable and returns the pending status',
      () async {
    final client = _Client(
      (_, __) => {'expiresAt': 1793000000000, 'maskedEmail': 'm***@g***.com'},
    );
    final status = await CallableGuardianGateway(client).sendLink(
      guardianName: 'Maria',
      guardianEmail: 'maria@gmail.com',
    );
    expect(client.calls.single.$1, 'sendGuardianLink');
    expect(client.calls.single.$2, {
      'guardianName': 'Maria',
      'guardianEmail': 'maria@gmail.com',
    });
    expect(status.status, GuardianConsentStatus.pending);
    expect(status.maskedEmail, 'm***@g***.com');
  });

  test('the request carries no student name', () async {
    final client = _Client((_, __) => {'expiresAt': 1, 'maskedEmail': 'x'});
    await CallableGuardianGateway(client).sendLink(
      guardianName: 'Maria',
      guardianEmail: 'maria@gmail.com',
    );
    expect(client.calls.single.$2.keys, ['guardianName', 'guardianEmail']);
  });

  test('the age check notice version goes with the link request', () async {
    final client = _Client((_, __) => {'expiresAt': 1, 'maskedEmail': 'x'});
    await CallableGuardianGateway(client).sendLink(
      guardianName: 'Maria',
      guardianEmail: 'maria@gmail.com',
      ageCheckNoticeVersion: '2026-11-09',
    );
    expect(client.calls.single.$2, {
      'guardianName': 'Maria',
      'guardianEmail': 'maria@gmail.com',
      'ageCheckNoticeVersion': '2026-11-09',
    });
  });

  test('marking the account adult calls the callable', () async {
    final client = _Client((_, __) => {'state': 'adult'});
    await CallableGuardianGateway(client).markAdult();
    expect(client.calls.single.$1, 'markGuardianAdult');
    expect(client.calls.single.$2, <String, Object?>{});
  });

  test('status reads the callable', () async {
    final client = _Client((_, __) => {'status': 'confirmed'});
    final status = await CallableGuardianGateway(client).status();
    expect(client.calls.single.$1, 'getGuardianStatus');
    expect(status.status, GuardianConsentStatus.confirmed);
  });

  test('the link view maps open and closed states', () async {
    final open = _Client(
      (_, __) => {'state': 'open', 'expiresAt': 1000},
    );
    final view = await CallableGuardianGateway(open).readLink('t');
    expect(open.calls.single.$1, 'getGuardianRequest');
    expect(open.calls.single.$2, {'token': 't'});
    expect(view, isA<GuardianLinkOpen>());
    expect(
      (view as GuardianLinkOpen).expiresAt,
      DateTime.utc(1970, 1, 1, 0, 0, 1),
    );
    for (final entry in {
      'used': GuardianLinkClosedReason.used,
      'expired': GuardianLinkClosedReason.expired,
      'unknown': GuardianLinkClosedReason.unknown,
      'garbage': GuardianLinkClosedReason.unknown,
    }.entries) {
      final closed = await CallableGuardianGateway(
        _Client((_, __) => {'state': entry.key}),
      ).readLink('t');
      expect((closed as GuardianLinkClosed).reason, entry.value);
    }
  });

  test('answering sends the decision and the agreement', () async {
    final client =
        _Client((_, __) => {'state': 'confirmed', 'manageToken': 'mt'});
    final gateway = CallableGuardianGateway(client);
    final confirmed = await gateway.answer(
      token: 't',
      confirm: true,
      agreed: true,
      allowSharing: true,
    );
    expect(confirmed.answer, GuardianAnswer.confirmed);
    expect(confirmed.manageToken, 'mt');
    expect(client.calls.single.$1, 'answerGuardianRequest');
    expect(client.calls.single.$2, {
      'token': 't',
      'decision': 'confirm',
      'agreed': true,
      'allowSharing': true,
      'documentVersions': {
        'privacy': '2026-11-11',
        'terms': '2026-11-11',
        'teens': '2026-11-11',
      },
      'noticeWordingVersion': '2026-11-11',
    });
    client.reply = (_, __) => {'state': 'declined'};
    final declined = await gateway.answer(
      token: 't',
      confirm: false,
      agreed: false,
      allowSharing: false,
    );
    expect(declined.answer, GuardianAnswer.declined);
    expect(declined.manageToken, isNull);
    expect(client.calls.last.$2['decision'], 'decline');
    expect(client.calls.last.$2['allowSharing'], false);
  });

  test('a rate limit and any other failure become typed errors', () async {
    final limited = CallableGuardianGateway(
      _Client((_, __) => throw const GuardianRateLimitedException()),
    );
    await expectLater(
      limited.sendLink(guardianName: 'a', guardianEmail: 'a@b.co'),
      throwsA(isA<GuardianRateLimitedException>()),
    );
    final malformed = CallableGuardianGateway(_Client((_, __) => 'oops'));
    await expectLater(
      malformed.status(),
      throwsA(isA<GuardianGatewayException>()),
    );
  });
}
