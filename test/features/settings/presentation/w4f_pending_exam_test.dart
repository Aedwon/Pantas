import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';

class _Telemetry extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

const _target = ExamCatalogEntry(
  id: 'exam_cse_pro',
  name: 'CSE Professional',
  shortName: 'CSE Professional',
  priceTier: 'Civil Service',
  group: 'Civil service',
  comingSoon: false,
  hasContent: true,
  publishedSittings: [],
);

void main() {
  for (final scenario in [
    'success',
    'cancelled',
    'unconfirmed',
    'other account',
    'student coverage only',
    'focus changed',
    'owner loading',
    'owner refresh',
    'no target',
    'wrong session',
    'expired',
    'malformed',
    'abandoned then purchase',
  ]) {
    testWidgets('pending exam switch: $scenario', (tester) async {
      final telemetry = _Telemetry();
      var hasGrant = scenario != 'abandoned then purchase';
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
        scenario == 'malformed'
            ? '{bad json'
            : jsonEncode({
                'uid': 'owner',
                'examId': 'exam_cse_pro',
                'count': false,
                'tier': 'civilService',
                'fromExamId': 'exam_upcat',
                'sessionId': 'cs_original',
                'createdAt': DateTime.now()
                    .subtract(Duration(hours: scenario == 'expired' ? 25 : 1))
                    .millisecondsSinceEpoch,
              }),
      );
      final gateway = WebPaymentGateway(
        callable: (_, __) async => {'plans': <Object?>[]},
        readGrants: (_) async => (scenario == 'unconfirmed' || !hasGrant)
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
          if (scenario.startsWith('owner ')) await refresh.future;
        },
        openUrl: (_) async => true,
      );
      final uid = scenario == 'other account' ? 'other' : 'owner';
      await gateway.logIn(uid);
      final routes = Provider(
        (ref) => GoRouter(
          initialLocation:
              '/pro?checkout=${scenario == 'cancelled' ? 'cancelled' : 'success'}&session_id=${scenario == 'wrong session' ? 'cs_other' : 'cs_original'}',
          routes: [
            GoRoute(
              path: '/pro',
              builder: (_, state) => ProPage(
                targetExam: scenario == 'no target' ? null : _target,
                checkoutReturnUri: state.uri,
              ),
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          telemetryProvider.overrideWithValue(telemetry),
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
      if (scenario.startsWith('owner ')) {
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
      if (scenario.startsWith('owner ')) {
        nextOwner.complete(
          AuthUser(
            uid: scenario == 'owner refresh' ? 'owner' : 'other',
            email: 'b@example.com',
            displayName: 'B',
          ),
        );
        await tester.pumpAndSettle();
      }
      if (scenario == 'owner refresh') {
        expect(await prefs.selectedExamId(), 'exam_cse_pro');
      }
      if (!['other account', 'owner loading'].contains(scenario)) {
        expect(await prefs.deviceValue('checkout_exam_v1:owner'), isEmpty);
      }
      if (scenario == 'malformed') {
        expect(telemetry.errors, hasLength(1));
        expect(find.text('Could not save. Please try again.'), findsNothing);
      }
      if (scenario == 'abandoned then purchase') {
        hasGrant = true;
        router.go('/pro?checkout=success&session_id=cs_later');
        await tester.pumpAndSettle();
        // Force a fresh page, as a later checkout would reload the app.
        await tester.pumpWidget(const SizedBox());
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
        expect(await prefs.selectedExamId(), 'exam_upcat');
      }
    });
  }
}
