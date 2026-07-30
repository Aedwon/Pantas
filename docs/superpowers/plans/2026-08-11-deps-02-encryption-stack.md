# Dependencies 02: the encryption stack, one change or none

> **How to work this plan.** Task by task, in order. Commit the moment a task's
> own check passes, before starting the next one.
>
> **Required reading before Task 1:** `AGENTS.md` in full, then
> `docs/superpowers/2026-08-11-dependency-audit.md`, the finding at the top.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous or looks wrong,
> **stop and say so.**

**Goal:** Get off `sqlcipher_flutter_libs`, which is end of life and does
nothing from 0.7.0, and onto SQLite3MultipleCiphers, which is how drift does
encryption from 2.32.

**Why it cannot be done in pieces.** Bumping the dead package alone makes the
loader a no-op. The opener's guard then fires and the app will not start. The
package removal, the drift bump, the sqlite3 bump and the new cipher are one
change or none.

**Tier:** Pro. It is small in lines and unforgiving in detail.

## Global Constraints

- **Work only inside your worktree.** Run `pwd` before your first write.
- **Never run `flutter test` with no arguments. Never run `flutter analyze`.
  Never run `dart run build_runner`.** You may run a single test file.
- **Never use `&`, `nohup`, or any background mechanism.**
- **Generated files are never edited by hand.** If drift's generated output
  looks stale after the bump, **stop and report it.** Regenerating is the
  dispatcher's job and it happens before the gates are judged.
- **Touch no package other than the four named here.**
- **No AI attribution in commits.**

## The one thing that must not be lost

**There is a real encrypted database on the test device right now.** It was
written by SQLCipher, and Aedwon has been testing against it: attempts, custom
tracks, settings. SQLite3MultipleCiphers can open a SQLCipher database, but
only if it is told to, and the pragmas that tell it must run **before** the key
is set.

**So this is not a clean-slate change.** The audit says there was no data to
migrate. That was written before a day of testing on the emulator.

---

## Task 1: The packages

**Files:** `pubspec.yaml`, `pubspec.lock`

- [ ] **Step 1: Make these four changes together**

| Package | Change |
|---|---|
| `drift` | ^2.20.0 to ^2.34.0 |
| `drift_dev` (dev) | ^2.20.0 to ^2.34.0 |
| `sqlite3` | ^2.4.0 to ^3.5.0 |
| `sqlcipher_flutter_libs` | **remove the line** |

- [ ] **Step 2: Add the build hook that bundles the cipher**

At the top level of `pubspec.yaml`, a sibling of `dependencies`:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
```

- [ ] **Step 3: `flutter pub get`**

**If resolution fails, stop and report it.**

- [ ] **Step 4: Commit.** Nothing compiles yet. Say so in the message.

---

## Task 2: The opener

**File:** `lib/core/storage/data/database_opener.dart`

**Read the whole file first.** It is 72 lines.

What has to change, and nothing else:

1. **Drop the `sqlcipher_flutter_libs` import** and the
   `applyWorkaroundToOpenSqlCipherOnOldAndroidVersions()` call.
2. **Drop the `isolateSetup` that overrides the Android loader**, and the
   `package:sqlite3/open.dart` import if nothing else uses it. The cipher now
   comes from the bundled library, not a loader override.
3. **Before the existing `PRAGMA key`, run these two, in this order:**

```dart
db.execute("PRAGMA cipher = 'sqlcipher';");
db.execute('PRAGMA legacy = 4;');
```

**These are what let the new library read the database SQLCipher wrote.**
Without them the existing install fails to open. Leave a comment saying that.

4. **Keep the `PRAGMA cipher_version` guard exactly as it is.** It is what makes
   a botched upgrade crash at launch instead of silently writing an unencrypted
   database. Do not soften it, do not wrap it in a try, do not make it debug
   only.
5. **Do not change the key, the key storage, the file name, or the hex
   encoding.**

- [ ] **Step 1: Make the change**
- [ ] **Step 2: Run the storage tests**

```bash
flutter test test/core/storage
```

- [ ] **Step 3: Commit**

---

## Task 3: A test that proves the guard still bites

**File:** `test/core/storage/database_opener_test.dart` (create if absent;
if a file of that name exists, add to it and do not rewrite it)

The opener touches the platform, so do not try to open a real encrypted file in
a unit test. **Test the one thing that is pure:** that a setup which sees no
rows from `PRAGMA cipher_version` throws.

If the current shape of the code makes that untestable without redesigning it,
**stop and report that**. Do not restructure the opener to make a test possible.
That is a decision, not an implementation detail.

- [ ] **Step 1: Write the test**
- [ ] **Step 2: Run that one file**
- [ ] **Step 3: Commit**

---

## What to report

- The versions that resolved, from `pubspec.lock`.
- The full text of the new `setup` block.
- The output of every test command you ran, pasted.
- Anything you stopped on.

**Do not claim the gates are green.** You cannot run them.

## What the dispatcher does after you

- Regenerates the drift output and judges the gates.
- Installs the build on the emulator and confirms the existing database still
  opens with the student's data intact. **No test can claim that.**
