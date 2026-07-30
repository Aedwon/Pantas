# Dependencies 03: flutter_local_notifications, five majors

> **How to work this plan.** Task by task, in order. Commit the moment a task's
> own check passes, before starting the next one.
>
> **Required reading before Task 1:** `AGENTS.md` in full.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous, contradicts the
> plan, or looks wrong, **stop and say so.** A plausible invention is more
> expensive than a question, because it looks finished.

**Goal:** Move `flutter_local_notifications` from 17.2.4 to 22.x. It is five
major versions behind and the scheduling API has moved in that time.

**Why now:** it is independent of the dependency chain the audit is working
through, so it can run while that queue is blocked.

**Tier:** Pro. Small surface, and the API has genuinely changed under it.

## Global Constraints

- **Work only inside your worktree.** Run `pwd` before your first write.
- **Never run `flutter test` with no arguments. Never run `flutter analyze`.
  Never run `dart run build_runner`.** You may run a single test file.
- **Never use `&`, `nohup`, or any background mechanism.**
- **Touch `flutter_local_notifications` and `timezone` only.** Every other
  package is a separate round and some are in flight.
- **Do not change what the app does.** No new notification kinds, no new
  channels, no changed copy, no changed ids. Channel ids are visible to the
  operating system and changing one orphans every scheduled notification.
- **No AI attribution in commits.**

## The whole surface, so you do not have to hunt

| File | What it holds |
|---|---|
| `lib/features/notifications/data/flutter_local_notifications_gateway.dart` | Every call into the plugin. 147 lines. This is the migration. |
| `lib/features/notifications/application/notifications_providers.dart` | Wiring only. |
| `test/tool/notifications_boundary_test.dart` | Asserts only this gateway imports the plugin, and that the pubspec declares it. |

**The gateway is the only file that touches the plugin, and that is enforced by
a test.** Keep it that way.

---

## Task 1: The bump

**Files:** `pubspec.yaml`, `pubspec.lock`

- [ ] **Step 1: `flutter_local_notifications` to ^22.0.0**

`timezone` may have to move with it. If it does, say so in your report. If
anything else has to move, **stop and ask.**

- [ ] **Step 2: `flutter pub get`**

**If resolution fails, stop and report it.** Do not widen another package's
constraint to force it.

- [ ] **Step 3: Commit.** The code does not compile yet. Say so in the message.

---

## Task 2: The gateway

**File:** `lib/features/notifications/data/flutter_local_notifications_gateway.dart`

**Read the whole file first.** Then find what moved. These are the calls most
likely to have changed, and the list is a starting point, not a promise:

- `initialize` and its `onDidReceiveNotificationResponse` callback
- `resolvePlatformSpecificImplementation` and the two platform classes
- `zonedSchedule`, its `androidScheduleMode`, and
  `uiLocalNotificationDateInterpretation`, which may no longer exist
- `areNotificationsEnabled` and `requestNotificationsPermission`
- `getNotificationAppLaunchDetails`

**Rules for this task, and they matter more than speed:**

1. **Behavior stays identical.** Same ids, same channels, same payloads, same
   permission states, same exact-alarm scheduling.
2. **If the new API cannot express something the old one did**, stop and
   report it. Do not approximate. An alarm that fires at roughly the right time
   is a defect a student notices and we do not.
3. **Do not delete a capability to make it compile.** If `requestPermissions`
   for iOS is gone, say so rather than dropping iOS.

- [ ] **Step 1: Migrate the file**
- [ ] **Step 2: Run the two test files that cover it**

```bash
flutter test test/features/notifications/application/notification_service_test.dart
flutter test test/tool/notifications_boundary_test.dart
```

- [ ] **Step 3: Commit**

---

## Task 3: The contract test still has to mean something

**File:** `test/features/notifications/data/notifications_gateway_contract_test.dart`

Read it before changing anything. It tests a fake, not the plugin, so it may
need no change at all. **If it passes untouched, say so and change nothing.**

**What must not happen:** a test that passes because an assertion was removed or
weakened. If a case cannot be expressed against the new API, leave it failing
and report it. A test that cannot fail is worse than no test.

- [ ] **Step 1: Run it**
- [ ] **Step 2: Only if it fails, decide whether the fake or the assertion is
      wrong, and fix that one**
- [ ] **Step 3: Commit**

---

## What to report

- The versions that resolved, from `pubspec.lock`.
- **Every API that moved, named, old to new.** This is the most useful thing you
  will produce, because the next person hits the same wall.
- Anything the new API cannot do that the old one could.
- The pasted output of every command you ran.

**Do not claim the gates are green.** You cannot run them.

## What the dispatcher does after you

- Runs the full gates and the analyzer.
- Puts a build on the emulator and confirms a reminder actually fires. **No test
  can claim that**, and a scheduling migration is exactly where it breaks.
