import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('picker heading stays fixed while content scrolls',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      Builder(
        builder: (context) => PantasPage(
          title: 'Customize your own',
          titleStyle: context.type.pageTitle,
          fixedTitle: true,
          headerTrailing:
              TextButton(onPressed: () {}, child: const Text('Clear')),
          backLabel: 'Quiz',
          onBack: () {},
          backIconSize: 24,
          backPadding: const EdgeInsets.only(left: 4, right: 12),
          titlePadding: const EdgeInsets.fromLTRB(4, 4, 4, 18),
          children: [for (var i = 0; i < 40; i++) Text('Row $i')],
        ),
      ),
      viewportSize: const Size(390, 844),
    );
    final before = tester.getTopLeft(find.text('Customize your own'));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Customize your own')), before);
    expect(find.text('Clear'), findsOneWidget);
  });
}
