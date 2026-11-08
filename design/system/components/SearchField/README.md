SearchField is the search input: a field with a leading magnifier and, on desktop, a Ctrl K hint.

## When to use
- Use it to search a list or the whole app.
- Don't use it for a general text answer (use Field).

## Anatomy
- Min height 38 (`size-search`), radius `radius-sm` (8), `surface-card`, padding 0 10 0 12. CHANGE: the radius was 10.
- Ring: 1px `border-control` (3:1). Magnifier 18px `icon-muted`. Text 15. Placeholder `text-secondary`.
- Phone (`search--phone`): min height 44, radius `radius-md` (12), text 17. A Cancel text button appears on focus.

## Variants and props
- Desktop with a KeyHint ("Ctrl K"), phone with Cancel.
- With a value, show a clear IconButton (`icon-btn--sm`, 32px, 44px hit area on touch).
- The consumer provides the search handler and the scope in the accessible name.

## States
- Hover: ring `text-secondary`. Focus: 2px `accent` ring. With a value: clear button.
- The desktop field is pointer-first: 38px is above the 32px pointer target. The phone field is 44px.

## Keyboard
- Ctrl K (Cmd K on Mac) focuses the field. Esc clears the value. Enter runs the search.

## Accessibility
- Wrap in `<form role="search">`. Give the input `type="search"` and an accessible name ("Search questions").
- The hint is hidden on touch screens and is `aria-hidden`.
- The clear button needs `aria-label`.

## Motion
- Ring color fades over `dur-short-2` on `motion-fade` on hover and focus. The clear button appears at once.
- Reduced motion: the same.

## Flutter
- Reuse SearchField (`components/search_field.dart`), including its `outlined` variant.
- Reads `surface-card` [`surface`], `border-control` [`controlOutline`], `accent`, `text-secondary` [`secondaryLabel`], `icon-chevron` [`chevron`] (the muted icon).

## Do
- Open it with Ctrl K (Cmd K on Mac) and show the hint only on desktop.
- Name the scope in the accessible name.

## Don't
- Don't hide the field behind an icon on desktop.
- Don't show the key hint on a touch screen.

## Placement
Under the wordmark in SidebarNav (pointer-only, 38px). At the top of lists on phone (44px).

## Tokens used
`space-8`, `size-search`, `space-10`, `space-12`, `radius-sm`, `surface-card`, `border-ring`, `border-control`, `text-secondary`, `type-web-sub`, `tracking-web-sub`, `dur-short-2`, `motion-fade`, `text-primary`, `icon-muted`, `border-ring-selected`, `accent`, `size-icon-btn`, `radius-md`, `type-phone-body`, `tracking-phone-body`, `size-target-touch`

## Status
Approved (from the boards); changed in 2.0: radius 10 to 8; ring `border-control`; placeholder `text-secondary`; search landmark; clear button.
