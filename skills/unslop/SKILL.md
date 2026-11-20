---
name: unslop
description: Edit prose to remove AI writing patterns without changing its meaning or voice. Use when the user says "unslop", or asks to tighten or clean up docs, a README, a PR description, a commit message or other writing.
---

# Unslop

Edit prose so it reads as if a careful person wrote it. This is for writing:
docs, READMEs, PR descriptions, commit bodies, replies and interface text.
Code is the `cleanup` skill's job.

## How to edit

1. Read the whole text. Note who reads it and what they need from it.
2. Fix the patterns below. Change as little as the fix needs.
3. Compare your edit with the original. Every number, name, caveat and
   commitment must survive with the same strength. Cutting a hedge can turn
   "may fail" into "fails", and that is a change of meaning.
4. Keep the author's voice. When the text is the user's own, fix the patterns
   and leave their word choices and rhythm alone.

Stop when the patterns are gone. A second pass that only shortens makes the
text choppy and harder to read.

## Patterns to remove

**Filler and framing**

- Openers that praise, agree or announce ("Great question", "Here's the
  thing", "Let's dive in").
- Closers that summarise what was just said, offer more help or check in.
- Phrases that add no fact: "it is important to note that", "in order to",
  "at the end of the day".
- Signposting that promises content instead of giving it.
- Stacked hedges. One hedge, where the doubt is real.

**Shape**

- "Not just X, but Y" and "it isn't X, it's Y". State the point.
- Ideas forced into threes.
- A clause tacked on with "-ing" that adds nothing ("ensuring...",
  "highlighting...").
- A short quotable line that restates the paragraph it ends.
- "From X to Y" when X and Y are not ends of a real scale.
- A bold label that repeats its own sentence.
- Bold scattered through a paragraph, headings on a short answer, and
  decorative emoji.

**Words**

- Inflated verbs: "serves as", "stands as", "boasts", "leverages". Use "is",
  "has", "uses".
- Vocabulary that marks the text as generated, such as "delve", "crucial",
  "seamless", "robust", "landscape", "testament". Use the plain word.
- Intensifiers and sincerity markers: "really", "truly", "honestly",
  "simply".
- Metaphor where a literal phrase exists. Say what the thing does.
- Vague sources ("experts say"). Name the source or cut the claim.
- A new name for the same thing. Pick one name and repeat it.

**Substance**

- A sentence that could sit unchanged in another project's docs. Make it
  specific or cut it.
- Adjectives in place of the number or the mechanism.
- Passive voice that hides who does what, where the actor matters.

## House rules

These are the defaults for everything edited here. Where the user's
instructions or the project set a different convention, follow that.

- British or Australian spelling, unless the project's prose is already
  American.
- No en or em dashes. Plain hyphens are fine. Where a dash would join two
  clauses, use a full stop, a comma or a colon.
- Dates day first or in ISO form.
- Whole sentences with their articles and verbs. Do not compress prose into
  fragments, arrows or undefined abbreviations.

## Reply

Give the edited text. When the edit is to a file, say in a line or two what
kind of change you made. If you found a claim you could not keep without
changing its meaning, quote it and ask.
