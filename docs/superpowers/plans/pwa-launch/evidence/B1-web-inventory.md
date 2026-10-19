# B1 web-blocker inventory

Ref: origin/integration/new-design-r1
SHA: 5e6cda4541a80609b27f2784fc2e58d39731a33b
Scope: lib/ (791 files tracked under lib/, including lib/main.dart, main_dev.dart, main_prod.dart, main_staging.dart)
Method: git grep on the ref. Plugin web support checked against local pub cache pubspecs where present. Read-only.

Paths are relative to the repo root on that ref.

## Blocker hits

| blocker | file path | line | what it does |
|---|---|---|---|
| dart:io | lib/core/content/bundle/protected_content_installer.dart | 2 | imports dart:io for content file access |
| dart:io | lib/core/content/bundle/seed_installer.dart | 1 | imports dart:io for seed file access |
| dart:io | lib/core/content/content_database_opener.dart | 2 | imports dart:io for database file access |
| dart:io | lib/core/content/security/content_cipher_profile.dart | 1 | imports dart:io; opens sqlite3mc files by path |
| dart:io | lib/core/storage/data/database_opener.dart | 2 | imports dart:io for app database file access |
| Platform. (dart:io) | none | n/a | no dart:io Platform.* use found; "Platform." hits are TargetPlatform only |
| path_provider | lib/core/content/bundle/protected_content_installer.dart | 10 | imports path_provider for app directories |
| path_provider | lib/core/content/bundle/seed_installer.dart | 6 | imports path_provider for app directories |
| path_provider | lib/core/content/content_database_opener.dart | 11 | imports path_provider for database directory |
| path_provider | lib/core/storage/data/database_opener.dart | 10 | imports path_provider for database directory |
| flutter_local_notifications | lib/features/notifications/data/flutter_local_notifications_gateway.dart | 4 | imports plugin for local notification scheduling |
| flutter_local_notifications | lib/features/notifications/application/notifications_providers.dart | 9 | imports the gateway that wraps the plugin |
| firebase_crashlytics | lib/core/telemetry/firebase_telemetry.dart | 3 | imports Crashlytics for crash reporting |
| purchases_flutter | lib/features/paywall/data/revenuecat_sdk.dart | 5 | imports RevenueCat SDK for purchases |
| purchases_flutter | lib/features/paywall/data/revenuecat_sdk.dart | 7 | re-exports RevenueCat SDK API |
| flutter_secure_storage | lib/core/content/security/content_key_store.dart | 4 | imports secure storage for content key |
| flutter_secure_storage | lib/core/storage/data/database_opener.dart | 7 | imports secure storage for database key (line 12 is a comment) |
| in_app_review | lib/features/review_prompt/data/in_app_review_gateway.dart | 1 | imports plugin for review prompt |
| in_app_review | lib/app/bootstrap.dart | 40 | imports the review gateway |
| app_settings | lib/features/notifications/data/flutter_local_notifications_gateway.dart | 3 | imports plugin to open system settings |
| google_sign_in | lib/core/auth/firebase_google_sign_in_gateway.dart | 1 | imports Google sign-in plugin |
| google_sign_in | lib/app/auth_bootstrap.dart | 8 | imports the Google sign-in gateway (indirect) |
| sign_in_with_apple | none | n/a | declared in pubspec only; no lib import |
| firebase_messaging | none | n/a | declared in pubspec only; no lib import |
| sqlite3 / sqlite3mc | lib/core/content/security/content_cipher_profile.dart | 4 | imports sqlite3; sqlite3.open at lines 15 and 47 |
| NativeDatabase / drift native | lib/core/content/content_database_opener.dart | 6, 57 | imports drift native; NativeDatabase.createInBackground |
| NativeDatabase / drift native | lib/core/storage/data/database_opener.dart | 6, 35 | imports drift native; NativeDatabase.createInBackground |
| url_launcher | lib/features/paywall/application/paywall_controller.dart | 9 | imports URL launcher to open purchase/external pages |
| url_launcher | lib/features/settings/presentation/feedback_intent.dart | 1 | imports URL launcher for feedback link |
| url_launcher | lib/features/settings/presentation/pages/about_page.dart | 17 | imports URL launcher for external links |
| url_launcher | lib/features/settings/presentation/pages/pro_page.dart | 13 | imports URL launcher for external links |
| url_launcher | lib/features/shell/presentation/update_required_page.dart | 4 | imports URL launcher to open store page |
| share_plus / share plugin | none | n/a | no hit |
| package_info_plus | none | n/a | no hit |
| connectivity | none | n/a | no hit |
| MethodChannel | lib/features/paywall/application/trusted_clock.dart | 21 | native channel 'pantas/trusted_clock' for elapsed realtime |
| EventChannel | none | n/a | no hit |
| dart:ffi | none | n/a | no hit |
| dart:isolate / Isolate | none in lib/ (drift createInBackground uses isolates internally, see rows above) | n/a | no direct hit |
| kIsWeb (existing) | lib/firebase_options_dev.dart | 19 | web branch in Firebase options |
| kIsWeb (existing) | lib/firebase_options_prod.dart | 19 | web branch in Firebase options |
| kIsWeb (existing) | lib/firebase_options_staging.dart | 19 | web branch in Firebase options |
| dart.library conditional import | none | n/a | no hit |
| defaultTargetPlatform (not a blocker, noted) | lib/features/paywall/application/trusted_clock.dart | 11 | returns null on iOS before channel call |

