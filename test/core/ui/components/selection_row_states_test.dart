import 'dart:ui' show CheckedState, Tristate;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

void main() {
  for (final web in [false, true]) {
    testWidgets('board states and one keyboard action, web=$web',
        (tester) async {
      debugWebPlatformOverride = web;
      addTearDown(() => debugWebPlatformOverride = null);
      var selected = false;
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => CheckboxRow(
                title: 'Choice',
                selected: selected,
                onTap: () {
                  taps++;
                  setState(() => selected = !selected);
                },
              ),
            ),
          ),
        ),
      );
      final markFinder = find.byKey(const ValueKey('selection-mark'));
      expect(tester.getSize(markFinder), const Size(24, 24));
      final off =
          tester.widget<Container>(markFinder).decoration! as BoxDecoration;
      expect(off.borderRadius, BorderRadius.circular(7));
      expect((off.border! as Border).top.width, 1.5);
      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.style!.splashFactory, NoSplash.splashFactory);
      expect(
        button.style!.overlayColor!.resolve({WidgetState.pressed}),
        Colors.transparent,
      );
      expect(
        button.style!.backgroundColor!.resolve({WidgetState.hovered}) !=
            Colors.transparent,
        web,
      );
      expect(
        button.style!.backgroundColor!.resolve({WidgetState.pressed}) !=
            Colors.transparent,
        !web,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(button.style!.side!.resolve({WidgetState.focused})!.width, 2);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(taps, 1);
      final on =
          tester.widget<Container>(markFinder).decoration! as BoxDecoration;
      expect(on.border, isNull);
      final semantics = tester.ensureSemantics();
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Choice'))
            .flagsCollection
            .isChecked,
        CheckedState.isTrue,
      );
      semantics.dispose();
    });
  }
  testWidgets('disabled radio and mixed checkbox keep their roles',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: Column(
            children: [
              RadioRow(title: 'Disabled', selected: true, onTap: null),
              CheckboxRow(
                title: 'Partial',
                selected: false,
                mixed: true,
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
    final marks = tester
        .widgetList<Container>(find.byKey(const ValueKey('selection-mark')))
        .toList();
    expect(
      (marks.first.decoration! as BoxDecoration).borderRadius,
      BorderRadius.circular(99),
    );
    expect(
      find.byWidgetPredicate((w) => w is Opacity && w.opacity == .45),
      findsNWidgets(2),
    );
    expect(
      tester
          .widgetList<TextButton>(find.byType(TextButton))
          .every((button) => button.onPressed == null),
      true,
    );
    final semantics = tester.ensureSemantics();
    final radio = tester.getSemantics(find.bySemanticsLabel('Disabled'));
    expect(radio.flagsCollection.isChecked, CheckedState.isTrue);
    expect(radio.flagsCollection.isInMutuallyExclusiveGroup, true);
    expect(radio.flagsCollection.isEnabled, Tristate.isFalse);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Partial'))
          .flagsCollection
          .isChecked,
      CheckedState.mixed,
    );
    semantics.dispose();
  });
}
