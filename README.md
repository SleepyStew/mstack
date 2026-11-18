# mstack

How I want coding agents to work with me: one file of global instructions
and a small set of skills. It works in Claude Code and Codex, and uses
[T3 Code](https://github.com/pingdotgg/t3code) features where they exist.

The aim is less code of higher quality, and agents that show their work
instead of describing it.

## What's here

| Path | What it is |
| --- | --- |
| `global/AGENTS.md` | Instructions loaded into every session: how to talk to me, write, code, comment, test, commit and hand work back. |
| `skills/evidence` | Capturing screenshots, recordings or command output as proof at handoff. |
| `skills/unslop` | Editing prose to remove AI writing patterns. |
| `skills/cleanup` | Surveying a repo for slop, proposing a plan, then cleaning up with no change in behaviour. |
| `skills/improve` | Suggesting and building improvements to a project, one approved change at a time. |
| `skills/docs` | One flat, indexed convention for a project's `docs/` folder, with a checker script. |
| `skills/tasks` | Planned work as plain Markdown files in a `tasks/` folder. |
| `skills/sol-loop` | Reviewing a change with GPT Sol in a loop until both agents agree. |

`global/AGENTS.md` holds only what applies to almost every session. Anything
narrower is a skill, or belongs in a project's own `AGENTS.md` or docs.

## Set up

These steps are written for an agent to follow. They are safe to repeat, and
repeating them is how to update.

1. **Get the repo.** Clone it, or pull if it is already there.

   ```sh
   gh repo clone SleepyStew/mstack ~/Code/mstack
   git -C ~/Code/mstack pull --ff-only
   ```

2. **Check the global file before replacing it.** The targets are
   `~/.claude/CLAUDE.md` for Claude Code and `~/.codex/AGENTS.md` for Codex.
   If a target exists and its first line does not mention mstack, it holds
   someone's own instructions: show the user the difference and ask before
   going on.

3. **Install the global file and the skills** for each harness that is
   present. Run this from the repo root.

   ```sh
   cd ~/Code/mstack
   [ -d "$HOME/.claude" ] && cp global/AGENTS.md "$HOME/.claude/CLAUDE.md"
   [ -d "$HOME/.codex" ] && cp global/AGENTS.md "$HOME/.codex/AGENTS.md"
   for home in "$HOME/.claude" "$HOME/.codex"; do
     [ -d "$home" ] || continue
     for skill in skills/*/; do
       name=$(basename "$skill")
       mkdir -p "$home/skills/$name"
       cp -R "$skill". "$home/skills/$name/"
     done
   done
   ```

   This overwrites the files of skills that share a name with one in mstack
   and deletes nothing. Other skills in those folders are left alone.

4. **Confirm.** List `~/.claude/skills` or `~/.codex/skills` and check that
   each skill in the table above is there. New sessions pick the files up.
   Sessions already running keep the old ones.

Because nothing is deleted, a skill or file that mstack has dropped stays
installed until someone removes it by hand.

## Changing mstack

Edit the files here, never the installed copies, then repeat step 3. After
changing the docs checker, run its tests:

```sh
python3 -m unittest discover -s skills/docs/scripts
```

## Requirements

- An authenticated [GitHub CLI](https://cli.github.com) (`gh`).
- `python3` for the docs checker.
- `sol-loop` needs a harness that can run GPT Sol. T3 Code does this with
  `delegate_task`.

## Credits

Some skills are adapted from [pstack](https://github.com/cursor/plugins/tree/main/pstack)
and [tstack](https://github.com/t3dotgg/tstack). See
[credits](CREDITS.md).
