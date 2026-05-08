# Frontend UI/UX Design — CSE/CET Reviewer

**Status:** Approved  
**Date:** 2026-05-08  
**Scope:** Foundation spec — brand system, color tokens, typography, 12 core components, navigation, fool-proof patterns, motion, content types. Per-flow screen specs (onboarding, quiz, lesson, review, mock exam, progress, paywall, auth) follow in separate specs that reference this foundation.

---

## 1. Design philosophy

**Modern Filipino, Warm Confident.** Clean and professional enough to be trusted for a government exam. Approachable and motivating enough to open every day. Sits between GCash's polish and a focused study tool.

**Fool-proof by default.** Filipino mobile users scan, they don't read. Every screen is designed with the assumption that no user will read body copy before tapping. Key actions must be unmissable. Destructive actions must be confirmed. Consequences must be stated before the action.

---

## 2. Language strategy

**English throughout the UI.** Navigation, buttons, labels, error messages, empty states, settings, dialogs — all English.

**Brief Filipino only on high-emotion celebration moments.** Not whole sentences. Short exclamations only:
- Quiz completion: "Magaling! 8/10 correct"
- New personal best streak: "Napakahusay! New record!"
- Perfect score: "Perpekto!"

**Rationale:** Mixed-language UI is harder to scan than consistent English. English is also the language of the CSE and UPCAT exams, making it the natural register for exam prep content.

---

## 3. Color system

### 3.1 Brand palette

| Name | Hex | Usage |
|---|---|---|
| Primary | `#1F6BFF` | Buttons, active nav, links, progress bars |
| Success | `#22C55E` | Correct answer reveal, sync ok, completion |
| Warning | `#F59E0B` | Streak urgency, overdue reviews, caution banners |
| Error | `#EF4444` | Wrong answer reveal, destructive actions, error banners |

### 3.2 Light mode semantic tokens

| Token | Value | Usage |
|---|---|---|
| `colorSurface` | `#FFFFFF` | Cards, tiles, dialogs |
| `colorBackground` | `#F8FAFC` | Screen backgrounds |
| `colorOnSurface` | `#1E293B` | Primary text |
| `colorOnSurfaceMuted` | `#64748B` | Secondary text, metadata, placeholder |
| `colorBorder` | `#E2E8F0` | Unselected tile borders, dividers |
| `colorBorderSelected` | `#1F6BFF` | Selected tile left-border accent |
| `colorPrimaryContainer` | `#EFF6FF` | Primary tint backgrounds (info banners) |
| `colorSuccessContainer` | `#F0FDF4` | Correct answer tile bg after reveal |
| `colorErrorContainer` | `#FEF2F2` | Wrong answer tile bg after reveal |
| `colorWarningContainer` | `#FFFBEB` | Offline banner bg, streak-at-risk bg |

### 3.3 Dark mode semantic tokens

| Token | Value |
|---|---|
| `colorSurface` | `#1E293B` |
| `colorBackground` | `#0F172A` |
| `colorOnSurface` | `#F1F5F9` |
| `colorOnSurfaceMuted` | `#94A3B8` |
| `colorBorder` | `#334155` |
| `colorBorderSelected` | `#4D8FFF` |
| `colorPrimaryContainer` | `#1E3A70` |
| `colorSuccessContainer` | `#14532D` |
| `colorErrorContainer` | `#450A0A` |
| `colorWarningContainer` | `#451A03` |
| `colorPrimary` (dark adjusted) | `#4D8FFF` |
| `colorSuccess` (dark adjusted) | `#4ADE80` |
| `colorWarning` (dark adjusted) | `#FCD34D` |
| `colorError` (dark adjusted) | `#F87171` |

### 3.4 Dark mode approach

Base: `ColorScheme.fromSeed(seedColor: Color(0xFF1F6BFF), brightness: Brightness.dark)`, then override with the custom token pairs above. All components reference tokens only — never raw hex. Dark mode is automatic when tokens are correct.

### 3.5 Selection state rule

**Selected answer tiles use a bold left border, never a color fill.**

