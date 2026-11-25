// T5, borderless buttons (Aedwon's finding 3). The boards draw a phone text
// button 44 high at its natural width, the Restore Purchases line 24 high,
// and a wide text button 42 high with 14 beside the label (48 and 16 on the
// onboarding boards). The 52 full-width ghost stays only where a board draws
// it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../../../helpers/ds_matrix.dart';

const _phone = DsCell(390, 1, dark: false);
const _wide = DsCell(1440, 1, dark: false);

/// A phone page like a bottom stack: the buttons stretch, as in a Column with
/// `crossAxisAlignment: stretch`.
Future<void> _mount(
  WidgetTester tester,
  List<Widget> children, {
  DsCell cell = _phone,
}) =>
    pumpDs(
      tester,
      cell,
      SizedBox(
        width: cell.width - 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
      scroll: false,
    );

/// The drawn button: the Material inside the TextButton. The TextButton's own
/// box is Material's 48 tap target around it.
Size _drawn(WidgetTester tester) => tester.getSize(
      find
          .descendant(
            of: find.byType(TextButton),
            matching: find.byType(Material),
          )
          .first,
    );

void main() {
  setUpAll(loadDsFonts);

  group('the size classes', () {
    test('text-phone is 44 high, natural width, 17/600, padding 4 and 8', () {
      final m = pantasButtonMetrics(
        PantasButtonSize.textPhone,
        PantasButtonKind.tertiary,
      );
      expect(m.height, 44);
      expect(m.fullWidth, isFalse);
      expect((m.padLeft, m.padRight), (4, 8));
      expect(m.style.fontSize, PantasType.phoneHeadline.fontSize);
      expect(m.style.fontWeight, FontWeight.w600);
    });

    test('text-phone-sm is the 24 high 15/600 line', () {
      final m = pantasButtonMetrics(
        PantasButtonSize.textPhoneSm,
        PantasButtonKind.tertiary,
      );
      expect(m.height, 24);
      expect(m.fullWidth, isFalse);
      expect(m.style.fontSize, 15);
      expect(m.style.fontWeight, FontWeight.w600);
    });

    test('a wide tertiary is 42 high with 14 beside the label', () {
      for (final size in [PantasButtonSize.standard, PantasButtonSize.sm]) {
        final m = pantasButtonMetrics(size, PantasButtonKind.tertiary);
        expect(m.height, 42, reason: '$size');
        expect((m.padLeft, m.padRight), (14, 14), reason: '$size');
      }
    });

    test('a tall wide tertiary (onboarding) is 48 high with 16 beside', () {
      final m = pantasButtonMetrics(
        PantasButtonSize.standard,
        PantasButtonKind.tertiary,
        heightOverride: 48,
      );
      expect(m.height, 48);
      expect((m.padLeft, m.padRight), (16, 16));
    });

    test('a filled wide button keeps 44 and 20', () {
      final m = pantasButtonMetrics(
        PantasButtonSize.standard,
        PantasButtonKind.primary,
      );
      expect(m.height, 44);
      expect((m.padLeft, m.padRight), (20, 20));
    });
  });

  group('phone PantasButton', () {
    testWidgets('a tertiary button is 44 high at natural width, centered',
        (tester) async {
      await _mount(tester, [
        PantasButton(
          label: 'Back to Home',
          variant: PantasButtonVariant.tertiary,
          onPressed: () {},
        ),
      ]);
      final size = _drawn(tester);
      expect(size.height, 44);
      // Label plus 4 and 8 of padding, nowhere near the 358 of the column.
      expect(size.width, lessThan(200));
      final center = tester.getCenter(find.byType(TextButton)).dx;
      // The column is 358 wide: the label sits in its middle.
      expect(center, closeTo(358 / 2, 8));
    });

    testWidgets(
        'a tertiary button given height 44 and no full width is the '
        'same button', (tester) async {
      await _mount(tester, [
        PantasButton(
          label: 'Try Again',
          variant: PantasButtonVariant.tertiary,
          height: 44,
          fullWidth: false,
          onPressed: () {},
        ),
      ]);
      final size = _drawn(tester);
      expect(size.height, 44);
      expect(size.width, lessThan(200));
    });

    testWidgets('a tertiary button can still ask for full width at 44',
        (tester) async {
      await _mount(tester, [
        PantasButton(
          label: 'Discard This Mock',
          kind: PantasButtonKind.tertiary,
          tone: PantasButtonTone.critical,
          height: 44,
          fullWidth: true,
          onPressed: () {},
        ),
      ]);
      final size = _drawn(tester);
      expect(size.height, 44);
      expect(size.width, 358);
    });

    testWidgets(
        'the phone size class stays 52 and full width where a board '
        'draws the stacked ghost button (Every Day)', (tester) async {
      await _mount(tester, [
        PantasButton(
          label: 'Every Day',
          variant: PantasButtonVariant.tertiary,
          size: PantasButtonSize.phone,
          onPressed: () {},
        ),
      ]);
      final size = tester.getSize(find.byType(TextButton));
      expect(size.height, 52);
      expect(size.width, 358);
    });

    testWidgets('a filled button is still 52 and full width', (tester) async {
      await _mount(tester, [
        PantasButton(label: 'Continue', onPressed: () {}),
      ]);
      final size = tester.getSize(find.byType(TextButton));
      expect(size.height, 52);
      expect(size.width, 358);
    });

    testWidgets('text-phone-sm is the Restore Purchases line: 24 high, 15/600',
        (tester) async {
      await _mount(tester, [
        PantasButton(
          label: 'Restore Purchases',
          kind: PantasButtonKind.tertiary,
          tone: PantasButtonTone.accent,
          size: PantasButtonSize.textPhoneSm,
          onPressed: () {},
        ),
      ]);
      final size = tester.getSize(find.byType(TextButton));
      expect(size.height, closeTo(24, .5));
      expect(size.width, lessThan(260));
      final text = tester.widget<Text>(find.text('Restore Purchases'));
      expect(text.style!.fontSize, 15);
      expect(text.style!.fontWeight, FontWeight.w600);
    });

    testWidgets(
        'the Restore line keeps a 44 high tap area without taking '
        'the room', (tester) async {
      var taps = 0;
      // The bar around the line has room above and below, as the page has.
      await _mount(tester, [
        const SizedBox(height: 20),
        PantasButton(
          label: 'Restore Purchases',
          kind: PantasButtonKind.tertiary,
          tone: PantasButtonTone.accent,
          size: PantasButtonSize.textPhoneSm,
          onPressed: () => taps++,
        ),
        const SizedBox(height: 20),
      ]);
      final rect = tester.getRect(find.byType(TextButton));
      // 9 px above the line is inside the 44 tap area (10 each side).
      await tester.tapAt(Offset(rect.center.dx, rect.top - 9));
      await tester.pump();
      expect(taps, 1);
      await tester.tapAt(Offset(rect.center.dx, rect.bottom + 9));
      await tester.pump();
      expect(taps, 2);
      // 14 px away is outside it.
      await tester.tapAt(Offset(rect.center.dx, rect.top - 14));
      await tester.pump();
      expect(taps, 2);
    });
  });

  group('wide WebButton', () {
    testWidgets('a tertiary button is 42 high with 14 beside the label',
        (tester) async {
      await _mount(
        tester,
        [
          WebButton(
            label: 'Cancel',
            variant: WebButtonVariant.tertiary,
            onPressed: () {},
          ),
        ],
        cell: _wide,
      );
      final button = tester.getRect(find.byType(TextButton));
      expect(button.height, 42);
      final label = tester.getRect(find.text('Cancel'));
      expect(label.left - button.left, 14);
      expect(button.right - label.right, 14);
    });

    testWidgets('a tall tertiary (onboarding) is 48 high with 16 beside',
        (tester) async {
      await _mount(
        tester,
        [
          WebButton(
            label: 'Every Day',
            variant: WebButtonVariant.tertiary,
            tall: true,
            onPressed: () {},
          ),
        ],
        cell: _wide,
      );
      final button = tester.getRect(find.byType(TextButton));
      expect(button.height, 48);
      final label = tester.getRect(find.text('Every Day'));
      expect(label.left - button.left, 16);
    });

    testWidgets('a filled button is still 44 with 20', (tester) async {
      await _mount(
        tester,
        [WebButton(label: 'Save', onPressed: () {})],
        cell: _wide,
      );
      final button = tester.getRect(find.byType(TextButton));
      expect(button.height, 44);
      expect(tester.getRect(find.text('Save')).left - button.left, 20);
    });

    testWidgets('PantasButton tertiary on a wide screen is the 42 button',
        (tester) async {
      await _mount(
        tester,
        [
          PantasButton(
            label: 'Later',
            variant: PantasButtonVariant.tertiary,
            onPressed: () {},
          ),
        ],
        cell: _wide,
      );
      expect(tester.getSize(find.byType(TextButton)).height, 42);
    });
  });
}
