# W4c implementation evidence

## Assignment and source identity

- Policy retrieved from main after fetch: `da314d1e8bb1d68f617ef50ee0b23aea46ee605b`.
- Read current AGENTS.md, WORKFLOW.md and SUBAGENTS.md. The initial startup read used `56f642543e9c04de7dc673f8d1674c6cc222c4d6`; the user resumed before implementation, so main was fetched again.
- Code base: `cee7a9c55387674787030c722967104705d7bb3a`, branch `web/new-design-w4c-r1`, assigned worktree.
- Plans L2-W4c and L3-W4c, amendment spec, traceability W4c rows, current parallel map and W2 lead rulings read from main. Shared state-pattern notes read from the assigned worktree.
- Design boards and outline/timeline scripts are absent on the code base. Read their exact current main versions from the main checkout without editing it or merging main.
- No application-code freeze was lifted beyond this authorized workstream. No merge or push is authorized.

## Open questions and dependencies

1. Task 1, ST_TopicOpen Today tag: 12 px, weight 600, foreground `#6E6E73`, background `#EDEDF0`. WCAG sRGB contrast is `4.340286685319358:1`, below the binding 4.5:1 text rule. The explicit SearchField exception does not cover this tag. Task 1 is blocked until the lead records a darker text token, a lighter background, or a specific exception. No changed presentation has been implemented.
2. Task 5 depends on W4b Task 3's `LessonDayContext`. It is absent from this code base. No local substitute will be added.
3. Task 7 depends on W4d Task 1's `startLessonQuiz(lessonId)` and `startQuickQuiz()` entry contracts. They are absent from this code base. The existing `startQuickQuizProvider` is a different interface.

## Task 2: search

Implemented and task checks pass. Independent acceptance remains with the lead.

Behavior: the W2 search field folds Study over 300 ms using the board's house curve; Cancel clears the query and restores the map. Search includes every lesson of a matching topic in corpus order without duplicate hits. Results show uppercase counts, bold matches, snippets, grouped rows and 15 px tabular minutes. Empty query with no recents shows nothing. Recents show at most three lessons. Result routes identify search as origin.

Shared component extensions authorized by the dispatch:
- `lib/core/ui/components/search_field.dart`: optional `onEditingChanged` lets a screen switch the body when editing starts and ends. `titleInset` defaults to zero; Study uses 4 px inside its 16 px screen gutter to reproduce the 20 px title gutter. ST_Search: title fold and Cancel 300 ms, `Cubic(.3,.9,.3,1)`.
- `lib/core/ui/components/list_row.dart`: optional rich title/subtitle spans, footer, leading widget, title color, value style and vertical padding. Defaults preserve other families. ST_Search: 17/400 title, 13 px topic/snippet, 15 px minutes, 12 px vertical inset. Real keyboard activation remains on W2's InkWell. Tests live beside W2 tests.

Files: those two shared components; lesson search provider; Study page's search call site; search field bar and result widgets; search provider, field bar, results, search board and existing pinned-transition tests; W2 search extension tests; this evidence. No other screen family changed.

Verification, run serially through the Mac relay:
- Issue 9409: initial test failed to compile because ignored generated files were absent. This was setup failure, not the required failing test.
- Issue 9410: `dart run build_runner build --delete-conflicting-outputs`, exit 0, `Built with build_runner/aot in 25s; wrote 2735 outputs.` Generated files remain ignored and uncommitted.
- Issue 9411: three search test files, exit 1, `00:00 +12 -8: Some tests failed.` Topic matching, W2 search field, uppercase headings and no-match copy failed as intended before their implementation.
- Issues 9412 and 9413: prescribed focused check, exit 1. Issue 9412 output was truncated. Issue 9413 captured full output in `.dart_tool/w4c-task2-check.log`: `00:39 +843 -6: Some tests failed.` Five failures came from the replacement search wrapper lacking Material in isolated tests. One old pinned test matched a TextField opacity widget too. Both causes corrected; no unrelated failure was ignored.
- Issue 9414: narrowed regressions, exit 1, `00:01 +9 -1: Some tests failed.` The Cancel test tapped before the newly required 300 ms reveal completed. The test now waits for that reveal.
- Issue 9415: light/dark, 100%/200% board metric tests, exit 1, `00:00 +0 -4: Some tests failed.` Each correctly found 17 px minutes where ST_Search requires 15 px. Shared value-style extension corrects this.
- Issue 9416: `flutter test test/features/lesson test/app/study_route_test.dart test/core/ui --reporter expanded`, exit 0, `00:32 +855: All tests passed!` Full log: `.dart_tool/w4c-task2-check-final.log`.
- Issue 9417: six relevant board and extension tests after making the test surfaces use the actual theme background and tightening the intermediate animation value, exit 0, `00:00 +6: All tests passed!` The title opacity at 150 ms is 0.057725, tolerance 0.001. Tests cover real light/dark contrast, 200% layout and keyboard activation.
- `dart format` on the changed Dart files: exit 0. `git diff --check`: exit 0.

The full Flutter suite has not run; these are the plan's focused checks only.

## Acceptance

No tasks accepted yet. Independent review and Aedwon's Android/iPhone visual checks have not run. Full Flutter suite has not run.
