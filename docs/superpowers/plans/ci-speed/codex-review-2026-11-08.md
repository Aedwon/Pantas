Read-only review. Estimates below are forecasts, not measured results.

**1. Errors and weak assumptions**

- S1 addresses the measured problem. But “70% loading” includes waiting for compilation. It is not CPU time. Do not assume sixfold wall-time improvement.
- Android already takes approximately **8m22s including setup**. It sets the next limit. More test shards alone cannot deliver five minutes.
- S3’s shared `prepare` job adds a dependency before consumers start. It saves repeated computation, but may save **no wall time**. The claimed 50–90 seconds per job ignores that delay. See [setup-app](/Users/aedwon/Documents/Projects/Pantas-web-hidden-r1/.github/actions/setup-app/action.yml).
- S7 weakens verification by removing coverage from some pushes. Keep coverage on every required run.
- S4: calling `ci.yml` from `main.yml` still duplicates work if both retain push triggers. SHA-based cancellation also needs care: PR runs normally test a merge SHA.
- S6 misses dependencies. [Functions’ build](/Users/aedwon/Documents/Projects/Pantas-web-hidden-r1/functions/package.json:8) reads `content/exams/catalog.json`. App setup runs `tools/**`, but the Flutter filter lists only `tool/**`. Also include `build.yaml`, localization configuration, web assets, and shared configuration.
- S5: separate tests within one file remain sequential. Parallelizing presets also risks shared global state.
- S2’s 20-job budget is account-wide, not per workflow. Count journeys and overlapping runs. [GitHub limits](https://docs.github.com/en/actions/reference/limits).

**2. Missed improvements**

Savings are per affected job unless stated otherwise. They overlap.

| Change | Estimated saving | Risk |
|---|---:|---|
| Benchmark `flutter test -j 2`, `4`, `6`, `8` with coverage on identical file shards | 0–25% of shard time | CPU contention, memory pressure, timeouts. Compilation is serialized, so higher concurrency may lose. |
| Restore Flutter’s incremental `build/test_cache` | 0–60s/shard | Cache size and invalidation. Key by SDK, OS, dependencies and compiler options. Let Flutter recompile changed sources. This is a compiler seed, not cached test results. [Flutter source](https://github.com/flutter/flutter/blob/3.44.6/packages/flutter_tools/lib/src/test/test_compiler.dart). |
| Add Gradle dependency/task-output caching and enable the build cache | 1–3m/Android job | Plugin task cacheability; verify cold builds too. Neither exists in [Android CI](/Users/aedwon/Documents/Projects/Pantas-web-hidden-r1/.github/workflows/ci.yml:161). [Gradle guidance](https://github.com/gradle/actions/blob/main/docs/setup-gradle.md). |
| Reuse generated outputs across runs with complete input keys | 40–60s/cache hit | Stale generation. Include `tools/**`, localization inputs, SDK and lockfile. Benchmark against the `prepare` barrier. |
| Use several small bundles per shard | 30–120s/shard | Global-state leaks and serialized execution. Retain separate suites for sensitive tests. Bundling can reduce repeated coverage-collection overhead while preserving coverage. |
| Split emulator files across two independent jobs | 30–60s/Functions job | Low isolation risk across runners. Raising concurrency inside the existing shared project risks fixture collisions. |
| Cache emulator jars | About 10s | Low. Firebase documents [the cache location](https://firebase.google.com/docs/emulator-suite/install_and_configure). |

The 1.6 GB restore costs only 17 seconds. Avoiding it saves **at most 17 seconds before replacement download costs**. `cache: true` already caches the SDK. [Action documentation](https://github.com/subosito/flutter-action/blob/main/README.md).

Move repository scans and gitleaks ahead of app setup: approximately **1–2 minutes faster failure feedback**, little successful-run saving. Keep standard runners. [Larger runners cost money](https://docs.github.com/en/billing/concepts/product-billing/github-actions).

**3. Recommended order and expected wall time**

1. Capture Ubuntu baselines, test identities and coverage. Remove duplicate triggers: **about 26 minutes**, less duplicated compute.
2. Introduce six balanced file shards: **8.5–11 minutes**.
3. Add Gradle caching and tune test concurrency: **6–9 minutes**.
4. Try 8–12 shards and generation/compiler caches: **5–8 minutes warm**. Budget **8–10 minutes cold**.
5. Optimize real waits and content fixtures. Try small bundles only if needed: **5–7 minutes is plausible**, under five remains unproven.

**4. Guards against silently losing tests**

- Compare same-commit test identities, outcomes and skips. Counts alone can hide omissions, duplicates and synthetic loading events.
- Verify exact file partitioning. Reject empty shards. Pass paths as arguments safely.
- Require every shard’s fresh coverage artifact. Compare covered lines and the coverage denominator, not just percentage.
- Make `ci-ok` run with `always()`. Fail on failed, canceled or unexpectedly skipped dependencies, including coverage.
- Preserve platform annotations. [The browser-only database test](/Users/aedwon/Documents/Projects/Pantas-web-hidden-r1/test/core/storage/data/database_opener_web_test.dart:5) already does not run in VM CI.
- Keep CLI fixture tests exercising the CLI. Copy shared database fixtures before mutation.
