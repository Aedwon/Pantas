import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../../../helpers/ds_matrix.dart';

Container _card(WidgetTester tester) => tester.widget<Container>(
      find
          .descendant(
            of: find.byType(WebCard),
            matching: find.byType(Container),
          )
          .first,
    );

void main() {
  dsMatrix(
    'WebCard is a flat surface-card, radius 18, dark edge only in dark',
    (context) => const SizedBox(
      width: 360,
      child: WebCard(padding: EdgeInsets.all(20), child: Text('Body')),
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(WebCard)).colors;
      final card = _card(tester);
      final deco = card.decoration! as BoxDecoration;
      expect(deco.color, c.surfaceCard);
      expect(deco.borderRadius, BorderRadius.circular(18));
      expect(deco.boxShadow, isNull);
      final edge = card.foregroundDecoration as BoxDecoration?;
      if (cell.dark) {
        expect((edge!.border! as Border).top.color, c.edgeCard);
      } else {
        expect(edge, isNull);
      }
    },
  );

  dsMatrix(
    'a selected WebCard is accent-tint with a 2 accent ring',
    (context) => const SizedBox(
      width: 360,
      child: WebCard(selected: true, child: Text('Body')),
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(WebCard)).colors;
      final card = _card(tester);
      expect((card.decoration! as BoxDecoration).color, c.accentTint);
      final ring =
          (card.foregroundDecoration! as BoxDecoration).border! as Border;
      expect(ring.top.color, c.accent);
      expect(ring.top.width, 2);
    },
  );

  dsMatrix(
    'a floating WebCard takes the bar shadow and the edge-bar edge',
    (context) => const SizedBox(
      width: 360,
      child: WebCard(floating: true, child: Text('Body')),
    ),
    check: (tester, cell) async {
      final c = tester.element(find.byType(WebCard)).colors;
      final deco = _card(tester).decoration! as BoxDecoration;
      expect((deco.border! as Border).top.color, c.edgeBar);
      expect(deco.boxShadow, isNotEmpty);
    },
  );

  dsMatrix(
    'WebChevron is the 16px Bold chevron in icon-chevron',
    (context) => const WebChevron(),
    check: (tester, cell) async {
      final c = tester.element(find.byType(WebChevron)).colors;
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, PantasIcons.bold(PantasIcons.next));
      expect(icon.size, 16);
      expect(icon.color, c.iconChevron);
    },
  );

  Widget row({
    bool selected = false,
    String? value = 'Free',
    String? subtitle = 'Renews March 1',
    String title = 'Plan',
    WebRowChevron chevron = WebRowChevron.always,
    bool dimmed = false,
    bool wrapTitle = false,
  }) =>
      SizedBox(
        width: 420,
        child: WebRow(
          title: title,
          subtitle: subtitle,
          value: value,
          selected: selected,
          dimmed: dimmed,
          wrapTitle: wrapTitle,
          chevron: chevron,
          onPressed: () {},
        ),
      );

  dsMatrix(
    'WebRow pads 13, 17/400 title, 14 subtitle and 15 value in the roles',
    (context) => row(),
    check: (tester, cell) async {
      final c = tester.element(find.byType(WebRow)).colors;
      final title = tester.widget<Text>(find.text('Plan'));
      expect(title.style!.fontSize, 17);
      expect(title.style!.color, c.textPrimary);
      final sub = tester.widget<Text>(find.text('Renews March 1'));
      expect(sub.style!.fontSize, 14);
      expect(sub.style!.color, c.textSecondary);
      final value = tester.widget<Text>(find.text('Free'));
      expect(value.style!.fontSize, 15);
      expect(value.style!.color, c.textSecondary);
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, c.iconChevron);
      if (cell.scale == 1) {
        // 13 above and below a 17px title and a 14px subtitle, plus the rule.
        expect(
          tester.getSize(find.byType(WebRow)).height,
          closeTo(13 * 2 + 17 * 1.3 + 14 * 1.3 + .5, 1.5),
        );
      }
    },
  );

  dsMatrix(
    'a selected WebRow uses on-tint text and an accent-tint-text chevron',
    (context) => row(selected: true),
    check: (tester, cell) async {
      final c = tester.element(find.byType(WebRow)).colors;
      expect(
        tester.widget<Text>(find.text('Renews March 1')).style!.color,
        c.textOnTintSecondary,
      );
      expect(
        tester.widget<Text>(find.text('Free')).style!.color,
        c.textOnTintSecondary,
      );
      expect(tester.widget<Icon>(find.byType(Icon)).color, c.accentTintText);
      expect(
        find.descendant(
          of: find.byType(WebRow),
          matching: find.byWidgetPredicate(
            (w) => w is ColoredBox && w.color == c.accentTint,
          ),
        ),
        findsOneWidget,
      );
    },
  );

  dsMatrix(
    'the value stacks under the title when they no longer fit',
    (context) => row(
      title: 'Which exam are you preparing for this year',
      value: 'University of the Philippines College Admission Test',
      wrapTitle: true,
    ),
    check: (tester, cell) async {
      final title = tester.getRect(find.textContaining('Which exam'));
      final value = tester.getRect(find.textContaining('University'));
      expect(value.top, greaterThanOrEqualTo(title.bottom - 1));
      expect(value.left, title.left);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a short title and value stay on one line at 200 percent',
      (tester) async {
    await pumpDs(
      tester,
      dsCells[6],
      SizedBox(
        width: 900,
        child: WebRow(
          title: 'Plan',
          value: 'Free',
          wrapTitle: true,
          onPressed: () {},
        ),
      ),
    );
    final title = tester.getRect(find.text('Plan'));
    final value = tester.getRect(find.text('Free'));
    expect((title.center.dy - value.center.dy).abs(), lessThan(4));
    expect(value.left, greaterThan(title.right));
  });

  testWidgets('hover shows the surface-hover well and fades the chevron in',
      (tester) async {
    await pumpDs(tester, dsCells[4], row(chevron: WebRowChevron.hover));
    final c = tester.element(find.byType(WebRow)).colors;
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      0,
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(WebRow)));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      1,
    );
    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(
      button.style!.backgroundColor!.resolve({WidgetState.hovered}),
      c.surfaceHover,
    );
    expect(
      button.style!.backgroundColor!.resolve({WidgetState.pressed}),
      c.surfaceHover,
    );
  });

  testWidgets('a dimmed row uses text-secondary and no opacity',
      (tester) async {
    await pumpDs(tester, dsCells[4], row(dimmed: true));
    final c = tester.element(find.byType(WebRow)).colors;
    expect(
      tester.widget<Text>(find.text('Plan')).style!.color,
      c.textSecondary,
    );
    expect(
      find.byWidgetPredicate((w) => w is Opacity && w.opacity < 1),
      findsNothing,
    );
    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('keyboard focus draws a 2 accent ring inside the row',
      (tester) async {
    resetWebKeyboardFocus();
    await pumpDs(tester, dsCells[4], row());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final c = tester.element(find.byType(WebRow)).colors;
    final ring = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(WebRow),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.borderRadius != null);
    final side = (ring.border! as Border).top;
    expect(side.width, 2);
    expect(side.color, c.accent);
  });
}
