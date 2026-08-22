# Lesson Illustrations Completion and Review Design

**Date:** 22 August 2026
**Status:** Approved in conversation, awaiting written review
**Supplements:** `2026-08-15-lesson-illustrations-reduction-design.md`
**Decision log:** `docs/superpowers/decisions/2026-08-22-lesson-illustration-completion-log.md`

---

## 1. Purpose

Complete the 52 lesson illustration briefs that have no exact approved open
source. Draw them through the existing Flutter figure registry. Give Aedwon a
local review workflow inside Lesson Author before any asset upload or final
acceptance.

The original brief text remains frozen. This supplement changes the production
route, not the requested lesson content.

## 2. Revised strategy totals

The four verified Commons assets remain open assets:

- `science/chemistry/mixtures-and-separation#1`
- `science/chemistry/nuclear-chemistry#1`
- `science/earth-science-astronomy/layers-of-the-earth#1`
- `science/earth-science-astronomy/layers-of-the-earth#2`

The other 52 rows formerly assigned to `open` become `code`. The exact set is
all 56 open keys in Appendix A of the original plan except the four keys above.

| Strategy | Revised count |
|---|---:|
| Code figures | 241 |
| Open educational assets | 4 |
| Native Markdown or LaTeX | 23 |
| Cuts | 8 |
| Founder assets | 3 |
| Total | 279 |

No sixth strategy is added. The strategy manifest identifies the 52 new code
rows with the batches `original-code-a` and `original-code-b` so the review
tool can select them without a second inventory.

## 3. Original figure architecture

The 52 diagrams use the existing `FigureRegistry` seam. Lesson Markdown
replaces each owned `ILLUSTRATION` marker with a one-line `FIGURE` marker.
Every new marker contains:

```json
{
  "kind": "biology-diagram",
  "type": "cell-protein-flow",
  "illustrationKey": "science/biology/cell-biology#1"
}
```

The real marker also carries every label, value, relationship, and state needed
to reproduce its frozen brief. It contains no unstated number or claim.

Six deep painter modules divide the domain work:

- `reading-diagram`: the plot line and rhetorical appeals figures.
- `biology-diagram`: the eight biology figures.
- `chemistry-diagram`: the ten chemistry figures.
- `earth-science-diagram`: the eighteen Earth Science figures.
- `physics-mechanics-diagram`: dynamics, fluids, orbital motion, kinematics,
  momentum, and mechanical energy.
- `physics-energy-diagram`: circuits, electric fields, optics, heat transfer,
  waves, and the Doppler effect.

Each module exposes one `fromSpec(Map<String, Object?>)` interface. It validates
its private `type` variants and returns null for malformed input. The registry
remains the only dispatcher. Callers do not learn the variant implementations.

All figures follow Ink and Rule. They use Source Sans 3, theme ink, paper,
faint rule, and board green only where meaning requires it. They have no
shadows, large radii, decorative color, or hardcoded black and white.

## 4. Accuracy and rights

The figures are original Pantas drawings expressed in code. Workers may study
authoritative facts. They may not trace, copy, or reconstruct the composition
of a third-party illustration.

`docs/content/illustrations/original-code-a.yaml` and
`docs/content/illustrations/original-code-b.yaml` record the 52 keys and one or
more authoritative factual references. A reference entry contains a title,
publisher, and HTTPS URL. These references support factual verification. They
are not image credits. The split matches the two independent implementation
batches and prevents shared-file edits.

The four Commons files keep their creator, source page, direct URL, license,
credit line, modification notice when required, and SHA-256 digest. The review
screen shows those fields exactly. The three founder files use Pantas
all-rights-reserved metadata after Aedwon supplies them.

## 5. Exact visual previews

Lesson Author shows previews rendered from the same Flutter widgets used by
the app. A Flutter preview harness scans the 52 `FIGURE` markers by
`illustrationKey`, renders each figure at a 390 logical-pixel lesson width, and
writes light and dark PNG previews under
`build/lesson_author/illustration_previews/`.

The preview harness produces a manifest containing the key, both preview
paths, and a combined digest. The combined digest is the SHA-256 of the light
PNG's SHA-256, a colon, and the dark PNG's SHA-256. A changed spec, painter,
theme result, or rendered label changes the digest.

Open and founder image rows use the SHA-256 of the local PNG as their review
digest. Their light and dark lesson previews display the same image on the
appropriate lesson background.

## 6. Lesson Author review workflow

Lesson Author gains an **Illustration review** mode. It keeps the existing
subject, topic, lesson, and previous or next navigation.

The mode provides:

- a queue containing the 52 new code figures, four Commons assets, and three
  founder assets;
- filters for **Pending**, **Needs changes**, **Approved**, and **Missing**;
- a progress count over all 59 review items;
- the actual lesson preview with the illustration inserted at its marker;
- light and dark previews for code figures;
- the exact frozen brief;
- factual references for original figures;
- source, creator, license, credit, and modification details for Commons
  assets;
- **Approve**, **Needs changes**, and notes controls;
- a **Refresh previews** action that rebuilds the local Flutter snapshots.

Selecting a queue item opens its lesson and scrolls to the illustration. The
authoring editor remains available in author mode. Review actions never edit a
lesson.

## 7. Review state and stale approvals

Review state lives in `docs/content/illustrations/review.json`:

```json
{
  "version": 1,
  "items": {
    "science/biology/cell-biology#1": {
      "status": "approved",
      "notes": "",
      "reviewedDigest": "<sha256>",
      "reviewedAt": "2026-08-22T00:00:00.000Z"
    }
  }
}
```

Valid statuses are `pending`, `approved`, and `changes-requested`. The UI says
**Needs changes** for `changes-requested`.

The server accepts a review write only when the submitted digest matches the
current digest. It writes the JSON file atomically. If the current digest no
longer matches `reviewedDigest`, the item displays as pending and stale. Notes
remain visible so the implementor can see the requested correction.

Missing files have no digest and cannot be approved. This applies to the three
founder files until Aedwon supplies them.

## 8. Local interfaces

The Lesson Author server adds three local interfaces:

- `GET /api/illustrations` returns the 59 review items and their current state.
- `POST /api/illustration-review` writes one digest-bound status and note.
- `POST /api/illustration-previews/rebuild` runs one preview build at a time
  and returns its final result.

`GET /api/illustration-preview?key=<key>&theme=light|dark` serves only a file
resolved from the known review catalog. It never accepts a filesystem path.

All interfaces remain bound to the local Lesson Author process. They perform
no network request, Sanity write, push, or upload.

Lesson Author adds the same `yaml` npm dependency already used by Illustration
Studio. One parser reads the Commons and factual-reference manifests. No
Flutter dependency changes.

## 9. Gates

The illustration checker gains three phases:

- `inventory`: exact totals `241/4/23/8/3` and 279 unique keys.
- `review-ready`: 241 valid `FIGURE` markers, seven remaining image markers,
  four verified Commons PNGs, 52 current light and dark previews, and 59 review
  catalog entries. Missing founder files are allowed and reported.
- `complete`: all seven PNGs exist and all 59 items are approved against their
  current digest.

Gemini 3.1 Pro High verifies every Flash batch without editing. Codex inspects
all results, integrates the registry and review interfaces, and runs final
verification. Aedwon performs visual acceptance in Lesson Author. No Sanity
upload occurs without a later explicit authorization.
