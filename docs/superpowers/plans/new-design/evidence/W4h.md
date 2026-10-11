# W4h app-wide states: worker evidence

Date: October 11, 2026. Assignment: L3 Tasks 1, 2, 3 and 5. Task 4 is deferred to the lead's later dispatch.

## Policy, task context and source identity

- Policy read after `git fetch origin`: `origin/main` **7a450ca2334a2e7ff9994ef4340e79ab18123ca9**. Read AGENTS.md, WORKFLOW.md and SUBAGENTS.md in full. Read the linked startup, routing and Actions resource decisions.
- Task plans and amendment spec read from the same main revision: L3-W4h-app-wide-states.md, L2-W4h-app-wide-states.md, 2026-10-05-new-design-amendment-design.md. Read W4h traceability rows, the parallel map, stage 0 decisions, the restart decisions and W2's October 10 rulings.
- Workspace: `/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w4h-r1`, branch `web/new-design-w4h-r1`, initial clean HEAD `b935cbd20e4ad2f178cc2aa085d714136c84764d`.
- Origin points to Aedwon/Pantas. Remote integration branch matched that initial SHA. The assigned worker branch had no remote counterpart. No merge, push, reset or rebase was performed.
- Authorization: October 5 restart applies to the new design. Other paused engineering and the main application-code freeze remain unchanged.
- The design files are absent from this integration-derived worktree. Read the main checkout's files without changing it. Retrieved the three relevant board blobs from origin/main as well. SY_Update matches its original handoff revision 58667f2a byte for byte.
- Board SHA-256: SY_Error `a4e8d8aee9f444d6bfc5f10f71e8a926b3df3fd3f36dfbe9b0d1eed90fc3ce91`; ST_NoExam `9da925678d93fb722374834ef3dab8c097a6a1d0549c01ffbf7898dc26c66e07`; SY_Update `de5a7c3faf6d5427a391c35cd051ad8909db655101598b67e5fa2edf3edf9992`.
- Ran outline.py first for every board. Read the board itself for layout properties and complete SVG paths omitted by the outline. Ran timeline.py on SY_Error, SY_Update and ST_NoExam: each printed `No CSS animations on this board.` No entry animation was invented.
- Flutter 3.44.6, framework ee80f08bbf; Dart 3.12.2. Local Mac execution, no hosted Actions or computer control.

## Task 1: blocked, not implemented or committed

Two lead questions are pending. No family should treat this branch as delivering the Task 1 dependency.

1. S0-34 and the L3 plan specify one calm save-failure line with Try Again, but supply no exact wording. The relevant boards have no save-failure copy. Proposed wording for the lead: **“Could not save your progress.”** with **“Try Again”**. Do not use this proposal until approved.
2. The W2 StateView contract exposes message, optional error, icon and retry, but no supporting paragraph, alternate action label or primary action. ST_NoExam requires “Choose your exam”, “Pick the exam you are reviewing for.” and “Choose Exam”. The board uses a 40 px faint icon, 6 px gaps, a 20/700 title (1.35 line height, -.2 spacing), a 15/400 paragraph (1.45), a 48 px primary action (radius 14, horizontal inset 26), and bottom padding 150. The assessment fallback requires its existing supporting paragraph and “Back to Quiz”. Ask the lead whether W4h may extend the shared component or whether W2 supplies the missing contract. L2 §7 requires escalation when a needed shared contract is missing. No local copy was built.

The requested first Task 1 commit cannot be delivered while these questions remain open. No Task 1 helper tests or guide are claimed.

## Task 2: blocked, not implemented or committed

SY_Error's full-screen mark and positioning differ from the accepted W2 implementation:

- Board: 72 px circle, 36 px error glyph, light glyph color #6E6E73 on #EDEDF0, 14 px gaps. Existing StateView.fullScreen: 38 px progressError glyph using chevron (#C7C7CC in light).
- Board: full available content height with top padding 8 and bottom padding 120. The button overlays the bottom with 16 px side gutters, 14 px top padding and 30 px bottom padding. Existing StateView places its button in bottomNavigationBar, removing that area before centering the message; it lacks the 120 px content padding.

These are shared-component changes outside W4h's file table and ownership. The lead must assign or authorize them. No corrective edits were made to W2. The contrast exemption for faint marks does not change the board's actual values.

The release ErrorWidget builder, bootstrap recovery and retry remain unchanged. AppErrorView remains in use. Startup Firebase currently returns unavailable on initialization failure instead of throwing; Task 2 must account for that swallowed failure, not merely add a zone callback.

## Task 3: implemented and automatically verified; review and visual acceptance pending

Files:

- `lib/features/shell/presentation/update_required_page.dart`
- `test/features/shell/update_required_test.dart`
- This evidence file, as required by Task 5.

The screen uses W2 PantasButton and W1 colors/type. The Pantas logo reproduces the exact six SVG elements and 307 309 640 640 viewBox from SY_Update with a CustomPainter. No new package, asset or color literal was added. The screen preserves the existing non-dismissible PopScope, gate decision and external Google Play listing. The scrollable center accommodates 200% text. Its message is a live region; the logo has an image label. The painter retains no controllers or disposable resources and repaints when theme colors change.

Automated tests pin 96 px logo size, 14 px logo/title gap, centered 24/700 title, 1.25 line height, -.288 letter spacing, 358 px action width at a 390 px viewport, 52 px height, radius 14, bottom edge 814 at 844 px height, live-region presence, system-back blocking with a real previous route, keyboard activation, exact external listing, real text/button backgrounds in light and dark, actual rendered logo ink/tassel pixel colors and contrast at 3:1, and 200% text without overflow. Existing gate tests retain above-minimum, at-minimum, deep-link, and no-published-minimum coverage.

