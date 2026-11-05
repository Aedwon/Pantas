import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/run_checks.dart';

void main() {
  test('each check names the failure it came from', () {
    expect(allChecks, isNotEmpty);
    for (final check in allChecks) {
      expect(check.name, isNotEmpty);
      expect(check.origin.length, greaterThan(20), reason: check.name);
    }
  });
}
