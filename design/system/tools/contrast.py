"""Pantas contrast check. Product path: tools/contrast.py [--table FILE] [BUNDLE]. Writes the README contrast table to FILE when given.
History: r2 contrast_r2.py, round 3 contrast_r3.py (dialog hover wells, composited red hover, data marks on accent, hero gradient,
hover-equals-ground check), round 4 (state washes read opacity-hover, promo card rows).
Round 2 contrast table (README) plus the ground check from R2-O05: every color a component sets inside a rule
whose background is accent-tint, danger-tint or fill (and that rule's descendants) is tested on that ground."""
import json, sys, re, os
def _h2r(h): h = h.lstrip('#'); return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))
def _r2h(c): return '#%02X%02X%02X' % tuple(max(0, min(255, round(x))) for x in c)
def _lin(c): c = c / 255; return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
def _lum(h): r, g, b = _h2r(h); return 0.2126 * _lin(r) + 0.7152 * _lin(g) + 0.0722 * _lin(b)
def cr(a, b): la, lb = _lum(a), _lum(b); return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
def mix(a, b, t): A, B = _h2r(a), _h2r(b); return _r2h(tuple(A[i] + (B[i] - A[i]) * t for i in range(3)))
P = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
args = [a for a in sys.argv[1:]]
OUT = args[args.index('--table') + 1] if '--table' in args else None
if '--table' in args: i = args.index('--table'); del args[i:i + 2]
d = json.load(open(P + '/tokens.json'))
OPA = {t['name']: float(t['value']) for t in d['opacity']['tokens']}
C = {t['name']: t for t in d['color']['tokens']}
def res(n, th):
    v = C[n]['value']; v = v if isinstance(v, str) else v.get(th, v.get('light'))
    return res(v[1:-1], th) if v.startswith('{') else v
def ground(bg, th):
    # "a@b" = alpha color a over b; "a%opacity-hover@b" = color a at the opacity token over b (a state wash, R4-O05)
    if '%' in bg:
        a, rest = bg.split('%'); op, b = rest.split('@')
        return mix(ground(b, th), res(a, th)[:7], OPA[op])
    if '@' in bg:
        a, b = bg.split('@'); base = ground(b, th); top = res(a, th)
        return mix(base, top[:7], int(top[7:9], 16) / 255) if len(top) == 9 else top
    return res(bg, th) if not bg.startswith('#') else bg
def flat(fg, bg, th):
    b = ground(bg, th); f = res(fg, th) if not fg.startswith('#') else fg
    if len(f) == 9: f = mix(b, f[:7], int(f[7:9], 16) / 255)
    return f, b
