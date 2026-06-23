# Paywall 01: the ladder and the live gateway

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**This plan is model-agnostic.** It names no harness-specific skill in its tasks. Read
`AGENTS.md` and `SUBAGENTS.md` before writing a line. Its spec is
`docs/superpowers/specs/2026-08-03-paywall-pricing-and-flow-design.md`, amended 4 August 2026,
and its companion `docs/superpowers/specs/2026-08-02-pro-entitlement-consolidation-design.md`.

**Goal:** Correct the SKU ladder and the recommendation to the settled spec, and replace
`DisabledRevenueCatGateway` with a real `purchases_flutter` implementation so the app can take
money.

**Architecture:** The `RevenueCatGateway` interface already exists and is already the only seam
the rest of the app knows about. This plan drops `lifetime` from the ladder, corrects the
recommendation buckets and copy, adds a `LiveRevenueCatGateway` in `data/`, and selects it by
config. **Nothing in `presentation/` is redrawn here**; that is Paywall 02.

**Tech Stack:** Flutter, Riverpod, `purchases_flutter ^8.0.0` (already declared in
`pubspec.yaml` and currently imported by zero files in `lib/`).

---

## Global Constraints

Every task's requirements implicitly include this section.

- **Do not modify `entitlementProvider`.** `docs/superpowers/2026-08-03-execution-pipeline.md`
  Part 8 names it as a collision between `offline-posture` Task 1 and the paywall rebuild, and
  the offline plan owns it. **The paywall must not undo the cached-wins rule:** last known
  entitlement stands until positively contradicted, and a network failure is not a
  contradiction. If `entitlementProvider` still reads as it does today when you finish, that is
  correct.
- **Do not touch `schemaVersion`** in `lib/core/storage/data/app_database.dart`.
- **No em dashes** anywhere: not in copy, not in comments, not in commit messages. Use a colon
  or a comma.
- **American spelling.** practice, color, behavior, analyze, gray, center, organize.
- **Never put AI attribution in a commit message.** No "Claude", no "Gemini", no
  "Co-Authored-By", no "Generated with". `dart run tool/check_no_ai_attribution.dart` reads
  commit messages and must stay at 0.
- **Scores are "points", never "marks".**
- **Never print a figure this project did not measure.**
- `test/tool/paywall_boundary_test.dart` forbids `package:purchases_flutter/` in
  `lib/features/paywall/domain/`. The live gateway belongs in `data/`.
- `test/tool/paywall_release_guard_test.dart` requires that `FAKE_PRO` appears **only** in
  `lib/features/paywall/application/paywall_providers.dart`, guarded by `kDebugMode`.

### Settled values, copied verbatim from the spec

| SKU ID | Price | Trial |
|---|---|---|
| `pro_weekly` | ₱29 / week | None |
| `pro_monthly` | ₱99 / month | None |
| `pro_yearly` | ₱999 / year | 7 days |

**`pro_lifetime` is removed.** Nothing has to be migrated: no SKUs exist in Play Console or
RevenueCat yet, so no student has ever held one.

| Time to exam | Recommended | Badge |
|---|---|---|
| ≤ 21 days | Weekly | `Best for your exam date` |
| 22 days to 10 months | Monthly | `Best for your exam date` |
| Over 10 months | Yearly | `Best for your exam date` |
| No date, or a past date | **Monthly** | `Best for most` |

**The crossover is 10 months**, because ₱999 ÷ ₱99 = 10.09.

### Gate command

