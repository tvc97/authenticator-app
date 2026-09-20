---
name: review
description: Get an independent cold review of a PR against its issue, plan and evidence. Use after verification passes and a PR exists, before merging.
---

# Review

1. Open the PR if it does not exist:
   ```bash
   gh pr create --fill --body-file .github/pull_request_template.md
   ```
2. Run the scope check:
   ```bash
   ./.ai/adapter/checks/scope-check origin/main
   ```
3. Delegate to the **`reviewer` subagent**. Give it the issue, the plan, the diff and the
   evidence file. Do **not** give it your implementation reasoning — its independence is the point.
4. Post the result as a PR review.

On `REQUEST CHANGES`: address every numbered item, re-run `flow verify`, request review again.
Do not argue with a finding you have not first verified against the code.

On `APPROVE`: check CI is green and evidence is fresh, then the state is `READY_TO_MERGE`.
