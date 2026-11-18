---
name: cleanup
description: Survey a repo or folder for slop, propose a clean-up plan, then carry out the approved parts without changing behaviour. Use when the user says "cleanup" or "clean up this repo", or asks to remove dead code, slop or misleading comments and docs.
---

# Cleanup

Leave the repo smaller, clearer and less misleading, and behaving exactly as
it did. You survey on your own, propose a plan, and change nothing until the
user approves it.

Cleanup never changes behaviour, meaning anything a user, an API caller or
another program can observe: output, responses, screens, stored data and
public interfaces. Removing a prop nobody passes is a clean-up. Removing a
field from an API response is not, even when nothing here reads it. Anything
that would change behaviour, including a likely bug, goes in the "Looks
wrong" list for the user. Larger changes that make the project better belong
to the `improve` skill.

## 1. Set the scope and baseline

- The scope is what the user names. With none named, it is the whole repo.
- Run `git status --short`. Leave uncommitted work that is not yours alone,
  and stop to ask if it overlaps the scope.
- Read the project's `AGENTS.md` or `CLAUDE.md` and its docs index, so you
  know which patterns are deliberate.
- Find what a commit or push sets off: read the CI config for deploys and
  releases. When a push to the current branch ships to production, say so at
  the top of the plan and recommend doing the work on a branch.
- Run the checks CI runs that only read the code (typecheck, lint, unit
  tests) and record the result. This is the baseline. Note anything that
  already fails. Do not let a check install dependencies, rebuild generated
  files or start services: call the installed binary directly when the
  package script would. List every check you skipped and why.

## 2. Survey

Read, search and run analysis tools. Do not edit yet. Use the tools already
installed in the project (`knip`, `tsc --noEmit`, `cargo clippy`, `ruff`). Do
not download one. When a tool that would have helped is missing, say so in
the plan.

Put the effort where the slop is. In a large repo, read the core in full and
search the rest, and move on from a category that turns up nothing after a
fair look. Look for:

- **Dead weight:** unused files, exports, dependencies, flags, scripts,
  config and assets. Commented-out code.
- **Needless indirection:** wrappers with one caller, pass-through layers,
  options nobody sets, abstractions with one implementation.
- **Duplication:** the same logic in several places under the same contract.
  Code that only looks alike is not duplication.
- **Defensive noise:** guards and try/catch for states the types rule out,
  inside trusted code.
- **Type escapes:** `any`, casts and suppressions with no reason given.
- **Comments:** narration, section banners, change history, and comments
  that no longer match the code. Keep comments that explain why.
- **Docs:** pages that are stale, duplicated or wrong, and broken links. When
  the project has a `docs/` folder, run the checker that sits beside this
  skill, `../docs/scripts/check_docs.py` from this skill's folder. It finds
  broken links. Wrong content only shows up by reading the docs against the
  code.
- **Inconsistency:** two ways of doing one thing, and names that drifted.
- **Tests:** tests that cannot fail, and tests that repeat each other.

Before you call anything dead, look for uses a search misses: names built
from strings, file-based routes, auto-imports, config and CI references,
package `exports`, Worker entry points and anything another repo imports.

## 3. Propose the plan

Reply with the plan and stop.

- **Clean-ups**, grouped by class, since each class becomes one commit. Rank
  the classes by value for the risk. For each class: why it is slop, how you
  know removing it is safe, the risk and the rough size, then its items as
  file and line with a few words each.
- **Coverage.** What you read in full, what you only searched, and which
  categories turned up nothing.
- **Looks wrong.** Things that seem off but that cleanup must not touch:
  suspected bugs, swallowed errors, security smells, docs or names that
  contradict the code, behaviour that looks unintended. Give the file and
  line and say what you would check.
- **Left alone.** What you considered and kept, and why, in a line each.
- **Prevention.** For a class that was large, the cheapest check that would
  stop it coming back, such as a lint rule, a compiler flag or a dead-code
  check in CI. These are proposals, not part of the clean-up.

When the plan is large, split it into batches that can each be reviewed in
one sitting, and recommend which to do first. Say so when the repo is
already clean. An empty plan is a valid result.

## 4. Carry out what was approved

- One class per commit, deletions first.
- Touch only what the plan named. Do not reformat, rename public things, edit
  generated files or migrations, or upgrade dependencies. Remove an unused
  dependency through the package manager.
- After each commit, run the baseline checks again. The result must match the
  baseline. If it does not, find out why before going on.
- If an item turns out to need a behaviour change, drop it and move it to
  "Looks wrong".
- Build approved prevention checks last, each in its own commit, and show
  that each one fails on the slop it targets.

## 5. Report

Per commit: what went and the diff size. Then the checks against the
baseline, the "Looks wrong" list as it now stands, and anything approved that
you did not do, with the reason.