Run after every task. All must pass.

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
dart run tool/check_layering.dart            # expect 7
dart run tool/check_no_ai_attribution.dart   # expect 0
```

`flutter analyze`'s raw count drifts with `tools/`. **The invariant is zero issues under `lib/`
and `test/` outside `test/tool/`.**

---

## File Structure

| File | Responsibility | Task |
|---|---|---|
| `lib/features/paywall/domain/entitlement.dart` | The plan enum and what Pro means. Modify | 1 |
| `lib/features/paywall/domain/paywall_package.dart` | The SKU enum. Modify | 1 |
| `lib/features/settings/domain/delete_account_copy.dart` | Its own plan enum, mirrors the ladder. Modify | 1 |
| `lib/features/legal/domain/legal_document.dart` | Billing copy naming lifetime. Modify | 1 |
| `lib/app/router.dart` | Two exhaustive switch arms over `EntitlementPlan`. Modify | 1 |
| `lib/features/paywall/presentation/subscription_panel.dart` | Lifetime branches. Modify | 1 |
| `lib/features/paywall/presentation/paywall_package_card.dart` | Lifetime label. Modify | 1 |
| `lib/features/paywall/domain/paywall_recommendation.dart` | Buckets, badge, CTA, order. Modify | 2, 3 |
| `lib/features/paywall/data/live_revenuecat_gateway.dart` | **Create.** The real gateway | 4 |
| `lib/features/paywall/data/revenuecat_gateway.dart` | Interface plus the disabled stub. Modify | 4 |
| `lib/features/paywall/application/paywall_providers.dart` | Gateway selection only. Modify | 5 |

---

### Task 1: Remove `lifetime` from the ladder

`lifetime` is threaded through seven files. A partial removal will not compile, because Dart
switch expressions over an enum are exhaustive, so this is one task rather than several.

**Files:**
- Modify: `lib/features/paywall/domain/entitlement.dart`
- Modify: `lib/features/paywall/domain/paywall_package.dart`
- Modify: `lib/features/paywall/domain/paywall_recommendation.dart:31,52`
- Modify: `lib/features/paywall/presentation/subscription_panel.dart:29,65,83`
- Modify: `lib/features/paywall/presentation/paywall_package_card.dart:30,39`
- Modify: `lib/features/settings/domain/delete_account_copy.dart:4,26,36-37,51-53`
- Modify: `lib/features/legal/domain/legal_document.dart:65`
- Modify: `lib/app/router.dart:335,346`
- Test: `test/features/paywall/domain/entitlement_test.dart`
- Test: `test/tool/paywall_docs_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `enum EntitlementPlan { free, weekly, monthly, yearly }` and
  `enum PaywallSku { weekly, monthly, yearly }`. `Entitlement.isLifetime` **is deleted**;
  nothing may reference it after this task. `SettingsEntitlementPlan` drops `lifetime` and
  `SettingsEntitlement.isLifetime` is deleted.

- [ ] **Step 1: Write the failing test**

Add to `test/features/paywall/domain/entitlement_test.dart`:

```dart
test('the ladder has exactly three paid plans and no lifetime', () {
  expect(EntitlementPlan.values, [
    EntitlementPlan.free,
    EntitlementPlan.weekly,
    EntitlementPlan.monthly,
    EntitlementPlan.yearly,
  ]);
  expect(PaywallSku.values, [
    PaywallSku.weekly,
    PaywallSku.monthly,
    PaywallSku.yearly,
  ]);
});
```

Add the import `package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart` at the
top of that file if it is not already present.

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/domain/entitlement_test.dart
```

Expected: FAIL. `EntitlementPlan.values` still contains a fifth element, `lifetime`.

- [ ] **Step 3: Drop the enum members and the getters**

`lib/features/paywall/domain/entitlement.dart`:

```dart
enum EntitlementPlan { free, weekly, monthly, yearly }
```

and delete this line entirely:

```dart
  bool get isLifetime => plan == EntitlementPlan.lifetime;
```

`lib/features/paywall/domain/paywall_package.dart`:

```dart
enum PaywallSku { weekly, monthly, yearly }
```

- [ ] **Step 4: Fix every exhaustive switch and every reference**

`lib/features/paywall/domain/paywall_recommendation.dart` — delete the `lifetime` arm from
both switches, leaving:

```dart
String ctaCopyFor(PaywallPackage package) {
  return switch (package.sku) {
    PaywallSku.weekly => 'Get Pro - ${package.priceString}/week',
    PaywallSku.monthly => 'Get Pro - ${package.priceString}/month',
    PaywallSku.yearly => 'Start 7-day free trial',
  };
}

int _skuRank(PaywallSku sku) {
  return switch (sku) {
    PaywallSku.weekly => 0,
    PaywallSku.monthly => 1,
    PaywallSku.yearly => 2,
  };
}
```

**Leave the copy strings alone in this task.** Task 3 corrects them, and changing them here
would put two unrelated reasons in one commit.

`lib/features/paywall/presentation/subscription_panel.dart`:

```dart
    final canManage = entitlement.proIsActive;
