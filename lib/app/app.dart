import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({required this.flavor, super.key});

  final Flavor flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: flavor.displayName,
      theme: appLightTheme(),
      darkTheme: appDarkTheme(),
      home: _PlaceholderHome(flavor: flavor),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome({required this.flavor});

  final Flavor flavor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(flavor.displayName)),
      body: Center(child: Text('Foundation OK — ${flavor.name}')),
    );
  }
}
