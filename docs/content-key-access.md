# Local protected-content key access

Recorded September 10, 2026, at Aedwon's request. This note contains paths and
loading instructions only. It does not grant permission to use credentials,
regenerate a package, run device tests, deploy, commit, or push.

## Existing keys on Aedwon's Mac

- Bootstrap: /Users/aedwon/.pantas-production-keys/content-bootstrap-v1.b64
  Environment variable: PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64
- Signing seed: /Users/aedwon/.pantas-production-keys/content-signing-v1.seed.b64
  Environment variable: PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64

E04 reported that both files were saved permanently as canonical Base64 encoding
32 bytes, with file permissions 0600 and directory permissions 0700. These
permissions were not rechecked for this documentation change. Both existing keys
were successfully used for the E05 package build and verification on September 9.

## After permission is granted

Read the assigned stage's instructions first. Use only the named files. Do not
search for replacements or create new keys if either is unavailable. Report the
missing prerequisite without exposing values.

For verification and protected app testing, load only the bootstrap key into the
same zsh process that will run the authorized command:

```zsh
unsetopt XTRACE VERBOSE
export PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64="$(< /Users/aedwon/.pantas-production-keys/content-bootstrap-v1.b64)"
[[ -n "$PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64" ]] && printf 'bootstrap: present\n' || printf 'bootstrap: missing\n'
```

Only an explicitly authorized package build needs the signing seed as well:

```zsh
export PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64="$(< /Users/aedwon/.pantas-production-keys/content-signing-v1.seed.b64)"
[[ -n "$PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64" ]] && printf 'signing: present\n' || printf 'signing: missing\n'
```

Run the authorized tool in that same process. Separate agent shell calls do not
inherit exports from a previous call. A Codex CLI launched from this Terminal
inherits them; an already-running desktop task does not.

Environment loading alone does not pass a key into Flutter compile-time defines.
Use the stage's reviewed runner and required build inputs. Never expand a key into
a user-visible command or enable verbose output that exposes build arguments.
Do not print, inspect for display, copy into chat, or commit either value. Do not
use env, printenv, shell tracing, or diagnostic environment dumps.

When finished, clear the variables, including on command failure:

```zsh
unset PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64
unset PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64
```

Prefer a scoped shell with an EXIT trap when automating cleanup.

## Package identity and E09

Key access is not permission to rebuild the accepted package. Preserve the exact
content.db, manifest, and detached signature required by the current assignment.
Regeneration changes artifact identity and invalidates affected stage evidence.

As observed September 10, local and remote E09 source matched at
645646f3f6b908c5f18b8c82a2462e8bbce15db0. Its latest commit adds Android emulator
rehearsal work. The governing E09 gate requires physical-device security and
lower-end performance evidence. This note does not claim that gate passed.
