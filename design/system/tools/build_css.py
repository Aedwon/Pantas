"""Pantas build step for components/bundle.css. Product path: tools/build_css.py, run from anywhere:
   python3 tools/build_css.py --check   (default; writes nothing, exits 1 when the generated block or the tracking pairs differ from tokens.json; CI uses this)
   python3 tools/build_css.py --write [--out DIR]   (rewrites the generated block and the tracking pairs in bundle.css)
History: r2 build_css.py, round 3 build_css_r3.py (ruling 4, ruling 11, the R3-O09 weight check), round 4 (container widths, bottom reserves).
1. Writes the generated block (type custom properties, reader-scale overrides, margin reset, color-scheme, System theme)
   from tokens.json, so a type or color change reaches every component.
2. Pairs every font:var(--type-X) with letter-spacing:var(--tracking-X).
3. Checks: type declarations only through --type-*, no type-class name reused as a selector, no literal colors,
   every var() resolves, media queries use the bp-* values, spacing literals sit on the 2px grid or are listed internals.
   Round 4: every @container width is a layout-* or size-* token value or a listed Chart step, and no element above a pinned bar keeps a
   pixel bottom reserve of 100px or more (reserves are layout-reserve-* in rem, R4-O07).
4. With --out DIR, writes DIR/type-slots.md (the slot to style table) and DIR/internals.json (literal spacing per selector).
Exit code 1 on any check failure."""
import json, re, sys, os
P = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUTD = sys.argv[sys.argv.index('--out') + 1] if '--out' in sys.argv and '--write' in sys.argv else None
d = json.load(open(P + '/tokens.json'))
css = open(P + '/components/bundle.css').read()
WRITE = '--write' in sys.argv
ORIG = css
SCALED = {'web-question', 'web-reader-body', 'web-reader-block', 'web-explanation', 'web-option', 'phone-question', 'phone-reader-body', 'phone-option', 'phone-explanation'}
styles = [(g, s) for g in d['type']['groups'] for s in g['styles']]
names = [s['name'] for g, s in styles]

def size(s):
    v = s['fontSize']
    return 'calc(%s * var(--reader-scale,1))' % v if s['name'] in SCALED else v

def cval(v, th):
    if isinstance(v, dict): v = v.get(th, v.get('light'))
    m = re.match(r'^\{(.+)\}$', v)
    return 'var(--%s)' % m.group(1) if m else v

# ---------- 1. generated block ----------
g = ['/* @generated type:start */',
     '/* Written by tools/build_css.py from tokens.json. Type: font:var(--type-<style>) plus letter-spacing:var(--tracking-<style>). */',
     ':where(%s){margin:0}' % ','.join('.' + n for n in names)]
props = []
for grp, s in styles:
    fam = s.get('family', grp['family'])
    props.append('--type-%s:%s %s/%s var(--font-%s)' % (s['name'], s['fontWeight'], size(s), s['lineHeight'], fam))
    props.append('--tracking-%s:%s' % (s['name'], s.get('letterSpacing', 'normal')))
g.append(':root{%s}' % ';'.join(props))
g.append('/* Lesson text scale (R2-O02, ruling 4): the scaled styles are redeclared on every element, so --reader-scale set on any element '
         '(.reader, .focus, a question region) reaches every component inside it, and two readers can differ. Overlays reset it to 1. */')
sc = []
for grp, s in styles:
    if s['name'] in SCALED:
        fam = s.get('family', grp['family'])
        sc.append('--type-%s:%s %s/%s var(--font-%s)' % (s['name'], s['fontWeight'], size(s), s['lineHeight'], fam))
g.append(':where(*){%s}' % ';'.join(sc))
for grp, s in styles:
    if s['name'] in SCALED: g.append('.%s{font-size:%s}' % (s['name'], size(s)))
