import 'package:pantas/app/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every settings row has a route to land on', () {
    const required = [
      '/settings',
      '/settings/exam',
      '/settings/exam/change',
      '/settings/exam/included',
      '/settings/pro',
      '/settings/account',
      '/settings/backup',
      '/settings/about',
    ];

    final paths = collectRoutePaths();

    for (final path in required) {
      expect(paths, contains(path), reason: 'missing route $path');
    }
  });

  test('the retired subscription path still redirects', () {
    expect(collectRoutePaths(), contains('/settings/subscription'));
  });
}
