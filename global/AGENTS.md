This file lives in my mstack repo (github.com/SleepyStew/mstack) as `global/AGENTS.md`, and its setup script links it into place. To change it, edit it in that clone and commit.

These are my defaults across projects. A project's own `CLAUDE.md` or `AGENTS.md` overrides them.

## Keeping me in the loop

Match a reply's length to the task: answer quick questions briefly and directly. On longer tasks, say what you're about to do and give a short update when a stage finishes or the plan changes. Make those replies detailed but scannable: lead with the outcome, then the specifics, in short paragraphs or lists. Explain non-obvious decisions, and say plainly what you skipped or couldn't verify.

## Asking me questions

I prefer you ask with your question tool (`AskUserQuestion` in Claude Code) instead of in your reply text, so I can pick an answer rather than type one. When a choice is clearly a matter of preference or you need clarification, ask rather than pick a default. That covers behaviour, look and feel, scope, workflow, and names people see or depend on (commands, UI labels, public APIs, packages, projects). Name internal things such as variables, functions and files yourself, and decide yourself when the code or docs clearly settle it.

Use plain text instead when the answer has to be free-form (a detailed description), when I'd need to read a lot first (a plan, review or design), or when the tool isn't available.

## Handing work back

When work is ready for my review, show me that it works instead of telling me. This applies once, at handoff, not to updates along the way.

- **Something I can see changed:** a screenshot of the result in the running app, with a before shot when the comparison matters. Use a short recording when the change is a flow, an interaction or motion.
- **Nothing visible changed** (CLI, API, library, data, refactor): the command you ran and its real output, such as the test that failed before and passes now.
- **Trivial changes** (copy, docs, comments, config) need no capture.

You have my standing permission to run the app and use browser preview, simulator and recording tools for this without asking. A project's own rules on how to verify still apply. Capture the real app on the code as committed, never a mock-up or a generated picture of a screen. If you can't capture it, write `No screenshot: <reason>` and show the next best check. Keep captures out of the repo. The `evidence` skill has the details.

## Writing

Use British/Australian spelling in all prose: replies, commit messages, comments, docs and interface text. In code, names from a language, library, API or CSS keep their own spelling (`color`); names you add follow the codebase's convention, or American spelling if it has none. If a project's prose already uses American spelling, follow it and tell me the first time in a session, so I can ask you to switch or convert it.

Use plain hyphens, never en or em dashes. Write dates day first or in ISO form (21 October 2026, 2026-10-21), never month first.

## Memory

Put what you learn about a project (decisions, preferences, gotchas) in its `CLAUDE.md` or `AGENTS.md`, whichever it uses, or the doc it belongs in, where every session and subagent reads it. Memory is only for notes about me and details too narrow for the docs.

## Environment

My terminal runs zsh, which may not be what your shell tool runs. In commands for me to run, flag or avoid zsh differences (word splitting of unquoted variables, unmatched globs, array indexing).

Get secrets through T3's `request_secret` tool when available.

## Code

Write less code. Make the smallest change that solves the problem, and look for something to delete or reuse before adding anything.

- Follow the patterns already in the codebase, and reuse what exists before adding a helper, layer or dependency.
- Build for the case in front of you: no speculative options, abstractions with one use, or compatibility shims for callers that don't exist.
- Validate at the edges (user input, network, files) and trust the types inside. Don't guard against states that can't happen.
- Fix a bug where it starts. A guard that hides the symptom isn't a fix.
- If something outside the task looks wrong, tell me instead of fixing it quietly or ignoring it.

## Comments

Comment only what the code can't say: why it's written this way, an invariant or ordering that must hold, or a quirk of a library or platform. Public API docs and suppressions with a reason are fine. Don't narrate what the code does, label sections, record what changed, leave commented-out code or write notes to the reviewer. When you change code, update or delete the comments beside it, and don't remove an existing comment that explains why.

## Tests

Where a project has a test suite, add a regression test with each bug fix and tests for new logic. Don't set up a test framework unless I ask.

## Commits

Commit as you go on the current branch, the default branch included, without asking: at the end of each stage, at good stopping points, and when a turn is finished, including work you're about to show me, since I review the committed diff in T3. Push only when I ask; merge only once I've agreed.

In a folder that isn't a git repo, run `git init` first if you're building something meant to last. For one-off work such as answering questions or reviewing, skip commits without mentioning it.

- One change per commit; a summary that lists several things means split it.
- Stage only files you changed. Leave out changes you didn't make and mention them; if a file you changed also has someone else's changes, ask before committing it.
- Run the project's quick checks (typecheck, lint, fast tests) first. If something still fails at handback, commit anyway, list what's failing in the commit body and tell me.
- Never use `--no-verify`. If a hook blocks a commit, leave the work uncommitted and tell me.
- You may amend, squash or reorder your own unpushed commits. Never rewrite pushed commits or force-push.
- Commits are authored by me through my git config: no `Co-Authored-By` or "Generated with" lines.

Use [Conventional Commits](https://www.conventionalcommits.org): `<type>(<scope>): <summary>`, a blank line, then the body.

- **First line:** at most 72 characters, imperative, lowercase after the colon, no full stop. Detail and the why go in the body, wrapped at 72; leave the body out if it would only restate the first line.
- **Types:** `feat` (anything new or changed a user would notice, including taste changes while polishing), `fix`, `docs` (including `CLAUDE.md`, `AGENTS.md` and `.claude/`), `refactor`, `perf`, `test`, `build` (dependencies, build tooling, package and Wrangler config), `ci`, `chore` (housekeeping, such as deleting old builds or editing `.gitignore`).
- **Scope:** optional, the area most of the change touches. Use the scopes the project's `CLAUDE.md` or `AGENTS.md` lists, otherwise those in its recent history; if none fit well, choose a sensible one yourself.
- **Merges** keep git's first line (`Merge branch 'feature/x'`) with a summary in the body. For a subagent's `worktree-agent-...` branch, name what the merge brings instead (`Merge the replay controls into panel`).

## Package managers

Use pnpm for JavaScript and uv for Python in new projects. In existing ones, use whatever the lockfile or `packageManager` field shows, and never add a second lockfile.

## Deployment

I deploy with Cloudflare Wrangler. Only deploy when I ask, and treat any change to live production as a deploy, whatever makes it (Wrangler, an API, an MCP server). On Cloudflare that includes secrets, `--remote` writes and migrations for D1, KV and R2, version uploads and rollbacks, and DNS or zone settings. Reading live state is always fine, as is local and preview work (`wrangler dev`, `wrangler deploy --dry-run`), except that `wrangler dev --remote` and `remote: true` bindings use real resources, so writes through them count as deploys.
