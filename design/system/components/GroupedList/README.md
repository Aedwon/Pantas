GroupedList is the phone list: an optional header, one rounded group of rows, and an optional footer.

## When to use
- Use it for lists and settings on the phone.
- On wide screens use ListRow inside a Card.
- Don't use it for a choice among options (use SelectableTile or Radio).

## Anatomy
- Header `.group__head`: 13/600, uppercase, +0.02em, `text-secondary`, padding 0 16px 7px.
- Group `.group`: `surface-card`, radius `radius-lg` 14, a 1px `edge-card` edge. Rows are inset 16px from the left. The 0.5px separator starts at the text, not the edge.
- Row `.row--phone`: minimum 44px (`size-row-min-phone`), title 17 (`phone-body`), subtitle 13, value 17 in `text-secondary`, chevron always visible.
- Footer `.group__foot`: 13/400, `text-secondary`, padding 7px 16px 0.
- Sections are 24px apart (`space-24`).
- CHANGE: the group radius is `radius-lg` 14. The row tokens are renamed.
- CHANGE: disabled rows use `text-disabled` for the title, subtitle and value (was 45% opacity).

## Variants and props
- Row variants: label only, label and value, label and chevron, label and switch, leading icon, caption line, destructive (red title, no chevron).
- Destructive rows sit in their own group at the bottom.
- At large text sizes the value stacks under the title. Flutter does this above 1.5x. `bundle.css` has no class for it yet.
- The consumer provides the sections, rows, values and the destination or action of each row.
- A switch row uses the native Switch: `<label class="row__t" for>` names `<input type="checkbox" role="switch" class="switch">` (ruling 6).
- A phone row with a separate trailing action (Bookmarks remove) uses ListRow's split anatomy: `.row.row--phone.row--split` with `a.row__main` and `.row__action` (ruling 3).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="group-sec">
  <div class="group__head" role="heading" aria-level="2">Account</div>
  <div class="group">
    <a class="row row--phone" href="#">
      <div class="row__in">
        <div class="row__t">
          <span class="row__title">Plan</span>
        </div>
        <span class="row__v">Free</span>
        <svg class="row__cv" aria-hidden="true">...</svg>
      </div>
    </a>
    <a class="row row--phone" href="#">
      <span class="row__lead">
        <svg aria-hidden="true">...</svg>
      </span>
      <div class="row__in">
        <div class="row__t">
          <span class="row__title">Your exam</span>
        </div>
        <span class="row__v">UPCAT</span>
        <svg class="row__cv" aria-hidden="true">...</svg>
      </div>
    </a>
    <a class="row row--phone" href="#">
      <div class="row__in">
        <div class="row__t">
          <span class="row__title">Back Up</span>
          <span class="row__sub">Last backup today</span>
        </div>
        <svg class="row__cv" aria-hidden="true">...</svg>
      </div>
    </a>
    <div class="row row--phone" aria-disabled="true">
      <div class="row__in">
        <div class="row__t">
          <span class="row__title">Pro Tools</span>
          <span class="row__sub">Needs a Pro plan</span>
        </div>
      </div>
    </div>
  </div>
  <div class="group__foot">Your plan renews on March 1, 2027.</div>
</div>
```

## States
- Pressed: `surface-hover`. Keyboard focus: 2px `accent` outline, offset -2px.
- Disabled: `aria-disabled="true"` and `text-disabled`, no press.
- A switch row applies at once. Its row is not tappable as a whole unless the page decides so.

## Keyboard
- Tab goes through the rows in order. Enter activates a link or button row. Space toggles a switch.

## Accessibility
- Give each group a heading (`role="heading"` with `aria-level`) and keep the order of reading.
- Tie each switch to its row title with `aria-labelledby`.
- Do not show state by color alone. A destructive row has red text and a position in its own group.
- Rows are at least 44px high.

## Motion
- None.

## Flutter
- Reuse GroupedSection (`core/ui/components/grouped_section.dart`) and ListRow for the rows. Use PantasSwitch for the switch rows.
- Reads `surface-card` [`surface`], `divider` [`separator`], `text-secondary` [`secondaryLabel`], `danger` [`destructive`] and `text-disabled` [`disabledActionLabel`].

## Do
- Keep one group per topic.
- Put destructive rows in their own group at the bottom.

## Don't
- Don't use a tinted tile behind a row icon.
- Don't put a primary button inside a group.
- Don't use opacity to show a disabled row.

## Placement
Inside the phone gutter (16px), on `bg-page`.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.group__head`: padding 7px (phone board 0 16px 7px (x241))
- `.group__foot`: padding 7px (phone board 7px 16px 0 (x46))

## Tokens used
`space-24`, `space-16`, `type-web-eyebrow`, `tracking-web-eyebrow`, `text-secondary`, `surface-card`, `radius-lg`, `edge-card`, `type-web-small`, `tracking-web-small`, `space-12`

## Status
Approved (from the boards); changed in 2.0: group `radius-lg`, disabled rows use `text-disabled`, switch rows tied by `aria-labelledby`, section gap 24. Changed in 3.2: split rows (ruling 3).

