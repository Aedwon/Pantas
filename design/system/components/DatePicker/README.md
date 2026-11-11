DatePicker lets the learner choose a date, such as the exam date. Wide screens show a month grid and a date grid. The phone shows wheels. Both offer typed entry.

## When to use
- Use it to pick a date in the near future, such as an exam date.
- Always offer the typed field too.
- Don't use it for a date far in the past, such as a birth date (use the typed field and a Select for the year). Don't use it for a time of day.

## Anatomy
- Typed field: Field (48px) with `inputmode="numeric"`, placeholder "MM/DD/YYYY", and a `.field__msg` help line.
- Month grid: 4 columns, gap 8px. Month cell minimum height 42px (`size-month-cell`), radius 12 (`radius-md`), 15/500, background `bg-page`.
- Date grid: 7 columns, gap 4px. Weekday labels 11/600 `text-secondary`. Date cell minimum height 46px (`size-date-cell`), radius 12, 15/500, tabular figures.
- Selected: `accent-fill` with `on-accent` text, 700 weight. Today: `accent` text, 700 weight. Past: `text-secondary`, 400 weight.
- CHANGE: past and unselected values use `text-secondary`, not #AEAEB2. They are readable values.
- Phone wheel: five rows visible, row height 36px (`size-wheel-row`), selection band 36px in `bg-page` with radius 8. The row height follows the scaled line (D190): the larger of 36px and the wheel line plus 16px, so 36px at default text and 56px at 200%. The viewport (five rows), the snap spacing and the band all use that one height, so adjacent rows never overlap. Unselected 20/400 `text-secondary`. Selected 20/500 `text-primary`.
- WheelGroup `.wheel-group` (ruling 6, Onboarding exam date, OB boards): the month, day and year wheels in equal columns with one shared selection band (`bg-page`, radius 8, 12px in from each side) behind all three; each wheel inside drops its own band. CHANGE D160: the phone boards draw the columns 140 and 80 wide. The group is a size container (`container: wheelgroup`), so it needs a definite width (a block-level grid). Under `layout-wheel-full` (21rem) of group width the month wheel shows the short name (Jan, Feb) so a full month never overflows its column (D190): in each month option put the full name in `.wheel__full` and the short name in `.wheel__short` (`aria-hidden="true"`); the full name stays in the accessible name. There is no separate fallback control; the typed field is already offered beside the wheels.

## Variants and props
- `.datepick` holds `.month-grid` of `.month-cell` buttons and `.date-grid` of `.date-cell` buttons.
- Month cell: `aria-pressed="true"` when chosen. Past months are `disabled`.
- Date cell: `aria-selected="true"` when chosen, `aria-current="date"` for today, `disabled` for past days.
- `.wheel` (`role="listbox"`) holds `.wheel__opt` items (`role="option"`, `aria-selected`). Use one wheel per part: month, day, year, side by side in a `.wheel-group` (ruling 6).
- The consumer provides the first allowed date, the chosen date and the change handler.

## Markup
The phone wheels in a WheelGroup (ruling 6).

```html
<div class="wheel-group">
  <div class="wheel" role="listbox" tabindex="0" aria-label="Month" aria-activedescendant="wh-m-10">
    <div class="wheel__opt" role="option" id="wh-m-0" aria-selected="false"><span class="wheel__full">January</span><span class="wheel__short" aria-hidden="true">Jan</span></div>
    <div class="wheel__opt" role="option" id="wh-m-1" aria-selected="false"><span class="wheel__full">February</span><span class="wheel__short" aria-hidden="true">Feb</span></div>
    <!-- 9 more -->
    <div class="wheel__opt" role="option" id="wh-m-11" aria-selected="false"><span class="wheel__full">December</span><span class="wheel__short" aria-hidden="true">Dec</span></div>
  </div>
  <div class="wheel" role="listbox" tabindex="0" aria-label="Day" aria-activedescendant="wh-d-27">
    <div class="wheel__opt" role="option" id="wh-d-0" aria-selected="false">1</div>
    <div class="wheel__opt" role="option" id="wh-d-1" aria-selected="false">2</div>
    <!-- 27 more -->
    <div class="wheel__opt" role="option" id="wh-d-29" aria-selected="false">30</div>
  </div>
  <div class="wheel" role="listbox" tabindex="0" aria-label="Year" aria-activedescendant="wh-y-0">
    <div class="wheel__opt" role="option" id="wh-y-0" aria-selected="true">2026</div>
    <div class="wheel__opt" role="option" id="wh-y-1" aria-selected="false">2027</div>
    <div class="wheel__opt" role="option" id="wh-y-2" aria-selected="false">2028</div>
  </div>
</div>
```

