# Pantas Community Skins (Post-Launch)

**Status:** Ideation complete. Slated for post-launch development.

## Overview
A gamified, community-driven asset system where users can customize specific visual elements of the Pantas app. The feature is designed to convert high user engagement (study streaks, FSRS tasks) into RevenueCat Pro tier conversions by inducing FOMO.

## 1. Scope & Aesthetic Fit ("Ink and Rule" Protected)
To protect Pantas's strict "Ink and Rule" design identity, community skins are **Component-Specific**. 
Skins cannot alter core UI elements, semantic colors (Rust/Amber/Green), or typography. Instead, they target isolated, fun assets:
- OMR sheet backgrounds
- "Wrapped" card frames
- Archetype illustrations

### Creator Guidelines
To ensure quality, all submitted skins will be bound by strict, pixel-perfect guidelines. For example:
- OMR backgrounds must not exceed a specific opacity or contrast ratio to ensure the test bubbles remain perfectly readable.
- "Wrapped" card frames must strictly adhere to a 9:16 aspect ratio bounding box with predefined safe zones for text.
- Asset files cannot exceed specified file sizes (e.g., max 200kb).

## 2. Gamification & Acquisition (FOMO Loop)
Users earn "Study Points" passively by completing their daily FSRS reviews and maintaining streaks.
- **The Shop:** A dynamic Skin Shop where users can browse community skins.
- **The Catch:** Users can accumulate points and afford items, but they are **blocked from equipping them unless they subscribe to the Pro tier**. This lets users see the value they've earned while driving monetization through FOMO.

## 3. Community Integration Pipeline
Skins are created by community contributors and ingested via the following pipeline:
1. **GitHub PR:** Creators submit a Pull Request to a public repository containing their static assets (WEBP/SVG) and a JSON config file.
2. **Sanity CMS:** Once approved, the assets and metadata are uploaded to a new `communitySkin` schema in Sanity CMS.
3. **App Sync:** Using the existing infrastructure that syncs lessons/questions, Pantas dynamically fetches the new skins in the background and stores them in the local Drift database. This allows the shop to update instantly without requiring app store releases while preserving offline functionality.

## 4. Asset Format & Performance Safety
To guarantee that high-stakes Mock Exams never drop frames or stutter, community skins are restricted to:
- **Static Formats Only:** WEBP for raster images, SVG for vectors.
- Lottie (JSON animations) and custom code are strictly banned to prevent memory leaks and heavy CPU overhead during tests.
