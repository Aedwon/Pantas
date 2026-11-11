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
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _Preferences extends AppPreferencesRepository {
  _Preferences(super.db, this.afterPrepare, this.depth);
  final int depth;
  final void Function() afterPrepare;
  @override
  Future<void> setDeviceValue(String key, String value) async {
    await super.setDeviceValue(key, value);
    if (value.isNotEmpty) {
      void later(int left) {
        if (left == 0) {
          afterPrepare();
        } else {
          scheduleMicrotask(() => later(left - 1));
        }
      }

      later(depth);
    }
  }
}

void main() {
  for (final (depth, accountChanges, count, finishOnFree, opens) in [
    (2, false, false, false, true),
    (2, false, true, false, true),
    (2, true, false, false, true),
    (4, true, true, false, true),
    (2, false, false, true, true),
    (2, false, false, false, false),
  ]) {
    testWidgets(
        'web upgrade count=$count accountChanges=$accountChanges '
        'depth=$depth free=$finishOnFree opens=$opens', (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final loading = StateProvider<bool>((ref) => false);
      final nextUser = Completer<AuthUser?>();
      late ProviderContainer container;
      final prefs = _Preferences(
        db,
        () {
          if (accountChanges) container.read(loading.notifier).state = true;
        },
        depth,
      );
      await prefs.setSelectedExamId('exam_upcat');
      var opened = 0;
      final callNames = <String>[];
      Map<String, dynamic>? stored;
      final gateway = WebPaymentGateway(
        callable: (name, __) async {
          callNames.add(name);
          return {
            'checkoutUrl': 'https://checkout.paymongo.com/test',
            'sessionId': 'cs_test',
            'reference': 'ref_test',
          };
        },
        readGrants: (_) async => [],
        refreshClaims: (_) async {},
        openUrl: (_) async {
          opened++;
          expect(await prefs.selectedExamId(), 'exam_upcat');
          final raw = await prefs.deviceValue('checkout_exam_v1:owner');
          stored = jsonDecode(raw!) as Map<String, dynamic>;
          return opens;
        },
      );
      await gateway.logIn('owner');
      final upcat = buildExam(id: 'exam_upcat', shortName: 'UPCAT');
      final cse = buildExam(id: 'exam_cse_pro', shortName: 'CSE Professional');
      final routes = Provider(
        (ref) => GoRouter(
          initialLocation: '/settings/exam',
          routes: settingsRoutes(ref),
        ),
      );
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          appPreferencesRepositoryProvider.overrideWithValue(prefs),
          currentUserProvider.overrideWith(
            (ref) async => ref.watch(loading)
                ? nextUser.future
                : const AuthUser(
                    uid: 'owner',
                    email: 'a@example.com',
                    displayName: 'A',
                  ),
          ),
          isAnonymousProvider.overrideWith((ref) async => false),
          paymentsOnWebProvider.overrideWithValue(true),
          revenueCatGatewayProvider.overrideWithValue(gateway),
          activeExamFocusProvider
              .overrideWith((ref) async => ActiveExamFocus.selected(upcat)),
          examListProvider.overrideWith((ref) async => [upcat, cse]),
          examPickerCatalogProvider.overrideWith(
            (ref) => Stream.value([
              for (final e in [upcat, cse])
                ExamCatalogEntry(
                  id: e.id,
                  name: e.shortName,
                  shortName: e.shortName,
                  priceTier: e == upcat ? 'Student' : 'Civil Service',
                  group: e == upcat ? 'College entrance' : 'Civil service',
                  comingSoon: false,
                  hasContent: true,
                  publishedSittings: const [],
                ),
            ]),
          ),
          entitlementProvider.overrideWith(
            (ref) => Stream.value(
              Entitlement(
                plan: EntitlementPlan.monthly,
                tier: PriceTier.student,
                productId: 'pantas_pro_monthly',
                expiresAt: DateTime.utc(2035),
              ),
            ),
          ),
          carryableCountProvider.overrideWith((ref, id) async => 3),
          unfilteredPaywallOfferingProvider.overrideWith(
            (ref) async => const PaywallOfferingResult(
              status: PaywallOfferingStatus.available,
              recognizedPackages: [
                PaywallPackage(
                  sku: PaywallSku.monthly,
                  productId: 'pantas_cs_monthly',
                  priceString: '₱149',
                  priceAmount: 149,
                  trialEligible: true,
                ),
              ],
            ),
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
      await tester.tap(find.text('Exam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CSE Professional'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/settings/exam/upgrade');
      expect(router.canPop(), isTrue);
      expect(find.text('Try 7 Days Free'), findsNothing);
      expect(find.text('7 DAYS FREE'), findsNothing);
      expect(find.text('No payment needed.'), findsNothing);
      if (finishOnFree) {
        await prefs.setDeviceValue('checkout_exam_v1:owner', 'old intent');
        await tester.tap(find.text('Switch on Free'));
        await tester.pumpAndSettle();
        expect(await prefs.deviceValue('checkout_exam_v1:owner'), isEmpty);
        expect(opened, 0);
        return;
      }
      await tester.tap(find.text('Upgrade for ₱149 a Month'));
      await tester.pumpAndSettle();
      expect(opened, 0);
      await tester.ensureVisible(
        find.text(count ? 'Count Them' : 'Start My Numbers Fresh'),
      );
      await tester
          .tap(find.text(count ? 'Count Them' : 'Start My Numbers Fresh'));
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      if (accountChanges) {
        expect(
          tester
              .widget<PantasButton>(
                find.byWidgetPredicate(
                  (w) =>
                      w is PantasButton &&
                      w.label == 'Upgrade for ₱149 a Month',
                ),
              )
              .busy,
          isFalse,
        );
        expect(opened, 0);
        nextUser.complete(
          const AuthUser(
            uid: 'other',
            email: 'b@example.com',
            displayName: 'B',
          ),
        );
        await tester.pumpAndSettle();
        return;
      }
      expect(opened, 1);
      expect(callNames, ['createPaymongoCheckout']);
      expect(stored!['count'], count);
      expect(stored!['sessionId'], 'cs_test');
      expect(stored!['reference'], 'ref_test');
      expect(stored!['createdAt'], isA<int>());
      expect(
        DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(
            stored!['createdAt'] as int,
          ),
        ),
        lessThan(const Duration(minutes: 1)),
      );
      expect(await prefs.selectedExamId(), 'exam_upcat');
      if (!opens) {
        expect(await prefs.deviceValue('checkout_exam_v1:owner'), isEmpty);
        expect(
          tester
              .widget<PantasButton>(
                find.byWidgetPredicate(
                  (w) =>
                      w is PantasButton &&
                      w.label == 'Upgrade for ₱149 a Month',
                ),
              )
              .busy,
          isFalse,
        );
        return;
      }
      expect(
        (await container.read(settingsRepositoryProvider).readUserSettings())
            .carryOverProgress,
        isTrue,
      );
      if (count) {
        final visit = router.push<void>('/settings/account/name');
        await tester.pumpAndSettle();
        router.pop();
        await visit;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      } else {
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();
      }
      expect(
        tester
            .widget<PantasButton>(
              find.byWidgetPredicate(
                (w) =>
                    w is PantasButton && w.label == 'Upgrade for ₱149 a Month',
              ),
            )
            .busy,
        isFalse,
      );
      expect(await prefs.deviceValue('checkout_exam_v1:owner'), isEmpty);
      router.pop();
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/settings/exam/change');
      expect(await prefs.selectedExamId(), 'exam_upcat');
    });
  }
}