EX_SUP = 'Exempt: supplementary, the number is always printed (WCAG 1.4.11)'
P_ = [
('Primary text on page', 'text-primary', 'bg-page', 4.5, '', ''),
('Primary text on card', 'text-primary', 'surface-card', 4.5, '', ''),
('Primary text on dialog and sheet', 'text-primary', 'surface-modal', 4.5, '', 'D114'),
('Primary text on fill (neutral button)', 'text-primary', 'fill', 4.5, '', ''),
('Selected text (::selection)', 'text-primary', 'accent-tint', 4.5, '', 'D116'),
('Secondary text on page', 'text-secondary', 'bg-page', 4.5, '', ''),
('Secondary text on card', 'text-secondary', 'surface-card', 4.5, '', 'D47'),
('Secondary text on dialog and sheet', 'text-secondary', 'surface-modal', 4.5, '', 'D114'),
('Secondary text on card footer', 'text-secondary', 'surface-inset', 4.5, '', ''),
('Secondary text on hover well', 'text-secondary', 'surface-hover', 4.5, '', ''),
('Primary text on dialog hover well', 'text-primary', 'surface-modal-hover@surface-modal', 4.5, '', 'D121'),
('Secondary text on dialog hover well', 'text-secondary', 'surface-modal-hover@surface-modal', 4.5, '', 'D121'),
('Completed row title, selected', 'text-on-tint-secondary', 'accent-tint', 4.5, '', 'D122'),
('Text on fill: gray tag, segment labels', 'text-on-fill', 'fill', 4.5, '', 'D52'),
('Selected row subtitle and value', 'text-on-tint-secondary', 'accent-tint', 4.5, '', 'D53, D98 CHANGE'),
('Supporting text on the selected card', 'text-on-tint-secondary', 'accent-tint', 4.5, '', 'D190 CHANGE (was text-secondary, 4.38:1)'),
('Link on page', 'accent', 'bg-page', 4.5, '', ''),
('Link on card', 'accent', 'surface-card', 4.5, '', ''),
('Link on hover well', 'accent', 'surface-hover', 4.5, '', ''),
('Link hover on card', 'accent-hover', 'surface-card', 4.5, '', ''),
('Teal text on tint; active tab label', 'accent-tint-text', 'accent-tint', 4.5, '', ''),
('Tonal hover label', 'accent-hover', 'accent-tint-hover', 4.5, '', ''),
('Label on primary', 'on-accent', 'accent-fill', 4.5, '', ''),
('Label on primary hover', 'on-accent', 'accent-fill-hover', 4.5, '', ''),
('Key hint in a primary button', 'on-accent', 'kbd-on-fill@accent-fill', 4.5, '', 'D10'),
('Red text on card', 'danger-text', 'surface-card', 4.5, '', ''),
('Red text on page', 'danger-text', 'bg-page', 4.5, '', ''),
('Red text on wrong wash', 'danger-text', 'danger-tint', 4.5, '', ''),
('Red ghost hover label on its wash, card', 'danger-text-hover', 'danger-text-hover%opacity-hover@surface-card', 4.5, '', 'D123 CHANGE'),
('Red ghost hover label on its wash, dialog', 'danger-text-hover', 'danger-text-hover%opacity-hover@surface-modal', 4.5, '', 'D123 CHANGE'),
('Neutral button hover label (text-primary at opacity-hover over fill)', 'text-primary', 'text-primary%opacity-hover@fill', 4.5, '', 'D168'),
('Tertiary hover label on its wash, card', 'text-primary', 'text-primary%opacity-hover@surface-card', 4.5, '', 'D168'),
('Teal tertiary hover label on its wash, card', 'accent-hover', 'accent-hover%opacity-hover@surface-card', 4.5, '', 'D168'),
('Promo secondary text on the card end', 'text-on-tint-secondary', 'surface-card', 4.5, '', 'D167 CHANGE'),
('Promo secondary text on its tint end', 'text-on-tint-secondary', 'accent-tint', 4.5, '', 'D167 CHANGE'),
('Promo primary text on its tint end', 'text-primary', 'accent-tint', 4.5, '', 'D167'),
('Red ghost label in a dialog', 'danger-text', 'surface-modal', 4.5, '', ''),
('Label on danger fill', 'on-danger', 'danger-fill', 4.5, '', ''),
('Label on danger hover', 'on-danger', 'danger-fill-hover', 4.5, '', ''),
('Primary text on right bar', 'text-primary', 'accent-bar', 4.5, '', ''),
('Primary text on wrong bar', 'text-primary', 'danger-bar', 4.5, '', ''),
('Primary text on segment thumb', 'text-primary', 'surface-segment-on', 4.5, '', ''),
('Pro mark text', 'on-pro', 'pro', 4.5, '', ''),
('Warning text on card', 'warning-text', 'surface-card', 4.5, '', 'D54'),
('Warning text on page', 'warning-text', 'bg-page', 4.5, '', ''),
('Warning tag text', 'warning-tint-text', 'warning-tint', 4.5, '', 'D54'),
('Toast message', 'toast-text', 'toast-bg', 4.5, '', 'D51'),
('Toast action', 'toast-action', 'toast-bg', 4.5, '', ''),
('Toast action on its hover well', 'toast-action', 'toast-action-hover@toast-bg', 4.5, '', ''),
('Reader body on card', 'reader-body', 'surface-card', 4.5, '', ''),
('Reader strong on card', 'reader-strong', 'surface-card', 4.5, '', ''),
('Reader note text on tint', 'reader-note-text', 'accent-tint', 4.5, '', ''),
('Reader mistake text on its tint', 'reader-mistake-text', 'reader-mistake-tint', 4.5, '', ''),
('Figure caption on figure scrim', 'figure-caption', 'figure-scrim@bg-page', 4.5, '', ''),
('Chart and axis labels on card', 'text-secondary', 'surface-card', 4.5, '', 'D105'),
('Disabled label on fill', 'text-disabled', 'fill', 4.5, 'Exempt: disabled control', ''),
('Focus ring on page', 'accent', 'bg-page', 3, '', ''),
('Focus ring on card', 'accent', 'surface-card', 3, '', ''),
('Field, search, select, white button ring on card', 'border-control', 'surface-card', 3, '', 'D45 CHANGE'),
('SelectableTile rest ring on card', 'border-control', 'surface-card', 3, '', 'D158 CHANGE'),
('SelectableTile rest ring on page', 'border-control', 'bg-page', 3, '', 'D158 CHANGE'),
('Control ring on page', 'border-control', 'bg-page', 3, '', ''),
('Control ring in a dialog', 'border-control', 'surface-modal', 3, '', 'D114'),
('Answer badge ring on card', 'border-control', 'surface-card', 3, '', 'D45 CHANGE'),
('Switch off ring on card', 'border-control', 'surface-card', 3, '', 'D45 CHANGE'),
('Not-started task marker on card', 'border-control', 'surface-card', 3, '', ''),
('Blank question chip ring on page', 'border-control', 'bg-page', 3, '', 'D97 CHANGE'),
('Blank question chip ring on card', 'border-control', 'surface-card', 3, '', 'D97 CHANGE'),
('Inactive nav icon on page', 'icon-muted', 'bg-page', 3, '', ''),
('Inactive nav icon on card', 'icon-muted', 'surface-card', 3, '', ''),
('Row chevron on card', 'icon-chevron', 'surface-card', 3, '', ''),
('Row chevron on hover well', 'icon-chevron', 'surface-hover', 3, '', ''),
('Selected row chevron on tint', 'accent-tint-text', 'accent-tint', 3, '', 'D98 CHANGE'),
('Figure viewer controls on scrim', 'figure-on-viewer', 'figure-scrim@bg-page', 3, '', ''),
('Wrong ring on wrong wash', 'danger', 'danger-tint', 3, '', ''),
('Wrong ring on card', 'danger', 'surface-card', 3, '', ''),
('Invalid field ring on card', 'danger', 'surface-card', 3, '', ''),
('Chart bar and line on card', 'accent', 'surface-card', 3, '', 'D105, D124 CHANGE'),
('Progress fill on its track', 'accent', 'fill', 3, '', 'D124 CHANGE'),
('Slider progress on its track', 'accent', 'fill', 3, '', 'D124 CHANGE'),
('Reader progress thread on its track', 'accent', 'fill', 3, '', 'D125'),
('Week done dot on card', 'accent', 'surface-card', 3, '', 'D124 CHANGE'),
('Hero title on the gradient start (large text)', 'on-hero', 'hero-start', 3, '', 'D126'),
('Hero body text on the middle stop', 'on-hero', 'hero-mid', 4.5, '', 'D126'),
('Hero icons on the gradient start', 'on-hero-secondary', 'hero-start', 3, '', 'D126'),
('Topic-done text on its end', 'on-hero', 'topic-done-end', 4.5, '', 'D126'),
('Search match highlight', 'accent-tint-text', 'accent-tint', 4.5, '', 'D127'),
('Tooltip text', 'toast-text', 'toast-bg', 4.5, '', 'D128'),
('Focus ring in a dialog', 'accent', 'surface-modal', 3, '', ''),
('Accuracy step 1 on its track', 'chart-1', 'fill', 3, EX_SUP, 'D46, D117'),
('Accuracy step 2 on its track', 'chart-2', 'fill', 3, EX_SUP, 'D117'),
('Accuracy step 3 on its track', 'chart-3', 'fill', 3, EX_SUP, 'D117'),
('Accuracy step 4 on its track', 'chart-4', 'fill', 3, EX_SUP, 'D117'),
('Accuracy step 5 on its track', 'chart-5', 'fill', 3, EX_SUP, 'D117'),
('Selected ring (accent) on card', 'accent', 'surface-card', 3, '', ''),
('Divider on card (decorative)', 'divider', 'surface-card', 3, 'Decorative: never a control boundary', ''),
('Strong divider on card (decorative)', 'divider-strong', 'surface-card', 3, 'Decorative: key-hint ring, hover ring', ''),
('Progress ring track on card', 'divider', 'surface-card', 3, 'Decorative: the number or status text is printed', ''),
('Skeleton on card', 'fill-skeleton', 'surface-card', 3, 'Decorative: a placeholder', 'D112'),
('Skeleton on hover well', 'fill-skeleton', 'surface-hover', 3, 'Decorative: a placeholder', 'D112'),
('Card on page (flat surface)', 'surface-card', 'bg-page', 3, 'Decorative: content identifies a card', ''),
('Dialog on dimmed card (dark: surface-modal on card under the scrim)', 'surface-modal', 'scrim@surface-card', 3, 'Not required: a dialog is identified by its content and elevation', 'D114'),
('Toast on dark page (raised gray plus 1px edge)', 'toast-bg', 'bg-page', 3, 'Not required: the toast has a 1px #4A4A4A edge in dark', 'D51'),
]
rows = ['| Pair | Light | Dark | Needs | Result | Exemption | Decision |', '|---|---|---|---|---|---|---|']
fails = []
for lab, fg, bg, need, ex, dec in P_:
    vals = []; ok = True
    for th in ('light', 'dark'):
        f, b = flat(fg, bg, th); c = cr(f, b); vals.append(c)
        if c < need: ok = False
    if not ok and not ex: fails.append(lab)
    rows.append('| %s (`%s` on `%s`) | %.2f | %.2f | %s:1 | %s | %s | %s |' % (lab, fg, bg.replace('@', ' over '), vals[0], vals[1], '3' if need == 3 else '4.5', 'Pass' if ok else 'Fail', ex, dec))
