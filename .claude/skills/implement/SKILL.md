---
name: implement
description: Implement a plan in an isolated worktree, verifying after each small step. Use once the issue carries has:plan.
---

# Implement

Precondition: the issue carries `has:plan`. If not, run `/plan <issue>` first.
No human approval step — see ADR-002.

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
- `manifest.yml: human_paths` (entitlements, `Info.plist`, `.claude/hooks/**`,
  `.claude/settings.json`) cannot be edited at all — the settings deny list and
  `pre-tool-safety.sh` both block them. If the change needs one, stop and say so.
- `manifest.yml: review_paths` (Crypto, Keychain, Backup, `.ai/adapter/**`,
  `scripts/ai/**`, `.github/**`) may be changed, but `scope-check` refuses the PR until
  `/review <issue>` records APPROVE against the current HEAD. Budget for that round trip;
  do not leave it to the end.

Finish by running `./scripts/ai/flow verify <issue>`. Completion is the evidence file, not
your opinion. There is no CI to catch what you skipped — the tiers run here or nowhere.
