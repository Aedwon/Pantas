WeekStrip shows the current week: which days were studied, which is today, and the exam date. The learner can select a day.

## When to use
- Use it at the top of Home for the current week.
- Don't use it to pick a date (use DatePicker). Don't use it for a long history.

## Anatomy
- Card `surface-card`, radius `radius-xl` (18), padding 8 10 8 8. Seven day cells, gap 4. Each cell is 44px wide (`size-week-day`), radius `radius-md` (12), padding 4 0.
- Each cell: weekday 11/600 `text-secondary`, date 15/500 tabular, a 5px dot (`size-accuracy-bar`).
- Dot: `accent` is done. Half `accent` and half `divider-strong` is partly done. No dot is no study or planned (D124).
- Today: weekday in `accent` 700, date inside a 26px `accent-fill` disc with `on-accent` 14/700. A 34px progress ring (`.wd__ring`) surrounds the disc: viewBox "0 0 34 34", r 16, track `divider`, arc `accent`.
- Past days with no study (`is-off`): `text-secondary`, weight 400. They are never red.
- Phone (`week--phone`): cells 44px wide (`size-week-day`), radius `radius-sm` (8), weekday 10/600, Today disc 28px. CHANGE: the cells were 34px.
- The seven days sit in `.week__days`, which carries `role="tablist"`; an ExamChip can sit at the right after a hairline, outside the tablist (usage gap 3). Under 600 the chip wraps onto its own line and the hairline goes (D185). The hairline goes by viewport, not by wrapping, because CSS cannot see a wrapped item; at 600 and up the chip has room at default text, and in a narrow tablet column at very large text a wrapped chip can keep its hairline, right-aligned (accepted limit, D189).
- No legend (CHANGE D186: the "Done / Partly done" legend is removed). A day that has a status shows a Tooltip with its status in sentence case: "Done", "Partly done", "No study", "Planned"; Today always shows "Today", whatever its progress (Today has no dot; its ring and its name carry the progress, D189). It shows on hover with a fine pointer after `dur-tooltip` (500ms) and at once on keyboard focus, never on touch. Hover and focus are tracked separately and the tooltip stays while either holds, so a pointer elsewhere does not hide a focused day's tooltip. The hover zone is the whole strip (`.week`, including its 8px padding) plus the tooltip and its 8px bridge, so the pointer can cross from the day to the tooltip (WCAG 1.4.13: hoverable, persistent, dismissible with Esc; the preview script is the reference).
- The tooltip is one `.tooltip` (`aria-hidden="true"`, `hidden` when not shown) that is a child of `.week`, which is `position: relative`, not of a day: `.week__days` scrolls sideways at 320 (`overflow-x: auto`) and would clip a tooltip inside it, and it must stay `overflow-x: auto`. The app sets its position with the data property `--x` (unitless pixels, D189), for example `style="--x:132"`, to the centre of the hovered or focused day minus the scroll offset (`day.offsetLeft - days.scrollLeft + day.offsetWidth / 2`), and keeps it inside the strip. The CSS reads it as `calc(var(--x) * 1px)`; no inline `left`. It sits 8px above the strip (Tooltip placement).

## Variants and props
- The consumer provides the seven days, each status, the Today progress and the selected day.
- Dot classes: `is-done`, `is-half`, `is-off`, `is-today`.
- Narrow screens (R3-A04): each day keeps 44px (`flex: 0 0 44px`). When seven days do not fit (320px), the ExamChip moves to its own line first, then the days scroll sideways inside the strip and the app scrolls the selected day into view; focus rings keep 4px clearance.
- Done and half dots are data marks on `accent` (R3-O07; dark `#4CC3AC`).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="week">
  <div class="week__days" role="tablist" aria-label="This week">
    <button type="button" class="wd is-done" role="tab" id="ws-m-0" aria-selected="false" tabindex="-1" aria-label="Monday, October 12, done" aria-controls="ws-panel">
      <small>Mon</small>
      <b>12</b>
      <i></i>
    </button>
    <button type="button" class="wd is-half" role="tab" id="ws-m-1" aria-selected="false" tabindex="-1" aria-label="Tuesday, October 13, partly done" aria-controls="ws-panel">
      <small>Tue</small>
      <b>13</b>
      <i></i>
    </button>
    <!-- 4 more -->
    <button type="button" class="wd" role="tab" id="ws-m-6" aria-selected="false" tabindex="-1" aria-label="Sunday, October 18, planned" aria-controls="ws-panel">
      <small>Sun</small>
      <b>18</b>
      <i></i>
    </button>
  </div>
  <div class="exam-chip">
    <div class="cal" role="img" aria-label="November 11">
      <b>11</b>
      <small>NOV</small>
    </div>
    <div>
      <div class="exam-chip__name">UPCAT</div>
      <div class="exam-chip__days">27 days</div>
    </div>
  </div>
