import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

import '../../../helpers/ds_matrix.dart';

Widget _row({
  bool selected = false,
  String? value = 'UPCAT',
  String? subtitle = 'Last backup today',
  VoidCallback? onTap,
}) =>
    SizedBox(
      width: 380,
      child: ListRow(
        title: 'Your exam',
        value: value,
        subtitle: subtitle,
        selected: selected,
        variant: ListRowVariant.value,
        onTap: onTap ?? () {},
      ),
    );

void main() {
  dsMatrix(
    'ListRow: 13 on wide screens (11 on the phone), 17px title, 44pt row',
    (context) => SizedBox(
      width: 380,
      child: ListRow(title: 'Plan', onTap: () {}),
    ),
    check: (tester, cell) async {
      final box = tester.getSize(find.byType(ListRow));
      expect(box.height, greaterThanOrEqualTo(44));
      final title = tester.widget<Text>(find.text('Plan'));
      expect(title.style!.fontSize, 17);
      final c = tester.element(find.byType(ListRow)).colors;
      expect(title.style!.color, c.textPrimary);
      if (cell.width >= 1024 && cell.scale == 1) {
        // 13 above and below a 17px title at line height 1.3.
        expect(box.height, closeTo(13 * 2 + 17 * 1.3, 1));
      }
      expect(tester.takeException(), isNull);
    },
  );

  dsMatrix(
    'ListRow chevron is the Bold chevron in icon-chevron, 16px',
    (context) =>
        SizedBox(width: 380, child: ListRow(title: 'Plan', onTap: () {})),
    check: (tester, cell) async {
      final c = tester.element(find.byType(ListRow)).colors;
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, PantasIcons.bold(PantasIcons.next));
      expect(icon.size, 16);
      expect(icon.color, c.iconChevron);
    },
  );

  dsMatrix(
    'selected ListRow is accent-tint with on-tint supporting text',
    (context) => _row(selected: true),
    check: (tester, cell) async {
      final c = tester.element(find.byType(ListRow)).colors;
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(ListRow),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, c.accentTint);
      expect(
        tester.widget<Text>(find.text('Last backup today')).style!.color,
        c.textOnTintSecondary,
      );
      expect(
        tester.widget<Text>(find.text('UPCAT')).style!.color,
        c.textOnTintSecondary,
      );
    },
  );

  dsMatrix(
    'ListRow value and subtitle use secondary text at rest',
    (context) => _row(),
    check: (tester, cell) async {
      final c = tester.element(find.byType(ListRow)).colors;
      expect(
        tester.widget<Text>(find.text('UPCAT')).style!.color,
        c.textSecondary,
      );
      expect(
        tester.widget<Text>(find.text('Last backup today')).style!.color,
        c.textSecondary,
      );
    },
  );

  testWidgets('hover and press show the surface-hover well', (tester) async {
    await pumpDs(tester, dsCells.first, _row());
    final c = tester.element(find.byType(ListRow)).colors;
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(inkWell.hoverColor, c.surfaceHover);
    expect(inkWell.highlightColor, c.surfaceHover);
    expect(inkWell.splashColor, Colors.transparent);
  });

  testWidgets('a disabled exam row uses text-disabled, not opacity',
      (tester) async {
    await pumpDs(
      tester,
      dsCells[0],
      const SizedBox(
        width: 380,
        child: ListRow.exam(
          title: 'DCAT',
          subtitle: 'Coming later',
          selected: false,
          comingSoon: true,
          settingsMode: true,
          onTap: null,
        ),
      ),
    );
    final c = tester.element(find.byType(ListRow)).colors;
    expect(tester.widget<Text>(find.text('DCAT')).style!.color, c.textDisabled);
    expect(
      tester.widget<Text>(find.text('Coming soon')).style!.color,
      c.textDisabled,
    );
    expect(
      find.byWidgetPredicate((w) => w is Opacity && w.opacity < 1),
      findsNothing,
    );
  });

  testWidgets('keyboard focus draws a 2 accent ring inside the row',
      (tester) async {
    resetWebKeyboardFocus();
    await pumpDs(tester, dsCells.first, _row());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final c = tester.element(find.byType(ListRow)).colors;
    final rings = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(ListRow),
        matching: find.byType(DecoratedBox),
      ),
    );
    final ring = rings.firstWhere(
      (box) =>
          box.position == DecorationPosition.foreground &&
          (box.decoration as BoxDecoration).border != null,
    );
    final side = ((ring.decoration as BoxDecoration).border! as Border).top;
    expect(side.width, 2);
    expect(side.color, c.accent);
  });

  dsMatrix(
    'the value stacks under the title when they no longer fit',
    (context) => const SizedBox(
      width: 300,
      child: ListRow(
        title: 'Which exam are you preparing for',
        value: 'University of the Philippines',
        variant: ListRowVariant.value,
      ),
    ),
    check: (tester, cell) async {
      final title =
          tester.getRect(find.text('Which exam are you preparing for'));
      final value = tester.getRect(find.text('University of the Philippines'));
      expect(value.top, greaterThanOrEqualTo(title.bottom - 1));
      expect(value.left, title.left);
    },
  );

  dsMatrix(
    'GroupedSection: radius 14 card with a 13/600 header and 13/400 footer',
    (context) => const GroupedSection(
      header: 'Account',
      footer: 'Your plan renews on March 1, 2027.',
      children: [
        ListRow(title: 'Plan', value: 'Free', variant: ListRowVariant.value),
      ],
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(GroupedSection)).colors;
      final surface = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('grouped-section-surface')),
      );
      final decoration = surface.decoration as BoxDecoration;
      expect(decoration.color, c.surfaceCard);
      expect(decoration.borderRadius, BorderRadius.circular(14));
      if (cell.dark) {
        expect((decoration.border! as Border).top.color, c.edgeCard);
      } else {
        expect(decoration.border, isNull);
      }
      final header = tester.widget<Text>(find.text('ACCOUNT'));
      expect(header.style!.color, c.textSecondary);
      expect(header.style!.fontSize, 13);
      final footer =
          tester.widget<Text>(find.text('Your plan renews on March 1, 2027.'));
      expect(footer.style!.color, c.textSecondary);
    },
  );
}
