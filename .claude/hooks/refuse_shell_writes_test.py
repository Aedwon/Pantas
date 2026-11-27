#!/usr/bin/env python3
"""Feeds sample Bash commands to refuse_shell_writes.py and checks each verdict.

Run from the repository root:  python3 .claude/hooks/refuse_shell_writes_test.py
Exit 0 when every sample gets the expected verdict, 1 otherwise.
"""
import json
import subprocess
import sys
from pathlib import Path

HOOK = Path(__file__).with_name("refuse_shell_writes.py")

BLOCKED = [
    "cat > notes.txt <<'EOF'\nhi\nEOF",
    "python3 - <<'EOF'\nprint(1)\nEOF",
    "cat <<EOF\nhi\nEOF",
    "echo hi > out.txt",
    "echo hi >> out.txt",
    "ls 2> err.log",
    "ls &> all.log",
    "git status; echo done > /tmp/x",
    'echo hi > "out file.txt"',
    "grep -n foo lib/a.dart | tee result.txt",
    "grep -n foo lib/a.dart | tee -a result.txt",
    "sed -i '' 's/a/b/' file.md",
    "sed -i.bak 's/a/b/' file.md",
    "sed -Ei 's/a/b/' file.md",
    "sed --in-place 's/a/b/' file.md",
    "python3 -c 'print(1)'",
    'python -c "import os"',
    "cat x.py | python3 -",
    "cd lib && /usr/bin/python3 -c 'x'",
    "env python3 -c 'x'",
    "perl -pi -e 's/a/b/' f.md",
    "perl -e 'print 1'",
    "perl -i.bak -pe 's/a/b/' f.md",
    "node -e 'console.log(1)'",
    "node --eval 'console.log(1)'",
    "sh -c 'echo hi'",
    'bash -c "ls"',
    "bash -lc 'ls'",
    "zsh -c 'ls'",
    "find . -name '*.md' | xargs sh -c 'echo $0'",
]

ALLOWED = [
    "ls -la lib",
    'grep -rn "a > b" docs',
    "grep -rn 'x >> y' docs",
    "git status",
    "git log --oneline -5 2>&1",
    "git diff --stat origin/main...HEAD",
    'git commit -m "Refuse python -c, sed -i and > file in Bash"',
    "git commit -m \"$(cat <<'EOF'\nSubject\n\nBody\nEOF\n)\"",
    "git add .claude/settings.json && git commit -m 'msg' && git push origin HEAD:main",
    "git diff --quiet >/dev/null 2>&1",
    "ls 1>&2",
    "tool/flutter-locked.sh test test/foo_test.dart",
    "bash tool/flutter-locked.sh analyze",
    "dart run tool/checks/run_checks.dart",
    "dart run tools/import_questions/import_questions.dart --root content/questions/x >/dev/null 2>&1; echo \"exit: $?\"",
    'codex-pick exec --skip-git-repo-check "audit this" < /dev/null',
    "codex-pick --status",
    "gh pr view 12 --json state,mergeable",
    "gh api repos/Aedwon/Pantas/commits/main --jq .sha",
    "python3 tool/velocity/timer.py E-200 status",
    "python3 -m json.tool data.json",
    "python3 .claude/hooks/refuse_shell_writes_test.py",
    "sed -n '1,40p' lib/main.dart",
    "cat a.txt | head -5",
    "grep -c python3 notes.md",
    "find . -name '*.dart' | wc -l",
    "date -u",
]


def verdict(command):
    payload = json.dumps(
        {"hook_event_name": "PreToolUse", "tool_name": "Bash", "tool_input": {"command": command}}
    )
    result = subprocess.run(
        [sys.executable, str(HOOK)], input=payload, capture_output=True, text=True
    )
    if result.returncode != 0:
        return "error: exit %d %s" % (result.returncode, result.stderr.strip())
    if not result.stdout.strip():
        return "allow"
    decision = json.loads(result.stdout)["hookSpecificOutput"]["permissionDecision"]
    return decision


def main():
    failures = []
    for command in BLOCKED:
        got = verdict(command)
        if got != "deny":
            failures.append("expected deny, got %s: %r" % (got, command))
    for command in ALLOWED:
        got = verdict(command)
        if got != "allow":
            failures.append("expected allow, got %s: %r" % (got, command))
    for line in failures:
        print("FAIL " + line)
    total = len(BLOCKED) + len(ALLOWED)
    print("%d of %d samples correct" % (total - len(failures), total))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