```

Delete the line `if (entitlement.isLifetime) return 'Pro · Lifetime · yours forever.';` and
delete the `EntitlementPlan.lifetime => 'Lifetime',` switch arm.

`lib/features/paywall/presentation/paywall_package_card.dart` — delete the
`PaywallSku.lifetime => 'Lifetime',` arm and the
`PaywallSku.lifetime => '${package.priceString} · Pay once',` arm.

`lib/features/settings/domain/delete_account_copy.dart`:

```dart
enum SettingsEntitlementPlan { free, weekly, monthly, yearly }
```

Delete `bool get isLifetime => plan == SettingsEntitlementPlan.lifetime;`. Then delete the
whole `if (entitlement.isLifetime) { ... }` block at line 36 and the
`if (!entitlement.isLifetime) return null;` guard at line 51 together with the string it
guards. **If deleting the guard at line 51 leaves its enclosing function with no reachable
return, make that function return `null` unconditionally and say so in your report:** that is
a behavior change this plan did not anticipate and it should be checked rather than absorbed.

`lib/features/legal/domain/legal_document.dart:65` — the sentence mentions a "lifetime
purchase". Replace that clause so the sentence reads about subscriptions only, keeping the rest
of the paragraph as it stands.

`lib/app/router.dart` — delete these two arms:

```dart
    EntitlementPlan.lifetime => 'Pro · Lifetime',
      EntitlementPlan.lifetime => SettingsEntitlementPlan.lifetime,
```

**`lib/app/router.dart` is touched by 25 plans.** Change only these two lines. Never resolve a
router conflict on your own; report it.

- [ ] **Step 5: Run the tests and fix the fallout**

```bash
flutter test
```

Expected: the new test passes. Several existing tests reference lifetime and will fail:
`test/features/settings/domain/delete_account_copy_test.dart`,
`test/features/paywall/domain/paywall_recommendation_test.dart`,
`test/features/paywall/presentation/paywall_page_test.dart`,
`test/features/paywall/application/paywall_providers_test.dart`,
`test/features/paywall/presentation/subscription_panel_test.dart`.

**Delete the lifetime cases from those tests rather than rewriting them to assert something
else.** They assert behavior for a plan that can no longer exist.

- [ ] **Step 6: Run the full gate set**

Run the gate command from Global Constraints. All must pass.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat(paywall): the ladder loses lifetime, so no code claims a plan nobody can buy"
```

---

### Task 2: Correct the recommendation buckets

Today `recommendedSkuForExamDate` recommends Yearly with no date and switches to Yearly at 5
months. **At ₱999 the crossover is 10.09 months**, so the current buckets recommend Yearly to a
student for whom Monthly is ₱405 cheaper. The spec calls that dishonest on a surface this
project calls a coach.

**Files:**
- Modify: `lib/features/paywall/domain/paywall_recommendation.dart:3-13`
- Test: `test/features/paywall/domain/paywall_recommendation_test.dart`

**Interfaces:**
- Consumes: `PaywallSku` from Task 1.
- Produces: `PaywallSku recommendedSkuForExamDate({required DateTime today, DateTime? examDate})`
  with the corrected buckets. Signature is unchanged.

- [ ] **Step 1: Write the failing test**

Add to `test/features/paywall/domain/paywall_recommendation_test.dart`:

```dart
group('recommendation buckets at the ₱999 crossover', () {
  final today = DateTime(2026, 8, 4);

  test('no exam date recommends Monthly, not Yearly', () {
    expect(
      recommendedSkuForExamDate(today: today, examDate: null),
      PaywallSku.monthly,
    );
  });

  test('a past exam date recommends Monthly', () {
    expect(
      recommendedSkuForExamDate(today: today, examDate: DateTime(2026, 7, 1)),
      PaywallSku.monthly,
    );
  });

  test('21 days out recommends Weekly', () {
    expect(
      recommendedSkuForExamDate(today: today, examDate: DateTime(2026, 8, 25)),
      PaywallSku.weekly,
    );
  });

  test('22 days out recommends Monthly', () {
    expect(
      recommendedSkuForExamDate(today: today, examDate: DateTime(2026, 8, 26)),
      PaywallSku.monthly,
    );
  });

  test('six months out recommends Monthly, which the old buckets got wrong', () {
    expect(
      recommendedSkuForExamDate(today: today, examDate: DateTime(2027, 2, 4)),
      PaywallSku.monthly,
    );
  });

  test('ten months out still recommends Monthly', () {
    expect(
      recommendedSkuForExamDate(today: today, examDate: DateTime(2027, 6, 4)),
      PaywallSku.monthly,
    );
  });

  test('eleven months out recommends Yearly', () {
    expect(
      recommendedSkuForExamDate(today: today, examDate: DateTime(2027, 7, 4)),
      PaywallSku.yearly,
    );
  });
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/domain/paywall_recommendation_test.dart
```

