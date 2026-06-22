# Content Seed Delivery Implementation Plan

> **How to work this plan.** Implement it task by task, in order. For each task: write the
> failing test first, run it and confirm it fails, then write the code that makes it pass. Do
> not skip a step and do not batch tasks. Steps use checkbox (`- [ ]`) syntax so progress can
> be tracked.
>
> **Required reading before Task 1:** `AGENTS.md` at the repository root, in full. It carries
> the build commands, the visual identity bans, the voice rules, the never-invent-a-figure
> rule and the landmines, and every one of them applies to this plan whether or not the
> Global Constraints below happen to repeat it.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous, contradicts the spec, or looks
> wrong, **stop and say so** rather than inventing a solution. A plausible invention is more
> expensive than a question, because it looks finished.
>
> **Analyzer baseline:** `flutter analyze` reports **25 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. **The number drifts as those tools change; the
> invariant is that `lib/` and `test/` outside `test/tool/` are clean.** Any issue there is
> one you introduced.
>
> **Work only inside your worktree.** Never write to the main checkout. A previous run left a
> half-applied `app_database.dart` in the main tree with `schemaVersion` bumped and no
> migration: a broken state that compiles.
>
> **Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand and never
> committed.** This repo gitignores them.
>
> **No AI attribution in commit messages.** No `Co-Authored-By` trailers, no "Generated with"
> lines, no similar marker.

**Goal:** Make the bundled content database actually reach the app: declare it as an
asset, install it at bootstrap, resolve `contentDatabaseProvider`, and make the installer
replace a stale copy instead of ignoring it forever.

**Architecture:** No new subsystems. One line in `pubspec.yaml`, a version constant and a
device preference so the installer can tell a stale copy from a current one, and four
lines in `bootstrap.dart` between the storage overrides and `runApp`.

**Tech Stack:** Flutter, Drift, Riverpod, `path_provider`, `flutter_test`. No new packages.

**Source:** there is no design spec for this; it is a repair. Read `docs/superpowers/specs/2026-08-03-content-delivery-and-seed-upgrade-design.md` **Section 8 first**, which says which of the two content paths this plan owns: `content.db` for blueprints and mock papers, not `v1.json` for questions and lessons.

**Source:** `docs/superpowers/2026-08-02-work-checkpoint.md` section 3, and
`docs/superpowers/specs/2026-07-30-progress-tab-design.md` Section 10, "Delivery, which is
currently broken". There is no design spec for this; it is a repair.

---

## What is actually broken, verified on 2 August 2026

1. **`assets/seed/content.db` is not declared in `pubspec.yaml`.** Line 100 lists only
   `assets/seed/v1.json`, so the file ships in the repo and not in the bundle.
2. **`SeedInstaller` has no caller.** `grep -rln SeedInstaller lib` returns only its own
   file.
3. **`contentDatabaseProvider` throws.** `lib/core/content/content.dart:27` is a
   `Provider` whose body is `throw UnimplementedError('Override contentDatabaseProvider in
   main bootstrap or tests')`, and `bootstrapContentOverrides()` is never called.
   `bootstrap.dart` calls `bootstrapStorageOverrides()` only.
4. **`SeedInstaller.install()` never updates.** `seed_installer.dart:25` reads
   `if (destination.existsSync()) return;`. Once a copy is on the device, **no future app
   release can ever replace it**. This is the defect worth fixing beyond the wiring: it
   would ship silently and only surface as "the new questions never arrived".

## What this plan does not do, and it matters

**It does not make mock exams work.** The bundled `assets/seed/content.db` is a 20 July
artifact. Verified by querying it:

| Table | Rows |
|---|---|
| `content_exams` | 4 |
| `content_subjects` | 1 |
| `content_topics` | 1 |
| `content_questions` | 16 |
| `content_lessons` | 0 |
| `content_mock_blueprints` | **0** |
| `content_diagnostic_sets` | 0 |

Zero blueprints means `mockBlueprintsProvider` stays empty and no mock paper can be
assembled, exactly as before. **Regenerating the file is a content operation**, run through
`tools/build_content_seed/seed_writer.dart` against a Sanity export, and it is Aedwon's to
run rather than something this plan can do.

**It also changes nothing a student sees today.** The app reads
`assets/seed/v1.json` into `AppDatabase` via `Seeder`, and nothing in `lib/` currently
reads `contentDatabaseProvider`, which is why its `throw` has never fired. What this plan
buys is that the path exists and works, so the mock and blueprint work later does not have
to build it first, and so a regenerated database reaches devices when one is produced.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand, and never committed.** `.gitignore` excludes
  `**/*.g.dart` and `**/*.freezed.dart`.
