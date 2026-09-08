# E04 R3 Plan Self-Review

- Spec coverage: manifest v2/runtime verifier, first protected install/open, device-local accepted-package state, crash-safe promotion, exact E02 migration, key-loss recovery, bootstrap/provider ordering, analyzer debt, and full E04 verification are each assigned to a task.
- TDD: Tasks 1–5 require meaningful RED evidence before production behavior changes and GREEN evidence afterward.
- Scope: E05+, pricing, production secret provisioning, `main`, deployment, final AAB, and Play are explicitly excluded.
- Production-key boundary: fixture-owned ephemeral keys are permitted; production acceptance remains blocked on the authorized Ed25519 public verification key.
- No placeholders: implementation semantics come from the approved E03 spec and E04–E14 release plan; any exact file discovered absent at the base is created under the paths named in the release plan rather than replaced with a new subsystem.
- Type/interface consistency: frozen `ContentKeyStore`, `ContentPackageVerifier`, `ensureProtectedContentInstalled`, and `openProtectedContentDatabase` remain the implementation interfaces.

This review adds no implementation authorization beyond the existing E04 bounded lane.