Expected: FAIL on the no-date case (returns `yearly`, expected `monthly`) and on the six-month
case (returns `yearly`, expected `monthly`).

- [ ] **Step 3: Correct the buckets**

Replace the body of `recommendedSkuForExamDate` in
`lib/features/paywall/domain/paywall_recommendation.dart`:

```dart
PaywallSku recommendedSkuForExamDate({
  required DateTime today,
  DateTime? examDate,
}) {
  // No date, or a date already gone: most students prep for three to six
  // months, and at a 10 month crossover Yearly is not the honest guess.
  if (examDate == null || !examDate.isAfter(today)) {
    return PaywallSku.monthly;
  }
  // Past 3 weekly renewals (₱87) the next one exceeds Monthly's ₱99,
  // so recommending Weekly beyond 21 days would break coach honesty.
  if (examDate.difference(today).inDays <= 21) return PaywallSku.weekly;
  // ₱999 ÷ ₱99 = 10.09, so Monthly is cheaper than Yearly under ten months.
  final months = _wholeMonthsBetween(today, examDate);
  if (months <= 10) return PaywallSku.monthly;
  return PaywallSku.yearly;
}
```

`_wholeMonthsBetween` is unchanged and stays where it is.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/paywall/domain/paywall_recommendation_test.dart
```

Expected: PASS, all seven.

- [ ] **Step 5: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "fix(paywall): recommend Monthly under ten months, because ₱999 moved the crossover"
```

---

### Task 3: Correct the badge and CTA copy

The spec fixes this copy verbatim. Today the badge reads `Best value for most` and the CTA
strings use a hyphen and a different trial phrase.

**Files:**
- Modify: `lib/features/paywall/domain/paywall_recommendation.dart:15-33`
- Test: `test/features/paywall/domain/paywall_recommendation_test.dart`

**Interfaces:**
- Consumes: `PaywallSku` from Task 1.
- Produces: `String recommendationBadgeCopy({required PaywallSku recommended, required bool hasExamDate})`
  and `String ctaCopyFor(PaywallPackage package)`. Signatures are unchanged. Paywall 02 renders
  both and asserts these exact strings.

- [ ] **Step 1: Write the failing test**

```dart
group('badge and CTA copy, verbatim from the spec', () {
  test('with an exam date the badge names the date', () {
    expect(
      recommendationBadgeCopy(
        recommended: PaywallSku.monthly,
        hasExamDate: true,
      ),
      'Best for your exam date',
    );
  });

  test('with no exam date the badge reads Best for most', () {
    expect(
      recommendationBadgeCopy(
        recommended: PaywallSku.monthly,
        hasExamDate: false,
      ),
      'Best for most',
    );
  });

  test('the CTA states the price as a sentence', () {
    expect(
      ctaCopyFor(
        const PaywallPackage(
          sku: PaywallSku.monthly,
          productId: 'pro_monthly',
          priceString: '₱99',
        ),
      ),
      'Get Pro. ₱99 a month.',
    );
    expect(
      ctaCopyFor(
        const PaywallPackage(
          sku: PaywallSku.weekly,
          productId: 'pro_weekly',
          priceString: '₱29',
        ),
      ),
      'Get Pro. ₱29 a week.',
    );
  });

  test('Yearly sends the student to the trial screen instead of naming a price', () {
    expect(
      ctaCopyFor(
        const PaywallPackage(
          sku: PaywallSku.yearly,
          productId: 'pro_yearly',
          priceString: '₱999',
        ),
      ),
      'Start my free trial',
    );
  });

  test('no copy contains an em dash', () {
    final all = [
      recommendationBadgeCopy(recommended: PaywallSku.monthly, hasExamDate: true),
      recommendationBadgeCopy(recommended: PaywallSku.monthly, hasExamDate: false),
      ctaCopyFor(
        const PaywallPackage(
          sku: PaywallSku.yearly,
          productId: 'pro_yearly',
          priceString: '₱999',
        ),
      ),
    ];
    for (final copy in all) {
      expect(copy.contains('—'), isFalse, reason: copy);
    }
  });
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/domain/paywall_recommendation_test.dart
```

