# Pantas Level 4 lesson audit, packet {{PACKET}}, role {{ROLE}}

Your whole job is in one file. Read it in full and follow it exactly.

- Repository: `Aedwon/Pantas`
- Commit: `{{COMMIT}}` (branch `docs/content-coverage-audit-r1`)
- File: `docs/content/audit/coverage-r1/level4/packets/{{PACKET}}.md`
- Your role: `{{ROLE}}`
- Your attempt number: `{{ATTEMPT}}`

Rules for this assignment:

1. Read that file at that commit through GitHub. Read no other Pantas file, and
   no other Issue or pull request in any repository, apart from the relay
   instructions your worker contract names. Another reader is checking the same
   lesson separately, and the audit depends on you not seeing each other's work.
2. You audit and report. You do not edit, create, or delete any file, and you
   make no relay request other than the two hand-in requests the packet gives.
3. You hand in by following the packet's "How to hand in" section, with role
   `{{ROLE}}` and attempt `{{ATTEMPT}}` wherever it says `ROLE` and `ATTEMPT`.
   Nobody reads your chat reply.
4. The Pantas startup rule asks workers to read `AGENTS.md`, `WORKFLOW.md`, and
   `SUBAGENTS.md`. For this assignment the packet already carries every rule
   that applies, so do not read them.
5. When the hand-in check answers `ACCEPTED`, publish your completed worker
   event with the summary "form accepted" and nothing else about the lesson. Use
   `{{COMMIT}}` for `base_sha` and `head_sha`, an empty `commits` list, and
   "hand-in check answered ACCEPTED" as the verification.
6. If the check answers `HELD`, `STOPPED`, or `BAD REQUEST`, publish a blocked
   worker event with that word as the blocker code, and stop.
