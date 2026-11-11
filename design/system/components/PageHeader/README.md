PageHeader opens a page: an optional back link, the title, and an optional lead line, then 28px of space to the content.

## When to use
- Use it at the top of every page, once.
- On a question screen the question stem is the page `h1`. Style it `web-question` (or `phone-question`). Don't add a second header.
- Don't center the title on desktop.

## Anatomy
- Root page `page-head--root`: a date line (`web-sub`) above the `web-h1` title, both in `.page-head__text`. A trailing slot `.page-head__trail` holds the WeekStrip. The row wraps on narrow space. Gap 20px.
- Sub-page: BackLink, 6px gap, `web-h1` title, optional `web-lead` line.
- Pane `page-head--pane` (Settings detail): a line icon in `accent` (`.page-head__icon`), a `web-h2` title and one `web-sub` line. Gap 14px, space below 24px.
- Results: the title and Done (primary large) share `.page-head__title-row`, centered on one line, so Done sits level with the title; the lead goes under it (usage gap 12).
- Phone `page-head--phone`: a 44px bar (`.page-head__bar`, the same recipe as `.phone-nav`, usage gap 18) with BackLink at the left and a text action at the right, then `phone-large-title` with padding 6px 4px 20px. At large text the large title steps down to `phone-title-2` (D180; see PhoneFrame).
- Gap to the content: 28px (`layout-section-gap`). CHANGE: was 26.
- Rule (ruling 9): a header inside a container that owns its gap (`.wrap`, `.stack`, the column wrappers, `.phone-screen`, `.qcol`) has no bottom margin. No wrapper is needed.

## Variants and props
- `page-head`, `page-head--root`, `page-head--pane`, `page-head--phone`.
- The consumer provides the title, the optional lead or date, the parent name for the back link, and the trailing content.
- `page-head--question` (quiz, mock): the overline (`page-head__overline`, subject) at the left and, on phones under 400px, the flag (`.fbar__flag-alt`) at the right end in `.page-head__trail`; the stem `h1` below (ruling 9).
- `.page-head__after`: a right-aligned line under the row (usage gap 20). Home no longer uses it: the WeekStrip legend is removed (D186).
- Mock question header (R3-O04, HANDOFF, MK question boards): at every width the trailing slot `.page-head__trail` at the right end of `.page-head__row` holds "Flag" with its F hint: `button.btn.btn--tertiary.btn--xs` (36 high, `size-btn-xs`, 14/600, flag icon 17, gap 8) with `aria-pressed` and the name "Flag question"; pressed is teal. The quiz keeps its flag in the bar (QS_Flag) and moves it here only under 400px.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="page-head page-head--root">
  <div class="page-head__row">
    <div class="page-head__text">
      <div class="web-sub">Thursday, October 6</div>
      <h1 class="web-h1 page-head__title">Good Morning</h1>
    </div>
    <div class="page-head__trail">
      <div class="week" role="group" aria-label="This week">
        <button type="button" class="wd is-done" aria-label="Monday, October 3, done">
          <small>Mon</small>
          <b>3</b>
          <i></i>
        </button>
        <button type="button" class="wd is-half" aria-label="Tuesday, October 4, partly done">
          <small>Tue</small>
          <b>4</b>
          <i></i>
        </button>
        <!-- 4 more -->
        <button type="button" class="wd" aria-label="Sunday, October 9">
          <small>Sun</small>
          <b>9</b>
          <i></i>
        </button>
      </div>
    </div>
  </div>
</div>
```

## States
- Rest is the only state. The header holds controls (back link, Done), and each control has its own states.
- Empty trailing slot: omit `.page-head__trail`. The title keeps its place.

## Keyboard
- Tab goes to the back link first, then the trailing controls. The title takes no focus.

## Accessibility
- Use one `h1` per page. Question screens use the stem as the `h1`.
- The WeekStrip in the trailing slot is a group with its own label and day names.
- The line icon in a pane header is decorative (`aria-hidden`).

## Motion
- None.

## Flutter
- Use PageScaffold with TabHeader for the root pages and AppNavBar with BackChevron for the phone bar.
- Reads `text-primary`, `text-secondary` and `accent`. Take the 28px gap from WebTokens.

## Do
- Use one `h1` per page.
- Keep the lead line to one short sentence.

## Don't
- Don't add a back link on a root page.
- Don't center the title on desktop.
- Don't add a second header on a question screen.

## Placement
Top of the content column, inside `layout-content-max`. Phone: top of the scroll view.

## Tokens used
`space-6`, `layout-section-gap`, `space-16`, `space-4`, `space-8`, `space-10`, `space-20`, `space-14`, `space-24`, `accent`

## Status
Approved (from the boards); changed in 2.0: gap to content 28 (was 26), root and pane variants, trailing slot, stem as the page `h1`. Changed in 3.0: question header with the flag slot; title row for results; after-row note; margin rule covers the phone and question containers. Changed in 3.1: the mock Flag at the top right of the question (R3-O04). Changed in 3.2: one flag slot, `.page-head__trail` (R4-O13). Changed in 3.3: no WeekStrip legend (D186); the phone large title steps down at large text (D180).
