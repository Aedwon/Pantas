ProgressBar is a thin bar that shows how far along something is, such as the question number or the time used.

## When to use
- Use it for a straight-line measure with a label, such as "Question 4 of 10" or time left.
- Don't use it for accuracy by subject (use StatRow). Don't use it for a round score (use ProgressRing or Gauge).

## Anatomy
- Track: 5px high (`size-accuracy-bar`), `fill`, `radius-full`, clips its fill.
- Fill: `accent-fill`, `radius-full`. Warning: `warning-text`.
- Visible label above the bar: 14/600 (`web-label`), with an optional short value at the right (15/400 `text-secondary`, or a warning Tag). Gap 8px.
- The time bar and the question bar in the phone mock use the same 5px bar.
- Label row `.pbar-head` (Onboarding step header, OB boards): `.pbar-head__label` (`web-label`, `text-primary`) at the left and `.pbar-head__value` ("Step 2 of 4", `web-small`, `text-secondary`, tabular) at the right, wrapping at large text; the bar follows 8px below. A Back link, when the step has one, sits in the nav bar above, not in the row.

## Variants and props
- `.pbar` with a single `<i style="--value:N">`. `.pbar--warning` colors the fill `warning-text`.
- The consumer provides the label, the current and maximum values, a text for `aria-valuetext`, and the width in percent.
- Data contract (ruling 4): the value is one custom property on the element, `style="--value:62"` (0 to 100, the printed number). The class reads it. This is data, not styling; inline styles carry only the data and state properties the README lists (R3-O12). CHANGE: it was an inline width or a `stroke-dasharray` attribute.
- The fill is a data mark on `accent` (R3-O07; dark `#4CC3AC`, 6.1:1 on its `fill` track; light unchanged).

## Markup
The label row, then the bar.

```html
<div class="pbar-head">
  <span class="pbar-head__label" id="pbh">Your Exam</span>
  <span class="pbar-head__value">Step 2 of 4</span>
</div>
```

## States
- Empty (0%): track only. Partial. Complete (100%): full fill, and say "Done" in text.
- Warning: `warning-text` fill plus a visible text, such as a Tag that says "4 min left".
- The bar is not interactive, so it has no hover, pressed, focus or disabled state.

## Keyboard
- The bar takes no keys.

## Accessibility
- Use `role="progressbar"` with `aria-valuenow`, `aria-valuemin`, `aria-valuemax` and `aria-valuetext`. Name it with `aria-labelledby` pointing to the visible label.
- The label and the value are text, so color is never the only cue. A warning always has words.
- Update `aria-valuenow` and `aria-valuetext` when the value changes. Don't announce every step.
- In forced colors, the fill uses the system highlight color.

## Motion
- The fill width changes over 600ms (`dur-long-2`, `motion-house`).
- Reduced motion: the width jumps to the new value.

## Flutter
- Build PantasProgressBar on a ClipRRect with a LinearProgressIndicator, or a custom painter, with `minHeight` 5.
- Reads `fill`, `accent-fill` and `warning-text`.

## Do
- Show the current value as text next to the bar.
- Use the warning bar only with a warning text.

## Don't
- Don't use red for a running-out bar. Use the warning color with words.
- Don't make the bar taller than 5px.

## Placement
Top of a question screen (full width, under the header) and in the mock exam top bar. On Home, under a study-time label.

## Tokens used
`size-accuracy-bar`, `radius-full`, `fill`, `accent`, `dur-long-2`, `motion-house`, `warning-text`, `size-timer-bar`, `space-4`, `space-12`, `type-web-label`, `tracking-web-label`, `text-primary`, `type-web-small`, `tracking-web-small`, `text-secondary`, `space-8`

## Status
Draft (new in 2.0). Source: the phone time bar and question bar (5 high, `fill` track). Changed in 3.0: `--value` data contract (ruling 4). Changed in 3.1: fill on `accent` (R3-O07). Changed in 3.2: `.pbar-head` label row.

