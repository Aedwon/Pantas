import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/application/session_debrief_provider.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('claim survives disposal, blocks a second session and isolates accounts',
      () async {
    final db = inMemoryDatabase();
    var now = DateTime(2026, 10, 30, 12);
    ProviderContainer container(String uid) => ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            authStateProvider.overrideWith(
              (_) => Stream.value(AuthState.anonymous(uid: uid)),
            ),
            nowProvider.overrideWithValue(() => now),
          ],
        );
    final first = container('one');
    expect(await first.read(sessionDebriefClaimProvider('a').future), isTrue);
    expect(await first.read(sessionDebriefClaimProvider('b').future), isFalse);
    first.dispose();
    final reopened = container('one');
    expect(
      await reopened.read(sessionDebriefClaimProvider('a').future),
      isFalse,
    );
    reopened.dispose();
    final other = container('two');
    expect(await other.read(sessionDebriefClaimProvider('c').future), isTrue);
    other.dispose();
    now = now.add(const Duration(days: 1));
    final tomorrow = container('one');
    expect(
      await tomorrow.read(sessionDebriefClaimProvider('a').future),
      isFalse,
    );
    expect(
      await tomorrow.read(sessionDebriefClaimProvider('d').future),
      isTrue,
    );
    tomorrow.dispose();
    await db.close();
  });

  test('concurrent sessions cannot both claim a day', () async {
    final db = inMemoryDatabase();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'one')),
        ),
      ],
    );
    final results = await Future.wait([
      container.read(sessionDebriefClaimProvider('a').future),
      container.read(sessionDebriefClaimProvider('b').future),
    ]);
    expect(results.where((v) => v), hasLength(1));
    container.dispose();
    await db.close();
  });

  test('all four reason kinds use the approved wording', () {
    expect(
      debriefBecause(PlanReasonKind.prerequisite, 'Algebraic Expressions'),
      'Algebraic Expressions builds on it.',
    );
    expect(
      debriefBecause(PlanReasonKind.followUp, 'Algebraic Expressions'),
      'Practice this before going back to Algebraic Expressions.',
    );
    expect(
      debriefBecause(PlanReasonKind.weakTopic, 'Algebra'),
      'Your recent answers in Algebra need work.',
    );
    expect(
      debriefBecause(PlanReasonKind.nextUp, 'Algebra'),
      'It is next in your plan for Algebra.',
    );
  });
}
