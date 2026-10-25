#!/usr/bin/env python3
"""Reject silently ignored SVG features, then draw through the app parser.

Usage: python3 tools/check_lesson_svgs.py [ROOT] [--validate-only]
No images are saved. The Flutter harness draws in memory in both themes.
"""
import argparse
import os
from pathlib import Path
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

TAGS = set('svg g defs path rect circle ellipse line polygon polyline text tspan linearGradient radialGradient stop clipPath use symbol title desc'.split())
PAINT = set('id fill fill-rule fill-opacity stroke stroke-width stroke-opacity stroke-linecap stroke-linejoin stroke-miterlimit stroke-dasharray stroke-dashoffset opacity transform clip-path clip-rule'.split())
TEXT = set('font-family font-size font-weight text-anchor'.split())
EXTRA = {
    'svg': set('x y width height viewBox preserveAspectRatio'.split()) | TEXT,
    'g': TEXT, 'defs': TEXT, 'symbol': TEXT,
    'path': {'d'}, 'rect': set('x y width height rx ry'.split()),
    'circle': set('cx cy r'.split()), 'ellipse': set('cx cy rx ry'.split()),
    'line': set('x1 y1 x2 y2'.split()), 'polygon': {'points'}, 'polyline': {'points'},
    'text': TEXT | set('x y dx dy'.split()), 'tspan': TEXT | set('x y dx dy'.split()),
    'clipPath': set(), 'use': set('x y href'.split()),
}
GRADIENT = set('id href gradientTransform gradientUnits spreadMethod'.split())
SPECIAL = {
    'linearGradient': GRADIENT | set('x1 y1 x2 y2'.split()),
    'radialGradient': GRADIENT | set('cx cy r fx fy'.split()),
    'stop': set('id offset stop-color stop-opacity'.split()),
    'title': {'id'}, 'desc': {'id'},
}
SVG_NS = 'http://www.w3.org/2000/svg'


def validate(file):
    text = Path(file).read_text(encoding='utf8')
    if re.search(r'<!DOCTYPE|<!ENTITY|<\?xml-stylesheet', text, re.I):
        raise ValueError('external declarations, entities and stylesheets are forbidden')
    try:
        root = ET.fromstring(text)
    except ET.ParseError as error:
        raise ValueError(f'invalid XML: {error}') from error
    if root.tag not in ('svg', f'{{{SVG_NS}}}svg'):
        raise ValueError('root must be svg')
    for element in root.iter():
        tag = element.tag.removeprefix(f'{{{SVG_NS}}}')
        if tag == 'svg' and element is not root:
            raise ValueError('unsupported nested svg element')
        if tag not in TAGS:
            raise ValueError(f'unsupported element <{tag}>')
        if tag == 'clipPath':
            for child in element:
                child_tag = child.tag.removeprefix(f'{{{SVG_NS}}}')
                if child_tag not in {'path', 'rect', 'circle', 'ellipse', 'line', 'polygon', 'polyline', 'use'}:
                    raise ValueError(f'unsupported clipPath child <{child_tag}>')
        if tag in ('linearGradient', 'radialGradient'):
            if any(child.tag.removeprefix(f'{{{SVG_NS}}}') != 'stop' for child in element):
                raise ValueError('gradients may contain only stop elements')
        allowed = SPECIAL.get(tag, PAINT | EXTRA.get(tag, set()))
        for raw, value in element.attrib.items():
            name = raw.removeprefix('{http://www.w3.org/1999/xlink}')
            if name not in allowed:
                raise ValueError(f'unsupported attribute {raw} on <{tag}> (CSS and event handlers are forbidden)')
            if name == 'href' and not re.fullmatch(r'#[A-Za-z_][\w.-]*', value.strip()):
                raise ValueError(f'external reference: {value}')
            for reference in re.findall(r'url\s*\((.*?)\)', value, re.I):
                if not re.fullmatch(r'#[A-Za-z_][\w.-]*', reference.strip(' \t\'"')):
                    raise ValueError(f'external paint reference: {reference}')
            if name in ('fill', 'stroke', 'stop-color') and ('var(' in value.lower() or 'context-' in value.lower()):
                raise ValueError(f'unsupported CSS color: {value}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', nargs='?', default='content/illustrations')
    parser.add_argument('--validate-only', action='store_true')
    args = parser.parse_args()
    root = Path(args.root).resolve()
    if not root.exists():
        print(f'{root}: missing SVG root', file=sys.stderr)
        return 1
    files = sorted(root.rglob('*.svg')) if root.is_dir() else [root]
    errors = 0
    for file in files:
        try:
            validate(file)
        except (ValueError, OSError) as error:
            print(f'{file}: {error}', file=sys.stderr)
            errors += 1
    print(f'SVG preflight: {len(files)} files, {errors} failures', flush=True)
    if errors:
        return 1
    if args.validate_only or not files:
        return 0
    environment = dict(os.environ, B9_SVG_ROOT=str(root))
    return subprocess.run(['flutter', 'test', 'tools/check_lesson_svgs_render_test.dart', '--reporter', 'expanded'], env=environment, check=False).returncode


if __name__ == '__main__':
    sys.exit(main())