Expected: FAIL. The badge returns `Best value for most`, and the CTA returns
`Get Pro - ₱99/month`.

- [ ] **Step 3: Correct the copy**

```dart
String recommendationBadgeCopy({
  required PaywallSku recommended,
  required bool hasExamDate,
}) {
  if (!hasExamDate) return 'Best for most';
  return 'Best for your exam date';
}

String ctaCopyFor(PaywallPackage package) {
  return switch (package.sku) {
    PaywallSku.weekly => 'Get Pro. ${package.priceString} a week.',
    PaywallSku.monthly => 'Get Pro. ${package.priceString} a month.',
    // Yearly is the only SKU with a trial, so its CTA opens screen 3
    // rather than naming a price the student has not agreed to yet.
    PaywallSku.yearly => 'Start my free trial',
  };
}
```

**The spec also allows a dated badge**, `Best for 12 Oct` where the day is known. That variant
belongs to Paywall 02, which is the plan that knows the exam date's precision. Do not add it
here.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/paywall/domain/paywall_recommendation_test.dart
```

Expected: PASS.

- [ ] **Step 5: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "fix(paywall): badge and CTA copy match the spec word for word"
```

---

### Task 4: The live RevenueCat gateway

**This is the task that lets the app take money.** Today `purchase()` returns Free and no
student can buy anything.

**Files:**
- Create: `lib/features/paywall/data/live_revenuecat_gateway.dart`
- Test: `test/features/paywall/data/live_revenuecat_gateway_test.dart`

**Interfaces:**
- Consumes: `RevenueCatGateway`, `Entitlement`, `EntitlementPlan`, `PaywallPackage`,
  `PaywallSku` from Task 1.
- Produces: `class LiveRevenueCatGateway implements RevenueCatGateway`, and two pure functions
  that Task 5 does not use but the tests do:
  `Entitlement entitlementFromCustomerInfo(CustomerInfo info)` and
  `PaywallSku? skuFromProductId(String productId)`.

- [ ] **Step 0: Confirm the SDK surface before writing against it**

`purchases_flutter` changed its purchase API between major versions. **Confirm which one is
installed** rather than trusting this plan:

```bash
grep -n "purchases_flutter" pubspec.lock
grep -rn "static Future<PurchaseResult> purchase\|static Future<CustomerInfo> purchasePackage" \
  ~/.pub-cache/hosted/pub.dev/purchases_flutter-*/lib/purchases_flutter.dart
```

Expected on 8.x: `Purchases.purchase(PurchaseParams)` returning `PurchaseResult`. **If the
installed version instead exposes `purchasePackage` returning `CustomerInfo`, stop and say
so.** Do not guess and do not change the pubspec constraint to make this plan fit.

- [ ] **Step 1: Write the failing test**

Create `test/features/paywall/data/live_revenuecat_gateway_test.dart`. These tests cover the
mapping, which is the part that carries the money risk. The SDK calls themselves are not
mocked here because that would test the mock.

```dart
import 'package:cse_cet_reviewer/features/paywall/data/live_revenuecat_gateway.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('skuFromProductId', () {
    test('maps the three settled product ids', () {
      expect(skuFromProductId('pro_weekly'), PaywallSku.weekly);
      expect(skuFromProductId('pro_monthly'), PaywallSku.monthly);
      expect(skuFromProductId('pro_yearly'), PaywallSku.yearly);
    });

    test('an unknown product id maps to null rather than to a guess', () {
      expect(skuFromProductId('pro_lifetime'), isNull);
      expect(skuFromProductId(''), isNull);
      expect(skuFromProductId('cse_cet_pro_monthly'), isNull);
    });

    test('a Play base plan suffix still resolves', () {
      expect(skuFromProductId('pro_monthly:monthly-autorenewing'),
          PaywallSku.monthly);
    });
  });

  group('planForSku', () {
    test('each SKU has exactly one plan', () {
      expect(planForSku(PaywallSku.weekly), EntitlementPlan.weekly);
      expect(planForSku(PaywallSku.monthly), EntitlementPlan.monthly);
      expect(planForSku(PaywallSku.yearly), EntitlementPlan.yearly);
    });
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/data/live_revenuecat_gateway_test.dart
```