- Default: `colorBorder` border (1.5px), `colorSurface` background
- Selected: `colorBorderSelected` left border (4px), `colorSurface` background, `colorOnSurface` text
- Correct (after reveal): `colorSuccessContainer` bg, `colorSuccess` border (2px), green ✅ icon
- Incorrect (after reveal): `colorErrorContainer` bg, `colorError` border (2px), red ❌ icon, strikethrough text
- Correct-but-missed (after reveal): `colorSuccessContainer` bg, `colorSuccess` dashed border (2px), 💡 icon — visually distinct from "you got it right"

---

## 4. Typography

### 4.1 Typeface

**Poppins** across all text. Geometric, rounded, warm. The de-facto typeface of PH fintech apps; familiar to the target audience. Loaded via Google Fonts bundle.

**Noto Serif** for math expressions only (answer tiles and equations). Visually distinct from Poppins so math notation doesn't conflict with UI copy.

### 4.2 Type scale

| Token | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `displayLarge` | 28sp | 700 | 1.2 | Screen titles, celebration headers |
| `displaySmall` | 22sp | 700 | 1.2 | Section display titles |
| `headlineMedium` | 18sp | 600 | 1.3 | Screen headings, card section titles |
| `headlineSmall` | 16sp | 600 | 1.3 | Sub-section headings |
| `bodyLarge` | 16sp | 500 | 1.6 | **Question text** — minimum for readable exam content |
| `bodyMedium` | 14sp | 400 | 1.5 | Answer options, body copy, explanations |
| `bodySmall` | 12sp | 400 | 1.4 | Metadata, timestamps, captions — never interactive |
| `labelLarge` | 12sp | 600 | 1.2 | Progress counters, tab labels |
| `labelSmall` | 10sp | 600 | 1.2 | Tags, badges, category chips; 0.5px letter-spacing |

**Hard rule:** No interactive element (anything a user taps or reads to make a decision) may use a font size below 14sp. Metadata-only elements may go to 12sp minimum.

---

## 5. Spacing & shape

### 5.1 Grid

4pt base grid. All spacing values are multiples of 4: `4, 8, 12, 16, 20, 24, 32, 40, 48`.

### 5.2 Border radii

| Token | Value | Usage |
|---|---|---|
| `radiusXS` | 6px | Badges, chips, small tags |
| `radiusSM` | 8px | Input fields, small banners |
| `radiusMD` | 10px | Answer tiles, buttons, compact cards |
| `radiusLG` | 14px | Primary cards, dialogs, coach marks |
| `radiusXL` | 20px | Bottom sheets, screen-level containers |
| `radiusFull` | 999px | Pills, streak indicators, FAB |

### 5.3 Shadows

| Token | Value | Usage |
|---|---|---|
| `shadowSM` | `0 1px 4px rgba(0,0,0,.05)` | Flat cards, list items |
| `shadowMD` | `0 2px 8px rgba(0,0,0,.08)` | Active cards, quiz cards |
| `shadowLG` | `0 4px 20px rgba(0,0,0,.10)` | Floating elements, sheets |
| `shadowPrimary` | `0 3px 10px rgba(31,107,255,.35)` | Emphasized Learn FAB button |

### 5.4 Tap targets

Minimum tap target: **48×48dp** on all interactive elements. Answer tiles meet this via vertical padding (`paddingVertical: 12`). Buttons are full-width by default.

---

## 6. Navigation

### 6.1 Structure

Three-tab bottom navigation:

```
[ Home ]  [ ● Learn ● ]  [ More ]
```

- **Home** — dashboard, streak, today's plan, progress shortcut, weak-area chips
- **Learn** — center tab, visually emphasized (circular raised button, `shadowPrimary`); contains: Daily Review (priority), Quick Quiz, Lessons, Mock Exam (Pro-gated), exam switcher
- **More** — Settings, Account, Notifications, Upgrade to Pro, Privacy & Terms, Help / Report a problem

### 6.2 Learn tab emphasis

The Learn tab icon is rendered as a circular raised button (38dp diameter, `colorPrimary` fill, `shadowPrimary`) that floats above the navigation bar. Active/inactive state changes only the label color, not the button shape — the button is always prominent.

### 6.3 Active state

