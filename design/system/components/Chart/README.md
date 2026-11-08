Chart shows results over time as bars or a line: the Results past-results chart and the Performance trend.

## When to use
- Use it for a series over time: past mock scores (Results, Record), accuracy trend (Performance). The past-results chart runs the full content width (HANDOFF).
- Don't use it for one subject's accuracy (use AccuracyBar or StatRow with the five steps). Don't use it for a single number (use Gauge).

## Anatomy
- `figure.chart`: head (`web-h3` title, optional legend), a one-line summary (`.chart__summary`, `web-sub`, `text-secondary`), the plot, and a table equivalent.
- Plot: height `size-chart-h` (220) at every width. Y axis `.chart__y`: 0, 25, 50, 75, 100% in `web-caption` (12/400) `text-secondary`, tabular. Gridlines 1px `divider` every 25%, plus the top and the baseline.
- Columns `.chart__col`: one per result, equal shares of the plot width, each at least `size-chart-col` (2.75rem, 44px at default size): when the plot is narrower than that, the chart keeps only the most recent points that fit (12, 8, 6 or 4 when the chart is under 36, 25, 19.5 and 14rem wide) and `.chart__clipped` says "Showing the last N weeks. The table has all N." (ruling 7). X labels `.chart__x` in `web-caption`; the latest in 600 `text-primary`.
- Bars `.chart__bar`: `accent` (a data mark, R3-O07; dark 7.6:1 on the card), width up to 28px (60% of the column), radius 5 at the top, minimum height 5 so a low value shows.
- Line: each column draws its own segment from its point to the next (`.chart__seg`, an SVG `line` from the column center to the next center, 2px `accent`, non-scaling stroke), so the line and the points share the column boxes as one coordinate system at every width (R3-A15). Points `.chart__point` are 8px `accent` discs with a 2px `surface-card` edge, above the line.
- Value labels `.chart__val`: `web-tag` (12/600) `text-primary`, tabular, 8px above the mark. The body reserves room above the plot, so a value of 100 keeps its label inside the card (R3-A11).
- Second series (`.chart__seg--b`, `.chart__point--b`): `text-secondary`, dashed 4 4, square markers. It differs by line style and marker shape, never by hue alone. Legend keys `.chart__key` and `.chart__key--b`.
- Text never scales with the SVG: labels are HTML at a fixed type size (minimum 12px at every width). The SVG holds only line segments. The plot never scrolls sideways (ruling 7).

## Variants and props
- Bar or line: `.chart__bar` or `.chart__point` in each column; a line is one `.chart__seg` per column (see Anatomy). The line is never one SVG for the whole series, because its points would stop matching the columns when the chart hides the oldest ones (R4-O06).
- Data (ruling 4): each `.chart__col` carries `style="--value:62"` (0 to 100). Each segment is SVG data: `viewBox="0 0 100 100"` with `preserveAspectRatio="none"`, from (0, 100 minus this value) to (100, 100 minus the next value). The last column has none.
- One point: a line chart shows the point and no line; the summary says "One result so far".
- Empty: `.chart__empty` in the plot ("No results yet. Take a mock exam to see your trend."), gridlines kept, no table.
- Color: one teal series. Accuracy by topic uses the five `chart-*` steps in AccuracyBar, not here (usage gap 10).
- The consumer provides the points, the labels, the summary sentence and the table.
- The clipped note (R4-O09): `.chart__clipped` shows only when the chart hides a column (it counts the columns), so a 10-point series at 30rem prints nothing and adds no gap. Include one span per step that can apply.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<figure class="chart" aria-labelledby="ch-lbarPas">
  <figcaption class="chart__head">
    <span class="web-h3" id="ch-lbarPas">Past results</span>
  </figcaption>
  <p class="chart__summary">Your last 6 mocks ranged from 48% to 71%. The...</p>
  <div class="chart__body" aria-hidden="true">
    <div class="chart__y">
      <span>100%</span>
      <!-- 3 more -->
      <span>0%</span>
    </div>
    <div class="chart__scroll">
      <div class="chart__cols">
        <div class="chart__col" style="--value:48">
          <div class="chart__mark">
            <span class="chart__bar"></span>
            <span class="chart__val">48%</span>
          </div>
          <span class="chart__x">Jun 2</span>
        </div>
        <!-- 4 more -->
        <div class="chart__col is-current" style="--value:71">
          <div class="chart__mark">
            <span class="chart__bar"></span>
            <span class="chart__val">71%</span>
          </div>
          <span class="chart__x">Aug 20</span>
        </div>
      </div>
    </div>
  </div>
  <p class="chart__clipped">
    <span class="chart__clipped-4">Showing the last 4 mocks. The table has all 6.</span>
  </p>
  <button type="button" class="btn btn--tertiary btn--sm chart__table-toggle" aria-expanded="false" aria-controls="ch-table">Show Table</button>
  <div class="chart__table" id="ch-table">
   <div class="dtable-wrap">
    <table class="dtable">
      <caption>Past results</caption>
      <thead>
        <tr>
          <th scope="col">Date</th>
          <th scope="col">Score</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <th scope="row">Jun 2</th>
          <td>48%</td>
        </tr>
        <!-- 4 more -->
        <tr>
          <th scope="row">Aug 20</th>
          <td>71%</td>
        </tr>
      </tbody>
    </table>
   </div>
  </div>
