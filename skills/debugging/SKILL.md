---
name: debugging
description: Find and fix the root cause of a bug, failing test, crash or slowdown by first building a check that fails on it. Use when the user reports something broken, throwing, failing, flaky or slow, or says "debug this" or "diagnose".
---

# Debugging

Most of the work is the first step: a check that fails on this bug. With one,
the cause falls out. Without one, reading code produces theories, not fixes.

When the cause is already plain, such as a typo, a wrong constant or a
missing import, just fix it. Use this method when it isn't.

Redact secrets in anything you show, and keep credentials in environment
variables rather than in scripts.

## 1. Build a failing check

Before forming any theory, make one command that reproduces the user's exact
symptom. Try roughly in this order:

1. A failing test at whatever level reaches the bug.
2. A script or `curl` against the running dev server.
3. The CLI with a fixture input, diffed against known good output.
4. A browser script that asserts on the page, console or network. In T3
   Code the preview tools can drive it.
5. A captured request, payload or log replayed through the code path.
6. A throwaway harness that calls the code directly.
7. Many random inputs, for bugs that are only sometimes wrong.
8. `git bisect run` with the check, when it worked at an earlier commit.
9. The same input through the old and new versions, with the outputs diffed.

The check is ready when you have run it and it:

- fails on the symptom the user described, not a nearby one
- gives the same result every run. For a flaky bug, loop it, run it in
  parallel or add load until it fails often enough to work with.
- runs in seconds, without a person in the loop

If you can't build one, stop. Say what you tried, and ask for access to
where it reproduces, a captured log, HAR file or recording, or permission
to add temporary logging. Don't guess at a fix without a check.

## 2. Shrink it

Cut inputs, steps, config and data one at a time, rerunning the check after
each cut, until every part left is needed for the failure.

## 3. Rank hypotheses

Write three to five before testing any. Give each a prediction: "if X is
the cause, changing Y makes the check pass". Show the list to the user, who
may already know which one it is, but carry on with your ranking unless they
answer.

## 4. Test one at a time

Each probe tests one prediction and changes one thing. Prefer a debugger or
REPL, then logs at the boundary that separates two hypotheses. Tag every
temporary log with a unique prefix such as `[DEBUG-a4f2]` so one search finds
them all. For a slowdown, measure a baseline and bisect instead of logging.

## 5. Fix it where it starts

Fix the cause, not where it shows. A guard that hides the symptom is not a
fix.

When the global rules call for a regression test, turn the shrunk repro into
one at a level where it exercises the real bug. Watch it fail before the fix
and pass after. If the only place a test fits is too shallow to reproduce
the bug, say so instead of writing a test that would pass anyway.

## 6. Clean up and report

- Rerun the original check and confirm it passes.
- Remove the tagged logs and any throwaway harnesses.
- Put the cause, and how you proved it, in the commit body.

Hand back per the `evidence` skill: the check failing before the fix and
passing after.
