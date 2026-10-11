#!/usr/bin/env python3
"""Print a compact outline of a design board: the text and the style values that matter.

Usage: python3 docs/design/tools/outline.py docs/design/boards/HP_Free.html [more boards]

Each line is one element: indentation shows nesting, then the style values, then the text.
Only values an implementor needs are kept (size, weight, color, spacing, radius, motion).
The board file stays the authority; use `timeline.py` for keyframe timing.
"""
import re
import sys
from html.parser import HTMLParser

KEEP = (
    'font-size', 'font-weight', 'color', 'background', 'background-color', 'padding',
    'margin', 'gap', 'border-radius', 'border', 'width', 'height', 'min-height',
    'line-height', 'letter-spacing', 'opacity', 'animation', 'transform', 'box-shadow',
    'justify-content', 'align-items', 'flex-direction', 'text-align', 'stroke',
    'stroke-width', 'fill', 'font-variant-numeric', 'text-transform',
)
VOID = {'br', 'img', 'input', 'meta', 'link', 'hr', 'path', 'circle', 'rect', 'line'}
SKIP = {'style', 'script', 'head', 'title'}
SVG_ATTRS = ('d', 'r', 'cx', 'cy', 'x', 'y', 'width', 'height', 'viewBox', 'stroke',
             'stroke-width', 'fill', 'stroke-linecap')


def styles(raw):
    out = []
    for part in (raw or '').split(';'):
        if ':' not in part:
            continue
        key, value = part.split(':', 1)
        key, value = key.strip(), re.sub(r'\s+', ' ', value.strip())
        if key in KEEP and value not in ('', '0', 'normal', 'none'):
            out.append(f'{key}:{value}')
    return ' '.join(out)


class Outline(HTMLParser):
    def __init__(self):
        super().__init__()
        self.depth = 0
        self.skip = 0
        self.lines = []

    def handle_starttag(self, tag, attrs):
        if tag in SKIP:
            self.skip += 1
            return
        if self.skip:
            return
        a = dict(attrs)
        bits = [styles(a.get('style'))]
        if a.get('class'):
            bits.append('.' + '.'.join(a['class'].split()))
        if tag in ('svg', 'path', 'circle', 'rect', 'line'):
            bits.append(' '.join(f'{k}={a[k][:60]}' for k in SVG_ATTRS if k in a))
        text = ' '.join(b for b in bits if b)
        self.lines.append(('  ' * self.depth) + f'<{tag}> {text}'.rstrip())
        if tag not in VOID:
            self.depth += 1

    def handle_endtag(self, tag):
        if tag in SKIP:
            self.skip = max(0, self.skip - 1)
            return
        if not self.skip and tag not in VOID:
            self.depth = max(0, self.depth - 1)

    def handle_data(self, data):
        text = re.sub(r'\s+', ' ', data).strip()
        if text and not self.skip:
            self.lines.append(('  ' * self.depth) + f'"{text}"')


def main(paths):
    for path in paths:
        source = open(path, encoding='utf-8').read()
        print(f'# {path}')
        for name, body in re.findall(r'@keyframes\s+([\w-]+)\s*\{((?:[^{}]|\{[^{}]*\})*)\}', source):
            print(f'@keyframes {name} {{{re.sub(chr(92) + "s+", " ", body).strip()}}}')
        for selector, body in re.findall(r'(\.[\w.-]+(?:\.[\w-]+)*)\s*\{([^{}]*animation[^{}]*)\}', source):
            print(f'{selector} {{{body.strip()}}}')
        parser = Outline()
        parser.feed(source)
        merged = []
        for line in parser.lines:
            if line.lstrip().startswith('"') and merged and not merged[-1].lstrip().startswith('"'):
                merged[-1] += ' ' + line.strip()
            else:
                merged.append(line)
        print('\n'.join(merged))
        print()


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    main(sys.argv[1:])
