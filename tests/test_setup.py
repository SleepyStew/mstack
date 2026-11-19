"""Run with: python3 -m unittest discover -s tests"""

import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SKILLS = sorted(path.name for path in (REPO / "skills").iterdir() if path.is_dir())


class Setup(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        self.claude = self.root / "claude"
        self.codex = self.root / "codex"
        self.claude.mkdir()
        self.codex.mkdir()

    def run_setup(self, *args):
        env = {**os.environ, "CLAUDE_CONFIG_DIR": str(self.claude), "CODEX_HOME": str(self.codex)}
        result = subprocess.run([str(REPO / "setup.sh"), *args], env=env, check=True, capture_output=True, text=True)
        return result.stdout

    def test_links_instructions_and_skills(self):
        self.run_setup()
        self.assertEqual(os.readlink(self.claude / "CLAUDE.md"), str(REPO / "global/AGENTS.md"))
        self.assertEqual(os.readlink(self.codex / "AGENTS.md"), str(REPO / "global/AGENTS.md"))
        for home in (self.claude, self.codex):
            links = {path.name: os.readlink(path) for path in (home / "skills").iterdir()}
            self.assertEqual(links, {name: str(REPO / "skills" / name) for name in SKILLS})
        self.assertFalse((self.claude / "settings.json").exists())

    def test_settings_merge_only_when_asked(self):
        (self.claude / "settings.json").write_text('{"theme": "light"}')
        self.run_setup()
        self.assertEqual((self.claude / "settings.json").read_text(), '{"theme": "light"}')
        self.run_setup("--apply-settings")
        overrides = json.loads((REPO / "claude/settings-overrides.json").read_text(encoding="utf-8"))
        overrides["env"]["CLAUDE_CODE_SHELL"] = shutil.which("bash")
        self.assertEqual(
            json.loads((self.claude / "settings.json").read_text(encoding="utf-8")), {"theme": "light", **overrides}
        )
        self.assertFalse((self.codex / "settings.json").exists())


if __name__ == "__main__":
    unittest.main()
