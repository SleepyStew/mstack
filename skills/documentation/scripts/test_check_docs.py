"""Run with: python3 -m unittest discover -s skills/documentation/scripts"""

import tempfile
import unittest
from pathlib import Path

from check_docs import check, slug


def repo(files):
    root = Path(tempfile.mkdtemp())
    for name, text in files.items():
        path = root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
    return root


class CheckDocs(unittest.TestCase):
    def test_clean_repo_passes(self):
        root = repo(
            {
                "README.md": "See [the docs](docs/README.md).",
                "docs/README.md": "[Setup](setup.md#run-it) and [records](records/README.md)",
                "docs/setup.md": "# Setup\n\n## Run it\n",
                "docs/records/README.md": "# Records\n",
            }
        )
        self.assertEqual(check(root), ([], []))

    def test_broken_link_and_anchor(self):
        root = repo(
            {
                "docs/README.md": "[a](setup.md#missing) [b](gone.md) [c](setup.md)",
                "docs/setup.md": "# Setup\n",
            }
        )
        errors, _ = check(root)
        self.assertEqual(len(errors), 2)
        self.assertIn("no heading for #missing", errors[0])
        self.assertIn("broken link gone.md", errors[1])

    def test_links_in_code_are_ignored(self):
        root = repo(
            {"docs/README.md": "`[x](nope.md)`\n\n```\n[y](nope.md)\n```\n\nhttps://example.com [z](https://example.com/a.md)\n"}
        )
        self.assertEqual(check(root), ([], []))

    def test_guide_and_folder_missing_from_index(self):
        root = repo(
            {
                "docs/README.md": "[Setup](setup.md)",
                "docs/setup.md": "# Setup\n",
                "docs/deploy.md": "# Deploy\n",
                "docs/records/2026-11-18-audit.md": "# Audit\n",
            }
        )
        errors, _ = check(root)
        self.assertEqual(
            errors,
            [
                "docs/deploy.md: not linked from docs/README.md",
                "docs/records/: not linked from docs/README.md",
            ],
        )

    def test_index_required_from_three_guides(self):
        two = repo({"docs/a.md": "", "docs/b.md": ""})
        three = repo({"docs/a.md": "", "docs/b.md": "", "docs/c.md": ""})
        self.assertEqual(check(two)[0], [])
        self.assertEqual(len(check(three)[0]), 1)

    def test_point_in_time_guide_warns(self):
        root = repo({"docs/README.md": "[p](release-plan.md)", "docs/release-plan.md": ""})
        errors, warnings = check(root)
        self.assertEqual(errors, [])
        self.assertEqual(len(warnings), 1)

    def test_point_in_time_matches_whole_words_only(self):
        names = ["explanation.md", "reporting.md", "planner.md", "ci-timing-2026-11-04.md"]
        index = " ".join(f"[x]({name})" for name in names)
        root = repo({"docs/README.md": index, **{f"docs/{name}": "" for name in names}})
        _, warnings = check(root)
        self.assertEqual(len(warnings), 1)
        self.assertIn("ci-timing-2026-11-04.md", warnings[0])

    def test_slug_matches_github(self):
        self.assertEqual(slug("Add a game"), "add-a-game")
        self.assertEqual(slug("CI/CD and `pnpm`"), "cicd-and-pnpm")
        self.assertEqual(slug("[Setup](setup.md): first run"), "setup-first-run")


if __name__ == "__main__":
    unittest.main()
