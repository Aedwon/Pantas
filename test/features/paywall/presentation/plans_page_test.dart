import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/presentation/plans_page.dart';

void main() {
  final today = DateTime(2026, 8, 2);
  const weekly = PaywallPackage(
    sku: PaywallSku.weekly,
    productId: 'pantas_pro_weekly',
    priceString: '₱29',
    priceAmount: 29,
  );
  const monthly = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pantas_pro_monthly',
    priceString: '₱99',
    priceAmount: 99,
  );
  const yearly = PaywallPackage(
    sku: PaywallSku.yearly,
    productId: 'pantas_pro_yearly',
    priceString: '₱799',
    priceAmount: 799,
  );
  const packages = [weekly, monthly, yearly];

  Future<void> pumpPlans(
    WidgetTester tester, {
    required ExamDate? examDate,
    PaywallPackage? selectedPackage,
    ValueChanged<PaywallPackage>? onSelect,
    bool isBusy = false,
    MediaQueryData? mediaQueryData,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        builder: mediaQueryData == null
            ? null
            : (_, child) => MediaQuery(
                  data: mediaQueryData,
                  child: child!,
                ),
        home: PlansPage(
          packages: packages,
          examDate: examDate,
          today: today,
          selectedPackage: selectedPackage ?? monthly,
          onSelect: onSelect ?? (_) {},
          onContinue: () {},
          isBusy: isBusy,
        ),
      ),
    );
  }

  testWidgets('at day precision the column head names the date',
      (tester) async {
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

  testWidgets(
      'with no date the head reads Price and the badge reads Best for most',
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

  testWidgets('Yearly uses the current RevenueCat price', (tester) async {
    await pumpPlans(tester, examDate: null);
    expect(
      find.text('7-day free trial, then ₱799 a year'),
      findsOneWidget,
    );
    expect(find.textContaining('₱999'), findsNothing);
  });

  testWidgets('selected plan exposes selected semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    await pumpPlans(tester, examDate: null, selectedPackage: monthly);

    final node = tester.getSemantics(find.bySemanticsLabel('Monthly plan'));
    expect(node.hasFlag(SemanticsFlag.isSelected), isTrue);
  });

  testWidgets('busy purchase exposes busy semantics and disables plan changes',
      (tester) async {
    var selections = 0;
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    await pumpPlans(
      tester,
      examDate: null,
      isBusy: true,
      onSelect: (_) => selections++,
    );

    expect(find.bySemanticsLabel('Purchase in progress'), findsOneWidget);
    await tester.tap(find.text('Weekly'));
    await tester.pump();
    expect(selections, 0);
  });

  testWidgets('representative plans flow has no overflow at 200 percent text',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpPlans(
      tester,
      examDate: ExamDate.inMonth(year: 2026, month: 10),
      mediaQueryData: const MediaQueryData(
        size: Size(430, 932),
        textScaler: TextScaler.linear(2),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Get Pro. ₱99 a month.'), findsOneWidget);
  });
}
