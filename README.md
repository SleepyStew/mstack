# mstack

How I want coding agents to work with me: one file of global instructions,
a small set of skills and my Claude Code settings. It works in Claude Code
and Codex, and uses [T3 Code](https://github.com/pingdotgg/t3code) features
where they exist.

The aim is less code of higher quality, and agents that show their work
instead of describing it.

## What's here

| Path | What it is |
| --- | --- |
| `global/AGENTS.md` | Instructions loaded into every session: how to talk to me, write, code, comment, test, commit and hand work back. |
| `claude/settings.json` | My Claude Code user settings. |
| `skills/evidence` | Capturing screenshots, recordings or command output as proof at handoff. |
| `skills/unslop` | Editing prose to remove AI writing patterns. |
| `skills/cleanup` | Surveying a repo for slop, proposing a plan, then cleaning up with no change in behaviour. |
| `skills/improve` | Suggesting and building improvements to a project, one approved change at a time. |
| `skills/documentation` | One flat, indexed convention for a project's `docs/` folder, with a checker script. |
| `skills/tasks` | Planned work as plain Markdown files in a `tasks/` folder. |
| `skills/sol-loop` | Reviewing a change with GPT Sol in a loop until both agents agree. |

`global/AGENTS.md` holds only what applies to almost every session. Anything
narrower is a skill, or belongs in a project's own `AGENTS.md` or docs.

## Set up

Clone the repo anywhere and run the setup script. A person or an agent can
do this, and it is safe to run again.

```sh
gh repo clone SleepyStew/mstack ~/Code/mstack
~/Code/mstack/setup.sh
```

On Windows, run `setup.ps1` in PowerShell instead. File links there need
Developer Mode or an elevated shell.

The script links these into place, for each harness that is installed:

| Link | Points at |
| --- | --- |
| `~/.claude/CLAUDE.md` | `global/AGENTS.md` |
| `~/.claude/settings.json` | `claude/settings.json` |
| `~/.claude/skills/<name>` | `skills/<name>`, one link per skill |
| `~/.codex/AGENTS.md` | `global/AGENTS.md` |
| `~/.codex/skills/<name>` | `skills/<name>`, one link per skill |

Codex gets the instructions and the skills only. `CLAUDE_CONFIG_DIR` and
`CODEX_HOME` are respected when set.

- **Nothing is deleted.** A file or folder already in the way moves to
  `mstack-backup/<timestamp>/` inside the same harness folder.
- **Other skills are left alone.** Only skills that share a name with one
  here are replaced.
- **Don't move the clone.** The links hold its path. If you move it, run
  setup again.

New sessions pick the files up. Sessions already running keep what they
loaded.

## Update

```sh
git -C ~/Code/mstack pull
```

That is all, because everything is a link into the clone. Run setup again
only when a pull adds or removes a skill: it links the new one and removes
the link to the one that went.

## Changing mstack

Edit the files in the clone, commit and push. The installed paths are links,
so an edit in the clone is live at once, and an agent's edit tools may refuse
to write through the link.

Two things to know about `claude/settings.json`:

- Claude Code may replace the link with a regular file when it saves a
  setting itself, for example from `/config`. This machine's copy then stops
  following the repo. Run setup again to restore the link. The replaced file
  goes to the backup folder, so copy across any change worth keeping.
- The file is shared by every machine. `env.CLAUDE_CODE_SHELL` holds a path
  that may not exist elsewhere, in which case Claude Code picks a shell
  itself.

After changing the docs checker, run its tests:

```sh
python3 -m unittest discover -s skills/documentation/scripts
```

## Requirements

- An authenticated [GitHub CLI](https://cli.github.com) (`gh`), or plain
  `git clone` if the repo is public.
- `python3` for the docs checker.
- `sol-loop` needs a harness that can run GPT Sol. T3 Code does this with
  `delegate_task`.

## Credits

Some skills are adapted from [pstack](https://github.com/cursor/plugins/tree/main/pstack)
and [tstack](https://github.com/t3dotgg/tstack). See
[credits](CREDITS.md).