- **No user-facing strings.** If you find yourself writing copy shown to a student, you are
  off-plan. Stop and say so.
- **Layering (`tool/check_layering.dart`).** R1: `lib/core/**` must not import
  `lib/features/**`. R2: one feature must not import another. R3: `domain/` must not import
  Flutter or platform packages.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Modify:**
- `pubspec.yaml` — declare the asset.
- `lib/core/content/bundle/seed_installer.dart` — version-aware install.
- `lib/core/content/content_database_opener.dart` — the version constant lives beside
  `contentDbFileName`.
- `lib/core/storage/data/repos/app_preferences_repository.dart` — read and write the
  installed version.
- `lib/app/bootstrap.dart` — install, then add the content overrides.

**Test:**
- `test/core/content/bundle/seed_installer_test.dart` — exists, gains the staleness cases.
- `test/core/content/bundle/content_asset_test.dart` — create.

---

## Task 1: Ship the asset and resolve the provider

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/app/bootstrap.dart`
- Test: `test/core/content/bundle/content_asset_test.dart` (create)

**Interfaces:**
- Consumes: `SeedInstaller` and `bootstrapContentOverrides`, both of which already exist.
- Produces: a resolvable `contentDatabaseProvider` at runtime. Nothing new in code.

- [ ] **Step 1: Write the failing test**

Create `test/core/content/bundle/content_asset_test.dart`:

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the content database ships in the asset bundle', () async {
    final data = await rootBundle.load('assets/seed/content.db');

    expect(data.lengthInBytes, greaterThan(0));
  });

  test('the bundled file is a SQLite database', () async {
    final data = await rootBundle.load('assets/seed/content.db');
    final header = data.buffer
        .asUint8List(data.offsetInBytes, 16)
        .map((b) => String.fromCharCode(b))
        .join();

    // Every SQLite file begins with this 16-byte magic string. The
    // sixteenth byte is a NUL, not a space, so it is written as an
    // escape: a literal NUL pasted into source is silently lossy.
    expect(header, 'SQLite format 3\x00');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/content/bundle/content_asset_test.dart`
Expected: FAIL with a `FlutterError` saying the asset was not found, because it is not
declared.

- [ ] **Step 3: Declare the asset**

In `pubspec.yaml`, under `flutter: assets:`, add the entry beneath the existing one so the
list stays alphabetical:

```yaml
  assets:
    - assets/seed/content.db
    - assets/seed/v1.json
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/content/bundle/content_asset_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 5: Install it and resolve the provider at bootstrap**

In `lib/app/bootstrap.dart`, add the two imports:

```dart
import 'package:cse_cet_reviewer/core/content/bundle/seed_installer.dart';
import 'package:cse_cet_reviewer/core/content/content.dart';
```

Then, **between** `bootstrapStorageOverrides()` and the `ProviderContainer`, install the
file and build the content overrides. Order matters: the database cannot be opened before
it exists on disk.

```dart
  final overrides = await bootstrapStorageOverrides();

  // The content database must be on disk before it can be opened, so the
  // install runs before the overrides that open it.
  await SeedInstaller().install();
  final contentOverrides = await bootstrapContentOverrides();

  final container = ProviderContainer(
    overrides: [
      ...overrides,
      ...contentOverrides,
      notificationServiceProvider.overrideWith(
        (ref) => ref.watch(featureNotificationServiceProvider),
      ),
      notificationPermissionStatusProvider.overrideWith(
        (ref) => ref.watch(featurePermissionStatusStreamProvider),
      ),
    ],
  );
```

Leave `await container.read(seederProvider).maybeSeed();` exactly where it is. It seeds
`AppDatabase` from `v1.json` and is a different path entirely.

- [ ] **Step 6: Verify nothing regressed**

Run: `flutter test`
Expected: PASS, whole suite. `bootstrap()` is not unit tested, so this proves the wiring
compiles and broke nothing.

- [ ] **Step 7: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add pubspec.yaml lib/app/bootstrap.dart test/core/content
git commit -m "fix(content): ship the content database and open it at startup

It has been in the repo and out of the bundle since July, SeedInstaller
had no caller, and contentDatabaseProvider threw on read. Nothing read it
yet, which is the only reason this was invisible."
```

---

