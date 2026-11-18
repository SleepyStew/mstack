---
name: documentation
description: Write, update, audit or reorganise a project's Markdown docs to one flat, indexed convention. Use when adding or changing a file under docs/, when the user asks to document something or to check, tidy or restructure the docs, and when setting up docs in a new project.
---

# Documentation

A project's docs describe how it works today, in one flat folder that an
index maps by task. Keep them few, current and checkable.

## Layout

```
README.md             What the project is and how to run it.
AGENTS.md / CLAUDE.md Short rules for agents, pointing at docs/README.md.
docs/README.md        The index: a table from task to guide.
docs/<topic>.md       Maintained guides. Flat, kebab-case names.
docs/<kind>/          Dated records only, named YYYY-MM-DD-<slug>.md.
```

- Every guide sits at the top level of `docs/`. Do not sort guides into
  folders by type or area.
- A subfolder holds one kind of dated record: `decisions/` for a choice and
  its reasons, `evidence/` for what a check found on a given day, or another
  kind the project needs. Each has a `README.md` saying what it holds. A
  record describes a moment and is not edited afterwards. A later record
  supersedes it and links back.
- Add a `decisions/` record only for a choice someone will question or an
  agent might undo. Most reasons belong in the commit body or the owning
  guide.
- Plans, roadmaps and to-do lists are not docs. They go in `tasks/` (see the
  `tasks` skill) and leave when the work lands. History lives in git.
- A project with one or two guides needs no index. From three, it does.

A project's own docs rules override this layout. Follow an existing
convention that works, and raise the difference with the user before moving
files.

## Writing a guide

- **One job per guide.** A guide is either steps to do something, facts to
  look up, or an explanation of why the system is shaped as it is. Split a
  guide that does two, and link the halves.
- **One home per fact.** Find the guide that owns a contract and write it
  there. Everywhere else links to it. The agent file holds the short rule and
  the guide holds the detail.
- **Present tense, implemented behaviour.** Describe what the code does now.
  Leave out what it used to do and what it might do.
- **Only what the code cannot tell the reader.** Contracts, entry points,
  decisions that are not obvious, and traps. Do not restate the source.
- **Checkable claims.** Every command exists in the package scripts or the
  tool's help, and every path exists. Run a command before you document it.
  Avoid counts and lists that drift. Do not call remote infrastructure
  verified on the strength of a config file.
- **Shape.** One `#` title, an opening paragraph saying what the guide covers
  and who needs it, then sentence-case headings. Relative links whose text
  says where they go. Code in fences with a language.
- **Prose.** Apply the `unslop` skill.

## Changing code

Update the owning guide in the same change as the code. Delete the docs for
anything you remove. When you add a guide, add its row to the index.

## Audit

1. Run the checker from the repo root and read its output:

   ```sh
   python3 <this skill's folder>/scripts/check_docs.py .
   ```

   It reports broken links and anchors, guides and subfolders missing from
   the index, and top-level files that look like plans or dated records.
2. Read the guides against the code for what a script cannot see: commands
   and paths that no longer exist, behaviour that changed, two guides owning
   the same fact, and guides nobody would miss.
3. Fix broken links and index rows directly. Report everything else first,
   as a list of findings with a proposed change for each, and wait for the
   user before moving, merging or deleting guides.

## Adopting the layout

For a project whose docs do not follow it, propose a mapping from each
existing file to its new place (kept, merged, moved to a dated subfolder,
turned into tasks, or deleted) and ask before moving anything. Use `git mv`
so history follows, fix the links, and finish with a clean checker run.
