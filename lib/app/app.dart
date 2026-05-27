import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/app/router.dart';
import 'package:cse_cet_reviewer/app/theme.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
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
    return MaterialApp.router(
      title: flavor.displayName,
      theme: appLightTheme(),
      darkTheme: appDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
