ListRow is one line in a list: optional leading icon, title, optional subtitle and value, and a chevron.

## When to use
- Use it for a list of items the learner can open or read: subjects, lessons, settings.
- Don't use it for a choice among options (use SelectableTile or Radio). Don't use it on the phone (use GroupedList).
- Don't put a primary button in a row. Use `.row-actions` for Sign Out and Delete Account.

## Anatomy
- Leading icon 22px in `accent` (`.row__lead`), then title 17/400, subtitle 14 in `text-secondary`, value 15 in `text-secondary`, chevron 16px in `icon-chevron`.
- Inset 20px (`layout-row-inset`), or 16px for settings rows (`layout-row-inset-settings`). Gap 16px. Vertical padding 13px (`layout-row-pad-y`).
- Vertical padding stays 13 (D179): a 17px title (line height 1.3) plus 13 above and below gives a 48px row, over the 44pt minimum target. The Settings row has a 16px title and is 47px. The boards also drew 15 and 16.
- A 0.5px `divider` starts at the title. It is hidden on the last row, and on the row before a CardFooter.
- Titles and subtitles wrap. No ellipsis by default. Add `.truncate` on the title only when the page asks.
- An inline Tag or Pro mark in a title gets a 6px gap and a 2px baseline lift.
- `.row--settings`: title and value 16px (board).
- `.row-actions`: Sign Out and Delete Account as tertiary `btn--sm`. The first button is pulled left 18px so its label lines up with the row text. The destructive button is last.
- `.hint-text`: 13px, `text-secondary`, for text hints like "Click to copy".
- Chevron (3.2.1): out of the wrapping flow at the end of the row, centered on it; the row keeps its slot (1rem plus the 12px gap) as padding. It never takes a line of its own, at 320px or at 200% text; when the value stacks, the chevron stays at the end, centered on both lines.
- Split row `.row--split` (ruling 3, Bookmarks BM boards): the main area `.row__main` is the link or button and holds the lead, title, subtitle, value and chevron; a trailing `.row__action` (an IconButton such as "Remove bookmark") is its sibling, never nested inside it. The hover well covers the main area only; one hairline runs under both from the row inset; the action sits 8px from the right edge (4 on the phone). At large text the chevron stays at the end of the main area (on the title's line when the title wraps), never on a line of its own.

## Variants and props
- `a.row` for a link, `button.row` for an action, `div.row` for a read-only line.
- `.row--done`: title, subtitle and value in `text-secondary`.
- `.row--static`: no hover, default cursor, not focusable. For read-only values like "Signed in with Google".
- `.row--settings`, `.row--compact` (12px vertical), `.row--phone` (see GroupedList).
- Selected row in a list-detail view: `aria-current="true"`. The fill is `accent-tint` and the subtitle is `text-on-tint-secondary`.
- `.is-dim`: a row that is not available yet. It uses `text-secondary` color, not opacity.
- The consumer provides the title, subtitle, value, icon and destination.
- In a card that mixes link rows and static rows, a static row reserves the chevron slot (an empty 16px cell), so values line up (usage gap 23).
- Large text (ruling 12): wrap rules stack the value under the title by themselves: the title keeps at least 6em of its own text (3.2.1; 8em stacked board rows at 100% text), and when title and value no longer fit on one line the value wraps under it (about 1.5x on a 390 phone; works in link, button and static rows). `.row--stack` stays as a forced override.
- Completed and selected: the title takes `text-on-tint-secondary` on the tint (4.6:1; R3-A06).
- `.row--split` with `a.row__main` (or `button.row__main`) and a `.row__action` button; it works with `.row--phone` and `.row--settings`. Link styles never reach row parts: `a.row__main` and `a.row__t` reset color and underline (ruling 3).

## Markup
The split row (ruling 3); a plain row is the same without `.row__main` and `.row__action`.

```html
<div class="row row--split">
  <a class="row__main" href="#">
    <div class="row__in">
      <div class="row__t">
        <span class="row__title">Which fraction is the same as 0.75?</span>
        <span class="row__sub">Fractions · UPCAT Practice</span>
      </div>
      <svg class="row__cv" aria-hidden="true">...</svg>
    </div>
  </a>
  <button type="button" class="icon-btn icon-btn--md row__action" aria-label="Remove bookmark: Which fraction is the same as 0.75?">
    <svg aria-hidden="true">...</svg>
  </button>
</div>
```

## States
- Hover: `surface-hover` and the chevron fades in (150ms). Pressed: keeps the hover fill.
- Selected: `accent-tint`. Keyboard focus: 2px `accent` outline, offset -2px (inside the row).
- Dim: `text-secondary`, no hover. Disabled (`aria-disabled="true"`): `text-disabled`, no hover, no press.
- On touch the chevron is always visible.
- Selected (`.is-selected` or `aria-current`): `accent-tint` fill; subtitle and value in `text-on-tint-secondary` (4.6:1 light), chevron in `accent-tint-text` (4.5:1). CHANGE (R2-O05): the value stayed `text-secondary` (4.4:1) and the chevron `icon-chevron` (2.8:1) on the tint.

## Keyboard
- Tab focuses a link or button row. Enter activates a link or button. Space also activates a button.
- A static row takes no focus.
- Split row: Tab reaches the main area, then the action. Enter opens the main area; Enter or Space runs the action.

## Accessibility
- The whole row is the target, at least 44px high with the default padding.
- A selected row carries `aria-current="true"`, not only the tint.
- The chevron is decorative (`aria-hidden`). Do not name it.
- Never use opacity to dim text; it fails contrast.
- Split row: name the action with its target ("Remove bookmark: Which fraction is the same as 0.75?"). Never put a button inside a link or a link inside a button.

## Motion
- The hover fill and the chevron fade over 150ms (`dur-short-2`, `motion-fade`).
- Reduced motion: the fades stay at 150ms.

## Flutter
- Reuse ListRow (`core/ui/components/list_row.dart`) for the row and InkTableRow for dense tables.
- Reads `surface-card` [`surface`], `accent`, `accent-tint`, `text-primary`, `text-secondary`, `text-disabled`, `icon-chevron` [`chevron`] and `divider` [`separator`].
- Split row: a `Row` of an `Expanded` `InkWell` (the main area, with the hover well) and an `IconButton`; never an `IconButton` inside the `InkWell`. Reads `surface-hover`, `divider` and `icon-chevron` as above.

## Do
- Make the whole row the target.
- Use `row--compact` (12px) for dense lists.
- Let titles wrap.

## Don't
- Don't use a red icon unless the row is destructive.
- Don't truncate a title to make room for the value. Shorten the value.
- Don't dim a row with opacity.

## Placement
Inside a Card, with no card padding. Phone: GroupedList.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.row--phone .row__in`: padding 11px, padding 11px (phone board 11px 16px 11px 0 (x280))

## Tokens used
`border-focus`, `accent`, `space-8`, `layout-row-inset-settings`, `space-18`, `space-16`, `layout-row-inset`, `text-primary`, `type-web-row-title`, `tracking-web-row-title`, `dur-short-2`, `motion-fade`, `surface-hover`, `accent-tint`, `text-on-tint-secondary`, `accent-tint-text`, `space-12`, `layout-row-pad-y`, `border-hairline`, `divider`, `space-6`, `type-web-row-sub`, `tracking-web-row-sub`, `text-secondary`, `type-web-row-value`, `tracking-web-row-value`, `icon-chevron`, `type-web-row-title-settings`, `tracking-web-row-title-settings`, `space-2`, `size-row-min-phone`, `type-phone-body`, `tracking-phone-body`, `type-phone-footnote`, `tracking-phone-footnote`, `danger-text`, `text-disabled`, `space-4`

## Status
Approved (from the boards); changed in 2.0: titles wrap, `row--done`, `row--static`, `row--settings` 16px, `aria-current` selected row, dim uses `text-secondary`, inline Tag spacing, `.row-actions`, `.hint-text`. D23 (13 vs 15 and 16) stays open. Changed in 3.0: selected value and chevron colors pass on `accent-tint` (R2-O05); static rows keep the chevron slot. Changed in 3.1: automatic stacking at large text (ruling 12); completed plus selected title (R3-A06). Changed in 3.2: split row with a trailing action (ruling 3). Changed in 3.3: vertical padding 13 confirmed (D179).
