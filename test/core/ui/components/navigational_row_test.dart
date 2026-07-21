import 'package:cse_cet_reviewer/core/ui/components/navigational_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('a navigational row is serif 14/700 with a chevron',
      (tester) async {
    await tester.pumpApp(
      NavigationalRow(
        title: 'How you work',
        subtitle: 'Night-Owl Sprinter. Sharpest at 9 pm, in 8 minute sits.',
        onTap: () {},
      ),
    );
    final title = tester.widget<Text>(find.text('How you work'));
    expect(title.style?.fontFamily, 'SourceSans3');
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
