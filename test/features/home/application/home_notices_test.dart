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
}
