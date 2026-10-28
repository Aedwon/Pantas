import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('svg_check', Path(__file__).with_name('check_lesson_svgs.py'))
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)


class SvgContract(unittest.TestCase):
    def test_supported_fixture(self):
        for file in Path('tools/svg_fixtures/pass').glob('*.svg'):
            check.validate(file)

    def test_font_families(self):
        check.validate(Path('tools/svg_fixtures/pass/fonts.svg'))
        for name in ['font-unknown.svg', 'font-bare.svg', 'font-tspan.svg']:
            with self.subTest(name=name):
                with self.assertRaisesRegex(ValueError, 'unsupported font-family'):
                    check.validate(Path('tools/svg_fixtures/fail') / name)

    def test_use_cycles_are_reported_with_their_path(self):
        for name, expected in [('use-cycle.svg', 'a -> b -> a'), ('use-self.svg', 'a -> a')]:
            with self.subTest(name=name):
                with self.assertRaisesRegex(ValueError, expected):
                    check.validate(Path('tools/svg_fixtures/fail') / name)

    def test_rejected_fixtures(self):
        for file in Path('tools/svg_fixtures/fail').glob('*.svg'):
            with self.subTest(file=file.name):
                with self.assertRaises(ValueError):
                    check.validate(file)


class FileNames(unittest.TestCase):
    def run_check(self, name):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder) / 'content' / 'illustrations'
            file = root / name
            file.parent.mkdir(parents=True)
            file.write_text('<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>')
            result = subprocess.run(
                [sys.executable, str(Path(__file__).with_name('check_lesson_svgs.py')), str(root), '--validate-only'],
                capture_output=True, text=True, check=False)
            return result, file

    def test_good_name_passes(self):
        result, _ = self.run_check('math/topic/lesson/01-good-name.svg')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_names_off_the_path_rule_fail_with_path_and_rule(self):
        for name in [
            'math/topic/lesson/1-short.svg',
            'math/topic/lesson/01-Upper.svg',
            'math/topic/lesson/01-upper-extension.SVG',
            'math/topic/lesson/01_underscore.svg',
            'math/topic/lesson/00-zero.svg',
            'math/topic/01-too-shallow.svg',
            'math/topic/lesson/extra/01-too-deep.svg',
        ]:
            with self.subTest(name=name):
                result, file = self.run_check(name)
                self.assertEqual(result.returncode, 1)
                self.assertIn(str(file.resolve()), result.stderr)
                self.assertIn('NN-slug', result.stderr)

    def test_fixture_folders_are_not_held_to_the_name_rule(self):
        result = subprocess.run(
            [sys.executable, str(Path(__file__).with_name('check_lesson_svgs.py')), 'tools/svg_fixtures/pass', '--validate-only'],
            capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