if OUT: open(OUT, 'w').write('\n'.join(rows) + '\n')
# ---- ground check (R2-O05) ----
BUNDLE = args[0] if args else P + '/components/bundle.css'
css = re.sub(r'/\*.*?\*/', '', open(BUNDLE).read(), flags=re.S)
css = css[css.find('/* @generated type:end */') if '/* @generated type:end */' in css else 0:]
rules = re.findall(r'([^{}@]+)\{([^{}]*)\}', css)
GROUNDS = ('accent-tint', 'danger-tint', 'fill')
TEXTY = re.compile(r'^(text-|accent|danger|on-|icon-|reader-|warning|toast-action|figure-caption)')
issues = []
def split(sel):
    out, depth, cur = [], 0, ''
    for ch in sel:
        if ch == '(': depth += 1
        elif ch == ')': depth -= 1
        if ch == ',' and depth == 0: out.append(cur.strip()); cur = ''
        else: cur += ch
    out.append(cur.strip()); return out
for sel, body in rules:
    m = re.search(r'background(?:-color)?:var\(--(%s)\)' % '|'.join(GROUNDS), body)
    if not m: continue
    g = m.group(1)
    for s1 in split(sel):
        base = re.sub(r':is\(\.is-hover[^)]*\)|:is\(:hover[^)]*\)', '', s1)
        for sel2, body2 in rules:
            for s2 in split(sel2):
                if s2 == s1 or s2.startswith(s1 + ' ') or s2.startswith(base + ' '):
                    if 'background' in body2 and s2 != s1 and re.search(r'background(?:-color)?:var\(--', body2): continue
                    for col in re.findall(r'(?<![-\w])color:var\(--([\w-]+)\)', body2):
                        if not TEXTY.match(col) or col not in C: continue
                        if col == 'text-disabled' or re.search(r'disabled', s2 + s1): continue
                        for th in ('light', 'dark'):
                            f, b = flat(col, g, th); c = cr(f, b)
                            need = 3 if col.startswith('icon-') or 'cv' in s2 or 'svg' in s2 or 'mark' in s2 else 4.5
                            if c < need: issues.append('%s on %s (%s): %.2f < %s  [%s]' % (col, g, th, c, need, s2[:80]))
