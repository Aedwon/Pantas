ExamChip shows the chosen exam and how many days are left.

## When to use
- Use it at the right end of the WeekStrip, or in a Settings row, to show the exam and the days left.
- Don't use it to pick a date (use DatePicker).

## Anatomy
- Calendar tile: 42px wide, minimum height 36, radius `radius-sm` (8), 1.5px `text-primary` outline. Day 14/700, month 11/700 `text-secondary`. CHANGE: the month was 9px and the radius was 10.
- Empty tile: dashed 1.5px `border-control` outline, "--" in `text-secondary`, "DATE" below.
- Beside it: exam name 13/700 and days left 13/400 `text-secondary`. Gap 10.
- In a week strip it follows a 0.5px `divider` rule and 12px of padding. When it wraps under the days (a phone under 600 wide) it takes its own line, 4px in from the left, and the rule is removed (`flex-basis: 100%`, no margin-left, no border; D185, board G25 A).
- The calendar tile is 2.625rem wide (42px at default text), so "DEC" stays inside it at 200% text (usage gap 26).

## Variants and props
- Set, or empty with a TextLink "Add Date".
- The consumer provides the exam name, the date and the days left, measured by the app.
- The exam name is `web-chip-name` (13/700) and the calendar day `web-glyph` (R3-O09). On a narrow strip the chip moves to its own line without the rule (R3-A04, D185).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
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
```

## States
- Not interactive. The "Add Date" link takes TextLink hover, pressed and focus.

## Keyboard
- Only the "Add Date" link takes Tab and Enter.

## Accessibility
- Give the calendar tile `role="img"` and a full date as its name ("November 11"). The text beside it names the exam and the days.
- The dashed outline is not the only cue: the word "Add Date" says what to do.

## Motion
- None.

## Flutter
- Build it inside WeekStrip (`components/week_strip.dart`) and the Settings exam row. The chip is a Row of a bordered Container and a Column of two Text widgets.
- Reads `text-primary` [`label`], `text-secondary` [`secondaryLabel`], `border-control` [`controlOutline`] and `divider` [`separator`].

## Do
- Show only the days left that the app measured.
- Offer "Add Date" as a TextLink when empty.

## Don't
- Don't invent a countdown for an exam without a date.
- Don't use red or a warning color for few days left.

## Placement
Right end of the WeekStrip after a 0.5px divider; on its own line under the days when it wraps; or in a Settings row.

## Tokens used
`space-10`, `space-4`, `space-12`, `border-hairline`, `divider`, `radius-sm`, `border-ring-strong`, `text-primary`, `type-web-glyph`, `tracking-web-glyph`, `type-web-pro`, `tracking-web-pro`, `text-secondary`, `border-control`, `type-web-chip-name`, `tracking-web-chip-name`, `type-web-small`, `tracking-web-small`

## Status
Approved (from the boards); changed in 2.0: month label 9 to 11px; tile radius 8; empty outline `border-control`. Changed in 3.1: `web-chip-name`, `web-glyph`. Changed in 3.2: calendar tile width in rem (usage gap 26). Changed in 3.3: the wrapped chip sits on its own line with no hairline (D185).