Note: "Platform." hits in firebase_options_*.dart and trusted_clock.dart are TargetPlatform, not dart:io Platform.

## Counts (files with a real hit)

- dart:io: 5
- path_provider: 4
- flutter_local_notifications: 2 (1 plugin import, 1 gateway import)
- firebase_crashlytics: 1
- purchases_flutter: 1
- flutter_secure_storage: 2
- in_app_review: 2 (1 plugin import, 1 gateway import in bootstrap)
- app_settings: 1
- google_sign_in: 2 (1 plugin import, 1 indirect)
- sign_in_with_apple: 0 in lib (pubspec only)
- firebase_messaging: 0 in lib (pubspec only)
- sqlite3: 1
- drift native (NativeDatabase): 2
- url_launcher: 5
- MethodChannel: 1
- kIsWeb: 3 (firebase options)
- Other blockers (share_plus, package_info_plus, connectivity, EventChannel, dart:ffi, Isolate, dart.library): 0

## pubspec.yaml dependencies (ref)

Web column: "no web" = pub-cache pubspec lists no web platform (proven). "web" = pub-cache pubspec lists web platform (proven). "UNCONFIRMED" = not checked or unclear. Versions are pubspec constraints.

| package | constraint | web | note |
|---|---|---|---|
| flutter_riverpod | ^2.5.1 | UNCONFIRMED | |
| go_router | ^17.0.0 | UNCONFIRMED | |
| freezed_annotation | ^3.1.0 | UNCONFIRMED | |
| json_annotation | ^4.9.0 | UNCONFIRMED | |
| dio | ^5.11.0 | UNCONFIRMED | |
| drift | ^2.34.0 | UNCONFIRMED | native import used; needs drift wasm/web setup |
| sqlite3 | ^3.5.0 | web (pub-cache 3.5.1) | native app DB path still uses it |
| path_provider | ^2.1.6 | no web (proven, 2.1.6) | blocker |
| path | ^1.9.0 | UNCONFIRMED | pure Dart, likely fine |
| firebase_core | ^4.0.0 | UNCONFIRMED | |
| firebase_auth | ^6.0.0 | UNCONFIRMED | |
| cloud_firestore | ^6.0.0 | UNCONFIRMED | |
| firebase_analytics | ^12.0.0 | UNCONFIRMED | |
| firebase_crashlytics | ^5.0.0 | no web (proven, 5.2.7) | blocker |
| firebase_remote_config | ^6.0.0 | UNCONFIRMED | |
| firebase_messaging | ^16.0.0 | UNCONFIRMED | not imported in lib |
| firebase_app_check | ^0.4.0 | UNCONFIRMED | web needs a reCAPTCHA provider |
| cloud_functions | ^6.0.0 | UNCONFIRMED | |
| firebase_storage | ^13.0.0 | UNCONFIRMED | |
| google_sign_in | ^7.2.0 | web (pub-cache 7.2.0) | |
| sign_in_with_apple | ^8.0.0 | web (pub-cache 8.1.0) | not imported in lib |
| purchases_flutter | ^10.8.0 | web (pub-cache 10.8.0) | web uses separate web setup |
| flutter_secure_storage | ^10.3.1 | UNCONFIRMED | web needs its own storage backend |
| cached_network_image | ^3.3.1 | UNCONFIRMED | |
| collection | ^1.19.0 | UNCONFIRMED | pure Dart |
| meta | ^1.16.0 | UNCONFIRMED | pure Dart |
| intl | ^0.20.0 | UNCONFIRMED | pure Dart |
| timezone | ^0.11.0 | UNCONFIRMED | |
| qr_flutter | ^4.1.0 | UNCONFIRMED | |
| flutter_math_fork | ^0.7.2 | UNCONFIRMED | |
| flutter_local_notifications | ^22.0.0 | UNCONFIRMED (pub-cache 22.3.0 lists android, ios, macos, linux; web not seen) | |
| app_settings | ^8.0.0 | no web (proven, 8.0.3) | blocker |
| url_launcher | ^6.3.0 | UNCONFIRMED | |
| uuid | ^4.6.0 | UNCONFIRMED | |
| in_app_review | ^2.0.12 | no web (proven, 2.0.12) | blocker |
| cryptography | 2.9.0 | UNCONFIRMED | pure Dart expected |
| dev: integration_test, very_good_analysis, build_runner, freezed, json_serializable, drift_dev, mocktail, yaml, crypto | various | n/a | dev only |

## Open items

- Web column for UNCONFIRMED rows was not checked against pub metadata.
- The lib/ inventory counts files, not call sites inside each file beyond what grep showed.
- Pub-cache versions were used as proof; they may differ from the pubspec.lock on the ref.
