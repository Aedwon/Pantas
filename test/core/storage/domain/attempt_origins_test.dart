// test/core/storage/domain/attempt_origins_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';

void main() {
  test('the assessment and recorded mocks are the untimed origins', () {
    expect(AttemptOrigins.untimed, {'assessment', 'mock'});
  });

  test('recorded mocks are the only mirrored origin', () {
    expect(AttemptOrigins.mirrored, {'mock'});
  });
}
