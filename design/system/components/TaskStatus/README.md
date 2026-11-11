TaskStatus is the round marker at the start of a plan row. It shows whether a task is done, half done, up next, or not started.

## When to use
- Use it in the lead slot of a plan or study-list row.
- Don't use it for a choice the learner makes (use Checkbox). Don't use it for a share of a whole (use ProgressRing).

## Anatomy
- Disc 26px on wide screens (`size-task`), 24px on the phone (`size-check`), `radius-full`.
- Not started: 1.5px `border-control` ring (`border-ring-strong`), no fill.
- Half done: 1.5px `border-control` track and a 2.4px `accent` arc over half the ring, starting at 12 o'clock. Use a viewBox equal to the pixel size.
- Up next: 2px `accent` ring (`border-ring-selected`) on `surface-card`.
- Done: `accent-fill` disc with a 13px `on-accent` check, stroke 3.
- Each marker carries hidden text in `.sr-only`.
- CHANGE: the boards drew the not-started ring in #C7C7CC. It is `border-control` (3.4:1) so it passes the 3:1 rule.

## Variants and props
- `.task` plus one of `.task--todo`, `.task--partial`, `.task--current`, `.task--done`.
- `.task--phone` makes the disc 24px.
- `.task--partial` holds an svg with two circles, `.ring__track` and `.ring__value`, both with `pathLength="100"`. Set `style="--value:P"` on `.ring__value` (ruling 4).
- The consumer provides the state and the hidden text: "Done", "Half done", "Up next" or "Not started".
- Partial ring strokes: track `border-ring-strong`, value `size-ring-stroke` (R3-O22).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<span class="task task--done">
  <svg aria-hidden="true">...</svg>
  <span class="sr-only">Done</span>
</span>
```

## States
- The marker has no hover, pressed or disabled state. The row around it takes hover (`surface-hover`), pressed and focus.
- Keyboard focus: 2px `accent` outline on the row, offset -2px.
- Done rows dim their title and subtitle to `text-secondary` (`.row--done`).

## Keyboard
- The marker takes no keys. The row link takes Tab to focus and Enter to open.

## Accessibility
- The svg is `aria-hidden`. The `.sr-only` text names the state, so the row reads "Done, Fractions, part 1".
- The four shapes differ (empty ring, partial arc, thick ring, check), so color is never the only cue.
- The row is the touch target: at least 44px high.

## Motion
- The done check pops in 420ms (`dur-medium-3`), keyframed overshoot on `motion-enter` (R2-O13).
- The half arc grows over 900ms (`dur-long-3`) after `dur-wait`, with `motion-house`.
- Reduced motion: both draw at once.

## Flutter
- Reuse ProgressRing (`components/progress_ring.dart`, the `.study` constructor) for the half arc and CheckMark for the done disc.
- Build a thin TaskStatus widget that picks between them.
- Reads `border-control` [`controlOutline`], `accent`, `accent-fill`, `on-accent` and `surface-card` [`surface`].

## Do
- Put the state in text for screen readers on every marker.
- Use the half arc only when the app measured partial progress.

## Don't
- Don't show a red or orange marker for a missed task.
- Don't use a lighter ring than `border-control` for not started.

## Placement
Left end of a ListRow in the plan list on Home. On the phone, it is the lead of a row in a GroupedList.

## Tokens used
`size-task`, `radius-full`, `on-accent`, `size-check`, `border-ring-strong`, `border-control`, `border-ring-selected`, `accent`, `surface-card`, `accent-fill`, `dur-medium-3`, `motion-enter`, `size-ring-stroke`

## Status
Draft (new in 2.0). Source: the Main board (Home plan rows, 26px) and the phone checks (24px). Flutter: ProgressRing and CheckMark. Changed in 3.0: `--value` contract; pop curve. Changed in 3.1: stroke tokens (R3-O22).
