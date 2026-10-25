import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';

import '../../../helpers/in_memory_database.dart';

class _FailingFirstFlag extends AppPreferencesRepository {
  _FailingFirstFlag(super.db);
  bool fail = true;

  @override
  Future<void> setAnnouncedFirstFlag() {
    if (fail) throw StateError('private preference failure');
    return super.setAnnouncedFirstFlag();
  }
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('flagging a question stores it', () async {
    await container.read(questionFlagControllerProvider.notifier).toggle('q_1');

    expect(await container.read(flaggedIdsProvider.future), contains('q_1'));
  });

  test('flagging twice removes it', () async {
    final controller = container.read(questionFlagControllerProvider.notifier);
    await controller.toggle('q_1');
    await controller.toggle('q_1');

    expect(await container.read(flaggedIdsProvider.future), isEmpty);
  });

  test('the first flag is announced once', () async {
    final controller = container.read(questionFlagControllerProvider.notifier);

    expect(await controller.toggle('q_1'), FlagToggle.firstFlagged);
    expect(await controller.toggle('q_2'), FlagToggle.flagged);
    expect(await controller.toggle('q_2'), FlagToggle.unflagged);
  });

  test('retry keeps flag intent after a partial announcement write failure',
      () async {
    container.dispose();
    final prefs = _FailingFirstFlag(db);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        appPreferencesRepositoryProvider.overrideWithValue(prefs),
      ],
    );
    final controller = container.read(questionFlagControllerProvider.notifier);
    final flags = container.read(questionFlagsRepositoryProvider);
    await expectLater(
      controller.setFlagged('q', flagged: true),
      throwsStateError,
    );
    final first = (await flags.flagsNewestFirst()).single.flaggedAt;
    prefs.fail = false;
    expect(
      await controller.setFlagged('q', flagged: true),
      FlagToggle.firstFlagged,
    );
    expect(await flags.isFlagged('q'), isTrue);
    expect((await flags.flagsNewestFirst()).single.flaggedAt, first);
    await controller.setFlagged('q', flagged: false);
    await controller.setFlagged('q', flagged: false);
    expect(await flags.isFlagged('q'), isFalse);
  });
}
