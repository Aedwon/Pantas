# Pantas UI Redesign — "Ink & Rule"

**Date:** 2026-07-18
**Status:** Approved by Aedwon (direction, tokens, components, and sweep plan validated interactively via visual companion mockups in `.superpowers/brainstorm/73545-1784382720/content/`)

## Problem

The app's current UI reads as AI-generated ("vibe-coded"): Poppins bold everywhere, the stock Tailwind palette (blue `#1F6BFF` + default green/amber/red), large pastel container blocks, full-width pill buttons, and uniform stat tiles. Aedwon wants the neat, deliberate feel of his lesson-author and illustration-studio tools before deploying.

Research identified the telltale patterns to eliminate: geometric-sans-for-everything typography, all-caps letterspaced labels, emojis as UI elements, cards nested in cards, colored card borders, uniform stat-tile rows, pill badges, gradient/glow decoration, and rounded-everything with soft shadows.

## Chosen direction

**"Ink & rule"** — a dense, editorial, printed-workbook identity derived from the lesson author's palette, selected over a spacious editorial variant and a cool SaaS variant. Key traits:

- Warm paper surfaces; grouping by whitespace and 1px hairline rules, not boxes. Depth never comes from shadows.
- Tabular layouts: aligned meta columns (category, minutes), faint row rules.
- A two-column header (greeting left, streak/countdown right, plain text — no chips).
- A "figures first" stats band: large serif numerals on their own line, sans labels beneath, vertical hairline dividers, ruled top and bottom.
- One accent color with a strict budget; semantic colors only on semantic values.
- No emojis, no all-caps labels, sentence case throughout.

## Scope

The whole app: all 17 feature modules, light and night modes. Approach: rebuild the token layer, build a shared component kit, then sweep every screen. (Chosen over screen-by-screen bespoke styling, which drifts, and tokens-only, which leaves slop layouts intact.)

## Section 1 — Design tokens

All tokens live in the existing `ThemeExtension` files: `lib/core/ui/theme/app_colors.dart`, `app_text_styles.dart`, `app_dimensions.dart`. Token names change to the new vocabulary so stale references fail the build.

### Color — Light ("Paper")

| Token | Hex | Use |
|---|---|---|
| `background` | `#FBF9F4` | screen background |
| `surface` | `#FFFFFF` | rare raised surfaces |
| `ink` | `#26221B` | primary text |
| `inkMuted` | `#6E675C` | secondary text, labels |
| `rule` | `#E5DFD3` | section hairlines |
| `ruleFaint` | `#F1EDE4` | row hairlines |
| `board` | `#1D5C50` | accent (see budget) |
| `boardTint` | `#E3EFEA` | rare tinted fills |
| `rust` | `#A33B2E` | error / weak scores |
| `amber` | `#9A6B15` | warning / middling scores |

### Color — Night ("Ink")

Warm near-black, not inverted slate: `background #191613`, `surface #211D18`, text `cream #EFEAE0`, `creamMuted #A69C8C`, `rule #38332B`, `ruleFaint #2A2620`, `board #4FA08D` (dark text on it: `#14110D`), `boardTint #22352F`, `rust #D4705F`, `amber #C99A45`. All text/background pairs must pass WCAG AA.

### Color budget (enforced by components)

- `board` appears only on: the primary action, progress indicators, and done-checkmarks.
- `rust`/`amber` appear only on semantic values (weak-area percentages, warnings) — never as decoration.
- One primary action per screen.

### Typography

Two families, bundled as assets in `assets/fonts/` and declared in `pubspec.yaml` — no runtime font fetching. Remove the `google_fonts` Poppins usage entirely.

- **Source Serif 4** — display: greetings, section headings, large numerals.
- **Source Sans 3** — everything else: body, labels, buttons, table meta.

The type scale drops all-caps letterspaced styles; hierarchy comes from size, weight, and `inkMuted`.

### Dimensions

- Radii: 5px (buttons), 8px (rare surfaces). No pills.
- Hairlines: 1px.
- Progress bars: 3px tall.
- Spacing scale tightened to match the approved mock's density.

## Section 2 — Component kit

New widgets in `lib/core/ui/widgets/`. Screens compose these; they do not hand-style.

| Widget | Purpose |
|---|---|
| `PageScaffold` | Paper background, standard padding and top spacing |
| `SectionHeader` | Serif heading + optional trailing action on the same baseline |
| `RuledSection` | Card replacement: block bounded by 1px rules, standard rhythm |
| `InkTableRow` | List row: glyph slot, title/subtitle, right-aligned meta columns, faint bottom rule. States: done (muted, ✓), active (semibold, ○), plain |
| `StatsBand` | Figures-first stats: serif numerals with muted suffixes, sans labels beneath, vertical hairline dividers, ruled top/bottom |
| `ProgressRule` | 3px board-green progress line on a faint track |
| `InlineMeter` | Compact bar + colored percentage for weak areas |
| `BoardButton` | Flat board-green primary, 5px radius; text-only secondary variant |

Quiz/exam-specific pieces (answer rows, timers) are styled variants of these primitives, built during the sweep.

## Section 3 — Sweep, verification, testing

### Sweep order

`shell` → `home` (reference implementation, matched to the approved mock) → `onboarding` → `study_plan` → `lesson` → `quiz` → `assessment` → `review` → `mock_exam` → `progress` → `metrics` → `wrapped` → `paywall` → `notifications` → `settings` → `auth_flow` → `legal`.

On every screen, hunt and replace: pastel blocks, pill buttons, icon-in-tinted-circle headers, stat tiles, emoji-as-icon, all-caps labels.

### States

- Loading skeletons: faint pulsing rules, not gray rounded blocks.
- Empty states: serif message, one quiet action, no illustrations or emoji.

### Verification

- Per feature: run on the Android emulator, screenshot light **and** night, check against the color budget and identity rules.
- Final: full-app walkthrough on the emulator; entire test suite passes.
- Widget tests asserting old colors/styles are updated within each feature's sweep, not batched.

## Out of scope

- New features or content changes — every screen keeps its existing information and behavior.
- App icon / launch screen rework (worth doing later; the launcher still shows the default Flutter icon).
- iOS build setup (the design carries over unchanged when iOS ships; fonts are bundled assets).
