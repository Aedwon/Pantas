import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/ui/components/card_footer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';

import '../../../helpers/button_placement.dart';

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  testWidgets('wide signed-out Account sign-in pair keeps the 8 px gap',
      (tester) async {
    // Button placement rule: 8 px between a pair; it was 12 px before Nov 25.
    debugWebPlatformOverride = true;
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => null),
          paymentsOnWebProvider.overrideWithValue(true),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(web: true),
          routerConfig: GoRouter(
            routes: [
              GoRoute(path: '/', builder: (_, __) => const AccountPage()),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expectWidePlacement(tester, within: find.byType(CardFooter));
  });
}
