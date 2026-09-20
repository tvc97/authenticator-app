---
name: plan
description: Produce a reviewable implementation plan before any code changes. Use after preflight, for any change beyond a trivial mechanical fix.
---

# Plan

Read-only. No edits, no branches, no commits during planning.

Delegate breadth to the `researcher` subagent first. Then write:

```md
# Implementation Plan — #<issue>

## Objective
## Existing architecture
## Files to modify
## Files to add
## Files explicitly NOT to modify          <- the reviewer checks the diff against this
## Implementation steps                    <- ordered, each independently verifiable
## Tests                                   <- what fails if the behavior regresses
## Security impact                         <- seeds, Keychain, logging, pasteboard, entitlements
## Runtime verification                    <- simulator or device, and which scenarios
## Risks
## Assumptions
## Definition of done
```

Then:

```bash
gh issue comment <issue> --body-file plan.md
gh issue edit <issue> --add-label has:plan
```

The `has:plan` label is the whole gate. Nobody approves it — the plan is on the issue, so it
is already reviewable, and the PR is where it gets checked against the diff. Go straight to
`/implement <issue>`.

What makes this safe is not an approver. It is that **the plan is a commitment the reviewer
checks the diff against** — especially `## Files explicitly NOT to modify`. A plan written
loosely enough to permit anything gates nothing. Write it to be falsifiable.

If research was inconclusive, do not write a speculative plan — report `BLOCKED` with what is
missing, and add `needs:clarification`. That label is a real stop: a question addressed to the
human is the one thing no amount of evidence can answer.
