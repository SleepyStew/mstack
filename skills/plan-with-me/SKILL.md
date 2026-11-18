---
name: plan-with-me
description: Interview the user in rounds of questions until you agree on what to build, then confirm a written summary before acting. Use when the user says "plan with me", "grill me" or "interview me", asks to plan or think something through together, or makes a request that leaves out who it is for, why, what done looks like or what limits it.
---

# Plan with me

Find out what the user actually wants before anything is built. You find the
facts and recommend; the user makes the decisions. Nothing gets built until
they have confirmed a written summary.

If you started this yourself because a request was vague, say so in one line
so the user can wave it off and have you go ahead. With no user to answer,
as in a delegated or scheduled run, state your assumptions and carry on
instead.

## 1. Look, then give your read

Read what the request touches first: the code, docs, tasks and earlier
conversation. Finding facts is your job, never the user's, so don't ask
anything you could look up. When a lookup is slow, give it to a subagent and
carry on with the questions that don't depend on it.

Then give your current read in one sentence, and list what is still open
from: who it is for, why now, what done looks like, what limits it, and what
is out of scope.

## 2. Ask in rounds

Map the open decisions as a tree, where settling one opens the ones that hang
off it. Each round asks every decision whose prerequisites are settled. A
question that depends on an answer still open in this round waits for the
next one.

- Ask each round with the question tool. Put your recommended answer first,
  labelled "(Recommended)", with the reason in its description. Use previews
  to compare layouts, code or configs side by side.
- The tool takes four questions per call. When a round has more, ask the four
  that unblock the most and keep the rest for the next round.
- Ask in plain text when the answer has to be free-form, or when the user
  needs to read something long first.
- Without a question tool, number the questions in text, give your
  recommended answer under each, and word each one so that "yes" accepts it.

After each round, update the tree and your read, then ask the next round.

## 3. Hear what they actually want

- Watch for answers that sound right without saying anything: "scalable",
  "clean", "the standard way", "I should probably". Ask what they would want
  if they didn't have to justify it to anyone.
- When a quick prototype could settle a choice, offer to build it and show
  both options instead of asking in the abstract.
- When the user says "you decide", decide, and list the choice under
  "Decided by me" in the summary so they can still see it.

## 4. Confirm the summary

Stop asking when no decision is open and you could predict the user's answers
to the next few questions. If several rounds pass and your read keeps
shifting, stop and say what seems to be missing instead.

Write the summary in the user's words where you can, leaving out lines that
don't apply. Always include "Out of scope", since much disagreement is about
what is not being built.

```text
- Outcome:       <one line>
- For:           <who benefits>
- Why now:       <what changed>
- Done when:     <how we will know it worked>
- Limits:        <the constraint that binds>
- Out of scope:  <what we are not doing>
- Decided by me: <choices the user left to you>
```

Then ask with the question tool whether it is right, offering to build it
now, to save it as a task when the project keeps a `tasks/` folder, or to
change it. A correction means updating the summary and asking again. Build
nothing until the user picks an option that says to.
