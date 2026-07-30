import 'package:pantas/core/ui/components/tab_header.dart';
import 'package:pantas/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // Aedwon: "the headers themselves aren't equal". Study drew its own row at
  // 17px, Quiz used an AppBar at 18 with a fixed 56 height, and Progress used
  // a bare AppBar that took the Material default for all three of those.
  testWidgets('every tab title is the same size and weight', (tester) async {
    for (final title in ['Study', 'Quiz', 'Progress']) {
      await tester.pumpApp(TabHeader(title: title));
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text(title));
      expect(
        text.style?.fontSize,
        AppTextStyles.create().headlineMedium.fontSize,
      );
      expect(
        text.style?.fontWeight,
        AppTextStyles.create().headlineMedium.fontWeight,
      );
    }
  });

  testWidgets('a trailing action does not move the title', (tester) async {
    await tester.pumpApp(const TabHeader(title: 'Study'));
    await tester.pumpAndSettle();
    final without = tester.getRect(find.text('Study'));

    await tester.pumpApp(
      const TabHeader(title: 'Study', trailing: Icon(Icons.search)),
    );
    await tester.pumpAndSettle();
    final with_ = tester.getRect(find.text('Study'));

    expect(with_.left, without.left);
    expect(with_.top, without.top);
  });

  testWidgets('the header sits the same distance from the top either way',
      (tester) async {
    await tester.pumpApp(const TabHeader(title: 'Quiz'));
    await tester.pumpAndSettle();

    final header = tester.getRect(find.byType(TabHeader));
    final text = tester.getRect(find.text('Quiz'));

    expect(header.height, 12 + TabHeader.rowHeight + TabHeader.spaceBelow);
    expect(text.center.dy, header.top + 12 + TabHeader.rowHeight / 2);
  });
}
