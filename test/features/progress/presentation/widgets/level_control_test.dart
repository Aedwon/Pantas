import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/progress/application/table_order_prefs.dart';
import 'package:pantas/features/progress/presentation/widgets/level_control.dart';

void main() {
  Widget harness({
    TableLevel level = TableLevel.subject,
    bool isPro = true,
    bool lessonAvailable = true,
    ValueChanged<TableLevel>? onChanged,
    VoidCallback? onLocked,
  }) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: LevelControl(
          level: level,
          isPro: isPro,
          lessonAvailable: lessonAvailable,
          onChanged: onChanged ?? (_) {},
          onLocked: onLocked ?? () {},
        ),
      ),
    );
  }

  testWidgets('three labels, active in ink at 700', (tester) async {
    await tester.pumpWidget(harness(level: TableLevel.topic));

    expect(
      tester.widget<Text>(find.text('Topic')).style?.fontWeight,
      FontWeight.w700,
    );
    expect(
      tester.widget<Text>(find.text('Subject')).style?.color,
      AppColors.light.inkMuted,
    );
  });

  testWidgets('Free sees Topic and Lesson dimmed, not hidden', (tester) async {
    await tester.pumpWidget(harness(isPro: false));

    expect(find.text('Topic'), findsOneWidget);
    expect(find.text('Lesson'), findsOneWidget);
  });

  testWidgets('Free cannot change the level', (tester) async {
    final changes = <TableLevel>[];
    await tester.pumpWidget(harness(isPro: false, onChanged: changes.add));

    await tester.tap(find.text('Topic'));
    expect(changes, isEmpty);
  });

  testWidgets('a dimmed label routes to the paywall', (tester) async {
    var locked = 0;
    await tester.pumpWidget(
      harness(isPro: false, onLocked: () => locked += 1),
    );

    await tester.tap(find.text('Topic'));
    expect(locked, 1);
  });

  testWidgets('Pro can change the level', (tester) async {
    final changes = <TableLevel>[];
    await tester.pumpWidget(harness(onChanged: changes.add));

    await tester.tap(find.text('Lesson'));
    expect(changes, [TableLevel.lesson]);
  });

  testWidgets('without lesson tagging the label is absent, not dimmed',
      (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(
        harness(isPro: isPro, lessonAvailable: false),
      );

      expect(find.text('Lesson'), findsNothing);
      expect(find.text('Subject'), findsOneWidget);
      expect(find.text('Topic'), findsOneWidget);
    }
  });

  testWidgets('no pills and no picker', (tester) async {
    await tester.pumpWidget(harness());

    expect(find.byType(Chip), findsNothing);
    expect(find.byType(DropdownButton<Object>), findsNothing);
    expect(find.byType(SegmentedButton<Object>), findsNothing);
  });
}
