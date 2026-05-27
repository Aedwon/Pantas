enum NotificationPermission {
  notYetAsked,
  granted,
  denied;

  bool get canSchedule => this == NotificationPermission.granted;
}
