# mstack

How I want coding agents to work with me, kept small on purpose.
The aim is less code of higher quality, and agents that are independent
and show their work instead of describing it.

## The skills

| Skill             | Why it is here                                                                                                                                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `plan-with-me`  | A vague request gets built the way the agent guessed it. Here the agent looks up the facts itself, interviews me in rounds of questions about the decisions, and builds nothing until I confirm a written summary. |
| `debugging`     | Reading code produces theories, not fixes. The agent first builds a check that fails on the bug, finds the root cause, then fixes it where it starts.                                                              |
| `why`           | Code shows what it does and rarely why. The answer comes from the commits, pull requests and issues behind it, with the agent's own inferences marked.                                                             |
| `evidence`      | I review what an agent shows, not what it says. At handoff it captures screenshots, a recording or real command output as proof.                                                                                   |
| `review-loop`   | A change is more likely to be correct once a second model has reviewed it. GPT Sol reviews in a loop until both agents agree. Needs a harness that can run GPT Sol, which T3 Code does with `delegate_task`.     |
| `cleanup`       | Repos collect dead code, slop and misleading comments. The agent surveys the repo, proposes a plan, then cleans up the approved parts with no change in behaviour.                                                 |
| `improve`       | Improvements change behaviour, so I choose them. The agent suggests, I pick, and it builds one approved change at a time.                                                                                          |
| `unslop`        | Prose from an agent reads as generated. This edits out the AI writing patterns without changing the meaning or the voice.                                                                                          |
| `documentation` | Docs need to stay few, current and checkable. This sets one flat, indexed convention for a project's `docs/` folder, with a checker script that needs `python3`.                                               |
| `tasks`         | Planned work lives as plain Markdown files in a `tasks/` folder, so there is no tool to install. A finished task's file is deleted, because old ones hold stale descriptions of the code.                        |

## Set up

Clone the repo anywhere and run the setup script. It's safe to run multiple times.

```sh
git clone https://github.com/SleepyStew/mstack ~/Code/mstack
~/Code/mstack/setup.sh
```

`setup.sh` needs `python3`. On Windows, run `setup.ps1` in PowerShell
instead, which does not. File links there need Developer Mode or an
elevated shell. Use Windows PowerShell or PowerShell 7.5 or later:
PowerShell 6 to 7.4 rewrites a `settings.json` string that looks like a
timestamp in another form.

The script links these into place, for each harness that is installed:

| Link                        | Points at                             |
| --------------------------- | ------------------------------------- |
| `~/.claude/CLAUDE.md`     | `global/AGENTS.md`                  |
| `~/.claude/skills/<name>` | `skills/<name>`, one link per skill |
| `~/.codex/AGENTS.md`      | `global/AGENTS.md`                  |
| `~/.codex/skills/<name>`  | `skills/<name>`, one link per skill |

It also merges `claude/settings-overrides.json` into
`~/.claude/settings.json`, which stays a regular file that Claude Code and
you can edit. It is merged and not linked because Claude Code rewrites
`settings.json` when it saves a setting, which would replace a link with a
regular file. Objects merge key by key, and any other value, lists included,
replaces the one already there. Settings the overrides do not name are left
alone.

Codex gets the instructions and the skills only. `CLAUDE_CONFIG_DIR` and
`CODEX_HOME` are respected when set.

- **Files and folders are never deleted.** One already in the way moves to
  `mstack-backup/<timestamp>/` inside the same harness folder, and
  `settings.json` is copied there before a merge changes it. A link in the
  way is replaced, and what it pointed at is left alone.
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

A pull updates the instructions and skills, since they are links into the
clone. Run setup again when a pull adds or removes a skill or changes
`claude/settings-overrides.json`: it links the new skill, removes the link
to the one that went and merges the overrides again.

## Changing mstack

Edit the files in the clone, commit and push. An edit to the instructions
or a skill is live at once, though an agent's edit tools may refuse to
write through the link.

`claude/settings-overrides.json` is shared by every machine, and an edit to
it reaches a machine only when setup runs there. Setup puts its values back
on every run, so a setting changed on one machine, for example from
`/config`, lasts only if the overrides do not name it. Removing a key from
the overrides does not remove it from a machine that already has it.
`env.CLAUDE_CODE_SHELL` holds a path that may not exist on every machine,
in which case Claude Code picks a shell itself.

After changing the docs checker, the settings merge or a setup script, run
its tests:

```sh
python3 -m unittest discover -s tests
```

`tests/test_setup.ps1` does the same for `setup.ps1` on Windows. CI runs
all of them on every push to `main`, the Windows one under both Windows
PowerShell and PowerShell 7.

## Credits

Some skills are adapted from these projects:

- `unslop` from [pstack](https://github.com/cursor/plugins/tree/main/pstack), (c) 2026 Lauren Tan
- `why` from [pstack](https://github.com/cursor/plugins/tree/main/pstack), (c) 2026 Lauren Tan
- `review-loop` from the `sol-loop` skill in [tstack](https://github.com/t3dotgg/tstack), (c) 2026 Theo Browne
- `plan-with-me` from the `grilling` skill in [mattpocock/skills](https://github.com/mattpocock/skills),
  (c) 2026 Matt Pocock, and the `interview-me` skill in
  [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills), (c) 2025 Addy Osmani
- `debugging` from the `diagnosing-bugs` skill in [mattpocock/skills](https://github.com/mattpocock/skills), (c) 2026 Matt Pocock

`cleanup`, `evidence` and `documentation` take ideas from pstack's `correct`,
`prove-it-works` and `technical-writing` skills and from tstack's
`full-send`.

The adapted parts are under the MIT licence in [LICENSE](LICENSE), with the
copyright lines above.
