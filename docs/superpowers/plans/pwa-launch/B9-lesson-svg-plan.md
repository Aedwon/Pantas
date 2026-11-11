# B9 implementation plan

Approved scope: October 25 lead brief, E4-E7 P0.8 and B9 status on origin/main
73572280cf4d9478d56e42247be04dad8ad1acd9. No commits, fetches, deployments,
devices, screenshots, or changes outside the two assigned worktrees.

1. Test SVG dispatch, source loading, accessibility, failure and light/dark colors.
   Extend both portable and current lesson renderers. Preserve PNG behavior and
   layout. SVG frames inherit the active theme, including expanded figures.
2. Document currentColor plus reserved literal palette tokens mapped to PantasColors.
3. Test local illustration discovery and ordered marker joining. Include local
   SVG/PNG bytes as data URLs in seed/server content, preserving existing remote
   asset-map URLs and credits. Server Markdown receives resolved IMAGE markers.
   This uses the existing content database/cache without another hosting service.
   Reject ambiguous sequence numbers and unsafe paths. Extend the staging remote
   Markdown parser to read resolved IMAGE markers. No database schema change.
4. Test strict SVG preflight fixtures, then parse and draw accepted files with
   flutter_svg in a headless Flutter test. Reject unsupported elements/attributes,
   CSS, animation, scripts, raster content and external resources before parsing.
5. Run focused checks, full APP suite, requested static checks and platform builds.
   Preserve exact logs and dirty source identity in B9-lesson-svg.md. The lead owns
   independent review, integration and visual acceptance.

Files: pubspec.yaml/lock; lib/core/ui/components/{portable_text_renderer,
content_renderer,lesson_svg}.dart; tools/content/lesson_asset_map.dart;
tools/check_lesson_svgs*; test/core/ui/components/lesson_svg_test.dart;
test/tools/lesson_svg_assets_test.dart; docs/content/lesson-svg-authoring.md.
STAGING: tools/upload_content/*; lib/core/content/remote/lesson_markdown.dart;
test/core/content/remote/lesson_markdown_test.dart. Add directly affected helpers
and tests only. No lesson text or seed package regeneration.
