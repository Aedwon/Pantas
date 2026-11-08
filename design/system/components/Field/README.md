Field is a single-line or multi-line text input with a label above, a ring that turns teal on focus, and an error state.

## When to use
- Use it for text the learner types: name, email, a note.
- Don't use it to pick from a list (use Select). Don't use it to pick a date (use DatePicker).

## Anatomy
- Label 13/600 `text-secondary`, 6px above (`space-6`). Field: min height 48 (`size-field`), radius `radius-md` (12), `surface-card`, padding 0 14, input 16px.
- Ring: 1px `border-control` (3:1). CHANGE: it was `divider` (1.2:1).
- Placeholder and hint text: `text-secondary`. Help and error lines: 13px under the field, with an icon, 6px gap.
- Multi-line (`.field--multi`): minimum height 92 (`size-textarea`), padding 12 14, resizes vertically.

## Variants and props
- `<label for>` with a unique id on the input. Help and error lines are tied with `aria-describedby`.
- Required is the default. Mark the others with `.field__opt` "(optional)".
- Set the right `type`, `inputmode` and `autocomplete` (name, email, nickname).
- The consumer provides the label, the validation and the message text.
- Trailing action slot (ruling 6): `<span class="field__action"><button class="icon-btn icon-btn--sm" aria-label="Choose a date">...</button></span>` as the last child of `.field`, for the date picker or a clear or show-password button. One action only; it pulls 8px into the padding so the icon lines up with the padding edge.
- A date field: typed entry (`inputmode="numeric"`, placeholder "MM / DD / YYYY") plus the trailing calendar button that opens DatePicker (patterns: offer both).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="field-wrap">
  <label class="field__label" for="f-a">Name</label>
  <div class="field">
    <input id="f-a" type="text" placeholder="Your full name" autocomplete="name" value="">
  </div>
</div>
```

## States
- Hover: ring `text-secondary`. Focus: 2px `accent` ring, inset.
- Invalid: 2px `danger` ring on `surface-card`. CHANGE: the red wash (`danger-tint`) is gone. Invalid and focused also shows the outer focus outline (2px `accent`, offset 2).
- Read-only (`[readonly]`): `surface-inset` with a 1px `divider` ring. Disabled: `fill`, `text-disabled`. Neither takes hover or press.
- Read only and focused: the read-only fill and ring stay, and the 2px `accent` outline is added outside (R3-A09).

## Keyboard
- Tab moves between fields. Enter in a single-line field submits the form.
- On submit with an invalid field, focus moves to the first invalid field.

## Accessibility
- `aria-invalid="true"` only after validation. The error message gets `role="alert"` on submit only, not on blur.
- The error is color plus icon plus text. Say how to fix it.
- Never use the placeholder as the label.
- The field is 48px high and the input stretches to fill it, so a tap anywhere in the visible well focuses the input and the 44px touch target is met (D190). A multi-line field is a textarea that fills its own area.

## Motion
- Ring color and width change over `dur-short-2` (150) on `motion-fade` on hover, focus and validation. Nothing moves.
- Reduced motion: the same fade (color is not spatial motion).

## Flutter
- No shared widget exists in the inventory. Build it on a TextField with an InputDecoration made from PantasColors.
- Reads `surface-card` [`surface`], `border-control` [`controlOutline`], `accent`, `danger` [`destructive`], `text-secondary` [`secondaryLabel`], `fill` and `inset`.
- Set `keyboardType`, `textInputAction` and `autofillHints` to match the web `type` and `autocomplete`.

## Do
- Validate on submit and say how to fix the problem ("Enter a full email address").
- Tie help and error text with `aria-describedby`.
- Move focus to the first invalid field on submit.

## Don't
- Don't show the error by color alone.
- Don't use the placeholder as the label.
- Don't validate on each key.

## Placement
Stacked, 16px apart. Wide screens: natural width (about 320 to 420px), left-aligned. Phone: full width.

## Tokens used
`space-6`, `type-web-field-label`, `tracking-web-field-label`, `text-secondary`, `space-4`, `space-8`, `size-field`, `space-14`, `radius-md`, `surface-card`, `border-ring`, `border-control`, `dur-short-2`, `motion-fade`, `text-primary`, `type-web-row-title-settings`, `tracking-web-row-title-settings`, `border-ring-selected`, `accent`, `danger`, `border-focus`, `fill`, `text-disabled`, `surface-inset`, `divider`, `size-textarea`, `space-12`, `type-web-body`, `tracking-web-body`, `type-web-small`, `tracking-web-small`, `space-2`, `danger-text`

## Status
Approved (from the boards); changed in 2.0: ring `border-control`; invalid fill is `surface-card`; invalid and focused outline; read-only; multi-line; optional marker; submit behavior; semantics. Changed in 3.0: trailing action slot `.field__action` (ruling 6); label style `web-field-label` (R2-O01). Changed in 3.1: read-only focus outline (R3-A09). Changed in 3.4.0: the input stretches to the full height of the field (D190).
