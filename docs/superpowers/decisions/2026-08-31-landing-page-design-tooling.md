# Landing Page Design Tooling Decision Log

## 31 August 2026 - frontend design tooling

### Options presented

1. Stack Anthropic frontend-design, UI/UX Pro Max, Vercel Web Interface Guidelines, and project rules together.
   - Cost: broad coverage, but duplicated guidance and more chances for a general skill to pull the design away from the Pantas SSOT.
2. Use Impeccable as the main general-purpose design skill, keep Vercel/WCAG as implementation review gates, and use the Pantas SSOT as the visual authority.
   - Cost: simpler and more coherent, but project-specific rules must explicitly override generic Impeccable opinions when they conflict.
3. Write a large custom Pantas skill that copies useful parts of the other skills.
   - Cost: maximal control, but creates a second body of design guidance to maintain and duplicates mature upstream tooling.

### Decision

Use option 2.

The Pantas landing-page SSOT remains the human authority. A compact `PRODUCT.md`, seed `DESIGN.md`, and frontend workflow document translate it into project context. Impeccable is the primary general design workflow. Vercel Web Interface Guidelines and WCAG are review gates. General skills may refine implementation but may not redefine the Pantas visual identity.

A large custom `SKILL.md` is not being created. Project-specific conventions belong in project instructions and design context. This also avoids maintaining a fork of Impeccable.

### Typeface status

The landing-page typeface is not decided. Inter and Geist remain prototype/fallback examples only. Source Sans 3 remains the Flutter app typeface and is not automatically the website typeface. Final website type selection is a separate brand decision.

### User comments

> "is impeccable better than using those other 3 frontend design skills you mentioned?"

After the recommendation to use Pantas design contract + Impeccable + Vercel/WCAG:

> "okay, proceed with your recommendation. also has the font been decided already? based on your statements i assume it is"
