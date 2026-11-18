---
name: tasks
description: Keep a project's planned work as plain Markdown files in a tasks/ folder. Use when the project has a tasks/ folder, or when the user asks to add, list, pick, start or finish a task, asks what to work on next, or wants a task list set up.
---

# Tasks

Planned work lives in `tasks/`, one Markdown file per task. There is no tool
to install: read and edit the files directly. A project may add its own
fields, labels and sections, and its own rules win over these.

## A task

`tasks/<slug>.md`, where the slug is the title in kebab case.

```markdown
---
title: Add push notifications
status: idea
type: feature
created: 2026-11-18
---

Goal, in a sentence or two.
```

- **status** is where the task stands: `idea` (not agreed), `ready` (agreed,
  not started) or `doing`. A finished task has no status, because its file is
  deleted.
- **type** is what it is: `feature`, `bug` or `chore`.
- **Optional fields:** `priority: high` or `priority: low`, `depends:` with a
  list of slugs, `branch:` while the work is in progress, and anything else
  the project uses.
- **The body is free-form.** A title alone is a valid task. When there is
  more to say, these headings help: Goal, Why, Scope, Open decisions,
  Decisions, Notes.

Use slugs, never numbers. Two worktrees can then add tasks without clashing.

## Working with tasks

**List.** `grep -H '^status:' tasks/*.md` shows every task and its status.
Read the files you need from there.

**Add.** Create the file with `status: idea`. Only the user moves a task from
`idea` to `ready`, so use `ready` only when they asked for the work. Check
for an existing task on the same thing first.

**Pick the next one.** Choose from `ready` tasks whose `depends` are all
finished, meaning their files are gone. Take `priority: high` first and
`priority: low` last. When that leaves more than one, ask the user.

**Start.**

1. Check that nobody else has it. Your branch cannot see a status changed on
   another one, so read it from every branch:

   ```sh
   git grep '^status:' $(git branch -a --format='%(refname:short)') -- tasks/<slug>.md
   ```

   A branch that shows `doing` has the task.
2. Read the whole task. Settle its Open decisions with the user before you
   build, using the question tool.
3. Set `status: doing` and `branch:`, and commit that on the working branch.

**While working.** Record a choice made on the way under Decisions, with the
date. Keep notes short. The task is not a diary.

**Finish.** In the last commit of the work, delete the task file and say in
the commit body what the task was and how it ended. Move any fact worth
keeping into the guide that owns it first. The task then leaves the main
branch exactly when the work merges. Finished tasks are deleted, not
archived, so that a search of the repo never turns up a stale description of
how things used to work.

To read a finished task, find the commit that removed it:
`git log --diff-filter=D --oneline -- tasks/`.

**Stop early.** Set the status back to `ready` and add a note saying why and
where the branch stands.

**Split.** When a task grows too large, move parts into new task files and
list them in the original.

## Boundaries

- Commit a task change with the work it describes.
- A task says what to build and why. How the system works goes in `docs/`.
- Product, design and pricing choices in a task are the user's. Naming and
  structure inside the code are yours.