# BEM children of a grounded block (for example .row__v inside a selected .row) sit on the same ground
for sel, body in rules:
    m = re.search(r'background(?:-color)?:var\(--(%s)\)' % '|'.join(GROUNDS), body)
    if not m: continue
    g = m.group(1)
    for s1 in split(sel):
        mb = re.match(r'\.([a-z0-9-]+)(?=[:.\[]|$)', s1)
        if not mb or ' ' in s1 or re.search(r'disabled|hover|active', s1): continue
        base = mb.group(1)
        for sel2, body2 in rules:
            for s2 in split(sel2):
                mc = re.match(r'\.(%s__[a-z0-9-]+)$' % re.escape(base), s2)
                if not mc: continue
                child = mc.group(1)
                over = any(s3.startswith(s1 + ' ') and child in s3 and 'color:' in b3 for sx, b3 in rules for s3 in split(sx))
                if over: continue
                for col in re.findall(r'(?<![-\w])color:var\(--([\w-]+)\)', body2):
                    if col not in C or not TEXTY.match(col) or col == 'text-disabled': continue
                    for th in ('light', 'dark'):
                        f, b = flat(col, g, th); c = cr(f, b)
                        need = 3 if col.startswith('icon-') or child.endswith(('cv', 'icon', 'mark', 'lead')) else 4.5
                        if c < need: issues.append('%s on %s (%s): %.2f < %s  [%s inside %s]' % (col, g, th, c, need, s2, s1[:60]))
# R3-O02: a hover or press well must differ from the ground it sits on (1.00:1 means no feedback).
WELLS = [('surface-hover', 'surface-card'), ('surface-modal-hover@surface-modal', 'surface-modal'), ('accent-tint-hover', 'accent-tint')]
for w, g in WELLS:
    for th in ('light', 'dark'):
        c = cr(ground(w, th), ground(g, th))
        if c < 1.03: issues.append('hover well %s equals its ground %s (%s): %.2f' % (w, g, th, c))
print('table rows', len(P_), 'unexempted fails:', fails)
print('ground check issues:', len(set(issues)))
for i in sorted(set(issues)): print('  ', i)
sys.exit(1 if fails or issues else 0)
