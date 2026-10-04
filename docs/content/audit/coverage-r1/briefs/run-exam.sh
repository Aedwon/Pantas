#!/bin/zsh
A=/Users/aedwon/Documents/Projects/Pantas-wt-content-coverage-audit-r1; B=$A/docs/content/audit/coverage-r1/briefs; e=$1
codex exec -m gpt-6.1-sol -c model_reasoning_effort=high -c 'notify=[]' --disable computer_use --disable browser_use --disable browser_use_external --disable in_app_browser -s workspace-write -C $A -o $B/t2-requirements-$e-result.md "$(cat $B/t2-requirements-$e.md)" < /dev/null > $B/t2-requirements-$e.log 2>&1
echo "$e exit=$?"; ls -la $A/docs/content/audit/coverage-r1/requirements/$e.md 2>&1
