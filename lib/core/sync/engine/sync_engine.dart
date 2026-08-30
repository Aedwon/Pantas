import 'dart:async';

import 'package:pantas/core/sync/engine/collection_registry.dart';

class SyncEngine {
  SyncEngine({
    required this.uid,
    required this.isAnonymous,
    Future<void> Function()? forceFlush,
    Duration localMutationDebounce = defaultLocalMutationDebounce,
  })  : _forceFlush = forceFlush ?? (() async {}),
        _localMutationDebounce = localMutationDebounce;

  static const defaultLocalMutationDebounce = Duration(seconds: 5);

  final String uid;
  final bool isAnonymous;
  final Future<void> Function() _forceFlush;
  final Duration _localMutationDebounce;
  final _activeListenerPaths = <String>[];

  Timer? _localMutationTimer;
  String? _activeGenerationId;

  List<String> get activeListenerPaths =>
      List.unmodifiable(_activeListenerPaths);

  String? get activeGenerationId => _activeGenerationId;

  Future<void> start({required String generationId}) async {
    if (isAnonymous) return;
    if (generationId.isEmpty) {
      throw ArgumentError.value(
        generationId,
        'generationId',
        'must not be empty',
      );
    }
    if (_activeGenerationId == generationId &&
        _activeListenerPaths.isNotEmpty) {
      return;
    }
    if (_activeGenerationId != null || _activeListenerPaths.isNotEmpty) {
      await stop();
    }

    _activeGenerationId = generationId;
    _activeListenerPaths.addAll(
      activeSyncCollections.map(
        (entry) =>
            'users/$uid/sync_generations/$generationId/${entry.firestorePath}',
      ),
    );
  }

  Future<void> stop() async {
    _localMutationTimer?.cancel();
    _localMutationTimer = null;
    _activeListenerPaths.clear();
    _activeGenerationId = null;
  }

  Future<void> switchGeneration({
    required String generationId,
    required Future<void> Function() replaceLocalSnapshot,
  }) async {
    if (isAnonymous) return;
    await stop();
    await replaceLocalSnapshot();
    await start(generationId: generationId);
  }

  void notifyLocalMutation() {
    if (isAnonymous || _activeGenerationId == null) return;
    _localMutationTimer?.cancel();
    _localMutationTimer = Timer(_localMutationDebounce, () {
      _localMutationTimer = null;
      unawaited(_forceFlush());
    });
  }

  Future<void> onReconnect() async {
    if (isAnonymous || _activeGenerationId == null) return;
    _localMutationTimer?.cancel();
    _localMutationTimer = null;
    await _forceFlush();
  }

  Future<void> manualRefresh() async {
    if (isAnonymous) return;
    final generationId = _activeGenerationId;
    if (generationId == null) return;
    await stop();
    await start(generationId: generationId);
    await _forceFlush();
  }
}
