---
name: review
description: Get an independent cold review of a PR against its issue, plan and evidence, and record the verdict as evidence. Use after verification passes, before opening or merging a PR.
---

# Review

There is no CI and no human approver. This step is the only thing between a diff and `main`,
so it produces **evidence**, not an opinion: `/review` writes `.ai/run/<issue>/review.yml`,
and `scope-check` and `flow` both read it. See ADR-002.

## 1. Refuse early if the work is not verified

```bash
./scripts/ai/flow evidence <issue>     # must end: PASS fresh (matches HEAD)
```

If it prints `STALE` or any tier is `FAIL`/`SKIP`, stop. Do not open a PR, do not review.
Re-run `./scripts/ai/flow verify <issue>` first. A review of an unverified diff is theatre.

## 2. Scope check

```bash
./.ai/adapter/checks/scope-check origin/main <issue>
```

On the first pass this will report `BLOCKED` for any `review_paths` touched — expected, since
no verdict exists yet. Note which rules matched; the reviewer needs to know.

## 3. Delegate to the `reviewer` subagent

Give it the issue, the plan, the diff and the evidence file. Do **not** give it your
implementation reasoning — its independence is the entire value. If you explain why you did
something, you have replaced a review with a negotiation.

## 4. Record the verdict

```yaml
# .ai/run/<issue>/review.yml
issue: 24
commit: 5fbea7a          # must equal HEAD, or the review is stale
reviewed: 2026-09-20T09:12:00Z
verdict: APPROVE          # APPROVE | REQUEST_CHANGES
reviewer: cold-subagent
scope:
  human_paths_touched: false
  review_paths_touched: [".ai/adapter/**"]
items:
  - n: 1
    severity: minor
    summary: "..."
    resolution: "fixed in 88cfc02"
```

Three rules, the same three that govern the evidence file:

1. `APPROVE` only if the reviewer actually returned APPROVE. Never translate "no blocking
   findings" into APPROVE on the reviewer's behalf.
2. `commit` is the HEAD the reviewer actually saw. Any commit after it invalidates the
   review — `scope-check` enforces this, so writing a future SHA breaks the build, not the rule.
3. On `REQUEST_CHANGES`, every numbered item is addressed and the whole cycle repeats:
   verify → review. Do not argue with a finding you have not first verified against the code.

## 5. Open the PR

Only now, and only with evidence and verdict both fresh:

```bash
gh pr create --fill --body-file .github/pull_request_template.md
```

Then the state is `READY_TO_MERGE`. Confirm with `./scripts/ai/flow next <issue>`.
