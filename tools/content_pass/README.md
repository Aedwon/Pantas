# Content Pass

A local Mac app for reviewing every CSE Pro and CSE Subpro content item through the app's real
screen code, with tags and comments beside it. Spec:
`docs/superpowers/specs/2026-11-02-content-pass.md`.

## Open it

Search Spotlight for Content Pass. To create or refresh the app:

```bash
tools/content_pass/make_app.sh
```

It installs `~/Applications/Content Pass.app`. The app carries its own web build and server, so it
keeps working if this checkout goes away. Rebuild to pick up changes to the app's screens. Rebuilding
never touches the notes.

## Read the notes (for agents)

`~/Library/Application Support/Content Pass/notes.json`. It is not committed: it is one person's
review state on one machine.

`records` has one entry per item touched: `id`, `kind`, `file`, `exams`, `state`, `choice`, `size`,
`plan`, `theme`, `tags`, `comment`, `status` (`not_reviewed`, `looks_good`, `tagged`), `time`, `hash`,
`commit`. To act on the problems, read records with status `tagged` and fix `file` at `id`. `state`,
`choice`, `size` (`desktop`, `tablet` or `phone`; old notes say `wide`, which means desktop), `plan`
(`free` or `pro`) and `theme` say what was on screen. `previous` holds the earlier note when the
content changed after review. `removed: true` means the item is gone from the content.

## Choose the content

`~/Library/Application Support/Content Pass/source.json` is one of:

```json
{"repo": "/Users/aedwon/Documents/Projects/Pantas", "ref": "origin/content/cse-rewrite-r1"}
{"checkout": "/path/to/a/checkout"}
```

Repo mode fetches the branch and extracts it to a snapshot, so it never writes to a worktree.
Checkout mode reads the files as they are, including uncommitted edits. Restart the app, or use Check
for updates, after a change. Items reviewed earlier whose content changed go back to Not reviewed.

## What is real and what is not

Real: `LessonPage`, `QuizPage`, `MockSetupPage`, `MockSessionPage`, `ContentRenderer`, the themes, the
export and the seed writer. Test seams only: the two databases, the auth state, and a quiz controller
holding a fixed state. The Free and Pro switch (default Pro) sets whether a question shows the Pro wrong-choice notes, so Wrong
needs Pro to show each note. It applies to questions only.

Not real:

- Phone runs at phone width in the web engine, so a device-only rendering bug will not show.
- The quiz session holds the item and one other question, so it reads "1 of 2".
- Taps that would leave the screen go nowhere.
- The mock Exam question order is file order from the first section, not the server's draw.

## Old tools

Lesson Author and Illustration Studio stay for authoring. Question Studio can retire once one full
Content Pass over CSE is finished, because its review job is the only part still in use. Its YAML
editing has no replacement here, so check nobody still edits through it first.

## Verify the real window

The window app takes `CONTENT_PASS_DRIVE=<steps.json>`, a list of `{"js"}`, `{"wait"}`, `{"snap"}` and
`{"quit"}` steps. Use it instead of UI automation.
