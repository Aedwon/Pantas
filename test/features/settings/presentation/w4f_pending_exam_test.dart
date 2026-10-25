import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  for (final scenario in [
    'success',
    'cancelled',
    'unconfirmed',
    'other account',
    'student coverage only',
    'focus changed',
    'owner loading',
  ]) {
    testWidgets('pending exam switch: $scenario', (tester) async {
      final ownerLoading = StateProvider<bool>((ref) => false);
      final nextOwner = Completer<AuthUser?>();
      final refresh = Completer<void>();
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final prefs = AppPreferencesRepository(db);
      await prefs.setSelectedExamId(
        scenario == 'focus changed' ? 'exam_dost' : 'exam_upcat',
      );
      await prefs.setDeviceValue(
        'checkout_exam_v1:owner',
        jsonEncode({
          'uid': 'owner',
          'examId': 'exam_cse_pro',
          'count': false,
          'tier': 'civilService',
          'fromExamId': 'exam_upcat',
        }),
      );
      final gateway = WebPaymentGateway(
        callable: (_, __) async => {'plans': <Object?>[]},
        readGrants: (_) async => scenario == 'unconfirmed'
            ? []
            : [
                {
                  'product': scenario == 'student coverage only'
                      ? 'pantas_pro_monthly'
                      : 'pantas_cs_monthly',
                  'state': 'active',
                  'startsAt': DateTime.utc(2020).millisecondsSinceEpoch,
                  'endsAt': DateTime.utc(2035).millisecondsSinceEpoch,
                },
              ],
        refreshClaims: (_) async {
          if (scenario == 'owner loading') await refresh.future;
        },
        openUrl: (_) async => true,
      );
      final uid = scenario == 'other account' ? 'other' : 'owner';
      await gateway.logIn(uid);
      final routes = Provider(
        (ref) => GoRouter(
          initialLocation:
              '/pro?checkout=${scenario == 'cancelled' ? 'cancelled' : 'success'}',
          routes: settingsRoutes(ref),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          currentUserProvider.overrideWith(
            (ref) async => ref.watch(ownerLoading)
                ? nextOwner.future
                : AuthUser(uid: uid, email: 'a@example.com', displayName: 'A'),
          ),
          isAnonymousProvider.overrideWith((ref) async => false),
          paymentsOnWebProvider.overrideWithValue(true),
          revenueCatGatewayProvider.overrideWithValue(gateway),
          proForActiveExamProvider.overrideWith((ref) async => false),
          activeProCatalogEntryProvider.overrideWith((ref) async => null),
          paywallOfferingProvider.overrideWith(
            (ref) async => const PaywallOfferingResult.noCurrentOffering(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: appLightTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (scenario == 'owner loading') {
        container.read(ownerLoading.notifier).state = true;
        await tester.pump();
        expect(container.read(currentUserProvider).isLoading, isTrue);
        refresh.complete();
        await tester.pumpAndSettle();
      }
      expect(
        await prefs.selectedExamId(),
        scenario == 'success'
            ? 'exam_cse_pro'
            : scenario == 'focus changed'
                ? 'exam_dost'
                : 'exam_upcat',
      );
      expect(
        (await container.read(settingsRepositoryProvider).readUserSettings())
            .carryOverProgress,
        scenario == 'success' ? isFalse : isTrue,
      );
      if (scenario == 'owner loading') {
        nextOwner.complete(
          const AuthUser(
            uid: 'other',
            email: 'b@example.com',
            displayName: 'B',
          ),
        );
        await tester.pumpAndSettle();
      }
      if (scenario == 'success' || scenario == 'cancelled') {
        expect(await prefs.deviceValue('checkout_exam_v1:owner'), isEmpty);
      }
    });
  }
}
