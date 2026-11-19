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

    def run_setup(self):
        env = {**os.environ, "CLAUDE_CONFIG_DIR": str(self.claude), "CODEX_HOME": str(self.codex)}
        result = subprocess.run([str(REPO / "setup.sh")], env=env, check=True, capture_output=True, text=True)
        return result.stdout

    def test_links_instructions_and_skills_and_creates_settings(self):
        self.run_setup()
        self.assertEqual(os.readlink(self.claude / "CLAUDE.md"), str(REPO / "global/AGENTS.md"))
        self.assertEqual(os.readlink(self.codex / "AGENTS.md"), str(REPO / "global/AGENTS.md"))
        for home in (self.claude, self.codex):
            links = {path.name: os.readlink(path) for path in (home / "skills").iterdir()}
            self.assertEqual(links, {name: str(REPO / "skills" / name) for name in SKILLS})
        overrides = json.loads((REPO / "claude/settings-overrides.json").read_text(encoding="utf-8"))
        overrides["env"]["CLAUDE_CODE_SHELL"] = shutil.which("bash")
        self.assertEqual(json.loads((self.claude / "settings.json").read_text(encoding="utf-8")), overrides)
        self.assertFalse((self.codex / "settings.json").exists())

    def test_second_run_changes_nothing(self):
        self.run_setup()
        actions = [line.split()[0] for line in self.run_setup().splitlines() if line.startswith("  ")]
        self.assertEqual(set(actions), {"ok"})
        self.assertFalse((self.claude / "mstack-backup").exists())

    def test_file_or_folder_in_the_way_moves_to_the_backup(self):
        (self.claude / "CLAUDE.md").write_text("mine")
        (self.claude / "skills/why").mkdir(parents=True)
        (self.claude / "skills/why/SKILL.md").write_text("mine")
        self.run_setup()
        (backup,) = (self.claude / "mstack-backup").iterdir()
        self.assertEqual((backup / "CLAUDE.md").read_text(), "mine")
        self.assertEqual((backup / "skills/why/SKILL.md").read_text(), "mine")
        self.assertEqual(os.readlink(self.claude / "skills/why"), str(REPO / "skills/why"))

    def test_stale_links_go_and_other_skills_stay(self):
        skills = self.claude / "skills"
        elsewhere = self.root / "elsewhere"
        for folder in (skills, elsewhere, skills / "theirs"):
            folder.mkdir()
        (skills / "why").symlink_to(elsewhere)
        (skills / "gone").symlink_to(REPO / "skills/gone")
        (skills / "their-dangling").symlink_to(self.root / "nowhere")
        self.run_setup()
        self.assertEqual(os.readlink(skills / "why"), str(REPO / "skills/why"))
        self.assertTrue(elsewhere.is_dir())
        self.assertFalse((skills / "gone").is_symlink())
        self.assertTrue((skills / "theirs").is_dir())
        self.assertTrue((skills / "their-dangling").is_symlink())
        self.assertFalse((self.claude / "mstack-backup").exists())


if __name__ == "__main__":
    unittest.main()
