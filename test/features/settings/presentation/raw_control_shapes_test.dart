import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/hover_shape.dart';

/// The controls that replaced raw Material ones in the settings, onboarding,
/// assessment, guardian, feedback, wrapped, shell, legal and app folders
/// draw a rounded rectangle on hover, never the framework's stadium.
void main() {
  const wide = DsCell(1440, 1, dark: false);

  /// The hover shape of the first [TextButton] under [of].
  OutlinedBorder hoverShape(WidgetTester tester, Finder of) {
    final button = tester.widget<TextButton>(
      find.descendant(of: of, matching: find.byType(TextButton)).first,
    );
    return button.style!.shape!.resolve({WidgetState.hovered})!;
  }

  void expectRounded(OutlinedBorder shape, Size size) {
    expect(shape, isA<RoundedRectangleBorder>());
    expect(shape, isNot(isA<StadiumBorder>()));
    final radius = (shape as RoundedRectangleBorder)
        .borderRadius
        .resolve(TextDirection.ltr)
        .topLeft
        .x;
    expect(radius, lessThan(size.height / 2));
  }

  testWidgets('PantasButton, the decline and retry buttons', (tester) async {
    await pumpDs(
      tester,
      wide,
      PantasButton(
        label: "I Don't Agree",
        kind: PantasButtonKind.tertiary,
        tone: PantasButtonTone.critical,
        onPressed: () {},
      ),
      web: true,
    );
    final finder = find.byType(PantasButton);
    expectRounded(hoverShape(tester, finder), tester.getSize(finder));
    expectHitArea(tester, finder);
  });

  testWidgets('a disabled PantasButton takes no wash and no tap',
      (tester) async {
    await pumpDs(
      tester,
      wide,
      const PantasButton(
        label: "I Don't Agree",
        kind: PantasButtonKind.tertiary,
        tone: PantasButtonTone.critical,
      ),
      web: true,
    );
    await expectDisabledInert(
      tester,
      find.descendant(
        of: find.byType(PantasButton),
        matching: find.byType(TextButton),
      ),
    );
  });

  testWidgets('WebTextLink, the Terms and Privacy links', (tester) async {
    await pumpDs(
      tester,
      wide,
      WebTextLink(label: 'Terms of Service', arrow: false, onPressed: () {}),
      web: true,
    );
    final finder = find.byType(WebTextLink);
    expectRounded(hoverShape(tester, finder), tester.getSize(finder));
    expectHitArea(
      tester,
      finder,
      min: const Size(44, 16),
      reason: 'TextLink is inline; only a coarse pointer pads it to 44 '
          '(TextLink README, Accessibility)',
    );
  });

  testWidgets('WebBackLink, the legal page Back', (tester) async {
    await pumpDs(
      tester,
      wide,
      WebBackLink(label: 'Back', onPressed: () {}),
      web: true,
    );
    final finder = find.byType(WebBackLink);
    expectRounded(hoverShape(tester, finder), tester.getSize(finder));
    expectHitArea(
      tester,
      finder,
      min: const Size(44, 40),
      reason: 'BackLink is size-back (40) high on a fine pointer',
    );
  });

  testWidgets('PantasIconButton, the year steppers and close buttons',
      (tester) async {
    await pumpDs(
      tester,
      wide,
      PantasIconButton(
        tooltip: 'Close',
        glyph: PantasIcons.close,
        size: PantasIconButtonSize.sm,
        onPressed: () {},
      ),
      web: true,
    );
    final button = tester.widget<IconButton>(find.byType(IconButton));
    final shape = button.style!.shape!.resolve({WidgetState.hovered})!;
    expectRounded(shape, const Size.square(32));
    expectHitArea(
      tester,
      find.byType(PantasIconButton),
      min: const Size.square(32),
      reason: 'the 32 icon button is the preferred size on pointer-only '
          'desktop bars (IconButton README, Accessibility)',
    );
  });

  testWidgets('a disabled PantasIconButton takes no wash and no tap',
      (tester) async {
    await pumpDs(
      tester,
      wide,
      PantasIconButton(
        tooltip: 'Close',
        glyph: PantasIcons.close,
        size: PantasIconButtonSize.sm,
        onPressed: null,
      ),
      web: true,
    );
    await expectDisabledInert(tester, find.byType(IconButton));
  });

  testWidgets('ListRow, the session order choices and debug rows',
      (tester) async {
    await pumpDs(
      tester,
      wide,
      ListRow(
        title: 'One topic only',
        variant: ListRowVariant.check,
        selected: true,
        onTap: () {},
      ),
      web: true,
    );
    expect(find.byType(ListRow), findsOneWidget);
    // A row is a flat band: no stadium anywhere in it.
    expect(
      find.descendant(
        of: find.byType(ListRow),
        matching: find.byType(StadiumBorder),
      ),
      findsNothing,
    );
  });

  testWidgets('PantasSpinner, the backup wait', (tester) async {
    await pumpDs(tester, wide, const PantasSpinner(), web: true);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.getSize(find.byType(PantasSpinner)), const Size.square(20));
  });
}
