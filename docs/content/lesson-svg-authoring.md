# Lesson SVG figures

B9, October 25, 2026. Static lesson figures only. Question figures and animation
are outside this convention. `flutter_svg` 2.3.0 parses figures in both the app
and the render check. Existing PNG figures still work.

## Files and markers

Save each figure at:

`content/illustrations/<subject>/<topic>/<lesson-slug>/NN-<slug>.svg`

Use the lesson's existing `<!-- ILLUSTRATION: description -->` markers. Files join
to markers in numeric sequence order. Sequence numbers may have gaps. Do not
reuse a sequence for two SVGs. An SVG replaces a PNG with the same sequence.
The marker description supplies alt text unless an existing asset map supplies it.
Write the full teaching meaning in the description, including relationships and
values someone needs without seeing the figure.

Credits. The seed and the upload stop with the file name and the credit key when a
figure file has no credit; neither one defaults a credit. An existing asset-map entry
with a URL and no credit is not a figure file: the upload stops on it, and the seed
drops that image with a warning, as it did before figures were embedded. The only figure with no entry in
`content/illustrations/sources/*.yaml` is a new original SVG: a `.svg` file in a slot
that has no existing asset-map entry. Pantas made it, and its credit is `Pantas`.
Every other figure needs a credit entry keyed by `subject/topic/lesson#N`: a PNG, a
third-party drawing, or an SVG that replaces an existing entry (it keeps that entry's
credit key, and the credit key must exist). When an original SVG replaces a
third-party figure, delete the third-party credit entry for that slot. Add
third-party credits to the manifests. Do not use the default for a third-party drawing.

The native seed and server uploader carry local bytes as data URLs in the lesson
content. This keeps offline figures in the same database/cache as their lessons.
The uploader replaces illustration markers with resolved `IMAGE` JSON markers;
authors keep writing `ILLUSTRATION`, not `IMAGE`. Do not hand-edit generated output.
Existing remote PNG URLs remain supported. The app also accepts remote `.svg`
URLs, including query strings, and bundled asset paths. Native remote SVGs use
the existing PNG disk cache; web SVGs use network loading and parser caching.
Base64 increases uncompressed source size. A lesson may take at most 900,000 bytes
once its figures are embedded (the lesson text with each marker replaced by its
`IMAGE` marker, counted in UTF-8 bytes). The server upload rejects a lesson over that
size, before any writes. The seed and export tools count the same way and drop the
figure that would pass the limit, with a warning, as they did before figures were
embedded. Split or optimize an oversized figure instead of weakening the limit. No
new public asset host is required.

## Theme colors without CSS

Use `fill="currentColor"` and `stroke="currentColor"` for primary ink. The app
sets it to `PantasColors.label` in the active theme. Explicitly set paint on
visible elements: SVG's default black fill is not theme-aware.

The following reserved literal hex values are color tokens, not displayed colors:

| Name | Literal | PantasColors property |
|---|---|---|
| ink | `#010101` | label |
| secondary ink | `#020202` | secondaryLabel |
| paper | `#030303` | surface |
| rule | `#040404` | separator |
| accent | `#050505` | accent |
| error | `#060606` | destructive |
| warning | `#070707` | warningText |

Use these values directly in fill, stroke, or stop-color attributes. The color
mapper replaces them before painting, in both themes. Use fill-opacity,
stroke-opacity, or opacity for transparency. Other literal colors remain fixed,
which preserves full-color teaching diagrams. Use fixed colors only when their
meaning requires them. The SVG frame and expanded viewer use the active surface.
PNG and code-figure backgrounds retain their existing behavior.

Do not use CSS variables, style attributes, style elements, classes, or external
stylesheets. `currentColor` is the SVG paint keyword, not a CSS stylesheet.

## Supported subset and validation

Use svg, g, defs, path, rect, circle, ellipse, line, polygon, polyline, text,
tspan, linearGradient, radialGradient, stop, clipPath, use, symbol, title, desc.
Use local `#id` references only. Convert labels to paths if they need an exact
font; font availability differs by platform. Keep a useful alt description.

No filters (including blur/shadow), masks, raster images, scripts, event handlers,
foreignObject, CSS, animation/SMIL, external references, entities or doctypes.
Unknown attributes fail instead of silently disappearing. The checker lists the
accepted attributes in its source; keep exports simple presentation attributes.

Run from the APP worktree, with no other Flutter command running:

```sh
python3 tools/check_lesson_svgs.py
python3 tools/check_lesson_svgs_test.py
python3 tools/check_lesson_svgs.py tools/svg_fixtures/pass
python3 tools/check_lesson_svgs.py tools/svg_fixtures/fail --validate-only
```

The last command must exit 1 and name every rejected fixture and reason. The
first and third commands draw each accepted SVG in memory through the app's
parser in both themes. They save no screenshots. Aedwon performs visual checks.
