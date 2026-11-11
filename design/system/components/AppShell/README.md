AppShell is the page frame on desktop: a sticky sidebar at the left and a main column that holds the page content.

## When to use
- Use it for every signed-in page at every width: one markup serves the phone, tablet, compact and wide tiers (ruling 11). PhoneFrame is for phone-only screens.
- Don't use it in focus mode (use FocusLayout). It has no sidebar there.

## Anatomy
- `.shell`: a wrapping flex row on `bg-page`. `.shell__side` holds the `.sidebar`. `.main` holds the page.
- Sidebar: flex basis 220 (`layout-sidebar-min`), maximum 244 (`layout-sidebar-max`), sticky at the top, full viewport height. Padding 22 14 20.
- Sidebar content: brand, `.sidebar__nav` with `.nav-item` links and one `.sidebar__marker`, then the account row at the bottom.
- Main `.main`: flex `999 1 560px` (`layout-main`), padding 28 top (`layout-main-pad-top`), 44 sides (`layout-main-pad-x`), 44 bottom (`layout-main-pad-bottom`).
- Content `.wrap`: maximum 1080 (`layout-content-max`), centered, a flex column. Gap between blocks 28 (`layout-section-gap`).
- CHANGE: the section gap was 26. It is now 28, and the column gap is the same token (`layout-cols-gap` folded into `layout-section-gap` in 3.0.0).
- Page head: `.page-head.page-head--root` with a date line (`web-sub`), the `web-h1` title, and a trail (a WeekStrip) at the right.
- `.stack` lays out cards in a column with the same 28 gap.

## Variants and props
- Compact (1024 to 1439px): the sidebar at its minimum width (220) and 32px main sides.
- The consumer provides the nav items, the active page, and the page content.
- One `web-h1` per page. It lives in the page head. Below 1024 the `.main` is a size container, so the phone large title it shows steps down at large text like the phone screen (D180, D189).
- The shell switch is built (R2-O25, ruling 11): below 1024px `.shell > .shell__side` hides and `.shell > .tabbar-dock` shows, with the `layout-reserve-tabbar` bottom reserve on `.main`; from 1024px the sidebar shows and the dock hides.
- One markup across tiers (ruling 11): wide 1440 and up (the full sidebar, main sides 44); compact 1024 to 1439 (the sidebar at 220, main sides 32); tablet 600 to 1023 (no sidebar, the TabBar dock, content in the centered 640 column with 24px sides, phone type); phone under 600 (16px gutters, phone type). The same Home markup renders 600, 1024 and 1440; put the `.tabbar-dock` inside `.shell` (it hides from 1024). `.shell--desktop` forces the wide shell in documentation frames.
- The page root swaps type below 1024 (`phoneScale`, README Type) and the main bottom padding is `layout-reserve-tabbar` plus the safe area (ruling 3).

## Markup
The page root; see SidebarNav and TabBar for their parts.

```html
<div class="shell shell--desktop">
  <div class="shell__side">
    <nav class="sidebar" aria-label="Main">
      <div class="sidebar__brand">Pantas</div>
      <div class="sidebar__nav">
        <!-- content -->
      </div>
      <div class="sidebar__who">
        <!-- content -->
      </div>
    </nav>
  </div>
  <main class="main">
    <div class="wrap">
      <div class="page-head page-head--root">
        <!-- content -->
      </div>
      <div class="stack">
        <!-- content -->
      </div>
    </div>
  </main>
</div>
```

## States
- Nav item rest, hover (8% tint), pressed (scale 0.98), keyboard focus (2px `accent` ring) and current follow SidebarNav.
- Current item: `aria-current="page"`. The marker (`surface-card` with `elev-nav-active`) slides to it.
- The shell has no empty or error state. Pages draw their own.

## Keyboard
- Tab goes through the sidebar items, then into the main column.
- Enter on a nav item opens that page and moves the marker.

## Accessibility
- Use landmarks: `nav` with `aria-label="Main"` for the sidebar and `main` for the content.
- Mark the current item with `aria-current="page"`. The marker is decoration only.
- One `h1` per page. Use `h2` for card titles.
- Nav items are at least 40px high on pointers and get a 44px hit area on touch.

## Motion
- The marker moves 240ms (`dur-medium-1`) with `motion-move`.
- Reduced motion: the marker jumps to the new item at once.

## Flutter
- Build it with `_DesktopShell` and WebSidebar in `features/shell/presentation/web_shell.dart`. Pages sit in PantasPage with WebLayoutTheme.
- Take 220, 244, 1080, 28 and 44 from WebTokens. Reads `bg-page`, `surface-card` [`surface`], `accent` and `text-primary`.

## Do
- Keep the content at 1080 or less, centered, even on wide monitors.
- Put the page title in the page head, once.
- Keep 28px between blocks.

## Don't
- Don't show the sidebar below 1024px.
- Don't add a second h1 or a second main landmark.
- Don't put the TabBar and the sidebar on the same screen.

## Placement
The shell is the outermost frame of the page. Sidebar left, main right.

## Tokens used
`bg-page`, `layout-sidebar-min`, `layout-sidebar-max`, `layout-main`, `layout-main-pad-top`, `layout-main-pad-x`, `layout-main-pad-bottom`, `space-32`, `space-24`, `layout-reserve-tabbar`, `layout-tablet-column`, `layout-gutter-phone`, `space-16`, `layout-content-max`, `layout-section-gap`, `space-12`

## Status
Draft (new in 2.0). Source: the Main board and the shell code. The section gap changes from 26 to 28. In the preview the gap under the page head is 56px, because the page head adds its 28px bottom margin to the 28px block gap. Changed in 3.0: shell switch at 1280 built in CSS (R2-O25). Changed in 3.1: tiers from one markup; sidebar from 1024 (ruling 11, CHANGE D136). Changed in 3.2: `.main--tablet` reserve removed (R4-O16); no inline marker index (R4-O12).

