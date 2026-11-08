Checkbox selects zero or more items, or part of a group (mixed).

## When to use
- Use it for options that apply when the learner submits: which subjects to include, consent.
- Don't use it for a setting that applies at once (use Switch). Don't use it for one choice among several (use Radio).

## Anatomy
- 24px square (`size-check`), radius `radius-sm` (8).
- Unchecked: 1.5px `border-control` ring. Checked: `accent-fill` with a 14px `on-accent` check (stroke 3.2), no ring. Mixed: same fill with a dash. The mark is a mask in `currentColor`, drawn by the class.
- The `.choice` row (a `label`) holds the input and its label text (16px, `web-row-title-settings`). The row is the 44px target.
- A group is a `fieldset.choice-group` with a `legend` (13/600, `web-field-label`, `text-secondary`).

## Variants and props
- Built on a native input: `<label class="choice"><input type="checkbox" class="check" name value><span class="choice__label">Label</span></label>`. CHANGE (ruling 6): it was a `button` with `role="checkbox"`, which a plain form cannot submit.
- Mixed is the input's `indeterminate` property, set in script (no HTML attribute exists). `.is-mixed` forces it in previews.
- Never use a generic label such as "Option". The consumer provides the labels, names, values and the handler.
- Grouped checkboxes (ruling 5, Custom Quiz CZ boards, more than eight topics): `.choice-tree` per subject holds a parent `label.choice.choice--parent` (label `web-title-sm`) and `.choice-tree__children` (`role="group"`, labelled by the parent), indented by the checkbox width plus 12px. An optional count `.choice__meta` ("2 of 4") sits at the right end of the parent. An optional Select All row `label.choice.choice--all` above the subjects, over a hairline. Subjects are separated by hairlines.
- Parent state: checked when every child is checked, unchecked when none is, mixed otherwise. The app sets `input.indeterminate = true` for mixed (previews use `.is-mixed`); checking a mixed or unchecked parent checks every child, unchecking clears them.

## Markup
One subject of the grouped checkboxes (ruling 5); a single checkbox is one `label.choice`.

```html
<div class="choice-tree">
  <label class="choice choice--parent" id="ct-m">
    <input type="checkbox" class="check" aria-controls="ct-m0 ct-m1 ct-m2 ct-m3">
    <span class="choice__label">Mathematics</span>
    <span class="choice__meta">2 of 4</span>
  </label>
  <div class="choice-tree__children" role="group" aria-labelledby="ct-m">
    <label class="choice">
      <input type="checkbox" class="check" id="ct-m0" checked>
      <span class="choice__label">Fractions</span>
    </label>
    <label class="choice">
      <input type="checkbox" class="check" id="ct-m1" checked>
      <span class="choice__label">Percent</span>
    </label>
    <!-- 1 more -->
    <label class="choice">
      <input type="checkbox" class="check" id="ct-m3">
      <span class="choice__label">Algebra Basics</span>
    </label>
  </div>
</div>
```

## States
- Hover: `surface-hover` well. Checked hover: `accent-fill-hover`. Pressed: scale 0.94.
- Keyboard focus: 2px `accent` outline, offset 2. Disabled (`disabled`): `opacity-disabled` (0.4). No hover and no press.

## Keyboard
- Tab focuses a checkbox. Space toggles it (native). Enter submits the form, as browsers do.
- Grouped checkboxes: Tab moves through Select All, each parent and each child in order; Space toggles. No arrow-key model.

## Accessibility
- The native input reports checked, not checked and mixed. The `label` names it; the `legend` names the group.
- State shows by the check and the dash as well as color. The row is a 44px target, with a padded hit area on the control.
- A parent checkbox names its group ("Mathematics, 2 of 4 selected") and sets `aria-controls` to its children's ids; the native mixed state is announced as "mixed".

## Motion
- The check pops in 420ms (`dur-medium-3`): scale .4 to 1.08 at 60% to 1, each segment on a curve without overshoot (`motion-enter`, then `motion-fade`). Reduced motion: it appears at once.

## Flutter
- Reuse CheckboxRow (`components/selection_row.dart`), including its tristate (mixed) value.
- Reads `border-control` [`controlOutline`], `accent-fill`, `on-accent`, `surface-hover` [`rowHover`] and `text-primary` [`label`]. Use radius 8.
- Grouped checkboxes: a parent `Checkbox(tristate: true)` per group with the child rows indented by the checkbox width plus 12.

## Do
- Put the label to the right and make the whole row clickable (the `label` does it).
- Use the mixed state for a parent with some children checked.

## Don't
- Don't use a checkbox for a setting that applies at once (use Switch).
- Don't label it "Option".

## Placement
Left of its label, in a ListRow or a form. A parent with children shows the mixed state.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.check::before,.radio::before`: inset -10px (touch hit area)

## Tokens used
`border-focus`, `accent`, `size-check`, `on-accent`, `border-ring-strong`, `border-control`, `dur-short-2`, `motion-fade`, `dur-short-3`, `motion-move`, `radius-sm`, `accent-fill`, `dur-medium-3`, `motion-enter`, `surface-hover`, `accent-fill-hover`, `opacity-disabled`, `space-12`, `size-target-touch`, `type-web-row-title-settings`, `tracking-web-row-title-settings`, `space-4`, `type-web-field-label`, `tracking-web-field-label`, `text-secondary`, `type-web-title-sm`, `tracking-web-title-sm`, `type-web-small`, `tracking-web-small`

## Status
Approved (from the boards); changed in 2.0: radius 7 to 8; ring `border-control`; disabled opacity .4. Changed in 3.0: native input (ruling 6); keyframed pop without an overshooting curve (R2-O13). Changed in 3.2: grouped checkboxes with a mixed parent and Select All (ruling 5).

