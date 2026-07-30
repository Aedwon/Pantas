import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/paywall.dart';

void main() {
  test('bootstrap skips RevenueCat when Android API key is absent', () async {
    final gateway = BootstrapGateway();
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.configure(RevenueCatConfig.fromEnvironment());

    expect(gateway.configuredKeys, isEmpty);
  });

  test('bootstrap configures gateway when Android API key is present',
      () async {
    final gateway = BootstrapGateway();
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.configure(
      RevenueCatConfig.fromEnvironment(androidApiKey: 'rc_key'),
    );

    expect(gateway.configuredKeys, ['rc_key']);
  });

  test('auth uid association calls logIn for anonymous and named UIDs',
      () async {
    final gateway = BootstrapGateway();
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.associateUid('anon_uid');
    await bootstrapper.associateUid('named_uid');

    expect(gateway.loggedInUids, ['anon_uid', 'named_uid']);
  });

  test('same uid is not logged in repeatedly', () async {
    final gateway = BootstrapGateway();
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.associateUid('uid_1');
    await bootstrapper.associateUid('uid_1');

    expect(gateway.loggedInUids, ['uid_1']);
  });
}

class BootstrapGateway extends DisabledRevenueCatGateway {
  final configuredKeys = <String>[];
  final loggedInUids = <String>[];

  @override
  Future<void> configure({required String androidApiKey}) async {
    configuredKeys.add(androidApiKey);
  }

  @override
  Future<void> logIn(String uid) async {
    loggedInUids.add(uid);
  }
}
