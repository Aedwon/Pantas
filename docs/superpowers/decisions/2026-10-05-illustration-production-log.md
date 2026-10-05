# Illustration production direction

## 5 October 2026

While adding an illustration review to the coverage audit, Aedwon revisited the August 15 decision to
cut lesson illustrations from 279 to 3 hand-made images. The original plan had him drawing them, which
made him the release bottleneck. Code-generated figures removed that bottleneck, but the reduction was
never rescinded.

**Decisions**

1. **The August 15 reduction is rescinded.** The 278 lesson and 155 question counts were marker lists,
   not judgments of need. The final count comes from the audit's level 4 (lessons) and level 5
   (questions) illustration review. The old counts are a cross-check only. A lesson or question can
   need several illustrations.
2. **Production is code-generated or sourced, not hand-drawn.** Aedwon hand-makes only bespoke test
   stimuli such as the three Reading Comprehension cartoons and comics. Open-licensed sources are used
   where code is a poor fit (for example biology), with attribution tracked.
3. **Two tiers.** Exact exam figures (geometry, circuits, cube nets, figure series) are precise and
   minimally styled. Concept illustrations (for example a cell or the water cycle) are simplified to be
   memorable and easy for a student to redraw, without looking cheap.
4. **Style: variety that serves the concept.** No uniform thick stroke. Stroke weight above a legibility
   floor, shading, and detail level vary per figure, especially in science. Fixed across all figures:
   shared palette with defined color roles, one label typeface and minimum size, minimum stroke weight
   readable at about 400 px wide, light and dark theme support, safe margins, and every label and value
   in the lesson text appearing in the figure. Each science figure's one taught idea must be its most
   visible element; detail that does not serve it is cut.
5. **Pipeline, to minimize Aedwon's involvement.** Per figure: generate; mechanical checks (render at
   phone width in both themes, label match against the lesson, sizes, margins, clipping, overlap);
   visual critic by a different model against a written rubric; revise, at most 3 rounds, then flag as
   stuck; separate accuracy check for science and math content. Aedwon reviews every finished figure
   on contact sheets at the end and gives a verdict per figure. He supplies no examples or references.

**Not yet verified**

- The existing kit has two parts: an AI-image prompt template with the Illustration Studio (7 images
  produced) and 24 code-drawn figure types in `lib/core/ui/figures`. Their code and fit have not been
  reviewed. The style kit task starts there.

**Scope.** The coverage audit only reports findings and creates no illustrations. Building the style
kit and pipeline is a separate task after the audit.