Expected: FAIL to compile. `live_revenuecat_gateway.dart` does not exist.

- [ ] **Step 3: Write the gateway**

Create `lib/features/paywall/data/live_revenuecat_gateway.dart`:

```dart
import 'dart:async';

import 'package:cse_cet_reviewer/features/paywall/data/revenuecat_gateway.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// The RevenueCat entitlement identifier configured in the dashboard.
/// One entitlement covers all three SKUs.
const proEntitlementId = 'pro';

const _weeklyProductId = 'pro_weekly';
const _monthlyProductId = 'pro_monthly';
const _yearlyProductId = 'pro_yearly';

/// Google Play appends a base plan id to the product id, as in
/// `pro_monthly:monthly-autorenewing`. Compare on the part before the colon.
PaywallSku? skuFromProductId(String productId) {
  final base = productId.split(':').first;
  return switch (base) {
    _weeklyProductId => PaywallSku.weekly,
    _monthlyProductId => PaywallSku.monthly,
    _yearlyProductId => PaywallSku.yearly,
    _ => null,
  };
}

EntitlementPlan planForSku(PaywallSku sku) {
  return switch (sku) {
    PaywallSku.weekly => EntitlementPlan.weekly,
    PaywallSku.monthly => EntitlementPlan.monthly,
    PaywallSku.yearly => EntitlementPlan.yearly,
  };
}

Entitlement entitlementFromCustomerInfo(CustomerInfo info) {
  final active = info.entitlements.active[proEntitlementId];
  if (active == null) return const Entitlement.free();

  final sku = skuFromProductId(active.productIdentifier);
  // An active entitlement on a product this build does not know about is a
  // paid student. Treat it as Pro on the monthly plan rather than as Free:
  // failing closed here would take Pro from someone who paid for it.
  final plan = sku == null ? EntitlementPlan.monthly : planForSku(sku);

  return Entitlement(
    plan: plan,
    productId: active.productIdentifier,
    expiresAt: active.expirationDate == null
        ? null
        : DateTime.tryParse(active.expirationDate!),
    isTrial: active.periodType == PeriodType.trial,
    willRenew: active.willRenew,
  );
}

class LiveRevenueCatGateway implements RevenueCatGateway {
  LiveRevenueCatGateway();

  final _controller = StreamController<Entitlement>.broadcast();
  Entitlement? _cached;
  bool _listening = false;

  @override
  Entitlement? get cachedEntitlement => _cached;

  @override
  Stream<Entitlement> get customerInfoUpdates => _controller.stream;

  @override
  Future<void> configure({required String androidApiKey}) async {
    await Purchases.configure(PurchasesConfiguration(androidApiKey));
    if (!_listening) {
      _listening = true;
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
    }
    final info = await Purchases.getCustomerInfo();
    _onCustomerInfo(info);
  }

  void _onCustomerInfo(CustomerInfo info) {
    final entitlement = entitlementFromCustomerInfo(info);
    _cached = entitlement;
    if (!_controller.isClosed) _controller.add(entitlement);
  }

  @override
  Future<void> logIn(String uid) async {
    final result = await Purchases.logIn(uid);
    _onCustomerInfo(result.customerInfo);
  }

  @override
  Future<List<PaywallPackage>> currentOffering() async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) return const [];

    final packages = <PaywallPackage>[];
    for (final package in current.availablePackages) {
      final product = package.storeProduct;
      final sku = skuFromProductId(product.identifier);
      // A product the ladder does not name is not shown. The ladder is three
      // SKUs and a fourth appearing on screen would be a pricing bug.
      if (sku == null) continue;
      packages.add(
        PaywallPackage(
          sku: sku,
          productId: product.identifier,
          priceString: product.priceString,
        ),
      );
    }
    return packages;
  }

  @override
  Future<Entitlement> purchase(PaywallPackage package) async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) {
      throw StateError('No current offering configured in RevenueCat.');
    }
    final target = current.availablePackages.firstWhere(
      (candidate) => candidate.storeProduct.identifier == package.productId,
      orElse: () => throw StateError(
        'Product ${package.productId} is not in the current offering.',
      ),
    );

    final result = await Purchases.purchase(PurchaseParams.package(target));
    final entitlement = entitlementFromCustomerInfo(result.customerInfo);
    _cached = entitlement;
    return entitlement;
  }

  @override
  Future<Entitlement> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    final entitlement = entitlementFromCustomerInfo(info);
    _cached = entitlement;
    return entitlement;
  }
}
```

