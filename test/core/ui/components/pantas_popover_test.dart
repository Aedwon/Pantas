import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_popover.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

import '../../../helpers/ds_matrix.dart';

class _Host extends StatefulWidget {
  const _Host({
    this.role = PantasPopoverRole.menu,
    this.onPick,
    this.top = 120,
  });

  final PantasPopoverRole role;
  final ValueChanged<int>? onPick;
  final double top;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final controller = PantasPopoverController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: widget.top),
        child: PantasPopover(
          controller: controller,
          role: widget.role,
          label: 'Sort by',
          trigger: TextButton(
            onPressed: controller.toggle,
            child: const Text('Sort'),
          ),
          children: [
            for (var i = 0; i < 3; i++)
              PantasPopoverItem(
                label: ['Weakest first', 'Strongest first', 'A to Z'][i],
                selected: widget.role == PantasPopoverRole.picker && i == 1,
                check: widget.role == PantasPopoverRole.picker,
                onPressed: () {
                  widget.onPick?.call(i);
                  controller.close();
                },
              ),
            const PantasPopoverSeparator(),
            const PantasPopoverItem(label: 'Disabled'),
          ],
        ),
      );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Sort'));
  await tester.pump();
  await tester.pump(PantasDurations.medium1);
}

void main() {
  tearDown(resetWebKeyboardFocus);

  for (final role in PantasPopoverRole.values) {
    dsMatrix(
      'Popover $role fits every width, theme and text scale',
      (context) => _Host(role: role),
      check: (tester, cell) async {
        await _open(tester);
        expect(tester.takeException(), isNull);
        final colors = cell.dark ? PantasColors.dark : PantasColors.light;
        final shadows = cell.dark ? PantasShadow.dark : PantasShadow.light;
        final surface = tester.widget<DecoratedBox>(
          find.byKey(const ValueKey('pantas-popover-surface')),
        );
        final box = surface.decoration as BoxDecoration;
        expect(box.color, colors.surfaceCard);
        expect(box.borderRadius, BorderRadius.circular(PantasRadius.lg));
        expect(box.boxShadow, shadows.popover);
        final rect = tester
            .getRect(find.byKey(const ValueKey('pantas-popover-surface')));
        expect(rect.width, greaterThanOrEqualTo(PantasPopover.minWidth));
        expect(rect.width, lessThanOrEqualTo(PantasPopover.maxWidth));
        expect(rect.height, lessThanOrEqualTo(PantasPopover.maxHeight));
        // 8 below the trigger, aligned to its left edge.
        final trigger = tester.getRect(find.text('Sort')).inflate(0);
        expect(rect.top, greaterThan(trigger.bottom));
        // Items are 40 high at least, with a 44 target.
        for (final label in ['Weakest first', 'A to Z']) {
          final item = tester.getRect(
            find
                .ancestor(
                  of: find.text(label),
                  matching: find.byType(AnimatedContainer),
                )
                .first,
          );
          expect(item.height, greaterThanOrEqualTo(40));
        }
      },
    );
  }

  testWidgets('Picker shows a check on the selected item as well as the tint',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      const _Host(role: PantasPopoverRole.picker),
    );
    await _open(tester);
    // Selection is not color alone: the chosen row ends with a check.
    expect(
      find.byWidgetPredicate((w) => w is Icon && w.icon == PantasIcons.check),
      findsOneWidget,
    );
    const colors = PantasColors.light;
    final selected = tester.widget<AnimatedContainer>(
      find
          .ancestor(
            of: find.text('Strongest first'),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    expect((selected.decoration! as BoxDecoration).color, colors.accentTint);
    final text = tester.widget<Text>(find.text('Strongest first'));
    expect(text.style!.fontWeight, FontWeight.w600);
    expect(text.style!.color, colors.accentTintText);
  });

  testWidgets('Esc closes it and an outside tap closes it', (tester) async {
    await pumpDs(tester, dsCells.first, const _Host());
    await _open(tester);
    expect(find.text('Weakest first'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Weakest first'), findsNothing);
    await _open(tester);
    await tester.tapAt(const Offset(5, 700));
    await tester.pumpAndSettle();
    expect(find.text('Weakest first'), findsNothing);
  });

  testWidgets('Choosing an item fires and closes', (tester) async {
    final picked = <int>[];
    await pumpDs(tester, dsCells.first, _Host(onPick: picked.add));
    await _open(tester);
    await tester.tap(find.text('A to Z'));
    await tester.pumpAndSettle();
    expect(picked, [2]);
    expect(find.text('A to Z'), findsNothing);
  });

  testWidgets('A disabled item cannot be chosen or focused', (tester) async {
    final picked = <int>[];
    await pumpDs(tester, dsCells.first, _Host(onPick: picked.add));
    await _open(tester);
    await tester.tap(find.text('Disabled'));
    await tester.pump();
    expect(picked, isEmpty);
    const colors = PantasColors.light;
    expect(
      tester.widget<Text>(find.text('Disabled')).style!.color,
      colors.textDisabled,
    );
  });

  testWidgets('Arrow keys move between items and Enter chooses',
      (tester) async {
    final picked = <int>[];
    await pumpDs(tester, dsCells.first, _Host(onPick: picked.add));
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(picked.length, 1);
  });

  testWidgets('It flips above the trigger when there is no room below',
      (tester) async {
    await pumpDs(tester, dsCells.first, const _Host(top: 780));
    await tester.tap(find.text('Sort'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(PantasDurations.medium1);
    final trigger = tester.getRect(find.text('Sort'));
    final rect =
        tester.getRect(find.byKey(const ValueKey('pantas-popover-surface')));
    expect(rect.bottom, lessThanOrEqualTo(trigger.top));
  });

  testWidgets('Reduced motion fades in place with no rise', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: const _Host(),
        ),
      ),
    );
    await tester.tap(find.text('Sort'));
    await tester.pump();
    final first = tester
        .getTopLeft(find.byKey(const ValueKey('pantas-popover-surface')))
        .dy;
    await tester.pump(PantasDurations.medium1);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('pantas-popover-surface')))
          .dy,
      first,
    );
  });
}
