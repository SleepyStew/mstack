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
the judge is never told what you changed. You may reject the judge's advice
with a reason, and later judges rule on it.

Keep the run's files in the session's scratch folder, outside the repo:
`criteria.md`, `notes.md`, `log.md` and one folder of captures per round.

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

Otherwise answer the baseline's notes as section 5 describes, send the
scores as an update and carry on. From here the
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
Disputed notes: an earlier judge gave these and the author rejected them.
Rule on each before you score. Uphold a note only if you would give it
yourself, and lower no score for one you drop.
N4 C2 <capture file>, <element>: <the note>. Rejected: <reason, evidence>
Reply first with one line for each disputed note:
N4 upheld: <reason>
N4 dropped
Give one score line for each set and criterion:
A C1 <n>/10 <what you saw>
Under each score below 10, give one to three notes on what holds it down,
the costliest first and at least one of them major:
A C1 [major|nit] <capture file>, <element>: <fault>. Change: <what to do>
A note names one capture, one element in it and one change that someone
could make without asking what you meant. "Improve the hierarchy" is not a
note. major means the change would raise this score. nit means it would
not.
```

In round 0, name the one folder and leave out the sentences about two
versions. Leave out the disputed notes when there are none.

Check each major note against the capture it cites. If one cites something
the capture does not show, discard that judging and run one fresh judge.
Never argue a score up. A missing score, a timeout or an error is not a
pass.

## 5. Answer the notes

A note is the judge's advice, and you check it as you would a review
finding. The score is the judge's alone. Keep every note on the set you
kept in `notes.md`, with an id of your own, its criterion, its label and one
outcome:

- **Open:** a note you agree with and have not built yet.
- **Taken:** built, with the round that built it.
- **Rejected:** a major note that is wrong, because its change would break
  a gate, leave the scope, or go against a criterion's anchors or another
  criterion. Give the reason with evidence: a capture, a line of
  `criteria.md` or a gate's output. The work it would take is not a reason.
- **Declined:** a nit you disagree with, in one line. It holds no score
  down, so no judge rules on it.

A nit raises no score, so it is never a round's idea. The open nits ride
with one instead, as section 6 describes, and never hold up a pass.

A fresh judge often repeats an old note. Match it to the id it already has,
and do not open it again. Leave out a note that names no element or no
change. It gives you nothing to build, and your own look at the captures
still can.

Rejecting a note does not raise a score. List every rejected note in each
later brief for as long as the captures still show what it describes, and
record each judge's ruling beside it. A judge that drops the note scores
without it. Once two judges in a row have upheld it, take it or stop as
blocked.

## 6. Rounds

The user is not watching. Once the baseline holds, work without stopping to
ask or to report until section 7 says to stop. End a turn mid-run only to
wait for a judge, whose notice wakes you. Each round:

1. **Aim.** Take the lowest criterion of the last kept set. Pick one idea,
   however large, from its open notes or your own look at the captures, and
   write down why it should raise that score.
2. **Build.** Change only what the idea needs, run the gates, and commit it
   on its own. If a gate fails and the idea cannot be built without
   breaking it, drop the change and log the round without a judge.
   Otherwise build the open nits after it, one commit each, and run the
   gates again.
3. **Capture.** Retake the whole capture set from that commit, the same way
   as every round before.
4. **Judge.** Wait for the scores. Do not start the next change while a
   judge runs.
5. **Keep or revert.** Keep the round's commits when the new set is at the
   bar on every criterion, or when it scores higher than the old on the
   criterion you aimed at and lower on none. Otherwise revert them in full.
   Their nits stay open and sit out the next round, in case one of them
   cost the score. A change that only might help is not kept.
6. **Notes.** Answer the notes on the set you kept, and record the rulings
   on the disputed ones.
7. **Log.** Add one row to `log.md`: the round, the idea and the notes it
   took, the commit, both sets' scores, and kept or reverted.

After three reverts in a row, stop adjusting. Read the judge's notes from
every round again and try a different kind of change, such as restructuring
a layout instead of tuning it, or combining two near misses.

## 7. Stop

- **Passed:** a judge scored the capture set of the code as it now stands at
  the bar or above on every criterion, and the gates are green.
- **Budget spent, or stuck:** the rounds ran out, or three more reverts
  followed the change of approach. Neither is a pass. Stop and report.
- **Blocked:** a criterion cannot rise without breaking a gate or leaving
  the scope, two judges in a row upheld a note you still reject, or a
  criterion now looks wrong. Ask with the question tool, so the thread
  shows that it is waiting, with the scores, both sides of a disputed note
  and the options in the question.

Do not push.

## 8. Report

Hand back per the `evidence` skill, leading with before and after captures
of the screens that changed most. Then give:

- the outcome: passed, budget spent, stuck or blocked
- each criterion's baseline and final score beside the bar
- the rounds run, with one line for each kept change and each reverted idea
- the notes you rejected, with each judge's ruling, and the nits you
  declined or left open
- the judge's model, and its effort if that was exposed
- the gates' results, and what the capture set left unjudged
- the path to `log.md`, and the idea you would try next
