import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/card_footer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/ds_matrix.dart';

Widget _footer({String caption = 'About 15 min'}) => SizedBox(
      width: 435,
      child: CardFooter(
        caption: caption,
        action: FilledButton(onPressed: () {}, child: const Text('Continue')),
      ),
    );

void main() {
  dsMatrix(
    'CardFooter is an inset band under a divider rule, caption and action',
    (context) => _footer(),
    check: (tester, cell) async {
      final c = tester.element(find.byType(CardFooter)).colors;
      final band = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('card-footer')),
      );
      final decoration = band.decoration as BoxDecoration;
      expect(decoration.color, c.surfaceInset);
      final border = decoration.border! as Border;
      expect(border.top.color, c.divider);
      expect(border.top.width, 0.5);
      final caption = tester.widget<Text>(find.text('About 15 min'));
      expect(caption.style!.fontSize, 15);
      expect(caption.style!.color, c.textSecondary);
      // Caption at the left, action at the right, inside the 20 inset.
      final footer = tester.getRect(find.byKey(const ValueKey('card-footer')));
      expect(tester.getTopLeft(find.text('About 15 min')).dx, footer.left + 20);
      expect(
        tester.getRect(find.byType(FilledButton)).right,
        footer.right - 20,
      );
    },
  );

  dsMatrix(
    'a long caption wraps and the action drops under it at the right',
    (context) => _footer(
      caption: 'This lesson has a short quiz at the end and a longer review.',
    ),
    check: (tester, cell) async {
      final caption = tester.getRect(find.textContaining('This lesson'));
      final action = tester.getRect(find.byType(FilledButton));
      final footer = tester.getRect(find.byKey(const ValueKey('card-footer')));
      if (cell.scale > 1) {
        expect(action.top, greaterThanOrEqualTo(caption.bottom));
        expect(action.right, footer.right - 20);
      }
      expect(action.height, greaterThanOrEqualTo(40));
    },
  );
}
