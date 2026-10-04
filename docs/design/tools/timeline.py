#!/usr/bin/env python3
"""Print the motion timeline of a design board in milliseconds.

Usage:  python3 docs/design/tools/timeline.py docs/design/boards/ST_ExamSwitchCount.html [--all]

For every animated element it prints the element's label (its first text, or its tag and
size), the animation name, duration, delay, easing and loop, then each keyframe stop
converted to absolute milliseconds with the properties at that stop. Stops that only
repeat the previous values print as (holds); --all prints their values.

Boards that loop compress a whole interaction (finger tap, then the app's reaction) into
one loop. The gray circle that appears and fades is the finger, not part of the UI. The
part of a loop after the last change (the hold and the jump back to the start) exists only
so the board replays; build the animation from the start to the last change.
"""
import re, sys
from html.parser import HTMLParser

VOID = {'br', 'img', 'input', 'meta', 'link', 'hr', 'path', 'circle', 'rect', 'line', 'polyline', 'polygon', 'ellipse', 'stop', 'use'}

class Node:
    def __init__(s, tag, attrs, parent):
        s.tag, s.attrs, s.parent, s.kids, s.text = tag, dict(attrs), parent, [], ''

class P(HTMLParser):
    def __init__(s):
        super().__init__(); s.root = Node('root', [], None); s.cur = s.root; s.styles = []; s.in_style = False
    def handle_starttag(s, tag, attrs):
        n = Node(tag, attrs, s.cur); s.cur.kids.append(n)
        if tag == 'style': s.in_style = True
        if tag not in VOID: s.cur = n
    def handle_startendtag(s, tag, attrs):
        s.cur.kids.append(Node(tag, attrs, s.cur))
    def handle_endtag(s, tag):
        if tag == 'style': s.in_style = False
        n = s.cur
        while n is not None and n.tag != tag: n = n.parent
        if n is not None and n.parent is not None: s.cur = n.parent
    def handle_data(s, d):
        if s.in_style: s.styles.append(d)
        elif d.strip(): s.cur.kids.append(d.strip())

def text_of(n, limit=60):
    out = []
    def walk(x):
        if len(' '.join(out)) > limit: return
        if isinstance(x, str): out.append(x); return
        if x.tag in ('style', 'script'): return
        for k in x.kids: walk(k)
    walk(n)
    t = ' '.join(out)
    return (t[:limit] + '…') if len(t) > limit else t

def ms(v):
    v = v.strip()
    return float(v[:-2]) if v.endswith('ms') else float(v[:-1]) * 1000 if v.endswith('s') else None

def parse_keyframes(css):
    kf = {}
    for m in re.finditer(r'@keyframes\s+([\w-]+)\s*\{', css):
        i = m.end(); depth = 1; j = i
        while depth and j < len(css):
            depth += {'{': 1, '}': -1}.get(css[j], 0); j += 1
        body = css[i:j - 1]; stops = []
        for sm in re.finditer(r'([\d.%,\sfromto]+)\{([^}]*)\}', body):
            for sel in sm.group(1).split(','):
                sel = sel.strip(); pct = 0 if sel == 'from' else 100 if sel == 'to' else float(sel.rstrip('%'))
                stops.append((pct, sm.group(2).strip()))
        kf[m.group(1)] = sorted(stops, key=lambda x: x[0])
    return kf

def split_anims(v):
    parts, depth, cur = [], 0, ''
    for ch in v:
        if ch == '(': depth += 1
        if ch == ')': depth -= 1
        if ch == ',' and depth == 0: parts.append(cur); cur = ''
        else: cur += ch
    parts.append(cur); return [p.strip() for p in parts if p.strip()]

def anims_of(style, kf):
    out = []
    m = re.search(r'(?:^|;)\s*animation\s*:\s*([^;]+)', style)
    if not m: return out
    delay_override = re.search(r'animation-delay\s*:\s*([\d.]+m?s)', style)
    for a in split_anims(m.group(1)):
        toks = re.findall(r'cubic-bezier\([^)]*\)|steps\([^)]*\)|\S+', a)
        name = next((t for t in toks if t in kf), None)
        if not name: continue
        times = [ms(t) for t in toks if re.fullmatch(r'[\d.]+m?s', t)]
        ease = next((t for t in toks if t.startswith(('cubic', 'steps')) or t in ('ease', 'linear', 'ease-in', 'ease-out', 'ease-in-out')), 'ease')
        dur = times[0] if times else 0; delay = times[1] if len(times) > 1 else 0
        if delay_override: delay = ms(delay_override.group(1))
        out.append(dict(name=name, dur=dur, delay=delay, ease=ease, loop='infinite' in toks))
    return out

def main():
    path = sys.argv[1]; show_all = '--all' in sys.argv
    p = P(); p.feed(open(path, encoding='utf-8').read())
    kf = parse_keyframes('\n'.join(p.styles))
    rows = []
    def walk(n, depth):
        if isinstance(n, str): return
        st = n.attrs.get('style') or ''
        for a in anims_of(st, kf):
            label = text_of(n)
            if not label:
                up, hops = n.parent, 0
                while up is not None and hops < 3 and not text_of(up, 40): up, hops = up.parent, hops + 1
                ctx = text_of(up, 40) if up is not None else ''
                label = f"<{n.tag}> " + ' '.join(re.findall(r'(?:width|height|background)\s*:\s*[^;]+', st)[:3]) + (f"  (in: {ctx})" if ctx else '')
            rows.append((a, label))
        for k in n.kids: walk(k, depth + 1)
    walk(p.root, 0)
    if not rows: print('No CSS animations on this board.'); return
    for a, label in rows:
        print(f"\n■ {label}\n  {a['name']}  {a['dur']:.0f}ms" + (f" after {a['delay']:.0f}ms" if a['delay'] else '') + f"  {a['ease']}" + ('  (loops)' if a['loop'] else ''))
        prev = None
        for pct, props in kf[a['name']]:
            props = re.sub(r'animation-timing-function:\s*([^;]+);?', r'[then \1]', props).strip()
            core = re.sub(r'\[then [^\]]*\]', '', props).strip()
            same = core == prev
            prev = core
            if same and not show_all: props = '(holds)' + (' ' + re.search(r'\[then [^\]]*\]', props).group(0) if '[then' in props else '')
            print(f"    {a['delay'] + a['dur'] * pct / 100:7.0f}ms  {props}")

if __name__ == '__main__':
    main()
