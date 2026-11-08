# Plan: guardrails so the app cannot drift from design system 4.0 (Nov 9, 2026)

Status: plan only, waiting for Aedwon's approval. Nothing below is built.

## Part 1: For approval (plain language)

### What happened

On staging, the lesson reader's "< Study" back control showed Flutter's gray pill on hover. The
system says back controls are a rounded rectangle with a teal wash, never a pill. Aedwon: "tsk, this
may be the only thing that i've personally encountered but there might be other things that haven't
been followed. are you joking? we built this system exactly for the purpose of making sure things
like this don't happen. shouldn't the lint checks catch this? where did we go wrong? fix this"

### Where we went wrong

1. The check only banned typed values (colors, sizes, spacing, corners, curves). It never checked
   that screens use the system's components. A raw framework button has no typed value, so it passed
   and drew the framework's default look. About 180 such controls remain in about 60 screen files.
2. The app theme never replaced the framework's default control looks, so every leftover control
   falls back to them.
3. The checks were text searches, not a real linter. They miss values passed through helpers or
   variables.
4. Tests proved "nothing overflows", not "this looks like the system". Reviewers read code against
   the README text; nobody compared what renders against the system.
5. Batches shipped faster than Aedwon could look at them.

### The plan: four layers, cheapest and strongest first

1. **Screens cannot use raw framework controls (compile time).** Screens import one design-system
   file instead of the framework's control library. That file hides the raw buttons, tap areas,
   fields, tooltips, snack bars and the rest, so using one in a screen does not compile. A screen
   that needs something new gets a system component first. One existing import check enforces it.
   About half a day (mostly a mechanical import change).
2. **A real design linter (write time and CI).** A Dart analyzer rule that understands types: any
   typed number, color, duration or curve that ends up as a color, padding, corner, text size or
   animation, by any route, is flagged in the editor and fails CI. Exceptions need a written reason.
   It replaces both text-search checks. About a day, after a short proof that our CI analyzer shows
   the rule's findings.
3. **Visual proof against the system (CI).**
   - Render each of the system's 65 component previews once, as the reference.
   - Render each app component in every state (rest, hover, pressed, focus, disabled, selected),
     light and dark, as one sheet per component, the same way.
   - A reviewer compares each pair and lists every difference; we fix them.
   - Aedwon reviews one side-by-side gallery (system against app) once. On approval, the sheets
     become locked reference images, plus about 25 key screens at phone and desktop width.
   - From then on, any change that alters how a component or key screen looks fails CI and shows
     the before and after images.
   About a day and a half plus fixes, and one review session for Aedwon.
4. **Safe fallback (in progress).** The theme gives every framework control the system's shape and
   hover, so anything missed still looks right.

### How we keep screenshots efficient (Aedwon's directive)

- Agents capture images only where a look must be confirmed: the one-time reference capture, the
  component and screen sheets, and a failing visual test.
- One image per component (all states on one sheet), not one per state: about 65 sheets and 50
  screen images in total.
- All rendering is offscreen or headless. No computer control. Every browser closes when its capture
  ends.
- Images are compared by a reviewer only at the one-time audit and when a visual test fails, never
  routinely.

### Process changes

- Each batch's change shows up as a visual diff gallery for Aedwon to skim. Prod release waits for
  his pass; building the next batch does not.
- Reviewers check component use and visual diffs, not just values.
- The process-improvement entry and the WORKFLOW screenshot exemption are recorded with his words.

### Order and time

1. Now (running, from "fix this"): replace the raw controls, theme fallback.
2. Layer 1 and the linter proof, in parallel.
3. The linter.
4. Reference capture, component sheets, audit, fixes.
5. Aedwon's one gallery review, then lock the images and add the CI job.

About three working days in total. Staging gets each step as it lands; prod waits for Aedwon.

### Decisions for Aedwon

1. Approve the plan.
2. Prod release waits for his visual pass, but building does not (default). Or every batch waits for
   his pass.

---

## Part 2: Agent section

