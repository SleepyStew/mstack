---
name: review-loop
description: Use when the user says "review loop" or "sol loop".
---

# Review loop

Have OpenAI's GPT Sol review your code changes in a loop, usually before you
file a pull request, to make them more correct.

Make the smallest changes that answer the Sol reviewer's findings. Watch for
scope creep, and push back when you disagree.

## Budget

- The default is 3 rounds in total. Round 1 is a full review. Later rounds
  check only the changed code and the open findings.
- Extend to 5 rounds only when the change touches security, permissions,
  auth, data loss or state and concurrency, and a `blocker` or `should`
  finding stays open with evidence. Extend also when the user asks.
- Stop early when a round returns only nits. Declined nits, and fixes that
  touch only comments, docs or formatting, need no new round.
- Use one reviewer only. Sol must not start subagents or other reviewers.
- Keep a ledger of each finding's id, severity and outcome, with the usage
  if it was returned. Never guess the usage.

## 1. Scope

Run `git status --short`. Do not stash, discard or include unrelated
changes. Limit the review to the paths of the change if they separate
cleanly from the rest. Otherwise stop and ask.

Run `git fetch origin`, then find the base:

- **For a pull request,** run
  `gh pr view <n> --json baseRefName,headRefOid`. Check out the branch only
  if the working tree is clean. Confirm that `HEAD` is the PR head, or is
  ahead of it only by this change. The base is
  `git merge-base HEAD origin/<baseRefName>`.
- **For local work,** the base is
  `git merge-base HEAD origin/<default-branch>`. With no remote, use a base
  the user names, or `HEAD` when the change is uncommitted work only.

The change is everything from the base to the working tree in those paths,
untracked files included. Use the same diff command in every round. State
the intent, and what is out of scope, in one or two sentences. Run the
checks that cover the change. Do not send code that this change breaks. Note
in the brief any check that is missing or that failed before this change.

## 2. Start Sol

In T3, call `orchestrator_capabilities`. Pick the latest Sol unless the user
named a version, and do not hardcode an ID. If the chosen Sol exposes a
reasoning effort, pass `high`, or the effort the user asked for. Record the
provider, model and effort only if they are exposed. Use `delegate_task` in
every round, with `role: "review"` and `mode: "async"`. Save the `taskId`,
and use a new `clientRequestId` for each round. `childThreadId` is storage
only. It is not the target for the next round. Do not use `t3_thread_send`,
`create_threads` or `t3_thread_launch` for review.

If T3 tools are not listed, try one direct capability call. Outside T3, use
a native Sol subagent and keep its ID. In Claude Code, use a custom subagent
only if it is set up to run Sol. If no route runs Sol, report the blocker. Do
not substitute another model.

Do not edit the files in scope while a review runs. Wait for the notice that
it is done. Do not poll, and do not start a second reviewer. A timeout, an
error or no reply is not approval. On a failure, cancel the task, verify
that it stopped, and start it again with the ledger.

This is the round 1 brief. T3 children get no history, so it has to stand on
its own:

```text
Review only. Do not edit, commit, push, comment on PRs or start subagents.
Repo: <abs path>
Base: <sha>
Intent: <intent>
Out of scope: <scope>
Checks: <results>
To see the change, run git diff <base> [-- <paths>] and git status --short,
and read the untracked files.
Read the surrounding code. Find bugs, broken callers and anything that does
not match the intent. Skip style unless it hides a bug. Hold the author to
the smallest change. Flag code, tests or guards the intent does not need.
Other paths, rare cases, small performance costs and extra compatibility
are nits.
Severity: blocker means the intended case is wrong. should means a real bug
that callers will hit, within the intent. nit means everything else.
Reply in this form, and keep each id stable across rounds:
VERDICT: APPROVE or CHANGES
S1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion>
```

## 3. Answer findings

Check each finding and its severity yourself. A finding about another path,
a rare case or a small cost is a nit, whatever label it came with.

- **When you agree,** make the smallest fix. Prefer deleting or narrowing
  code over adding a lock, cache, helper or option. Fix the case that
  happened. Add one focused test that fails without the fix, if the intent
  needs it.
- **When you disagree,** say why, with evidence: a file and line, a test or
  output.
- **When a finding is out of scope or a nit,** decline it in one line and
  list it as a follow-up.

Update the ledger. Run the checks and `git diff --shortstat <base>` again.
If the review grew the diff, cut it back first. Do not agree just to end the
loop.

## 4. Next round

Start another round only if budget remains and one of these holds: a
`blocker` or `should` is open, code that affects behaviour changed, or the
approval does not cover the current behaviour diff. Use a fresh
`delegate_task` in T3, or follow up with the saved native ID. Send the
round 1 brief, the ledger (`fixed:`, `disagree:` or `declined:` for each
finding, with evidence), the same base diff, and the change since the last
round. Tell Sol to look at the open ids and the changed code only, and to
mark each old id `resolved` or `still open: <reason>`.

## 5. Stop and ship

The loop has agreed when Sol returns APPROVE on the current behaviour diff,
no `blocker` or `should` is open, and you have no concern of your own.

The loop is stuck when an item stays disputed after two replies, or when the
budget ends. Show both sides in two or three lines each, and let the user
decide. The budget ending is not approval.

Do not push during the loop. After agreement, push only if the user asked
you to push, ship or update the PR. If you push to a PR, add this line above
the model blurb:

`Reviewed with review-loop: <N> rounds with <model>. Sol verdict: approved`.

Add `on <effort>` only if you verified the effort.

Report the rounds, the model, what Sol changed, the diff size before and
after, the fixed and declined findings with reasons, the usage if it was
exposed (say so if it was not), and whether you pushed.