</div>
```

## States
- Hover: `surface-hover`. Pressed: scale 0.97. Keyboard focus: 2px `accent` outline, offset 2. The status tooltip shows with hover and focus (see Anatomy).
- Selected: 2px `accent` inset ring (`border-ring-selected`) and `aria-selected="true"`. CHANGE: it was the hover well (1.07:1).
- When a selected day takes focus, the outline is `text-primary`.

## Keyboard
- Tab reaches the selected day only (roving tabindex). Left and Right move and select the next day. Home and End select Monday and Sunday.

## Accessibility
- Use `role="tablist"` for the days, `role="tab"` with `aria-selected`, and `aria-controls` the plan panel. Today also has `aria-current="date"`.
- Each day's accessible name is the full date plus its status ("Wednesday, October 14, no study").
- Never color alone: the dot shape (a full dot is done, a half dot is partly done) and the day name carry the status. The tooltip repeats the status for sighted pointer and keyboard users only: it is `aria-hidden="true"` and the days have no `aria-describedby`, because each name already ends with its status (an exception to the Tooltip rule, D186). On touch there is no tooltip; the dot shape and the selected day's plan carry the status. Accepted limit (D189): a planned day and a no-study day both show no dot, and on touch only the text weight and color (`is-off`) and the day's name tell them apart; planned is always a future day and no-study a past day, so the position in the week and the name carry the difference.
- Each cell is a 44px target.
- Forced colors (R4-O02): only done dots paint `CanvasText`; half dots paint a half `CanvasText` disc with a `CanvasText` edge; planned, no-study and today cells show no dot.

## Motion
- The Today ring fills over 900ms (`dur-long-3`) after 300ms (`dur-wait`). Reduced motion: drawn at once.

## Flutter
- Reuse WeekStrip (`components/week_strip.dart`) with its WeekDayState values done, partial, missed, dayOff, today and plain. Show missed as neutral.
- Status tooltip: Flutter `Tooltip` with `excludeFromSemantics: true` on each day (the day label already ends with the status), `TooltipTriggerMode.manual` on touch platforms.
- Reads `surface-card` [`surface`], `accent`, `accent-fill`, `divider` [`separator`], `divider-strong`, `text-secondary` [`secondaryLabel`] and `text-primary` [`label`]. Cell radius 12 on wide, 8 on phone.

## Do
- Show the dot and the day name, not color alone.
- Keep missed days neutral.

## Don't
- Don't use red for missed days.
- Don't use the hover well as the selected state.

## Placement
Top of Home, full content width. The page header can hold it in its trailing slot.

## Tokens used
`border-focus`, `accent`, `text-primary`, `space-4`, `space-8`, `space-10`, `radius-xl`, `surface-card`, `edge-card`, `space-2`, `size-week-day`, `radius-md`, `dur-short-2`, `motion-fade`, `dur-short-3`, `motion-move`, `surface-hover`, `border-ring-selected`, `type-web-key-hint-sm`, `tracking-web-key-hint-sm`, `text-secondary`, `type-web-nav`, `tracking-web-nav`, `size-accuracy-bar`, `radius-full`, `divider-strong`, `accent-fill`, `on-accent`, `type-web-label`, `tracking-web-label`, `divider`, `radius-sm`, `type-phone-caption-small`, `tracking-phone-caption-small`, `space-16`, `toast-bg`, `toast-text`, `elev-toast`, `z-tooltip`, `size-tooltip-max`, `radius-sm`, `type-web-caption`, `tracking-web-caption`

## Status
Approved (from the boards); changed in 2.0: selected 2px ring; Today ring; legend; full-date names; phone cells 44px; past days `text-secondary`. Changed in 3.0: `.week__days` holds the tablist; the ExamChip sits outside it; legend in `.page-head__after`. Changed in 3.1: 44px days that scroll at 320 (R3-A04); dots on `accent` (R3-O07); Flutter reads `divider-strong` (R3-A10). Changed in 3.2: dot color line fixed; forced colors by state (R4-O02, R4-O13). Changed in 3.3: the legend is removed and each day with a status shows a Tooltip (CHANGE D186); the wrapped ExamChip sits on its own line (D185). Changed in 3.4.0: the tooltip is placed with `--x`, not an inline `left`; Today's tooltip precedence; the ExamChip and touch limits stated (D189).
