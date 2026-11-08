AccuracyBar shows accuracy for a subject or topic as a thin bar beside its number.

## When to use
- Use it beside a subject or topic name to show accuracy.
- Don't use it for progress through a task (use ProgressBar). Don't use it without the number.

## Anatomy
- Track `fill`, 5px high (`size-accuracy-bar`), 4px in topic rows (`size-accuracy-bar-compact`), `radius-full`.
- The fill is one of five discrete steps. No interpolation. CHANGE: the app used to blend between two colors.
- `chart-1` below 45%. `chart-2` 45 to 54. `chart-3` 55 to 64. `chart-4` 65 to 74. `chart-5` 75 and up.
- Every step holds 3:1 on the card in both themes. The dark ramp is dimmer for lower accuracy.
- A bar never shrinks below its own height, so a low value still shows (`min-width`).
- One rule for both platforms.

## Variants and props
- `.bar5` with `.bar5--rows` for topic rows. The fill is `<i class="c1">` to `<i class="c5">` with `style="--value:N"`.
- The consumer provides the percent, the step class and the printed number.
- Data contract (ruling 4): the value is one custom property on the element, `style="--value:62"` (0 to 100, the printed number). The class reads it. This is data, not styling; inline styles carry only the data and state properties the README lists (R3-O12). CHANGE: it was an inline width or a `stroke-dasharray` attribute.
- Contrast: the steps sit on the `fill` track, where step 1 is 2.6:1 light and 2.4:1 dark. Exempt (WCAG 1.4.11): the bar is supplementary and the number is always printed (R2-O06, D46).
- Row: `.acc-row` puts the label (`web-row-sub`, at most 7rem), the bar and the value (`web-row-value`, tabular, right-aligned) in one grid row; no inline layout (R3-O12).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="acc-row">
  <span class="acc-row__label">Mathematics</span>
  <div class="bar5" aria-hidden="true">
    <i class="c1" style="--value:38"></i>
  </div>
  <span class="acc-row__v">38%</span>
</div>
```

## States
- Filled and growing. The bar is not interactive.

## Keyboard
- None. The bar is not focusable.

## Accessibility
- Print the percentage beside the bar. The bar is `aria-hidden` because the number says the same thing.
- Lighter or dimmer fill is never the only cue.

## Motion
- Grows from 0 over 600ms (`dur-long-2`) on `motion-house`. Reduced motion: full at once.

## Flutter
- Reuse AccuracyBar (`components/accuracy_bar.dart`, `.topicRows` for 4px). Replace the `accuracyTint` blend with the five steps.
- Reads `fill` and the five chart steps (`chart-1` to `chart-5`).

## Do
- Use the same ramp for every subject.
- Print the number every time.

## Don't
- Don't give subjects their own hues.
- Don't use red or green for low and high.

## Placement
Beside a subject name in a Card, and inside StatRow and Performance rows.

## Tokens used
`size-accuracy-bar`, `radius-full`, `fill`, `size-accuracy-bar-compact`, `chart-3`, `dur-long-2`, `motion-house`, `chart-1`, `chart-2`, `chart-4`, `chart-5`, `space-12`, `type-web-row-sub`, `tracking-web-row-sub`, `text-secondary`, `type-web-row-value`, `tracking-web-row-value`

## Status
Approved (from the boards); changed in 2.0: five discrete steps with new thresholds; dark ramp; minimum width. Changed in 3.0: `--value` data contract (ruling 4); contrast measured on the track and marked exempt (R2-O06). Changed in 3.1: `.acc-row` (R3-O12).