Active tab: label uses `colorPrimary`, icon weight increases.  
Inactive tab: label and icon use `colorOnSurfaceMuted`.  
No underline indicator — the label color change is sufficient.

### 6.4 Screen header

All main tab screens have a blue (`colorPrimary`) header with white text. Secondary screens (launched from Learn, More, etc.) use a white `AppBar` with `colorOnSurface` text and a back chevron.

---

## 7. Core component library

### 7.1 AppButton

Variants: `primary`, `secondary`, `ghost`, `destructive`, `disabled`, `loading`.

```
primary:     colorPrimary fill, white text, radiusMD, shadowMD, 48dp height, full-width
secondary:   colorSurface fill, colorPrimary border (2px), colorPrimary text
ghost:       transparent, colorPrimary text, no border
destructive: colorError fill, white text
disabled:    colorBorder fill, colorOnSurfaceMuted text, no shadow, cursor blocked
loading:     primary style, opacity 0.8, spinner replacing label
```

All variants: Poppins 600, 14sp, horizontal padding 20px. Optional leading icon (16sp emoji or SVG, 8px gap to label).

### 7.2 QuizAnswerTile

Full-width tappable row. Minimum 48dp height enforced via `paddingVertical: 12`.

```
default:         colorSurface bg, colorBorder border (1.5px), letter prefix (A/B/C/D) in colorOnSurfaceMuted
selected:        colorSurface bg, colorBorderSelected left-border (4px), letter in colorPrimary, text in colorOnSurface, Poppins 500
correct:         colorSuccessContainer bg, colorSuccess border (2px), ✅ icon replaces letter, Poppins 600 green text
incorrect:       colorErrorContainer bg, colorError border (2px), ❌ icon, strikethrough text
correct-missed:  colorSuccessContainer bg, colorSuccess dashed border (2px), 💡 icon, green text
```

Math answer tiles use Noto Serif for the expression text. All other tiles use Poppins bodyMedium.

### 7.3 AppCard

Surface container. `colorSurface` background, `shadowSM`, `radiusLG`.

Variants:
- **Plain** — no top accent; used for topic cards, subject cards
- **Accent** — 3px solid top border in `colorPrimary`; used for "due today" urgency cards
- **Gradient** — linear gradient fill; used for priority Daily Review card and StreakBanner

Cards never have tap feedback on the container itself — only child elements are interactive.

### 7.4 EmptyState

Required structure: illustration (emoji or SVG, 40–48px) + `headlineSmall` + `bodyMedium` (max 2 lines) + `AppButton` (primary).

Never show a blank screen or plain text. Every empty state has a CTA that tells the user what to do next.

Examples:
- No reviews due: 🎉 "All caught up!" / "You've finished all due cards. Come back tomorrow!" / "Quiz instead"
- No internet on first launch: 📡 "No connection" / "Content couldn't load. Check your internet." / "Try again"

### 7.5 ErrorBanner

Top-of-screen non-modal banner. Three variants:

```
error:   colorErrorContainer bg, colorError left-border (4px), ⚠️ icon, retry CTA right-aligned
offline: colorWarningContainer bg, colorWarning left-border (4px), 📶 icon, dismissible (✕)
success: colorSuccessContainer bg, colorSuccess left-border (4px), ✅ icon, auto-dismisses after 3s
```

Banners never block the quiz flow. The offline banner appears above content, not as a modal. Banners stack if multiple are active (max 2 visible at once).

### 7.6 InlineOfflineBanner

Persistent, non-blocking amber banner shown during offline state:

> 📶 Offline — your progress is still being saved

Dismissible with ✕. Reappears if user navigates to a new screen while still offline. Never shown during active quiz — queued until quiz completion screen.

### 7.7 CoachMark

Dark tooltip (`#1E293B` bg, white text, `radiusLG`) with a directional arrow pointing at the target element. Appears on first visit to a screen, max 2 active simultaneously.

Required fields: headline (Poppins 600, 12sp), body (Poppins 400, 11sp, `colorOnSurfaceMuted` on dark bg — use `#94A3B8`), dismiss CTA ("Got it →" right-aligned, `colorPrimary` on dark bg — use `#4D8FFF`).

