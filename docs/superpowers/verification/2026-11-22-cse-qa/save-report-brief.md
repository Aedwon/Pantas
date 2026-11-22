# Audit brief: quiz answer save path and question report path (read only)

Startup: you work on Aedwon/Pantas. Policy is AGENTS.md, WORKFLOW.md and SUBAGENTS.md
from origin/main (policy commit ecfeaf0d1); read them with `git show origin/main:<file>`.
This is a READ-ONLY audit. Edit no tracked file. Do not run flutter, builds, emulators,
network calls, or anything against Firebase. Write findings ONLY to your findings file
(named in your prompt), appending each finding the moment you find it, not at the end.

Code: this worktree (branch qa/cse-release-r1, same app code as origin/main 67ed1b52b).
Prod content tree (what prod serves): build/audit/prodtree/content (from content/cet-bite-r1
d97de9415). Main's content tree: content/.

## Known so far (do not re-derive; build on it)
- Prod, Nov 22: "Could not save your progress" on quiz questions. Cause confirmed: SubmitAnswer
  (lib/features/quiz/domain/use_cases/submit_answer.dart) awaited a question_answered analytics
  event before saving; lib/core/telemetry/telemetry.dart assertPropertiesAllowed threw on string
  values not matching ^[a-zA-Z0-9_-]{1,64}$. 261 of 4,427 prod question ids are over 64 chars.
  A hotfix is in review on another branch (gate drops bad properties; log after save).
- Question reports: queued on the device only; ReportQueue.sendPending has no backend
  ("No approved backend endpoint"). The student sees "Saved on this device.".
- Firestore App Check and rules allowed every call from the reporting phone.

## What to find
A. Every OTHER way a quiz answer save (practice, Today/review sessions, in-lesson quiz,
   inline quiz, mock) can fail or be blocked for one specific question while others work.
   Trace end to end: quiz controller -> SubmitAnswer -> review state / review log / quiz
   session repositories (Drift, web IndexedDB) -> sync outbox -> server ingest
   (functions/src/_answers.ts and callers, sync callables) -> Firestore rules. List every
   limit, pattern, length, uniqueness or shape rule applied to a question id, choice id,
   chosen label, lesson id, topic id, session id, review log id, or any value derived from a
   question, on each layer. Note where a failure surfaces as "Could not save your progress".
B. Apply every limit you found to EVERY question in BOTH content trees, all exams (not samples):
   ids, choice ids, choice count, exactly-one-correct, duplicate ids across files, characters,
   lengths, topic/lesson references, anything the save or sync path reads. For each rule, give
   the count of failing questions per exam and list each failing id (a list file is fine).
C. The report path end to end: report sheet UI state -> ReportQueue -> local storage ->
   sendPending -> (missing) backend. What exactly happens offline and online, what the student
   is told, whether anything is ever lost, and what a backend would need (callable vs direct
   Firestore write, rules, App Check, per-day write cost).
D. Other student-visible failure paths with the same shape (an optional side effect awaited
   before the real work: analytics, telemetry, crash reporting, perf timeline, notifications,
   screen counts) anywhere in lib/.

## Output format (each finding, appended as found)
### <short title>
- Severity: blocker / major / minor
- Evidence: file:line (and content id/path for content)
- Failure: concrete input -> what the student sees
- Fix idea (one line)
