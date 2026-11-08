Select lets the learner pick one value from a list of six or more options. In forms it is a native `select` (ruling 6); the custom button and Popover listbox is only for the onboarding select box with search.

## When to use
- Use it for one choice from six or more options, such as a province or a school.
- Add a search field inside the list when it has more than about ten options.
- Don't use it for five options or fewer. Use Radio or SegmentedControl. Don't use it for several values (use SelectableTile or Checkbox).

## Anatomy
- Label above: `field__label` (13/600, `text-secondary`), 6px gap.
- Button: full width, minimum height 48px (`size-field`), radius 12 (`radius-md`), `surface-card`, 1px `border-control` ring, padding 8px 12px 8px 14px, value 16/400.
- Chevron-down 16px (`icon-muted`) at the right end.
- Large: `.select--lg`, minimum height 56px (`size-select`), radius 14 (`radius-lg`), left padding 16px. Used for the onboarding select box.
- List: Popover (`surface-card`, radius 14, padding 6px, `elev-popover`) 6px under the button, same width. Items 40px high, radius 12, 15/400.
- Selected item: `accent-tint` fill, 600 weight, and a check at the right end.
- Search: a `.search` field (38px) at the top of the list, then a hairline. The list shows "No results" in `.popover__empty` (15, `text-secondary`) only when no option is visible (it uses `hidden` otherwise; the bundle's `[hidden]` rule wins over its display, R3-A08), and a `.spinner` with text while loading.

## Variants and props
- `button.select` with `.select__value` and `.select__chev`, inside `.select-wrap`. `.select__value.is-placeholder` shows the placeholder in `text-secondary`.
- `.select--lg` for the 56px box.
- `.popover[role="listbox"]` holds `.popover__item[role="option"][aria-selected]`. With search, the `.popover` holds the search field and a separate `[role="listbox"]`.
- The consumer provides the label, the options, the selected value and the placeholder. For long lists, the consumer filters.
- Forms use a native select (ruling 6): `<span class="select-native"><select class="select" name id>...</select><svg class="select__chev">...</svg></span>`. It submits with the form, opens the platform list (best on phones) and needs no script.
- The custom listbox (`button.select` and a Popover) is only for the places the boards draw it: the onboarding select box with search. It carries the value in a hidden input (`<input type="hidden" name value>`) so the form still submits it.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<button type="button" id="sel-ex1" class="select" aria-haspopup="listbox" aria-expanded="false" aria-controls="sel-ex1-pop" aria-labelledby="sel-ex1-lbl sel-ex1-val">
  <span class="select__value" id="sel-ex1-val">UPCAT</span>
  <svg class="select__chev" aria-hidden="true">...</svg>
</button>
```

## States
- Rest: 1px `border-control` ring. Hover: ring `text-secondary`.
- Open (`aria-expanded="true"`): 2px `accent` ring, the chevron turns 180 degrees in 240ms (`dur-medium-1`, `motion-move`).
- Keyboard focus on the button: 2px `accent` outline, offset 2px. In the list, the active item has `surface-hover` and the same outline.
- Selected: item tint, weight and check. Placeholder: `text-secondary`.
- Disabled: `fill` background, `text-disabled`, no ring.
- Loading: a spinner and the text "Loading provinces". Empty: "No results".
- Error: `aria-invalid="true"` (or `.is-error`) draws a 2px inset `danger` ring; the message sits under the field with an alert icon, linked by `aria-describedby`, as in Field. With keyboard focus the red ring stays and the 2px `accent` outline is added outside it (R3-A09).

## Keyboard
- Button: Enter, Space or Arrow Down opens the list. Arrow Up also opens it.
- In the list: Arrow Down and Arrow Up move the active item. Home and End jump to the first and last item.
- Enter, or Space without search, picks the active item, closes the list and returns focus to the button.
- Esc closes the list and returns focus to the button. Tab closes it and moves on.
- Typeahead without search: type the first letters to jump to a match. With search, typing filters.

## Accessibility
- The button has `aria-haspopup="listbox"`, `aria-expanded` and `aria-controls`. Its name is the label plus the value (`aria-labelledby`).
- The list has `role="listbox"` and a name. Items have `role="option"` and `aria-selected`. Focus stays on the list or the search field, and `aria-activedescendant` points to the active item.
- With search, the field is `role="combobox"` with `aria-controls` and `aria-autocomplete="list"`.
- Announce the result count ("3 results", "No results") in a `role="status"` region.
- The selected item has a check, so it is not shown by color alone. The button is at least 48px high.

## Motion
- The list rises 8px and fades in over 240ms (`dur-medium-1`, `motion-move`) and fades out over the same time.
- Reduced motion: the list appears and disappears at once. The ring color fade may stay.

## Flutter
- Build PantasSelect on a MenuAnchor (a button child and `MenuItemButton` rows), or reuse WebPickerColumn for the list.
- Reads `surface-card` [`surface`], `border-control` [`controlOutline`], `accent`, `accent-tint`, `accent-tint-text`, `text-secondary` [`secondaryLabel`] and `fill`.
- Use PantasType for the 16px value and the 15px items.

## Do
- Keep the label visible. Don't use the placeholder as the label.
- Close the list on pick, Esc, outside click and Tab.

## Don't
- Don't use a Select for five options or fewer.
- Don't build the custom listbox for a plain form field: use the native `select`.

## Placement
Stacked with other fields, 16px apart, natural width (up to about 420px) on wide screens. Full width on the phone, where a bottom Sheet may hold the list instead.

## Tokens used
`border-focus`, `accent`, `space-8`, `size-field`, `space-12`, `space-14`, `radius-md`, `surface-card`, `border-ring`, `border-control`, `text-primary`, `type-web-row-title-settings`, `tracking-web-row-title-settings`, `dur-short-2`, `motion-fade`, `text-secondary`, `icon-muted`, `dur-medium-1`, `motion-move`, `border-ring-selected`, `size-select`, `radius-lg`, `space-16`, `danger`, `fill`, `text-disabled`

## Status
Draft (new in 2.0). Source: the onboarding select box (`.sb`, 56px) and the list pattern in Popover. Changed in 3.0: native `select` is the form default; the custom listbox keeps a hidden input (ruling 6). Changed in 3.1: native `select` is the default throughout; the invalid ring and invalid plus focus documented as built (R3-A01, R3-A09); the empty message obeys `hidden` (R3-A08).
