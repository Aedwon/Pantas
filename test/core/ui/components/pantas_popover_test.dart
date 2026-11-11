import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_popover.dart';
import 'package:pantas/core/ui/components/typeahead_buffer.dart';
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
  final triggerFocus = FocusNode();

  @override
  void dispose() {
    triggerFocus.dispose();
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
            focusNode: triggerFocus,
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

/// The label of the popover item that holds keyboard focus, or null.
String? _focusedLabel() => FocusManager.instance.primaryFocus?.context
    ?.findAncestorWidgetOfExactType<PantasPopoverItem>()
    ?.label;

_HostState _host(WidgetTester tester) =>
    tester.state<_HostState>(find.byType(_Host));

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump();
}

Future<void> _type(
  WidgetTester tester,
  LogicalKeyboardKey key,
  String ch,
) async {
  await tester.sendKeyDownEvent(key, character: ch);
  await tester.sendKeyUpEvent(key);
  await tester.pump();
}

Future<void> _openByKeyboard(WidgetTester tester) async {
  _host(tester).triggerFocus.requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
  await tester.pump();
  await tester.pump(PantasDurations.medium1);
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Sort'));
  await tester.pump();
  await tester.pump(PantasDurations.medium1);
}

void main() {
  setUpAll(loadDsFonts);

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

  group('keyboard (Popover README)', () {
    testWidgets('Down Arrow on the trigger opens it and focuses the first item',
        (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      await _openByKeyboard(tester);
      expect(find.text('Weakest first'), findsOneWidget);
      expect(_focusedLabel(), 'Weakest first');
    });

    testWidgets('opening focuses the selected item of a picker',
        (tester) async {
      await pumpDs(
        tester,
        dsCells.first,
        const _Host(role: PantasPopoverRole.picker),
      );
      await _openByKeyboard(tester);
      expect(_focusedLabel(), 'Strongest first');
    });

    testWidgets('Down and Up wrap and skip the disabled item', (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      await _openByKeyboard(tester);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_focusedLabel(), 'Strongest first');
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_focusedLabel(), 'A to Z');
      // The last enabled item wraps to the first, not onto Disabled.
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_focusedLabel(), 'Weakest first');
      // The first wraps back to the last enabled item.
      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(_focusedLabel(), 'A to Z');
    });

    testWidgets('Home and End jump to the first and last enabled item',
        (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      await _openByKeyboard(tester);
      await _key(tester, LogicalKeyboardKey.end);
      expect(_focusedLabel(), 'A to Z');
      await _key(tester, LogicalKeyboardKey.home);
      expect(_focusedLabel(), 'Weakest first');
    });

    testWidgets('typing letters jumps to the item that starts with them',
        (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      await _openByKeyboard(tester);
      await _type(tester, LogicalKeyboardKey.keyS, 's');
      expect(_focusedLabel(), 'Strongest first');
      // Letters inside the window extend the prefix: "s" then "t".
      await _type(tester, LogicalKeyboardKey.keyT, 't');
      expect(_focusedLabel(), 'Strongest first');
      // Past the typeahead window a new letter starts a new prefix.
      await tester.runAsync(
        () => Future<void>.delayed(
          TypeaheadBuffer.window + const Duration(milliseconds: 100),
        ),
      );
      await _type(tester, LogicalKeyboardKey.keyA, 'a');
      expect(_focusedLabel(), 'A to Z');
    });

    testWidgets('typeahead never lands on a disabled item', (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      await _openByKeyboard(tester);
      await _type(tester, LogicalKeyboardKey.keyD, 'd');
      expect(_focusedLabel(), isNot('Disabled'));
    });

    testWidgets('Esc closes it and returns focus to the trigger',
        (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      await _openByKeyboard(tester);
      await _key(tester, LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Weakest first'), findsNothing);
      expect(_host(tester).triggerFocus.hasFocus, isTrue);
    });

    testWidgets('Tab closes it', (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      await _openByKeyboard(tester);
      await _key(tester, LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(find.text('Weakest first'), findsNothing);
    });

    testWidgets('choosing with Enter closes it and returns focus',
        (tester) async {
      final picked = <int>[];
      await pumpDs(tester, dsCells.first, _Host(onPick: picked.add));
      await _openByKeyboard(tester);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _key(tester, LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, [1]);
      expect(_host(tester).triggerFocus.hasFocus, isTrue);
    });
  });

  group('reduced motion (R2)', () {
    Widget still() => Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: const _Host(),
          ),
        );

    double opacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find
              .ancestor(
                of: find.byKey(const ValueKey('pantas-popover-surface')),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;

    testWidgets('fades in over 150 ms, not at once', (tester) async {
      await pumpDs(tester, dsCells.first, still());
      await tester.tap(find.text('Sort'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(opacity(tester), lessThan(0.5));
      await tester.pump(const Duration(milliseconds: 75));
      expect(opacity(tester), allOf(greaterThan(0.2), lessThan(1)));
      await tester.pump(PantasDurations.short2);
      expect(opacity(tester), 1);
    });

    testWidgets('fades out over 150 ms in place', (tester) async {
      await pumpDs(tester, dsCells.first, still());
      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();
      final top = tester
          .getTopLeft(find.byKey(const ValueKey('pantas-popover-surface')))
          .dy;
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      expect(find.text('Weakest first'), findsOneWidget);
      expect(
        tester
            .getTopLeft(find.byKey(const ValueKey('pantas-popover-surface')))
            .dy,
        top,
      );
      await tester.pump(PantasDurations.short2);
      expect(find.text('Weakest first'), findsNothing);
    });
  });
}
