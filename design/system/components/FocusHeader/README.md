FocusHeader is the slim top bar in focus mode. It holds Close, the place in the quiz, and Report.

## When to use
- Use it at the top of a quiz, mock exam or assessment, where the sidebar and tab bar are hidden.
- Don't use it on normal pages (use PageHeader). Don't use it for the answer controls (those live in the FloatingBar).

## Anatomy
- Desktop `.focus-head`: minimum height 64 (`layout-focus-head`), padding 0 by 20 (`space-20`), gap `space-10`.
- Left: Close, a 44px IconButton (`size-icon-btn`). Right: Report, a 44px IconButton.
- Title `.focus-head__title`: 14/400, `text-secondary`, centered, flexible width, one line with an ellipsis (ruling 7), for example "Mathematics · 4 of 10". The full text is also the document title.
- There is no separate phone class: the one-markup header draws the phone header under 600 (R4R-O01).
- Phone center: an optional Timer (`.timer`).
- Source: the `.fhead` rule and the phone focus boards. The Report icon (a speech bubble) is a chosen value; see Decisions.
- Slots (ruling 7), in DOM order: Close (IconButton, left), the title (center, flexible), the clock (`.timer.timer--inline`, after the title), then the actions (Report and at most one more IconButton, at the right end). Only the title shrinks.
- One markup from 320 to 1440 (ruling 7): under `layout-focus-head-narrow` (24rem of header width; 384px at default text, sooner at large text) the clock drops its bar and keeps the time. Under 600 the header is the phone header (R4R-O01): 44px high at default text (`layout-focus-head-phone`, 2.75rem, as the approved phone boards draw it), growing only with text, sides 4 and 8; the phone question list sheet and its scrim start under it. From 600 up it is 64 (`layout-focus-head`). Measured: at 320 and 200% text Close, the time and Report stay on screen.

## Variants and props
- `.focus-head` at every width (64 from 600 up, 44 on phones at default text).
- The consumer provides the Close and Report handlers, the title text (desktop) and the Timer (phone, optional).
- The quiz flag never moves into FocusHeader; under 400px it goes to the question header (PageHeader `page-head--question`).
- Close stays at the left of the content column. In a mock the header sits inside `.qpanel-shift`, so the question list never covers Close or the clock (ruling 5).
- The mock clock in the header is `.timer.timer--inline` (time and bar on one line), so it centers on the 64px header like the title (usage gap 12).
- Icon-only buttons (Close, Report) show a Tooltip with their name and shortcut with a fine pointer (R3-O10).

## Markup
The mock header: Close, title, clock, actions (ruling 7).

```html
<header class="focus-head">
  <button type="button" class="icon-btn" aria-label="Close the mock exam">
    <svg aria-hidden="true">...</svg>
  </button>
  <div class="focus-head__title">UPCAT Mock Exam · Mathematics</div>
  <div class="timer timer--inline">
    <span class="timer__time" role="timer" aria-label="Time left">1:12:40</span>
    <div class="pbar" aria-hidden="true">
      <i style="--value:81"></i>
    </div>
  </div>
  <button type="button" class="icon-btn" aria-label="Report a problem">
    <svg aria-hidden="true">...</svg>
  </button>
</header>
```

## States
- Each button follows IconButton: hover tint (8% of `currentColor`), pressed scale 0.97, keyboard focus 2px `accent` ring offset 2px, disabled `text-disabled`.
- Rest color is `text-secondary`; hover is `text-primary`.
- The title has no states. A long title truncates with an ellipsis, so the header keeps its height and the buttons never move.

## Keyboard
- Tab goes to Close, then Report. Enter or Space activates.
- The title takes no focus. The page may bind Esc to Close and show that in a tooltip.

## Accessibility
- Both buttons are icon-only. Give each an `aria-label`: "Close quiz" and "Report a problem".
- The question stem is the page `h1`. The title is plain text, not a heading.
- The Timer keeps its own `role="timer"` and stays silent; announce the five-minute warning once in a status line.
- Touch targets are 44px on both sizes.

## Motion
- None.

## Flutter
- Desktop: WebTopBar. Phone and centered layouts with a timer: WebCenteredTopBar.
- Reads `text-secondary`, `text-primary`, `text-disabled` and `accent`. Use WebTokens for the 64 and 20 values.
- One header widget for every width: a `Row` with the title in `Expanded` (`maxLines: 1`, `TextOverflow.ellipsis`); the inline timer hides its bar when the header is under 24rem times the text scale.

## Do
- Keep Close at the left on every screen size.
- Put the progress in the title, as text.
- Confirm in a Dialog before Close if leaving would lose answers.

## Don't
- Don't add a back link or a menu. Focus mode has one way out: Close.
- Don't tint the bar or add a divider under it.
- Don't make Close red. Leaving is not destructive.

## Placement
Top of the focus page, above the stage. It scrolls with the page or stays fixed; the page decides. It does not sit over the question column.

## Tokens used
`space-10`, `layout-focus-head`, `space-20`, `type-web-row-sub`, `tracking-web-row-sub`, `text-secondary`, `space-6`, `space-8`, `space-4`, `layout-focus-head-phone`

## Status
Draft (new in 2.0). Source: the `.fhead` rule and the phone focus boards. The Report icon is a chosen value; see Decisions. Changed in 3.1: Close in the content column (ruling 5); inline timer; tooltips. Changed in 3.2: one markup from 320 to 1440, the clock slot, the title truncates (ruling 7); 44px on phones and `.focus-head--phone` deprecated (R4R-O01).

