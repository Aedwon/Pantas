import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

// QA 4N-1 and 4N-6: the sidebar search field against the board's `.srch`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  setUp(() {
    debugWebPlatformOverride = true;
    resetWebKeyboardFocus();
  });
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> mount(WidgetTester tester, {bool dark = true}) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
        home: Scaffold(
          body: Row(
            children: [
              WebSidebar(
                activeIndex: 0,
                person: 'Aerol',
                exam: 'CSE Pro',
                plan: 'Pro',
                onNavigate: (_) {},
                onSearch: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
    testWidgets('the key hint is 42 px wide and 8 px from the text, $platform',
        (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await mount(tester);
        final hint = find.descendant(
          of: find.byType(WebKeyHint),
          matching: find.byType(Container),
        );
        // The sidebar is as wide as its search row: 220 up to 244.
        expect(
          tester.getSize(find.byType(WebSidebar)).width,
          closeTo(230.4, .5),
        );
        final chip = tester.getRect(hint);
        // Board `.kc`: "Ctrl K" is 42 px. "Cmd K" gives its extra width back
        // from its own padding, so the text keeps the board's room.
        expect(chip.width, closeTo(42, .5));
        final text = tester.getRect(find.text('Search lessons'));
        expect(chip.left - text.right, 8);
        // The text is not cut, and the field's right padding is 10 px.
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text('Search lessons'),
        );
        expect(paragraph.didExceedMaxLines, isFalse);
        final field = tester.getRect(
          find.ancestor(
            of: find.text('Search lessons'),
            matching: find.byType(TextButton),
          ),
        );
        expect(field.right - chip.right, 10);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('Tab puts the 2 px accent ring on the search field (4N-6)',
      (tester) async {
    await mount(tester);
    final field = find.ancestor(
      of: find.text('Search lessons'),
      matching: find.byType(TextButton),
    );
    BorderSide side() => (tester
            .widget<Material>(
              find.descendant(of: field, matching: find.byType(Material)).first,
            )
            .shape! as OutlinedBorder)
        .side;
    // At rest it keeps the field's own 1 px rule.
    expect(side().width, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(side().width, 2);
    expect(side().color, buildDarkTheme(web: true).colorScheme.primary);
  });
}
