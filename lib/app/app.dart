import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/app/router.dart';
import 'package:cse_cet_reviewer/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({required this.flavor, super.key});

  final Flavor flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: flavor.displayName,
      theme: appLightTheme(),
      darkTheme: appDarkTheme(),
      routerConfig: router,
    );
  }
}
