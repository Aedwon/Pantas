enum SessionOrigin {
  todayTopic('today_topic'),
  todayInterleaved('today_interleaved'),
  drill('drill'),
  retake('retake'),
  inline('inline');

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
