ReaderTopBar is the pinned top bar of the lesson reader: back, "n of N" with the lesson title, the lesson contents button and a progress thread.

## When to use
- Use it on every lesson screen (RD boards), wide and phone.
- Don't put the topic in it (HANDOFF: "n of N" plus the lesson title only). Don't use it in focus mode (use FocusHeader).

## Anatomy
- `.reader-bar`: sticky at the top, `z-nav`, `bg-page`, three columns (44, flexible, 44), 64px high (`layout-focus-head`) with 20px sides; `.reader-bar--phone` 44px high (`size-target-touch`) with the phone nav padding.
- Back: an IconButton (chevron left), named "Back to Study". Contents: an IconButton that opens the lesson outline (Popover menu).
- Title `.reader-bar__title`: `.reader-bar__count` "3 of 12" in `web-small` (13/400) `text-secondary`, tabular; `.reader-bar__lesson` in `web-label` (14/600) `text-primary`, one line with an ellipsis (board `.n` 13 and `.lt` 14/600; usage gap 2).
- Thread `.reader-bar__thread`: 3px (`size-thread`) under the bar across its width, `fill` track and `accent` progress from `--value` (0 to 100). It stays at the top edge of the window while the bar is hidden.

## Variants and props
- States the app sets from the scroll position (ruling 2): `.is-titled` after `layout-reader-title-scroll` (90px), `.is-hidden` after `layout-reader-hide-scroll` (120px) more, cleared by the first scroll up; the bar can hide only below that line.
- `--value` on the thread's `i` (the share of the lesson read).
- The consumer provides the count, the lesson title, the back target and the outline.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<header class="reader-bar">
  <a class="icon-btn" href="#" aria-label="Back to Study">
    <svg aria-hidden="true">...</svg>
  </a>
  <div class="reader-bar__title">
    <span class="reader-bar__count">3 of 12</span>
    <span class="reader-bar__lesson" aria-hidden="true">Adding Fractions with Unlike Denominators</span>
  </div>
  <button type="button" class="icon-btn" aria-label="In this lesson" aria-haspopup="menu">
    <svg aria-hidden="true">...</svg>
  </button>
  <div class="reader-bar__thread" role="progressbar" aria-label="Lesson progress" aria-valuemin="0" aria-valuemax="100" aria-valuenow="3">
    <i style="--value:3"></i>
  </div>
</header>
```

## States
- At the top: count only. Titled: the title faded in. Hidden: the bar above the window, thread visible. Back and contents buttons have IconButton hover, pressed and focus states.

## Keyboard
- Tab: back, contents. Focus inside the bar clears `.is-hidden` (the app shows the bar while it holds focus).

## Accessibility
- The bar is a `header`; the lesson `h1` stays in the article. The title in the bar repeats it, so it is `aria-hidden`; the count is read.
- The thread is `role="progressbar"` with a name and `aria-valuenow`.
- Hiding the bar never hides focus: the bar returns while any of its controls has focus.

## Motion
- Title: opacity and a 6px rise over `dur-medium-1` (`motion-move`). Bar: slides up its own height over `dur-medium-2` (`motion-move`). Thread width: `dur-medium-1`. The board's curve (.4,0,.2,1) has no token; `motion-move` is used (D125).
- Reduced motion: the states switch at once (no translate, no fade).

## Flutter
- `reader_bar.dart`: a `SliverPersistentHeader` (pinned) driven by the scroll offset; the title opacity and the bar offset follow the same 90 and 120 thresholds (`layout-reader-title-scroll`, `layout-reader-hide-scroll`).
- Reads `bg-page`, `text-primary`, `text-secondary`, `accent`, `fill`, `web-label`, `web-small`, `size-thread`, `layout-focus-head`, `dur-medium-1`, `dur-medium-2`, `motion-move`.

## Do
- Keep the title to the lesson title. Keep the thread visible while the bar hides.

## Don't
- Don't hide the bar near the top of the lesson. Don't animate it under reduced motion.

## Placement
First child of `.reader`, above `.reader__col`.

## Tokens used
`z-nav`, `size-icon-btn`, `space-8`, `layout-focus-head`, `space-20`, `bg-page`, `dur-medium-2`, `motion-move`, `size-target-touch`, `space-6`, `space-4`, `type-web-small`, `tracking-web-small`, `text-secondary`, `type-web-label`, `tracking-web-label`, `text-primary`, `dur-medium-1`, `size-thread`, `fill`, `accent`

## Status
Draft (new in 3.1, ruling 2). Source: HANDOFF reader top bar, RD_FocusMotion, web-canvas `.lp` (`.lt` 14/600, `.n` 13). New tokens: `size-thread`, `layout-reader-title-scroll`, `layout-reader-hide-scroll`.
