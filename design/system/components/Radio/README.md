Radio picks exactly one option from a short list.

## When to use
- Use it for 2 to 5 mutually exclusive options that apply when the learner submits.
- Don't use it for more than five options (use Select). Don't use it for a setting that applies at once (use Switch).

## Anatomy
- 24px circle (`size-check`). Unselected: 1.5px `border-control` ring. Selected: `accent-fill` with a 14px `on-accent` check, no ring.
- The radio keeps the check mark, as the approved phone boards draw it. A dot is not adopted.
- The `.choice` row (a `label`) holds the input and its 16px label. The row is the 44px target. The group is a `fieldset.choice-group` with a `legend`.

## Variants and props
- Built on a native input: `<input type="radio" class="radio" name value>`. CHANGE (ruling 6): it was a `button` with `role="radio"`. Inputs that share a `name` form the group.
- The consumer provides the options, the name and the handler.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<fieldset class="choice-group">
  <legend>Study time</legend>
  <label class="choice">
    <input type="radio" class="radio" name="time-l" value="mornings" checked>
    <span class="choice__label">Mornings</span>
  </label>
  <label class="choice">
    <input type="radio" class="radio" name="time-l" value="afternoons">
    <span class="choice__label">Afternoons</span>
  </label>
  <label class="choice">
    <input type="radio" class="radio" name="time-l" value="evenings">
    <span class="choice__label">Evenings</span>
  </label>
</fieldset>
```

## States
- Hover: `surface-hover` well. Selected hover: `accent-fill-hover`. Pressed: scale 0.94.
- Keyboard focus: 2px `accent` outline, offset 2. Disabled (`disabled`): `opacity-disabled` (0.4). No hover and no press.

## Keyboard
- Native: Tab reaches the selected radio, or the first when none is selected. Arrow keys move and select, wrapping. Space selects.

## Accessibility
- The `fieldset` and `legend` name the group; each `label` names its radio. The browser reports "radio, 1 of 3, selected".
- State shows by the check as well as color. The row is a 44px target.

## Motion
- The check pops in 420ms (`dur-medium-3`): keyframed overshoot to 1.08, segments on `motion-enter` then `motion-fade`. Reduced motion: it appears at once.

## Flutter
- Reuse RadioRow (`components/selection_row.dart`). Wrap the group in Semantics with `inMutuallyExclusiveGroup`.
- Reads `border-control` [`controlOutline`], `accent-fill`, `on-accent`, `surface-hover` [`rowHover`] and `text-primary` [`label`].

## Do
- Use for 2 to 5 mutually exclusive options.
- Name the group with a visible legend.

## Don't
- Don't use for more than five options (use Select).
- Don't change the other options' text when one is chosen.

## Placement
Left of its label in a ListRow or a form, stacked with the 44px rows touching.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.check::before,.radio::before`: inset -10px (touch hit area)

## Tokens used
`border-focus`, `accent`, `size-check`, `on-accent`, `border-ring-strong`, `border-control`, `dur-short-2`, `motion-fade`, `dur-short-3`, `motion-move`, `radius-full`, `accent-fill`, `dur-medium-3`, `motion-enter`, `surface-hover`, `accent-fill-hover`, `opacity-disabled`, `space-12`, `size-target-touch`, `type-web-row-title-settings`, `tracking-web-row-title-settings`, `space-4`, `type-web-field-label`, `tracking-web-field-label`, `text-secondary`, `type-web-title-sm`, `tracking-web-title-sm`, `type-web-small`, `tracking-web-small`

## Status
Approved (from the boards); changed in 2.0: ring `border-control`; disabled opacity .4. Changed in 3.0: native input (ruling 6); keyframed pop (R2-O13).
