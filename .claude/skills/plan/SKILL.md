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

Stop. State: `AWAITING_PLAN_APPROVAL`. A human adds `gate:plan-approved`.
Do not create a branch before that label exists.

If research was inconclusive, do not write a speculative plan — report `BLOCKED` with what is missing.
