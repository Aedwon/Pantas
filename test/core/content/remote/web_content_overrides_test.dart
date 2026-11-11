import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/content/remote/content_remote.dart';
import 'package:pantas/core/storage/storage.dart';

import '../../../helpers/in_memory_database.dart';

class _Remote implements ContentRemote {
  final calls = <String>[];
  bool signedIn = false;

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async {
    calls.add('${kind.wire}:${ids.join(",")}');
    if (!signedIn) throw StateError('unauthenticated');
    Map<String, Object?> data(String id) => switch (kind) {
          ContentKind.catalog => {
              'id': id,
              if (id == 'index') 'catalogs': ['exam_x'],
              if (id == 'exam_x')
                'lessons': [
                  {
                    'id': 'lesson-a-b',
                    'topic': 'topic_upcat_a',
                    'subtopic': 'subtopic_b',
                    'title': 'B',
                    'summary': 's',
                    'estimatedMinutes': 3,
                  },
                ],
            },
          ContentKind.lessons => {
              'id': id,
              'title': 'B',
              'summary': 's',
              'topic': 'topic-a',
              'estimatedMinutes': 3,
              'body': 'Hello.',
            },
          ContentKind.questions => {'id': id},
        };
    return ContentFetch(
      tier: 'free',
      entries: {
        for (final id in ids)
          id: RemoteEntry.ok(version: 'v.f', data: data(id)),
      },
    );
  }
}

void main() {
  test('without the web overrides the repositories get no fetch hook', () {
    final container = ProviderContainer(
      overrides: [
        contentDatabaseProvider.overrideWithValue(inMemoryContentDatabase()),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(contentFetchHookProvider), isNull);
  });

  test(
      'on web the repositories fetch through the mirror, and a sign-in '
      'refreshes the catalog', () async {
    final appDb = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    addTearDown(appDb.close);
    addTearDown(contentDb.close);
    final remote = _Remote();
    final auth = StreamController<AuthState>();
    addTearDown(auth.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        contentRemoteProvider.overrideWithValue(remote),
        authStateProvider.overrideWith((ref) => auth.stream),
        ...await bootstrapWebContentOverrides(open: () async => contentDb),
      ],
    );
    addTearDown(container.dispose);

    final mirror = container.read(contentMirrorProvider);
    await mirror.start();
    await mirror.idle;
    expect(remote.calls, ['catalog:index'], reason: 'not signed in yet');

    remote.signedIn = true;
    auth.add(const AuthState.anonymous(uid: 'u1'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await mirror.idle;
    expect(remote.calls, contains('catalog:exam_x'));

    final lesson = await container
        .read(contentRepositoryProvider)
        .lessonById('lesson-a-b');
    expect(lesson!.bodyJson.single['_type'], 'block');
    final same =
        await container.read(lessonRepoProvider).findById('lesson-a-b');
    expect(same!.title, 'B');
  });
}
