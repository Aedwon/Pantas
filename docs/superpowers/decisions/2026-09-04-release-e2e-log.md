# Release E2E design decisions

## 4 September 2026: balanced suite complexity

The release E2E program was classified as architectural because the repository has
the Flutter integration-test dependency and a CI placeholder, but no top-level
release harness or execution contract.

Three scopes were offered:

- Minimal: local app journeys only. This would take about one to two days. It
  would leave the Firebase sync seam covered only by lower-level tests.
- Balanced: four to six local journeys, Firebase Emulator coverage where it can
  make an honest claim, one local runner, and documented Play-only gaps. This
  would take about three to five days.
- Hardened: broader lifecycle coverage, process-death tooling, and deeper emulator
  coverage. This would take about one to two weeks and add more maintenance and
  flake risk.

Codex recommended balanced because it covers the highest-risk local and sync
seams without creating a large device harness.

Aedwon chose balanced:

> proceed with balanced

## 4 September 2026: mock interruption and resume stop

The design audit found a production defect in the frozen Android beta candidate
`b642e2d169e0a03120d4f71cc6e10a6148cc5ef0`.

Reproduction:

1. Start a mock exam.
2. Answer and flag one or more questions.
3. Leave the mock or terminate and relaunch the app.
4. Return to the Quiz tab and try to resume the mock.

The candidate cannot preserve this journey:

- A started mock is stored with user ID `local`, while the Quiz tab checks for an
  in-progress mock using the authenticated user's ID or an empty ID. The started
  attempt is therefore not found through the production panel path.
- Answers, flags, elapsed time, and the current question remain only in the
  in-memory controller. The persistence scheduler and repository flush operation
  are not connected to the production mock route.
- The Quiz tab's Resume action opens the normal quiz resume route. It does not
  restore a mock attempt. The existing mock resume use case and resume sheet are
  not connected to a production route.

Severity: beta blocker for interrupted mock exams because learner work can be
lost and the advertised Resume action cannot restore the mock.

Exact release test that would fail: the planned Android scenario
`mock_interruption_resume_test.dart`, covering start, answer, flag, supported
interruption, app relaunch, resume, state verification, submit, and results.

This is candidate application behavior, not missing E2E infrastructure. The
release E2E program stopped before writing its design spec or implementation, as
required. The defect needs a separately authorized narrow beta repair. The frozen
candidate and its signed Task 14 artifact remain unchanged until that repair is
accepted and rebuilt.

## 5 September 2026: resume against the combined candidate

The mock-resume repair was completed outside the Release E2E branch and combined
with the accepted RevenueCat repair. Aedwon resumed this program with this exact
instruction:

> Resume the paused balanced Release E2E program against exact combined candidate `0f69e79c9a13daaf7198eae62706f09dd9822ab5`. The mock-resume repair commit is `7a5257ec76d15bcc6158b450b667bb100625383b`; its other parent is the accepted RevenueCat candidate `e9f9ad6537d1573642e5d0e763cf858d01862aae`. The combined candidate passed analyzer, 269 focused tests, the full 2,862-test Flutter suite, 31 Functions tests, and 11 RevenueCat behavior tests. Revalidate the exact refs and ancestry yourself before moving the E2E worktree. Preserve the existing uncommitted Release E2E decision log and all prior design evidence. Continue the previously selected balanced E2E design and implementation from this exact SHA. Do not modify `main`. Do not build a replacement AAB yet. Do not upload to Google Play. If E2E finds another production defect, stop and report it instead of changing production behavior in the E2E task. When E2E is accepted, report the exact accepted SHA and hand back for the final replacement signed Task 14 AAB build and full reverification.

Revalidation found:

- `0f69e79c9a13daaf7198eae62706f09dd9822ab5` is a merge commit whose
  first parent is `e9f9ad6537d1573642e5d0e763cf858d01862aae` and whose second
  parent is `7a5257ec76d15bcc6158b450b667bb100625383b`.
- Both parents descend directly from the old frozen candidate
  `b642e2d169e0a03120d4f71cc6e10a6148cc5ef0`.
- Current GitHub Issue #21 names `0f69e79c9a13daaf7198eae62706f09dd9822ab5`
  as the exact combined local candidate. It also records that the remote beta ref
  remains at the RevenueCat parent because no push was authorized.
- `origin/main` remains unchanged at
  `b642e2d169e0a03120d4f71cc6e10a6148cc5ef0`.

The isolated `codex/release-e2e-r1` branch was fast-forwarded from the old
candidate to the exact combined candidate. The uncommitted decision log remained
present. No other worktree, branch, remote ref, AAB, or external system changed.

## 5 September 2026: content strategy

Three strategies were considered:

- Shipping content only: strongest release fidelity, but every behavioral test
  would be tied to the approved corpus and would break when that corpus changes.
- Fixture content only: smallest and most stable, but it would not prove that the
  approved bundled database can install, open, and support a real first run.
