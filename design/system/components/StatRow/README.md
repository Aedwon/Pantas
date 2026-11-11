StatRow shows one subject and its accuracy as a name, a percentage and a teal bar.

## When to use
- Use it for a list of subjects or topics with an accuracy score each, inside a Card.
- Don't use it for one hero score (use Gauge). Don't use it to open a page (use ListRow).

## Anatomy
- `.stat-list` inside a `.card` (`radius-xl`). Padding 6px top, 20px sides (`space-20`), 8px bottom (`space-8`).
- Each `.stat-row`: padding 12px (`space-12`) top and bottom, and 8px gap (`space-8`) between the top line and the bar.
- A 0.5px `divider` rule sits under every row except the last.
- Top line: name 16/400 at the left, value 16/600 tabular at the right.
- Bar: `.bar5`, 5px (`size-accuracy-bar`), `fill` track, one of five teal steps for the fill (see AccuracyBar).
- Empty row: value "No data" in 16/400 `text-secondary` and a bar with no fill.

## Variants and props
- `.bar5 > i.cN`: c1 below 45%, c2 45 to 54, c3 55 to 64, c4 65 to 74, c5 75 and up. Set `style="--value:N"` to the same percent as the value (ruling 4).
- `.stat-row.is-empty`: no `<i>` in the bar. A fill of 0% still shows a 5px dot, so use the empty row for no data.
- The consumer provides the name, the percent and the container.
- Link (ruling 8): `a.stat-row.stat-row--link` for a subject row that opens its page (Performance). The whole row is the link; a 16px chevron (`.stat-row__cv`, `icon-chevron`) sits at the end of the top line; hover and press show the `surface-hover` well (radius 12, reaching 12px past the text); keyboard focus draws the 2px `accent` ring inside the row.
- Value: `web-stat-value` (16/600); empty is the 400 state (R3-O09).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="stat-row" role="listitem">
  <div class="stat-row__top">
    <span>Mathematics</span>
    <span class="stat-row__v">61%</span>
  </div>
  <div class="bar5" aria-hidden="true">
    <i class="c3" style="--value:61"></i>
  </div>
</div>
```

## States
- Rest, and empty. A row is not interactive, so it has no hover, pressed, focus or disabled state.
- If a row opens a page, use ListRow instead and keep the bar inside it.

## Keyboard
- The row takes no keys.

## Accessibility
- Use `role="list"` on `.stat-list` and `role="listitem"` on each row, so the count is announced.
- The name and the value are text. Mark the bar `aria-hidden`, because the percentage already says the same.
- Never rely on the bar color. The lightest step is 3.0:1 on `surface-card`, and the number is always printed.
- A link row is one link: its name is the subject and the value ("Mathematics, 38%"). The bar stays `aria-hidden`.

## Motion
- The fill grows from 0 over 600ms (`dur-long-2`, `motion-house`). Reduced motion: full at once.

## Flutter
- Reuse ScoreBreakdownRow (`components/score_breakdown_row.dart`) and AccuracyBar.
- Reads `fill`, the five chart steps, `text-primary` [`label`], `text-secondary` [`secondaryLabel`] and `divider` [`separator`].

## Do
- Print the percent next to the name, with tabular figures.
- Use "No data" for a subject the learner has not practiced.

## Don't
- Don't give each subject its own color.
- Don't use red or green for low and high accuracy.

## Placement
Inside a Card on Home (Performance) and on results screens, one row per subject, full card width.

## Tokens used
`border-focus`, `accent`, `space-6`, `space-20`, `space-8`, `space-12`, `border-hairline`, `divider`, `space-4`, `type-web-row-title-settings`, `tracking-web-row-title-settings`, `type-web-stat-value`, `tracking-web-stat-value`, `radius-md`, `dur-short-2`, `motion-fade`, `surface-hover`, `icon-chevron`, `text-secondary`

## Status
Draft (new in 2.0). Source: the Home and Mock results boards. The paddings (6/20/8, 12, 8) are chosen; see Decisions. Flutter: ScoreBreakdownRow and AccuracyBar. Changed in 3.0: `--value` data contract. Changed in 3.1: link variant (ruling 8); value style `web-stat-value` (R3-O09).
