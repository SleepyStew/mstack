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
| `hillclimb`     | Polish has no finish line, and an agent grades its own work kindly. We agree scored criteria, then it improves a screen or flow in rounds until GPT Sol scores every criterion at the bar. Needs GPT Sol too.      |
| `cleanup`       | Repos collect dead code, slop and misleading comments. The agent surveys the repo, proposes a plan, then cleans up the approved parts with no change in behaviour.                                                 |
| `improve`       | Improvements change behaviour, so I choose them. The agent suggests, I pick, and it builds one approved change at a time.                                                                                          |
| `unslop`        | Prose from an agent reads as generated. This edits out the AI writing patterns without changing the meaning or the voice.                                                                                          |
| `documentation` | Docs need to stay few, current and checkable. This sets one flat, indexed convention for a project's `docs/` folder, with a checker script that needs `python3`.                                               |
| `tasks`         | Planned work lives as plain Markdown files in a `tasks/` folder, so there is no tool to install. A finished task's file is deleted, because old ones hold stale descriptions of the code.                        |

## The instructions

As you probably know, a global `AGENTS.md` is loaded into every session, so
it should only hold what applies to almost every session. Anything narrower
is a skill, or belongs in a project's own `AGENTS.md` or docs. Mine tells an
agent how to:

- keep me informed without padding, and ask me a question when a choice is
  a matter of preference instead of picking a default
- hand work back with proof: a screenshot, a recording or real command
  output
- write the least code that solves the problem, comment only what the code
  can't say, and add tests where they would catch something
- commit as it goes in small Conventional Commits

Setup leaves your own global instructions alone unless you run it with
`--apply-instructions`. Most of the file is about how to work and should
suit anyone. The parts below are about me, so fork the repo and change them
before you do:

| Section             | What to change                                                                                                                                                                                                                 |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| The opening lines   | They name this repo as the file's home. Point them at your fork.                                                                                                                                                               |
| Asking me questions | It prefers Claude Code's question tool to questions in the reply. Drop it if you would rather answer in text.                                                                                                                  |
| Writing             | British and Australian spelling, plain hyphens and day-first dates. Set your own spelling, punctuation and date format.                                                                                                        |
| Environment         | My terminal runs zsh and secrets come through T3 Code. Name your own shell and the way you hand over secrets.                                                                                                                  |
| Commits             | Agents commit without asking, on the default branch too, with no co-author lines, and never push or merge unasked. Change this if you want to approve commits, keep the attribution or let agents push and merge on their own. |
| Package managers    | pnpm for JavaScript and uv for Python.                                                                                                                                                                                         |
| Deployment          | Cloudflare Wrangler, and only when I ask. Replace it with how you deploy and what counts as production.                                                                                                                        |

`claude/settings-overrides.json` is mine in the same way: bash as the shell,
the fullscreen interface, the advisor model and no attribution on commits or
pull requests. Setup leaves your Claude Code settings alone unless you run
it with `--apply-settings`, so edit that file first too.

## Set up

Clone the repo anywhere and run the setup script. It's safe to run multiple times.

```sh
git clone https://github.com/SleepyStew/mstack ~/Code/mstack
~/Code/mstack/setup.sh
```

On Windows, run `setup.ps1` in PowerShell instead.

That links the skills into each harness that is installed, as
`~/.claude/skills/<name>` and `~/.codex/skills/<name>`, and touches nothing
else. The instructions and the settings are personal, so each needs a flag:

| `setup.sh`               | `setup.ps1`          | What it adds                                                                                  |
| ------------------------ | -------------------- | --------------------------------------------------------------------------------------------- |
| `--apply-instructions` | `-ApplyInstructions` | Links `global/AGENTS.md` in as `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`.              |
| `--apply-settings`     | `-ApplySettings`     | Merges `claude/settings-overrides.json` into `~/.claude/settings.json`. See [Settings](#settings). |
| `--all`                | `-All`               | Both of the above. This is what I run on my own machines.                                     |
| `--dry-run`            | `-DryRun`            | Prints what the run would do and changes nothing. Combine it with the others.                 |

`CLAUDE_CONFIG_DIR` and `CODEX_HOME` are respected when set. On Windows,
linking the instructions needs Developer Mode or an elevated shell.

- **Files and folders are never deleted.** One already in the way moves to
  `mstack-backup/<timestamp>/` inside the same harness folder. A link in the
  way is replaced, and what it pointed at is left alone.
- **Other skills are left alone.** Only skills that share a name with one
  here are replaced.
- **Don't move the clone.** The links hold its path. If you move it, run
  setup again.

New sessions pick the files up. Sessions already running keep what they
loaded.

### Settings

`--apply-settings` is for Claude Code only. Codex gets no settings.

`settings.json` stays a regular file that Claude Code and you can edit, and
it is copied to the backup folder before a merge changes it. It is merged
and not linked because Claude Code rewrites `settings.json` when it saves a
setting, which would replace a link with a regular file. Objects merge key
by key, and any other value, lists included, replaces the one already there.
Settings the overrides do not name are left alone.

The merge needs `python3` in `setup.sh`. In PowerShell, use Windows
PowerShell or PowerShell 7.5 or later: PowerShell 6 to 7.4 rewrites a
`settings.json` string that looks like a timestamp in another form.

## Update

```sh
git -C ~/Code/mstack pull
```

A pull updates the instructions and skills, since they are links into the
clone. Run setup again, with the flags you used before, when a pull adds or
removes a skill or changes `claude/settings-overrides.json`: it links the
new skill, removes the link to the one that went and merges the overrides
again.

## Remove

```sh
~/Code/mstack/remove.sh
```

On Windows that is `remove.ps1`. It takes out the links that point into the
clone and nothing else, so your own skills stay. Where setup moved a file or
folder of yours aside to make room for a link, such as your own `CLAUDE.md`,
the newest copy in `mstack-backup/` is moved back.

`settings.json` keeps any overrides you applied, because it may have changed
since and an old copy would lose that. Its earlier versions are in
`mstack-backup/` inside the harness folder if you want one back.

Then delete the clone.

## Changing mstack

Edit the files in the clone, commit and push. An edit to the instructions
or a skill is live at once, though an agent's edit tools may refuse to
write through the link.

`claude/settings-overrides.json` is shared by every machine, and an edit to
it reaches a machine only when setup runs there with `--apply-settings`.
That puts its values back on every run, so a setting changed on one machine, for example from
`/config`, lasts only if the overrides do not name it. Removing a key from
the overrides does not remove it from a machine that already has it.
`env.CLAUDE_CODE_SHELL` names a shell, not a path, because the path differs
by machine. `setup.sh` writes the path it finds there, and leaves the
setting alone when the shell is missing. `setup.ps1` always leaves it alone,
since Claude Code on Windows finds Git Bash itself.

After changing the docs checker, the settings merge or a setup script, run
its tests:

```sh
python3 -m unittest discover -s tests
```

`tests/test_setup.ps1` does the same for `setup.ps1` and `remove.ps1` on
Windows. CI runs all of them on every push to `main`, the Windows one under
both Windows PowerShell and PowerShell 7.

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
`hillclimb` takes ideas from the Hillclimb and Eval playbooks in pstack's
`poteto-mode` and from tstack's `council` and `full-send`.

The adapted parts are under the MIT licence in [LICENSE](LICENSE), with the
copyright lines above.
