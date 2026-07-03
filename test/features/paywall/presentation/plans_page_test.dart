import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:cse_cet_reviewer/features/paywall/presentation/plans_page.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 8, 2);
  const weekly = PaywallPackage(
    sku: PaywallSku.weekly,
    productId: 'pro_weekly',
    priceString: '₱29',
    priceAmount: 29,
  );
  const monthly = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pro_monthly',
    priceString: '₱99',
    priceAmount: 99,
  );
  const yearly = PaywallPackage(
    sku: PaywallSku.yearly,
    productId: 'pro_yearly',
    priceString: '₱999',
    priceAmount: 999,
  );
  final packages = [weekly, monthly, yearly];

  Future<void> pumpPlans(
    WidgetTester tester, {
    required ExamDate? examDate,
    PaywallPackage? selectedPackage,
    ValueChanged<PaywallPackage>? onSelect,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: PlansPage(
            packages: packages,
            examDate: examDate,
            today: today,
            selectedPackage: selectedPackage ?? monthly,
            onSelect: onSelect ?? (_) {},
            onContinue: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('at day precision the column head names the date', (tester) async {
    await pumpPlans(tester, examDate: ExamDate.onDay(DateTime(2026, 10, 12)));
    expect(find.text('Your exam is in 71 days.'), findsOneWidget);
    expect(find.text('Until 12 October'), findsOneWidget);
  });

  testWidgets('at month precision no day count is printed', (tester) async {
    await pumpPlans(tester, examDate: ExamDate.inMonth(year: 2026, month: 10));
    expect(find.text('Your exam is in October 2026.'), findsOneWidget);
    expect(find.text('Through October'), findsOneWidget);
    expect(find.textContaining('days.'), findsNothing);
  });

  testWidgets('with no date the head reads Price and the badge reads Best for most',
      (tester) async {
    await pumpPlans(tester, examDate: null);
    expect(find.text('Choose how long you need it.'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Best for most'), findsOneWidget);
  });

  testWidgets('the rows are always Weekly, Monthly, Yearly in that order',
      (tester) async {
    await pumpPlans(tester, examDate: ExamDate.onDay(DateTime(2026, 10, 12)));
    final weeklyPos = tester.getTopLeft(find.text('Weekly')).dy;
    final monthlyPos = tester.getTopLeft(find.text('Monthly')).dy;
    final yearlyPos = tester.getTopLeft(find.text('Yearly')).dy;
    expect(weeklyPos < monthlyPos && monthlyPos < yearlyPos, isTrue);
  });

  testWidgets('Yearly states that it runs past the exam', (tester) async {
    await pumpPlans(tester, examDate: ExamDate.onDay(DateTime(2026, 10, 12)));
    expect(find.text('294 days past your exam'), findsOneWidget);
  });

  testWidgets('the fine print is verbatim', (tester) async {
    await pumpPlans(tester, examDate: null);
    expect(find.text('Cancel any time. Paid through Google Play.'), findsOneWidget);
  });
}