</figure>
```

## States
- Rest, empty, one point. Growing on first show. The chart is not interactive; values are printed.

## Keyboard
- None: the plot is not interactive and never scrolls. The table equivalent holds every value.

## Accessibility
- The plot is `aria-hidden`. The summary sentence is visible text, and a table carries every value. The table sits in `.chart__table`, a visually hidden region that screen readers always reach (never `table.sr-only`, which cannot shrink below its content).
- Whenever the chart hides columns, sighted users must be able to read the hidden results (D190, Astra #16): a visible tertiary "Show Table" button (`.chart__table-toggle`, `btn btn--tertiary btn--sm`, `aria-expanded`, `aria-controls` the table) appears under the clipped note only while a column is hidden. Pressing it adds `.is-open` to `.chart__table`, which shows the DataTable (`.dtable-wrap` with `.dtable`) with all values, and its label becomes "Hide Table". The app toggles the class and the label. Do not omit the button: the note "The table has all 6" must lead somewhere a sighted phone or large-text user can open.
- Values are printed beside the marks, so color is never the only signal. Gridlines are decorative (exempt from 3:1).
- Forced colors: bars and points keep `CanvasText` (`forced-color-adjust: none`), the second series `GrayText`, segments `CanvasText` (R3-O06).

## Motion
- Bars grow from the baseline over `dur-long-2` (600) on `motion-house`, like AccuracyBar. The line has no draw animation. Reduced motion: drawn at once (the bar grow is in the reduced-motion list, R3-O05).

## Flutter
- Draw with a `CustomPainter` for the gridlines, bars and line; labels are `Text` widgets laid out by the row, never painted text, so they follow the text scale. Lay out the columns first and draw each segment between column centers. Keep the most recent points that fit at `size-chart-col` each. Wrap the painter in `ExcludeSemantics` and expose the summary and a table. When the chart keeps fewer points than it has, show a "Show Table" tertiary button under the clipped note that reveals a DataTable with every value (D190).
- Reads `accent`, `divider`, `text-secondary`, `text-primary`, `surface-card`, `web-caption`, `web-tag`, `size-chart-h`, `size-chart-col`.

## Do
- Print every value and give a one-line summary.
- Keep labels at their type size and let the chart drop the oldest points.

## Don't
- Don't scale the chart text with the drawing.
- Don't add a second hue for a second series.

## Placement
Results: full content width, under the score card. Record and Performance: in the primary column.

## Tokens used
`space-12`, `space-4`, `space-16`, `type-web-sub`, `tracking-web-sub`, `text-secondary`, `type-web-caption`, `tracking-web-caption`, `space-6`, `border-ring-selected`, `accent`, `space-8`, `size-chart-h`, `divider`, `border-ring`, `space-28`, `size-accuracy-bar`, `radius-xs`, `dur-long-2`, `motion-house`, `radius-full`, `surface-card`, `type-web-tag`, `tracking-web-tag`, `text-primary`, `space-2`

## Status
Draft (new in 3.0, ruling 3). Colors and type from existing tokens; `size-chart-h` 220 is new, no board. Changed in 3.1: no sideways scroll, most recent points that fit, per-column segments, value headroom, bars on `accent` (ruling 7, R3-A11, R3-A15, R3-O07). Changed in 3.2: no whole-series line; the clipped note only when a column is hidden (R4-O06, R4-O09). Changed in 3.4.0: the table equivalent is `.chart__table` with a visible "Show Table" button while columns are hidden (D190).

