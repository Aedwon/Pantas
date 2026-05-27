import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugSettingsPage extends StatelessWidget {
  const DebugSettingsPage({super.key});

  static const enabled = kDebugMode && bool.fromEnvironment('DEBUG_SETTINGS');

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const Scaffold(
        body: Center(child: Text('Debug settings are unavailable.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Debug settings')),
      body: ListView(
        children: const [
          ListTile(title: Text('Wipe local data')),
          ListTile(title: Text('Current entitlement state')),
          ListTile(title: Text('Force resync')),
          ListTile(title: Text('Raw last-sync')),
        ],
      ),
    );
  }
}
