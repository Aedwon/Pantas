import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/notifications/presentation/notification_tap_router.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:pantas/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({required this.flavor, super.key});

  final Flavor flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themePreferenceProvider).maybeWhen(
          data: (preference) => preference.themeMode,
          orElse: () => ThemeMode.system,
        );
    final gateway = ref.watch(notificationsGatewayProvider);
    return MaterialApp.router(
      title: flavor.displayName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: appLightTheme(),
      darkTheme: appDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => NotificationTapRouter(
        gateway: gateway,
        router: router,
        now: DateTime.now,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
