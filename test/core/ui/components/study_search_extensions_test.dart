import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/search_field.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'search tells its screen when focus starts and Cancel ends editing',
      (tester) async {
    final editing = <bool>[];
    await tester.pumpApp(SearchField(
        title: 'Study',
        titleInset: 4,
        onChanged: (_) {},
        onEditingChanged: editing.add));
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final titleOpacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('Study'), matching: find.byType(Opacity)));
    expect(titleOpacity.opacity, closeTo(.057725, .001));
    await tester.pumpAndSettle();
    expect(editing, [true]);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(editing, [true, false]);
  });

  testWidgets('rich row keeps match emphasis and keyboard navigation',
      (tester) async {
    var opened = 0;
    await tester.pumpApp(ListRow(
        title: 'Stoichiometry',
        richTitle: const TextSpan(children: [
          TextSpan(
              text: 'Stoich', style: TextStyle(fontWeight: FontWeight.w700)),
          TextSpan(text: 'iometry'),
        ]),
        subtitle: 'Chemistry',
        footer: const Text('A matching snippet'),
        verticalPadding: 12,
        leading: const SizedBox.square(dimension: 24),
        onTap: () => opened++));
    final text = tester.widget<Text>(find.text('Stoichiometry'));
    expect((text.textSpan! as TextSpan).children!.first.style!.fontWeight,
        FontWeight.w700);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(opened, 1);
    expect(find.text('A matching snippet'), findsOneWidget);
  });
}
