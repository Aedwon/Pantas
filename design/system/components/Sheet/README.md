Sheet is the phone's panel from the bottom. It holds pickers, filters and short forms.

## When to use
- Use it on the phone for a picker, a filter or a short form.
- On wide screens use Drawer or Dialog. Don't use a sheet to confirm a destructive action. Use a centered Dialog.
- Don't use it for a message that needs no answer. Use Toast.

## Anatomy
- Surface `surface-modal`, top radius `radius-lg` 14, `elev-sheet`. Padding 8px 20px, gap 16.
- Bottom padding is `max(34px, safe area + 20px)`, so the buttons clear the home indicator.
- Grabber 36x5, `radius-full`, `divider-strong`. Title 20/700.
- Body scrolls (`.sheet__body`). The actions stay visible: stacked 52px buttons, main on top, secondary under, 8px apart.
- Maximum height is the viewport minus the top safe area minus 32px.
- Landscape: when the height is 500px or less the sheet is centered and at most 560px wide.
- The scrim (`scrim scrim--sheet`, no padding) is `z-overlay` 40. The sheet is `z-modal` 50.
- CHANGE: top radius is 14 (`radius-lg`). The canvas drew 22.
- CHANGE: a Close or Cancel button is required as the keyboard alternative to dragging.
- Surface `surface-modal`: the card in light, one step up (#2A2A2A) in dark (usage gap 24).
- One scrim recipe (R4-O03): the scrim is a real element that fades over `dur-switch`, closes on a tap and locks the page scroll (Drawer).

## Variants and props
- `role="dialog"` with `aria-modal="true"`, `aria-labelledby` the title id. Add `aria-describedby` when there is body text.
- A picker body is a `role="radiogroup"` of rows with `role="radio"` and `aria-checked`. The chosen row shows a check.
- Buttons: `btn--phone btn--primary` then `btn--phone btn--tertiary`.
- The consumer provides the title, the body and the buttons.
- Hover and press inside the sheet use `surface-modal-hover` (R3-O02), so Sort by and the exam picker rows show feedback in dark. Action pairs wrap main first at large text (R3-A12).
- `.sheet--reader` (ruling 11, R4-O01): a sheet that shows lesson content (the phone passage, "Show Passage") keeps the lesson text scale; every other sheet resets it to 1. The app copies `--reader-scale` from the page onto the sheet, because the sheet mounts outside `.focus`.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="sheet" role="dialog" aria-modal="true" aria-labelledby="sh-a-t">
  <div class="sheet__grab" aria-hidden="true"></div>
  <h2 class="sheet__title" id="sh-a-t">Sort by</h2>
  <div class="sheet__body">
    <div class="group" role="radiogroup" aria-labelledby="sh-a-t">
      <button class="row row--phone" type="button" role="radio" aria-checked="true">
        <div class="row__in">
          <div class="row__t">
            <span class="row__title">Weakest first</span>
          </div>
          <svg class="popover__check" aria-hidden="true">...</svg>
        </div>
      </button>
      <button class="row row--phone" type="button" role="radio" aria-checked="false">
        <div class="row__in">
          <div class="row__t">
            <span class="row__title">Strongest first</span>
          </div>
        </div>
      </button>
      <button class="row row--phone" type="button" role="radio" aria-checked="false">
        <div class="row__in">
          <div class="row__t">
            <span class="row__title">A to Z</span>
          </div>
        </div>
      </button>
    </div>
  </div>
  <div class="sheet__actions">
    <button type="button" class="btn btn--primary btn--phone">Apply</button>
    <button type="button" class="btn btn--tertiary btn--phone">Cancel</button>
  </div>
</div>
```

## States
- Open: the sheet sits at the bottom edge over the scrim. The page behind is inert.
- Exiting: add `.is-exiting`, wait for the animation, then unmount.
- Initial focus: the first field, or the main action. For a destructive confirm the safe action (but use a Dialog for those).
- Drag: dragging the grabber down closes it. Drag is a bonus; the Cancel button is the keyboard route.

## Keyboard
- Tab and Shift+Tab stay inside and wrap. Esc closes it. A scrim tap closes it.
- On close, focus returns to the control that opened it. Arrow keys move inside a radiogroup.

## Accessibility
- Set `role="dialog"`, `aria-modal="true"`, `aria-labelledby` and (if used) `aria-describedby`.
- The page behind is inert and the scrim locks page scroll. The grabber is decorative (`aria-hidden`).
- Rows and buttons are at least 44px high.
- The chosen row shows a check as well as `aria-checked`, so the choice is not color alone.

## Motion
- Opens in 450ms (`dur-long-1`), sliding up on `motion-slide`.
- Closes in 400ms (`dur-drawer-close`) on `motion-slide`.
- The scrim fades over 350ms (`dur-switch`) on `motion-fade`.
- Reduced motion: the sheet and scrim fade in place over 150ms with no slide.

## Flutter
- Reuse PantasSheet (`core/ui/components/pantas_sheet.dart`) for the surface, the grabber and the slide.
- Add a Cancel button to every sheet. Use GroupedSection for the radio rows.
- Reads `surface-modal` and `surface-modal-hover` for the sheet and its rows (R3-A10), `divider-strong`, `scrim` and `text-primary`. A reader sheet wraps its child in the lesson `TextScaler`.

## Do
- Hide the TabBar while a sheet with a footer button is open.
- Close on a drag down, a scrim tap, Esc and Cancel.
- Keep the actions visible while the body scrolls.

## Don't
- Don't use a sheet to confirm a destructive action. Use a centered Dialog.
- Don't ship a sheet without a Cancel or Close button.
- Don't put a fifth action in the stack.

## Placement
Anchored to the bottom edge, full width. Wide screens use Drawer or Dialog.

## Component internals
Literal spacing values this component keeps, with their source (R2-O08). Every other spacing value is a `space-*` or `layout-*` token.
- `.sheet`: padding 34px (phone board 8px 20px 34px)

## Tokens used
`dur-switch`, `motion-fade`, `surface-modal-hover`, `z-modal`, `space-16`, `space-8`, `space-20`, `radius-lg`, `surface-modal`, `elev-sheet`, `dur-long-1`, `motion-slide`, `dur-drawer-close`, `radius-full`, `divider-strong`, `type-phone-title-3`, `tracking-phone-title-3`, `space-12`, `dur-short-2`

## Status
Approved (from the boards); changed in 2.0: top radius 14, required Cancel button, one modal contract, safe-area padding, landscape rule, motion on `motion-slide`. Changed in 3.0: dark surface `surface-modal`. Changed in 3.1: modal hover well; reads `surface-modal` (R3-O02, R3-A10). Changed in 3.2: surface `surface-modal` in every line (R3-A10); `.sheet--reader` keeps the lesson scale (ruling 11).

