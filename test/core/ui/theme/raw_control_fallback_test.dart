import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';

// A raw Material control left anywhere must draw the system's look, not
// Flutter's: a rounded rectangle (never a stadium or circle), the
// `opacity-hover` wash, and no ink splash.
void main() {
  const themes = <String, bool>{'light': false, 'dark': true};

  for (final entry in themes.entries) {
    final dark = entry.value;
    final colors = dark ? PantasColors.dark : PantasColors.light;
    final theme = dark ? buildDarkTheme(web: true) : buildLightTheme(web: true);

    Widget host(Widget child) => MaterialApp(
          theme: theme,
          home: Scaffold(body: Center(child: child)),
        );

    void expectSystemRadius(ShapeBorder? shape, double radius) {
      expect(shape, isA<RoundedRectangleBorder>());
      expect(shape, isNot(isA<StadiumBorder>()));
      expect(
        (shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(radius),
      );
    }

    group('raw controls under the ${entry.key} theme', () {
      testWidgets('TextButton is a radius-md rectangle with the hover wash',
          (tester) async {
        await tester.pumpWidget(
          host(TextButton(onPressed: () {}, child: const Text('Back'))),
        );
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(TextButton),
            matching: find.byType(Material),
          ),
        );
        expectSystemRadius(material.shape, PantasRadius.md);
        final style = theme.textButtonTheme.style!;
        expect(
          style.overlayColor!.resolve({WidgetState.hovered}),
          colors.accent.withValues(alpha: PantasOpacity.hover),
        );
        expect(style.splashFactory, NoSplash.splashFactory);
      });

      testWidgets('IconButton is a radius-md rectangle with the hover wash',
          (tester) async {
        await tester.pumpWidget(
          host(
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close),
            ),
          ),
        );
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(IconButton),
            matching: find.byType(Material),
          ),
        );
        expectSystemRadius(material.shape, PantasRadius.md);
        expect(
          theme.iconButtonTheme.style!.overlayColor!
              .resolve({WidgetState.hovered}),
          colors.secondaryLabel.withValues(alpha: PantasOpacity.hover),
        );
      });

      testWidgets('every button theme is a rounded rectangle, not a stadium',
          (tester) async {
        for (final style in [
          theme.textButtonTheme.style,
          theme.filledButtonTheme.style,
          theme.elevatedButtonTheme.style,
          theme.outlinedButtonTheme.style,
          theme.iconButtonTheme.style,
        ]) {
          expectSystemRadius(style!.shape!.resolve({}), PantasRadius.md);
        }
      });

      testWidgets('InkWell in Material draws no splash and the system well',
          (tester) async {
        await tester.pumpWidget(
          host(
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {},
                child: const SizedBox(width: 80, height: 44),
              ),
            ),
          ),
        );
        final context = tester.element(find.byType(InkWell));
        final resolved = Theme.of(context);
        expect(resolved.splashFactory, NoSplash.splashFactory);
        expect(resolved.splashColor, Colors.transparent);
        expect(resolved.highlightColor, Colors.transparent);
        expect(resolved.hoverColor, colors.surfaceHover);
      });

      test('a field that turns its border off draws no theme outline', () {
        final fields = theme.inputDecorationTheme;
        // Per-state theme borders would win over a field's `border: none`
        // and draw a second outline inside a search box's own frame.
        expect(fields.enabledBorder, isNull);
        expect(fields.focusedBorder, isNull);
        expect(fields.disabledBorder, isNull);
        expect(fields.errorBorder, isNull);
        expect(fields.focusedErrorBorder, isNull);
        final bare = const InputDecoration(border: InputBorder.none)
            .applyDefaults(fields);
        expect(bare.border, InputBorder.none);
        expect(bare.enabledBorder, isNull);
        expect(bare.focusedBorder, isNull);
        final plain = const InputDecoration().applyDefaults(fields);
        final border = plain.border! as WidgetStateProperty<InputBorder>;
        final rest = border.resolve({}) as OutlineInputBorder;
        final focused =
            border.resolve({WidgetState.focused}) as OutlineInputBorder;
        expect(rest.borderSide.color, colors.controlOutline);
        expect(focused.borderSide.color, colors.accent);
        expect(rest.borderRadius, BorderRadius.circular(PantasRadius.md));
      });

      // Layer 4 audit: every control the layer 1 barrel hides keeps the
      // system's shape and hover when it is left raw.
      Future<void> hover(WidgetTester tester, Finder target) async {
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        addTearDown(mouse.removePointer);
        await mouse.moveTo(tester.getCenter(target));
        await tester.pumpAndSettle();
      }

      Material materialOf(WidgetTester tester, Finder of) =>
          tester.widget<Material>(
            find.descendant(of: of, matching: find.byType(Material)).first,
          );

      for (final (name, button, expectHover, style)
          in <(String, Widget Function(), Color, ButtonStyle?)>[
        (
          'ElevatedButton',
          () => ElevatedButton(onPressed: () {}, child: const Text('Go')),
          colors.label,
          theme.elevatedButtonTheme.style,
        ),
        (
          'OutlinedButton',
          () => OutlinedButton(onPressed: () {}, child: const Text('Go')),
          colors.label,
          theme.outlinedButtonTheme.style,
        ),
        (
          'FilledButton',
          () => FilledButton(onPressed: () {}, child: const Text('Go')),
          colors.accentFillHover,
          theme.filledButtonTheme.style,
        ),
      ]) {
        testWidgets('$name is a radius-md rectangle that hovers',
            (tester) async {
          await tester.pumpWidget(host(button()));
          final finder = find.byWidgetPredicate((w) => w is ButtonStyleButton);
          expectSystemRadius(materialOf(tester, finder).shape, PantasRadius.md);
          await hover(tester, finder);
          final states = {WidgetState.hovered};
          if (name == 'FilledButton') {
            expect(style!.backgroundColor!.resolve(states), expectHover);
          } else {
            expect(
              style!.overlayColor!.resolve(states),
              expectHover.withValues(alpha: PantasOpacity.hover),
              reason: '$name draws the opacity-hover wash',
            );
          }
        });
      }

      testWidgets('FloatingActionButton is a rectangle, flat, and hovers',
          (tester) async {
        await tester.pumpWidget(
          host(
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        );
        final fab = find.byType(FloatingActionButton);
        expectSystemRadius(materialOf(tester, fab).shape, PantasRadius.lg);
        final themed = theme.floatingActionButtonTheme;
        expect(themed.backgroundColor, colors.accentFill);
        expect(themed.foregroundColor, colors.onAccent);
        expect(themed.hoverColor, colors.accentFillHover);
        expect(themed.elevation, 0);
        expect(themed.hoverElevation, 0);
        expect(themed.highlightElevation, 0);
        expect(themed.focusElevation, 0);
        expect(themed.splashColor, Colors.transparent);
      });

      testWidgets('InkWell highlights a rectangle and InkResponse a flat well',
          (tester) async {
        await tester.pumpWidget(
          host(
            Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    key: const ValueKey('well'),
                    onTap: () {},
                    child: const SizedBox(width: 80, height: 44),
                  ),
                  InkResponse(
                    key: const ValueKey('response'),
                    onTap: () {},
                    child: const SizedBox(width: 80, height: 44),
                  ),
                ],
              ),
            ),
          ),
        );
        // InkWell's highlight is a rectangle by default.
        expect(
          tester
              .widget<InkWell>(find.byKey(const ValueKey('well')))
              .borderRadius,
          isNull,
        );
        final resolved =
            Theme.of(tester.element(find.byType(InkResponse).last));
        expect(resolved.splashFactory, NoSplash.splashFactory);
        expect(resolved.highlightColor, Colors.transparent);
        expect(resolved.hoverColor, colors.surfaceHover);
        // InkResponse defaults to a circle. A theme cannot change that, so the
        // barrel hides it and the check keeps it out of lib/.
        expect(
          tester
              .widget<InkResponse>(find.byKey(const ValueKey('response')))
              .highlightShape,
          BoxShape.circle,
        );
      });

      testWidgets('TextField takes the system ring on rest and focus',
          (tester) async {
        await tester.pumpWidget(
          host(const SizedBox(width: 240, child: TextField())),
        );
        final decoration = tester
            .widget<InputDecorator>(find.byType(InputDecorator))
            .decoration;
        final border = decoration.border! as WidgetStateInputBorder;
        final rest = border.resolve({}) as OutlineInputBorder;
        final focused =
            border.resolve({WidgetState.focused}) as OutlineInputBorder;
        expect(rest.borderSide.color, colors.controlOutline);
        expect(focused.borderSide.color, colors.accent);
        expect(focused.borderRadius, BorderRadius.circular(PantasRadius.md));
        await tester.tap(find.byType(TextField));
        await tester.pump();
        expect(
          tester.widget<InputDecorator>(find.byType(InputDecorator)).isFocused,
          isTrue,
        );
      });

      testWidgets('SnackBar and Tooltip draw the Toast surface',
          (tester) async {
        expect(theme.snackBarTheme.backgroundColor, colors.toastBackground);
        expectSystemRadius(theme.snackBarTheme.shape, PantasRadius.lg);
        expect(theme.snackBarTheme.actionTextColor, colors.toastAction);
        expect(theme.snackBarTheme.elevation, 0);
        final decoration = theme.tooltipTheme.decoration! as BoxDecoration;
        expect(decoration.color, colors.toastBackground);
        expect(decoration.borderRadius, BorderRadius.circular(PantasRadius.sm));
      });

      testWidgets('ListTile is a flat band with the hover well and a tint',
          (tester) async {
        await tester.pumpWidget(
          host(
            Material(
              child: ListTile(
                title: const Text('Row'),
                selected: true,
                onTap: () {},
              ),
            ),
          ),
        );
        final tile = theme.listTileTheme;
        expect(tile.shape, const RoundedRectangleBorder());
        expect(tile.selectedTileColor, colors.accentTint);
        expect(tile.selectedColor, colors.accentTintText);
        expect(tester.takeException(), isNull);
        expect(
          Theme.of(tester.element(find.byType(ListTile))).hoverColor,
          colors.surfaceHover,
        );
      });

      testWidgets('every chip is a radius-sm rectangle with the ring',
          (tester) async {
        await tester.pumpWidget(
          host(
            Wrap(
              children: [
                const Chip(label: Text('Chip')),
                ActionChip(label: const Text('Action'), onPressed: () {}),
                FilterChip(
                  label: const Text('Filter'),
                  selected: true,
                  onSelected: (_) {},
                ),
                ChoiceChip(
                  label: const Text('Choice'),
                  selected: false,
                  onSelected: (_) {},
                ),
                InputChip(label: const Text('Input'), onPressed: () {}),
              ],
            ),
          ),
        );
        for (final type in [
          Chip,
          ActionChip,
          FilterChip,
          ChoiceChip,
          InputChip,
        ]) {
          final material = tester.widget<Material>(
            find
                .descendant(
                  of: find.byType(type),
                  matching: find.byType(Material),
                )
                .first,
          );
          final shape = material.shape! as RoundedRectangleBorder;
          expect(shape, isNot(isA<StadiumBorder>()), reason: '$type');
          expect(
            shape.borderRadius,
            BorderRadius.circular(PantasRadius.sm),
            reason: '$type',
          );
          expect(shape.side.color, colors.controlOutline, reason: '$type');
        }
        expect(theme.chipTheme.selectedColor, colors.accentTint);
      });

      testWidgets(
          'Checkbox, Radio and Switch use the accent fill and no splash',
          (tester) async {
        await tester.pumpWidget(
          host(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(value: true, onChanged: (_) {}),
                RadioGroup<int>(
                  groupValue: 1,
                  onChanged: (_) {},
                  child: const Radio<int>(value: 1),
                ),
                Switch(value: true, onChanged: (_) {}),
              ],
            ),
          ),
        );
        final checkbox = theme.checkboxTheme;
        expectSystemRadius(checkbox.shape, PantasRadius.sm);
        expect(
          checkbox.fillColor!.resolve({WidgetState.selected}),
          colors.accentFill,
        );
        expect(checkbox.splashRadius, 0);
        expect(
          theme.radioTheme.fillColor!.resolve({WidgetState.selected}),
          colors.accentFill,
        );
        expect(theme.radioTheme.splashRadius, 0);
        expect(
          theme.switchTheme.trackColor!.resolve({WidgetState.selected}),
          colors.accentFill,
        );
        expect(theme.switchTheme.splashRadius, 0);
        expect(
          theme.checkboxTheme.overlayColor!.resolve({WidgetState.hovered}),
          colors.surfaceHover,
        );
      });

      testWidgets('Slider draws the accent track and a flat thumb',
          (tester) async {
        await tester.pumpWidget(
          host(
            SizedBox(
              width: 240,
              child: Slider(value: .5, onChanged: (_) {}),
            ),
          ),
        );
        final slider = theme.sliderTheme;
        expect(slider.activeTrackColor, colors.accent);
        expect(slider.inactiveTrackColor, colors.fill);
        expect(slider.thumbColor, colors.switchThumb);
        expect(
          slider.overlayColor,
          colors.accent.withValues(alpha: PantasOpacity.hover),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('DropdownButton and DropdownMenu open on the system surface',
          (tester) async {
        await tester.pumpWidget(
          host(
            DropdownButton<int>(
              value: 1,
              onChanged: (_) {},
              items: const [
                DropdownMenuItem(value: 1, child: Text('One')),
                DropdownMenuItem(value: 2, child: Text('Two')),
              ],
            ),
          ),
        );
        // The button's menu paints `canvasColor`, which is the card surface.
        expect(theme.canvasColor, colors.surface);
        expect(theme.focusColor, isNotNull);
        final menu = theme.dropdownMenuTheme.menuStyle!;
        expectSystemRadius(menu.shape!.resolve({}), PantasRadius.lg);
        expect(menu.backgroundColor!.resolve({}), colors.surface);
        expect(menu.elevation!.resolve({}), 0);
        final menuTheme = theme.menuTheme.style!;
        expectSystemRadius(menuTheme.shape!.resolve({}), PantasRadius.lg);
        final item = theme.menuButtonTheme.style!;
        expectSystemRadius(item.shape!.resolve({}), PantasRadius.md);
        expect(
          item.overlayColor!.resolve({WidgetState.hovered}),
          colors.label.withValues(alpha: PantasOpacity.hover),
        );
      });

      testWidgets('PopupMenuButton opens a radius-lg Popover surface',
          (tester) async {
        await tester.pumpWidget(
          host(
            PopupMenuButton<int>(
              itemBuilder: (_) => const [
                PopupMenuItem(value: 1, child: Text('One')),
              ],
            ),
          ),
        );
        await tester.tap(find.byType(PopupMenuButton<int>));
        await tester.pumpAndSettle();
        final popup = theme.popupMenuTheme;
        expectSystemRadius(popup.shape, PantasRadius.lg);
        expect(popup.color, colors.surface);
        expect(find.text('One'), findsOneWidget);
      });

      testWidgets('AlertDialog and SimpleDialog follow the Dialog README',
          (tester) async {
        // Dialog README: surface-modal, radius-2xl 22, title 20/700, body 16
        // in text-secondary.
        final dialog = theme.dialogTheme;
        expect(dialog.backgroundColor, colors.surfaceModal);
        expectSystemRadius(dialog.shape, PantasRadius.r2xl);
        expect(dialog.titleTextStyle!.fontSize, 20);
        expect(dialog.titleTextStyle!.fontWeight, FontWeight.w700);
        expect(dialog.titleTextStyle!.color, colors.label);
        expect(dialog.contentTextStyle!.fontSize, 16);
        expect(dialog.contentTextStyle!.color, colors.secondaryLabel);
        expect(dialog.barrierColor, colors.scrim);
        await tester.pumpWidget(
          host(
            Builder(
              builder: (context) => Column(
                children: [
                  TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const AlertDialog(
                        title: Text('Title'),
                        content: Text('Body'),
                      ),
                    ),
                    child: const Text('alert'),
                  ),
                  TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const SimpleDialog(title: Text('Pick')),
                    ),
                    child: const Text('simple'),
                  ),
                ],
              ),
            ),
          ),
        );
        for (final (open, type) in [
          ('alert', AlertDialog),
          ('simple', SimpleDialog),
        ]) {
          await tester.tap(find.text(open));
          await tester.pumpAndSettle();
          final material = tester.widget<Material>(
            find
                .descendant(
                  of: find.byType(type),
                  matching: find.byType(Material),
                )
                .first,
          );
          expectSystemRadius(material.shape, PantasRadius.r2xl);
          expect(material.color, colors.surfaceModal, reason: '$type');
          Navigator.of(tester.element(find.byType(type))).pop();
          await tester.pumpAndSettle();
        }
      });

      testWidgets('the bottom sheet is a radius-lg top on the modal surface',
          (tester) async {
        final sheet = theme.bottomSheetTheme;
        expect(sheet.backgroundColor, colors.surfaceModal);
        expect(sheet.modalBackgroundColor, colors.surfaceModal);
        expect(sheet.modalBarrierColor, colors.scrim);
        expect(
          sheet.shape,
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(PantasRadius.lg),
            ),
          ),
        );
        expect(sheet.elevation, 0);
      });

      testWidgets('both progress indicators draw the accent arc and bar',
          (tester) async {
        await tester.pumpWidget(
          host(
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(value: .5),
                ),
                CircularProgressIndicator(value: .5),
              ],
            ),
          ),
        );
        final progress = theme.progressIndicatorTheme;
        expect(progress.color, colors.accent);
        expect(progress.linearTrackColor, colors.fill);
        expect(progress.circularTrackColor, colors.fill);
        expect(progress.linearMinHeight, 5);
        expect(progress.strokeWidth, 2.5);
        expect(
          progress.borderRadius,
          const BorderRadius.all(Radius.circular(PantasRadius.full)),
        );
        expect(tester.takeException(), isNull);
      });
    });
  }
}
