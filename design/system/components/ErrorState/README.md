ErrorState says that loading failed and offers one way to retry.

## When to use
- Use it where content failed to load and a retry may work.
- Don't use it for an empty list (use EmptyState). Don't use it for a field the learner filled in wrong (use the Field error).

## Anatomy
- Same `.state` layout as EmptyState: icon 40px (`alert`, `icon-muted`), title, one line, one action.
- Try Again is a secondary (tonal) Button, 44px. On the phone it fills the width.
- The icon is neutral. Error never uses red.

## Variants and props
- Rest and busy. A centered pair of actions uses a centered `.btn-row`.
- The consumer provides the title, the line and the retry handler.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="state" role="alert">
  <svg class="state__icon" aria-hidden="true">...</svg>
  <h3 class="web-h3 state__title">We could not load this</h3>
  <p class="web-sub state__text">Check your connection and try again.</p>
  <button type="button" class="btn btn--secondary demo-retry">Try Again</button>
  <span class="sr-only" role="status"></span>
</div>
```

## States
- Rest: Try Again. Busy: spinner plus "Trying". The button keeps its rest width and ignores clicks.
- Done: the button returns to rest after the result. If the retry fails again, the state stays.

## Keyboard
- Tab reaches Try Again. Enter and Space activate it. Focus stays on the button while it is busy.

## Accessibility
- The container is `role="alert"`, so the message is announced when it appears.
- While busy, set `aria-busy="true"`, keep focus on the button and lock its width. Do not use the `disabled` attribute.
- Announce the verb and the result in a polite live region ("Trying again", "Could not load. Try again.").
- Never color alone. The icon, the title and the text say what happened.

## Motion
- None.

## Flutter
- Reuse StateView (`components/state_view.dart`). Its busy button is PantasButton with the busy flag.
- Reads `icon-chevron` [`chevron`], `text-primary` [`label`], `text-secondary` [`secondaryLabel`].

## Do
- Say what happened and what to do, in two short sentences at most.
- Keep the icon neutral.

## Don't
- Don't use red. Red is only for destructive actions and wrong answers.
- Don't show raw error codes.

## Placement
Replaces the content that failed to load, in the same card or column.

## Tokens used
`space-12`, `space-56`, `space-24`, `icon-muted`, `text-secondary`, `space-8`, `space-40`

## Status
Approved (from the boards); changed in 2.0: busy rules (width lock, live region, focus kept); centered button row.
