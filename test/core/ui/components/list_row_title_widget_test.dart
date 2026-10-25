import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('default title keeps truncation and the existing tap',
      (tester) async {
    var taps = 0;
    await tester.pumpApp(ListRow(title: 'Plain title', onTap: () => taps++));
    final title = tester.widget<Text>(find.text('Plain title'));
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    await tester.tap(find.text('Plain title'));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rich title replaces only the title while row action stays',
      (tester) async {
    var taps = 0;
    await tester.pumpApp(
      ListRow(
        title: 'Unrendered source',
        titleWidget: const Text('Readable title'),
        subtitle: 'Same subtitle',
        onTap: () => taps++,
      ),
    );
    expect(find.text('Unrendered source'), findsNothing);
    expect(find.text('Readable title'), findsOneWidget);
    expect(find.text('Same subtitle'), findsOneWidget);
    await tester.tap(find.text('Readable title'));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('single-line math title fits compact large text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Builder(
          builder: (context) => ListRow(
            title: 'Math source',
            titleWidget: DefaultTextStyle(
              style: context.type.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              child: const MathText(
                r'Compute $x^2$ and explain the very long expression',
              ),
            ),
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MathText), findsOneWidget);
    expect(tester.getSize(find.byType(ListRow)).width, 320);
    expect(tester.takeException(), isNull);
  });
}
