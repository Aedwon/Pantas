import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';

void main() {
  test('contentDatabaseProvider throws until bootstrap override is supplied',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(contentDatabaseProvider),
      throwsA(isA<UnimplementedError>()),
    );
  });

  test('contentDatabaseProvider returns supplied content database override',
      () {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [contentDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    expect(container.read(contentDatabaseProvider), same(db));
  });

  test('bootstrap content override returns a ContentDatabase instance',
      () async {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final overrides = await bootstrapContentOverrides(open: () async => db);
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);

    expect(container.read(contentDatabaseProvider), same(db));
  });

  test('content repository providers use contentDatabaseProvider', () {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [contentDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    expect(container.read(examRepoProvider).database, same(db));
    expect(container.read(questionRepoProvider).database, same(db));
    expect(container.read(lessonRepoProvider).database, same(db));
  });
}
