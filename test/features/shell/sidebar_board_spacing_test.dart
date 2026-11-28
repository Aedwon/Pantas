// U6: the wide sidebar spacing and brand type of boards X_Side and W_QuizTab
// (`.side` padding 22 14 20, search to Home 14 + 4, brand -0.02em).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

void main() {
  testWidgets('the sidebar keeps the board top padding and gaps',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: WebShellFrame(
          web: true,
          activeIndex: 0,
          person: 'Aerol',
          plan: 'Pro',
          onAccount: () {},
          onNavigate: (_) {},
          onSearch: () {},
          child: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final brand = find.text('Pantas');
    // Padding 22, then the brand's own 4 px of padding.
    expect(tester.getTopLeft(brand).dy, 26);
    expect(
      tester.widget<Text>(brand).style!.letterSpacing,
      closeTo(-0.44, 1e-9),
    );

    Rect rowOf(String label) => tester.getRect(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(TextButton),
          ),
        );
    final search = rowOf('Search lessons');
    final home = rowOf('Home');
    // Board: a 14 px margin under the search plus the 4 px column gap.
    expect(home.top - search.bottom, 18);
  });
}
