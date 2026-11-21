// Under-13 boards, built 1:1 from the picked boards. One sheet per screen, at
// the phone width the boards are drawn at (390).
//   1A    child_under_13          Main.dc.html
//   1A    child_under_13_closed   Decision 9 item 9 (no board)
//   2     child_parent_sign_in    S2S.dc.html
//   2A    child_parent_setup      S2A.dc.html
//   2A    child_parent_setup_used S2AE.dc.html
//   N2C   child_notice            N2C.dc.html
//   S7N   child_nickname          S7N.dc.html
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/onboarding/presentation/child/child_nickname_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/child_notice_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/parent_setup_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/parent_sign_in_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/under_thirteen_screen.dart';

import '../../helpers/child_setup_harness.dart';
import 'screen_harness.dart';

const _phone = [390.0];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  List<Override> overrides({
    FakeChildSetupGateway? gateway,
    bool closed = false,
  }) =>
      [
        authRepositoryProvider.overrideWithValue(fakeAuth()),
        childSetupGatewayProvider
            .overrideWithValue(gateway ?? FakeChildSetupGateway()),
        childSessionStarterProvider
            .overrideWithValue(FakeChildSessionStarter()),
        if (closed) childSetupClosedProvider.overrideWith((ref) => true),
      ];

  goldenScreen(
    'child_under_13',
    (tester, width) => pumpScreen(
      tester,
      width,
      const UnderThirteenScreen(),
      overrides: overrides(),
    ),
    widths: _phone,
  );

  goldenScreen(
    'child_under_13_closed',
    (tester, width) => pumpScreen(
      tester,
      width,
      const UnderThirteenScreen(),
      overrides: overrides(closed: true),
    ),
    widths: _phone,
  );

  goldenScreen(
    'child_parent_sign_in',
    (tester, width) => pumpScreen(
      tester,
      width,
      const ParentSignInScreen(),
      overrides: overrides(),
    ),
    widths: _phone,
  );

  goldenScreen(
    'child_parent_setup',
    (tester, width) => pumpScreen(
      tester,
      width,
      const ParentSetupScreen(),
      overrides: overrides(),
    ),
    widths: _phone,
  );

  goldenScreen(
    'child_parent_setup_used',
    (tester, width) async {
      final gateway = FakeChildSetupGateway()
        ..setupError =
            const ChildSetupException(ChildSetupFailure.emailHasAccount);
      final target = await pumpScreen(
        tester,
        width,
        const ParentSetupScreen(),
        overrides: overrides(gateway: gateway),
      );
      // Both ticks on, then the server refuses the email.
      // The box, not the middle of the row: the Terms link sits there.
      for (final row in [0, 1]) {
        final corner = tester.getTopLeft(find.byType(CheckboxRow).at(row));
        await tester.tapAt(corner + const Offset(30, 30));
      }
      await settleFrames(tester, 2);
      await tester.tap(find.text('Set Up Account'));
      await settleFrames(tester, 3);
      return target;
    },
    widths: _phone,
  );

  goldenScreen(
    'child_notice',
    (tester, width) => pumpScreen(
      tester,
      width,
      const ChildNoticeScreen(),
      overrides: overrides(),
    ),
    widths: _phone,
  );

  goldenScreen(
    'child_nickname',
    (tester, width) => pumpScreen(
      tester,
      width,
      ChildNicknameScreen(onSubmit: (_) async {}, onDone: () {}),
      overrides: overrides(),
    ),
    widths: _phone,
  );
}
