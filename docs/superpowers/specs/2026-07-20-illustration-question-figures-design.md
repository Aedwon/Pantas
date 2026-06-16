# Connect Illustration Studio to Question Figures — Design

Date: 2026-07-20
Status: Approved (conversation with Aedwon)

## Purpose

`content/questions/**/*.yaml` contains 144 figure-pending questions (`figure: <slug>`)
across `reasoning/mechanical-technical-reasoning` and `reasoning/spatial-abstract-reasoning`.
There is currently no way to attach an actual image to those slugs — Illustration
Studio only knows about `<!-- ILLUSTRATION: ... -->` markers in lesson markdown.
This fulfills the deferral called out in the static-question-pipeline design:
*"pointing [Illustration Studio] at this second worklist later needs no studio
changes now."*

Verified before designing: the current (manually-appended)
`docs/content/question-figures/worklist.tsv` has exactly 144 rows, one per
`figure:` slug in the question YAML, fully in sync — safe to regenerate
mechanically instead of hand-maintaining.

## Approach

Merge question figures into the existing Illustration Studio rather than
building a parallel tool. The studio already owns every piece of machinery
this needs: Downloads watching, image normalization (`sips` → PNG, resize to
1600px), copyright-chunk stamping, and the connect/replace flow. The only new
work is a second item source feeding the same `items` list.

## Worklist generation

New module `tools/illustration_studio/question_figures.mjs`:

- Walks `content/questions/**/*.yaml`, parsed with the `yaml` npm package
  (new dependency for this tool — `tools/illustration_studio/package.json`
  currently has none; installed on first run the same way `question_studio`
  does it).
- For each question carrying `figure: <slug>`, computes:
  `target: content/illustrations/questions/<subject>/<topic>/<subtopic>/<slug>.png`
- Rewrites `docs/content/question-figures/worklist.tsv` as a committed audit
  artifact (columns: `subject topic subtopic slug question_id target_file status`),
  mirroring `list_illustrations.py`'s output for lessons. `status` is derived
  from whether `target_file` exists — same convention as the lesson worklist.
- The TSV is a side artifact for humans/git-diff, **not** the server's runtime
  source — the server reads stem/choices/explanation straight from the
  question YAML, keeping one source of truth for content.

Image storage: `content/illustrations/questions/<subject>/<topic>/<subtopic>/<slug>.png`
— nested under the existing `content/illustrations/` root (so the server's
existing containment check `target.startsWith(illusRoot)` needs no change),
parallel to the lesson layout `content/illustrations/<subject>/<topic>/<lesson>/...`.

Since each `figure:` slug is a stable, author-assigned identifier (unlike
lesson illustrations, which slug from marker text and can drift), "done" is
an exact filename match — no glob-by-prefix needed.

## Server changes (`tools/illustration_studio/server.mjs`)

- On boot and on `/api/rescan`: run the existing Python lesson scan *and* the
  new in-process question scan; merge both into one `items` array, each
  tagged `kind: 'lesson' | 'question'`.
- Question items get `description` set to the question's `stem` — every
  figure-pending stem already reads "Figure shows…" (confirmed across
  subtopics), so it doubles as the "what to draw" brief with no extraction
  logic. This means the existing prompt-copy button and "what to draw" card
  work unmodified.
- `itemDone`, `connect`, `sips` normalization, copyright stamping: unchanged
  — they only touch `item.target`, which is already kind-agnostic.
- `markerContext` branches on `kind`: lessons keep the current
  file-lines-around-marker view; questions return `{ stem, choices,
  explanation }` read directly from the parsed question object (no line
  numbers involved).

## Frontend changes (`tools/illustration_studio/public/index.html`)

- Sidebar grouping gains a top-level split — **Lessons** vs **Questions** —
  above the existing subject·topic grouping. Question list-item labels read
  `<subtopic> · <slug>`.
- Breadcrumbs and the "N of M" counter become kind-aware (grouped by
  subject/topic/lesson for lessons, subject/topic/subtopic for questions).
- "Where it sits" card renders differently per kind: lessons show the
  existing markdown-context view; questions show the stem, its four choices
  (correct one marked), and the explanation.
- Everything else — Downloads polling, connect button, connected-file
  preview, keyboard nav — is unchanged and works for both kinds already.

## Docs

`docs/content/question-authoring-runbook.md` step 7 changes from "manually
append a row to the worklist" to "run Illustration Studio — it scans
`figure:` slugs automatically."

## Out of scope

- No change to Question Studio's UI to reflect "image connected" status; its
  `figurePending` badge keeps counting `figure:` presence only, not file
  existence. Natural follow-on, not required to unblock connecting images.
- No change to the quiz renderer or import pipeline — figure display in the
  app is still gated on the renderer upgrade tracked separately in the
  static-question-pipeline spec.

## Testing

- Run the new scan standalone (or via server boot) and confirm
  `worklist.tsv` regenerates with 144 rows, matching current content 1:1.
- Boot the studio; confirm the sidebar shows both Lesson and Question groups,
  a question item renders stem/choices/explanation, and connecting a test
  image lands at `content/illustrations/questions/.../<slug>.png` and flips
  its status to done on rescan.