Coach marks appear on first visit to: the **Learn tab** (pointing at Daily Review) and the **quiz answer confirmation button** (pointing at "Confirm answer"). These are the only two screens with coach marks in v1.

Persistence: tracked in local `SharedPreferences` as boolean flags (`coach_learn_seen`, `coach_quiz_confirm_seen`). Once dismissed, never shown again.

### 7.8 ConfirmationDialog

Used only for truly destructive or irreversible actions. Not for errors or informational prompts.

Structure: icon (emoji, 24px, centered) + title (`headlineSmall`, centered) + body (`bodyMedium`, centered, max 3 lines, consequence-first wording) + two-button row.

**Hard rule: Cancel/safe action always on the LEFT. Destructive always on the RIGHT. No exceptions.**

Wording rule: State the consequence before the action.
- ✓ "Your quiz progress will be lost." → [Keep going] [Leave quiz]
- ✗ "Are you sure you want to leave?" → [Cancel] [Leave]

Examples:
- Exit quiz mid-session: ⚠️ "Leave quiz?" / "Your progress on this quiz will be lost." / [Keep going] [Leave]
- Delete account: 🗑️ "Delete account?" / "All your data will be permanently deleted. This cannot be undone." / [Cancel] [Delete]

### 7.9 StreakBanner

AppCard with gradient fill. Two states:

```
active:   amber→orange gradient (F59E0B → F97316), shows current streak count (displaySmall, 800 weight) + personal best
at-risk:  red gradient (DC2626 → EF4444), streak count + "Review now to keep it!" inline CTA button
```

Shown on Home screen hero and on quiz completion screen. The at-risk state appears when the user has not completed their daily review by 8PM device local time.

### 7.10 ProGateBanner

Shown in place of Pro-gated content. Never a full-screen block or an error — always a friendly card that shows value first.

Structure: dark card (`#1E293B` bg), PRO badge (amber), feature name + one-line value proposition, primary CTA with price ("View Pro — ₱99/mo"), ghost "Maybe later" dismiss button, feature emoji right-aligned.

The "Maybe later" button is always present. Users are never trapped.

### 7.11 SkeletonLoader

Shimmer placeholder that exactly matches the layout of the content it replaces. Uses `E2E8F0 → F1F5F9` shimmer animation (1.5s, infinite, `background-size: 200%`). Dark mode: `334155 → 475569`.

Rules:
- Skeleton must match the real content's dimensions exactly — no layout shift on load
- Never show a spinner in place of content that has a known layout
- Spinners are acceptable only for button-level loading states (AppButton loading variant)

### 7.12 SyncStatusIndicator

Persistent pill shown in the top-right corner of the Home and Learn screens. Three states:

```
synced:   colorSuccessContainer bg, colorSuccess dot, "Synced" label — auto-hides after 5s
syncing:  colorPrimaryContainer bg, colorPrimary pulsing dot, "Syncing..." label
offline:  colorWarningContainer bg, colorWarning dot, "Offline" label — persists until reconnected
```

Tapping the indicator on any non-Synced state opens a bottom sheet with sync details and a "Sync now" button.

---

## 8. Content type handling

### 8.1 Math

**Rendering:** `flutter_math_fork` (KaTeX-compatible). All LaTeX sourced from Sanity `question.body` Portable Text blocks with type `math`.

**Equation block:** Rendered in a shaded container (`colorBackground` bg, `colorBorder` border, `radiusMD`), centered, with adequate vertical padding (12px). Visually distinct from question text so users know it's a formula, not prose.

**Answer tiles with math expressions:** Use Noto Serif for the expression text inside the tile. Poppins used for the letter prefix (A/B/C/D) only.

**Explanation after reveal:** Step-by-step always shown for math questions regardless of correct/incorrect. Steps numbered, each step on its own line, expression in Noto Serif blue. Shown in `colorPrimaryContainer` explanation card.

### 8.2 Images / diagrams

**Source:** Sanity asset pipeline, delivered via Sanity CDN. Images are attached to `question.body` as Portable Text image blocks.

**Layout rule:** Image always appears above the question text. Full card width. Aspect ratio preserved; max height 200dp on phone screens (scrollable if taller on tablets, but v1 is phone-only).