## States
- Rest, hover (`surface-hover`), keyboard focus (2px `accent` outline, offset 2px), selected, today, past (disabled).
- The selected cell pops over 350ms (`dur-switch`), keyframed overshoot on `motion-enter` (R2-O13).
- Empty: the typed field shows the placeholder and no cell is selected. Error: show a `.field__msg--error` line under the field, for example "Pick a date after today."
- Typed entry and the grid share one validator (R3-A13): a date is valid only if it is a real calendar date and not before the first allowed day. An invalid typed date sets `aria-invalid="true"` and shows the linked error on blur, keeps the last valid selection, and clears once a valid date is typed.

## Keyboard
- Date grid: Arrow Left and Arrow Right move one day. Arrow Up and Arrow Down move one week. Home and End jump to the first and last allowed day.
- Enter or Space chooses the focused day. Only one cell is in the Tab order.
- Month grid: Tab to each month, Enter or Space chooses it.
- Typed field: paste or type digits. A full valid date selects the cell.
- Wheel: Tab focuses it, Arrow Up and Arrow Down move one row.

## Accessibility
- Each date cell has a full name ("November 28, 2026") in `aria-label`. The grid is a `listbox` named by the month label.
- Month cells are toggle buttons (`aria-pressed`). Past values are `disabled`, not just gray.
- Today has `aria-current="date"` and a heavier weight, so it is not shown by color alone.
- The typed field is the accessible path for every user. Link its help line with `aria-describedby`.
- The grid cells are pointer targets of 42 to 46px high. On touch screens, use the wheel or the typed field.

## Motion
- The selected date pops in 350ms (`dur-switch`, keyframed, `motion-enter`). The wheel snaps to the nearest row.
- Reduced motion: no pop, and the wheel jumps to the row.

## Flutter
- Reuse MonthFirstDatePicker for the grids, ValueWheel for the phone wheels and WebPickerColumn for the web columns.
- Reads `accent-fill`, `on-accent`, `accent`, `text-secondary` [`inactiveDateLabel`], `text-secondary` [`secondaryLabel`], `bg-page` [`background`] and `surface-card` [`surface`].
- WheelGroup: a `Row` of `Expanded` ValueWheels over one `DecoratedBox` band inset 12. Row height and band height are `max(36, textScaler.scale(20) + 16)` (ValueWheel `itemExtent` and the band use the same value). When the group is under 21 times `textScaler.scale(16)` wide (the width in rem), the month wheel shows `DateFormat.MMM` and keeps the full name in `Semantics.label`.

## Do
- Offer typed entry beside every picker.
- Disable dates the learner can't choose, and say why in the help line.

## Don't
- Don't show past dates in a pale gray that fails contrast.
- Don't hide the year or the month name. Always label the grid.

## Placement
In a Card or Dialog on onboarding and in Settings, 380px wide on wide screens. On the phone, the typed field sits above the wheels in a Sheet or a page.

## Tokens used
`border-focus`, `accent`, `text-primary`, `space-16`, `space-8`, `size-month-cell`, `radius-md`, `bg-page`, `type-web-nav`, `tracking-web-nav`, `dur-short-2`, `motion-fade`, `surface-hover`, `accent-fill`, `on-accent`, `text-secondary`, `space-4`, `type-web-key-hint-sm`, `tracking-web-key-hint-sm`, `size-date-cell`, `dur-switch`, `motion-enter`, `size-wheel-row`, `space-12`, `radius-sm`, `type-phone-wheel`, `tracking-phone-wheel`, `text-disabled`, `size-target-touch`, `layout-wheel-full`

## Status
Draft (new in 2.0). Source: the onboarding month cell (`.mo`, 42 high), date cell (`.dd`, 46 high, pop 350ms) and the phone wheel (rows 36, band 36). Flutter: MonthFirstDatePicker, ValueWheel, WebPickerColumn. Changed in 3.1: one validator for typed entry and the grid (R3-A13). Changed in 3.2: WheelGroup (ruling 6). Changed in 3.4.0: wheel rows follow the scaled line; short month names under `layout-wheel-full` (D190).

