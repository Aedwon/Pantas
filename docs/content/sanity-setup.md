# Sanity Content Setup

## App runtime config

Flutter builds read public Sanity CDN configuration from dart defines:

```bash
flutter build apk \
  --dart-define=SANITY_PROJECT_ID=<project-id> \
  --dart-define=SANITY_DATASET=production
```

Development builds should point at the development dataset. Production builds should point at the production dataset.

## CDN validation

Before wiring a build, verify the public dataset can be read from:

```bash
https://<project-id>.apicdn.sanity.io/v2024-01-01/data/query/<dataset>?query=*[_type=="exam"][0]
```

The app runtime does not use a token. Configure Sanity usage alerts and spend caps in the dashboard before public testing.

## Required doctypes

Create and populate:

- `exam`
- `subject`
- `topic`
- `question`
- `lesson`
- `mockExam`
- `mockBlueprint`
- `diagnosticSet`

Each doctype must include `_id`, `_updatedAt`, `schemaVersion`, and `isActive`. English v1 content uses `language == "en"` where the doctype has a language field.

## Build-time seed generation

Release builds generate `assets/seed/content.db` before `flutter build`:

```bash
npm ci --prefix tools/build_content_seed
node tools/build_content_seed/build.mjs > build/seed_data.json
dart run tools/build_content_seed/seed_writer.dart build/seed_data.json assets/seed/content.db
```

The live fetch step requires these CI secrets or environment variables:

- `SANITY_PROJECT_ID`
- `SANITY_DATASET`
- `SANITY_READ_TOKEN`

`SANITY_READ_TOKEN` is for CI seed generation only. Do not ship it in the app.

## Local fixture smoke test

The seed writer can be tested without Sanity:

```bash
dart run tools/build_content_seed/seed_writer.dart \
  test/fixtures/sanity/content_sample.json \
  /tmp/content.db
```
