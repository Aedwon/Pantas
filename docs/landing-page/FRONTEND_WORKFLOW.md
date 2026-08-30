# Pantas Landing Page Frontend Workflow

This file defines how general frontend-design tooling is used for the public Pantas website. It is intentionally thin. Product truth belongs in `PRODUCT.md`; durable visual direction belongs in `DESIGN.md`; detailed human rationale lives in the Google Doc SSOT.

## Authority order

When guidance conflicts, use this order:

1. Explicit current user decision.
2. Pantas Landing Page Design Direction SSOT (Google Doc).
3. `docs/landing-page/PRODUCT.md` for product truth.
4. `docs/landing-page/DESIGN.md` for machine-readable visual rules.
5. Impeccable for design workflow, critique, adaptation, audit, and polish.
6. Vercel Web Interface Guidelines and WCAG for implementation-quality review.
7. Framework defaults, component-library defaults, and generic model taste.

A lower layer may refine a higher layer. It may not redefine it.

## Scope boundary

This workflow governs the public Pantas marketing website only. It does not redesign the Flutter app. The app's "Ink and Rule" identity, Source Sans 3 rule, and app-specific component bans remain app rules unless a separate decision changes them.

## Impeccable

Use Impeccable as the primary general frontend-design skill once a website implementation project exists.

From that web project's root, the current recommended installer is:

```bash
npx impeccable skills install
```

Keep `PRODUCT.md` and `DESIGN.md` at the web project root so Impeccable can load them as project context. Until the landing-page codebase exists, the canonical seed versions live in `docs/landing-page/` in this repository.

Do not run Impeccable `init` in a way that invents competing product truth. Seed the web project from the approved Pantas files first. Once real code and tokens exist, run Impeccable's documentation/extraction workflow to capture implemented tokens without changing the approved world silently.

### Preferred design sequence

1. **Load context.** Read current product truth, `DESIGN.md`, relevant decisions, and any route/surface brief.
2. **Shape.** Use Impeccable's shaping workflow to clarify information hierarchy and the page's UX before implementation.
3. **Resolve open brand decisions only when required.** Typeface, final accent, logo/app-icon-derived motifs, and the signature visual remain open until explicitly approved.
4. **Design and implement.** The Pantas contract constrains the visual world. Impeccable helps execute it.
5. **Critique.** Check hierarchy, product truth, clarity, and whether the result looks generic or templated.
6. **Distill or quieten when needed.** Remove unnecessary UI, decoration, repeated card structure, and competing focal points.
7. **Adapt.** Verify desktop, laptop, tablet, narrow mobile, zoom, keyboard, touch, and reduced-motion behavior.
8. **Audit.** Run Impeccable's technical audit plus the current Vercel Web Interface Guidelines review.
9. **Polish.** Finish typography, alignment, wrapping, states, image quality, motion timing, and focus behavior.
10. **Human visual review.** Final visual acceptance remains a human decision.

## Pantas overrides for generic design heuristics

General skills contain opinions that are useful as warnings, not project law.

- Inter and Geist are not banned. They are prototype/fallback choices until the final Pantas website typeface is approved.
- Source Sans 3 is not automatically the website font merely because it is the Flutter app font.
- Do not tint neutrals just because a general skill recommends tinted neutrals.
- Do not add a gradient, bento grid, unusual radius, glass surface, animation, decorative icon, or font pairing because a detector or skill treats it as modern.
- Do not choose a brand accent until the brand/app-icon work resolves it.
- Do not invent a signature element. Concept exploration should produce candidates grounded in real Pantas learning behavior, then the user chooses one.
- If a generic detector flags a deliberate Pantas rule, document or configure the exception instead of changing the identity to satisfy the detector.

## Vercel Web Interface Guidelines

Use Vercel's Web Interface Guidelines as an implementation-review gate, not as a visual identity source. Fetch the current guidelines at review time because they are maintained as a living standard.

Review at minimum:

- semantic HTML and native controls;
- keyboard operation and visible focus;
- link and button behavior;
- touch targets and mobile input behavior;
- responsive overflow and content resilience;
- reduced motion;
- image sizing and layout stability;
- font loading and performance;
- sticky/overlay behavior around focused elements;
- loading, empty, error, disabled, hover, focus, and active states;
- zoom and assistive-technology behavior.

WCAG 2.2 AA remains the accessibility baseline if another guideline is less strict or ambiguous.

## Review questions before accepting a design

- Does the page still read as Quiet Editorial Product Design?
- Is the main idea of each scene immediately obvious?
- Is real Pantas product evidence doing more work than decorative graphics?
- Does each structural device communicate actual information?
- Is there one clear focal priority per scene?
- Does the page avoid generic SaaS and noisy edtech patterns?
- Has any general-purpose skill introduced a visual decision that Pantas itself did not need?
- Are unresolved brand decisions still honestly unresolved?
- Does the implementation remain understandable without motion, hover, or color alone?

If the answer to the last four questions exposes a conflict, stop and resolve the design decision before polishing around it.
