abstract interface class TrialReminderScheduler {
  Future<void> scheduleTrialEndingReminder({required DateTime chargeDate});
  Future<void> cancelTrialEndingReminder();
}

class NoopTrialReminderScheduler implements TrialReminderScheduler {
  const NoopTrialReminderScheduler();

  @override
  Future<void> cancelTrialEndingReminder() async {}

  @override
  Future<void> scheduleTrialEndingReminder({
    required DateTime chargeDate,
  }) async {}
}
