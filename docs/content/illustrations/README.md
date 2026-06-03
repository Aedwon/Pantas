# Illustration production guide

Every `<!-- ILLUSTRATION: ... -->` marker in `content/lessons/` needs one
image. The full inventory lives in `worklist.tsv` (278 illustrations across
111 lessons). Regenerate it any time with:

```bash
python3 tools/audit/list_illustrations.py
```

The `status` column is derived from the filesystem: a row is `done` when its
image file exists at the target path, `todo` otherwise. No manual editing.

## The easy way: Illustration Studio

Double-click `tools/illustration_studio/Start Illustration Studio.command`.
It cycles through every needed illustration, shows the lesson context around
the marker, and gives you a one-click generation prompt (style boilerplate
lives in `tools/illustration_studio/prompt_template.md` — edit it to tune
your house style). It watches `~/Downloads`: when your exported image lands
there, it previews it, and **Connect** converts it to PNG, shrinks it to
1600 px if larger, renames it to the target filename, moves it into
`content/illustrations/`, and deletes the original from Downloads. The specs
and file placement below happen automatically when you use the studio.

## Where files go

Save each finished image at the exact `target_file` path from the worklist:

```
content/illustrations/<subject>/<topic>/<lesson-slug>/NN-<short-slug>.png
```

`NN` is the placeholder's order of appearance in the lesson file (1-based).
That order is the join key: the future `import_lessons` script will walk each
lesson, match marker N to file `NN-*.png` in that lesson's folder, upload the
asset to Sanity programmatically, and replace the marker with a portable-text
image block.

**Do not upload images to Sanity Studio by hand.** The repo folder is the
source of truth — versioned, reviewable, and re-importable. Sanity's asset
store is a build artifact of the import.

**Invariant:** if you add, remove, or reorder markers in a lesson, rerun
`list_illustrations.py` and rename the affected files to match the new `NN`
sequence before importing.

## File specs

- **Format:** PNG. (The app renders via CachedNetworkImage, which cannot
  display SVG; JPG artifacts blur line art and label text.)
- **Canvas:** 1600 px wide. Default 1600×1000 (16:10 landscape). Taller is
  fine when the subject is vertical (Earth layers, food chain) — keep the
  width at 1600 and don't exceed roughly 1600×2000. The renderer shows
  images at full content width and preserves aspect ratio, so width drives
  sharpness: 1600 px covers a ~400 dp column at 3–4× device pixel ratio.
- **File size:** aim under 300 KB. Flat-color PNGs compress well; run
  exports through a PNG optimizer if Canva/PowerPoint output is heavy.
- **Background: solid, never transparent.** The app has a dark theme;
  transparent PNGs with dark linework disappear on it. Bake in white or a
  very light neutral (e.g. #FFFFFF / #FAFAF7).
- **Safe margin:** keep all content ≥ 5% in from every edge. The app clips
  images to rounded corners, and edge-hugging labels look cramped.
- **No baked-in rounded corners, borders, or drop shadows** — the app
  applies its own corner radius.

## Style rules

- **Label text ≥ 40 px** on the 1600-wide canvas (reads as ~12 pt on a
  phone). One sans-serif family across all illustrations.
- Flat colors, bold strokes, high contrast — these render at ~400 px wide
  on budget phones, so no thin hairlines, no subtle gradients, no clutter.
- Pick one small palette and reuse it everywhere so illustrations read as
  one system across lessons.
- Match the marker description exactly: every label, count, and value named
  in the `<!-- ILLUSTRATION: ... -->` comment must appear in the image,
  because the surrounding lesson text references them. (Load-bearing
  figures in Reasoning especially — there the image IS the question.)
- English text only in labels, Grade-5-simple wording, consistent with the
  lesson voice.