## Task 2: A newer bundled database replaces the installed one

**Files:**
- Modify: `lib/core/content/content_database_opener.dart`
- Modify: `lib/core/content/bundle/seed_installer.dart`
- Modify: `lib/core/storage/data/repos/app_preferences_repository.dart`
- Modify: `lib/app/bootstrap.dart`
- Test: `test/core/content/bundle/seed_installer_test.dart`

**Interfaces:**
- Consumes: `AppPreferencesRepository` from Task 1's container, and the constant below.
- Produces: `const contentSeedVersion` in `content_database_opener.dart`;
  `AppPreferencesRepository.installedContentSeedVersion()` and
  `setInstalledContentSeedVersion(String)`; `SeedInstaller.install()` gains two named
  parameters, `installedVersion` and `bundledVersion`, and returns `Future<bool>` which is
  true when it wrote.

**The defect.** `seed_installer.dart:25` is `if (destination.existsSync()) return;`. A
device that installed the July database keeps it forever. Every future content release
lands in the bundle, never on disk, and the failure is silent: no crash, no error, just
content that never changes.

**Why a version constant and not a file hash.** Hashing a 6 MB asset on every cold start
costs real time on a Galaxy A15, and the answer is known at build time anyway. The
constant is bumped by whoever regenerates the database, which is the same person and the
same commit.

- [ ] **Step 1: Write the failing test**

Add to `test/core/content/bundle/seed_installer_test.dart`, matching its existing setup
idiom for `loadAssetBytes` and `destinationFile`:

```dart
  test('a first install writes the file', () async {
    final destination = File(p.join(tempDir.path, 'content.db'));
    final installer = SeedInstaller(
      loadAssetBytes: (_) async => Uint8List.fromList([1, 2, 3]),
      destinationFile: () async => destination,
    );

    final wrote = await installer.install(
      installedVersion: null,
      bundledVersion: '2026-07-20',
    );

    expect(wrote, isTrue);
    expect(destination.readAsBytesSync(), [1, 2, 3]);
  });

  test('the same version is not rewritten', () async {
    final destination = File(p.join(tempDir.path, 'content.db'))
      ..writeAsBytesSync([9, 9, 9]);
    final installer = SeedInstaller(
      loadAssetBytes: (_) async => Uint8List.fromList([1, 2, 3]),
      destinationFile: () async => destination,
    );

    final wrote = await installer.install(
      installedVersion: '2026-07-20',
      bundledVersion: '2026-07-20',
    );

    expect(wrote, isFalse);
    expect(destination.readAsBytesSync(), [9, 9, 9]);
  });

  test('a newer bundled version replaces the installed file', () async {
    final destination = File(p.join(tempDir.path, 'content.db'))
      ..writeAsBytesSync([9, 9, 9]);
    final installer = SeedInstaller(
      loadAssetBytes: (_) async => Uint8List.fromList([1, 2, 3]),
      destinationFile: () async => destination,
    );

    final wrote = await installer.install(
      installedVersion: '2026-07-20',
      bundledVersion: '2026-08-02',
    );

    expect(wrote, isTrue);
    expect(destination.readAsBytesSync(), [1, 2, 3]);
  });

  test('a file that vanished is reinstalled even at the same version',
      () async {
    final destination = File(p.join(tempDir.path, 'content.db'));
    final installer = SeedInstaller(
      loadAssetBytes: (_) async => Uint8List.fromList([1, 2, 3]),
      destinationFile: () async => destination,
    );

    final wrote = await installer.install(
      installedVersion: '2026-08-02',
      bundledVersion: '2026-08-02',
    );

    expect(wrote, isTrue);
    expect(destination.existsSync(), isTrue);
  });
```

The last case matters: the recorded version and the file on disk can disagree if the OS
cleared application support, and trusting the version alone would leave the app with no
database at all.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/content/bundle/seed_installer_test.dart`
Expected: FAIL. `install()` takes no named parameters and returns `Future<void>`.

- [ ] **Step 3: Add the version constant**

In `lib/core/content/content_database_opener.dart`, beside `contentDbFileName`:

```dart
const contentDbFileName = 'content.db';

