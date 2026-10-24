import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/application/home_notices.dart';

HomeNotice notice(HomeNoticeKind kind, {String token = 'yes'}) =>
    HomeNotice(kind: kind, title: kind.name, dismissalToken: token);
void main() {
  test('notice priority is service, trial, welcome, no date, month only', () {
    final candidates = [
      for (final kind in HomeNoticeKind.values.reversed) notice(kind),
    ];
    final dismissed = <HomeNoticeKind, String>{};
    for (final kind in HomeNoticeKind.values) {
      expect(selectHomeNotice(candidates, dismissed)?.kind, kind);
      dismissed[kind] = 'yes';
    }
    expect(selectHomeNotice(candidates, dismissed), isNull);
  });
  test(
      'changed service text returns '
      'while unchanged dismissed text stays closed', () {
    expect(
      selectHomeNotice(
        [notice(HomeNoticeKind.service, token: 'old')],
        {HomeNoticeKind.service: 'old'},
      ),
      isNull,
    );
    expect(
      selectHomeNotice(
        [notice(HomeNoticeKind.service, token: 'new')],
        {HomeNoticeKind.service: 'old'},
      )?.dismissalToken,
      'new',
    );
  });

  group('web trial notice', () {
    final now = DateTime(2026, 9, 30, 21);

    test('shows the approved prepaid wording with the actual end date', () {
      final result = webTrialHomeNotice(
        endsAt: DateTime(2026, 10, 2, 12),
        now: now,
      );
      expect(result?.kind, HomeNoticeKind.trial);
      expect(result?.title, 'Pro trial ends in 2 days');
      expect(
        result?.detail,
        'Your free trial ends on Oct 2. You won\u2019t be charged.',
      );
      expect(result?.primaryLabel, 'See Pro');
      expect(result?.secondaryLabel, 'Got It');
    });

    test('never prints a store charge, price or auto-renew claim', () {
      final detail = webTrialHomeNotice(
        endsAt: DateTime(2026, 10, 2),
        now: now,
      )!
          .detail!;
      expect(detail, isNot(contains('Google Play')));
      expect(detail, isNot(contains('\u20b1')));
      expect(detail, isNot(contains('Cancel')));
    });

    test('counts the actual days left', () {
      expect(
        webTrialHomeNotice(endsAt: DateTime(2026, 10), now: now)?.title,
        'Pro trial ends in 1 day',
      );
      expect(
        webTrialHomeNotice(endsAt: DateTime(2026, 9, 30, 23), now: now)?.title,
        'Pro trial ends today',
      );
    });

    test('is absent before the last two days and after it ended', () {
      expect(
        webTrialHomeNotice(endsAt: DateTime(2026, 10, 3), now: now),
        isNull,
      );
      expect(
        webTrialHomeNotice(endsAt: DateTime(2026, 9, 29), now: now),
        isNull,
      );
    });

    test('missing trial evidence means no notice', () {
      expect(webTrialHomeNotice(endsAt: null, now: now), isNull);
    });

    test('dismissal is bound to this trial end', () {
      final first = webTrialHomeNotice(
        endsAt: DateTime(2026, 10, 2),
        now: now,
      )!;
      final next = webTrialHomeNotice(
        endsAt: DateTime(2026, 10),
        now: now,
      )!;
      expect(first.dismissalToken, isNot(next.dismissalToken));
    });
  });
}
