import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_providers.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/progress/application/miss_causes_provider.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/progress_page.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/widgets/why_you_miss_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

Widget harness({
  required bool isPro,
  int? right,
  int? never,
  int? fast,
  int selfNoted = 0,
  MissCauses? causes,
}) {
  final missCauses = causes ??
      (right != null && never != null && fast != null
          ? MissCauses(
              hadItRightBefore: right,
              neverSeenIt: never,
              answeredTooFast: fast,
              topicsByCause: const {},
              selfNotedMisreads: selfNoted,
            )
          : null);

  final exam = buildExam(
    id: 'cse',
    code: 'CSE',
    name: 'Civil Service Exam',
    shortName: 'CSE',
  );

  return ProviderScope(
    key: UniqueKey(),
    overrides: [
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(exam),
      ),
      countForExamProvider('cse').overrideWith((ref) async => 5),
      entitlementProvider.overrideWith(
        (ref) => Stream.value(
          Entitlement(
            plan: isPro ? EntitlementPlan.monthly : EntitlementPlan.free,
          ),
        ),
      ),
      missCausesProvider.overrideWith((ref) async => missCauses),
    ],
    child: MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        extensions: [AppColors.light, AppTextStyles.create()],
      ),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: WhyYouMissSection(),
        ),
      ),
    ),
  );
}

Widget fullTabHarness({required bool isPro}) {
  final exam = buildExam(
    id: 'cse',
    code: 'CSE',
    name: 'Civil Service Exam',
    shortName: 'CSE',
  );

  const dummyCauses = MissCauses(
    hadItRightBefore: 6,
    neverSeenIt: 3,
    answeredTooFast: 2,
    topicsByCause: {},
    selfNotedMisreads: 0,
  );

  return ProviderScope(
    overrides: [
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(exam),
      ),
      countForExamProvider('cse').overrideWith((ref) async => 5),
      entitlementProvider.overrideWith(
        (ref) => Stream.value(
          Entitlement(
            plan: isPro ? EntitlementPlan.monthly : EntitlementPlan.free,
          ),
        ),
      ),
      missCausesProvider.overrideWith((ref) async => dummyCauses),
    ],
    child: MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        extensions: [AppColors.light, AppTextStyles.create()],
      ),
      home: const ProgressPage(),
    ),
  );
}

void main() {
  testWidgets('Pro sees three counts and one sentence', (tester) async {
    await tester.pumpWidget(
      harness(isPro: true, right: 6, never: 3, fast: 2),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('6'), findsWidgets);
    expect(find.textContaining('had it right before'), findsOneWidget);
    expect(find.textContaining('never seen it'), findsOneWidget);
    expect(find.textContaining('answered too fast'), findsOneWidget);
    expect(
      find.text(
        'You mostly know this material already. What is missing is a second '
        'pass, not a first one.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the sentence follows the largest count', (tester) async {
    await tester.pumpWidget(harness(isPro: true, right: 1, never: 9, fast: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('This is new ground'), findsOneWidget);

    await tester.pumpWidget(harness(isPro: true, right: 1, never: 2, fast: 9));
    await tester.pumpAndSettle();
    expect(find.textContaining('Slowing down'), findsOneWidget);
  });

  testWidgets('a tie prints exactly one sentence', (tester) async {
    await tester.pumpWidget(harness(isPro: true, right: 4, never: 4, fast: 4));
    await tester.pumpAndSettle();

    expect(find.textContaining('second pass'), findsOneWidget);
    expect(find.textContaining('new ground'), findsNothing);
    expect(find.textContaining('Slowing down'), findsNothing);
  });

  testWidgets('Free sees labels and bars, never the counts', (tester) async {
    await tester.pumpWidget(
      harness(isPro: false, right: 6, never: 3, fast: 2),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('had it right before'), findsOneWidget);
    expect(find.text('6'), findsNothing);
    expect(find.byType(FaintBars), findsWidgets);
    expect(find.text('Unlock with Pro'), findsOneWidget);
  });

  testWidgets('no lock icon, no blur, no banner', (tester) async {
    await tester.pumpWidget(harness(isPro: false, right: 6, never: 3, fast: 2));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.lock), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('exactly one teaser on the whole tab', (tester) async {
    await tester.pumpWidget(fullTabHarness(isPro: false));
    await tester.pumpAndSettle();
    expect(find.text('Unlock with Pro'), findsOneWidget);
  });

  testWidgets('the teaser sits after the free content, never before it',
      (tester) async {
    await tester.pumpWidget(fullTabHarness(isPro: false));
    await tester.pumpAndSettle();

    final paceY = tester.getTopLeft(find.text('Your pace')).dy;
    final teaserY = tester.getTopLeft(find.text('Unlock with Pro')).dy;
    expect(paceY, lessThan(teaserY));
  });

  testWidgets('no misses renders no section, on either tier', (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(harness(isPro: isPro, causes: null));
      await tester.pumpAndSettle();
      expect(find.textContaining('had it right before'), findsNothing);
    }
  });

  testWidgets('Pro extras are absent, not zero, without their data',
      (tester) async {
    await tester.pumpWidget(
      harness(isPro: true, right: 6, never: 3, fast: 2, selfNoted: 0),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('you noted'), findsNothing);
    expect(find.text('0'), findsNothing);
  });
}
