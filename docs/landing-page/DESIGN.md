---
name: Pantas Landing Page
description: Quiet editorial product design for the public Pantas marketing website
---

<!-- SEED: established with the user before implementation; re-run /impeccable document once there's code to capture the actual tokens and components. -->

# Design System: Pantas Landing Page

## Overview

**Creative North Star: "Quiet Editorial Product Design"**

The public Pantas website should feel calm, intelligent, warm, focused, and carefully authored. It uses large typographic hierarchy, generous negative space, restrained surfaces, real product artifacts, and a small number of memorable interactions. The page should feel composed, not decorated.

The strongest visual references are Marka for editorial hierarchy and pacing, Keeby for tactile product demonstration, Adrian Abelarde for restraint and gallery-like framing, Songwrap for singular focus, and Mizan for product storytelling through authentic interface artifacts. Apple Human Interface Guidelines influence purpose, agency, familiarity, flexibility, simplicity, craft, delight, and accessibility. Apple styling is not a reference target.

**Key Characteristics:**
- Type first, product artifacts second, supporting chrome last.
- Low-to-medium visual density with deliberate focal areas.
- Sections behave like distinct scenes, not a repeated module template.
- Negative space is structural and may occupy substantial portions of a scene.
- Neutral-first surfaces with one controlled brand accent once that accent is approved.
- Real Pantas UI and learning artifacts are the primary visual proof.
- Motion explains state, continuity, or product behavior. It does not decorate scrolling.
- Each final landing-page concept should have one Pantas-specific signature visual or interaction. The signature remains intentionally unresolved until concept exploration.
- Structural decoration must encode something real. Numbering, status pills, metadata, diagrams, dividers, and technical labels are used only when they communicate actual structure or information.

This file is the machine-readable design contract. The human SSOT is the Google Doc "Pantas Landing Page Design Direction - SSOT." If these diverge, stop and reconcile the conflict before designing or implementing.

## Colors

The palette is neutral-first. The exact final color tokens are not established yet.

- **Canvas:** white to warm off-white. Avoid a default cool blue-gray cast.
- **Primary text:** near-black with strong contrast.
- **Secondary text:** restrained gray that still meets accessibility requirements.
- **Hairlines:** low-contrast neutral rules used for structure, not for boxing every region.
- **Accent:** one primary brand accent family once the brand/app-icon work establishes it.
- **Semantic colors:** reserved for genuine success, warning, error, or status meaning.

**The Chromatic Budget Rule.** Most sections should contain zero or one prominent chromatic family outside the product UI itself. Color must direct attention or communicate meaning.

Generic purple-blue SaaS gradients, gradient headline text, ambient glowing blobs, decorative rainbow sections, and color added only to make a section feel branded are out of direction.

## Typography

**Display Font:** [to be resolved during branding / implementation]

**Body Font:** [to be resolved during branding / implementation]

**Character:** Use a contemporary sans with excellent legibility, clean punctuation, strong numerals and mathematical characters, and enough personality to support an editorial product identity without becoming conspicuous. The final family must be deliberately selected. Inter, Geist, and similar neutral sans families are acceptable prototype or fallback choices, not approved final branding by default. Source Sans 3 is the Flutter app's established typeface; it is not automatically the website typeface.

### Hierarchy

- Hero display: roughly 64-88 px desktop and 42-58 px mobile, compact line-height, confident but not theatrical.
- Section statement: roughly 44-64 px desktop and 34-44 px mobile.
- Section heading: roughly 28-36 px desktop and 26-32 px mobile.
- Lead body: roughly 18-22 px desktop and 17-20 px mobile.
- Body: 16-18 px with comfortable line-height.
- Metadata / eyebrow: typically 12-14 px, used sparingly.

These ranges are design starting points, not engineering tokens.

Prefer weight, scale, spacing, and placement for hierarchy before introducing additional color. Body text should usually remain around 55-72 characters per line. Large headlines may use intentionally short measures. Avoid brittle forced line breaks that fail responsively.

**The Chosen Type Rule.** Do not let a generic design skill select a fashionable typeface automatically. Prototype quickly if needed, then evaluate the final family against Pantas content, numerals, math, responsive rendering, licensing, and the editorial reference set.

