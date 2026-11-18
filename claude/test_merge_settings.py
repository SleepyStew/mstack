"""Run with: python3 -m unittest discover -s claude"""

import json
import tempfile
import unittest
from pathlib import Path

from merge_settings import apply, merge


class MergeSettings(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        self.overrides = self.root / "overrides.json"
        self.settings = self.root / "home" / "settings.json"
        self.backup = self.root / "backup"
        self.overrides.write_text(json.dumps({"env": {"A": "1"}, "rules": ["x"]}))

    def run_apply(self):
        return apply(self.overrides, self.settings, self.backup)

    def read(self):
        return json.loads(self.settings.read_text())

    def test_objects_merge_and_other_values_replace(self):
        base = {"env": {"A": "0", "B": "2"}, "rules": ["a", "b"], "theme": "light"}
        self.assertEqual(
            merge(base, {"env": {"A": "1"}, "rules": ["x"]}),
            {"env": {"A": "1", "B": "2"}, "rules": ["x"], "theme": "light"},
        )

    def test_creates_a_missing_file(self):
        self.assertEqual(self.run_apply(), "created")
        self.assertEqual(self.read(), {"env": {"A": "1"}, "rules": ["x"]})
        self.assertFalse(self.backup.exists())

    def test_keeps_other_keys_and_backs_up_the_old_file(self):
        self.settings.parent.mkdir()
        self.settings.write_text('{"theme": "light", "env": {"B": "2"}}')
        self.assertEqual(self.run_apply(), "merged")
        self.assertEqual(self.read(), {"theme": "light", "env": {"B": "2", "A": "1"}, "rules": ["x"]})
        self.assertEqual(json.loads((self.backup / "settings.json").read_text()), {"theme": "light", "env": {"B": "2"}})

    def test_second_run_changes_nothing(self):
        self.run_apply()
        self.assertEqual(self.run_apply(), "ok")
        self.assertFalse(self.backup.exists())

    def test_invalid_json_is_left_alone(self):
        self.settings.parent.mkdir()
        self.settings.write_text("{broken")
        with self.assertRaises(SystemExit):
            self.run_apply()
        self.assertEqual(self.settings.read_text(), "{broken")

    def test_dangling_link_becomes_a_file_without_creating_its_target(self):
        target = self.root / "gone.json"
        self.settings.parent.mkdir()
        self.settings.symlink_to(target)
        self.assertEqual(self.run_apply(), "created")
        self.assertFalse(self.settings.is_symlink())
        self.assertFalse(target.exists())
        self.assertEqual(self.read(), {"env": {"A": "1"}, "rules": ["x"]})


if __name__ == "__main__":
    unittest.main()
