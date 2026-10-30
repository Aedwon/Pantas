import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/error/app_error_recovery.dart';
import 'package:pantas/core/platform/welcome/welcome_handover_providers.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/ui/web/web_layout_theme.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/notifications/presentation/notification_tap_router.dart';
import 'package:pantas/features/settings/presentation/widgets/sync_reconciliation_gate.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:pantas/l10n/app_localizations.dart';

class App extends ConsumerWidget {
  const App({required this.flavor, super.key});

  final Flavor flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(studyDeliveryLifecycleProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themePreferenceProvider).maybeWhen(
          data: (preference) => preference.themeMode,
          orElse: () => ThemeMode.system,
        );
    final gateway = ref.watch(notificationsGatewayProvider);
    // A learner who is already set up never needs the HTML Welcome screen.
    if (ref.watch(onboardingCompleteProvider).valueOrNull ?? false) {
      final handover = ref.read(welcomeHandoverProvider);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => handover.appReady(holdForTap: false),
      );
    }
    return MaterialApp.router(
      title: flavor.displayName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: appLightTheme(),
      darkTheme: appDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => WebLayoutTheme(
        child: AppErrorRecovery(
          child: SyncReconciliationGate(
            child: NotificationTapRouter(
              gateway: gateway,
              router: router,
              now: DateTime.now,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
