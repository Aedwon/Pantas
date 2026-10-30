import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  testWidgets('busy button holds its last frame under reduced motion',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      PantasButton(label: 'Saving', busy: true, onPressed: () {}),
      disableAnimations: true,
    );
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      1,
    );
  });
  testWidgets('wrong floating surface follows QV_MissPro', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const FloatingBar(
        left: Text('Back'),
        counter: '4 of 10',
        right: Text('Next'),
        state: FloatingBarState.wrong,
      ),
      disableAnimations: true,
    );
    final bar =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect((bar.decoration! as BoxDecoration).color, const Color(0xFFFFF3F4));
  });
  testWidgets('dark destructive text uses the readable approved red',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ListRow(
        title: 'Delete account',
        variant: ListRowVariant.destructive,
      ),
      brightness: Brightness.dark,
    );
    final text = tester.widget<Text>(find.text('Delete account'));
    expect(text.style!.color, const Color(0xFFE0706B));
    expectContrast(text.style!.color!, const Color(0xFF1F1F1F));
  });
  testWidgets('Pro tag centers its label', (tester) async {
    await pumpAccessibilitySurface(tester, const ProTag());
    final outer = tester.getRect(find.byType(ProTag));
    final text = tester.getRect(find.text('Pro'));
    expect(text.center.dy, closeTo(outer.center.dy, .1));
  });
}
