import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import '../../../helpers/pump_app.dart';
import '../data/server_mock_results_test.dart' as fixture;

void main() {
  testWidgets('result Retry makes a fresh request to the failed server reader',
      (tester) async {
    var calls = 0;
    await tester.pumpAppWithProviders(
      const MockResultsRoute(attemptId: 'MockResult000001'),
      overrides: [
        mockUsesServerProvider.overrideWithValue(true),
        serverMockIdentityProvider.overrideWithValue('a'),
        serverMockActorProvider.overrideWithValue(() => 'a'),
        entitlementProvider
            .overrideWith((ref) => const Stream<Entitlement>.empty()),
        serverMockApiProvider.overrideWithValue(
          ServerMockApi((name, data) async {
            if (name == 'getMockHistory') {
              return {'items': <Object?>[], 'next': null};
            }
            calls++;
            if (calls == 1) {
              throw const ServerMockException(code: 'unavailable');
            }
            return fixture.result(open: false);
          }),
        ),
      ],
    );
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    expect(calls, 1);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Try Again'), findsNothing);
  });
}
