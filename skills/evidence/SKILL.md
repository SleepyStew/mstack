---
name: evidence
description: Capture proof that work is ready for review, as screenshots or a short recording for visible changes and real command output otherwise. Use at handoff, when the user asks for proof, a screenshot or a video, or says "show me".
---

# Evidence

The user reviews what you show, not what you say. At handoff, give them proof
they can check at a glance, captured from the real thing.

Do this once, when the work is ready for review. Stage updates along the way
need no captures.

## Pick the proof

| What changed | Proof |
| --- | --- |
| A screen, layout or style | Screenshot of the result. Add a before shot at the same size when the comparison matters. |
| A flow, interaction, animation or timing | Recording of that flow only, under 30 seconds. |
| Layout at more than one size | One desktop and one phone-width screenshot. |
| A bug with a visible symptom | The symptom before, and the same steps after. |
| CLI, API, library, data or build | The command and its real output, trimmed to the part that matters. |
| A refactor | The checks that pass, and the diff size. |
| Copy, docs, comments or config | Nothing. Say what you changed. |

When several rows apply, use the one closest to what the user will look at
first.

## Capture it

1. Find how the project runs. Read its `AGENTS.md` or `CLAUDE.md`, its docs
   and its package scripts before guessing. Follow any rule there about how
   to verify, such as which launcher or URL to use.
2. Commit first, then run the app from that commit. A capture of a stale
   build proves nothing.
3. Drive the app the way a user would, through the real entry point. Do not
   set state through devtools, a test-only route or a script to reach the
   screen.
4. Capture with the harness's tools. In T3 Code these are the `preview_*`
   tools for a browser tab, recording included, and the device tools for a
   simulator or emulator. The user's standing permission covers them.
5. Look at the capture before you send it. If it shows something wrong, fix
   the work or report the problem. Do not reshoot until it looks right.

## Keep it honest

- Capture in this session. Never reuse an earlier capture after the code
  changed.
- Show the real app. Never a mock-up, a rendered HTML copy or a generated
  image of a screen.
- Keep enough of the page in frame to show where you are. Do not crop out an
  error or a console warning that matters.
- Say when the data is seeded or a service is mocked.
- A passing mocked test does not show that the screen works. Say which of
  the two you have.

## Store and send it

- Save captures outside the repo, in the session's scratch folder. Commit
  one only when the project already keeps dated evidence, and follow its
  convention.
- Embed each capture in the handoff reply by absolute path, with one line
  under it saying what it shows.
- Never upload a capture to a public host. In a pull request, say in one line
  how you proved the change, and attach captures only when the harness can
  upload them privately.

Lead the reply with the captures, then what changed, then what you did not
check.

## When you can't capture

Write `No screenshot: <reason>` in the reply. Show the next best check and
say what stays unverified. Try a capture a few times, then stop. Do not
build a harness to photograph a one-line change.

If you had to work out how to launch or drive the project, offer to record
it in the project's docs so the next session does not start from nothing.