- Hybrid: one cold-start journey uses the exact approved shipping database, while
  behavioral journeys use a tiny deterministic database through the production
  schema and loading path. This adds one fixture build step, but it separates
  release-asset proof from stable behavior proof.

Codex recommended the hybrid strategy.

Aedwon approved it and added guardrails:

> Approved. Use the hybrid approach.
>
> Guardrails:
>
> - The cold-start test must use the exact approved shipping `content.db` for the current combined candidate and verify its expected SHA before launch.
> - The tiny deterministic fixture DB should use the same production schema/loading path, not a test-only substitute that bypasses real app behavior.
> - Keep the fixture minimal, deterministic, repo-reproducible, and independent of production content changes.
> - Do not duplicate production logic just to make the tests pass.
>
> Proceed with the next design section.

Decision: use the hybrid strategy. The runner verifies the approved shipping
database SHA before any device launch. The fixture is generated from a small,
tracked source in the production export shape through the production seed
writer. It is then installed and opened through the production bundle loader
and content database opener. Tests do not reimplement content insertion or
application bootstrap logic.

## 5 September 2026: three-layer architecture

The balanced architecture separates local Android journeys, Firebase Emulator
behavior, and manual Play acceptance. Local tests use the production UI and
on-device persistence. Emulator tests are limited to current Auth and Firestore
gateways, current rules, and reconciliation behavior. Play-dependent behavior is
recorded but not automated. One local runner owns prerequisites and isolation.

Aedwon approved the architecture and added these guardrails:

> Approved. The three-layer architecture looks right.
>
> Proceed with these guardrails:
>
> - For the shipping-content cold-start test, verify the expected `content.db` SHA against the exact current combined candidate before treating `eb3a9da...` as authoritative. Fail closed if provenance/hash differs.
> - For deterministic journeys, track the minimal fixture source inputs, then generate/install/open them through the production seed-writer → installer → database-opener path. Do not maintain a hand-crafted parallel database implementation.
> - Keep the Firebase Emulator layer limited to behavior it can honestly prove: production Auth/Firestore gateways, reconciliation, and current security rules. Explicitly record Functions coverage as deferred rather than simulated.
> - Do not rely on an accidental CI-discovery loophole as a permanent contract. Keep the suite explicitly local/release-candidate driven and document why hosted device execution remains disabled; avoid broad workflow changes unless necessary.
> - App-tree reconstruction may prove persisted-state restoration, but do not label it process-death coverage. Keep true Android process death as the separate ADB preflight.
> - The runner should isolate every scenario, clear state deterministically, fail on missing prerequisites, and never require production credentials or network services.
>
> Proceed to the next design section.

Decision: proceed with the three layers and these limits. Local-only execution is
an explicit release policy, not an effect of file placement. The design will add
a checked local-suite marker that keeps hosted workflows from running the device
suite unless a later decision expressly enables them. The suite will not add a
Functions substitute or claim process-death coverage.

## 5 September 2026: release scenario set

The balanced v1 set contains six journeys:

1. Exact shipping-content cold start, onboarding, offline learning, and persisted
   lesson completion.
2. Deterministic quiz completion, results, persisted attempt and review state,
   and restoration after app-tree reconstruction.
3. Deterministic mock interruption, reconstruction, production-route resume, and
   submission.
4. Anonymous local-data deletion through Settings.
5. Emulator-backed Auth and Firestore sync round trip between isolated local
   databases.
6. Emulator-backed conflict reconciliation and cross-user rules denial.

Assessment, bookmarks, notification routing, and force-update routing remain at
their existing lower-level seams. Functions, named-account deletion and export,
Google Sign-In, App Check, RevenueCat, Play, and true process death remain
deferred.

Aedwon approved this set and added these guardrails:

> Approved. The six-scenario set looks right.
>
> A few guardrails before you lock it:
>
> - Scenario 1 should fail explicitly if the candidate SHA or shipping `content.db` SHA does not match the expected release inputs. Do not silently regenerate or substitute content.
> - Scenario 3 should verify the repaired mock contract end to end: same attempt identity, persisted answers/flags/timing, production resume route, and successful submit after reconstruction. Keep the claim as interruption/reconstruction coverage, not true process death.
> - Scenario 4 should distinguish local anonymous-data deletion from any cloud/account-deletion semantics. Verify exactly what Settings promises for an anonymous user, and do not overclaim named-account deletion coverage.
> - Scenario 5 may provision the emulator user/Pro state through test setup, but the actual sync must use the production Auth/Firestore gateways and production rules. Do not simulate gateway behavior.
> - Scenario 6 should prove both reconciliation correctness and hard cross-user denial under the actual emulator rules.
> - Keep the deferred list explicit in the final design so passing this suite cannot be interpreted as Task 15 completion.
>
> Otherwise, lock these six scenarios and proceed to the next design section.

