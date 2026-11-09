DataTable lays out results in rows and columns: Record (past mocks) and Performance (subject and topic breakdown).

## When to use
- Use it for many results with several measures each: date, exam, score, correct, time.
- Don't use it for a short list of one measure (use StatRow or ListRow). Don't use it for layout.

## Anatomy
- `.dtable-wrap`: `surface-card`, radius `radius-xl` (18), 1px `edge-card` in dark, scrolls sideways (`overflow-x:auto`) inside the card on narrow screens.
- Caption: `web-title-sm` (16/600), padding 16 20 8.
- Header cells (`thead th` only): `web-eyebrow` (13/600, uppercase, +0.02em) in `text-secondary`, padding 12 by 16, a `divider` hairline under the row.
- Body cells: `web-row-value` (15/400/1.3) in `text-primary`, minimum row height 44 (`size-target-touch`), padding 10 by 16, `divider` hairlines between rows.
- Numbers `.is-num`: right-aligned, tabular figures, no wrap. One decimal only where the source has one. No data: `.is-empty` "No data" in `text-secondary`, never "0%".
- The first column is sticky (`position:sticky`, `surface-card` behind it) and the row header (`th scope="row"`). Row headers take the body cell style, not the header style (D194). Outer cells pad 20.
- Sort button `.dtable__sort` in a header: label plus a 14px chevron; hover `text-primary` with an 8% wash; the sorted column's header carries `aria-sort` and turns `text-primary`; descending flips the chevron.

## Variants and props
- Sortable or plain headers. The consumer provides the columns, the rows, the sort state and the caption.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<table class="dtable">
  <caption id="dt-lFalse">Past mock results</caption>
  <thead>
    <tr>
      <th scope="col" aria-sort="descending">
        <button type="button" class="dtable__sort">
          Date
          <svg aria-hidden="true">...</svg>
        </button>
      </th>
      <th scope="col">Exam</th>
      <!-- 2 more -->
      <th scope="col" class="is-num">Time</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row" class="web-row-value">Aug 20</th>
      <td>UPCAT Mock 6</td>
      <td class="is-num">71%</td>
      <!-- 1 more -->
      <td class="is-num">2:41</td>
    </tr>
    <tr>
      <th scope="row" class="web-row-value">Aug 3</th>
      <td>UPCAT Mock 5</td>
      <td class="is-num">64%</td>
      <!-- 1 more -->
      <td class="is-num">2:52</td>
    </tr>
    <!-- 2 more -->
    <tr>
      <th scope="row" class="web-row-value">Jun 16</th>
      <td>CSE Practice</td>
      <td class="is-num is-empty">No data</td>
      <!-- 1 more -->
      <td class="is-num">
        <span class="sr-only">No time</span>
      </td>
    </tr>
  </tbody>
</table>
```

## States
- Rest; sorted ascending or descending; empty ("No results yet", use EmptyState in the card); loading (Skeleton rows).
- Sort button: hover, pressed, keyboard focus (2px `accent` outline). The scroll region takes the focus ring when it scrolls.

## Keyboard
- Tab reaches the scroll region (`tabindex="0"`) when it overflows, then each sort button. Arrow keys scroll the region. Enter or Space sorts.

## Accessibility
- A real `table` with `caption`, `th scope="col"` and `th scope="row"`. The wrapper is `role="region"` named by the caption.
- `aria-sort="ascending"` or `"descending"` sits on the sorted `th`, so the order is announced. Empty time cells carry hidden text.
- On coarse pointers the sort button gets a 44px hit area (R3-O16).

## Motion
- None. Sorting reorders at once.

## Flutter
- Build with `Table` or a `ListView` of rows inside a horizontal `SingleChildScrollView`, the first column pinned. Use `Semantics(sortKey)` and announce the sort.
- Reads `surface-card`, `divider`, `text-primary`, `text-secondary`, `web-eyebrow`, `web-row-value`.

## Do
- Right-align numbers and show "No data" where nothing was measured.
- Keep the first column in view while the rest scroll.

## Don't
- Don't shrink text to fit columns; let the table scroll.
- Don't color a cell by value without printing the value.

## Placement
Record and Performance: in the primary column, full width of the column.

## Tokens used
`border-focus`, `accent`, `radius-xl`, `surface-card`, `edge-card`, `type-web-row-value`, `tracking-web-row-value`, `text-primary`, `space-16`, `space-20`, `space-8`, `type-web-title-sm`, `tracking-web-title-sm`, `space-12`, `border-hairline`, `divider`, `type-web-eyebrow`, `tracking-web-eyebrow`, `text-secondary`, `size-target-touch`, `space-10`, `space-4`, `space-6`, `radius-xs`, `dur-short-2`, `motion-fade`, `opacity-hover`

## Status
Draft (new in 3.0, R2-O10). All values from existing tokens; source: patterns.md "Data display" and the Record and Performance boards. Changed in 3.1: coarse hit area on sort (R3-O16).
