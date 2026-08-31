abstract interface class AccountTransitionGateway {
  Future<void> prepareForSignOut();

  Future<void> prepareForAccountSwitch();

  Future<void> prepareForDeleteAccount();
}

class NoopAccountTransitionGateway implements AccountTransitionGateway {
  const NoopAccountTransitionGateway();

  @override
  Future<void> prepareForSignOut() async {}

  @override
  Future<void> prepareForAccountSwitch() async {}

  @override
  Future<void> prepareForDeleteAccount() async {}
}
