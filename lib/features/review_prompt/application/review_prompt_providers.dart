import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_controller.dart';
import 'package:pantas/features/review_prompt/data/review_prompt_store.dart';
import 'package:pantas/features/review_prompt/domain/app_review_gateway.dart';

/// Overridden in `bootstrap` with the drift-backed store. Left in memory in
/// tests, where there is no database behind `appDatabaseProvider`.
final reviewPromptStoreProvider = Provider<ReviewPromptStore>(
  (ref) => InMemoryReviewPromptStore(),
);

/// The SDK seam. Overridden in `bootstrap` with Play's own review API, and
/// left unavailable everywhere else, so nothing pops in a test.
final appReviewGatewayProvider = Provider<AppReviewGateway>(
  (ref) => const UnavailableReviewGateway(),
);

final reviewPromptControllerProvider = Provider<ReviewPromptController>(
  (ref) => ReviewPromptController(
    store: ref.watch(reviewPromptStoreProvider),
    gateway: ref.watch(appReviewGatewayProvider),
  ),
);
