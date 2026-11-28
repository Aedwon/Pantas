# Sidebar account card (wide web): design

Status: Aedwon picked direction 1, Pro mark B without the gold ring, and minimal complexity (Nov 28). Build waits for the operations manager's go. Ships with the first prod web update after service worker revision 2.

Board: Claude Design canvas "Sidebar Account Card", https://claude.ai/artifact/PDZfPQk3m5acvcAM24LtsC, version 7 (1795854456-aa93), section "B. Pro card (picked, no gold ring)" and the B column of "Narrow sidebar, 1024". Build it 1:1.

## For Aedwon: what changes

- The name row at the bottom of the wide sidebar becomes a button. Clicking it opens Settings, then Account, the same place the name card opens on the phone.
- The second line shows the plan only: "Free account" or "Pro account". The exam leaves this row; Home already shows it with the days left.
- A Pro account sits on a white card (dark: the dark card color). A Free account stays plain on the sidebar.
- Hover: a light gray fill, like the menu items above it; on the Pro card, the card turns one step grayer. Keyboard focus: the teal focus ring. The pointer becomes a hand.
- At 1024 the sidebar is narrower: a long name ends in dots, and the plan line always shows in full.
- Phones do not change.
- Known cost you accepted: the selected menu item is also a white card, so the Pro row can look selected.
- Cost: about 1 h 30 min of build and checks, one Sonnet worker, plus one independent review.

## How completion is judged

The wide sidebar matches the board's B states in light and dark at 1440 and 1024; clicking or pressing Enter or Space on the row opens Settings, Account; tests below pass; Aedwon's visual check on staging.

## Agent section

### Current code (main a269f8cbd)

- Row: `lib/features/shell/presentation/web_shell.dart`, the `Row` with `_SidebarAvatar` (~line 455 to 495), not interactive. Line 2 is `exam · plan`.
- Data: `lib/app/web_route_shell.dart` ~line 102 to 115: `person`, `exam` (`activeExamShortNameProvider`), `plan` from `proForActiveExamProvider` (`null` → '', true → 'Pro', false → 'Free').
- Phone equivalent: Settings home name card (`settings_home_page.dart`), `onTap: push('/settings/account')`.

### Build

- `WebShellFrame` and its sidebar take `plan` (keep the tri-state) and an `onAccount` callback; drop the `exam` parameter from the row. Keep `exam` out of the sidebar entirely if nothing else in the sidebar uses it.
- The row is one focusable button (`Semantics(button: true, label: 'Account, <name>, <Free|Pro> account')`), click cursor, activates on click, Enter and Space. Reuse the sidebar item's existing hover and focus machinery (`webFocusRing`, the nav item's `textPrimary` at `PantasOpacity.hover` hover fill) instead of new code. Fade any fill from a zero-alpha version of its own color, never `Colors.transparent` (see `fix/web-hover-fade-r1`).
- Layout per board: padding 10 by 12, radius 10 (the nav items' radius), gap 10, avatar 30, name `webLabel` (14/600) single line with ellipsis, line 2 `webCaption` (12) `textSecondary`, single line.
- Pro (plan true): fill `surfaceCard`, shadow as the selected nav item's (`0 1px 2px rgba(0,0,0,.06)`); hover fill `surfaceHover` (light #F7F7F9, dark #2A2A2A). Free (plan false): transparent at rest, hover `textPrimary` at `PantasOpacity.hover`. Focus: the standard web focus ring (2 px accent, 2 px offset), any plan.
- Line 2: "Free account" or "Pro account".
- Plan unknown (`null`, coverage not loaded): no card and no second line (name only), still a button. Lead decision: the board draws no such state; showing "Free" would be a guess (existing comment), and a blank line would jump.
- No name: keep today's name and avatar behavior (plain avatar icon).
- Click: open Settings with Account selected, the way the Settings tab opens its Account page on wide web. Telemetry: log `tabOpened` with `tab: settings` as the sidebar's Settings item does. Use the route the Settings list uses for Account (read it; `context.go` vs `push` per AGENTS.md: inside the tab shell, Settings stays highlighted).
- No gold ring, no Pro tag, no countdown.

### Tests (failing first)

- Widget: the row is a button with the label above; tap, Enter and Space each call the Account route once; Free shows "Free account" with no card; Pro shows "Pro account" on `surfaceCard`; unknown shows no second line and no card; the exam name is not in the row; hover fill per plan; focus shows the ring; a long name ellipsizes at 220 and the plan line is whole.
- Golden: one sheet, light and dark, 1440 and 1024, Free and Pro, rest, hover and focus (board B states). Images come from CI.
- Existing sidebar tests that assert `exam · plan` change to the new line.

### Standards applied

- WEB-A1 visible keyboard focus and order; WEB-I10 target size (row is about 50 px tall, full sidebar width); WEB-C1 and WEB-C6 text contrast in light and dark (secondary text on the card and on the sidebar); WEB-G8 missing states (plan unknown, no name). Source: `~/Documents/Projects/agent-standards/web-interface-design.md`.
- UXW-CONCISE, UXW-TERMS: "Free account" and "Pro account", the plan named once. Source: `~/Documents/Projects/agent-standards/ux-writing.md`.

### Decision record

- Nov 28 about 4:15 PM Manila, Aedwon (request): "hmmm this part in the left sidebar on web view could have more use i think. one thing i can think of is that it is clickable and leads to the account tab in settings. but you might have better ideas. also CSE Pro Pro is a bit awkward, why not make it "Free/Pro account" instead and the Pro account has a card distinction or something. wdyt? let's brainstorm first (or maybe spawn another lead for this so you stay on top of things) and then design".
- Options offered (lead): 1 clickable card to Account, plan line "Free/Pro account", exam leaves the row (about 1 to 2 h, recommended); 2 a small menu with Account, Pantas Pro, Your exam, Sign out (4 to 6 h); 3 option 1 plus a "Get Pro" link for Free (can feel pushy). Days to the exam was not offered: Home's week strip already shows it.
- Aedwon: "let's go with 1".
- Board v3 offered Pro mark A (gold Pro tag beside the name, recommended) and B (white card with a gold ring; cost: reads like the selected menu item). Complexity: minimal recommended (about 1.5 h).
- Aedwon: "B Pro card but no gold ring" and "minimal". Board updated to v7 (ring removed).
