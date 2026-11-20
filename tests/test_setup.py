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

    def run_script(self, name, *args):
        env = {**os.environ, "CLAUDE_CONFIG_DIR": str(self.claude), "CODEX_HOME": str(self.codex)}
        result = subprocess.run([str(REPO / name), *args], env=env, check=True, capture_output=True, text=True)
        return result.stdout

    def run_setup(self, *args):
        return self.run_script("setup.sh", *args)

    def test_links_only_the_skills_unless_asked(self):
        self.run_setup()
        for home in (self.claude, self.codex):
            self.assertEqual([path.name for path in home.iterdir()], ["skills"])
            links = {path.name: os.readlink(path) for path in (home / "skills").iterdir()}
            self.assertEqual(links, {name: str(REPO / "skills" / name) for name in SKILLS})

    def test_links_the_instructions_when_asked(self):
        self.run_setup("--apply-instructions")
        self.assertEqual(os.readlink(self.claude / "CLAUDE.md"), str(REPO / "global/AGENTS.md"))
        self.assertEqual(os.readlink(self.codex / "AGENTS.md"), str(REPO / "global/AGENTS.md"))
        self.assertFalse((self.claude / "settings.json").exists())

    def test_dry_run_changes_nothing(self):
        (self.claude / "CLAUDE.md").write_text("mine")
        output = self.run_setup("--all", "--dry-run")
        self.assertIn(f"linked  {self.claude}/skills/why", output)
        self.assertIn(f"backup  {self.claude}/CLAUDE.md", output)
        self.assertEqual([path.name for path in self.claude.iterdir()], ["CLAUDE.md"])
        self.assertEqual((self.claude / "CLAUDE.md").read_text(), "mine")
        self.assertEqual(list(self.codex.iterdir()), [])

    def test_settings_merge_only_when_asked(self):
        (self.claude / "settings.json").write_text('{"theme": "light"}')
        self.run_setup("--apply-instructions")
        self.assertEqual((self.claude / "settings.json").read_text(), '{"theme": "light"}')
        self.run_setup("--apply-settings")
        overrides = json.loads((REPO / "claude/settings-overrides.json").read_text(encoding="utf-8"))
        overrides["env"]["CLAUDE_CODE_SHELL"] = shutil.which("bash")
        self.assertEqual(
            json.loads((self.claude / "settings.json").read_text(encoding="utf-8")), {"theme": "light", **overrides}
        )
        self.assertFalse((self.codex / "settings.json").exists())

    def test_remove_takes_out_only_the_links_into_this_clone(self):
        skills = self.claude / "skills"
        elsewhere = self.root / "elsewhere"
        for folder in (skills, elsewhere, skills / "theirs"):
            folder.mkdir()
        (skills / "their-link").symlink_to(elsewhere)
        self.run_setup("--all")
        settings = (self.claude / "settings.json").read_text()
        self.run_script("remove.sh")
        self.assertEqual(sorted(path.name for path in skills.iterdir()), ["their-link", "theirs"])
        self.assertFalse((self.claude / "CLAUDE.md").is_symlink())
        self.assertEqual(list((self.codex / "skills").iterdir()), [])
        self.assertEqual((self.claude / "settings.json").read_text(), settings)
        self.assertNotIn("removed", self.run_script("remove.sh"))

    def test_second_run_changes_nothing(self):
        self.run_setup("--all")
        actions = [line.split()[0] for line in self.run_setup("--all").splitlines() if line.startswith("  ")]
        self.assertEqual(set(actions), {"ok"})
        self.assertFalse((self.claude / "mstack-backup").exists())

    def test_file_or_folder_in_the_way_moves_to_the_backup(self):
        (self.claude / "CLAUDE.md").write_text("mine")
        (self.claude / "skills/why").mkdir(parents=True)
        (self.claude / "skills/why/SKILL.md").write_text("mine")
        self.run_setup("--apply-instructions")
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
