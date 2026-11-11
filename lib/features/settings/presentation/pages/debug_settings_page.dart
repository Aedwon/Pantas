import 'package:flutter/foundation.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/ds.dart';

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
          ListRow(title: 'Wipe local data', hideTrailing: true),
          ListRow(title: 'Current entitlement state', hideTrailing: true),
          ListRow(title: 'Force resync', hideTrailing: true),
          ListRow(title: 'Raw last-sync', hideTrailing: true),
        ],
      ),
    );
  }
}
