import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_hover.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';
import 'package:pantas/features/home/presentation/plan_web.dart';

// QA 5Q-8, 5Q-10 and 5Q-16.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  void size(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> mount(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme(web: true),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 500, child: child),
            ),
          ),
        ),
      );

  Future<void> hover(WidgetTester tester, Finder finder) async {
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: const Offset(900, 800));
    await tester.pump();
    await mouse.moveTo(tester.getCenter(finder));
    await tester.pumpAndSettle();
  }

  testWidgets('WebHover tells its child when the pointer is over it',
      (tester) async {
    size(tester);
    var hovered = false;
    await mount(
      tester,
      WebHover(
        builder: (context, over) {
          hovered = over;
          return const SizedBox(width: 100, height: 40, child: Text('Pill'));
        },
      ),
    );
    expect(hovered, isFalse);
    await hover(tester, find.text('Pill'));
    expect(hovered, isTrue);
  });

  testWidgets('5Q-8: the See more row inside the Plan card tints on hover',
      (tester) async {
    size(tester);
    await mount(
      tester,
      PlanWebHistory(
        entries: const [
          PlanHistoryEntry(id: 'a', date: 'Today', text: 'Your plan changed.'),
        ],
        hasMore: true,
        moreInsideCard: true,
        onMore: () {},
      ),
    );
    final row = find.ancestor(
      of: find.text('See more'),
      matching: find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).borderRadius != null,
      ),
    );
    Color? fill() =>
        (tester.widget<DecoratedBox>(row.first).decoration as BoxDecoration)
            .color;
    expect(fill(), Colors.transparent);
    await hover(tester, find.text('See more'));
    expect(fill(), const WebTokens(Brightness.dark).rowHover);
  });

  group('5Q-16: the full title shows only when the row cuts it', () {
    Future<void> row(WidgetTester tester, String title) => mount(
          tester,
          WebRow(title: title, tooltipWhenCut: true, onPressed: () {}),
        );

    testWidgets('a title that fits has no tooltip', (tester) async {
      size(tester);
      await row(tester, 'Order of operations');
      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('a title that is cut has one', (tester) async {
      size(tester);
      await row(
        tester,
        'Properties of real numbers and how they apply to every kind of '
        'arithmetic you will meet on the exam',
      );
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}