/// Bumped whenever `assets/seed/content.db` is regenerated by
/// `tools/build_content_seed/seed_writer.dart`. It is how a device knows the
/// copy it installed is older than the one in the app it just updated to.
const contentSeedVersion = '2026-07-20';
```

`2026-07-20` is the build date of the file currently in the repo, established by querying
it. **Do not invent a different value.**

- [ ] **Step 4: Rewrite `install()`**

In `lib/core/content/bundle/seed_installer.dart`:

```dart
  /// Writes the bundled database to disk when the installed copy is missing or
  /// older than the bundled one. Returns true when it wrote.
  ///
  /// The file's existence is checked as well as the version, because the two
  /// can disagree: the OS may clear application support without the recorded
  /// version changing, and trusting the version alone would leave the app with
  /// no database at all.
  Future<bool> install({
    required String? installedVersion,
    required String bundledVersion,
  }) async {
    final destination = await _destinationFile();
    final upToDate =
        installedVersion == bundledVersion && destination.existsSync();
    if (upToDate) return false;

    await destination.parent.create(recursive: true);
    final bytes = await _loadAssetBytes(assetPath);
    await destination.writeAsBytes(bytes, flush: true);
    return true;
  }
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/core/content/bundle/seed_installer_test.dart`
Expected: PASS, 4 tests plus whatever the file already had.

- [ ] **Step 6: Store the installed version**

In `lib/core/storage/data/repos/app_preferences_repository.dart`, add the key and the pair
of accessors, in the same shape as the existing ones. **No legacy fallback**, since the key
never existed in `app_preferences_local`:

```dart
  static const _contentSeedVersionKey = 'content_seed_version';
```

```dart
  Future<String?> installedContentSeedVersion() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(_contentSeedVersionKey)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setInstalledContentSeedVersion(String version) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(
            key: _contentSeedVersionKey,
            value: version,
          ),
        );
  }
```

Add a round-trip test to
`test/core/storage/data/repos/app_preferences_repository_test.dart`:

```dart
  test('the installed content seed version round-trips', () async {
    expect(await repo.installedContentSeedVersion(), isNull);

    await repo.setInstalledContentSeedVersion('2026-08-02');

    expect(await repo.installedContentSeedVersion(), '2026-08-02');
  });
```

- [ ] **Step 7: Wire it in bootstrap**

Replace the single `await SeedInstaller().install();` line added in Task 1 with the
version-aware call. It needs the preferences repository, which lives in the container, so
it moves **after** the container is built and before anything reads content:

```dart
  final overrides = await bootstrapStorageOverrides();
  final contentOverrides = await bootstrapContentOverrides();

  final container = ProviderContainer(
    overrides: [
      ...overrides,
      ...contentOverrides,
      // ... the notification overrides, unchanged
    ],
  );

  await _installContentSeed(container);
```

and add the helper at the bottom of the file:

```dart
Future<void> _installContentSeed(ProviderContainer container) async {
  final prefs = container.read(appPreferencesRepositoryProvider);
  final wrote = await SeedInstaller().install(
    installedVersion: await prefs.installedContentSeedVersion(),
    bundledVersion: contentSeedVersion,
  );
  if (wrote) {
    await prefs.setInstalledContentSeedVersion(contentSeedVersion);
  }
}
```

**A problem to solve, not to ignore.** `bootstrapContentOverrides()` opens the database
file, and it now runs before the install writes it. Drift's `NativeDatabase` opens lazily,
so this works, but it is fragile and depends on nothing querying content before
`_installContentSeed` returns. **If you cannot satisfy yourself that the open is lazy,
stop and say so** rather than shipping an ordering that happens to work. The alternative is
to read the installed version straight from `device_prefs` before the container exists,
using a short-lived `AppDatabase` from the storage overrides.

- [ ] **Step 8: Run the whole suite**

Run: `flutter test`
Expected: PASS, whole suite. This is the last task, so the suite is the gate.

- [ ] **Step 9: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "fix(content): a content update can actually reach an installed app

install() returned early whenever the file existed, so the first copy a
device wrote was the last one it would ever have. Every later content
release would have landed in the bundle and never on disk, with no crash
and no error to notice."
```

---

## Verification

```bash
flutter analyze                                  # no issues outside tool/
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # no new violations
flutter test                                     # all pass
```

By hand, on a device, since Aedwon does the visual verification:

- A fresh install starts and reaches Home. `contentDatabaseProvider` no longer throws.
- Reinstalling over an existing install does not re-copy the database, and bumping
  `contentSeedVersion` in a debug build does.

**Still true after this plan, and expected:** `content_mock_blueprints` has zero rows, so
mock exams remain unavailable. That is content, produced by
`tools/build_content_seed/seed_writer.dart` against a Sanity export, and it is the next
thing standing between the app and a working mock.