# Tier map (ruling 11)
TM = [(s['name'], s['phoneScale']) for grp, s in styles if s.get('phoneScale')]
ROOTS = '.shell,.focus,.reader'
NARROW = '.shell:not(.shell--desktop),.focus:not(.focus--split),.reader'
g.append('/* Tier map (ruling 11): inside a page root (%s) the type classes read their --type-* property; below 1024px each wide style takes '
         'its phoneScale style from tokens.json, so one markup serves the phone, tablet and wide tiers. */' % ROOTS)
for a, b in TM:
    g.append(':is(%s) .%s{font:var(--type-%s);letter-spacing:var(--tracking-%s)}' % (ROOTS, a, a, a))
g.append('@media (max-width:1023px){:is(%s),:is(%s) *{%s}}' % (NARROW, NARROW, ';'.join('--type-%s:var(--type-%s);--tracking-%s:var(--tracking-%s)' % (a, b, a, b) for a, b in TM)))
g = [x for x in g if x]
g.append('/* Themes (R2-O26): native controls, scrollbars and autofill follow the theme. With no data-theme, the page follows the OS (System). */')
g.append(':root,[data-theme="light"]{color-scheme:light}')
g.append('[data-theme="dark"]{color-scheme:dark}')
dark = ['color-scheme:dark']
for fam in ('color', 'shadow'):
    for t in d[fam]['tokens']:
        if isinstance(t['value'], dict) and t['value'].get('dark') != t['value'].get('light'):
            dark.append('--%s:%s' % (t['name'], cval(t['value'], 'dark')))
g.append('@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){%s}}' % ';'.join(dark))
g.append('/* @generated type:end */')
css = re.sub(r'/\* @generated type:start \*/.*?/\* @generated type:end \*/', lambda m: '\n'.join(g), css, flags=re.S)

# ---------- 2. tracking pairs ----------
def pair(m):
    n = m.group(1)
    return 'font:var(--type-%s);letter-spacing:var(--tracking-%s)' % (n, n)
gs, ge = css.index('/* @generated type:start */'), css.index('/* @generated type:end */')
body = css[ge:]
body = re.sub(r'font:var\(--type-([\w-]+)\)(;letter-spacing:var\(--tracking-[\w-]+\))?', pair, body)
css = css[:ge] + body
if WRITE: open(P + '/components/bundle.css', 'w').write(css)

# ---------- 3. checks ----------
err = []
src = re.sub(r'/\*.*?\*/', '', css[css.index('/* @generated type:end */'):], flags=re.S)
rules = []
containers = []
def walk(t, media=''):
    i = 0
    while i < len(t):
        j = t.find('{', i)
        if j < 0: break
        sel = t[i:j].strip(); depth = 1; k = j + 1
        while depth and k < len(t):
            if t[k] == '{': depth += 1
            elif t[k] == '}': depth -= 1
            k += 1
        inner = t[j + 1:k - 1]
        if sel.startswith('@media') or sel.startswith('@supports') or sel.startswith('@container'):
            if sel.startswith('@container'): containers.append(sel)
            walk(inner, sel)
        elif not sel.startswith('@keyframes'):
            rules.append((sel, inner, media))
        i = k
walk(src)
GLYPH = {'.slider__a', '.avatar--lg', '.cal small', '.date-cell', '.opt__badge', '.xcard__key', '.qnav__q', '.chart__y > span'}
slots = []
spacing = {}
SPACE_PROPS = re.compile(r'^(padding|margin|gap|row-gap|column-gap|inset)(-[a-z-]+)?$')
ODD_OK = {('.group__head', '7px'): 'phone board group header 0 16px 7px (x241)',
          ('.group__foot', '7px'): 'phone board group footer 7px 16px 0 (x46)',
          ('.sec-head--phone', '7px'): 'phone board section header 0 16px 7px (x241)',
          ('.row--phone .row__in', '11px'): 'phone board row 11px 16px 11px 0 (x280)',
          ('.opt--phone', '13px'): 'phone board answer row 13px 14px (x110)',
          ('.toast--phone', '13px'): 'phone board toast 13px 16px (x176)',
          ('.pro', '1px'): 'Pro mark optical height (boards)',
          ('.switch::before', '-7px'): 'touch hit area: (44 - 31) / 2, rounded up',
          ('.sr-only', '-1px'): 'standard visually-hidden pattern'}
