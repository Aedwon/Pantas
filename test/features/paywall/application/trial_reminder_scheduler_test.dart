import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/paywall.dart';

void main() {
  test('trial reminder scheduler no-ops when notification seam is unavailable',
      () async {
    const scheduler = NoopTrialReminderScheduler();

    await scheduler.scheduleTrialEndingReminder(
      chargeDate: DateTime.utc(2026, 5, 28),
    );
    await scheduler.cancelTrialEndingReminder();

    expect(scheduler, isA<TrialReminderScheduler>());
  });
}
