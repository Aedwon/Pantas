Notice tells the learner one thing that needs a decision or attention, and lets them dismiss it.

## When to use
- Use it for one message on a screen: a missing exam date, a trial that ends soon, a status such as offline or saving.
- Don't use it for the result of an action (use Toast). Don't use it to confirm a destructive action (use Dialog).

## Anatomy
- Surface `surface-card`, radius `radius-lg` (14), 1px `divider` ring. CHANGE: radius was 16.
- Head: min height 52, padding 0 6 0 18. Icon 20px, title `web-title-sm` (16/600), close IconButton (`icon-btn--md`, 40px, 44px hit area on touch).
- Body: text 15 `text-secondary` on its own line, then actions at the right end, secondary then main, gap 8.
- Phone (`notice--phone`): body text 13, 44px buttons side by side (`btn--notice`), secondary left and main right.

## Variants and props
- Default tone is info: icon in `accent`.
- `notice--success`: teal check icon. `notice--warning`: icon in `warning-text`.
- Red is never a notice tone. Data loss uses a neutral notice with an icon. A destructive confirmation is a Dialog.
- The consumer provides the icon, the title, the optional text, the optional actions and the dismiss rule.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<section class="notice" aria-labelledby="n1-t">
  <div class="notice__head">
    <span class="notice__icon">
      <svg aria-hidden="true">...</svg>
    </span>
    <span class="notice__title" id="n1-t">Add your exam date</span>
    <button type="button" class="icon-btn icon-btn--md" aria-label="Dismiss notice">
      <svg aria-hidden="true">...</svg>
    </button>
  </div>
  <div class="notice__body">
    <p class="notice__text">
      Pantas plans your weeks backward from the day...
    </p>
    <div class="notice__actions">
      <button type="button" class="btn btn--tertiary btn--sm">Later</button>
      <button type="button" class="btn btn--secondary btn--sm">Add Exam Date</button>
    </div>
  </div>
</section>
```

## States
- Rest, expanded (head, text, actions) and collapsed (head only).
- Dismissed: `.is-collapsing` shrinks the notice, then the page removes it.
- Buttons and the close control take their own hover, pressed and focus states.

## Keyboard
- Tab reaches the actions and the close button. Enter or Space activates them.
- After dismissal, move focus to the next sensible control, such as the restore link or the page heading.

## Accessibility
- Use `<section aria-labelledby>` with the title id. A status such as offline or saving also takes `role="status"`.
- The close button needs `aria-label` ("Dismiss notice").
- Tone is never color alone: each tone has its own icon and the title says what happened.
- Show one notice per screen. If several apply, show the highest priority: offline or saving first, then decisions, then tips.

## Motion
- Collapse shrinks max height and fades over 350ms (`dur-switch`, `motion-house`).
- Reduced motion: the notice disappears at once.
- The collapse starts from `--h` (the measured height, set by the app).

## Flutter
- Build it from NoticeStrip (`components/notice_strip.dart`). PausedQuizNotice uses the same pattern.
- Reads `surface-card` [`surface`], `divider` [`separator`], `accent`, `warning-text`, `text-primary` [`label`] and `text-secondary` [`secondaryLabel`].
- Take radius 14 from the shared shape constants.

## Do
- Show one notice per screen.
- Offer "Later" or a dismiss for good.
- Use simple words and one short sentence of body text.

## Don't
- Don't stack two notices.
- Don't use red. Data loss uses a neutral notice with an icon.
- Don't use a notice for the result of an action (use Toast).

## Placement
Top of the content column, under the PageHeader. Phone: under the week strip on Home.

## Tokens used
`surface-card`, `radius-lg`, `border-ring`, `divider`, `space-12`, `space-6`, `space-18`, `accent`, `warning-text`, `space-8`, `type-web-title-sm`, `tracking-web-title-sm`, `space-16`, `type-web-sub`, `tracking-web-sub`, `text-secondary`, `type-phone-footnote`, `tracking-phone-footnote`, `dur-switch`, `motion-house`

## Status
Approved (from the boards); changed in 2.0: radius 16 to 14; success and warning tones; red line removed; priority rule; semantics. Changed in 3.1: `--h` (R3-O12).
