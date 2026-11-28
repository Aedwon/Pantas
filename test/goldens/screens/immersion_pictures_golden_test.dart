// The wide reader in Immersion with a picture (an SVG illustration): an age
// problems lesson whose paragraph picture sits inline in the one centered
// column, with a Why? and a pair after it. At 1440, 1100 and 1728, light and
// dark.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../helpers/held_picture_fixtures.dart';
import '../../helpers/in_memory_database.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final dark in [false, true]) {
    goldenScreen(
      'immersion_pictures_${dark ? 'dark' : 'light'}',
      (tester, width) async {
        final db = inMemoryDatabase();
        addTearDown(db.close);
        final scroll = ScrollController();
        final offset = ValueNotifier<double>(0);
        final progress = ValueNotifier<double>(0);
        addTearDown(scroll.dispose);
        addTearDown(offset.dispose);
        addTearDown(progress.dispose);
        final target = await pumpScreen(
          tester,
          width,
          Scaffold(
            body: WebReaderLayout(
              reader: readerFor(
                'lesson-algebra-age-word-problems',
                agePicturesLesson(),
              ),
              controller: scroll,
              scrollOffset: offset,
              progress: progress,
              onBack: () {},
              onBookmark: () {},
              onLesson: (_) {},
              footer: const SizedBox(),
            ),
          ),
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          dark: dark,
        );
        afterCapture(() async {
          await tester.pumpWidget(const SizedBox());
        });
        return target;
      },
      widths: const [1440, 1100, 1728],
    );
  }
}
