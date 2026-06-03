import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_section.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RuledSection draws a top hairline in rule color', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(body: RuledSection(child: Text('content'))),
      ),
    );
    final container = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('content'),
            matching: find.byType(Container),
          )
          .first,
    );
    final border =
        // ignore: cast_nullable_to_non_nullable
        (container.decoration as BoxDecoration).border as Border;
    expect(border.top.color, AppColors.light.rule);
    expect(border.top.width, 1.0);
  });

  testWidgets('PageScaffold paints paper background', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const PageScaffold(body: Text('hello')),
      ),
    );
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.light.background);
    expect(find.text('hello'), findsOneWidget);
  });
}
