# Community-Driven Skins

## 2026-07-31

### Scope of Customization
- **Decision:** Component-Specific (Isolated Assets).
- **Reasoning:** Aedwon decided to isolate skins to specific fun assets like OMR sheet backgrounds, "Wrapped" card frames, and Archetype illustrations. This protects the core "Ink and Rule" UX (semantic colors, strict typefaces, no shadows) from being broken by chaotic community designs.

### Acquisition & Monetization
- **Decision:** In-App Currency (Study Points) gated by Pro subscription.
- **Reasoning:** Aedwon opted for a shop-based system where users earn points through FSRS tasks and streaks. However, he added a twist: purchasing/equipping is gated by a Pro subscription to induce FOMO. Users will see the items and their points accumulate, but will need Pro to actually unlock them.

### Community Integration & Delivery
- **Decision:** Automated Cloud Sync via Sanity CMS.
- **Reasoning:** Since Pantas already uses Sanity to dynamically sync lessons and questions down to the local Drift database, we will reuse this infrastructure. Community PRs will result in skins being added to a new Sanity schema. The app fetches them in the background, making the shop feel "alive" with instant updates without requiring app store releases.

### Asset Format & Performance Safety
- **Decision:** Strict Static Formats (WEBP / SVG only).
- **Reasoning:** To ensure there are no memory leaks or UI stutters during high-stakes Mock Exams, community skins are restricted to flat static images. WEBP provides tiny raster sizes, and SVG provides crisp vector scaling.
