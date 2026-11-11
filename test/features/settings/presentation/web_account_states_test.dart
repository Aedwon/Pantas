import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/public_id_provider.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';

import '../../../helpers/pump_app.dart';

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);
  testWidgets('Pantas ID copies digits only and restores after two seconds',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? copied;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpAppWithProviders(
      Theme(data: buildLightTheme(web: true), child: const AccountPage()),
      overrides: [
        currentUserProvider.overrideWith(
          (ref) async => const AuthUser(
            uid: 'a',
            email: 'a@example.com',
            displayName: 'A',
          ),
        ),
        publicIdProvider.overrideWith(
          (ref) => Stream.value(const PublicIdState.ready('482139075')),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byType(Avatar), findsOneWidget);
    expect(find.text('482 139 075'), findsOneWidget);
    await tester.tap(find.text('Pantas ID'));
    await tester.pump();
    expect(copied, '482139075');
    expect(find.text('Copied'), findsOneWidget);
    expect(find.byIcon(PantasIcons.check), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('482 139 075'), findsOneWidget);
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    expect(find.byType(CenteredDialog), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('centered-dialog-surface')))
          .width,
      440,
    );
    expect(
      find.descendant(
        of: find.byType(CenteredDialog),
        matching: find.byType(WebButton),
      ),
      findsNWidgets(2),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(CenteredDialog), findsNothing);
  });
}
