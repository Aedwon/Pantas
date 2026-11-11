import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/data/firebase_beta_feedback_api.dart';
import 'package:pantas/features/beta_feedback/data/picker_beta_image_source.dart';

void main() {
  test('the default API and image source are the real ones', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(betaFeedbackApiProvider),
      isA<FirebaseBetaFeedbackApi>(),
    );
    expect(
      container.read(betaImageSourceProvider),
      isA<PickerBetaImageSource>(),
    );
  });

  test('with no signed-in user the sent list is empty', () async {
    final container = ProviderContainer(
      overrides: [currentUserProvider.overrideWith((ref) async => null)],
    );
    addTearDown(container.dispose);
    await container.read(currentUserProvider.future);
    expect(await container.read(betaFeedbackApiProvider).sent().first, isEmpty);
  });
}