**If `PurchaseParams.package` does not exist in the installed version**, Step 0 told you to
stop. Stop here rather than substituting `purchasePackage`.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/paywall/data/live_revenuecat_gateway_test.dart
```

Expected: PASS, all five.

- [ ] **Step 5: Confirm the boundary test still passes**

```bash
flutter test test/tool/paywall_boundary_test.dart
```

Expected: PASS. `purchases_flutter` is imported in `data/`, never in `domain/`.

- [ ] **Step 6: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat(paywall): a real gateway, so a student can actually buy Pro"
```

---

### Task 5: Select the live gateway by config

`revenueCatGatewayProvider` returns `DisabledRevenueCatGateway` unconditionally.
`RevenueCatConfig.fromEnvironment()` already knows whether a key is present.

**Files:**
- Modify: `lib/features/paywall/application/paywall_providers.dart:8-10`
- Test: `test/features/paywall/application/paywall_providers_test.dart`

**Interfaces:**
- Consumes: `LiveRevenueCatGateway` from Task 4, `RevenueCatConfig` as it already stands.
- Produces: `revenueCatGatewayProvider` returning a live gateway when a key is configured and
  the disabled stub otherwise. **`entitlementProvider` is not modified.**

- [ ] **Step 1: Write the failing test**

```dart
test('the gateway is disabled when no API key is configured', () {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  // No REVENUECAT_ANDROID_API_KEY is defined in a test run, so the config
  // reports disabled and the stub is the correct choice.
  expect(
    container.read(revenueCatGatewayProvider),
    isA<DisabledRevenueCatGateway>(),
  );
});

test('the disabled gateway never reports Pro', () async {
  const gateway = DisabledRevenueCatGateway();
  final entitlement = await gateway.purchase(
    const PaywallPackage(
      sku: PaywallSku.monthly,
      productId: 'pro_monthly',
      priceString: '₱99',
    ),
  );
  expect(entitlement.proIsActive, isFalse);
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/application/paywall_providers_test.dart
```

Expected: the first test may already pass, since the stub is returned unconditionally. **That
is not a failure you may skip over.** Add this assertion, which does fail today, to prove the
selection is real rather than incidental:

```dart
test('gateway selection reads the config rather than being hard coded', () {
  final container = ProviderContainer(
    overrides: [
      revenueCatConfigProvider.overrideWithValue(
        RevenueCatConfig.fromEnvironment(androidApiKey: 'goog_test_key'),
      ),
    ],
  );
  addTearDown(container.dispose);
  expect(
    container.read(revenueCatGatewayProvider),
    isA<LiveRevenueCatGateway>(),
  );
});
```

This fails to compile: `revenueCatConfigProvider` does not exist yet.

- [ ] **Step 3: Add the config provider and the selection**

In `lib/features/paywall/application/paywall_providers.dart`, add the import for
`live_revenuecat_gateway.dart` and `revenuecat_config.dart`, then replace the gateway provider:

```dart
final revenueCatConfigProvider = Provider<RevenueCatConfig>(
  (ref) => RevenueCatConfig.fromEnvironment(),
);

final revenueCatGatewayProvider = Provider<RevenueCatGateway>((ref) {
  final config = ref.watch(revenueCatConfigProvider);
  if (!config.isEnabled) return const DisabledRevenueCatGateway();
  return LiveRevenueCatGateway();
});
```

**Do not touch `entitlementProvider` in this file.** It is directly below and it belongs to
`offline-posture` Task 1. Leave every line of it exactly as you found it.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/paywall/application/paywall_providers_test.dart
```

Expected: PASS, all three.

- [ ] **Step 5: Confirm the release guard still passes**

```bash
flutter test test/tool/paywall_release_guard_test.dart
```

Expected: PASS. `FAKE_PRO` still appears only in this file, still guarded by `kDebugMode`.

- [ ] **Step 6: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat(paywall): use the live gateway when a key is configured"
```

---

### Task 6: Carry the numeric price

