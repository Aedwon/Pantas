SidebarNav is the desktop sidebar: wordmark, search, four destinations and the account block. It shows from 1024px (compact to 1439px).

## When to use
- Use it as the main navigation from 1024px (compact from 1024 to 1439, full from 1440).
- Below 1024px use TabBar. Don't use it in focus mode (quiz, mock, assessment).
- Don't add a fifth destination. Four is the limit by design.

## Anatomy
- Container `.sidebar`: flex basis 220 (`layout-sidebar-min`), maximum 244 (`layout-sidebar-max`). Padding 22px 14px 20px. Gap `space-4`.
- Wordmark: 22/700, letter spacing -0.02em, padding 4px 12px 18px.
- Search: SearchField, 38px (`size-search`), radius `radius-sm` 8, with a Ctrl K hint. Pointer-only.
- Destinations: Home, Study, Quiz, Settings, in `.sidebar__nav`. Each item is 40px high (`size-nav-item`), radius `radius-md` 12, padding 8px 12px, icon 21px, label 15/500.
- Active marker: a real `.sidebar__marker` element in `.sidebar__nav`. It is `surface-card` with `elev-nav-active`, radius 12, as tall as the current item (R3-A14).
- Account block `.sidebar__who`: Avatar 30px (see Avatar), name 14/600 (`.sidebar__who-name`), plan 12/400 (`.sidebar__who-plan`, `text-secondary`).
- CHANGE: items moved from radius 10 to 12.
- CHANGE: the account block follows the board (name 14/600, plan 12). The old preview drew 15/500 and 13.
- CHANGE: the old preview drew five destinations with Plan. Every board has four.
- Padding 20 14 20. CHANGE: top 22 to 20 (R2-O08). Wordmark `web-h3-lg` (22/700). CHANGE (R2-O01): it was an unnamed 22/700/1.2 -0.02em.
- `.sidebar__search` adds 10px under the search, so the first destination sits 14px below it as the board draws (usage gap 19).

## Variants and props
- `.sidebar__nav` holds the marker and the items. The app measures the current item (`offsetTop`, `offsetHeight`) on selection, font load, resize and text-size change, sets `--active-top` and `--active-height` on `.sidebar__nav` and adds `.is-measured` (R3-A14). Without a measurement the marker hides and the current item draws its own highlight, so large text never leaves the highlight on the wrong item.
- Tiers (ruling 11): the sidebar shows from 1024. From 1024 to 1439 it is compact (fixed at 220, `layout-sidebar-min`); from 1440 it takes 220 to 244.
- Items are links (`a.nav-item`) with `aria-current="page"` on the current page.
- The consumer provides the four destinations and the account name and plan.

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="sidebar">
  <div class="sidebar__brand">Pantas</div>
  <label class="search">
    <svg aria-hidden="true">...</svg>
    <input type="search" placeholder="Search" aria-label="Search" autocomplete="off">
    <span class="kbd">Ctrl K</span>
  </label>
  <nav class="sidebar__nav" aria-label="Main">
    <span class="sidebar__marker" aria-hidden="true"></span>
    <a class="nav-item" href="#" aria-current="page">
      <svg aria-hidden="true">...</svg>
      Home
    </a>
    <a class="nav-item" href="#">
      <svg aria-hidden="true">...</svg>
      Study
    </a>
    <!-- 1 more -->
    <a class="nav-item" href="#">
      <svg aria-hidden="true">...</svg>
      Settings
    </a>
  </nav>
  <div class="sidebar__who">
    <span class="avatar" aria-hidden="true">M</span>
    <div>
      <div class="sidebar__who-name">Maria</div>
      <div class="sidebar__who-plan">Free plan</div>
    </div>
  </div>
</div>
```

## States
- Rest: icon `icon-muted`, label `text-primary`.
- Hover: 8% `text-primary` fill. Pressed: the same fill and scale 0.98.
- Active page: label weight 600, icon `accent` with stroke 2. The marker sits under it.
- Keyboard focus: 2px `accent` outline, 2px offset.
- Disabled: `aria-disabled="true"`, label `text-disabled`, no hover.

## Keyboard
- Tab goes through the search, then each destination, then the account block.
- Enter activates a link. Ctrl K focuses the search.

## Accessibility
- Wrap the items in `<nav aria-label="Main">`. Use real links with `aria-current="page"`.
- The active state is shown by weight, icon color and the marker, not by color alone.
- The Avatar is decorative here; the name next to it carries the meaning.
- Sidebar items are pointer-only desktop controls: 40px, above the 32px preferred size. Touch gets a padded 44px hit area.

## Motion
- The marker slides between items over 240ms (`dur-medium-1`, `motion-move`) to the measured position and height.
- Icon color fades over `dur-medium-1`. Press scales 0.98.
- Reduced motion: the marker jumps to the new item. Color fades stay at 150ms.

## Flutter
- Build it with WebSidebar in `features/shell/presentation/web_shell.dart`, inside `_DesktopShell`.
- Animate the marker with an AnimatedPositioned of 240ms on `motion-move`.
- Reads `bg-page`, `surface-card` [`surface`], `accent`, `text-primary`, `text-secondary` and `icon-muted`. Take 220, 244 and 40 from WebTokens.
- Position the marker from the measured bounds of the current item (a `GlobalKey` per item), never `index * 44` (R3-A14).

## Do
- Mark the current page with `aria-current="page"`.
- Keep the same four destinations in the same order as the TabBar.

## Don't
- Don't use more than four destinations.
- Don't color icons per item. Only the active icon is teal.
- Don't show it below 1024px.

## Placement
Left edge, full height, on `bg-page`. It sticks while the page scrolls. Hidden in focus mode.

## Tokens used
`border-focus`, `accent`, `layout-sidebar-min`, `layout-sidebar-max`, `space-4`, `space-20`, `space-14`, `space-12`, `space-18`, `type-web-h3-lg`, `tracking-web-h3-lg`, `text-primary`, `space-10`, `active-height`, `size-nav-item`, `radius-md`, `surface-card`, `elev-nav-active`, `active-top`, `dur-medium-1`, `motion-move`, `space-8`, `type-web-nav`, `tracking-web-nav`, `dur-short-2`, `motion-fade`, `dur-short-3`, `icon-muted`, `opacity-hover`, `text-disabled`, `type-web-label`, `tracking-web-label`, `type-web-caption`, `tracking-web-caption`, `text-secondary`, `size-target-touch`

## Status
Approved (from the boards); changed in 2.0: four destinations, real sliding marker element, item radius 12, account block type sizes, `text-secondary` token, links with `aria-current`. Changed in 3.0: search spacing class; padding on the spacing scale; wordmark style. Changed in 3.1: marker from measured bounds with an item fallback (R3-A14); shown from 1024, compact to 1439 (ruling 11).
