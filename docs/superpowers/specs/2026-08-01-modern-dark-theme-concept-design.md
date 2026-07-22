# Modern Dark Theme UI Concept (Proof of Concept)

> **Typography, amended 11 August 2026.** Every mention of a serif below is
> superseded. **The app uses one family, Source Sans 3, everywhere**: the serif
> was retired because Aedwon found it an eyesore, and a reader noticing the
> type is not reading the lesson. Read a "serif 16/700" here as "16/700".
> The round is in `decisions/2026-08-10-typeface-log.md`.
>
> **What the serif carried, the rest of the identity now carries alone**: the
> hairline rules, the underlined section heads, the tabular figures, and the
> absence of tinted callouts, rounded cards and drop shadows.



**Date:** 2026-08-01
**Status:** Draft / User Review

## Problem
The app currently follows an "Ink & Rule" theme (mimicking print on paper). The goal is to explore a more modern, premium approach that completely avoids the chaotic and generic "AI slop" patterns prevalent in the industry, serving as a temporary proof of concept for a potential UI evolution.

## Anti-Patterns (AI Slop) Avoided
This direction strictly avoids:
- **Visual Slop:** No heavy glassmorphism, no neon purple-to-cyan gradients, no glowing borders, and no generic bento-box grids.
- **Structural Slop:** Maintains rigorous padding and spacing, consistent typography scales, and high contrast for accessibility (avoiding the "one-shot generation" lack of system).
- **Functional Slop:** Does not disguise standard interfaces as chatbot interfaces.

## Proposed Direction: Sleek Dark Mode (Technical & Professional)
The chosen direction (Option C) translates the strict hierarchy of the "Ink & Rule" specs into a technical, high-information-density dark mode.

- **Backgrounds:** Deep charcoal and off-black (e.g., `#111214`, `#1e1f22`), rather than pure black or trendy tinted purples.
- **Typography:** Crisp sans-serif fonts, using subtle grays for secondary text to establish strong visual hierarchy without relying heavily on color.
- **Borders & Dividers:** Thin, subtle borders (`1px solid #2b2d31`) replace the harsh black hairlines of Ink & Rule, providing structure without visual noise.
- **Accent Colors:** Used sparingly and semantically (e.g., green for positive progress, amber/rust for weak areas, a single primary brand color for main calls to action like "Continue lesson").

## Navigation Icons
As strictly defined in the `2026-07-26-home-and-navigation-design.md` spec, the bottom navigation uses strict glyph metaphors (not emojis or generic UI icons):
- **Home:** A house
- **Study:** An open book
- **Quiz:** A single answer bubble (metaphor: shading a bubble on an answer sheet)
- **Progress:** A folded sheet with a rising line

## Implementation Context
This document serves as the design spec for the proof of concept. If this design direction is approved to move into implementation, it will require a targeted set of CSS/Flutter component overrides that safely shadow the existing Ink & Rule theme without breaking the underlying data wiring.
