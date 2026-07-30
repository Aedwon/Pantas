import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';

import '../../../helpers/in_memory_database.dart';

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
}
