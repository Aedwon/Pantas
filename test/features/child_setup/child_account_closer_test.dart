import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/child_setup/application/child_account_closer.dart';

import '../../helpers/child_setup_harness.dart';
import '../../helpers/in_memory_database.dart';

void main() {
  late MockAuthRepository auth;
  late List<String> steps;
  late Exception? deleteError;

  setUp(() {
    auth = fakeAuth();
    steps = [];
    deleteError = null;
    when(auth.signOut).thenAnswer((_) async {
      steps.add('signOut');
    });
  });

  ProviderContainer container() {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(content.close);
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        notificationServiceProvider
            .overrideWithValue(const NoopNotificationService()),
        childStoreDeleterProvider.overrideWithValue((uid) async {
          steps.add('delete $uid');
          final error = deleteError;
          if (error != null) throw error;
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test("the child's own session erases, signs out, then deletes the store",
      () async {
    await container()
        .read(childAccountCloserProvider)
        .finish(holderSession: false, childId: 'child-1');
    expect(steps, ['signOut', 'delete child-1']);
  });

  test("the parent's session signs out and deletes that child's store too",
      () async {
    await container()
        .read(childAccountCloserProvider)
        .finish(holderSession: true, childId: 'child-2');
    expect(steps, ['signOut', 'delete child-2']);
  });

  test('a store that cannot be deleted does not undo the closing', () async {
    deleteError = Exception('locked');
    await container()
        .read(childAccountCloserProvider)
        .finish(holderSession: false, childId: 'child-1');
    expect(steps, ['signOut', 'delete child-1']);
  });
}
