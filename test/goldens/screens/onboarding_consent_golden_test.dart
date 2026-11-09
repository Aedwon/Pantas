// Route /onboarding, consent step.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/onboarding_steps_harness.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen('onboarding_consent', (tester, width) async {
    final boundary = GlobalKey();
    await pumpFramedStep(
      tester,
      'consent',
      wide: width >= 1024,
      width: width,
      boundary: boundary,
    );
    return find.byKey(boundary);
  });
}
