Dialog asks one question over a scrim and offers at most two buttons.

## When to use
- Use it to confirm a choice, to confirm a destructive action, or to show a short block that needs a decision.
- Destructive confirmations always use a centered Dialog, never a Sheet.
- Don't use it for a list or a form with many fields. Use Drawer on wide screens and Sheet on the phone.
- Don't use it for a message that needs no answer. Use Toast or Notice.

## Anatomy
- Surface `surface-modal` (the card in light, #2A2A2A in dark so the dialog separates from the dimmed cards; usage gap 24), radius `radius-2xl` 22, padding 24, gap 16, `elev-modal`. CHANGE: padding 26 to 24 and gap 18 to 16 (public spacing scale, R2-O08). Width 440 (`layout-modal`), wide 560 (`dialog--wide`, `layout-modal-wide`). Maximum width is the viewport minus 48px.
- Maximum height is the viewport height minus the safe areas minus 32px. The body (`dialog__body`) scrolls and the actions stay visible.
- Title 20/700, letter spacing -0.012em. Body 16 in `text-secondary`. Actions at the right, 8px apart, wrapping if needed.
- Which class (D189): on a phone, under 600 wide, the app mounts `dialog--phone` with the `btn--dialog` pill pair, as the phone boards draw it; the dialog mounts outside the page root, so the app picks the class at the 600 tier, even for a page built once for every width. A plain `.dialog` under 600 is a fallback only: the same layout with `btn--sm` rounded rectangles in equal halves that wrap with the main action on top. Wide screens (600 and up) use the plain `.dialog` with `btn--sm`.
- Phone (`dialog--phone`): inset 24px, padding 20px 20px 18px, gap 8, title `phone-title-3` (20/700), body `phone-explanation` (15). CHANGE: top padding 22 to 20 (R2-O08). Two 46px pill buttons (`radius-full`, D187) side by side, 10px apart, 12px above.
- The scrim is `scrim` (`z-overlay` 40) and the dialog is `z-modal` 50.
- CHANGE: the scrim fade is 300ms linear, as in the phone code (was 150ms).
- One scrim recipe (R4-O03): every modal owns a real scrim element (never a shadow), so a click closes it and the page scroll locks; Drawer and Sheet fade theirs over `dur-switch`, the Dialog keeps its 300ms linear fade.
- The Dialog resets the lesson text scale to 1 (ruling 11).

## Variants and props
- `role="dialog"` for a normal question and `role="alertdialog"` for a destructive one. Both carry `aria-modal="true"`.
- `aria-labelledby` names the title id. `aria-describedby` names the body id.
- Wide screens: Cancel (tertiary `btn--sm`) then the main button (primary `btn--sm`). Destructive: the safe button first, `btn--primary btn--critical` last.
- Phone pair: `btn--dialog btn--neutral` plus `btn--dialog btn--primary` (or `btn--primary btn--critical` for a destructive confirm). The pair replaces the old inline gray override.
- A non-destructive confirm such as Sign Out uses a primary button.
- The consumer provides the title, the body, the buttons, and the element that opened it.
- Width (R3-A12): 440 (`layout-modal`) but never wider than the window minus 24px a side, subtracted once (272 at 320, 342 at 390).
- Large text: a pair that no longer fits wraps; on the phone the main action goes on top and each button takes the full width (`flex-wrap: wrap-reverse`, basis 7.5em, so the halves stay equal until then); on wide screens secondary then main. `.dialog__actions--stack` forces the stacked column (usage gap 32).
- Hover inside a dialog uses `surface-modal-hover` (R3-O02): in dark the row well equals the dialog surface otherwise.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="dialog" role="dialog" aria-modal="true" aria-labelledby="dg-a-t" aria-describedby="dg-a-b">
  <h2 class="dialog__title" id="dg-a-t">Sign out?</h2>
  <div class="dialog__body" id="dg-a-b">You can sign back in at any time. Your progre...</div>
  <div class="dialog__actions">
    <button type="button" class="btn btn--tertiary btn--sm">Cancel</button>
    <button type="button" class="btn btn--primary btn--sm">Sign Out</button>
  </div>
</div>
```

## States
- Open: the dialog sits centered over the scrim. The page behind is inert.
- Exiting: add `.is-exiting` to the scrim and the dialog, wait for the animation, then unmount.
- Initial focus: the safe action (Cancel, Keep It) for a destructive confirm. Otherwise the first field, or the main action.
- Busy: the main button shows the spinner and verb. Keep the dialog open until the result.
- Scroll: when the content is long the body scrolls. Give a scrolling body `tabindex="0"`.

## Keyboard
- Tab and Shift+Tab stay inside the dialog and wrap from the last control to the first.
- Esc closes the dialog. A scrim click closes it too, except for an alertdialog.
- On close, focus returns to the control that opened it.
- Enter activates the focused button. Do not bind Enter to the main action while a safe button is focused.

## Accessibility
- Set `role`, `aria-modal`, `aria-labelledby` and `aria-describedby` as listed above.
- The page behind is `inert`. The scrim is fixed to the viewport and locks page scroll.
- A visible close control always exists: the Cancel button, or a Close button on a one-action dialog.
- Buttons are 46px on the phone (`dialog--phone`) and 42px elsewhere with a padded 44px hit area on touch.
- Respect text scaling: the surface uses `max-height` and the body scrolls. Button labels may wrap.

## Motion
- Opens in 420ms (`dur-medium-3`): rises 24px and fades in on `motion-house`.
- Closes in 320ms (`dur-medium-2`) on `motion-house`.
- The scrim fades in and out over 300ms (`dur-flip`), linear.
- Reduced motion: both fade in place over 150ms with no rise.

## Flutter
- Use CenteredDialog (`core/ui/components/centered_dialog.dart`) and ButtonPair for the actions. Build a long body as a scrollable child. ButtonPair wraps to a column with the main action first when the labels do not fit.
- Show the dialog with a barrier fade of 300ms. Use a `RoundedRectangleBorder` from `radius-2xl`.
- Reads `surface-modal` [`surface`], `surface-modal-hover`, `text-primary`, `text-secondary`, `scrim`, `danger-fill` [`destructive`], `on-danger`, `elev-modal`, `layout-modal`.

## Do
- Put the secondary action first and the main action last (rightmost).
- In a destructive dialog, put the safe choice first and the red button last.
- Return focus to the trigger on close.

## Don't
- Don't stack three buttons.
- Don't use a pill on the wide dialog. Only the phone pair is a pill (D187); wide buttons are rounded rectangles.
- Don't close an alertdialog on a scrim click.

## Placement
Centered over the scrim, `z-modal` above `z-overlay`. Confirm destructive actions in a dialog, never in a sheet.

## Tokens used
`space-16`, `scrim`, `z-overlay`, `dur-flip`, `z-modal`, `layout-modal`, `space-24`, `radius-2xl`, `surface-modal`, `text-primary`, `elev-modal`, `dur-medium-3`, `motion-house`, `dur-medium-2`, `layout-modal-wide`, `type-web-h3`, `tracking-web-h3`, `type-web-body`, `tracking-web-body`, `text-secondary`, `space-8`, `space-20`, `space-18`, `type-phone-title-3`, `tracking-phone-title-3`, `type-phone-explanation`, `tracking-phone-explanation`, `space-10`, `space-12`, `surface-modal-hover`, `dur-short-2`, `size-btn-bar`, `radius-full`, `size-btn-sm`, `radius-md`

## Status
Approved (from the boards); changed in 2.0: one modal contract, long-form scrolling body, scrim fade 300ms linear, renamed motion tokens, phone pair uses `btn--neutral`. Changed in 3.0: padding 24 and gap 16 (R2-O08); dark surface `surface-modal`. Changed in 3.1: width once, large-text pairs, modal hover well, Flutter reads `surface-modal` (R3-A12, R3-O02, R3-A10). Changed in 3.2: one scrim recipe stated (R4-O03). Changed in 3.3.1: the phone pair is a pill again (D187). Changed in 3.4.0: which dialog class a page under 600 uses is stated (D189).

