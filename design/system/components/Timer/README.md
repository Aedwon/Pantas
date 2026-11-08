Timer is the clock in the mock exam: the time left over a thin bar. It changes on the clock itself when five minutes remain.

## When to use
- Use it in the Mock Exam top bar, where time is part of the test.
- Don't use it for study time on Home (use ProgressBar with a label). Don't use a toast for the time warning.

## Anatomy
- `.timer`: inline column, centered, gap 6px.
- Time: 17/700, tabular figures, `text-primary`. Format `h:mm:ss`, and `m:ss` under one hour.
- Bar: 120px wide (`size-timer-bar`) by 5px (`size-accuracy-bar`), `fill` track, `accent-fill` fill.
- Warning: time and bar fill become `warning-text`, and a visible Tag says "5 min left".
- Paused: time becomes `text-secondary`, and a gray Tag says "Paused".

## Variants and props
- `.timer`, `.timer.is-warning`, `.timer.is-paused`. `.timer__time` holds the clock text. A `.pbar` holds a single `<i style="--value:N">` (ruling 4).
- The consumer provides the time text, the fraction left and the state. Switch to warning when 5:00 or less remains.
- The warning appears on the clock itself, not as a toast (HANDOFF rule).
- `.timer--inline`: the time and a 60px bar on one line, for the FocusHeader (usage gap 12).

## Markup
Minimal markup, from the preview without its documentation scaffolding.

```html
<div class="timer">
  <span class="timer__time" role="timer" aria-live="off" aria-label="Time left">1:24:05</span>
  <div class="pbar" aria-hidden="true">
    <i style="--value:93.4"></i>
  </div>
  <span class="tag tag--warning">5 min left</span>
</div>
```

## States
- Running: `text-primary`, teal bar.
- Warning (under five minutes): `warning-text` time and bar, and the "5 min left" Tag.
- Paused: `text-secondary` time and the "Paused" Tag.
- It is not interactive, so it has no hover, pressed, focus or disabled state.

## Keyboard
- The clock takes no keys. Pause and resume belong to the buttons around it, which take Tab and Enter.

## Accessibility
- The time has `role="timer"`, `aria-live="off"` and a name ("Time left"). A running clock must not announce every second.
- Announce the five-minute warning once through a separate `role="status"` line, for example "Five minutes left."
- Never use color alone: the warning has text and the paused state has text.
- The warning words use `warning-text` and always come with the time.

## Motion
- The bar shrinks smoothly, with a 600ms width change each second (`dur-long-2`, `motion-house`).
- Reduced motion: the width steps at each second.
- The color change to the warning state is a color fade and may stay.

## Flutter
- Build PantasTimer from a Text with tabular figures over a 120 by 5 LinearProgressIndicator.
- Wrap the Text in Semantics with `liveRegion: false`. Send the warning through a separate SemanticsService announcement.
- Reads `text-primary` [`label`], `text-secondary` [`secondaryLabel`], `fill`, `accent-fill` and `warning-text`.

## Do
- Show the warning on the clock, in text and color together.
- Announce the warning once.

## Don't
- Don't show a toast or a dialog for the time warning.
- Don't use red for low time. Red is for wrong answers.

## Placement
Center or right of the mock exam top bar, over the 120px bar. On the phone, it sits in the 64px header.

## Tokens used
`space-6`, `type-web-timer`, `tracking-web-timer`, `text-primary`, `size-timer-bar`, `warning-text`, `text-secondary`, `space-10`

## Status
Draft (new in 2.0). Source: the phone mock top bar (clock 17/700 over a 120 by 5 bar). The warning rule comes from HANDOFF. Changed in 3.0: time style `web-timer` (R2-O01); `--value` contract. Changed in 3.1: `.timer--inline`.