Decision: lock the six journeys with these exact proof limits. Emulator setup may
create the prerequisite identity, Pro claim, generation, and starting documents.
All behavior under test uses the real client SDK, production gateways, and current
rules. The final evidence must state that the suite is pre-Play evidence and does
not complete Task 15.

## 5 September 2026: runner isolation and hosted CI

The runner design uses one local command, validates release provenance and pinned
tools before launch, resets every scenario independently, and limits network use
to local Android and Firebase Emulator endpoints. Fixture databases are generated
from tracked source inputs by the production seed writer, then passed through the
production installer and opener. Generated files and failure artifacts stay
untracked.

Three CI treatments were considered:

- Remove the dormant macOS integration job. This makes the local-only policy
  explicit and prevents future hosted device cost, but removes the placeholder.
- Keep the job with a permanent disabled condition and comment. This is a smaller
  change, but leaves dead workflow configuration.
- Keep the current discovery pattern and place tests where its glob misses them.
  This changes no workflow text, but makes the policy accidental and fragile.

Codex recommended removing only the dormant job.

Aedwon approved and adjusted the runner contract:

> Approved. Remove the dormant macOS integration job.
>
> Guardrails:
>
> - Remove only the dormant hosted integration/device-test job. Do not alter unrelated CI behavior.
> - Before removal, verify that no required check, workflow dependency, documentation, or release gate depends on that job name.
> - Document that Release E2E is intentionally local/release-candidate only and is run through `tools/release/test_e2e.sh`.
> - Validate the resulting workflow syntax/config after the edit.
> - Do not replace the removed job with another hosted emulator/device job.
>
> One runner-design adjustment: do not permanently hard-code the current candidate SHA into a reusable script. Require the expected candidate SHA as an explicit release input/argument and fail if the checked production base does not match it. The same principle should apply to release-specific provenance values where practical.
>
> Otherwise, the runner/isolation design is approved. Proceed.

Decision: remove only the dormant macOS integration job after proving that no
required check or repository contract depends on it. The reusable runner accepts
the expected candidate SHA and shipping database SHA as explicit release inputs.
It validates them and fails closed. It does not embed today's release identity as
a permanent script constant.

## 5 September 2026: execution and failure contract approved

The final runner contract requires immutable candidate, content digest, and device
inputs. It verifies candidate ancestry and rejects product changes outside the
approved E2E surface. It runs scenarios independently, treats cleanup failure as
fatal, and records safe text diagnostics. The emulator layer uses only a local
demo project. It never uses production credentials or endpoints.

Aedwon approved the contract and added final guardrails:

> Approved. The execution and failure contract looks right.
>
> A few final guardrails:
>
> - Treat `--candidate`, `--content-sha`, and `--device` as immutable run provenance and print them clearly at the start and end of the run.
> - Verify the checked-out E2E branch contains the candidate as an ancestor, but also fail if production-code files differ from that candidate outside the explicitly allowed E2E/test/runner/docs surface.
> - For the shipping database check, verify the full SHA plus the tracked digest/version prefix and fail closed on any mismatch. Do not regenerate it in the shipping-content scenario.
> - Emulator startup must use only local Auth and Firestore endpoints under the `demo-` project. Reject accidental production Firebase project IDs or credentials.
> - Cleanup failure should remain fatal because dirty emulator/device state can invalidate subsequent scenarios.
> - Diagnostics should include enough per-scenario provenance and failure context to reproduce locally, but must not dump secrets, tokens, or sensitive user data.
> - Keep screenshot/video capture out of this v1 runner as designed; manual visual/device acceptance remains separate.
> - Validate removal of the dormant CI job with YAML parsing plus the repository’s existing workflow/static checks.
>
> Otherwise, this contract is approved. Proceed to finalize the design/spec.

Decision: finalize the written design with these guardrails. The runner prints the
three immutable inputs before any mutation and repeats them in its final summary.
It rejects unexpected product diffs, non-demo Firebase identities, production
credentials, unsafe diagnostics, and incomplete cleanup.

## 5 September 2026: written design approved for handoff

Aedwon approved the written design and stopped the program before planning or
implementation:

> The written Release E2E design spec is approved.
>
> Do not create the implementation plan and do not begin implementation.
>
> For handoff to the ChatGPT Web coordinator:
>
> 1. Commit the approved design spec and the existing Release E2E decision/evidence documents only.
> 2. Push that documentation-only commit to the existing Release E2E branch.
> 3. Do not modify production code, tests, CI, fixtures, runners, candidate refs, beta refs, or main.
> 4. Do not build an AAB or perform any Play action.
> 5. Preserve the exact candidate under test:
>    0f69e79c9a13daaf7198eae62706f09dd9822ab5
> 6. Report:
>    - branch name
>    - exact documentation commit SHA
>    - paths committed
>    - confirmation that no implementation changes were included
>
> Then stop.

Decision: commit and push only the approved design, decision log, and research
evidence on `codex/release-e2e-r1`. The exact candidate remains the parent of the
documentation commit. Planning and implementation remain deferred to the
coordinator.
