import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/presentation/widgets/home_performance_section.dart';

void main() {
  testWidgets('failed performance read shows the approved retry state',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          performanceViewProvider.overrideWith((_) async {
            calls++;
            throw StateError('offline');
          }),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const Scaffold(body: HomePerformanceSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load your performance.'), findsOneWidget);
    final state = tester.widget<StateView>(find.byType(StateView));
    expect(state.boardLayout, isTrue);
    expect(find.text('Try Again'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });
}