**Loading:** SkeletonLoader placeholder matching image dimensions while loading. No spinner.

**Interaction:** Pinch-to-zoom enabled on all question images. Double-tap to reset zoom.

**Accessibility:** `alt` text field required in Sanity schema for all question images. Enforced by Sanity validation rule on `published` status.

**Explanation after reveal:** 1–2 sentence explanation shown only when the user answers **wrong**. Not shown on correct answers (positive reinforcement message only).

### 8.3 Text-only questions

**Explanation after reveal:** 1–2 sentence explanation shown only when the user answers **wrong**. Same rule as images.

**Correct answer feedback:** Brief positive message in the header bar ("Correct!") + green reveal on tiles. No explanation text unless the editor explicitly added one for a tricky question (optional `question.explanation` field in Sanity).

---

## 9. Fool-proof UX patterns

These are non-negotiable rules applied across all screens and flows.

### 9.1 One primary action per screen

Every screen has exactly one visually dominant primary action (`AppButton` primary variant, full-width). Secondary actions are ghost or secondary variant. The user should never have to choose between two equally-weighted blue buttons.

### 9.2 Confirmation before destruction

Any action that is irreversible or causes data loss requires a `ConfirmationDialog`. The consequence is stated in the dialog body before the action buttons appear. The safe action is always on the left.

Triggers: exit mid-quiz, delete account, clear all progress (settings), revoke auth.

Does NOT trigger: changing settings, dismissing banners, navigating away from a non-interactive screen.

### 9.3 Answer confirmation gate

Quiz answers require explicit confirmation before revealing. Tapping a tile selects it (border-only visual change). A "Confirm answer" `AppButton` must be tapped to trigger the reveal. This prevents accidental taps from being unrecoverable.

Exception: FSRS review cards use swipe gestures (Again / Hard / Good / Easy ratings) since the rating system is designed for deliberate self-assessment. A coach mark on first visit explains the gesture.

### 9.4 No dead ends

Every error state, empty state, and loading failure has a next action. No screen may end with only an error message and no way forward.

Every `EmptyState` has a primary CTA. Every `ErrorBanner` has a retry action or a dismiss. The `ProGateBanner` always has a "Maybe later" dismiss. Pro-gated routes redirect to paywall, never 404.

### 9.5 Icon + label always

Navigation tabs: always icon + label. No tab bar shows icons alone. Contextual icon buttons (share, more options) within screens are acceptable without labels if the icon is universally understood (✕ close, ← back, ⋮ more). When in doubt, add a label.

### 9.6 Progress visibility

Any multi-step flow (quiz, onboarding diagnostic, mock exam) shows explicit progress: "Question 4 of 10" + a linear progress bar. The user always knows where they are and how much is left.

### 9.7 First-run coach marks

Two coach marks in v1:
1. **Learn tab — Daily Review card**: "Tap this every day 🔁 — this FSRS review is what keeps knowledge in your long-term memory." Dismiss: "Got it →"
2. **Quiz — Confirm answer button**: "Tap to lock in your answer before seeing the result." Dismiss: "Got it →"

Persisted in `SharedPreferences`. Shown exactly once per user, never again after dismissal.

### 9.8 Offline continuity

Offline state never interrupts a quiz in progress. The `InlineOfflineBanner` queues until the quiz completion screen. Answers are written to Drift immediately; sync happens when connectivity returns. The user never loses an answer to a network error.

### 9.9 Pro gate framing

Pro-gated features are never presented as errors or locked-out failures. The `ProGateBanner` always shows what the feature does and why it's worth paying for before showing the price. The dismiss path ("Maybe later") is always visible.

---

## 10. Motion & animation

### 10.1 Navigation transitions

| Transition | Animation |
|---|---|
| Tab switch | Horizontal slide (200ms, ease-in-out) |
| Push (drill into screen) | Horizontal slide right (250ms, ease-in-out) |
| Pop (back) | Horizontal slide left (200ms, ease-in-out) |
| Modal / bottom sheet | Slide up (300ms, ease-out) |
| Dialog | Fade + scale from 0.95 (150ms) |

### 10.2 Interaction feedback

