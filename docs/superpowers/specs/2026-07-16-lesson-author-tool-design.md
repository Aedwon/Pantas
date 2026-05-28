# Lesson Author Tool — Design

Date: 2026-07-16
Status: Approved (conversation with Aedwon)

## Purpose

A local web tool for writing the ~141 lessons from the Pantas Corpus Outline
without touching technical details. Output is one Markdown file per lesson
with generated frontmatter, ready for a later Markdown → Portable Text →
Sanity NDJSON import step.

## Content mapping

| Corpus outline level | App concept | Example |
|---|---|---|
| Section header | `subject` | Mathematics |
| ● bullet | `topic` | Algebra |
| ○ bullet | one `lesson` | Quadratic Equations |
| ■ bullet | H2 section inside the lesson body | Completing the Square |

Language: English-only for v1 (matches `language == "en"` content setup).
The lesson `subtopic` ref stays unused.

## Components

`tools/lesson_author/`

- `outline.json` — full transcription of the corpus outline PDF with
  precomputed stable slugs. Document IDs derive from slugs, never from
  editable titles: `subject-<slug>`, `topic-<slug>`,
  `lesson-<topicSlug>-<lessonSlug>`.
- `server.mjs` — dependency-free Node HTTP server on port 4321.
  - Serves the single-page UI and vendored libs (marked, KaTeX from
    node_modules).
  - `GET /api/lessons` — scans `content/lessons/` and returns per-lesson
    status (exists + metadata) for the ✓ indicators and progress counter.
  - `GET /api/lesson?id=` — returns parsed frontmatter + body for editing.
  - `POST /api/lesson` — validates payload, writes
    `content/lessons/<subject>/<topic>/<lesson-slug>.md`.
  - Auto-opens the browser on start (`open` on macOS). Refuses path
    traversal; only writes inside `content/lessons/`.
- `public/index.html` — the whole UI, inline CSS/JS.

## UI

- Cascading selectors: subject → topic → lesson, plus a lesson list with
  done (✓) indicators and an overall progress counter.
- Metadata fields: title (prefilled from outline), summary, estimated
  minutes. IDs and refs are invisible to the author.
- Markdown editor with side-by-side live preview:
  - marked for Markdown, KaTeX for `$inline$` and `$$block$$` math.
  - Preview visually flags formatting the Flutter renderer does not yet
    support (lists, bold/italic, links, code, tables) so nothing silently
    degrades in-app.
- Section chips from the outline's ■ items insert `## Heading` with one
  click.
- Prev/Next cycle through the flattened lesson list.
- Unsaved work auto-drafts to localStorage per lesson; cleared on save.

## Saved file format

```markdown
---
_id: lesson-algebra-quadratic-equations
title: Quadratic Equations
summary: ...
subject: subject-mathematics
topic: topic-algebra
estimatedMinutes: 8
isActive: true
---

## Standard Form
...
```

## Out of scope (later steps)

- `tools/import_lessons`: Markdown → Portable Text NDJSON converter that
  also emits `subject`/`topic` documents from the same outline.json, for
  `sanity dataset import`.
- Renderer upgrades (lists, bold/italic) in the Flutter app.
- Filipino-language variants.
