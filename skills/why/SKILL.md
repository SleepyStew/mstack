---
name: why
description: Explain why code, a setting or a decision is the way it is, from the commits, pull requests and issues behind it. Use when the user asks "why is X like this", "why did we pick Y", or wants the history behind a design choice, a threshold or a regression.
---

# Why

Answer from the record, not from reading the code. Find the commit that
introduced the target and each later change to it (`git log -S`, `git log -L`,
`git blame`). Then read the pull requests, reviews and issues behind those
commits (`gh pr view`, `gh issue view`), and any docs that mention it. Look
further afield only when that trail is thin.

In the answer:

- Quote or cite what the authors wrote, with commit hashes and links.
- Mark your own inferences as inferences.
- Say what the record doesn't answer.

This skill covers intent. For what the code does at runtime, read and run
the code instead.
