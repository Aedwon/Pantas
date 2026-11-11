Future<void> deleteAccountFromSettings({
  required bool isAnonymous,
  required Future<void> Function() cancelNotifications,
  required Future<void> Function() deleteNamedAccount,
  required Future<void> Function() wipeAnonymousData,
}) async {
  await cancelNotifications();
  if (isAnonymous) {
    await wipeAnonymousData();
    return;
  }
  await deleteNamedAccount();
}