`PaywallPackage` holds only `priceString`, a display string. **Screen 2 multiplies the price by
a number of renewals**, which a string cannot do, and Paywall 02 cannot compute a single figure
without this. Adding it here keeps the gateway the only thing that reads the store.

**Files:**
- Modify: `lib/features/paywall/domain/paywall_package.dart`
- Modify: `lib/features/paywall/data/live_revenuecat_gateway.dart`
- Test: `test/features/paywall/data/live_revenuecat_gateway_test.dart`

**Interfaces:**
- Consumes: `PaywallPackage` from Task 1, `LiveRevenueCatGateway` from Task 4.
- Produces: `PaywallPackage` gains `final double priceAmount`, required. Paywall 02 reads it for
  every figure on screen 2. `priceString` stays and is still what gets printed for a single
  period, because it carries the store's own currency formatting.

- [ ] **Step 1: Write the failing test**

```dart
test('a package carries the numeric price as well as the display string', () {
  const package = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pro_monthly',
    priceString: '₱99.00',
    priceAmount: 99,
  );
  expect(package.priceAmount, 99);
  expect(package.priceString, '₱99.00');
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/data/live_revenuecat_gateway_test.dart
```

Expected: FAIL to compile. `PaywallPackage` has no named parameter `priceAmount`.

- [ ] **Step 3: Add the field**

`lib/features/paywall/domain/paywall_package.dart`:

```dart
enum PaywallSku { weekly, monthly, yearly }

class PaywallPackage {
  const PaywallPackage({
    required this.sku,
    required this.productId,
    required this.priceString,
    required this.priceAmount,
  });

  final PaywallSku sku;
  final String productId;

  /// The store's own formatted price, currency symbol included. Print this
  /// for a single period; never build it by hand from priceAmount.
  final String priceString;

  /// The same price as a number, for the multi-period arithmetic on the
  /// plans screen. A string cannot be multiplied by a renewal count.
  final double priceAmount;
}
```

In `live_revenuecat_gateway.dart`, populate it inside `currentOffering`:

```dart
      packages.add(
        PaywallPackage(
          sku: sku,
          productId: product.identifier,
          priceString: product.priceString,
          priceAmount: product.price,
        ),
      );
```

- [ ] **Step 4: Fix every other construction site**

```bash
flutter analyze
```

Every `PaywallPackage(` without `priceAmount` is now an error. Add the matching number to each,
in `test/features/paywall/**` and anywhere in `lib/` that builds one. **The value must equal
the `priceString` it sits beside**; a test that pairs `'₱99'` with `priceAmount: 29` would pass
and be wrong.

- [ ] **Step 5: Run the tests**

```bash
flutter test
```

Expected: PASS.

- [ ] **Step 6: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat(paywall): carry the numeric price, because the plans screen multiplies it"
```

---

## What this plan deliberately does not do

- **It does not modify `entitlementProvider`.** `offline-posture` Task 1 owns it and the
  cached-wins rule must survive this plan untouched.
- **It does not redraw any screen.** Paywall 02 owns the three screens, the sample specimen and
  the trial timeline. `paywall_page.dart`, `paywall_package_card.dart` and
  `subscription_panel.dart` are edited here **only** to drop lifetime and keep the build green.
- **It does not add the missing type tokens.** Section 7 of the spec was corrected on 4 August
  to record that five of its seven sizes do not exist in `AppTextStyles`. Adding them belongs to
  `settings-01-the-kit`, which owns that file, and Paywall 02 depends on it.
- **It does not create the products.** `plans/2026-05-21-paywall-live-validation.md` covers
  Play Console and RevenueCat setup, and it needs `pro_lifetime` dropped and Yearly moved to
  ₱999. That is Aedwon's, on his own account.

## Verification for the whole plan

```bash
grep -rn "lifetime\|Lifetime" lib | grep -v "\.g\.dart"
```

Expected: **nothing.**

```bash
grep -rn "₱126\|₱42\|₱499" lib
```

Expected: **nothing.**

```bash
grep -rn "purchases_flutter" lib
```

Expected: exactly one file, `lib/features/paywall/data/live_revenuecat_gateway.dart`.

- A student with an exam six months out is recommended Monthly.
- A student with no exam date is recommended Monthly, badged `Best for most`.
- `entitlementProvider` in `paywall_providers.dart` is byte-identical to how this plan found it.
