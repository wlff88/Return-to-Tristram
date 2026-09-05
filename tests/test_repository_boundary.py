from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]


class RepositoryBoundaryTests(unittest.TestCase):
    def test_local_sources_and_builds_are_ignored(self):
        paths = ['assets/blizzard/anything', 'assets/d2r/anything', 'local-assets/anything',
                 'local-cache/anything', 'cache/anything', '.d2r-cache/anything',
                 'build/anything', 'config.local.json']
        result = subprocess.run(['git', 'check-ignore', '-z', '--stdin'], cwd=ROOT,
                                input=('\0'.join(paths) + '\0').encode(), capture_output=True)
        self.assertEqual(set(result.stdout.decode().rstrip('\0').split('\0')), set(paths))

    def test_tracked_project_has_no_game_binaries(self):
        result = subprocess.run(['git', 'ls-files', '-z'], cwd=ROOT, capture_output=True, check=True)
        forbidden = {'.mpq', '.ds1', '.dt1', '.dcc', '.dc6', '.pl2', '.texture', '.model', '.dds'}
        paths = result.stdout.decode().split('\0')
        self.assertEqual([p for p in paths if Path(p).suffix.lower() in forbidden], [])


if __name__ == '__main__':
    unittest.main()
