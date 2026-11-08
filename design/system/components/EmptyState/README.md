EmptyState explains why a list is empty and offers the next step.

## When to use
- Use it where a list or a page would be, when there is nothing to show yet.
- Don't use it for a failed load (use ErrorState). Don't use it for a load in progress (use Skeleton).

## Anatomy
- `.state` is a centered column. Icon 40px, stroke 1.6, `icon-muted`. Title in `web-h3` or `phone-title-3`.
- Under the title: one short line in `text-secondary`, at most 360px wide. Then at most one action.
- Padding 56px 24px by default. Full-page empties add more space; the page decides.
- Gap 12. The action sits 8px lower.

## Variants and props
- One action: a Button inside `.state`. Two actions: a `.btn-row` (centered inside `.state`), secondary first, main last.
- Phone: `phone-title-3` and `phone-callout` type.
- The consumer provides the icon, the title, the line and the action.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="state">
  <svg class="state__icon" aria-hidden="true">...</svg>
  <h3 class="web-h3 state__title">No bookmarks yet</h3>
  <p class="web-sub state__text">Tap the flag on a question to keep it here.</p>
  <button type="button" class="btn btn--secondary">Browse Questions</button>
</div>
```

## States
- One state only. The action takes the Button states.

## Keyboard
- The action is a normal Button: Tab reaches it, Enter and Space activate it.

## Accessibility
- The title is a heading at the level of the page. The icon is `aria-hidden`.
- Never use red. An empty list is not an error.
- The action is 44px high.

## Motion
- None.

## Flutter
- Reuse StateView (`components/state_view.dart`) for empty and error states.
- Reads `icon-chevron` [`chevron`] (the muted icon), `text-primary` [`label`], `text-secondary` [`secondaryLabel`].

## Do
- Say what will appear and how it gets there, in one sentence.
- Center the single action. Centered layouts center their action.

## Don't
- Don't put the icon on a tinted tile.
- Don't use red.

## Placement
Fills the area where the list would be, inside its Card or the page column.
- The one action keeps its natural width on every tier, the phone included: it is centered under the text, not the screen's bottom action (usage gap 4).

## Tokens used
`space-12`, `space-56`, `space-24`, `icon-muted`, `text-secondary`, `space-8`, `space-40`

## Status
Approved (from the boards); changed in 2.0: shared `.state` layout; centered button row; wording only. Changed in 3.2: the action keeps its natural width on the phone (usage gap 4).

