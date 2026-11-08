Switch turns one setting on or off immediately.

## When to use
- Use it for a setting that takes effect at once, such as study reminders or Keyboard Shortcuts.
- Don't use it for a choice that needs a Save button (use Checkbox or Radio). Don't use it for an action.

## Anatomy
- Track 51x31 (`size-switch-w`, `size-switch-h`), `radius-full`. Thumb 27px `switch-thumb` (`size-switch-thumb`), 2px inset, `elev-knob`, travel 20px.
- Off: `switch-off` fill plus a 1.5px `border-control` ring (3:1). On: `accent-fill`, no ring.
- It sits at the right end of a row, with its label at the left.

## Variants and props
- Built on a native input: `<input type="checkbox" role="switch" class="switch">`. CHANGE (ruling 6): it was a `button` with `aria-checked`. A plain form submits it; `checked` is the state.
- Name it with a `<label for>` (the row title), or `aria-label` when no visible label exists. Tie a row subtitle with `aria-describedby`.
- The consumer provides the label, the state and the change handler. The change applies at once.

## States
- Hover: off track `divider-strong`, on track `accent-fill-hover`. Pressed: thumb shrinks to 96%.
- Keyboard focus: 2px `accent` outline, offset 2.
- Disabled (`disabled`): `opacity-disabled` (0.4). No hover and no press.
- Previews force states with `.is-on`, `.is-hover`, `.is-active`, `.is-focus`.

## Keyboard
- Tab focuses the switch. Space toggles it (native behavior). Enter does not.

## Accessibility
- `role="switch"` on the checkbox makes screen readers say "switch, on" or "off". The checked state comes from the input.
- The thumb position as well as the color shows state, so it is never color alone.
- The hit area is padded to 44px high.

## Motion
- Track 250ms (`dur-fade`, `motion-fade`). Thumb 350ms (`dur-switch`, `motion-spring`): a transition, so the curve's overshoot is the only one.
- Reduced motion: the thumb keeps its final position and the track fades in 150ms.

## Flutter
- Reuse PantasSwitch (`components/pantas_switch.dart`): 51x31, 27px thumb, 44px hit area. Wrap it in `Semantics(toggled:)`.
- Reads `switch-off`, `border-control` (off ring), `accent-fill`, `switch-thumb` and `elev-knob`.

## Do
- Apply the change at once. Label the row with what turns on.
- Use a `<label for>` so a click on the row text toggles it.

## Don't
- Don't use it for an action that needs a confirm button.
- Don't rely on track color alone.

## Placement
Right end of a ListRow or a phone GroupedList row. Settings > Accessibility holds the Keyboard Shortcuts row (wide screens only).

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.switch::before`: inset -7px, inset -2px (touch hit area)

## Tokens used
`border-focus`, `accent`, `size-switch-w`, `size-switch-h`, `radius-full`, `switch-off`, `border-ring-strong`, `border-control`, `dur-fade`, `motion-fade`, `size-switch-thumb`, `switch-thumb`, `elev-knob`, `dur-switch`, `motion-spring`, `accent-fill`, `divider-strong`, `accent-fill-hover`, `opacity-disabled`

## Status
Approved (from the boards); changed in 2.0: off ring `border-control`; disabled opacity .4. Changed in 3.0: built on a native checkbox with `role="switch"` (ruling 6). Changed in 3.1: Flutter reads `elev-knob` (`PantasShadow.knob`, R3-A10).
