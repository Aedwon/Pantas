import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/child_setup/application/child_account_closer.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';
import 'package:pantas/features/child_setup/presentation/for_parents_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../helpers/child_setup_harness.dart';

const _withdrawBody = 'Kiko is signed out. Their account and study records '
    'are deleted. This cannot be undone. It does not cancel an app store '
    'subscription. Withdrawing is free. Limited records stay as the Child '
    'Notice explains.';
const _deleteBody = "This deletes your child's study records from our "
    'servers. It keeps only the records the Child Notice lists. Copies on '
    'other devices stay until cleared.';
const _lastChild = 'This is your last child on this email. Closing it also '
    'closes your sign-in and removes its active sign-in details. Limited '
    'consent, payment, security, support and backup records remain as the '
    'Child Notice explains.';

LinkedChild _child(String uid, String nickname) =>
    (uid: uid, nickname: nickname, siblingOpenWithoutCode: false);

void main() {
  late FakeChildSetupGateway gateway;
  late FakeChildAccountCloser closer;
  late MockAuthRepository auth;
  late List<String> mailOpened;
  late List<GuardianGateRequest> gates;
  String? gateProof;
  var notices = 0;
  var closed = 0;
  var notHeld = 0;

  setUp(() {
    gateway = FakeChildSetupGateway();
    closer = FakeChildAccountCloser();
    auth = fakeAuth();
    when(auth.listChildren).thenAnswer(
      (_) async => (
        children: [_child('child-1', 'Kiko'), _child('child-2', 'Bea')],
        maskedHolderEmail: 'p***@example.test',
      ),
    );
    mailOpened = [];
    gates = [];
    gateProof = 'proof-1';
    notices = 0;
    closed = 0;
    notHeld = 0;
  });

  Future<void> pump(
    WidgetTester tester, {
    String? childId,
    ParentsAction? confirmOnOpen,
    bool holderSession = false,
    String localName = 'Kiko',
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const AuthState.signedIn(
                user: AuthUser(uid: 'child-1', email: '', displayName: ''),
              ),
            ),
          ),
          childSetupGatewayProvider.overrideWithValue(gateway),
          childAccountCloserProvider.overrideWithValue(closer),
          dpoMailOpenerProvider.overrideWithValue((email) async {
            mailOpened.add(email);
          }),
          userSettingsProvider.overrideWith(
            (ref) async => UserSettings(
              name: localName,
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
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: ForParentsPage(
            childId: childId,
            confirmOnOpen: confirmOnOpen,
            holderSession: holderSession,
            onOpenNotice: () => notices++,
            onClosed: () => closed++,
            onNotHeld: () => notHeld++,
            onOpenGate: (request) async {
              gates.add(request);
              return gateProof;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  CenteredDialog dialog(WidgetTester tester) =>
      tester.widget<CenteredDialog>(find.byType(CenteredDialog));

  group('the page (board ST4B2)', () {
    testWidgets('shows the board text, rows and consequence line',
        (tester) async {
      await pump(tester);
      expect(find.text('For parents'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(
          find.text('These actions apply to this child only.'), findsOneWidget);
      expect(find.text('Read the Child Notice'), findsOneWidget);
      expect(find.text("Get a copy of your child's data"), findsOneWidget);
      expect(
        find.text('Withdraw permission and close account'),
        findsOneWidget,
      );
      expect(
        find.text(
          'This is free. Study processing stops and the account closes. '
          'Limited records remain for the purposes and periods in the Child '
          'Notice. Earlier lawful processing remains lawful.',
        ),
        findsOneWidget,
      );
      expect(find.text('Delete this account'), findsOneWidget);
    });

    testWidgets('has no Switch Child row yet', (tester) async {
      await pump(tester);
      expect(find.text('Switch Child'), findsNothing);
    });

    testWidgets('the two destructive rows are destructive', (tester) async {
      await pump(tester);
      final rows = tester.widgetList<ListRow>(find.byType(ListRow)).toList();
      expect(
        rows.where((r) => r.variant == ListRowVariant.destructive).map(
              (r) => r.title,
            ),
        ['Withdraw permission and close account', 'Delete this account'],
      );
    });

    testWidgets('the Child Notice row opens the notice', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Read the Child Notice'));
      expect(notices, 1);
    });

    testWidgets('asks the server for the children when it opens',
        (tester) async {
      await pump(tester);
      verify(auth.listChildren).called(1);
    });
  });

  group('the data copy', () {
    testWidgets('shows the data protection officer in a one-button dialog',
        (tester) async {
      await pump(tester);
      await tester.tap(find.text("Get a copy of your child's data"));
      await tester.pumpAndSettle();
      expect(find.byType(CenteredDialog), findsOneWidget);
      expect(dialog(tester).title, "Get a copy of your child's data");
      expect(
        dialog(tester).message,
        'Write to dpo@pantas.study from the email you used to set up this '
        'account. We will check it is you and send the copy.',
      );
      expect(dialog(tester).secondaryLabel, isNull);
      expect(find.text('Got It'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
      // No code is asked, and nothing is requested.
      expect(gateway.codeRequests, isEmpty);
      expect(gates, isEmpty);
    });

    testWidgets('the address opens mail and Got It closes it', (tester) async {
      await pump(tester);
      await tester.tap(find.text("Get a copy of your child's data"));
      await tester.pumpAndSettle();
      final paragraph = tester.renderObject<RenderParagraph>(
        find
            .byWidgetPredicate(
              (w) =>
                  w is RichText && w.text.toPlainText().startsWith('Write to'),
            )
            .first,
      );
      const link = 'dpo@pantas.study';
      final at = paragraph.text.toPlainText().indexOf(link);
      final box = paragraph
          .getBoxesForSelection(
            TextSelection(baseOffset: at, extentOffset: at + link.length),
          )
          .first
          .toRect();
      await tester.tapAt(paragraph.localToGlobal(box.center));
      await tester.pump();
      expect(mailOpened, [link]);
      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();
      expect(find.byType(CenteredDialog), findsNothing);
    });
  });

  group('the four confirms', () {
    testWidgets('withdraw (D4W): the nickname comes from the server list',
        (tester) async {
      await pump(tester, localName: 'Local name');
      await tester.tap(find.text('Withdraw permission and close account'));
      await tester.pumpAndSettle();
      expect(dialog(tester).title, 'Withdraw Permission for Kiko?');
      expect(dialog(tester).message, _withdrawBody);
      expect(dialog(tester).primaryLabel, 'Withdraw');
      expect(dialog(tester).secondaryLabel, 'Cancel');
      expect(dialog(tester).destructive, isTrue);
    });

    testWidgets('delete (D4D)', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Delete this account'));
      await tester.pumpAndSettle();
      expect(dialog(tester).title, 'Delete this account?');
      expect(dialog(tester).message, _deleteBody);
      expect(dialog(tester).primaryLabel, 'Delete');
      expect(dialog(tester).secondaryLabel, 'Cancel');
    });

    testWidgets('withdraw, last child (D4LW)', (tester) async {
      when(auth.listChildren).thenAnswer(
        (_) async => (
          children: [_child('child-1', 'Kiko')],
          maskedHolderEmail: 'p***@example.test',
        ),
      );
      await pump(tester);
      await tester.tap(find.text('Withdraw permission and close account'));
      await tester.pumpAndSettle();
      expect(dialog(tester).title, 'Withdraw Permission for Kiko?');
      expect(dialog(tester).message, '$_withdrawBody $_lastChild');
    });

    testWidgets('delete, last child (D4L)', (tester) async {
      when(auth.listChildren).thenAnswer(
        (_) async => (
          children: [_child('child-1', 'Kiko')],
          maskedHolderEmail: 'p***@example.test',
        ),
      );
      await pump(tester);
      await tester.tap(find.text('Delete this account'));
      await tester.pumpAndSettle();
      expect(dialog(tester).message, '$_deleteBody $_lastChild');
    });

    testWidgets('a failed list shows the last-child wording and nothing else',
        (tester) async {
      when(auth.listChildren)
          .thenAnswer((_) async => throw const AuthGatewayException('x'));
      await pump(tester);
      expect(find.byType(NoticeStrip), findsNothing);
      await tester.tap(find.text('Delete this account'));
      await tester.pumpAndSettle();
      expect(dialog(tester).message, '$_deleteBody $_lastChild');
      expect(find.byType(NoticeStrip), findsNothing);
    });

    testWidgets('the list is asked again each time the page opens',
        (tester) async {
      await pump(tester);
      await tester.pumpWidget(const SizedBox());
      await pump(tester);
      verify(auth.listChildren).called(2);
    });

    testWidgets('Cancel closes the confirm and asks for nothing',
        (tester) async {
      await pump(tester);
      await tester.tap(find.text('Delete this account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(CenteredDialog), findsNothing);
      expect(gates, isEmpty);
      expect(gateway.closed, isEmpty);
    });
  });

  group('closing the account', () {
    testWidgets('withdraw needs the gate, then calls the server, then clears',
        (tester) async {
      await pump(tester);
      await tester.tap(find.text('Withdraw permission and close account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();
      expect(gates, hasLength(1));
      expect(gates.single.action, GuardianAction.withdraw);
      expect(gates.single.childId, 'child-1');
      expect(gates.single.nickname, 'Kiko');
      expect(gates.single.actionPhrase, 'withdrawal');
      expect(gateway.closed, [(GuardianAction.withdraw, 'child-1', 'proof-1')]);
      expect(closer.finished, [false]);
      expect(closed, 1);
    });

    testWidgets('delete says deletion and uses the delete callable',
        (tester) async {
      await pump(tester);
      await tester.tap(find.text('Delete this account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(gates.single.action, GuardianAction.delete);
      expect(gates.single.actionPhrase, 'deletion');
      expect(gateway.closed, [(GuardianAction.delete, 'child-1', 'proof-1')]);
      expect(closer.finished, [false]);
    });

    testWidgets('no proof means no server call and nothing cleared',
        (tester) async {
      gateProof = null;
      await pump(tester);
      await tester.tap(find.text('Delete this account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(gates, hasLength(1));
      expect(gateway.closed, isEmpty);
      expect(closer.finished, isEmpty);
      expect(closed, 0);
    });

    testWidgets('a server refusal shows the error and clears nothing',
        (tester) async {
      gateway.closeError =
          const GuardianGateException(GuardianGateFailure.proofInvalid);
      await pump(tester);
      await tester.tap(find.text('Delete this account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'We could not complete deletion. Try again or contact our DPO at '
          'dpo@pantas.study.',
        ),
        findsOneWidget,
      );
      expect(closer.finished, isEmpty);
      expect(closed, 0);
    });

    testWidgets('a withdraw refusal says withdrawal', (tester) async {
      gateway.closeError =
          const GuardianGateException(GuardianGateFailure.other);
      await pump(tester);
      await tester.tap(find.text('Withdraw permission and close account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'We could not complete withdrawal. Try again or contact our DPO at '
          'dpo@pantas.study.',
        ),
        findsOneWidget,
      );
    });
  });

  group("the parent's own session (the receipt link)", () {
    testWidgets('shows the delete confirm for that child with the nickname',
        (tester) async {
      await pump(
        tester,
        childId: 'child-2',
        holderSession: true,
        confirmOnOpen: ParentsAction.delete,
      );
      expect(find.byType(CenteredDialog), findsOneWidget);
      expect(dialog(tester).title, 'Delete this account?');
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(gates.single.childId, 'child-2');
      expect(gates.single.nickname, 'Bea');
      expect(gateway.closed, [(GuardianAction.delete, 'child-2', 'proof-1')]);
      // The parent's session cleared the device the way sign-out does.
      expect(closer.finished, [true]);
    });

    testWidgets('a child the parent does not hold is reported', (tester) async {
      await pump(
        tester,
        childId: 'someone-else',
        holderSession: true,
        confirmOnOpen: ParentsAction.delete,
      );
      expect(notHeld, 1);
      expect(find.byType(CenteredDialog), findsNothing);
    });

    testWidgets('an account with no children at all is reported',
        (tester) async {
      when(auth.listChildren).thenAnswer(
        (_) async => throw const AuthGatewayException('permission-denied'),
      );
      await pump(
        tester,
        childId: 'child-1',
        holderSession: true,
        confirmOnOpen: ParentsAction.delete,
      );
      expect(notHeld, 1);
    });
  });
}
