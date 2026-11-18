---
name: improve
description: Work with the user to find and build improvements to a project's structure, stack, features and quality, one approved change at a time. Use when the user says "improve", or asks what could be better about a repo or how to take it further.
---

# Improve

Make a project better, including one that is already decent. Unlike
`cleanup`, this changes behaviour and structure, so the user stays in the
loop throughout: you suggest, they choose, you build one thing and show it,
then ask again.

Ask with the question tool whenever the user has a choice to make. Keep
anything they must read first in the reply above it.

## 1. Learn the project and the user's aim

- Read `AGENTS.md` or `CLAUDE.md`, the README, the docs index, the package
  manifest, the open tasks and the recent history.
- Run the app and use it as a user would, when you can. The global rules give
  you permission.
- Then ask the user two things: which areas they care about this time, and
  how big a change they have appetite for. Skip a question the request has
  already answered.

## 2. Look through each lens

Cover the lenses the user picked. With none picked, cover them all, lightly.

- **Structure:** where things live, module boundaries, ownership of state,
  naming, what a newcomer would trip over.
- **Stack:** dependencies that are outdated, deprecated or replaceable by
  something the framework or platform now provides. Hand-rolled code a
  maintained library does better. Check current documentation before you
  claim a library can do something.
- **Features and experience:** rough edges, missing loading, empty and error
  states, accessibility, phone layouts, and the next feature the product
  seems to want.
- **Quality:** types on risky boundaries, tests on the paths that would hurt
  most, error handling, logging.
- **Performance:** only what you measured. Give the number and how you got
  it.
- **Developer experience:** setup, scripts, CI, feedback speed, docs.
- **Security and privacy:** the obvious risks.

Pure removal with no change in behaviour is a clean-up. Note it as a pointer
to `cleanup` and leave it out of the shortlist.

## 3. Propose a shortlist

At most eight suggestions, strongest first. For each:

- what it is, in a sentence
- why it is worth doing, with the evidence: a file and line, a measurement or
  a screenshot
- what changes for the people using the product
- effort (small, medium or large) and risk
- the alternative, including leaving it as it is

Say so when an area is in good shape and needs nothing. Do not pad the list
to look thorough, and give your real view when you think an idea of the
user's is not worth it.

Then ask which to take, as a multiple-choice question.

## 4. Build one at a time

For each approved suggestion:

1. Settle its open product and design choices with the user first. Where a
   quick prototype can settle a choice, build the prototype and show both
   options instead of asking in the abstract.
2. Build the smallest version that delivers the benefit, in its own commits.
   The global rules on code, tests and commits apply.
3. Hand it back with evidence, per the `evidence` skill.
4. Ask whether to continue to the next one, change course or stop.

Keep each improvement to what was approved. A new idea found on the way
becomes a new suggestion.

These need a yes of their own each time, even inside an approved suggestion:
deploys, major dependency upgrades, data migrations and deleting user data.

## 5. Close out

List what was built, what was declined and what remains. Offer to save the
remaining suggestions as tasks when the project keeps a `tasks/` folder.
