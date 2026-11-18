#!/usr/bin/env python3
"""Check a repo's Markdown docs against the flat docs convention.

Usage: check_docs.py [repo-root]

Errors (exit 1): relative links or heading anchors that do not resolve, a
missing docs/README.md index, and guides or subfolders the index does not
link. Warnings (exit 0): top-level docs that look like a plan or a dated
record.
"""

import re
import sys
from pathlib import Path
from urllib.parse import unquote

LINK = re.compile(r"!?\[[^\]]*\]\(\s*<?([^)\s>]+)>?(?:\s+\"[^\"]*\")?\s*\)")
HEADING = re.compile(r"^#{1,6}\s+(.*?)\s*#*\s*$")
FENCE = re.compile(r"^\s*(```|~~~)")
INLINE_CODE = re.compile(r"`[^`]*`")
EXTERNAL = re.compile(r"^[a-zA-Z][a-zA-Z0-9+.-]*:")
DATED = re.compile(r"\d{4}-\d{2}-\d{2}")
POINT_IN_TIME_WORDS = {
    "plan", "roadmap", "todo", "audit", "readiness", "feasibility", "proposal", "report",
}
INDEX_THRESHOLD = 3


def prose_lines(text):
    """Yield (line number, line) for lines outside fenced code blocks."""
    fenced = False
    for number, line in enumerate(text.splitlines(), 1):
        if FENCE.match(line):
            fenced = not fenced
        elif not fenced:
            yield number, line


def slug(heading):
    """GitHub's anchor for a heading, before duplicate numbering."""
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", heading)
    text = re.sub(r"[`*]", "", text).strip().lower()
    return re.sub(r"[^\w\- ]", "", text).replace(" ", "-")


def anchors(path):
    seen, result = {}, set()
    for _, line in prose_lines(path.read_text(encoding="utf-8")):
        match = HEADING.match(line)
        if not match:
            continue
        base = slug(match.group(1))
        count = seen.get(base, 0)
        seen[base] = count + 1
        result.add(base if count == 0 else f"{base}-{count}")
    return result


def links(path):
    """Yield (line number, target) for each relative link in a file."""
    for number, line in prose_lines(path.read_text(encoding="utf-8")):
        for match in LINK.finditer(INLINE_CODE.sub("", line)):
            target = match.group(1)
            if not EXTERNAL.match(target):
                yield number, target


def check(root):
    root = Path(root).resolve()
    docs = root / "docs"
    files = [root / name for name in ("README.md", "AGENTS.md", "CLAUDE.md")]
    files = [path for path in files if path.is_file()]
    if docs.is_dir():
        files += sorted(docs.rglob("*.md"))
    errors, warnings = [], []

    for path in files:
        for number, target in links(path):
            where = f"{path.relative_to(root)}:{number}"
            raw_path, _, fragment = target.partition("#")
            dest = (path.parent / unquote(raw_path)).resolve() if raw_path else path
            if not dest.exists():
                errors.append(f"{where}: broken link {target}")
            elif fragment and dest.suffix == ".md" and dest.is_file():
                if unquote(fragment).lower() not in anchors(dest):
                    errors.append(f"{where}: no heading for #{fragment} in {dest.name}")

    if not docs.is_dir():
        return errors, warnings

    index = docs / "README.md"
    guides = sorted(p for p in docs.glob("*.md") if p.name != "README.md")
    folders = sorted(p for p in docs.iterdir() if p.is_dir() and any(p.rglob("*.md")))
    if index.is_file():
        linked = {
            (docs / unquote(target.partition("#")[0])).resolve()
            for _, target in links(index)
        }
        for guide in guides:
            if guide.resolve() not in linked:
                errors.append(f"docs/{guide.name}: not linked from docs/README.md")
        for folder in folders:
            inside = folder.resolve()
            if not any(inside == p or inside in p.parents for p in linked):
                errors.append(f"docs/{folder.name}/: not linked from docs/README.md")
    elif len(guides) >= INDEX_THRESHOLD:
        errors.append(f"docs/: {len(guides)} guides and no docs/README.md index")

    for guide in guides:
        stem = guide.stem.lower()
        if DATED.search(stem) or POINT_IN_TIME_WORDS & set(re.split(r"[-_.]", stem)):
            warnings.append(
                f"docs/{guide.name}: looks like a plan or dated record, "
                "which belongs in a subfolder or tasks/"
            )
    return errors, warnings


def main(argv):
    errors, warnings = check(argv[1] if len(argv) > 1 else ".")
    for line in errors:
        print(f"error: {line}")
    for line in warnings:
        print(f"warning: {line}")
    print(f"{len(errors)} errors, {len(warnings)} warnings")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
