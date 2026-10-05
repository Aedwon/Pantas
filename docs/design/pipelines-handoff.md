# Handoff for Claude Design: Pantas pipelines page

Read from the repo on Oct 5, 2026: specs, plans, decision logs, and file lists on `main` and on the candidate branch `web/roadmap-engine-r1`.

## Status tags
- **Shipping line**: built and on `main`.
- **Candidate**: built on `web/roadmap-engine-r1` (105 commits ahead of `main`, last commit Oct 1) and not yet on `main`.
- **Planned**: specified, no code found.
- Some old specs describe things since changed. Where code and spec differ, this page follows the code.

## Context
Pantas is an Android-first Flutter exam reviewer for Philippine exams. It works fully offline. Content ships inside the app. The backend is Firebase (Singapore). Billing is RevenueCat over Google Play. Six things need a network: sign-in, sync, purchases, Pro content, the Wrapped web page, and account export or deletion.

## A. Content pipelines

**A1. Content, authoring to student** (Shipping line, already designed)
Write lessons (Markdown) and questions (YAML) -> check against content checklist, then blind-solve by someone other than the author -> importer validates (rejects a wrong choice without a note) -> review and approve in Question Studio -> add figures in Illustration Studio -> build the content database -> bundle in the app -> installed apps update content on launch.
Updates change content only, never progress. A revised question keeps its ID. A withdrawn question is hidden from practice but stays in history.

**A2. Content protection and signed package** (Candidate)
Approved plaintext content -> encrypted -> manifest (format v2, release sequence, source and payload hashes) with a detached signature -> verified on the phone -> installed with crash-safe promotion -> opened with its own key. An older package is rejected (anti-replay). Goal is extraction resistance, not DRM. Signing key stays with Aedwon.

**A3. Question QA round** (Candidate, content branches)
Three parallel worker agents (math, science, everything else) audit and expand every question against the Oct 1 rules, with a ledger per lesson. Result: all 158 lessons have at least 20 active questions (3,163 active), 799 added, 19 answer keys corrected, 134 questions flagged for Aedwon. Content authors reviewed their own work; the orchestrator checked mechanics only.

**A4. Illustrations** (Shipping line, partly)
279 lesson figure briefs: 241 drawn as code figures, 4 open assets, 23 native Markdown or LaTeX, 8 cut, 3 founder assets. Lesson Author gives a local review step before any upload. Question figures go through Illustration Studio. Questions with a pending figure stay inactive until the figure exists.

**A5. Content standards and audit** (standards merged to main Oct 4; audit Planned)
Standards cover Filipino-language content, source order, learning goals, and per-exam format profiles. The coverage audit then runs five approved levels: exam maps, overlap, lesson structure, lesson standards, quiz standards. It only reports findings. An automated check-and-edit pipeline follows later.

## B. Study engine

**B1. Placement and onboarding** (Shipping line)
Welcome -> age gate -> exam picker -> exam date -> name -> consent -> notification permission. Custom track adds a name and subjects. Then a one-time placement assessment (about 30 questions) gives per-topic scores and seeds the review scheduler.

**B2. Study loop** (Shipping line)
Student answers -> rating -> spaced-repetition scheduler (FSRS) sets the next review -> saved locally. Quiz modes: Today's Session (the only streak-eligible one), Drill a topic, Retake Mistakes, Quiz yourself. A per-student optimizer for FSRS is specified; no optimizer code found.

**B3. Prepared Today session** (Candidate)
Lightweight question metadata -> batched loading -> Today's session prepared ahead -> one launch owner starts it -> a stamp invalidates a stale session on any change. Resume keeps saved question order. Terminal sessions now close.

**B4. Adaptive roadmap** (Candidate; screens are a later design round)
Inputs: exam date, study days (Sun to Sat, at least one), excluded topics, topic accuracy, unread lessons, unseen questions, due reviews, recent answers per day, mock availability, four prerequisite links.
Each day: plan the stretch (a review-only stretch is the last 7 days or last quarter of time left, whichever is shorter) -> order topics (weakest first, prerequisites first, finish a topic before the next) -> size the day (lessons and new questions left / study days left, rounded up) -> add due reviews capped at the student's typical daily answers -> place one mock 1 to 6 days before the exam -> split into sittings (5, 10, 20, All; vocabulary grouped) -> freeze today.
Rebuilds on: new day, exam date, exam, scope, new content, assessment, study days. Each writes a change-log entry with a cause and no verdict.
"I want to advance" pulls in tomorrow's lessons and new questions. Mock answers now feed reviews and topic scores.
Feeds: Quiz Start, Home "Up next", reader "2 of N", reminders, plan screen. Free sees today and the mock day. Pro adds weeks ahead (topics only) and the synced change log.
States: needs assessment, no content, exam passed, month-only date, planning, review only, all covered.

