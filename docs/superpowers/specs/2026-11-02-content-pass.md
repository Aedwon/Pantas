# Content Pass

Aedwon approved the balanced build and the layout on 2 November 2026, in the session that
started this work. This spec records that approval and the lead's technical rulings.

## Plain-language section

A local Mac app shows every CSE Pro and CSE Subpro content item through the app's real screen
code, with tags and comments beside it. If real code cannot show an item, the item says
"Can't show this here" and why.

- Top bar: Content Pass, exam filter (CSE Pro, CSE Subpro), status filter (Not reviewed, Tagged,
  All), Phone, Wide, Light, Dark.
- Left: queue grouped as Lessons, Questions, Mock exams, Figures.
- Center: the real screen. Questions switch between Question, Correct and Wrong.
- Right: tags (Wrong answer, Wording, Figure, Layout, Other), comment, Looks good, Next.
  Keys: 1 to 5 tag, C comment, Enter next.
- Notes save as he goes to a plain JSON file an agent can read. Progress survives restarts.
- If the content changes, reviewed items that changed go back to Not reviewed.
- No sign-in, test accounts or emulators.
- Nothing from this tool reaches a normal build.

Limit: Phone uses the web engine at phone width, so it runs the real phone screens but not on
a phone. Fonts and layout come from the same code. A device-only rendering bug will not show.

## Agent section: lead rulings

Source layout: everything lives in `tools/content_pass/`. Nothing in `lib/` changes or imports it.

- `tools/content_pass/app/`: the Flutter web entry point (`main.dart`) and the reviewer chrome.
- `tools/content_pass/server/`: the local Dart server. It compiles to a standalone executable.
- `tools/content_pass/mac/`: the Swift window app and bundle template.
- `tools/content_pass/make_app.sh`: builds everything and installs `~/Applications/Content Pass.app`.

Data path, chosen so the content goes through the real pipeline:

1. The server gets the content tree. A source is either a Git repo and ref, extracted with
   `git archive` into a snapshot folder, or a working checkout read as is. Default: the Pantas
   repo at `origin/content/cse-rewrite-r1`. It never writes to another worktree.
2. The server runs this branch's `tools/build_content_export` with the content tree as its root,
   then `tools/build_content_seed/seed_writer.dart`. This is the same export and seed writer the
   bundled content uses, so illustrations resolve and questions drop out the same way.
3. The page downloads the plain seed database and opens it in memory with `sqlite3.wasm` as a
   real `ContentDatabase`. The study database is a real in-memory `AppDatabase`.
4. Real screens mount under a `ProviderScope` with test seams only: signed-out or anonymous auth,
   selected exam, Pro on, and a `QuizController` subclass that holds a fixed `QuizRunning` state.

Screens per item:

- Lesson: `LessonPage`.
- Question: `QuizPage` with the fixed controller. Question has no outcome. Correct and Wrong hold
  a real `AnswerOutcome`. Wrong has a choice switch, because each wrong choice has its own note.
- Mock: `MockSetupPage` and `MockSessionPage` with the blueprint and a sampled question.
- Figure: an illustration file in the real `ContentRenderer` image block at reader width. It
  also appears in place in its lesson.

A question that the export leaves out (a `figure` with no drawn `figureSpec`) is "Can't show this
here". So is an illustration file no lesson slot uses.

Notes file: `~/Library/Application Support/Content Pass/notes.json`. Not committed, because it is
per-machine review state. It is outside the build output and survives rebuilds. One record per
item: id, kind, file, screen state, size, theme, tags, comment, status, time, content hash, commit.

## Done means

See the task brief: analyze clean, relevant tests pass, layering and attribution checks pass, the
real .app driven through one of each item at phone, wide, light and dark, notes and progress
surviving a restart. Decisions are appended to `docs/superpowers/decisions/2026-11-02-content-pass-log.md`.
