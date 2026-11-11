Cover is the documentation cover of the design system: the Pantas mark and wordmark over a field of tiles. It is not a product component.

## When to use
- Use it only as the first card of the design-system page.
- Don't use it in the app. The app's logo widget is `pantas_logo.dart`.

## Anatomy
- The mark: a mortarboard with a P and a tassel, drawn from `pantas_logo.dart` (paths and viewBox exactly). The tassel is `accent`; the rest is `text-primary`. The wordmark is Geist 700.
- The field: 64px tiles in a 72px pitch (7 columns, 4 rows), `surface-card` on `bg-page`.

## Variants and props
- None.

## States
- None.

## Keyboard
- None. The cover is decorative; the page title carries the name.

## Accessibility
- The mark has `role="img"` and the name "Pantas". The tile field is `aria-hidden`.

## Motion
- The tassel swings once on load (`.tassel-swing`, motion.md recipe table). Reduced motion: no swing.

## Flutter
- None: the app draws the mark with `pantas_logo.dart`. Reads `accent`, `text-primary`, `surface-card`, `bg-page`.

## Do
- Keep the mark's paths exactly as `pantas_logo.dart` draws them.

## Don't
- Don't recolor the tassel or reuse the cover in product screens.

## Placement
The first card of the design-system page.

## Status
Approved (documentation only). Source: `pantas_logo.dart`. README added in 3.1 (R3-O18).
