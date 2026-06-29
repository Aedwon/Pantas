// test/core/storage/domain/attempt_origins_test.dart
import 'package:cse_cet_reviewer/core/storage/domain/attempt_origins.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assessment is the only untimed origin today', () {
    expect(AttemptOrigins.untimed, {'assessment'});
  });
}
