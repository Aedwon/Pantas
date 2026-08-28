# Firebase Runtime Auth R2 — Contract Amendment 1

## Reason

The Wave 2D plan said to remove `CloudProgressGateway` / `EmptyCloudProgressGateway` from the Auth domain if Auth no longer consumes them. At the assigned branch head, `lib/core/sync/cloud_progress_gateway.dart` still imports `lib/core/auth/auth_repository.dart` and implements that interface. Removing the declaration during Wave 2D would therefore require a Sync runtime change, which Wave 2D explicitly does not own.

## Coordinator ruling

For Wave 2D only:

- Keep the `CloudProgressGateway` interface declaration in `lib/core/auth/auth_repository.dart` as a temporary compatibility seam.
- Keep `EmptyCloudProgressGateway` if required for source/test compatibility.
- Remove `CloudProgressGateway` completely from `AuthRepository` construction and behavior:
  - no constructor parameter;
  - no stored field;
  - no cloud-progress call in credential-collision flow;
  - no meaningful-cloud/local booleans in `SignInResult.switchedToExisting`.
- Do not modify `lib/core/sync/cloud_progress_gateway.dart` in Wave 2D.
- Do not add any new Auth consumer of `CloudProgressGateway`.
- Wave 2E Sync owns relocating/redeclaring the interface in the Sync domain and removing the temporary Auth declaration once its implementation file is updated in the same wave.

## Task 4 override

This amendment supersedes only the Task 4 checklist item that says:

> Remove `CloudProgressGateway`/`EmptyCloudProgressGateway` from the Auth domain if no Auth consumer remains.

Replace that instruction with:

> Retain the interface declarations temporarily for Sync source compatibility, but remove them from `AuthRepository` dependencies and runtime behavior. Do not modify Sync runtime files in Wave 2D.

All other Wave 2D design, plan, scope, and verification requirements remain unchanged.
