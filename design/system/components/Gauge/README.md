Gauge is a half-ring that shows one score, such as overall accuracy, with the number under the arc.

## When to use
- Use it for one hero score on Home and on Mock results.
- Don't use it for progress through a task list (use ProgressRing). Don't use it for several subjects (use StatRow).

## Anatomy
- Dial 224 by 118: the width is `size-gauge-w` and the height comes from `aspect-ratio` (224 / 118). The arc runs from (7, 111) to (217, 111) with radius 105, so the stroke fits the dial.
- Stroke 14px (`size-gauge-stroke`), round caps. Track `fill`. Value `accent`.
- Number sits at the bottom center: `web-display` (48/700, tabular). The unit "%" is `web-stat-unit` (22/600, `text-secondary`).
- Label under the dial: 15/400, `text-secondary`, 4px below (`space-4`).
- Phone: the number is `phone-display-s` (44/700).

## Variants and props
- `.gauge` with `.gauge__dial`, `.gauge__track`, `.gauge__value`, `.gauge__num`, `.gauge__label`.
- The value path has `pathLength="100"`. Set `style="--value:P"` on the value path (ruling 4).
- `.gauge.is-empty`: the arc is hidden, the number is an en dash (U+2013) in `text-secondary`, and the label says "No score yet".
- The consumer provides the number, the label and the card around it.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="gauge" role="meter" aria-label="Overall accuracy" aria-valuemin="0" aria-valuemax="100" aria-valuenow="68" aria-valuetext="68 percent">
  <div class="gauge__dial">
    <svg aria-hidden="true">...</svg>
    <div class="gauge__num">
      <span class="web-display">68</span>
      <span class="web-stat-unit">%</span>
    </div>
  </div>
  <div class="gauge__label">Overall accuracy</div>
</div>
```

## States
- Rest: arc drawn to the value.
- Empty: track only, en dash, "No score yet".
- It is not interactive, so it has no hover, pressed, focus or disabled state.

## Keyboard
- The gauge takes no keys.

## Accessibility
- Use `role="meter"` with `aria-valuenow`, `aria-valuemin`, `aria-valuemax`, `aria-valuetext` ("68 percent") and an accessible name.
- Empty: use `role="img"` with a name that says there is no score.
- The number is always printed, so the arc is never the only signal.
- Mark the svg `aria-hidden`.

## Motion
- The arc fills over `dur-gauge` (1400ms) after `dur-wait` (300ms) with `motion-gauge`.
- The number counts up over the same time and lands on the value.
- Reduced motion: the final arc and number appear at once.

## Flutter
- Reuse HalfRingGauge (`components/half_ring_gauge.dart`).
- Reads `fill`, `accent`, `text-secondary` [`secondaryLabel`] and `text-primary` [`label`].

## Do
- Print the number and the label under the arc.
- Show the empty state when the learner has no score, not a zero.

## Don't
- Don't color the arc by score. Keep it one teal.
- Don't use a hyphen or an em dash for the empty number. Use the en dash.

## Placement
Home accuracy card and Mock results, centered in a Card. The dial shrinks with its container (`max-width: 100%`).
- Results score card: the Gauge is the score display (the boards' 48/700 "ring percentage" is this half gauge, `HalfRingGauge` in code). The full ring that lands on the score belongs to the Mock finale choreography only (usage gap 9).

## Tokens used
`space-4`, `size-gauge-w`, `fill`, `size-gauge-stroke`, `accent`, `dur-gauge`, `motion-gauge`, `dur-wait`, `space-2`, `text-secondary`, `type-web-sub`, `tracking-web-sub`

## Status
Draft (new in 2.0). Source: the Home accuracy and Mock results boards (224 by 118, 14px stroke). Flutter: HalfRingGauge. Changed in 3.0: `--value` data contract; results score card rule. Changed in 3.2: the dial height from `aspect-ratio` (R4-O13).

