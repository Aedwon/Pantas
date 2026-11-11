# Staging candidate seed digest test, October 27, 2026

Source: `3f7ad39731f020de6e95ea094869b7de3e8f4e1e`.
Policy: `origin/main` at `64e5757674ccca9eb42e1b63d22df84f788de470`, read with
`git show origin/main:AGENTS.md`, `WORKFLOW.md`, and `SUBAGENTS.md`.
No fetch, pull, commit, dependency addition, or protected-package regeneration.
Initial working tree was clean. Flutter 3.44.6, Dart 3.12.2, macos_arm64.

## Choice

Keep the generated `8ee751ee0504bafc` constant. Update the test's full plaintext
digest pin. This is a low-impact test correction with no runtime behavior change.

The E03 content-protection execution spec defines the version as the first 16
hexadecimal characters of the plaintext SQLite SHA-256 immediately before
protection. E04.2 of the release plan requires the package builder to write the
version file. The generated protected companions stay outside source control.
The builder calls `writeContentSeed`, hashes its bytes, and writes that prefix.
Encrypted payload hashes can change because protection uses randomized bytes.

History supports maintaining the test with the generated constant:
`70ebe6aa` updated both for schema 9. `3f7ad397` updated only the constant for
schema 10. B8-size.md records the matching schema-10 source hash and the stale
pin failure. The current source schema is 10. Reverting the constant would
restore a schema-9 identity that this committed source does not build.

## Fresh reproduction

Used the documented export command and the same plaintext seed writer that the
package builder calls. Outputs went to an ignored build directory. No keys were
needed, and existing protected package files were left unchanged.

```sh
dart run tools/build_content_export/build_content_export.dart build/seed-digest-check/export.json
dart run tools/build_content_seed/seed_writer.dart build/seed-digest-check/export.json build/seed-digest-check/content.db
shasum -a 256 build/seed-digest-check/export.json build/seed-digest-check/content.db
sqlite3 build/seed-digest-check/content.db 'PRAGMA user_version;'
```

Both build commands exited 0. Actual hashes and schema:

```text
d0d5f18d93e6be0d07ecd80274551c4c0119407cb567f627552baeef8f5d218a  build/seed-digest-check/export.json
8ee751ee0504bafc3645b3e40d02239c6c2371d13930ef0d71c0c594bf738a9d  build/seed-digest-check/content.db
10
```

These match the October 27 B8 export and source hashes. Export reported the same
two oversized lesson image omissions, visual-media.md and layers-of-the-earth.md.
No content source files were changed.

Before correction, the focused version test exited 1:

```text
Expected: '588610f4184ff762'
  Actual: '8ee751ee0504bafc'
00:00 +0 -1: Some tests failed.
```

Only the full digest literal in the test changed. The generated constant stayed
unchanged. The separate provenance test's old digest is fixture input, not the
shipping constant assertion, and stays unchanged.

## Verification

```sh
flutter test test/core/content/content_seed_version_test.dart test/tool/content_seed_writer_test.dart test/tool/content_package_builder_test.dart test/tool/content_package_verifier_test.dart --reporter expanded
```

Exit 0:

```text
00:10 +14: All tests passed!
```

`flutter analyze lib test tool`, exit 0:

```text
Analyzing 3 items...
No issues found! (ran in 18.4s)
```

Additional checks, all exit 0:

```text
Formatted 1 file (0 changed) in 0.01 seconds.
check_layering: OK
check_no_ai_attribution: OK
```

Full local command logs and generated files: `build/seed-digest-check/` (ignored).
This verifies source digest maintenance. It does not accept a production release
or replace any immutable protected package. No device or visual checks performed.

`flutter test`, exit 0:

```text
18:54 +4878: All tests passed!
```

Final `git diff --check`: exit 0, no output.
Final `git status --short`:

```text
 M test/core/content/content_seed_version_test.dart
?? docs/superpowers/plans/pwa-launch/evidence/seed-digest-test.md
```

The dirty patch consists only of the digest literal change shown above and this
new evidence file. No implementation, generated version, dependency, or content
source changed. No stop condition occurred. Process inspection during the slow
full test was unavailable in the sandbox; the test subsequently completed.
