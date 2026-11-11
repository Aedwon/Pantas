import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/paywall/application/beta_pro_provider.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';

const user = AuthUser(uid: 'beta-owner', email: '', displayName: '');
const exam = Exam(
  id: 'exam_cse_pro',
  code: 'CSE',
  name: 'CSE',
  shortName: 'CSE',
  language: 'en',
  isActive: true,
  subjects: [],
);
void main() {
  test('absent server config hides beta; signed-out discovery makes no call',
      () async {
    var calls = 0;
    for (final signedIn in [true, false]) {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider
              .overrideWith((ref) async => signedIn ? user : null),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(exam),
          ),
          betaProCallableProvider.overrideWithValue((name, data) async {
            calls++;
            expect(name, 'getWebEntitlement');
            expect(data, {'uid': user.uid});
            return {'betaProUntil': null, 'grants': <Object?>[]};
          }),
        ],
      );
      await container.read(currentUserProvider.future);
      expect(await container.read(betaProProvider.future), isNull);
      container.dispose();
    }
    expect(calls, 1);
  });
  test('a switch request keeps the owner and exam bound across the call',
      () async {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) async => user),
        activeExamFocusProvider
            .overrideWith((ref) async => const ActiveExamFocus.selected(exam)),
        revenueCatGatewayProvider
            .overrideWithValue(const DisabledRevenueCatGateway()),
        betaProCallableProvider.overrideWithValue((name, data) async {
          expect(name, 'setBetaPro');
          expect(data, {'uid': user.uid, 'enabled': true, 'examId': exam.id});
          return {'enabled': true};
        }),
      ],
    );
    addTearDown(container.dispose);
    await container.read(currentUserProvider.future);
    await container.read(setBetaProProvider)(enabled: true);
  });
  test('changing account during exam lookup cancels the old click', () async {
    final identity = StateProvider<AuthUser?>((ref) => user);
    final focus = Completer<ActiveExamFocus>();
    var calls = 0;
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) async => ref.watch(identity)),
        activeExamFocusProvider.overrideWith((ref) => focus.future),
        betaProCallableProvider.overrideWithValue((name, data) async {
          calls++;
          return null;
        }),
      ],
    );
    addTearDown(container.dispose);
    await container.read(currentUserProvider.future);
    final mutation = container.read(setBetaProProvider)(enabled: true);
    container.read(identity.notifier).state =
        const AuthUser(uid: 'new-owner', email: '', displayName: '');
    await container.read(currentUserProvider.future);
    focus.complete(const ActiveExamFocus.selected(exam));
    await mutation;
    expect(calls, 0);
  });
}