## Layout

Use a fluid centered page with a large-desktop content width around 1280-1360 px. Typical desktop edge margins are 48-72 px, medium screens 32-48 px, and mobile 20-24 px. Treat a 12-column grid as an alignment model, not a reason to expose repetitive boxed modules.

Major narrative sections should usually have substantial breathing room, approximately 120-184 px on desktop and 72-112 px on mobile. Hero or manifesto scenes may be roomier. Optical balance matters more than identical top and bottom padding.

Preferred composition families:
- statement + artifact;
- centered focus around one strong product artifact;
- asymmetric gallery with an offset copy block;
- open three-step rhythm without heavy cards;
- quiet proof band separated by hairline rules;
- artifact sequence showing a real flow.

Asymmetry is encouraged when it strengthens hierarchy. Product artifacts may break the nominal grid or partially extend off-canvas. Essential reading order and actions must remain obvious.

Responsive behavior preserves the order of meaning, not desktop geometry. Tablet may reduce spectacle. Mobile should stack early instead of compressing important content. Decorative motion and edge-breaking composition should simplify before content clarity does.

Native document scrolling is the default. Avoid scroll hijacking, constant parallax, or long pinned sequences that delay useful information.

## Elevation & Depth

The page chrome is predominantly flat. Group content with spacing, tonal separation, and hairline rules before introducing elevation.

Shadows, when used, should feel like soft environmental separation. Use low opacity, broad blur, and restrained displacement. Product screenshots or artifact-like objects may carry more depth when they are intentionally staged as tangible items.

Blur or translucency may appear in a navigation surface only when it preserves readability and has a functional reason. Glassmorphism and Liquid Glass imitation are not part of the identity.

Overlaps are allowed when they create a clear foreground/background relationship between product artifacts. Do not turn the page into a floating-card collage.

## Shapes

Use a small, consistent radius family rather than arbitrary curvature:
- compact utility surfaces: approximately 8-12 px;
- cards and screenshot frames: approximately 16-20 px;
- large feature canvases: approximately 24-32 px when the scene benefits from softness;
- pills: reserved for primary actions, concise labels, or genuine status/control semantics.

A card is a semantic grouping device, not the default container for content. If spacing communicates the relationship, use spacing.

Hairline rules and simple rectangles are preferred over ornamental frames. Avoid pill-shaped everything, excessive floating cards, large rounded-square icon tiles above every heading, and nested-card compositions.

## Do's and Don'ts

### Do
- Make the visitor's main idea in each section clear within a glance.
- Show real Pantas screens, realistic learning content, and focused interaction crops.
- Let one artifact or interaction dominate a visual scene.
- Use whitespace as active hierarchy.
- Rotate compositions so the page feels authored.
- Make delight come from craft, product truth, useful interaction, and precise motion.
- Keep buttons and links familiar, keyboard-operable, and visibly interactive.
- Respect reduced motion and browser zoom.
- Keep informative screenshot text legible at the target viewport.
- Use numbered sequences only when order is meaningful.
- Use status pills only for real statuses.
- Use metadata only when there is meaningful metadata.
- Prefer concrete product language over vague technology claims.
- Treat WCAG 2.2 AA as the implementation baseline.

### Don't
- Copy Apple.com layouts, navigation, animation signatures, or current Apple visual effects.
- Copy Marka's developer-tool identity, Keeby's hardware skeuomorphism, Adrian's portfolio ambiguity, Songwrap's extreme sparsity, or Mizan's enterprise density.
- Use generic purple/blue SaaS gradients or ambient blurred blobs.
- Use dense bento grids as the page's default structure.
- Repeat icon + heading + short paragraph cards across the whole page.
- Use stock photos of students studying as generic proof.
- Use decorative 3D school supplies, generic AI sparkles, or abstract blobs to fill space.
- Use gamified edtech aesthetics that are not grounded in actual Pantas behavior.
- Use tiny low-contrast gray text to appear sophisticated.
- Add pseudo-technical numbering, labels, or diagrams because they look editorial.
- Let Impeccable, Vercel guidelines, a component library, or another general skill override this design contract.
