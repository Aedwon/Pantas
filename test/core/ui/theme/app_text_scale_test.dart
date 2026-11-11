import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_text_scale.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';

import '../../../helpers/in_memory_database.dart';

Widget _root(double osScale, Widget child) => MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(osScale)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AppTextScale(child: child),
      ),
    );

void main() {
  testWidgets('UI text follows the OS size up to 2.0, then stops', (
    tester,
  ) async {
    late TextScaler ui;
    await tester.pumpWidget(
      _root(
        3,
        Builder(
          builder: (context) {
            ui = MediaQuery.textScalerOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(ui.scale(10), 20);
  });

  testWidgets('UI text below the cap is left alone', (tester) async {
    late TextScaler ui;
    await tester.pumpWidget(
      _root(
        1.5,
        Builder(
          builder: (context) {
            ui = MediaQuery.textScalerOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(ui.scale(10), 15);
  });

  testWidgets('the reader reads the OS size, never the clamped one', (
    tester,
  ) async {
    late TextScaler os;
    late TextScaler lesson;
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider
              .overrideWithValue(AppPreferencesRepository(db)),
        ],
        child: _root(
          3,
          Builder(
            builder: (context) {
              os = OsTextScaler.of(context);
              return LessonTextScale(
                child: Builder(
                  builder: (context) {
                    lesson = MediaQuery.textScalerOf(context);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
    expect(os.scale(10), 30);
    // The lesson preference defaults to 1.0, so the lesson scaler is the OS
    // scaler: 3.0, not the clamped 2.0.
    expect(lesson.scale(10), 30);
  });

  testWidgets('OsTextScaler falls back to the ambient scaler', (tester) async {
    late TextScaler os;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
        child: Builder(
          builder: (context) {
            os = OsTextScaler.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(os.scale(10), 12);
  });
}
