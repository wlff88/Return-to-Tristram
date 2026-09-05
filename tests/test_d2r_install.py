import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('probe', Path(__file__).resolve().parents[1] / 'tools/d2r_install.py')
probe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(probe)


class InstallationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'Data').mkdir()
        (self.root / 'D2R.exe').touch()
        self.metadata = self.root / '.build.info'
        self.header = 'Active!DEC:1|Build Key!HEX:16|Version!STRING:0\n'
        self.row = '1|' + 'a' * 32 + '|1.2.3\n'
        self.metadata.write_text(self.header + self.row)

    def test_read_only_and_deterministic(self):
        before = self.metadata.read_bytes()
        first = probe.inspect_install(self.root)
        self.assertEqual(first, probe.inspect_install(self.root))
        self.assertEqual(before, self.metadata.read_bytes())
        self.assertTrue(first['installation_detected'])
        self.assertFalse(first['presentation_supported'])
        self.assertEqual(len(first['fingerprint']), 64)

    def test_update_invalidates_identity(self):
        first = probe.inspect_install(self.root)
        self.metadata.write_text(self.header + self.row.replace('1.2.3', '1.2.4'))
        self.assertNotEqual(first['fingerprint'], probe.inspect_install(self.root)['fingerprint'])

    def test_reject_ambiguous_or_invalid_build(self):
        for body in ('', self.header, self.header + self.row * 2,
                     self.header + '1|bad|1.2.3\n', self.header + '1|short\n'):
            with self.subTest(body=body):
                self.metadata.write_text(body)
                with self.assertRaises(ValueError):
                    probe.inspect_install(self.root)

    def test_missing_executable(self):
        (self.root / 'D2R.exe').unlink()
        with self.assertRaises(ValueError):
            probe.inspect_install(self.root)


if __name__ == '__main__':
    unittest.main()
