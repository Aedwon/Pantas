import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/domain/cooldown_label.dart';

void main() {
  test('days and hours', () {
    expect(
      cooldownLabel(const Duration(days: 9, hours: 14)),
      '9d 14h',
    );
  });

  test('hours alone when under a day', () {
    expect(cooldownLabel(const Duration(hours: 14)), '14h');
  });

  test('days alone when the hours are zero', () {
    expect(cooldownLabel(const Duration(days: 9)), '9d');
  });

  test('part of an hour still shows an hour', () {
    expect(cooldownLabel(const Duration(minutes: 20)), '1h');
  });

  test('a finished cooldown has no label', () {
    expect(cooldownLabel(Duration.zero), isNull);
    expect(cooldownLabel(const Duration(seconds: -5)), isNull);
  });
}
