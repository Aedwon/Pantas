import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test(
      'Reviews reuse the existing lifetime guard and stable '
      'principal across auth changes', () async {
    final db = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    final auth = StreamController<AuthState>();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        authStateProvider.overrideWith((_) => auth.stream),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await auth.close();
      await contentDb.close();
      await db.close();
    });
    final authSub = container.listen(authStateProvider, (_, __) {});
    addTearDown(authSub.close);
    auth.add(const AuthState.anonymous(uid: 'one'));
    await container.read(authStateProvider.future);
    final repository = container.read(quizReviewBatchRepositoryProvider);
    final first = repository.capture('local', 'exam')!;
    expect(first.principal, 'anonymous:one');
    auth.add(const AuthState.signedOut());
    await Future<void>.delayed(Duration.zero);
    expect(repository.capture('local', 'exam'), isNull);
    auth.add(const AuthState.anonymous(uid: 'one'));
    await Future<void>.delayed(Duration.zero);
    final second = repository.capture('local', 'exam')!;
    expect(second.principal, first.principal);
    expect(second.accountLifetimeToken, isNot(first.accountLifetimeToken));
    final restarted = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'one')),
        ),
      ],
    );
    addTearDown(restarted.dispose);
    await restarted.read(authStateProvider.future);
    expect(
      restarted
          .read(quizReviewBatchRepositoryProvider)
          .capture('local', 'exam')!
          .principal,
      first.principal,
    );
  });
}
