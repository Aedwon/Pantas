#!/usr/bin/env python3
"""PreToolUse hook for Bash: refuse commands that write files or run inline scripts.

Agents in this project change files with the Edit or Write tool. A shell write
(heredoc, "> file", tee, sed -i, python -c and the like) asks Aedwon for
approval and has left workers waiting on him (docs/workflow/process-improvement.md,
Nov 26). This hook refuses those commands before the prompt, and tells the agent why.

Reads the hook JSON on stdin. Prints a deny decision, or nothing to allow.
Fails open: if the input cannot be read, the command goes on to the normal
permission check.

Known limit: text inside quotes is ignored, so a write hidden inside a quoted
command substitution ("$(python3 -c ...)") passes. That keeps quoted git commit
messages and grep patterns that contain ">" or "<<" from being refused. If that
gap is ever used, parse "$(...)" inside double quotes as well.
"""
import json
import re
import sys

MESSAGE = (
    "Refused by project hook: change files with the Edit or Write tool; "
    "Bash is for read-only commands and git only."
)
SAFE_TARGETS = {"/dev/null", "/dev/stdout", "/dev/stderr"}
REDIRECT = re.compile(r"&?\d*>>?\|?(&?)[ \t]*([^\s;&|()<>]*)")
SEPARATORS = re.compile(r"[;&|()`\n]")


def skeleton(command):
    """Replace each quoted string with Q and each escaped character with _."""
    out = []
    i, n = 0, len(command)
    while i < n:
        c = command[i]
        if c == "\\" and i + 1 < n:
            out.append("_")
            i += 2
        elif c == "'":
            end = command.find("'", i + 1)
            out.append("Q")
            i = n if end < 0 else end + 1
        elif c == '"':
            j = i + 1
            while j < n and command[j] != '"':
                j += 2 if command[j] == "\\" else 1
            out.append("Q")
            i = j + 1
        else:
            out.append(c)
            i += 1
    return "".join(out)


def options(tokens):
    """The option tokens that follow a program name, up to its first argument."""
    for tok in tokens:
        if not tok.startswith("-"):
            return
        yield tok


def inline_script(name, rest):
    """Return a rule name when this program call runs an inline script or edits in place."""
    if re.fullmatch(r"python[\d.]*", name):
        if any(t == "-" or re.match(r"-[A-Za-z]*c", t) for t in options(rest)):
            return "python -c or -"
    elif name == "perl":
        if any(re.match(r"-[A-Za-z]*[eEi]", t) for t in options(rest)):
            return "perl -e or -i"
    elif name in ("node", "nodejs"):
        if any(re.fullmatch(r"-[A-Za-z]*[ep]|--eval|--print", t) for t in options(rest)):
            return "node -e"
    elif name in ("sh", "bash", "zsh", "dash", "ksh"):
        if any(re.match(r"-[A-Za-z]*c", t) for t in options(rest)):
            return name + " -c"
    elif name == "sed":
        if any(re.match(r"-[A-Za-z]*i|--in-place", t) for t in rest):
            return "sed -i"
    elif name == "tee":
        if any(not t.startswith("-") and t not in SAFE_TARGETS for t in rest):
            return "tee into a file"
    return None


def refusal(command):
    """Return the rule a command breaks, or None when it may run."""
    sk = skeleton(command)
    if "<<" in sk:
        return "heredoc"
    for match in REDIRECT.finditer(sk):
        dup, target = match.groups()
        if dup and target.isdigit():
            continue  # 2>&1, 1>&2
        if target not in SAFE_TARGETS:
            return "output redirection to a file"
    for segment in SEPARATORS.split(sk):
        tokens = segment.split()
        for index, tok in enumerate(tokens):
            rule = inline_script(tok.rsplit("/", 1)[-1], tokens[index + 1 :])
            if rule:
                return rule
    return None


def main():
    try:
        data = json.load(sys.stdin)
        command = data["tool_input"]["command"]
    except Exception:
        return 0
    rule = refusal(command)
    if rule:
        json.dump(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": "%s (Matched: %s.)" % (MESSAGE, rule),
                }
            },
            sys.stdout,
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
