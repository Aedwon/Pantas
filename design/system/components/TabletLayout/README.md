TabletLayout names the four width tiers and what changes at each one. The tier comes from the window width, on the web and on native tablets alike.

## When to use
- Use the tiers to decide navigation, type scale, button width and hover affordances for a screen.
- Don't test a device name or orientation. Test the window width only.

## Anatomy
- Phone: under 600px. Phone layout with the floating TabBar (full width less 16 each side, maximum 358).
- Tablet portrait: 600 to 1023px. The phone layout, centered in a 640 column (`layout-tablet-column`, padding 24 24 120). The TabBar is centered at maximum 358 (`layout-tabbar-max`).
- Compact: 1024 to 1439px. The wide layout starts: desktop type, natural-width buttons, P2 placement, hover affordances, and the sidebar at its minimum width (ruling 11).
- Wide: 1440px and up. The full SidebarNav (AppShell). Content maximum 1080.
- Breakpoints: `bp-tablet-portrait` 600, `bp-tablet-landscape` 1024, `bp-wide` 1440.

| Tier | Width | Navigation | Type scale | Buttons | P2 | Hover affordances |
|---|---|---|---|---|---|---|
| Phone | under 600 | TabBar | Phone | Full width | No | No |
| Tablet portrait | 600 to 1023 | TabBar, centered, max 358 | Phone | Full width in the 640 column | No | No |
| Compact | 1024 to 1439 | SidebarNav at 220 | Desktop | Natural width | Yes | With a fine pointer |
| Wide | 1440 and up | SidebarNav, 220 to 244 | Desktop | Natural width | Yes | Yes |

- P2 is the wide button placement: buttons at the right end, secondary first, main last.

## Variants and props
- AppShell gives every tier its frame from one markup; there is no separate tablet class.
- Use `.btn--phone` (full width) in the first two tiers. Use natural-width `.btn` in a `.btn-row` from 1024px.
- The consumer provides one content tree. The tier changes the frame and the type, not the content.
- AppShell gives the tablet tier its 640 column from the same markup (ruling 11). A page needs no separate tablet build.

## Markup
AppShell switches tiers from one markup (R4R-O04):

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
  <div class="main">
    <div class="wrap">
      <div class="page-head">
        <!-- content -->
      </div>
      <div class="card">
        <!-- content -->
      </div>
      <div class="btn-row">
        <!-- content -->
      </div>
    </div>
  </div>
</div>
```

## States
- Pointer hover, pressed and focus follow the wide rules from 1024px. Below that, touch rules apply (rows show chevrons, key hints are hidden).
- Resizing a window moves between tiers at once. Do not animate the change.

## Keyboard
- Tablet landscape and desktop with a keyboard follow the wide rules: key hints show on primary buttons.
- Touch screens hide key hints (`pointer: coarse`).

## Accessibility
- Navigation is a `nav` with `aria-label="Main"` in every tier. The active item has `aria-current="page"`.
- Touch targets stay at 44px in every tier. On pointer devices, 32px is the minimum for pointer-only controls.
- Do not lock the orientation. Content must reflow when the window is rotated or resized.

## Motion
- None.

## Flutter
- Read the tier from `web/web_layout.dart`: WebLayoutTier, `webLayoutTier` and `isWideWebLayout`. Use these, not the platform.
- Desktop shell: `_DesktopShell` and WebSidebar in `features/shell/presentation/web_shell.dart`. Tablet bottom nav: WebTabletNavigation with FloatingTabBarScope.
- Pages use PantasPage and WebLayoutTheme. Reads PantasColors, PantasType and WebTokens for the sizes.

## Do
- Branch on the tier from the window width.
- Keep one set of content and change only the frame.
- Keep the TabBar floating and centered on tablets.

## Don't
- Don't show the SidebarNav below 1024px.
- Don't use full-width buttons from 1024px.
- Don't fork screens by device type.

## Placement
Applied at the top of the page: choose the frame (PhoneFrame, tablet column, wide layout, or AppShell) from the window width.

## Tokens used
`layout-tabbar-bottom`, `space-8`, `layout-reserve-tabbar`, `layout-tabbar-inset`, `z-nav`, `layout-tabbar-max`, `space-24`, `layout-tablet-column`

## Status
Draft (new in 2.0). Source: the tier rules in the layout notes (phone under 600, tablet portrait 600 to 1023, wide from 1024, desktop from 1280). Changed in 3.0: phone container is `.phone-screen` (R2-O16). Changed in 3.1: the tiers come from AppShell (ruling 11). Changed in 3.2: no inline marker index (R4-O12). Changed in 4.0.0: `.tablet-column`, `.main--tablet` and `bp-desktop` removed.

