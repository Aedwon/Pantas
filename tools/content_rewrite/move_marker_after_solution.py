# Moves the ILLUSTRATION marker inside one worked example, unchanged, to the end
# of that example (just before the next heading). Standing content ruling: a
# figure before a solution must not show the answer or the method.
# Usage: python3 -I move_marker_after_solution.py <lesson.md> "### #5:" ["### #7:" ...]
import sys
path, heads = sys.argv[1], sys.argv[2:]
L = open(path).read().split('\n')
for head in heads:
    i0 = next(i for i, l in enumerate(L) if l.startswith(head))
    i1 = next(i for i in range(i0 + 1, len(L)) if L[i].startswith('#'))
    m = next(i for i in range(i0, i1) if L[i].startswith('<!-- ILLUSTRATION:'))
    marker = L.pop(m)
    if m < len(L) and L[m] == '' and L[m - 1] == '':
        L.pop(m)
    i1 = next(i for i in range(i0 + 1, len(L)) if L[i].startswith('#'))
    j = i1
    while L[j - 1] == '':
        j -= 1
    L[j:j] = ['', marker]
open(path, 'w').write('\n'.join(L))
