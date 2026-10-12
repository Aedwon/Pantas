# W4d quiz evidence

## Assignment and policy

- Policy: origin/main `cb4dc3cecb5788e9036db24d41c7478aacc3638d`, fetched October 12, 2026. Read AGENTS.md, WORKFLOW.md, SUBAGENTS.md, the standing W4 rulings and the quiz plan's October 12 rulings.
- Product inputs: L3-W4d-quiz.md and L2-W4d-quiz.md on that main revision, all W4d traceability rows, the approved October 5 amendment, shared state-pattern contract, W2 October 10 contrast rulings, and design boards in the main checkout. Main checkout is read-only.
- Starting source: `958ed879`, branch `web/new-design-w4d-r1`, clean linked worktree. Integration already reached this branch, including W4e's MockCard. No previous W4d patch or commit was present.
- Authorization: October 5 restart applies to this design work. Other engineering pauses and main application-code freeze remain. Do not push or merge.
- Task order: 1, report contract/form from 7, then 2 through 9.
- Pre-flight shared interfaces: Task 1's lesson scope feeds Task 4; the report form feeds Tasks 4 and 6 and W4a; Task 4's checked outcomes feed Tasks 5 and 6. W4e's card is injected through the route layer, never imported by quiz presentation.
- Review and phone visual acceptance remain with the lead and Aedwon.

## Task 1: lesson and quick starts

Files:
- `lib/features/quiz/application/quiz_starts.dart`
- `lib/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart`
- `test/features/quiz/domain/use_cases/start_inline_lesson_quiz_test.dart`

Public entry contracts: `startLessonQuiz(BuildContext context, LessonId lessonId, {required ExamId examId})` and `startQuickQuiz(BuildContext context, {required ExamId examId})`, both `Future<void>`. Each pushes the declared route, preserving the reader or Study return route. Inline selection filters on the W0 question lesson id before the existing five-question picker. A smaller lesson pool stays smaller; sibling questions never fill it.

Checks:
- Initial test load failed because ignored Freezed outputs were absent. Ran `dart run build_runner build --delete-conflicting-outputs`: exit 0, wrote 2816 outputs. No generated files staged. Existing generator SDK-range and obsolete drift-option warnings reported; no dependency or configuration changes.
- RED: `flutter test test/features/quiz/domain/use_cases/start_inline_lesson_quiz_test.dart --reporter expanded`: exit 1, +3 -2. Three-question pool wrongly returned five; seven-question pool included a sibling.
- GREEN task checks: `flutter test test/features/quiz test/features/review_prompt test/app --reporter expanded`: exit 0, +459, All tests passed!
- Format: three affected Dart files, 0 changed.

## Contrast changes

None yet.

## Waiting on a contract

None yet.

## Open questions and remaining work

Tasks 2 through 9 remain. No backend report function exists; reports must remain queued until a sender is approved. No deployment is authorized.
- `flutter analyze lib test tool`: exit 1, `1 issue found. (ran in 8.3s)`. Only the existing bookmarks `onReorder` deprecation at line 238, explicitly assigned to W4c Task 8 and recorded as accepted in W2 evidence. Zero quiz findings.