| Interaction | Animation |
|---|---|
| Button tap | Scale press 1.0 → 0.97 → 1.0, 120ms |
| Answer tile select | Border color transition, 100ms |
| Correct reveal | Tile scale 0.95 → 1.0 + green color transition, 200ms ease-out |
| Wrong reveal | Horizontal shake ±4px × 3 cycles, 150ms |
| Streak celebration | Confetti burst + streak number scale 1.0 → 1.3 → 1.0, 500ms spring |
| New personal best | Larger confetti + medal icon bounce, 800ms spring |

### 10.3 Loading

SkeletonLoader shimmer: 1.5s linear infinite loop. Respects `reduceMotion` (static gray if enabled).

### 10.4 Reduce motion

All animations check `MediaQuery.of(context).disableAnimations`. When true: all transitions become instant (0ms duration), shimmer becomes static, celebrations show a static success state. No exceptions.

---

## 11. Accessibility baseline

| Requirement | Rule |
|---|---|
| Contrast | WCAG AA minimum (4.5:1 for normal text, 3:1 for large text) across both light and dark modes |
| Tap targets | 48×48dp minimum for all interactive elements |
| Font scaling | UI must remain usable at system font scale up to 1.3×. Answer tiles expand vertically; no text truncation on interactive elements |
| Screen reader | All interactive elements have `Semantics` labels. Images have alt text. Icons have `semanticLabel` |
| Reduce motion | All animations respect `disableAnimations` system setting |
| Color alone | Color is never the only differentiator — icons, text, or borders always accompany color-coded states |

---

## 12. Per-flow spec references

The following flows are designed in separate specs that reference this foundation:

- `2026-05-XX-onboarding-flow-design.md` — 10-question diagnostic, exam selection, goals
- `2026-05-XX-quiz-flow-design.md` — quick quiz, drill, retake mistakes
- `2026-05-XX-lesson-reader-design.md` — Portable Text reader, LaTeX, glossary
- `2026-05-XX-review-flow-design.md` — FSRS daily review queue, card flip, rating gestures
- `2026-05-XX-mock-exam-design.md` — full-length timed mock, pause, post-mock analysis
- `2026-05-XX-progress-design.md` — stats, trends, weakness map
- `2026-05-XX-paywall-design.md` — pricing, SKU comparison, RevenueCat purchase flow
- `2026-05-XX-auth-flow-design.md` — anon→named migration, OAuth sign-in screens
- `2026-05-XX-settings-design.md` — preferences, sync, account, legal, diagnostics

---

## 13. Flutter implementation notes

### 13.1 Theme wiring

Tokens map to `ThemeData` extensions. Create a `AppColors` extension and `AppTextStyles` extension registered on `ThemeData`. Access via `Theme.of(context).extension<AppColors>()`.

Do not use raw `Colors.*` anywhere in widgets — always go through tokens.

### 13.2 Font loading

```yaml
# pubspec.yaml — already has google_fonts dependency
# Use GoogleFonts.poppins() and GoogleFonts.notoSerif() 
# Preload both in bootstrap to avoid FOUT
```

### 13.3 Math rendering

```yaml
flutter_math_fork: ^0.7.x  # add to pubspec in Plan 2
```

Wrap in `Math.tex(expression)`. Handle parse errors gracefully — show a "Could not render equation" placeholder + report to Crashlytics as non-fatal.

### 13.4 Component location

```
lib/
  core/
    ui/
      theme/
        app_colors.dart          # AppColors ThemeData extension
        app_text_styles.dart     # AppTextStyles ThemeData extension
        app_theme.dart           # light + dark ThemeData builders
      components/
        app_button.dart
        quiz_answer_tile.dart
        app_card.dart
        empty_state.dart
        error_banner.dart
        inline_offline_banner.dart
        coach_mark.dart
        confirmation_dialog.dart
        streak_banner.dart
        pro_gate_banner.dart
        skeleton_loader.dart
        sync_status_indicator.dart
```

All components are in `core/ui/components/` — imported by features via `package:cse_cet_reviewer/core/ui/components/app_button.dart`. No feature may define a component used by another feature.

---

**End of frontend foundation design spec.**
