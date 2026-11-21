// Under-13 boards, built 1:1 from the picked boards. One sheet per screen, at
// the phone width the boards are drawn at (390).
//   8A    guardian_code_gate              C8AD.dc.html
//   4B    settings_for_parents            ST4B.dc.html (Switch Child is T10's)
//   4B    for_parents                     ST4B2.dc.html
//   4     for_parents_confirm_withdraw    D4W.dc.html
//   4     for_parents_confirm_delete      D4D.dc.html
//   4     for_parents_confirm_withdraw_last  D4LW.dc.html
//   4     for_parents_confirm_delete_last    D4L.dc.html
// The names are fixed fake text.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/child_setup/application/child_account_closer.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';
import 'package:pantas/features/child_setup/presentation/for_parents_page.dart';
import 'package:pantas/features/child_setup/presentation/guardian_code_gate_page.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../helpers/child_setup_harness.dart';
import '../../helpers/in_memory_database.dart';
import 'fixtures/settings_fixtures.dart';
import 'screen_harness.dart';

const _phone = [390.0];

LinkedChild _child(String uid, String nickname) =>
    (uid: uid, nickname: nickname, siblingOpenWithoutCode: false);

List<Override> _overrides({required bool last}) {
  final auth = fakeAuth();
  when(auth.listChildren).thenAnswer(
    (_) async => (
      children: [
        _child('child-1', 'Kiko'),
        if (!last) _child('child-2', 'Bea'),
      ],
      maskedHolderEmail: 'p***@example.test',
    ),
  );
  return [
    authRepositoryProvider.overrideWithValue(auth),
    authStateProvider.overrideWith(
      (ref) => Stream.value(
        const AuthState.signedIn(
          user: AuthUser(uid: 'child-1', email: '', displayName: ''),
        ),
      ),
    ),
    childSetupGatewayProvider.overrideWithValue(FakeChildSetupGateway()),
    childAccountCloserProvider.overrideWithValue(FakeChildAccountCloser()),
    userSettingsProvider.overrideWith(
      (ref) async => const UserSettings(
        name: 'Kiko',
        dailyReminderTime: null,
        studyDays: StudyDays.all,
        examDate: null,
        strictMockMode: false,
        helpImproveApp: false,
        carryOverProgress: true,
        sessionOrdering: SessionOrdering.interleavedTail,
        retainTableOrder: true,
        updatedAt: null,
      ),
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  goldenScreen(
    'guardian_code_gate',
    (tester, width) => pumpScreen(
      tester,
      width,
      const GuardianCodeGatePage(
        request: GuardianGateRequest(
          action: GuardianAction.withdraw,
          childId: 'child-1',
          nickname: 'Kiko',
          actionPhrase: GuardianGateCopy.withdrawalPhrase,
        ),
      ),
      overrides: _overrides(last: false),
    ),
    widths: _phone,
  );

  goldenScreen(
    'settings_for_parents',
    (tester, width) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await AppPreferencesRepository(db).setAgeGroup('child');
      return pumpScreen(
        tester,
        width,
        settingsFramed(const SettingsHomePage(), web: false),
        overrides: settingsOverrides(db),
      );
    },
    widths: _phone,
  );

  goldenScreen(
    'for_parents',
    (tester, width) => pumpScreen(
      tester,
      width,
      const ForParentsPage(),
      overrides: _overrides(last: false),
    ),
    widths: _phone,
  );

  for (final (name, action, last) in [
    ('for_parents_confirm_withdraw', ParentsAction.withdraw, false),
    ('for_parents_confirm_delete', ParentsAction.delete, false),
    ('for_parents_confirm_withdraw_last', ParentsAction.withdraw, true),
    ('for_parents_confirm_delete_last', ParentsAction.delete, true),
  ]) {
    goldenScreen(
      name,
      (tester, width) async {
        await pumpScreen(
          tester,
          width,
          ForParentsPage(confirmOnOpen: action),
          overrides: _overrides(last: last),
        );
        // The confirm sits in the navigator's overlay, above the page, so
        // the sheet is the whole window.
        return find.byType(MaterialApp);
      },
      widths: _phone,
    );
  }
}