### Test-first and setup evidence

First command: `flutter test test/features/shell`, exit 1. The amended update tests failed because PantasButton was absent and the title was not centered. The run also discovered missing ignored app_database.g.dart, which prevented four unrelated shell test files from compiling. This was a generation setup gap, not a test regression.

Ran `dart run build_runner build --delete-conflicting-outputs`, exit 0:

```text
Built with build_runner/aot in 24s; wrote 2725 outputs.
```

No generated file was staged. The prepared seed and localization files were preserved. No protected package was regenerated or key value accessed.

The first implementation run failed only because the new tests disposed their SemanticsHandles in teardown, after Flutter's end-of-test check. Disposed them before that check and reran. This was a test-harness correction.

Task check: `flutter test test/features/shell`, exit 0:

```text
00:01 +32: All tests passed!
```

After the full suite, self-inspection found two weak assertions: system back had no previous route to return to, and logo contrast read the theme rather than its painted colors. Strengthened those test assertions without changing any application source. The test now pushes the screen over a real previous route and samples the real CustomPainter output in memory. It disposes the Picture and Image. No app/emulator screenshot was captured or reviewed.

Renewed focused command: `flutter test test/features/shell`, exit 0:

```text
00:01 +32: All tests passed!
```

The full suite ran once on the unchanged application source. Its test blob was `74fe7e74e593a36acd158d07bd50e752b0727036`, code/test patch SHA-256 `89518b37a6297e0be03d445e2258afad13fd6637973c4ddca669d45603ddfb34`. The focused renewal verifies the stronger final test blob. No full-suite repetition is claimed.

## Task 4: deferred

Not run. The lead dispatches the cross-family raw-error check after the other families finish. No raw-error sweep or family inventory is claimed here.

## Task 5: incomplete

AppErrorView and its tests cannot be deleted while Task 2 still uses it. Required independent review and Aedwon's visual acceptance of SY_Error/SY_Update are pending. No app screenshot, device test or autonomous visual review was performed. The lead owns review, integration and publication.

## Verification identity and results

Final code/test dirty patch against b935cbd2, SHA-256: `8da5a851278c6ae3db288190e2c06b08d6d57ea8aa088a38a571c47dc4eda668`.

Git blob identities: update screen `b51bfce61da44df3a04a9a6fcf9dae32f84dc6cf`; update test `d813ea8c79fe6cab24a88c2b0fa33e16623ee6bb`. The task commit preserves these exact source blobs. All checks ran one at a time; the full Flutter suite ran once.

`flutter analyze`, exit 1, actual tail:

```text
Analyzing Pantas-wt-new-design-w4h-r1...

   info • 'onReorder' is deprecated and shouldn't be used. Use the onReorderItem callback instead. The onReorderItem callback adjusts the newIndex parameter for a removed item at the oldIndex. This feature was deprecated after v3.41.0-0.0.pre. Try replacing the use of the deprecated member with the replacement • lib/features/lesson/presentation/widgets/bookmarks_sheet.dart:238:21 • deprecated_member_use

1 issue found. (ran in 1.8s)
```

This exact exception remains assigned to W4c and is accepted for this candidate in b935cbd2's W2 evidence. There are no new analyzer findings. The earlier 24-info run was corrected only in the two task files.

`flutter test`, exit 0, actual final line:

```text
05:33 +3715: All tests passed!
```

`dart format --output=none --set-exit-if-changed lib test`, exit 0:

```text
Formatted 1392 files (0 changed) in 1.33 seconds.
```

`dart run tool/check_layering.dart`, exit 0:

```text
Running build hooks...Running build hooks...check_layering: OK
```

`dart run tool/check_no_ai_attribution.dart`, exit 0:

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

No application source changed after the full suite. The focused shell run, renewed analysis and renewed format check cover the strengthened tests. Layering evidence still applies to the identical lib source. The attribution check is renewed on the staged task files and after the task commit.

## Commit order and handoff

The assignment asks for Task 1 first. Task 1 remains blocked and has no implementation commit. Under the explicit stop rule to record unanswered choices and commit completed independent tasks, only Task 3 is saved in this run. This commit is not the Task 1 landing that other families require. No family-state work was started, and no incomplete helper API was committed.

The Task 3 commit includes exactly its two named application/test files and this required evidence file. No application file outside the plan was changed. Review this commit before integrating or pushing. Resume Tasks 1 and 2 only after the two lead questions above are resolved. Then finish Task 5 retirement and review. Task 4 remains separately deferred.

## Preserved inputs and remaining status

Prepared seed SHA-256 values, unchanged from W2 evidence:

```text
0ef89a64f2d2f63854b3d22048a7d992d5c04fb03df4fec2e7f4e898e6d083dc  assets/seed/content.db
51bc0a766558879e540475ab972f03df7e3077241bab8f688c1b50ece5874f23  assets/seed/content.manifest.json
e0853df259529031344f14d5a5fe6628e1b92c367a96c584894058fe13199f31  assets/seed/content.manifest.sig
```

No functions files changed. Reuse the lead's green Node 22/Java 21 backend evidence on b935cbd2 (52 plain and 58 emulator tests) rather than repeat unchanged backend checks. No independent review or visual acceptance is implied by automated passes.

This is the current worker checkpoint. The lead must update the main-owned STATUS/SSOT to reflect Task 3 and the Task 1/2 questions. The worker did not edit the main checkout or its status file. Workstream acceptance remains pending, and the other families' Task 1 dependency remains unsatisfied.
