import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/paywall_controller.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';

void main() {
  test('Manage opens the Google Play subscription page without buying',
      () async {
    Uri? opened;
    final controller = PaywallController(
      const DisabledRevenueCatGateway(),
      openManagementPage: (uri) async {
        opened = uri;
        return true;
      },
    );
    expect((await controller.manage()).result, PaymentResult.success);
    expect(
      opened.toString(),
      'https://play.google.com/store/account/subscriptions',
    );
  });

  test('a page that cannot open returns a store error', () async {
    final controller = PaywallController(
      const DisabledRevenueCatGateway(),
      openManagementPage: (_) async => false,
    );
    expect((await controller.manage()).result, PaymentResult.storeError);
  });
}
