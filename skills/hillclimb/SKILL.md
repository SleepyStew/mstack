---
name: hillclimb
description: Agree scored criteria with the user, then improve a screen, flow or other work that is judged by looking at it, in rounds, until GPT Sol scores every criterion at the agreed bar. Use when the user says "hillclimb" or "hill climb", or asks to keep improving something until it reaches a score.
---

# Hillclimb

Improve something people judge by looking at it or using it, such as a
screen, a flow or a whole interface, in rounds, until an independent judge
scores every agreed criterion at the bar. `review-loop` works from findings
on a diff to agreement. This works from scores on the running product to a
bar, and runs for much longer.

You build and OpenAI's GPT Sol judges. You never score your own work, and
the judge is never told what you changed.

Keep the run's files in the session's scratch folder, outside the repo:
`criteria.md`, `log.md` and one folder of captures per round.

## 1. Look first

Read the project's `AGENTS.md` or `CLAUDE.md` and its docs for how to run
it. Run `git status --short` and leave work that is not yours alone. Run the
checks that cover the area and note any that already fail. Then run the app
and capture the target as it stands, the way the `evidence` skill describes:
the real app, through the real entry point.

## 2. Agree the criteria

Show the user the captures and your read of what is weak. Then settle the
points below in rounds of questions, as the `plan-with-me` skill does. You
propose from what you saw, and the user decides.

- **Target:** the screens, flows and states in scope, who uses them, and
  what is out of scope.
- **Criteria:** three to six. Each names one quality a judge can see in a
  capture, and says what a 10 and a 5 look like, in the user's words where
  you can. "Feels modern" is not a criterion until it says what you would
  see. Ask for a product the user admires when they struggle to describe a
  10.
- **Capture set:** the fixed list of screenshots and recordings that every
  round retakes: which screens, in which states (empty, loading, error,
  full), at which widths and themes, with what data. Note the steps that
  reach each one, so two sets differ only by the code. The judge sees
  nothing else, so a state left out goes unjudged.
- **Bar:** the score out of 10 that every criterion must reach. Recommend 8.
  There is no average, because an average hides one weak criterion.
- **Gates:** the checks that must stay green, and what must not change, such
  as behaviour, copy, other screens or the design system.
- **Budget:** the most rounds to run. Recommend 10. A length of time is not
  a budget.

Write the result to `criteria.md` in this form, then ask with the question
tool whether it is right. Build nothing until the user confirms it.

```text
Target:       <screens and flows>, for <who uses them>
Out of scope: <what is not being changed or judged>
C1 <name>: <the quality judged>. 10: <what you would see>. 5: <the same>.
C2 ...
Captures:     <file name>: <screen, state, width>, one per line
Bar:          every criterion at <n>/10
Gates:        <checks>. Must not change: <list>
Budget:       <n> rounds
```

## 3. Baseline

Take the capture set from the current commit and have the judge score it,
as section 4 describes. This is round 0. Use it to check that the criteria
can tell good from bad:

- If the baseline already passes, the criteria are too easy or there is
  nothing to climb. Say so and ask.
- If the scores miss what the user said was wrong, a criterion is too vague.
  Fix it with the user now.
- If the judge could not open a capture, or left a criterion unscored,
  change the capture set with the user now.

Otherwise send the baseline scores as an update and carry on. From here the
criteria, the bar and the capture set are frozen, and only the user can
change them. Never lower the bar, reword a criterion, or pick data or states
that flatter a capture.

## 4. The judge

Start Sol as the "Start Sol" section of `review-loop` describes: the same
choice of model and effort, the same `delegate_task` call and the same rule
against a substitute model. Use a fresh judge every round. A judge that has
scored before anchors on its old scores.

Scores from two judges can differ by a point with nothing changed, so
compare only scores that one judge gave in one sitting. After round 0, give
the judge two capture sets, the last kept one and the new one. Copy them
into a new folder that holds nothing else, as `A` and `B` at random, with
the same file names in each. Record which is which in the log, never in the
brief. The judge is not told the bar, the round or what changed.

The brief has to stand on its own, since a T3 child gets no history:

```text
Score only. Do not edit, commit, push or start subagents.
You are judging <target> for <who uses it>.
Criteria, each scored from 1 to 10 against its anchors:
<the C lines from criteria.md>
Captures: <abs path>/A and <abs path>/B hold the same screens and states
from two versions. You are not told which is newer. Do not try to find out.
Open every capture. Score what the captures show, not what the code or its
author intends. If you cannot open a capture, say so, and give no score
that depends on it.
Reply with one line for each set and criterion, in this form:
A C1 <n>/10 <capture file>: <what you saw>. Raise it by: <one change>
```

In round 0, name the one folder and leave out the sentences about two
versions.

Check each score against the capture it cites. If it cites something the
capture does not show, discard that judging and run one fresh judge. Never
argue a score up. A missing score, a timeout or an error is not a pass.

## 5. Rounds

The user is not watching. Once the baseline holds, work without stopping to
ask or to report until section 6 says to stop. End a turn mid-run only to
wait for a judge, whose notice wakes you. Each round:

1. **Aim.** Take the lowest criterion of the last kept set. From the judge's
   "Raise it by" note and your own look at the captures, pick one idea,
   however large, and write down why it should raise that score.
2. **Build.** Change only what the idea needs, run the gates, and commit it
   on its own. If a gate fails and the idea cannot be built without
   breaking it, drop the change and log the round without a judge.
3. **Capture.** Retake the whole capture set from that commit, the same way
   as every round before.
4. **Judge.** Wait for the scores. Do not start the next change while a
   judge runs.
5. **Keep or revert.** Keep the commit when the new set is at the bar on
   every criterion, or when it scores higher than the old on the criterion
   you aimed at and lower on none. Otherwise revert it in full. A change
   that only might help is not kept.
6. **Log.** Add one row to `log.md`: the round, the idea, the commit, both
   sets' scores, kept or reverted, and the judge's main note.

After three reverts in a row, stop adjusting. Read the judge's notes from
every round again and try a different kind of change, such as restructuring
a layout instead of tuning it, or combining two near misses.

## 6. Stop

- **Passed:** a judge scored the capture set of the code as it now stands at
  the bar or above on every criterion, and the gates are green.
- **Budget spent, or stuck:** the rounds ran out, or three more reverts
  followed the change of approach. Neither is a pass. Stop and report.
- **Blocked:** a criterion cannot rise without breaking a gate or leaving
  the scope, or a criterion now looks wrong. Ask with the question tool, so
  the thread shows that it is waiting, with the scores and the options in
  the question.

Do not push.

## 7. Report

Hand back per the `evidence` skill, leading with before and after captures
of the screens that changed most. Then give:

- the outcome: passed, budget spent, stuck or blocked
- each criterion's baseline and final score beside the bar
- the rounds run, with one line for each kept change and each reverted idea
- the judge's model, and its effort if that was exposed
- the gates' results, and what the capture set left unjudged
- the path to `log.md`, and the idea you would try next
