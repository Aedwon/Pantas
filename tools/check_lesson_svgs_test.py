import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location('svg_check', Path(__file__).with_name('check_lesson_svgs.py'))
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)


class SvgContract(unittest.TestCase):
    def test_supported_fixture(self):
        for file in Path('tools/svg_fixtures/pass').glob('*.svg'):
            check.validate(file)

    def test_rejected_fixtures(self):
        for file in Path('tools/svg_fixtures/fail').glob('*.svg'):
            with self.subTest(file=file.name):
                with self.assertRaises(ValueError):
                    check.validate(file)


if __name__ == '__main__':
    unittest.main()
