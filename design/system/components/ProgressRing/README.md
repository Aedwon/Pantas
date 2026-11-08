ProgressRing shows a share of something done as an arc.

## When to use
- Use it for the share of a day's tasks or a lesson done, at 24, 34 or 44px, always beside a number or a word.
- Don't use it for a score (use Gauge). Don't use it for a finished task (use TaskStatus).

## Anatomy
- SVG ring with `pathLength="100"`. Set `style="--value:P"` on the value circle (ruling 4); the class turns it into the dash. It starts at 12 o'clock.
- Each size uses its own viewBox equal to its pixel size, so strokes stay 2px (track) and 2.4px (arc). CHANGE: one 36 viewBox was scaled.
- 24px: r 10.5. 34px: r 15.5. 44px: r 19, arc 2.5px with a butt cap.
- Track `divider` (decorative: the number or status text is always shown). Arc `accent`, round cap. `ring--web` uses a `fill` track.
- 0%: `.ring.is-empty` hides the arc, so no dot shows at 12 o'clock. CHANGE.
- 100%: swap the ring for the filled TaskStatus marker (`accent-fill` disc and check). CHANGE: it was an outline ring with a check.

## Variants and props
- `.ring--24`, `.ring--34`, `.ring--44` (default), `.ring--web`, `.is-empty`.
- The half gauge is its own component: see Gauge. The done marker is TaskStatus.
- The consumer provides the percent and the visible number or word.
- Strokes: track `border-ring-selected` (2), value `size-ring-stroke` (2.4), the 44px ring `border-ring-current` (2.5) (R3-O22). Put a type class on the center number (`.ring__center > span` sets no weight of its own, R3-O09).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<svg class="ring ring--24" aria-hidden="true">...</svg>
```

## States
- Filling, resting and empty. A ring is not interactive: no hover, pressed or focus state.

## Keyboard
- None. The ring is not focusable.

## Accessibility
- Mark the svg `aria-hidden`. Print the number or the word beside it ("3 of 4 tasks").
- The ring is never the only signal, which is why the track is decorative.

## Motion
- The arc grows from 0 over 900ms (`dur-long-3`) after 300ms (`dur-wait`), on `motion-house`.
- Reduced motion: drawn full at once.

## Flutter
- Reuse ProgressRing (`components/progress_ring.dart`, the `.study` constructor). Use CheckMark or TaskStatus for the done state.
- Reads `divider` [`separator`], `fill` and `accent`.

## Do
- Print the number or the word; the arc is not the only signal.
- Use TaskStatus for a finished task.

## Don't
- Don't color rings by subject. One teal.
- Don't show a dot at 12 o'clock for 0%.

## Placement
Day rows (24), card headers (34), Today (44).

## Tokens used
`divider`, `accent`, `border-ring-selected`, `size-ring-stroke`, `dur-long-3`, `motion-house`, `dur-wait`, `border-ring-current`, `fill`, `border-control`, `border-ring-strong`

## Status
Approved (from the boards); changed in 2.0: own viewBox per size; 0% hides the arc; done is TaskStatus; Gauge split out; large ring removed. Changed in 3.0: `--value` data contract. Changed in 3.1: stroke tokens (R3-O22).