- **Layer 1.** `lib/core/ui/ds.dart` exports `package:flutter/widgets.dart`, `package:flutter/material.dart`
  with `hide` on TextButton, ElevatedButton, OutlinedButton, FilledButton, IconButton,
  FloatingActionButton, InkWell, InkResponse, TextField, TextFormField, SnackBar, Tooltip, ListTile,
  the Chip family, Checkbox, Radio, Switch, Slider, DropdownButton, PopupMenuButton, AlertDialog,
  SimpleDialog, showDialog, showModalBottomSheet, LinearProgressIndicator and
  CircularProgressIndicator, plus the system component barrels. `tool/check_layering.dart` bans
  `package:flutter/material.dart` and `package:flutter/cupertino.dart` imports in `lib/features/` and
  `lib/app/` (with a failing-sample test). Run the import swap with a script after the sweep merges
  (Haiku or Gemini). Delete `tool/checks/design_token_literals.dart` only after layer 2 is live.
- **Layer 2.** Spike first (30 minutes): a `tool/lints` package on Dart 3.12's
  `analysis_server_plugin`, registered under `plugins:` in `analysis_options.yaml`. Confirm that
  `flutter analyze` on CI reports its diagnostics. If it does not, use `custom_lint` with its CLI in
  CI. Rules:
  - `ds_no_design_literal`: a numeric, Color, Duration or Cubic literal whose value reaches a
    parameter of type Color, EdgeInsetsGeometry, BorderRadiusGeometry, Radius, BoxConstraints, the
    TextStyle fontSize, letterSpacing or height, the SizedBox, Container or Padding dimensions, the
    Duration of animation APIs, or Curve. Follow conditionals, arithmetic, local finals and private
    consts within the library. Exempt `lib/core/ui/theme/` and the generated tokens.
  - `ds_board_value_reason`: top-level or static `const double`, `Duration` and `Color` in
    `lib/features/` and `lib/app/` need `// ds-board: <reason>`.
  - `ds-geometry` and `ds-board` markers need a non-empty reason; plain `// ignore:` on these rules
    needs a reason.
  - Tests use the plugin's test harness with good and bad samples.
- **Layer 3.**
  - Reference: a Node script with Playwright (headless Chromium from the existing ms-playwright
    cache) opens each `design/system/components/<Name>/preview.html` (check the real file names),
    screenshots the states block at 1x, light then dark through the system's theme switch, and
    writes `design/system/reference/<Name>-{light,dark}.png`. One browser per run, closed at the end.
  - App sheets: `test/goldens/components/<name>_golden_test.dart`. Each builds a grid of states,
    driving hover with a mouse TestGesture, pressed with a held down, focus with requestFocus, and
    selected and disabled with props. It loads the real fonts (Geist, Source Serif 4, Phosphor) and
    uses `matchesGoldenFile` with a tolerance comparator.
  - Audit: a Sonnet reviewer gets the system and app pairs and returns deviations ranked by
    severity. The lead verifies them and fixes go to builders. The gallery is an Artifact page,
    system | app per component.
  - Screens: about 25 key routes at 390 and 1440 wide, light, with fixed fake data and clocks.
  - CI: a `goldens` job on ubuntu-latest, with goldens generated by a `workflow_dispatch`
    "update goldens" workflow on the same image so fonts render the same. Failure diffs upload as
    artifacts (the repo is public, so test data only). Local runs skip the `golden` tag.
- **Layer 4.** Theme fallbacks in `app_theme.dart`, with the test that a raw TextButton or
  IconButton resolves to the system shape and wash (in progress).
- **Process.** Add a `docs/workflow/process-improvement.md` entry with the quotes above and the checks.
  Amend the WORKFLOW "Verification and visual checking" section with Aedwon's directive: "you can be
  exempt from the no screenshot rule for agents only if that part of their work is necessary to
  confirm (in this case, it's UI so of course screenshots are paramount for double checking). but
  ensure this process is efficient/not wasteful." Add the reviewer checklist items.
- **Stop conditions.** The plugin cannot surface in CI and `custom_lint` also fails. Goldens are
  flaky across runs on the same image. The system previews cannot render states statically. Report
  each to the lead with options.
