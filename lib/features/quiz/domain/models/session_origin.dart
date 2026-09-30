enum SessionOrigin {
  todayTopic('today_topic'),
  todayInterleaved('today_interleaved'),
  drill('drill'),
  retake('retake'),
  inline('inline'),

  /// The one-off assessment. Recorded as an attempt so the metrics layer and
  /// the Progress table can see its questions, and deliberately outside the
  /// streak: it is taken once and is not a day's work.
  assessment('assessment'),

  /// A submitted mock's answers, recorded so reviews and topic scores see
  /// them. The mock itself stays in `mock_attempts`; this is outside the
  /// streak because the mock is not a day's session.
  mock('mock');

  const SessionOrigin(this.storageValue);

  final String storageValue;

  bool get isStreakEligible =>
      this == SessionOrigin.todayTopic ||
      this == SessionOrigin.todayInterleaved;

  static SessionOrigin fromStorage(String value) {
    return SessionOrigin.values.firstWhere(
      (origin) => origin.storageValue == value,
      orElse: () => SessionOrigin.todayTopic,
    );
  }
}
