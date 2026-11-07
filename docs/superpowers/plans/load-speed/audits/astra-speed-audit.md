# Speed client lane audit

Read-only review of eae4b948a, 43d6d89f0, c83c6aa75 and 444dbaae7 against 64d1ab3b2, using spec Part 2 S3–S8. No source edits, builds or network calls.

## 1. P1: Plan deduplication bypasses the owner/core boundary

**Location:** `lib/features/home/presentation/home_today_screen.dart:225–234` (also `:246–267`, `:534–536`).

**Scenario:** Home has loaded a plan, then the active core token changes while the exam and exam-date widget key stay the same. The refreshed server plan can have exactly the same revision and membership. `_current()` checks only the exam, and `_builtFrom()` checks plan fields, so line 233 returns before `_retry()` and its owner check. The old `HomeTodayData`, including prepared question work and local lesson progress, remains displayed indefinitely with its old guard. A same-exam account transition that preserves this widget has the same defect. When the plan does differ, `_retry()` still exposes `_shown` while its asynchronous old-owner check reads the database, allowing stale content to remain visible during that check. This violates S6's owner boundary even though action guards may prevent stale writes.

**Fix:** Associate shown data with an owner/core generation and invalidate it when that generation changes, before plan equality or rendering. Preserve data during refresh only after establishing that it belongs to the current generation. Do not rely on a deferred guard check reached only for unequal plans. Cover both identical-plan and delayed-guard owner/core changes.

## 2. P2: Joining an older flush can leave newly completed work unsent

**Location:** `lib/features/home/data/study_observations.dart:50–52` (snapshot reads at `:97–105`).

**Scenario:** A lifecycle flush snapshots attempts and lesson reads, then waits on sending an older observation. The student finishes another quiz or lesson. The resulting lifecycle flush and Home's before-read flush share the same uid/exam/core key and join the existing future. The existing pass cannot see the new row, or a completion made after its snapshot, but both new callers return successfully when it finishes. Home then fetches a server plan that does not include the completed work. The observation stays unsent until another trigger causes a fresh flush. Previously, a separate reader instance started a fresh pass.

**Fix:** Track new flush requests during an active pass and drain a fresh snapshot before resolving those callers. Keep sends serialized and receipt checks intact so the follow-up pass uploads new work without resending acknowledged rows. Cover a completion inserted while an older send is blocked.

## Review coverage

- C4 / S3–S5: no additional confirmed defect. Remote Config handles fetch failures; beta prewarming handles errors and reuses the auth-dependent provider; payment setup installs the identity hook before yielding and remains awaited before sync.
- C5 / S6–S7: the two findings above. `DayPlan.operator ==` compares day, ordered ID lists, mock/rest flags, advanced IDs and reasons structurally. No separate plan-object equality defect was established. Receipt checks and per-send owner guards remain in place.
- C6 / S8: no additional confirmed defect in first-frame release, holding/error paths, skeleton visibility, reduced motion or splash timeouts.

Validation was static source inspection only, as requested. No runtime behavior was tested. The new splash JavaScript test calls `ready()` directly, so it does not itself verify Dart's first-frame integration.

verdict: ship after fixes
