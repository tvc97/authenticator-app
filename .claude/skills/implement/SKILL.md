---
name: implement
description: Implement an approved plan in an isolated worktree, verifying after each small step. Use only after the gate:plan-approved label exists on the issue.
---

# Implement

Precondition: `gh issue view <issue> --json labels` contains `gate:plan-approved`. If not, stop.

1. **Isolate** — one issue, one worktree, one branch:
   ```bash
   git worktree add ../wt-<issue> -b <type>/<issue>-<slug> main
   ```
2. **Small step → check → small step.** After each step: `./.ai/adapter/static`.
   Never accumulate a large unverified diff; a giant broken diff costs more to debug than it saved.
3. **Stay inside the plan.** If the plan turns out to be wrong, stop and emit:
   ```
   PLAN_CHANGE_REQUIRED
   Reason:
   Proposed adjustment:
   ```
   Do not silently redefine the requirement.
4. **Write the tests in the same step as the behavior**, not at the end.
5. **Commit small**, conventional commits, each one reviewable on its own.

Authenticator rules that override convenience:
- A seed goes to the Keychain and nowhere else. Not a log, not a plist, not a breadcrumb.
- Do not add a dependency. If you believe you must, stop and propose an ADR.
- Do not touch a `frozen_paths` entry. If the change requires it, stop and ask.

Finish by running `./scripts/ai/flow verify <issue>`. Completion is the evidence file, not your opinion.
