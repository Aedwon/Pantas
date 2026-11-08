Figure shows a question figure or a lesson diagram and opens it full screen in the FigureViewer.

## When to use
- Use it for every `figureSpec` figure in quiz, mock and assessment questions, and for diagrams in the reader.
- Don't use it for decoration or icons. Don't put text the learner must read only inside an image; give it a description.

## Anatomy
- `.figure`: the image inside `.figure__open` (a button), then `.figure__cap` (`web-small`, `text-secondary`).
- `.figure__open`: `figure-bg` backing (white in both themes, the printed look), padding 12, radius `radius-md` (12), 1px `divider` ring, a 32px zoom badge at the bottom right.
- `.figure--reader`: `figure-reader-bg` backing for reader illustrations.
- FigureViewer `.fviewer`: full-screen modal on `figure-scrim`, `z-modal`. Tool bar at the top right: zoom out, the zoom level (`web-row-sub`, `figure-caption`), zoom in, reset, Close; 44px icon buttons (`size-icon-btn`) in `figure-on-viewer`. Stage `.fviewer__stage` centers `.fviewer__fig` (`figure-bg`, radius 12). Caption `.fviewer__cap` in `figure-caption`.
- `figure-viewer-bg` is the stage color in the Flutter viewer (black); the web viewer shows the page through `figure-scrim`.

## Variants and props
- `.figure`, `.figure--reader`, `.fviewer`, `.fviewer--contained` (previews only).
- Zoom and pan are data on the figure: `--zoom` (1 to 4) and `--pan-x`, `--pan-y`, set by script.
- The consumer provides the image, the `alt` or description from `figureSpec`, the caption and the figure number.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<figure class="figure">
  <button type="button" class="figure__open" aria-haspopup="dialog" aria-label="Open figure 1 full screen">
    <svg>...</svg>
    <span class="figure__zoom">
      <svg aria-hidden="true">...</svg>
    </span>
  </button>
  <figcaption class="figure__cap">Figure 1. Find x.</figcaption>
</figure>
```

## States
- Figure: rest, hover (pointer: zoom cursor), keyboard focus (2px `accent` outline). The image itself is not interactive.
- Viewer: open, zoomed (1x to 4x), exiting (`.is-exiting`). Zoom out and reset do nothing at 1x.

## Keyboard
- Enter or Space on the figure opens the viewer; focus moves to Close.
- In the viewer: Tab cycles the tools and the stage (focus trapped). On the stage, arrow keys pan 40px when zoomed. Plus and minus keys zoom. Esc closes and returns focus to the figure.

## Accessibility
- The figure button says "Open figure 1 full screen". The image carries `role="img"` and the `figureSpec` description as its name.
- The viewer is `role="dialog"` with `aria-modal`, named "Figure 1"; the page behind is inert. The zoom level is announced politely.
- Pinch and wheel zoom have button equivalents.

## Motion
- The viewer opens with the dialog timing (`dur-flip` fade of the scrim; the figure needs no rise). Zoom changes ease over `dur-medium-1` on `motion-move`. Reduced motion: it fades in place; zoom jumps.

## Flutter
- Reuse the figure viewer route (`InteractiveViewer` with `minScale: 1`, `maxScale: 4`) on `figure-viewer-bg` [`figureViewerBackground`]; buttons in `figure-on-viewer` [`onFigureViewer`].
- Reads `figure-bg` [`figureBackground`], `figure-reader-bg` [`readerFigureBackground`], `figure-scrim`, `figure-caption`.

## Do
- Give every figure a description and a caption number.
- Keep figures white in dark, as printed.

## Don't
- Don't shrink a figure below its readable size; let the viewer zoom.
- Don't open the viewer on hover.

## Placement
In a question under the stem, before the options; in the reader inline with the text.

## Tokens used
`border-focus`, `accent`, `space-8`, `space-12`, `radius-md`, `figure-bg`, `border-ring`, `divider`, `size-icon-btn-sm`, `radius-sm`, `surface-card`, `text-secondary`, `elev-popover`, `figure-reader-bg`, `type-web-small`, `tracking-web-small`, `z-modal`, `figure-scrim`, `figure-on-viewer`, `dur-flip`, `dur-medium-2`, `space-4`, `type-web-row-sub`, `tracking-web-row-sub`, `figure-caption`, `space-16`, `dur-medium-1`, `motion-move`, `space-20`, `type-web-sub`, `tracking-web-sub`, `dur-short-2`

## Status
Draft (new in 3.0, R2-O11). Uses the six existing `figure-*` tokens; tool size is `size-icon-btn`. Source: README "Math and figures" contract and the code's figure viewer. Changed in 3.2: `figure-viewer-bg` is kept because the Flutter viewer stage reads it (R4-O11).

