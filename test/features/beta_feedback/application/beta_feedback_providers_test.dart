import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/data/firebase_beta_feedback_api.dart';

void main() {
  test('the default API is the real one', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(betaFeedbackApiProvider),
      isA<FirebaseBetaFeedbackApi>(),
    );
  });
}