for sel, body, media in rules:
    decls = [x.strip() for x in body.split(';') if ':' in x]
    used = []; weight = None; lh = None
    for dcl in decls:
        prop, val = [x.strip() for x in dcl.split(':', 1)]
        if prop == 'font':
            m = re.fullmatch(r'var\(--type-([\w-]+)\)', val)
            if m: used.append(m.group(1))
            elif val != 'inherit': err.append('raw font: %s { %s }' % (sel, val))
        elif prop == 'font-size':
            if sel not in ('.math', '.frac', '.tabbar__item'): err.append('raw font-size: %s { %s }' % (sel, val))
        elif prop == 'font-family':
            if sel not in ('.math',): err.append('raw font-family: %s' % sel)
        elif prop == 'line-height':
            if (val not in ('1',) or not any(sel == gsel for gsel in GLYPH)) and sel != '.frac': err.append('raw line-height: %s { %s }' % (sel, val))
            else: lh = val
        elif prop == 'letter-spacing':
            if not (val.startswith('var(--tracking-') or val == 'inherit'): err.append('raw letter-spacing: %s { %s }' % (sel, val))
        elif prop == 'font-weight':
            weight = val
            # R3-O09: a weight may change only for a state or a named emphasis modifier, never at rest
            if val != 'inherit' and not re.search(r'\.is-|\[aria-|:(hover|active|checked|disabled|indeterminate|focus|not)|--strong|\.field__opt|strong\b|\.today|^\.xcard__key$', sel):
                err.append('rest weight override: %s { font-weight:%s }' % (sel, val))
        if SPACE_PROPS.match(prop):
            for px in re.findall(r'(?<![\w.-])(-?\d*\.?\d+)px', re.sub(r'var\([^)]*\)', '', val)):
                v = px + 'px'
                if v in ('0px',): continue
                spacing.setdefault(sel, []).append((prop, v))
                if abs(float(px)) % 2 and (sel, v) not in ODD_OK:
                    err.append('off-grid spacing %s { %s: %s }' % (sel, prop, val))
        # literal colors
        val_nourl = re.sub(r'url\([^)]*\)', '', val)
        if re.search(r'#[0-9a-fA-F]{3,8}\b|rgba?\(|hsla?\(', val_nourl) and 'forced-colors' not in media:
            err.append('literal color %s { %s }' % (sel, dcl))
    # R2-O16: a type class may only carry color, case, figures or the margin reset; anything else is a collision
    if any(c in names for c in re.findall(r'\.([A-Za-z_][\w-]*)', sel)):
        bad = [x.split(':')[0].strip() for x in decls if x.split(':')[0].strip() not in ('color', 'text-transform', 'font-variant-numeric', 'margin', 'font-size')]
        # D180: inside an @container rule a type class may step to another type style (font:var(--type-*) and its tracking), nothing else
        if media.startswith('@container'):
            bad = [x for x in bad if x not in ('font', 'letter-spacing')]
        if bad: err.append('type style class used as a layout or component selector: %s (%s)' % (sel, ', '.join(bad)))
    if used or weight or lh:
        slots.append((sel, used, weight, lh, media))
