import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bridges Riverpod providers to go_router's `refreshListenable`.
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(
    Ref ref,
    List<ProviderListenable<Object?>> providers,
  ) {
    for (final p in providers) {
      ref.listen<Object?>(p, (_, __) => notifyListeners());
    }
  }
}
