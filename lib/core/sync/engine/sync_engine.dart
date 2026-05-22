import 'package:cse_cet_reviewer/core/sync/engine/collection_registry.dart';

class SyncEngine {
  SyncEngine({
    required this.uid,
    required this.isAnonymous,
    Future<void> Function()? forceFlush,
  }) : _forceFlush = forceFlush ?? (() async {});

  final String uid;
  final bool isAnonymous;
  final Future<void> Function() _forceFlush;
  final _activeListenerPaths = <String>[];

  List<String> get activeListenerPaths =>
      List.unmodifiable(_activeListenerPaths);

  Future<void> start() async {
    if (isAnonymous) return;
    if (_activeListenerPaths.isNotEmpty) return;

    _activeListenerPaths.addAll(
      activeSyncCollections
          .where((entry) => entry.tableType != 'preferences')
          .map((entry) => 'users/$uid/${entry.firestorePath}'),
    );
  }

  Future<void> stop() async {
    _activeListenerPaths.clear();
  }

  Future<void> manualRefresh() async {
    await stop();
    await start();
    await _forceFlush();
  }
}
