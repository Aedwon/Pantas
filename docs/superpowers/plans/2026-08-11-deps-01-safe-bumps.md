# Dependencies 01: the safe bumps

> **How to work this plan.** Task by task, in order. Commit the moment a task's
> own check passes, before starting the next one.
>
> **Required reading before Task 1:** `AGENTS.md` at the repository root, in full.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous or looks wrong,
> **stop and say so.** A plausible invention is more expensive than a question,
> because it looks finished.

**Goal:** Move the dependencies that have no API change behind them, so the
harder migrations that follow are not sitting on top of eleven stale packages.

**Source:** `docs/superpowers/2026-08-11-dependency-audit.md`, Group A and the
low-risk row of Group B.

**Tier:** Flash. This is mechanical.

## Global Constraints

- **Work only inside your worktree.** Run `pwd` before your first write.
- **Never run `flutter test` with no arguments. Never run `flutter analyze`.
  Never run `dart run build_runner`.** You may run a single test file. The full
  gates are run for you afterwards.
- **Never use `&`, `nohup`, or any background mechanism.**
- **Do not touch any package outside the table below.** `firebase_*`,
  `purchases_flutter`, `drift`, `sqlite3`, `sqlcipher_flutter_libs`,
  `flutter_riverpod`, `go_router`, `freezed`, `flutter_local_notifications`,
  `flutter_secure_storage`, `google_sign_in` and `very_good_analysis` are each
  their own round and several are already in flight. Leave them alone.
- **Do not edit `pubspec.lock` by hand.** `flutter pub get` writes it.
- **No AI attribution in commits.**

## What moves

| Package | From | To |
|---|---|---|
| `dio` | ^5.7.0 | ^5.11.0 |
| `path_provider` | ^2.1.4 | ^2.1.6 |
| `uuid` | ^4.5.1 | ^4.6.0 |
| `meta` | ^1.15.0 | latest that resolves |
| `app_settings` | ^5.1.1 | latest that resolves |
| `sign_in_with_apple` | ^6.1.2 | latest that resolves |
| `timezone` | ^0.9.4 | latest that resolves |

**`intl` and the codegen packages are deliberately not here.** `intl` is
constrained by `flutter_localizations`, and `build_runner`,
`json_serializable` and `json_annotation` need a regeneration you are not
allowed to run. Those are the dispatcher's.

---

## Task 1: The bumps that cannot fail

**Files:** `pubspec.yaml`, `pubspec.lock`

`dio`, `path_provider`, `uuid`, `meta`.

- [ ] **Step 1: Edit the constraints in `pubspec.yaml`**
- [ ] **Step 2: `flutter pub get`**

**If resolution fails, stop and report the conflict.** Do not widen another
package's constraint to force it.

- [ ] **Step 3: Prove nothing moved under the code that uses them**

Run these three files, one command each:

```bash
flutter test test/core/storage
flutter test test/features/sync
flutter test test/core/content
```

If a path does not exist, say so in your report and move on. Do not invent a
substitute.

- [ ] **Step 4: Commit**

---

## Task 2: The three small platform packages

**Files:** `pubspec.yaml`, `pubspec.lock`, and only the files that fail to
compile because of them.

`app_settings`, `sign_in_with_apple`, `timezone`.

- [ ] **Step 1: Bump all three and `flutter pub get`**
- [ ] **Step 2: Find every call site**

```bash
grep -rn "app_settings\|sign_in_with_apple\|timezone" lib/ test/
```

- [ ] **Step 3: Run the test file covering each call site you found**

**`timezone` is the one with a real chance of moving**, because the
notification scheduling uses it. If its API has changed, **stop and report what
changed**. Do not redesign the scheduling to fit a new API. That is a decision,
and `flutter_local_notifications` is being migrated separately.

- [ ] **Step 4: Commit**

---

## What to report

- The exact version each package resolved to, from `pubspec.lock`.
- The output of every test command you ran, pasted, not summarized.
- Anything you stopped on.

**Do not claim the gates are green.** You cannot run them. Report what you ran.
