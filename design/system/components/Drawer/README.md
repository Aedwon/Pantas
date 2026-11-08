Drawer is a 440px panel that slides in from the right. It holds lists and side tasks while the page stays in view.

## When to use
- Use it on wide screens for a list or a short task: lessons, the explanation panel below 1134px.
- On the phone use Sheet. Don't use it for a quick yes or no (use Dialog).
- Don't open a second drawer from a drawer.

## Anatomy
- Surface `bg-page`, `elev-drawer`, full height, width 440 (`layout-drawer`), maximum width 100%. Bottom padding adds the safe area.
- Head: title 20/700 and a Close IconButton (40px), padding 16px 20px.
- Body: scrolls, padding 4px 20px 20px, gap 16.
- Foot: a 0.5px `divider` rule above, padding 16px 20px 20px. Actions sit at the bottom right at natural width.
- The scrim (`scrim scrim--sheet`) is `z-overlay` 40. The drawer is `z-modal` 50.
- Maximum height is the viewport minus the safe areas. The body scrolls and the foot stays visible.
- CHANGE: the boards drew a full-width 50px foot button. The system uses natural width, secondary first.
- One scrim recipe for every modal (R4-O03): a real `.scrim` element at `z-overlay` under the panel, fading over `dur-switch`, closing on click and locking the page scroll. The focus-mode panels use the same recipe (`.scrim--qpanel`, `.scrim--xpl`); none draws its scrim as a shadow.
- Lesson text scale (ruling 11): a Drawer never resets `--reader-scale`; when it shows lesson content (Show Passage on wide screens) the app copies the page's value onto it, because overlays mount outside `.focus`.

## Variants and props
- `role="dialog"` with `aria-modal="true"`, `aria-labelledby` the title id and `aria-describedby` the id of the first body line.
- `.scrim--contained` keeps it inside a frame in previews. `.drawer--contained` does the same without a scrim.
- The consumer provides the title, the body content, and the foot buttons.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<aside class="drawer" role="dialog" aria-modal="true" aria-labelledby="dr-a-t" aria-describedby="dr-a-d">
  <div class="drawer__head">
    <h2 class="drawer__title" id="dr-a-t">Lessons</h2>
    <button type="button" class="icon-btn icon-btn--md" aria-label="Close lessons">
      <svg aria-hidden="true">...</svg>
    </button>
  </div>
  <div class="drawer__body">
    <p class="web-sub" id="dr-a-d">Pick a lesson to continue.</p>
    <div class="card">
      <a class="row row--compact" href="#">
        <div class="row__in">
          <div class="row__t">
            <span class="row__title">Fractions, part 2</span>
          </div>
          <span class="row__v">15 min</span>
          <svg class="row__cv" aria-hidden="true">...</svg>
        </div>
      </a>
      <a class="row row--compact" href="#">
        <div class="row__in">
          <div class="row__t">
            <span class="row__title">Ratios</span>
          </div>
          <span class="row__v">12 min</span>
          <svg class="row__cv" aria-hidden="true">...</svg>
        </div>
      </a>
      <a class="row row--compact" href="#">
        <div class="row__in">
          <div class="row__t">
            <span class="row__title">Percent</span>
          </div>
          <span class="row__v">10 min</span>
          <svg class="row__cv" aria-hidden="true">...</svg>
        </div>
      </a>
    </div>
  </div>
  <div class="drawer__foot">
    <button type="button" class="btn btn--tertiary btn--sm">Later</button>
    <button type="button" class="btn btn--primary">Continue Lesson</button>
  </div>
</aside>
```

## States
- Open: the drawer sits at the right edge over the scrim. The page behind is inert.
- Exiting: add `.is-exiting`, wait for the animation, then unmount.
- Initial focus: the main action, or the first field. For a destructive confirm the safe action.
- Scroll: the body scrolls when the content is long. The head and foot stay.

## Keyboard
- Tab and Shift+Tab stay inside and wrap. Esc closes it. A scrim click closes it.
- On close, focus returns to the control that opened it.

## Accessibility
- Set `role="dialog"`, `aria-modal="true"`, `aria-labelledby` and `aria-describedby`.
- The page behind is `inert` and the scrim locks page scroll.
- The Close icon button has `aria-label="Close lessons"`. A visible close control always exists.
- Foot buttons are 44px high. The Close icon button is 40px with a padded 44px hit area on touch.

## Motion
- Opens in 450ms (`dur-long-1`) sliding from the right on `motion-slide`.
- Closes in 400ms (`dur-drawer-close`) on `motion-slide`.
- The scrim fades over 350ms (`dur-switch`) on `motion-fade`.
- Reduced motion: the drawer and scrim fade in place over 150ms with no slide.

## Flutter
- Build it with a Drawer or a showGeneralDialog route that slides from the right (450ms in, 400ms out, `motion-slide`).
- Reads `bg-page`, `divider` [`separator`], `scrim` and `text-primary`. Take 440 from WebTokens.

## Do
- Trap focus inside and return it on close.
- Put the main action last in the foot, at natural width.
- Keep the head and foot visible while the body scrolls.

## Don't
- Don't stretch the foot button to the full drawer width.
- Don't open a second drawer from a drawer.
- Don't use a drawer on the phone. Use Sheet.

## Placement
Right edge, above the scrim. Details are in patterns.md.

## Tokens used
`dur-switch`, `motion-fade`, `layout-drawer`, `bg-page`, `elev-drawer`, `z-modal`, `dur-long-1`, `motion-slide`, `dur-drawer-close`, `space-12`, `space-16`, `space-20`, `type-web-h3`, `tracking-web-h3`, `space-4`, `space-8`, `border-hairline`, `divider`, `layout-focus-head`, `layout-focus-head-phone`, `dur-short-2`

## Status
Approved (from the boards); changed in 2.0: one modal contract, natural-width foot action, slide curve `motion-slide`, scrim 350ms, inert page and focus return. Changed in 3.2: one scrim recipe; keeps the lesson scale (R4-O03, ruling 11).

