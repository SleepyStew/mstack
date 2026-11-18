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
| `claude/settings-overrides.json` | The Claude Code user settings I want on every machine, merged into `settings.json` by setup. |
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
| `~/.claude/skills/<name>` | `skills/<name>`, one link per skill |
| `~/.codex/AGENTS.md` | `global/AGENTS.md` |
| `~/.codex/skills/<name>` | `skills/<name>`, one link per skill |

It also merges `claude/settings-overrides.json` into
`~/.claude/settings.json`, which stays a regular file that Claude Code and
you can edit. Objects merge key by key, and any other value, lists included,
replaces the one already there. Settings the overrides do not name are left
alone.

Codex gets the instructions and the skills only. `CLAUDE_CONFIG_DIR` and
`CODEX_HOME` are respected when set.

- **Nothing is deleted.** A file or folder already in the way moves to
  `mstack-backup/<timestamp>/` inside the same harness folder, and
  `settings.json` is copied there before a merge changes it.
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

The instructions and skills are links into the clone, so a pull updates
them. Run setup again when a pull adds or removes a skill or changes
`claude/settings-overrides.json`: it links the new skill, removes the link
to the one that went and merges the overrides again.

## Changing mstack

Edit the files in the clone, commit and push. The instructions and skills
are installed as links, so an edit in the clone is live at once, and an
agent's edit tools may refuse to write through the link.

Three things to know about `claude/settings-overrides.json`:

- An edit reaches a machine only when setup runs there.
- Setup puts its values back on every run, so a setting changed on one
  machine, for example from `/config`, lasts only if the overrides do not
  name it. Removing a key from the overrides does not remove it from a
  machine that already has it.
- The file is shared by every machine. `env.CLAUDE_CODE_SHELL` holds a path
  that may not exist elsewhere, in which case Claude Code picks a shell
  itself.

After changing the docs checker or the settings merge, run their tests:

```sh
python3 -m unittest discover -s skills/documentation/scripts
python3 -m unittest discover -s claude
```

## Requirements

- An authenticated [GitHub CLI](https://cli.github.com) (`gh`), or plain
  `git clone` if the repo is public.
- `python3` for `setup.sh` and the docs checker. `setup.ps1` does not need
  it.
- `sol-loop` needs a harness that can run GPT Sol. T3 Code does this with
  `delegate_task`.

## Credits

Some skills are adapted from [pstack](https://github.com/cursor/plugins/tree/main/pstack)
and [tstack](https://github.com/t3dotgg/tstack). See
[credits](CREDITS.md).
