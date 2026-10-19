import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/remote/content_cache.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/content/remote/content_service_providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';

class _NeverRemote implements ContentRemote {
  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) =>
      throw StateError('offline');
}

void main() {
  test('signing out removes cached Pro notes', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final auth = StreamController<AuthState>();
    addTearDown(auth.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentRemoteProvider.overrideWithValue(_NeverRemote()),
        authStateProvider.overrideWith((ref) => auth.stream),
      ],
    );
    addTearDown(container.dispose);
    await ContentCache(db).put(
      const ContentItem(
        kind: ContentKind.questions,
        id: 's1',
        version: 'v.p',
        tier: 'pro',
        data: {
          'questions': [
            {
              'choices': [
                {'text': 'a', 'rationale': 'why'},
              ],
            },
          ],
        },
      ),
    );
    container.read(contentServiceProvider);
    auth.add(const AuthState.anonymous(uid: 'u1'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(
        (await ContentCache(db).get(ContentKind.questions, 's1'))!.tier, 'pro');

    auth
      ..add(const AuthState.signedOut())
      ..add(const AuthState.anonymous(uid: 'u2'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final after = await ContentCache(db).get(ContentKind.questions, 's1');
    expect(after!.tier, 'free');
    expect(after.version, 'v.f');
  });
}