# --check (R4R-O05): the committed bundle must equal what --write would produce
if not WRITE and css != ORIG: err.append('bundle.css differs from tokens.json: the generated block or tracking pairs are stale (run tools/build_css.py --write)')
# var() resolution
tok = {t['name'] for k, v in d.items() if isinstance(v, dict) and 'tokens' in v for t in v['tokens']}
tok |= {'font-' + k for k in d['type']['families']} | {'type-' + n for n in names} | {'tracking-' + n for n in names}
local = set(re.findall(r'--([A-Za-z0-9_-]+)\s*:', css))
LOCAL_DATA = {'value', 'reader-scale', 'zoom', 'pan-x', 'pan-y', 'i', 'n', 'dir', 'reveal-delay', 'h', 'p', 'active-top', 'active-height', 'x'}
for v in sorted(set(re.findall(r'var\(--([A-Za-z0-9_.-]+)', re.sub(r'/\*.*?\*/', '', css, flags=re.S)))):
    if v not in tok and v not in local and v not in LOCAL_DATA: err.append('unresolved var(--%s)' % v)
# media queries
bp = {int(t['value'][:-2]) for t in d['layout']['tokens'] if t['name'].startswith('bp-')}
okbp = bp | {b - 1 for b in bp}
for mq in set(re.findall(r'@media[^{]+', src)):
    for kind, n in re.findall(r'(max-height|min-width|max-width):\s*(\d+)px', mq):
        if kind == 'max-height' and n == '500': continue  # phone landscape sheet rule (documented in Sheet)
        if int(n) not in okbp: err.append('media literal %spx not a bp-* value: %s' % (n, mq.strip()))
# container widths (round 4): a layout-* or size-* rem token, or a Chart step (D134)
remtok = {t['value'] for k in ('layout', 'size') for t in d[k]['tokens'] if t['value'].endswith('rem')}
CHART_STEPS = {'36rem', '25rem', '19.5rem', '14rem'}
for cq in set(containers):
    for w in re.findall(r'(?:max|min)-width:\s*([\d.]+(?:rem|px))', cq):
        if w not in remtok and w not in CHART_STEPS: err.append('container width %s is not a token value: %s' % (w, cq.strip()))
# bottom reserves above pinned bars (R4-O07): rem tokens, never a pixel literal of 100px or more
ABOVE_BAR = re.compile(r'\.(stage|qcol|xpl|passage-col|phone-screen|main|reader__col)\b')
for sel, body, media in rules:
    if not ABOVE_BAR.search(sel): continue
    for dcl in body.split(';'):
        if ':' not in dcl: continue
        prop, val = [x.strip() for x in dcl.split(':', 1)]
        if prop == 'padding-bottom': vals = [val]
        elif prop == 'padding':
            parts = re.sub(r'calc\([^)]*\)|max\([^)]*\)|var\([^)]*\)', 'X', val).split()
            vals = [parts[2]] if len(parts) >= 3 else []
        else: continue
        for v in vals:
            m = re.fullmatch(r'(\d+)px', v.strip())
            if m and int(m.group(1)) >= 100: err.append('pixel bottom reserve above a pinned bar: %s { %s: %s }' % (sel, prop, val))
if OUTD:
    os.makedirs(OUTD, exist_ok=True)
    json.dump(spacing, open(OUTD + '/internals.json', 'w'), indent=1)
# ---------- 4. slot table ----------
lines = ['| Selector | Type style | Weight override | Line height |', '|---|---|---|---|']
for sel, used, weight, lh, media in slots:
    if not used and not weight and not lh: continue
    lines.append('| `%s`%s | %s | %s | %s |' % (sel.replace('|', '\\|'), (' (%s)' % media.replace('@media ', '').replace('@container ', '')) if media else '',
                 ', '.join('`%s`' % u for u in used) or 'inherits', weight or '', ('%s (glyph box)' % lh) if lh else ''))
if OUTD: open(OUTD + '/type-slots.md', 'w').write('\n'.join(lines) + '\n')
print('rules', len(rules), 'slots', len(slots), 'spacing selectors', len(spacing))
print('ERRORS' if err else 'OK', len(err))
for e in err: print('  ', e)
sys.exit(1 if err else 0)
