# Settings wide web review fixes

October 30, 2026. Follow-up to the settings review findings. Existing uncommitted
settings implementation was present at startup and was preserved. No fetching,
staging, commits, pushes, branch switches, browser control, or screenshots.
The lead owns review, commits, and visual acceptance.

Policy read using `git show origin/main:<file>`: AGENTS.md, WORKFLOW.md,
SUBAGENTS.md. Policy revision: `245edecd31902824c8a97daaaa0458c5f4415c7b`.
Source HEAD: `8bd1e0f94b30729ea44bfa132a727b1358b370f1`.
Controlling spec and board map: origin/main's 2026-10-30-web-layout-design.md
and pwa-launch/web-layout-board-map.md. HANDOFF.md and the affected boards
supply the visual rules. Specs and plans were not changed.

## Findings addressed

1. ST_LargeText: keep SettingsRow on the shared web presentation at large text.
   Remove ellipsis from large web labels and subtitles so they actually wrap.
   Values stay below their labels. Rows grow with their contents.
2. ST_ProCSE / ST_ProCSEPass: Season Pass uses the shared plan card beside
   subscriptions on wide web, with the same title/price/period structure,
   26px price type, 12px card gaps, and stable text insets across selection.
   Existing available products and payment logic are preserved.
3. ST_Exam family: place Study days and seven 44px circles on one row with
   8px circle gaps. Wrap when space requires it. Reuse the same day callbacks,
   selection semantics, and last-day guard. Phone presentation stays separate.
4. W_Settings / DK_Settings: selector padding is 14px vertical and 16px
   horizontal. Its maximum width is 420px and it aligns left.
5. Reported 2x overflows: constrain sidebar navigation labels with Expanded.
   This was the shared source of the 81px overflow reported on Account and
   every other settings page. Labels can wrap inside the sidebar.

No findings rejected. Retained behavior: web backup remains hidden, names save
when leaving, sign-out keeps its confirmation copy, web uses existing prepaid
trial terms, and the existing weekly/yearly catalog remains available. No
reminders, pending GCash state, Wrapped, schema features, or motion added.

## Files changed by this follow-up

- lib/features/settings/presentation/widgets/settings_row.dart
- lib/features/settings/presentation/pages/pro_page.dart
- lib/features/settings/presentation/pages/exam_page.dart
- lib/features/settings/presentation/pages/session_building_page.dart
- lib/core/ui/web/web_components.dart, shared wrapping behavior
- lib/features/shell/presentation/web_shell.dart, common sidebar overflow
- test/features/settings/presentation/web_settings_layout_test.dart
- test/features/settings/presentation/web_pro_states_test.dart
- This evidence record.

Only the existing uncommitted wide-layout tests were extended. Committed tests
were not changed. Added assertions cover wrapping and stacked values, selector
width/padding, day-circle geometry, and aligned Season Pass typography in both
themes. Existing 1440px light/dark 1x/2x page coverage remains enabled.

Source identity: SHA-256 of sorted modified/untracked lib/ and test/ paths, then
NUL, file bytes, NUL per file:
`dbe617638135c6f92e7ec1a5e8c7be70d953dd6d9a124c43028953157e2d201c`.

## Verification

Startup reproduction: the assigned focused tests produced 462 passes and
30 failures. Added regression assertions also failed before their fixes.
All final commands exited 0. Actual output tails:

```text
flutter analyze
No issues found! (ran in 22.8s)

dart format --output=none --set-exit-if-changed lib test
Formatted 1627 files (0 changed) in 2.92 seconds.

dart run tool/check_layering.dart
check_layering: OK

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
```

Focused test command:

```sh
flutter test test/features/settings test/app test/core/ui/web test/features/shell test/features/legal test/features/onboarding/presentation/exam_picker_screen_test.dart test/core/ui/components/segmented_switch_test.dart test/core/ui/components/audit_avatar_fallback_test.dart test/core/ui/components/exam_picker_extensions_test.dart --reporter expanded
```

01:07 +608: All tests passed!

```text
flutter build web --release
Compiling lib/main.dart for the Web...                             74.6s
✓ Built build/web
```

The web build reports a missing CupertinoIcons font family warning. It still
builds successfully. Package updates are available and were not installed.
Full command logs: `/tmp/settings-final-{analyze,format,layering,attribution,tests,build}.log`.
No unresolved automated failures or implementation tasks remain from this review.

Visual acceptance remains with Aedwon. No screenshots or browser checks were
performed. Independent review and integration remain with the lead.
