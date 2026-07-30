import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/exam_name_line.dart';
import 'package:pantas/core/ui/components/tab_header.dart';
import 'package:pantas/core/ui/theme/app_text_styles.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // Aedwon, after the headers were unified: "the exam name on Study tab still
  // isn't the same with other tabs. maybe it's because of the search icon?"
  // It was not the icon. Study added 6px above the name that the others did
  // not, and the gap below it was 14 on Study, 20 on Quiz and 16 on Progress.
  testWidgets('the name sits directly under the header, with no gap of its own',
      (tester) async {
    await tester.pumpApp(
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabHeader(title: 'Study'),
          ExamNameLine('UPCAT'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final header = tester.getRect(find.byType(TabHeader));
    final name = tester.getRect(find.byType(ExamNameLine));

    expect(name.top, header.bottom);
  });

  testWidgets('a trailing action in the header does not move the name',
      (tester) async {
    Future<Rect> nameUnder(Widget? trailing) async {
      await tester.pumpApp(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabHeader(title: 'Study', trailing: trailing),
            const ExamNameLine('UPCAT'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      return tester.getRect(find.text('UPCAT'));
    }

    final plain = await nameUnder(null);
    final withSearch = await nameUnder(const Icon(Icons.search));

    expect(withSearch.top, plain.top);
    expect(withSearch.left, plain.left);
  });

  testWidgets('the name is the same size on every tab', (tester) async {
    await tester.pumpApp(const ExamNameLine('UPCAT'));
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.text('UPCAT'));
    expect(text.style?.fontSize, AppTextStyles.create().displaySmall.fontSize);
  });
}