**B5. Mock exam** (Shipping line)
Blueprint-sampled paper -> timed run with pause, flags, strict mode, crash-safe saves -> results with weak topics -> drill. Free gets 1 per 14 days per exam. Custom track builds the student's own mock.

## C. Insights and sharing

**C1. Metrics pipeline** (Shipping line)
Four layers over local data: signals (16 in code) -> Home atoms -> archetypes (14) -> Wrapped artifacts.

**C2. Tendency confidence** (Candidate)
Each tendency gets a state: early, forming, or clear, from standard tests (two-proportion z-test, Welch's t-test on log times, exact binomial test, Wilson interval). A sentence shows only when clear. Archetypes keep their 14-session floor.

**C3. Wrapped sharing** (Shipping line)
Trigger (post-mock, streak 7/30/100/365, mastery crossing, post-exam) -> composed 9:16 card -> privacy toggles -> shared -> pantas.app/wrapped/ID with preview tags -> store link. Revoked links show a generic page.

**C4. Notifications** (Shipping line)
Local only: daily reminder, streak save, exam countdown (30, 14, 7, 3, 2, 1, day of), comeback, Wrapped. A ceiling limits volume. Reschedules on every app open. Tap goes to Today's session.

## D. Accounts, data, money

**D1. Identity and sync** (Shipping line)
Anonymous and named Free users are local only. Sync runs only when the account is named, RevenueCat reports Pro, and a refreshed token carries the Pro claim. During the gap the state is "activating".
Local database -> queue -> batch every 5 seconds -> Firestore -> live listeners -> second device. Newest write wins per row. Content never syncs.
First sync decision: nothing on either side, push, pull, or the student chooses "keep this device" or "keep my account". If Pro lapses, sync stops and nothing is deleted.

**D2. Purchase and Pro** (Shipping line)
Google Play -> RevenueCat -> signed webhook (duplicate and rate-limit checks) -> Pro claim on the account -> app unlocks Pro and Pro content. Giveaways use a promotional grant through the same path. Prices: `docs/pricing.md` only.

**D3. Privacy and account data** (Partly built)
Export and delete exist. The export link is a placeholder. Two scheduled cleanups (orphan anonymous accounts, old audit logs) are empty stubs.

## E. Platform and trust

**E1. Telemetry** (Shipping line)
Off until the student consents. Twelve named events, each tied to a written question. Properties are checked; text, names, scores, and streaks are rejected. Crash reporting and an error boundary are separate.

**E2. Platform guards** (Shipping line)
App Check, remote flags (kill switch and version gate), review prompt, trial reminder.

## F. Delivery

**F1. Build and release** (Shipping line, publishing manual)
Pre-commit hooks -> pull request checks -> main adds integration tests and a dev APK -> `v*` tag makes unsigned artifacts -> signed build in Codemagic.
Release program on the candidate: E10 three isolated end-to-end passes -> E11 independent review -> E12 signed bundle -> E13 inspect the exact artifact -> E14 freeze, then Play upload and Play-installed checks. iOS publishing is disabled.

**F2. How work gets built** (Shipping line)
Idea -> spec -> plain-language approval -> plan -> implement -> independent review -> verify -> commit and push -> decision log and status update. A lead agent integrates and workers never merge. Aedwon does the visual check.

## Do not show
- Sanity as a live content source. Code exists but no runtime use was found.
- Any price or figure not in `docs/pricing.md`.
- Words in the app's banned list (behind, ahead, on track, ready, mastery, FSRS) inside app screens. They are fine on this internal page.

## Unverified
- Whether the approval flag gates what ships. An Aug 10 audit found it gated nothing.
- The latest acceptance state of E04 to E09. A Sep 8 note said the E04 work was blocked on a public signing key.
- Whether the sync failure indicators in the May spec (dot after 3 failures, banner after 24 hours) were built.
- Branch counts and file existence were checked; test results were not.
